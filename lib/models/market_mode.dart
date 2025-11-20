/// 市场调整模式
enum MarketMode {
  normal, // 正常模式
  accelerated, // 波动加快
  bullish, // 剧烈上涨
  bearish, // 剧烈下跌
  stable, // 平稳期
}

extension MarketModeExtension on MarketMode {
  String get name {
    switch (this) {
      case MarketMode.normal:
        return '正常模式';
      case MarketMode.accelerated:
        return '波动加快';
      case MarketMode.bullish:
        return '剧烈上涨';
      case MarketMode.bearish:
        return '剧烈下跌';
      case MarketMode.stable:
        return '平稳期';
    }
  }

  String get description {
    switch (this) {
      case MarketMode.normal:
        return '价值按照自然频率波动';
      case MarketMode.accelerated:
        return '波动频率提升，变化更快';
      case MarketMode.bullish:
        return '价值大幅上涨，积极冲击';
      case MarketMode.bearish:
        return '价值大幅下跌，谨慎应对';
      case MarketMode.stable:
        return '波动幅度降低，趋于稳定';
    }
  }

  // 波动系数
  double get volatilityFactor {
    switch (this) {
      case MarketMode.normal:
        return 1.0;
      case MarketMode.accelerated:
        return 1.5;
      case MarketMode.bullish:
        return 2.0;
      case MarketMode.bearish:
        return 2.0;
      case MarketMode.stable:
        return 0.5;
    }
  }

  // 趋势偏向（正数向上，负数向下）
  double get trendBias {
    switch (this) {
      case MarketMode.normal:
        return 0.0;
      case MarketMode.accelerated:
        return 0.0;
      case MarketMode.bullish:
        return 0.5;
      case MarketMode.bearish:
        return -0.5;
      case MarketMode.stable:
        return 0.0;
    }
  }
}
