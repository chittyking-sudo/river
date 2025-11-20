import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import '../models/game_state.dart';
import '../models/player.dart';
import '../models/group.dart';
import '../models/avatar_config.dart';
import '../models/market_mode.dart';
import '../services/game_engine.dart';
import '../services/storage_service.dart';

/// 游戏状态管理Provider
class GameProvider extends ChangeNotifier {
  final GameEngine _engine = GameEngine();
  final StorageService _storage = StorageService();
  
  GameState _gameState = GameState();
  String? _currentPlayerId;
  Timer? _tickTimer;
  Timer? _dailyTimer;
  
  final Random _random = Random();

  GameState get gameState => _gameState;
  String? get currentPlayerId => _currentPlayerId;
  
  Player? get currentPlayer {
    if (_currentPlayerId == null) return null;
    return _gameState.findPlayer(_currentPlayerId!);
  }

  /// 初始化Provider
  Future<void> initialize() async {
    await _storage.initialize();
    
    // 加载保存的玩家ID
    _currentPlayerId = await _storage.loadCurrentPlayerId();
    
    // 如果没有当前玩家，创建演示数据
    if (_currentPlayerId == null) {
      _initializeDemoGame();
    }
    
    notifyListeners();
  }

  /// 初始化演示游戏（包含多个AI玩家）
  void _initializeDemoGame() {
    final players = <Player>[];
    
    // 创建20个AI玩家
    for (int i = 0; i < 20; i++) {
      final player = Player(
        id: 'player_$i',
        avatarConfig: AvatarConfig(
          baseAvatar: _random.nextInt(3),
          accessory: _random.nextInt(3),
          colorTheme: _random.nextInt(3),
        ),
        coordinate: _engine.generateInitialCoordinate(),
        pixelDensity: 100.0,
      );
      players.add(player);
    }
    
    _gameState = GameState(
      players: players,
      groups: [],
      currentMode: MarketMode.normal,
      totalTicks: 0,
      currentDay: 1,
    );
    
    // 计算初始排名
    _updateRankings();
  }

  /// 创建新玩家
  Future<String> createPlayer(AvatarConfig avatarConfig) async {
    final playerId = 'player_${DateTime.now().millisecondsSinceEpoch}';
    
    final newPlayer = Player(
      id: playerId,
      avatarConfig: avatarConfig,
      coordinate: _engine.generateInitialCoordinate(),
      pixelDensity: 100.0,
    );
    
    final updatedPlayers = List<Player>.from(_gameState.players)..add(newPlayer);
    _gameState = _gameState.copyWith(players: updatedPlayers);
    
    _currentPlayerId = playerId;
    await _storage.saveCurrentPlayerId(playerId);
    
    _updateRankings();
    notifyListeners();
    
    return playerId;
  }

