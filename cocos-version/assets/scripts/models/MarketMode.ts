/**
 * 市场调整模式
 */
export enum MarketMode {
    NORMAL = 0,      // 正常模式
    ACCELERATED = 1, // 波动加快
    BULLISH = 2,     // 剧烈上涨
    BEARISH = 3,     // 剧烈下跌
    STABLE = 4       // 平稳期
}

/**
 * 市场模式工具类
 */
export class MarketModeUtil {
    /**
     * 获取模式名称
     */
    static getName(mode: MarketMode): string {
        switch (mode) {
            case MarketMode.NORMAL:
                return '正常模式';
            case MarketMode.ACCELERATED:
                return '波动加快';
            case MarketMode.BULLISH:
                return '剧烈上涨';
            case MarketMode.BEARISH:
                return '剧烈下跌';
            case MarketMode.STABLE:
                return '平稳期';
            default:
                return '未知模式';
        }
    }

    /**
     * 获取模式描述
     */
    static getDescription(mode: MarketMode): string {
        switch (mode) {
            case MarketMode.NORMAL:
                return '价值按照自然频率波动';
            case MarketMode.ACCELERATED:
                return '波动频率提升，变化更快';
            case MarketMode.BULLISH:
                return '价值大幅上涨，积极冲击';
            case MarketMode.BEARISH:
                return '价值大幅下跌，谨慎应对';
            case MarketMode.STABLE:
                return '波动幅度降低，趋于稳定';
            default:
                return '';
        }
    }

    /**
     * 获取波动系数
     */
    static getVolatilityFactor(mode: MarketMode): number {
        switch (mode) {
            case MarketMode.NORMAL:
                return 1.0;
            case MarketMode.ACCELERATED:
                return 1.5;
            case MarketMode.BULLISH:
                return 2.0;
            case MarketMode.BEARISH:
                return 2.0;
            case MarketMode.STABLE:
                return 0.5;
            default:
                return 1.0;
        }
    }

    /**
     * 获取趋势偏向（正数向上，负数向下）
     */
    static getTrendBias(mode: MarketMode): number {
        switch (mode) {
            case MarketMode.NORMAL:
                return 0.0;
            case MarketMode.ACCELERATED:
                return 0.0;
            case MarketMode.BULLISH:
                return 0.5;
            case MarketMode.BEARISH:
                return -0.5;
            case MarketMode.STABLE:
                return 0.0;
            default:
                return 0.0;
        }
    }
}
