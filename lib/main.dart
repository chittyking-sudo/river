import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/game_provider.dart';
import 'screens/avatar_creation_screen.dart';
import 'screens/main_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(const GalaxyRaceApp());
}

class GalaxyRaceApp extends StatelessWidget {
  const GalaxyRaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider()..initialize(),
      child: MaterialApp(
        title: '银河竞赛',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: Colors.black,
          primaryColor: Colors.white,
          colorScheme: const ColorScheme.dark(
            primary: Colors.white,
            secondary: Colors.amber,
          ),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}

/// 启动屏幕
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAndNavigate();
  }

  Future<void> _checkAndNavigate() async {
    // 等待Provider初始化
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    
    final gameProvider = context.read<GameProvider>();
    
    // 检查是否有当前玩家
    if (gameProvider.currentPlayerId != null) {
      // 已有玩家，直接进入游戏
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const MainGameScreen(),
        ),
      );
    } else {
      // 新玩家，进入头像创建
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => const AvatarCreationScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo区域
            const Icon(
              Icons.stars,
              color: Colors.white,
              size: 100,
            ),
            const SizedBox(height: 30),
            const Text(
              '银河竞赛',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 60),
            const CircularProgressIndicator(
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}