  /// 开始游戏循环
  void startGameLoop() {
    // 每3秒执行一次Tick
    _tickTimer?.cancel();
    _tickTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _executeTick();
    });
  }

  /// 停止游戏循环
  void stopGameLoop() {
    _tickTimer?.cancel();
    _tickTimer = null;
  }

  /// 执行单次Tick
  void _executeTick() {
    // 更新所有玩家
    final updatedPlayers = _gameState.players.map((player) {
      return _engine.updatePlayerTick(player, _gameState.currentMode);
    }).toList();
    
    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      totalTicks: _gameState.totalTicks + 1,
      lastUpdate: DateTime.now(),
    );
    
    // 检查是否触发市场调整
    final extremeCount = _engine.countExtremePlayers(_gameState.players);
    if (_engine.shouldTriggerMarketAdjustment(
      _gameState.playerCount,
      extremeCount,
    )) {
      final newMode = _engine.selectRandomMarketMode();
      _gameState = _gameState.copyWith(currentMode: newMode);
    }
    
    notifyListeners();
  }

  /// 创建组队
  Future<String?> createGroup(GroupDirection direction) async {
    final player = currentPlayer;
    if (player == null || player.dailyChances <= 0 || player.isInGroup) {
      return null;
    }
    
    final groupId = 'group_${DateTime.now().millisecondsSinceEpoch}';
    final newGroup = GameGroup(
      id: groupId,
      memberIds: [player.id],
      direction: direction,
      maxSize: 5,
    );
    
    // 更新玩家状态
    final updatedPlayer = player.copyWith(
      isInGroup: true,
      groupId: groupId,
    );
    
    final updatedPlayers = _gameState.players.map((p) {
      return p.id == player.id ? updatedPlayer : p;
    }).toList();
    
    final updatedGroups = List<GameGroup>.from(_gameState.groups)..add(newGroup);
    
    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      groups: updatedGroups,
    );
    
    notifyListeners();
    return groupId;
  }

  /// 加入组队
  Future<bool> joinGroup(String groupId) async {
    final player = currentPlayer;
    final group = _gameState.findGroup(groupId);
    
    if (player == null || group == null || !group.canJoin || player.isInGroup) {
      return false;
    }
    
    // 更新玩家
    final updatedPlayer = player.copyWith(
      isInGroup: true,
      groupId: groupId,
    );
    
    // 更新组队
    final updatedGroup = group.copyWith(
      memberIds: List<String>.from(group.memberIds)..add(player.id),
    );
    
    // 应用更新
    final updatedPlayers = _gameState.players.map((p) {
      return p.id == player.id ? updatedPlayer : p;
    }).toList();
    
    final updatedGroups = _gameState.groups.map((g) {
      return g.id == groupId ? updatedGroup : g;
    }).toList();
    
    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      groups: updatedGroups,
    );
    
    notifyListeners();
    return true;
  }

  /// 执行组队冲击
  Future<void> executeGroupImpact(String groupId) async {
    final group = _gameState.findGroup(groupId);
    if (group == null || group.memberCount < 2) return;
    
    // 对所有成员应用加成
    final updatedPlayers = _gameState.players.map((player) {
      if (group.memberIds.contains(player.id)) {
        return _engine.applyGroupBonus(player, group, group.direction);
      }
      return player;
    }).toList();
    
    // 将组队标记为不活跃
    final updatedGroups = _gameState.groups.map((g) {
      return g.id == groupId ? g.copyWith(isActive: false) : g;
    }).toList();
    
    _gameState = _gameState.copyWith(
      players: updatedPlayers,
      groups: updatedGroups,
    );
    
    _updateRankings();
    notifyListeners();
  }

  /// 融合玩家
  Future<bool> mergePlayers(String targetPlayerId) async {
    final currentP = currentPlayer;
    final targetP = _gameState.findPlayer(targetPlayerId);
    
    if (currentP == null || targetP == null) return false;
    
    // 执行融合
    final mergedPlayer = _engine.mergePlayers(currentP, targetP);
    
    // 移除目标玩家，更新当前玩家
    final updatedPlayers = _gameState.players
        .where((p) => p.id != targetPlayerId)
        .map((p) => p.id == currentP.id ? mergedPlayer : p)
        .toList();
    
    _gameState = _gameState.copyWith(players: updatedPlayers);
    
    _updateRankings();
    notifyListeners();
    return true;
  }

  /// 更新排名
  void _updateRankings() {
    final topPlayerId = _engine.calculateRankings(_gameState.players);
    _gameState = _gameState.copyWith(topPlayerId: topPlayerId);
  }

  /// 执行每日重置
  void performDailyReset() {
    final resetPlayers = _engine.performDailyReset(_gameState.players);
    
    _gameState = _gameState.copyWith(
      players: resetPlayers,
      groups: [], // 清空所有组队
      currentDay: _gameState.currentDay + 1,
    );
    
    _updateRankings();
    notifyListeners();
  }

  /// 获取排行榜
  List<Player> get leaderboard {
    final sorted = List<Player>.from(_gameState.players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    return sorted;
  }

  @override
  void dispose() {
    _tickTimer?.cancel();
    _dailyTimer?.cancel();
    super.dispose();
  }
}
