import { Player } from "./Player";
import { GameGroup } from "./Group";
import { MarketMode } from "./MarketMode";

/**
 * 游戏状态数据模型
 */
export class GameState {
    public players: Player[];           // 所有玩家
    public groups: GameGroup[];         // 所有组队
    public currentMode: MarketMode;     // 当前市场模式
    public totalTicks: number;          // 总Tick数
    public currentDay: number;          // 当前天数
    public lastUpdate: Date;            // 最后更新时间
    public topPlayerId: string | null;  // 榜首玩家ID

    constructor(
        players?: Player[],
        groups?: GameGroup[],
        currentMode: MarketMode = MarketMode.NORMAL,
        totalTicks: number = 0,
        currentDay: number = 1,
        lastUpdate?: Date,
        topPlayerId: string | null = null
    ) {
        this.players = players || [];
        this.groups = groups || [];
        this.currentMode = currentMode;
        this.totalTicks = totalTicks;
        this.currentDay = currentDay;
        this.lastUpdate = lastUpdate || new Date();
        this.topPlayerId = topPlayerId;
    }

    /**
     * 从JSON创建游戏状态
     */
    static fromJson(json: any): GameState {
        return new GameState(
            (json.players || []).map((p: any) => Player.fromJson(p)),
            (json.groups || []).map((g: any) => GameGroup.fromJson(g)),
            json.currentMode || MarketMode.NORMAL,
            json.totalTicks || 0,
            json.currentDay || 1,
            json.lastUpdate ? new Date(json.lastUpdate) : new Date(),
            json.topPlayerId || null
        );
    }

    /**
     * 转换为JSON
     */
    toJson(): any {
        return {
            players: this.players.map(p => p.toJson()),
            groups: this.groups.map(g => g.toJson()),
            currentMode: this.currentMode,
            totalTicks: this.totalTicks,
            currentDay: this.currentDay,
            lastUpdate: this.lastUpdate.toISOString(),
            topPlayerId: this.topPlayerId
        };
    }

    /**
     * 创建副本
     */
    copyWith(options?: {
        players?: Player[];
        groups?: GameGroup[];
        currentMode?: MarketMode;
        totalTicks?: number;
        currentDay?: number;
        lastUpdate?: Date;
        topPlayerId?: string | null;
    }): GameState {
        return new GameState(
            options?.players !== undefined ? options.players : this.players,
            options?.groups !== undefined ? options.groups : this.groups,
            options?.currentMode !== undefined ? options.currentMode : this.currentMode,
            options?.totalTicks !== undefined ? options.totalTicks : this.totalTicks,
            options?.currentDay !== undefined ? options.currentDay : this.currentDay,
            options?.lastUpdate !== undefined ? options.lastUpdate : this.lastUpdate,
            options?.topPlayerId !== undefined ? options.topPlayerId : this.topPlayerId
        );
    }

    /**
     * 获取玩家总数
     */
    get playerCount(): number {
        return this.players.length;
    }

    /**
     * 获取活跃组队数
     */
    get activeGroupCount(): number {
        return this.groups.filter(g => g.isActive).length;
    }

    /**
     * 计算中位数分数
     */
    get medianScore(): number {
        if (this.players.length === 0) return 0.0;

        const sortedScores = this.players.map(p => p.totalScore).sort((a, b) => a - b);
        const middle = Math.floor(sortedScores.length / 2);

        if (sortedScores.length % 2 === 0) {
            return (sortedScores[middle - 1] + sortedScores[middle]) / 2;
        } else {
            return sortedScores[middle];
        }
    }

    /**
     * 获取榜首玩家
     */
    get topPlayer(): Player | null {
        if (this.topPlayerId === null) return null;
        return this.findPlayer(this.topPlayerId) || (this.players.length > 0 ? this.players[0] : null);
    }

    /**
     * 计算需要救援的玩家数量
     */
    get rescueNeededCount(): number {
        const median = this.medianScore;
        return this.players.filter(p => p.needsRescue(median)).length;
    }

    /**
     * 获取底部10%玩家
     */
    get bottomPlayers(): Player[] {
        const sorted = [...this.players].sort((a, b) => a.totalScore - b.totalScore);
        const count = Math.ceil(sorted.length * 0.1);
        return sorted.slice(0, count);
    }

    /**
     * 通过ID查找玩家
     */
    findPlayer(id: string): Player | null {
        return this.players.find(p => p.id === id) || null;
    }

    /**
     * 通过ID查找组队
     */
    findGroup(id: string): GameGroup | null {
        return this.groups.find(g => g.id === id) || null;
    }

    toString(): string {
        return `GameState(players: ${this.playerCount}, groups: ${this.activeGroupCount}, day: ${this.currentDay}, mode: ${this.currentMode})`;
    }
}
