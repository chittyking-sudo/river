import 'package:flutter/material.dart';
import '../models/avatar_config.dart';

/// 像素风格头像组件
class PixelAvatar extends StatelessWidget {
  final AvatarConfig config;
  final double size;
  final double pixelDensity; // 像素密度 (100, 50, 25, ...)

  const PixelAvatar({
    super.key,
    required this.config,
    this.size = 64.0,
    this.pixelDensity = 100.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _PixelAvatarPainter(
        config: config,
        pixelDensity: pixelDensity,
      ),
    );
  }
}

class _PixelAvatarPainter extends CustomPainter {
  final AvatarConfig config;
  final double pixelDensity;

  _PixelAvatarPainter({
    required this.config,
    required this.pixelDensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final pixelSize = 8.0 * (100 / pixelDensity); // 像素密度影响像素大小
    final rows = (size.height / pixelSize).ceil();
    final cols = (size.width / pixelSize).ceil();

    // 获取颜色主题
    final colors = _getColorTheme(config.colorTheme);
    
    // 绘制基础形象
    _drawBaseAvatar(canvas, size, pixelSize, rows, cols, colors);
    
    // 绘制配饰
    _drawAccessory(canvas, size, pixelSize, rows, cols, colors);
  }

  List<Color> _getColorTheme(int theme) {
    switch (theme) {
      case 0: // 蓝色主题
        return [
          Colors.blue.shade700,
          Colors.blue.shade500,
          Colors.blue.shade300,
        ];
      case 1: // 红色主题
        return [
          Colors.red.shade700,
          Colors.red.shade500,
          Colors.red.shade300,
        ];
      case 2: // 绿色主题
        return [
          Colors.green.shade700,
          Colors.green.shade500,
          Colors.green.shade300,
        ];
      default:
        return [Colors.grey, Colors.grey.shade400, Colors.grey.shade200];
    }
  }

  void _drawBaseAvatar(
    Canvas canvas,
    Size size,
    double pixelSize,
    int rows,
    int cols,
    List<Color> colors,
  ) {
    final paint = Paint()..style = PaintingStyle.fill;

    // 简化的像素头像模式
    // 基础形象0: 圆脸
    // 基础形象1: 方脸
    // 基础形象2: 椭圆脸
    
    if (config.baseAvatar == 0) {
      // 圆脸 - 画一个圆形
      paint.color = colors[0];
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 3,
        paint,
      );
      
      // 眼睛
      paint.color = Colors.white;
      canvas.drawCircle(
        Offset(size.width / 3, size.height / 2.5),
        pixelSize,
        paint,
      );
      canvas.drawCircle(
        Offset(size.width * 2 / 3, size.height / 2.5),
        pixelSize,
        paint,
      );
      
    } else if (config.baseAvatar == 1) {
      // 方脸
      paint.color = colors[1];
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.7,
          height: size.height * 0.7,
        ),
        paint,
      );
      
      // 眼睛
      paint.color = Colors.white;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width / 3, size.height / 2.5),
          width: pixelSize * 1.5,
          height: pixelSize * 1.5,
        ),
        paint,
      );
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width * 2 / 3, size.height / 2.5),
          width: pixelSize * 1.5,
          height: pixelSize * 1.5,
        ),
        paint,
      );
      
    } else {
      // 椭圆脸
      paint.color = colors[2];
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: size.width * 0.6,
          height: size.height * 0.8,
        ),
        paint,
      );
      
      // 眼睛
      paint.color = Colors.white;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width / 3, size.height / 2.5),
          width: pixelSize * 1.2,
          height: pixelSize * 1.8,
        ),
        paint,
      );
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(size.width * 2 / 3, size.height / 2.5),
          width: pixelSize * 1.2,
          height: pixelSize * 1.8,
        ),
        paint,
      );
    }
  }

  void _drawAccessory(
    Canvas canvas,
    Size size,
    double pixelSize,
    int rows,
    int cols,
    List<Color> colors,
  ) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white;

    // 配饰0: 帽子
    // 配饰1: 眼镜
    // 配饰2: 胡子
    
    if (config.accessory == 0) {
      // 帽子
      canvas.drawRect(
        Rect.fromLTWH(
          size.width * 0.2,
          size.height * 0.1,
          size.width * 0.6,
          pixelSize * 2,
        ),
        paint,
      );
    } else if (config.accessory == 1) {
      // 眼镜
      paint.color = Colors.black;
      canvas.drawCircle(
        Offset(size.width / 3, size.height / 2.5),
        pixelSize * 1.5,
        paint..style = PaintingStyle.stroke..strokeWidth = 2,
      );
      canvas.drawCircle(
        Offset(size.width * 2 / 3, size.height / 2.5),
        pixelSize * 1.5,
        paint,
      );
    } else {
      // 胡子
      paint.color = Colors.black87;
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset(size.width / 2, size.height * 0.7),
          width: size.width * 0.4,
          height: pixelSize,
        ),
        paint..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _PixelAvatarPainter oldDelegate) {
    return oldDelegate.config.identifier != config.identifier ||
        oldDelegate.pixelDensity != pixelDensity;
  }
}
