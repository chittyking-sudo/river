import { AvatarConfig } from "./AvatarConfig";
import { Coordinate } from "./Coordinate";

/**
 * 玩家数据模型
 */
export class Player {
    public id: string;                      // 唯一标识符
    public avatarConfig: AvatarConfig;      // 头像配置
    public coordinate: Coordinate;          // 三维坐标
    public pixelDensity: number;            // 像素密度 (100, 50, 25, ...)
    public dailyChances: number;            // 每日次数 (1 or 0)
    public isInGroup: boolean;              // 是否在组队中
    public groupId: string | null;          // 所属组队ID
    public createdAt: Date;                 // 创建时间
    public lastUpdated: Date;               // 最后更新时间

    constructor(
        id: string,
        avatarConfig: AvatarConfig,
        coordinate: Coordinate,
        pixelDensity: number = 100.0,
        dailyChances: number = 1,
        isInGroup: boolean = false,
        groupId: string | null = null,
        createdAt?: Date,
        lastUpdated?: Date
    ) {
        this.id = id;
        this.avatarConfig = avatarConfig;
        this.coordinate = coordinate;
        this.pixelDensity = pixelDensity;
        this.dailyChances = dailyChances;
        this.isInGroup = isInGroup;
        this.groupId = groupId;
        this.createdAt = createdAt || new Date();
        this.lastUpdated = lastUpdated || new Date();
    }

    /**
     * 从JSON创建玩家
     */
    static fromJson(json: any): Player {
        return new Player(
            json.id,
            AvatarConfig.fromJson(json.avatarConfig),
            Coordinate.fromJson(json.coordinate),
            json.pixelDensity || 100.0,
            json.dailyChances || 1,
            json.isInGroup || false,
            json.groupId || null,
            json.createdAt ? new Date(json.createdAt) : new Date(),
            json.lastUpdated ? new Date(json.lastUpdated) : new Date()
        );
    }

    /**
     * 转换为JSON
     */
    toJson(): any {
        return {
            id: this.id,
            avatarConfig: this.avatarConfig.toJson(),
            coordinate: this.coordinate.toJson(),
            pixelDensity: this.pixelDensity,
            dailyChances: this.dailyChances,
            isInGroup: this.isInGroup,
            groupId: this.groupId,
            createdAt: this.createdAt.toISOString(),
            lastUpdated: this.lastUpdated.toISOString()
        };
    }

    /**
     * 创建副本并更新某些值
     */
    copyWith(options?: {
        id?: string;
        avatarConfig?: AvatarConfig;
        coordinate?: Coordinate;
        pixelDensity?: number;
        dailyChances?: number;
        isInGroup?: boolean;
        groupId?: string | null;
        createdAt?: Date;
        lastUpdated?: Date;
    }): Player {
        return new Player(
            options?.id !== undefined ? options.id : this.id,
            options?.avatarConfig !== undefined ? options.avatarConfig : this.avatarConfig,
            options?.coordinate !== undefined ? options.coordinate : this.coordinate,
            options?.pixelDensity !== undefined ? options.pixelDensity : this.pixelDensity,
            options?.dailyChances !== undefined ? options.dailyChances : this.dailyChances,
            options?.isInGroup !== undefined ? options.isInGroup : this.isInGroup,
            options?.groupId !== undefined ? options.groupId : this.groupId,
            options?.createdAt !== undefined ? options.createdAt : this.createdAt,
            options?.lastUpdated !== undefined ? options.lastUpdated : this.lastUpdated
        );
    }

    /**
     * 计算综合分数
     */
    get totalScore(): number {
        return this.coordinate.totalScore;
    }

    /**
     * 判断是否需要救援（分数低于中位数90%）
     */
    needsRescue(median: number): boolean {
        return this.totalScore < median * 0.9;
    }

    toString(): string {
        return `Player(id: ${this.id}, score: ${this.totalScore.toFixed(2)}, density: ${this.pixelDensity}%)`;
    }
}
