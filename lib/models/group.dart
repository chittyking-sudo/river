/// 组队方向
enum GroupDirection {
  up, // 向上冲击
  down, // 向下冲击
}

/// 组队数据模型
class GameGroup {
  final String id; // 组队唯一标识
  final List<String> memberIds; // 成员ID列表
  final GroupDirection direction; // 冲击方向
  final int maxSize; // 最大容量（2-5人）
  final DateTime createdAt; // 创建时间
  final bool isActive; // 是否活跃

  GameGroup({
    required this.id,
    required this.memberIds,
    required this.direction,
    this.maxSize = 5,
    DateTime? createdAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // 从JSON创建
  factory GameGroup.fromJson(Map<String, dynamic> json) {
    return GameGroup(
      id: json['id'] as String,
      memberIds: (json['memberIds'] as List<dynamic>).map((e) => e as String).toList(),
      direction: GroupDirection.values[json['direction'] as int],
      maxSize: json['maxSize'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isActive: json['isActive'] as bool,
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'memberIds': memberIds,
      'direction': direction.index,
      'maxSize': maxSize,
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
    };
  }

  // 创建副本
  GameGroup copyWith({
    String? id,
    List<String>? memberIds,
    GroupDirection? direction,
    int? maxSize,
    DateTime? createdAt,
    bool? isActive,
  }) {
    return GameGroup(
      id: id ?? this.id,
      memberIds: memberIds ?? this.memberIds,
      direction: direction ?? this.direction,
      maxSize: maxSize ?? this.maxSize,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
    );
  }

  // 获取剩余空位
  int get remainingSlots => maxSize - memberIds.length;

  // 是否已满
  bool get isFull => memberIds.length >= maxSize;

  // 是否可以加入
  bool get canJoin => isActive && !isFull;

  // 当前人数
  int get memberCount => memberIds.length;

  // 计算加成倍数（基于人数）
  double get bonusMultiplier {
    switch (memberCount) {
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

  @override
  String toString() {
    return 'GameGroup(id: $id, members: $memberCount/$maxSize, direction: $direction)';
  }
}
