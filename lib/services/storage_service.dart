import 'package:hive_flutter/hive_flutter.dart';
import '../models/game_state.dart';

/// 数据存储服务
class StorageService {
  static const String _gameStateBoxName = 'gameState';
  static const String _currentPlayerBoxName = 'currentPlayer';

  late Box<String> _gameStateBox;
  late Box<String> _currentPlayerBox;

  /// 初始化存储
  Future<void> initialize() async {
    await Hive.initFlutter();
    _gameStateBox = await Hive.openBox<String>(_gameStateBoxName);
    _currentPlayerBox = await Hive.openBox<String>(_currentPlayerBoxName);
  }

  /// 保存游戏状态
  Future<void> saveGameState(GameState gameState) async {
    final json = gameState.toJson();
    await _gameStateBox.put('state', json.toString());
  }

  /// 加载游戏状态
  Future<GameState?> loadGameState() async {
    try {
      final jsonString = _gameStateBox.get('state');
      if (jsonString == null) return null;
      
      // 这里需要实现JSON字符串到对象的转换
      // 简化版本，实际应该使用json.decode
      return null;
    } catch (e) {
      return null;
    }
  }

  /// 保存当前玩家ID
  Future<void> saveCurrentPlayerId(String playerId) async {
    await _currentPlayerBox.put('currentPlayerId', playerId);
  }

  /// 加载当前玩家ID
  Future<String?> loadCurrentPlayerId() async {
    return _currentPlayerBox.get('currentPlayerId');
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    await _gameStateBox.clear();
    await _currentPlayerBox.clear();
  }
}
