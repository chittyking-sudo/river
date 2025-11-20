import 'dart:math';
import '../models/player.dart';
import '../models/coordinate.dart';
import '../models/market_mode.dart';
import '../models/group.dart';

/// 游戏引擎 - 核心游戏逻辑
class GameEngine {
  final Random _random = Random();

  /// 生成初始坐标
  Coordinate generateInitialCoordinate() {
    return Coordinate(
      x: _random.nextDouble() * 100, // X轴: 0-100随机
      y: 50.0 + (_random.nextDouble() - 0.5) * 20, // Y轴: 40-60区间
      z: 10.0, // Z轴: 初始影响力10
    );
  }

  /// 价值波动算法
  double calculateValueFluctuation(
    double currentValue,
    MarketMode mode,
  ) {
    // 基础波动幅度 ±5%
    final baseFluctuation = currentValue * 0.05;
    
    // 随机波动（-1 到 1）
    final randomFactor = (_random.nextDouble() - 0.5) * 2;
    
    // 应用市场模式的波动系数和趋势偏向
    final fluctuation = baseFluctuation * randomFactor * mode.volatilityFactor;
    final trend = currentValue * mode.trendBias * 0.1;
    
    return fluctuation + trend;
  }

  /// 执行单次Tick更新
  Player updatePlayerTick(Player player, MarketMode mode) {
    final valueChange = calculateValueFluctuation(player.coordinate.y, mode);
    
    // 更新Y轴（当前价值）
    final newY = (player.coordinate.y + valueChange).clamp(0.0, 200.0);
    
    // X轴随机变化
    final newX = (player.coordinate.x + (_random.nextDouble() - 0.5) * 5).clamp(0.0, 100.0);
    
    // 返回更新后的玩家
    return player.copyWith(
      coordinate: player.coordinate.copyWith(
        x: newX,
        y: newY,
      ),
      lastUpdated: DateTime.now(),
    );
  }

  /// 组队加成计算
  Player applyGroupBonus(
    Player player,
    GameGroup group,
    GroupDirection direction,
  ) {
    final baseChange = player.coordinate.y * 0.1; // 基础变化10%
    final multiplier = group.bonusMultiplier;
    
    // 根据方向应用加成
    final change = direction == GroupDirection.up
        ? baseChange * multiplier
        : -baseChange * multiplier;
    
    // 更新价值和影响力
    final newY = (player.coordinate.y + change).clamp(0.0, 200.0);
    final newZ = player.coordinate.z + (multiplier * 2); // 影响力增长
    
    return player.copyWith(
      coordinate: player.coordinate.copyWith(
        y: newY,
        z: newZ,
      ),
      dailyChances: 0, // 消耗每日次数
      isInGroup: false, // 退出组队
      groupId: null,
      lastUpdated: DateTime.now(),
    );
  }

  /// 融合两个玩家
  Player mergePlayers(Player player1, Player player2) {
    // 计算平均值
    final newCoordinate = Coordinate(
      x: (player1.coordinate.x + player2.coordinate.x) / 2,
      y: (player1.coordinate.y + player2.coordinate.y) / 2,
      z: (player1.coordinate.z + player2.coordinate.z) / 2,
    );
    
    // 像素密度减半
    final avgDensity = (player1.pixelDensity + player2.pixelDensity) / 2;
    final newDensity = avgDensity / 2;
    
    return player1.copyWith(
      coordinate: newCoordinate,
      pixelDensity: newDensity,
      lastUpdated: DateTime.now(),
    );
  }

  /// 救援机制 - 与新用户
  Player rescueWithNewUser(Player player, double medianScore) {
    // 回归到中位数
    final newCoordinate = Coordinate(
      x: player.coordinate.x,
      y: medianScore * 0.5, // Y轴回归到中位数的50%
      z: player.coordinate.z + 5, // 影响力增加5
    );
    
    return player.copyWith(
      coordinate: newCoordinate,
      lastUpdated: DateTime.now(),
    );
  }

  /// 判断是否触发市场调整
  bool shouldTriggerMarketAdjustment(
    int totalPlayers,
    int extremePlayers,
  ) {
    if (totalPlayers == 0) return false;
    
    final extremeRatio = extremePlayers / totalPlayers;
    
    // 根据用户规模确定阈值
    if (totalPlayers < 100) {
      return extremeRatio >= 0.20;
    } else if (totalPlayers < 1000) {
      // 10% 或 20% 随机触发
      return extremeRatio >= (_random.nextBool() ? 0.10 : 0.20);
    } else {
      // 1%, 2%, 3% 随机触发
      final thresholds = [0.01, 0.02, 0.03];
      final threshold = thresholds[_random.nextInt(thresholds.length)];
      return extremeRatio >= threshold;
    }
  }

  /// 随机选择新的市场模式
  MarketMode selectRandomMarketMode() {
    final modes = [
      MarketMode.accelerated,
      MarketMode.bullish,
      MarketMode.bearish,
      MarketMode.stable,
    ];
    return modes[_random.nextInt(modes.length)];
  }

  /// 计算极端值玩家数量（前10%或后10%）
  int countExtremePlayers(List<Player> players) {
    if (players.isEmpty) return 0;
    
    final sorted = List<Player>.from(players)
      ..sort((a, b) => a.totalScore.compareTo(b.totalScore));
    
    final topBottomCount = (sorted.length * 0.1).ceil();
    return topBottomCount * 2; // 前10% + 后10%
  }

  /// 执行每日重置
  List<Player> performDailyReset(List<Player> players) {
    return players.map((player) {
      return player.copyWith(
        dailyChances: 1, // 重置每日次数
        isInGroup: false, // 清除组队状态
        groupId: null,
      );
    }).toList();
  }

  /// 计算排名并返回榜首ID
  String? calculateRankings(List<Player> players) {
    if (players.isEmpty) return null;
    
    final sorted = List<Player>.from(players)
      ..sort((a, b) => b.totalScore.compareTo(a.totalScore));
    
    return sorted.first.id;
  }
}
