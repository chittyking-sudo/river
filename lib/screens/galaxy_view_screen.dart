import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../widgets/pixel_avatar.dart';

/// 主界面A - 银河视图（3D黑白界面）
class GalaxyViewScreen extends StatelessWidget {
  const GalaxyViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final gameState = gameProvider.gameState;
            final topPlayer = gameState.topPlayer;
            
            return Stack(
              children: [
                // 银河区域（左下方）
                Positioned(
                  left: 0,
                  bottom: 0,
                  right: MediaQuery.of(context).size.width * 0.3,
                  top: MediaQuery.of(context).size.height * 0.3,
                  child: _buildGalaxyArea(gameState.players),
                ),
                
                // 太阳区域（右上方）
                Positioned(
                  right: 40,
                  top: 40,
                  child: _buildSunArea(topPlayer),
                ),
                
                // 顶部信息栏
                Positioned(
                  left: 20,
                  top: 20,
                  child: _buildTopInfo(gameState.currentMode.name, gameState.currentDay),
                ),
                
                // 底部统计信息
                Positioned(
                  left: 20,
                  bottom: 20,
                  child: _buildBottomStats(gameState.playerCount, gameState.medianScore),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildGalaxyArea(List<Player> players) {
    return CustomPaint(
      painter: _GalaxyPainter(players: players),
    );
  }

  Widget _buildSunArea(Player? topPlayer) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.amber,
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withValues(alpha: 0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: topPlayer != null
            ? PixelAvatar(
                config: topPlayer.avatarConfig,
                size: 100,
                pixelDensity: topPlayer.pixelDensity,
              )
            : const Icon(
                Icons.star,
                color: Colors.amber,
                size: 80,
              ),
      ),
    );
  }

  Widget _buildTopInfo(String modeName, int day) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '市场模式: $modeName',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '第 $day 天',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStats(int playerCount, double medianScore) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '玩家总数: $playerCount',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '中位数: ${medianScore.toStringAsFixed(1)}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

/// 银河绘制器
class _GalaxyPainter extends CustomPainter {
  final List<Player> players;
  final Random _random = Random(42); // 固定种子保证一致性

  _GalaxyPainter({required this.players});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    // 绘制每个玩家的坐标点
    for (final player in players) {
      // 将三维坐标映射到二维平面
      final x = (player.coordinate.x / 100) * size.width;
      final y = size.height - (player.coordinate.y / 200) * size.height;
      
      // 根据Z轴（影响力）确定点的大小
      final pointSize = 2.0 + (player.coordinate.z / 50) * 3;
      
      // 根据像素密度调整透明度
      paint.color = Colors.white.withValues(alpha: player.pixelDensity / 100);
      
      canvas.drawCircle(
        Offset(x, y),
        pointSize,
        paint,
      );
    }
    
    // 绘制连接线（可选，营造银河效果）
    paint
      ..color = Colors.white.withValues(alpha: 0.1)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < players.length; i++) {
      if (_random.nextDouble() > 0.7) continue; // 随机绘制部分连接线
      
      final player1 = players[i];
      final x1 = (player1.coordinate.x / 100) * size.width;
      final y1 = size.height - (player1.coordinate.y / 200) * size.height;
      
      if (i + 1 < players.length) {
        final player2 = players[i + 1];
        final x2 = (player2.coordinate.x / 100) * size.width;
        final y2 = size.height - (player2.coordinate.y / 200) * size.height;
        
        canvas.drawLine(
          Offset(x1, y1),
          Offset(x2, y2),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GalaxyPainter oldDelegate) {
    return oldDelegate.players != players;
  }
}
