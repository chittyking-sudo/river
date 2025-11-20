/// 三维坐标系统
/// X轴：随机变量（不可控因素）
/// Y轴：当前价值（核心竞争指标）
/// Z轴：影响力（长期积累值）
class Coordinate {
  final double x; // 随机变量
  final double y; // 当前价值
  final double z; // 影响力

  Coordinate({
    required this.x,
    required this.y,
    required this.z,
  });

  // 从JSON创建
  factory Coordinate.fromJson(Map<String, dynamic> json) {
    return Coordinate(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      z: (json['z'] as num).toDouble(),
    );
  }

  // 转换为JSON
  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'z': z,
    };
  }

  // 创建副本并更新某些值
  Coordinate copyWith({
    double? x,
    double? y,
    double? z,
  }) {
    return Coordinate(
      x: x ?? this.x,
      y: y ?? this.y,
      z: z ?? this.z,
    );
  }

  // 计算综合分数（用于排名）
  double get totalScore => y + z;

  @override
  String toString() {
    return 'Coordinate(x: ${x.toStringAsFixed(2)}, y: ${y.toStringAsFixed(2)}, z: ${z.toStringAsFixed(2)})';
  }
}
