/**
 * 三维坐标系统
 * X轴：随机变量（不可控因素）
 * Y轴：当前价值（核心竞争指标）
 * Z轴：影响力（长期积累值）
 */
export class Coordinate {
    public x: number; // 随机变量 (0-100)
    public y: number; // 当前价值 (0-200)
    public z: number; // 影响力 (10+)

    constructor(x: number, y: number, z: number) {
        this.x = x;
        this.y = y;
        this.z = z;
    }

    /**
     * 从JSON创建坐标
     */
    static fromJson(json: any): Coordinate {
        return new Coordinate(
            json.x || 0,
            json.y || 0,
            json.z || 0
        );
    }

    /**
     * 转换为JSON
     */
    toJson(): any {
        return {
            x: this.x,
            y: this.y,
            z: this.z
        };
    }

    /**
     * 创建副本
     */
    copyWith(options?: { x?: number; y?: number; z?: number }): Coordinate {
        return new Coordinate(
            options?.x !== undefined ? options.x : this.x,
            options?.y !== undefined ? options.y : this.y,
            options?.z !== undefined ? options.z : this.z
        );
    }

    /**
     * 计算综合分数（用于排名）
     */
    get totalScore(): number {
        return this.y + this.z;
    }

    toString(): string {
        return `Coordinate(x: ${this.x.toFixed(2)}, y: ${this.y.toFixed(2)}, z: ${this.z.toFixed(2)})`;
    }
}
