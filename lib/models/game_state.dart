import 'player.dart';
import 'group.dart';
import 'market_mode.dart';

/// 游戏状态数据模型
class GameState {
  final List<Player> players; // 所有玩家
  final List<GameGroup> groups; // 所有组队
  final MarketMode currentMode; // 当前市场模式
  final int totalTicks; // 总Tick数
  final int currentDay; // 当前天数
  final DateTime lastUpdate; // 最后更新时间
  final String? topPlayerId; // 榜首玩家ID

  GameState({
    List<Player>? players,
    List<GameGroup>? groups,
    this.currentMode = MarketMode.normal,
    this.totalTicks = 0,
    this.currentDay = 1,
    DateTime? lastUpdate,
    this.topPlayerId,
  })  : players = players ?? [],
        groups = groups ?? [],
        lastUpdate = lastUpdate ?? DateTime.now();

  // 从JSON创建
  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      players: (json['players'] as List<dynamic>)
          .map((e) => Player.fromJson(e as Map<String, dynamic>))
          .toList(),
      groups: (json['groups'] as List<dynamic>)
          .map((e) => GameGroup.fromJson(e as Map<String, dynamic>))
          .toList(),
      currentMode: MarketMode.values[json['currentMode'] as int],
      totalTicks: json['totalTicks'] as int,
      currentDay: json['currentDay'] as int,
      lastUpdate: DateTime.parse(json['lastUpdate'] as String),
      topPlayerId: json['topPlayerId'] as String?,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'players': players.map((p) => p.toJson()).toList(),
      'groups': groups.map((g) => g.toJson()).toList(),
      'currentMode': currentMode.index,
      'totalTicks': totalTicks,
      'currentDay': currentDay,
      'lastUpdate': lastUpdate.toIso8601String(),
      'topPlayerId': topPlayerId,
    };
  }

  // 创建副本
  GameState copyWith({
    List<Player>? players,
    List<GameGroup>? groups,
    MarketMode? currentMode,
    int? totalTicks,
    int? currentDay,
    DateTime? lastUpdate,
    String? topPlayerId,
  }) {
    return GameState(
      players: players ?? this.players,
      groups: groups ?? this.groups,
      currentMode: currentMode ?? this.currentMode,
      totalTicks: totalTicks ?? this.totalTicks,
      currentDay: currentDay ?? this.currentDay,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      topPlayerId: topPlayerId ?? this.topPlayerId,
    );
  }

  // 获取玩家总数
  int get playerCount => players.length;

  // 获取活跃组队数
  int get activeGroupCount => groups.where((g) => g.isActive).length;

  // 计算中位数分数
  double get medianScore {
    if (players.isEmpty) return 0.0;
    
    final sortedScores = players.map((p) => p.totalScore).toList()..sort();
    final middle = sortedScores.length ~/ 2;
    
    if (sortedScores.length % 2 == 0) {
      return (sortedScores[middle - 1] + sortedScores[middle]) / 2;
    } else {
      return sortedScores[middle];
    }
  }

  // 获取榜首玩家
  Player? get topPlayer {
    if (topPlayerId == null) return null;
    return players.firstWhere(
      (p) => p.id == topPlayerId,
      orElse: () => players.first,
    );
  }

  // 计算需要救援的玩家数量
  int get rescueNeededCount {
    final median = medianScore;
    return players.where((p) => p.needsRescue(median)).length;
  }

  // 获取底部10%玩家
  List<Player> get bottomPlayers {
    final sorted = List<Player>.from(players)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    final count = (sorted.length * 0.1).ceil();
    return sorted.take(count).toList();
  }

  // 通过ID查找玩家
  Player? findPlayer(String id) {
    try {
      return players.firstWhere((p) => p.id == id);
    } catch (e) {
      return null;
    }
  }

  // 通过ID查找组队
  GameGroup? findGroup(String id) {
    try {
      return groups.firstWhere((g) => g.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  String toString() {
    return 'GameState(players: $playerCount, groups: $activeGroupCount, day: $currentDay, mode: ${currentMode.name})';
  }
}
