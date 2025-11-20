import 'coordinate.dart';
import 'avatar_config.dart';

/// 玩家数据模型
class Player {
  final String id; // 唯一标识符
  final AvatarConfig avatarConfig; // 头像配置
  final Coordinate coordinate; // 三维坐标
  final double pixelDensity; // 像素密度 (100, 50, 25, ...)
  final int dailyChances; // 每日次数 (1 or 0)
  final bool isInGroup; // 是否在组队中
  final String? groupId; // 所属组队ID
  final DateTime createdAt; // 创建时间
  final DateTime lastUpdated; // 最后更新时间

  Player({
    required this.id,
    required this.avatarConfig,
    required this.coordinate,
    this.pixelDensity = 100.0,
    this.dailyChances = 1,
    this.isInGroup = false,
    this.groupId,
    DateTime? createdAt,
    DateTime? lastUpdated,
  })  : createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now();

  // 从JSON创建
  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      avatarConfig: AvatarConfig.fromJson(json['avatarConfig'] as Map<String, dynamic>),
      coordinate: Coordinate.fromJson(json['coordinate'] as Map<String, dynamic>),
      pixelDensity: (json['pixelDensity'] as num).toDouble(),
      dailyChances: json['dailyChances'] as int,
      isInGroup: json['isInGroup'] as bool,
      groupId: json['groupId'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'avatarConfig': avatarConfig.toJson(),
      'coordinate': coordinate.toJson(),
      'pixelDensity': pixelDensity,
      'dailyChances': dailyChances,
      'isInGroup': isInGroup,
      'groupId': groupId,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  // 创建副本并更新某些值
  Player copyWith({
    String? id,
    AvatarConfig? avatarConfig,
    Coordinate? coordinate,
    double? pixelDensity,
    int? dailyChances,
    bool? isInGroup,
    String? groupId,
    DateTime? createdAt,
    DateTime? lastUpdated,
  }) {
    return Player(
      id: id ?? this.id,
      avatarConfig: avatarConfig ?? this.avatarConfig,
      coordinate: coordinate ?? this.coordinate,
      pixelDensity: pixelDensity ?? this.pixelDensity,
      dailyChances: dailyChances ?? this.dailyChances,
      isInGroup: isInGroup ?? this.isInGroup,
      groupId: groupId ?? this.groupId,
      createdAt: createdAt ?? this.createdAt,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  // 计算综合分数
  double get totalScore => coordinate.totalScore;

  // 判断是否需要救援（分数低于中位数90%）
  bool needsRescue(double median) {
    return totalScore < median * 0.9;
  }

  @override
  String toString() {
    return 'Player(id: $id, score: ${totalScore.toStringAsFixed(2)}, density: $pixelDensity%)';
  }
}
