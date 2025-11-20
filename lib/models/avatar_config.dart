/// 头像配置
/// 三步选择流程：基础形象 -> 配饰 -> 颜色主题
class AvatarConfig {
  final int baseAvatar; // 基础形象选择 (0-2)
  final int accessory; // 配饰选择 (0-2)
  final int colorTheme; // 颜色主题选择 (0-2)

  AvatarConfig({
    required this.baseAvatar,
    required this.accessory,
    required this.colorTheme,
  });

  factory AvatarConfig.fromJson(Map<String, dynamic> json) {
    return AvatarConfig(
      baseAvatar: json['baseAvatar'] as int,
      accessory: json['accessory'] as int,
      colorTheme: json['colorTheme'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseAvatar': baseAvatar,
      'accessory': accessory,
      'colorTheme': colorTheme,
    };
  }

  // 生成唯一标识符
  String get identifier => '$baseAvatar-$accessory-$colorTheme';

  @override
  String toString() {
    return 'AvatarConfig(base: $baseAvatar, accessory: $accessory, color: $colorTheme)';
  }
}
