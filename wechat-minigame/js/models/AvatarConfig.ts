/**
 * 头像配置
 * 三步选择流程：基础形象 -> 配饰 -> 颜色主题
 */
export class AvatarConfig {
    public baseAvatar: number; // 基础形象选择 (0-2): 圆脸/方脸/椭圆脸
    public accessory: number;  // 配饰选择 (0-2): 帽子/眼镜/胡子
    public colorTheme: number; // 颜色主题选择 (0-2): 蓝/红/绿

    constructor(baseAvatar: number, accessory: number, colorTheme: number) {
        this.baseAvatar = baseAvatar;
        this.accessory = accessory;
        this.colorTheme = colorTheme;
    }

    /**
     * 从JSON创建头像配置
     */
    static fromJson(json: any): AvatarConfig {
        return new AvatarConfig(
            json.baseAvatar || 0,
            json.accessory || 0,
            json.colorTheme || 0
        );
    }

    /**
     * 转换为JSON
     */
    toJson(): any {
        return {
            baseAvatar: this.baseAvatar,
            accessory: this.accessory,
            colorTheme: this.colorTheme
        };
    }

    /**
     * 生成唯一标识符
     */
    get identifier(): string {
        return `${this.baseAvatar}-${this.accessory}-${this.colorTheme}`;
    }

    toString(): string {
        return `AvatarConfig(base: ${this.baseAvatar}, accessory: ${this.accessory}, color: ${this.colorTheme})`;
    }
}
