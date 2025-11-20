import { Player } from "../models/Player";
import { Coordinate } from "../models/Coordinate";
import { MarketMode, MarketModeUtil } from "../models/MarketMode";
import { GameGroup, GroupDirection } from "../models/Group";

/**
 * 游戏引擎 - 核心游戏逻辑
 */
export class GameEngine {
    /**
     * 生成初始坐标
     */
    generateInitialCoordinate(): Coordinate {
        return new Coordinate(
            Math.random() * 100,                    // X轴: 0-100随机
            50.0 + (Math.random() - 0.5) * 20,     // Y轴: 40-60区间
            10.0                                    // Z轴: 初始影响力10
        );
    }

    /**
     * 价值波动算法
     */
    calculateValueFluctuation(currentValue: number, mode: MarketMode): number {
        // 基础波动幅度 ±5%
        const baseFluctuation = currentValue * 0.05;

        // 随机波动（-1 到 1）
        const randomFactor = (Math.random() - 0.5) * 2;

        // 应用市场模式的波动系数和趋势偏向
        const volatilityFactor = MarketModeUtil.getVolatilityFactor(mode);
        const trendBias = MarketModeUtil.getTrendBias(mode);

        const fluctuation = baseFluctuation * randomFactor * volatilityFactor;
        const trend = currentValue * trendBias * 0.1;

        return fluctuation + trend;
    }

    /**
     * 执行单次Tick更新
     */
    updatePlayerTick(player: Player, mode: MarketMode): Player {
        const valueChange = this.calculateValueFluctuation(player.coordinate.y, mode);

        // 更新Y轴（当前价值）
        const newY = this.clamp(player.coordinate.y + valueChange, 0.0, 200.0);

        // X轴随机变化
        const newX = this.clamp(
            player.coordinate.x + (Math.random() - 0.5) * 5,
            0.0,
            100.0
        );

        // 返回更新后的玩家
        return player.copyWith({
            coordinate: player.coordinate.copyWith({
                x: newX,
                y: newY
            }),
            lastUpdated: new Date()
        });
    }

    /**
     * 组队加成计算
     */
    applyGroupBonus(
        player: Player,
        group: GameGroup,
        direction: GroupDirection
    ): Player {
        const baseChange = player.coordinate.y * 0.1; // 基础变化10%
        const multiplier = group.bonusMultiplier;

        // 根据方向应用加成
        const change = direction === GroupDirection.UP
            ? baseChange * multiplier
            : -baseChange * multiplier;

        // 更新价值和影响力
        const newY = this.clamp(player.coordinate.y + change, 0.0, 200.0);
        const newZ = player.coordinate.z + (multiplier * 2); // 影响力增长

        return player.copyWith({
            coordinate: player.coordinate.copyWith({
                y: newY,
                z: newZ
            }),
            dailyChances: 0,      // 消耗每日次数
            isInGroup: false,     // 退出组队
            groupId: null,
            lastUpdated: new Date()
        });
    }

    /**
     * 融合两个玩家
     */
    mergePlayers(player1: Player, player2: Player): Player {
        // 计算平均值
        const newCoordinate = new Coordinate(
            (player1.coordinate.x + player2.coordinate.x) / 2,
            (player1.coordinate.y + player2.coordinate.y) / 2,
            (player1.coordinate.z + player2.coordinate.z) / 2
        );

        // 像素密度减半
        const avgDensity = (player1.pixelDensity + player2.pixelDensity) / 2;
        const newDensity = avgDensity / 2;

        return player1.copyWith({
            coordinate: newCoordinate,
            pixelDensity: newDensity,
            lastUpdated: new Date()
        });
    }

    /**
     * 救援机制 - 与新用户
     */
    rescueWithNewUser(player: Player, medianScore: number): Player {
        // 回归到中位数
        const newCoordinate = new Coordinate(
            player.coordinate.x,
            medianScore * 0.5,           // Y轴回归到中位数的50%
            player.coordinate.z + 5      // 影响力增加5
        );

        return player.copyWith({
            coordinate: newCoordinate,
            lastUpdated: new Date()
        });
    }

    /**
     * 判断是否触发市场调整
     */
    shouldTriggerMarketAdjustment(totalPlayers: number, extremePlayers: number): boolean {
        if (totalPlayers === 0) return false;

        const extremeRatio = extremePlayers / totalPlayers;

        // 根据用户规模确定阈值
        if (totalPlayers < 100) {
            return extremeRatio >= 0.20;
        } else if (totalPlayers < 1000) {
            // 10% 或 20% 随机触发
            return extremeRatio >= (Math.random() < 0.5 ? 0.10 : 0.20);
        } else {
            // 1%, 2%, 3% 随机触发
            const thresholds = [0.01, 0.02, 0.03];
            const threshold = thresholds[Math.floor(Math.random() * thresholds.length)];
            return extremeRatio >= threshold;
        }
    }

    /**
     * 随机选择新的市场模式
     */
    selectRandomMarketMode(): MarketMode {
        const modes = [
            MarketMode.ACCELERATED,
            MarketMode.BULLISH,
            MarketMode.BEARISH,
            MarketMode.STABLE
        ];
        return modes[Math.floor(Math.random() * modes.length)];
    }

    /**
     * 计算极端值玩家数量（前10%或后10%）
     */
    countExtremePlayers(players: Player[]): number {
        if (players.length === 0) return 0;

        const sorted = [...players].sort((a, b) => a.totalScore - b.totalScore);
        const topBottomCount = Math.ceil(sorted.length * 0.1);
        return topBottomCount * 2; // 前10% + 后10%
    }

    /**
     * 执行每日重置
     */
    performDailyReset(players: Player[]): Player[] {
        return players.map(player =>
            player.copyWith({
                dailyChances: 1,      // 重置每日次数
                isInGroup: false,     // 清除组队状态
                groupId: null
            })
        );
    }

    /**
     * 计算排名并返回榜首ID
     */
    calculateRankings(players: Player[]): string | null {
        if (players.length === 0) return null;

        const sorted = [...players].sort((a, b) => b.totalScore - a.totalScore);
        return sorted[0].id;
    }

    /**
     * 限制数值范围
     */
    private clamp(value: number, min: number, max: number): number {
        return Math.max(min, Math.min(max, value));
    }
}
