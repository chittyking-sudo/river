/**
 * 组队方向
 */
export enum GroupDirection {
    UP = 0,   // 向上冲击
    DOWN = 1  // 向下冲击
}

/**
 * 组队数据模型
 */
export class GameGroup {
    public id: string;                  // 组队唯一标识
    public memberIds: string[];         // 成员ID列表
    public direction: GroupDirection;   // 冲击方向
    public maxSize: number;             // 最大容量（2-5人）
    public createdAt: Date;             // 创建时间
    public isActive: boolean;           // 是否活跃

    constructor(
        id: string,
        memberIds: string[],
        direction: GroupDirection,
        maxSize: number = 5,
        createdAt?: Date,
        isActive: boolean = true
    ) {
        this.id = id;
        this.memberIds = memberIds;
        this.direction = direction;
        this.maxSize = maxSize;
        this.createdAt = createdAt || new Date();
        this.isActive = isActive;
    }

    /**
     * 从JSON创建组队
     */
    static fromJson(json: any): GameGroup {
        return new GameGroup(
            json.id,
            json.memberIds || [],
            json.direction || GroupDirection.UP,
            json.maxSize || 5,
            json.createdAt ? new Date(json.createdAt) : new Date(),
            json.isActive !== undefined ? json.isActive : true
        );
    }

    /**
     * 转换为JSON
     */
    toJson(): any {
        return {
            id: this.id,
            memberIds: this.memberIds,
            direction: this.direction,
            maxSize: this.maxSize,
            createdAt: this.createdAt.toISOString(),
            isActive: this.isActive
        };
    }

    /**
     * 创建副本
     */
    copyWith(options?: {
        id?: string;
        memberIds?: string[];
        direction?: GroupDirection;
        maxSize?: number;
        createdAt?: Date;
        isActive?: boolean;
    }): GameGroup {
        return new GameGroup(
            options?.id !== undefined ? options.id : this.id,
            options?.memberIds !== undefined ? options.memberIds : this.memberIds,
            options?.direction !== undefined ? options.direction : this.direction,
            options?.maxSize !== undefined ? options.maxSize : this.maxSize,
            options?.createdAt !== undefined ? options.createdAt : this.createdAt,
            options?.isActive !== undefined ? options.isActive : this.isActive
        );
    }

    /**
     * 获取剩余空位
     */
    get remainingSlots(): number {
        return this.maxSize - this.memberIds.length;
    }

    /**
     * 是否已满
     */
    get isFull(): boolean {
        return this.memberIds.length >= this.maxSize;
    }

    /**
     * 是否可以加入
     */
    get canJoin(): boolean {
        return this.isActive && !this.isFull;
    }

    /**
     * 当前人数
     */
    get memberCount(): number {
        return this.memberIds.length;
    }

    /**
     * 计算加成倍数（基于人数）
     */
    get bonusMultiplier(): number {
        switch (this.memberCount) {
            case 2:
                return 1.5;
            case 3:
                return 2.0;
            case 4:
                return 2.5;
            case 5:
                return 3.0;
            default:
                return 1.0;
        }
    }

    toString(): string {
        return `GameGroup(id: ${this.id}, members: ${this.memberCount}/${this.maxSize}, direction: ${this.direction})`;
    }
}
