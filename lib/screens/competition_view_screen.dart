import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/player.dart';
import '../widgets/pixel_avatar.dart';
import 'group_chat_screen.dart';

/// 主界面B - 竞赛视图（像素小人界面）
class CompetitionViewScreen extends StatelessWidget {
  const CompetitionViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final currentPlayer = gameProvider.currentPlayer;
            final leaderboard = gameProvider.leaderboard;
            
            if (currentPlayer == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            
            return Row(
              children: [
                // 左侧：赛道曲线图
                Expanded(
                  flex: 3,
                  child: _buildRaceTrack(leaderboard, currentPlayer),
                ),
                
                // 右侧：个人属性面板
                Expanded(
                  flex: 2,
                  child: _buildAttributePanel(context, currentPlayer, gameProvider),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildRaceTrack(List<Player> leaderboard, Player currentPlayer) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '竞赛排行',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          
          // 排行榜列表
          Expanded(
            child: ListView.builder(
              itemCount: leaderboard.length.clamp(0, 10), // 显示前10名
              itemBuilder: (context, index) {
                final player = leaderboard[index];
                final isCurrentPlayer = player.id == currentPlayer.id;
                
                return _buildLeaderboardItem(
                  rank: index + 1,
                  player: player,
                  isCurrentPlayer: isCurrentPlayer,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required Player player,
    required bool isCurrentPlayer,
  }) {
    Color rankColor;
    if (rank == 1) {
      rankColor = Colors.amber;
    } else if (rank == 2) {
      rankColor = Colors.grey.shade400;
    } else if (rank == 3) {
      rankColor = Colors.brown.shade300;
    } else {
      rankColor = Colors.white.withValues(alpha: 0.7);
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? Colors.white.withValues(alpha: 0.2)
            : Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentPlayer
              ? Colors.white.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.1),
          width: isCurrentPlayer ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 排名
          SizedBox(
            width: 40,
            child: Text(
              '#$rank',
              style: TextStyle(
                color: rankColor,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // 头像
          PixelAvatar(
            config: player.avatarConfig,
            size: 40,
            pixelDensity: player.pixelDensity,
          ),
          
          const SizedBox(width: 12),
          
          // 信息
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCurrentPlayer ? '你' : 'Player $rank',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '分数: ${player.totalScore.toStringAsFixed(1)}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // 像素密度指示器
          if (player.pixelDensity < 100)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${player.pixelDensity.toInt()}%',
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttributePanel(
    BuildContext context,
    Player player,
    GameProvider gameProvider,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 头像
          Center(
            child: PixelAvatar(
              config: player.avatarConfig,
              size: 100,
              pixelDensity: player.pixelDensity,
            ),
          ),
          
          const SizedBox(height: 30),
          
          // 属性信息
          _buildAttributeItem(
            icon: Icons.trending_up,
            label: '当前价值',
            value: player.coordinate.y.toStringAsFixed(1),
          ),
          
          const SizedBox(height: 16),
          
          _buildAttributeItem(
            icon: Icons.star,
            label: '影响力',
            value: player.coordinate.z.toStringAsFixed(1),
          ),
          
          const SizedBox(height: 16),
          
          _buildAttributeItem(
            icon: Icons.assessment,
            label: '综合分数',
            value: player.totalScore.toStringAsFixed(1),
          ),
          
          const SizedBox(height: 16),
          
          _buildAttributeItem(
            icon: Icons.access_time,
            label: '今日次数',
            value: '${player.dailyChances}/1',
          ),
          
          const SizedBox(height: 16),
          
          _buildAttributeItem(
            icon: Icons.opacity,
            label: '像素密度',
            value: '${player.pixelDensity.toInt()}%',
          ),
          
          const Spacer(),
          
          // 群聊入口按钮
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: player.dailyChances > 0
                  ? () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const GroupChatScreen(),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.group, color: Colors.black),
              label: const Text(
                '组队冲击',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // 救援按钮（如果需要）
          if (player.needsRescue(gameProvider.gameState.medianScore))
            SizedBox(
              width: double.infinity,
              height: 56,
              child: OutlinedButton.icon(
                onPressed: () {
                  _showRescueDialog(context);
                },
                icon: const Icon(Icons.help_outline, color: Colors.red),
                label: const Text(
                  '需要救援',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAttributeItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.7),
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _showRescueDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900,
        title: const Text(
          '救援选项',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '你的分数较低，可以选择：\n\n'
          '1. 邀请新用户 - 双方回归中位数\n'
          '2. 融合现有用户 - 取平均值但像素密度减半',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现邀请新用户逻辑
              Navigator.pop(context);
            },
            child: const Text('邀请新用户'),
          ),
          TextButton(
            onPressed: () {
              // TODO: 实现融合逻辑
              Navigator.pop(context);
            },
            child: const Text('融合用户'),
          ),
        ],
      ),
    );
  }
}
