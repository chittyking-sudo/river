import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/avatar_config.dart';
import '../providers/game_provider.dart';
import '../widgets/pixel_avatar.dart';
import 'main_game_screen.dart';

/// 头像创建界面 - 三步选择流程
class AvatarCreationScreen extends StatefulWidget {
  const AvatarCreationScreen({super.key});

  @override
  State<AvatarCreationScreen> createState() => _AvatarCreationScreenState();
}

class _AvatarCreationScreenState extends State<AvatarCreationScreen> {
  int _currentStep = 0; // 当前步骤 (0-2)
  int? _selectedBase; // 选择的基础形象
  int? _selectedAccessory; // 选择的配饰
  int? _selectedColor; // 选择的颜色

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // 进度指示器
            _buildProgressIndicator(),
            
            const SizedBox(height: 40),
            
            // 标题
            _buildTitle(),
            
            const SizedBox(height: 60),
            
            // 选项区域
            Expanded(
              child: _buildSelectionArea(),
            ),
            
            // 底部按钮
            _buildBottomButton(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(3, (index) {
          final isCompleted = index < _currentStep;
          final isCurrent = index == _currentStep;
          
          return Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isCompleted
                      ? Colors.white
                      : isCurrent
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white.withValues(alpha: 0.2),
                  border: Border.all(
                    color: Colors.white,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: TextStyle(
                      color: isCompleted ? Colors.black : Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (index < 2)
                Container(
                  width: 60,
                  height: 2,
                  color: isCompleted
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.2),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTitle() {
    String title;
    String subtitle;
    
    switch (_currentStep) {
      case 0:
        title = '选择基础形象';
        subtitle = '三选一';
        break;
      case 1:
        title = '选择配饰';
        subtitle = '三选一';
        break;
      case 2:
        title = '选择颜色主题';
        subtitle = '三选一';
        break;
      default:
        title = '';
        subtitle = '';
    }
    
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionArea() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(3, (index) {
        return _buildOption(index);
      }),
    );
  }

  Widget _buildOption(int index) {
    bool isSelected = false;
    AvatarConfig previewConfig;
    
    // 根据当前步骤确定选中状态和预览配置
    switch (_currentStep) {
      case 0:
        isSelected = _selectedBase == index;
        previewConfig = AvatarConfig(
          baseAvatar: index,
          accessory: 0,
          colorTheme: 0,
        );
        break;
      case 1:
        isSelected = _selectedAccessory == index;
        previewConfig = AvatarConfig(
          baseAvatar: _selectedBase ?? 0,
          accessory: index,
          colorTheme: 0,
        );
        break;
      case 2:
        isSelected = _selectedColor == index;
        previewConfig = AvatarConfig(
          baseAvatar: _selectedBase ?? 0,
          accessory: _selectedAccessory ?? 0,
          colorTheme: index,
        );
        break;
      default:
        previewConfig = AvatarConfig(
          baseAvatar: 0,
          accessory: 0,
          colorTheme: 0,
        );
    }
    
    return GestureDetector(
      onTap: () => _selectOption(index),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          border: Border.all(
            color: isSelected ? Colors.white : Colors.white.withValues(alpha: 0.3),
            width: isSelected ? 4 : 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: PixelAvatar(
            config: previewConfig,
            size: 80,
          ),
        ),
      ),
    );
  }

  void _selectOption(int index) {
    setState(() {
      switch (_currentStep) {
        case 0:
          _selectedBase = index;
          break;
        case 1:
          _selectedAccessory = index;
          break;
        case 2:
          _selectedColor = index;
          break;
      }
    });
  }

  Widget _buildBottomButton() {
    bool canProceed = false;
    String buttonText = '下一步';
    
    switch (_currentStep) {
      case 0:
        canProceed = _selectedBase != null;
        break;
      case 1:
        canProceed = _selectedAccessory != null;
        break;
      case 2:
        canProceed = _selectedColor != null;
        buttonText = '完成创建';
        break;
    }
    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          onPressed: canProceed ? _handleNext : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            disabledBackgroundColor: Colors.white.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            buttonText,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _handleNext() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
    } else {
      // 完成创建
      _finishCreation();
    }
  }

  Future<void> _finishCreation() async {
    final config = AvatarConfig(
      baseAvatar: _selectedBase!,
      accessory: _selectedAccessory!,
      colorTheme: _selectedColor!,
    );
    
    final gameProvider = context.read<GameProvider>();
    await gameProvider.createPlayer(config);
    
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainGameScreen(),
        ),
      );
    }
  }
}
