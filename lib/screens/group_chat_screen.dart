import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../models/group.dart';

/// 组队群聊界面
class GroupChatScreen extends StatefulWidget {
  const GroupChatScreen({super.key});

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  GroupDirection? _selectedDirection;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          '组队冲击',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Consumer<GameProvider>(
          builder: (context, gameProvider, child) {
            final currentPlayer = gameProvider.currentPlayer;
            final gameState = gameProvider.gameState;
            
            if (currentPlayer == null) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            
            // 如果已经在组队中
            if (currentPlayer.isInGroup && currentPlayer.groupId != null) {
              final group = gameState.findGroup(currentPlayer.groupId!);
              if (group != null) {
                return _buildGroupView(context, group, gameProvider);
              }
            }
            
            // 创建新组队界面
            return _buildCreateGroupView(context, gameProvider);
          },
        ),
      ),
    );
  }

  Widget _buildCreateGroupView(BuildContext context, GameProvider gameProvider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 提示文字
            const Text(
              '寻找一个幸运儿/倒霉蛋',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '一起加成冲击',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 方向选择
            const Text(
              '选择冲击方向',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDirectionButton(
                  direction: GroupDirection.up,
                  label: '向上冲击',
                  icon: Icons.arrow_upward,
                  color: Colors.green,
                ),
                _buildDirectionButton(
                  direction: GroupDirection.down,
                  label: '向下冲击',
                  icon: Icons.arrow_downward,
                  color: Colors.red,
                ),
              ],
            ),
            
            const SizedBox(height: 60),
            
            // 创建组队按钮
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _selectedDirection != null
                    ? () => _createGroup(context, gameProvider)
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  '创建组队',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirectionButton({
    required GroupDirection direction,
    required String label,
    required IconData icon,
    required Color color,
  }) {
    final isSelected = _selectedDirection == direction;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDirection = direction;
        });
      },
      child: Container(
        width: 140,
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.3) : Colors.transparent,
          border: Border.all(
            color: isSelected ? color : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 3 : 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _createGroup(BuildContext context, GameProvider gameProvider) async {
    await gameProvider.createGroup(_selectedDirection!);
  }

  Widget _buildGroupView(BuildContext context, GameGroup group, GameProvider gameProvider) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 组队信息
            Text(
              '组队成员 ${group.memberCount}/${group.maxSize}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              '剩余空位: ${group.remainingSlots}',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 方向显示
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    group.direction == GroupDirection.up
                        ? Icons.arrow_upward
                        : Icons.arrow_downward,
                    color: group.direction == GroupDirection.up
                        ? Colors.green
                        : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    group.direction == GroupDirection.up ? '向上冲击' : '向下冲击',
                    style: TextStyle(
                      color: group.direction == GroupDirection.up
                          ? Colors.green
                          : Colors.red,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // 加成倍数
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    '当前加成倍数',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${group.bonusMultiplier.toStringAsFixed(1)}x',
                    style: const TextStyle(
                      color: Colors.amber,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 60),
            
            // 等待更多玩家加入
            Text(
              group.isFull ? '组队已满，准备冲击！' : '等待更多玩家加入...',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // 执行冲击按钮（需要至少2人）
            if (group.memberCount >= 2)
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () => _executeImpact(context, gameProvider, group.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    '执行冲击',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _executeImpact(
    BuildContext context,
    GameProvider gameProvider,
    String groupId,
  ) async {
    await gameProvider.executeGroupImpact(groupId);
    
    if (context.mounted) {
      Navigator.pop(context);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('冲击成功！价值已更新'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
