# 🌌 银河竞赛 - Cocos Creator 版本

这是《银河竞赛》的 Cocos Creator 版本，使用 TypeScript 开发。

## 📁 项目结构

```
cocos-version/
├── assets/
│   ├── scripts/
│   │   ├── models/           # 数据模型
│   │   │   ├── Coordinate.ts        # 三维坐标
│   │   │   ├── AvatarConfig.ts      # 头像配置
│   │   │   ├── MarketMode.ts        # 市场模式
│   │   │   ├── Player.ts            # 玩家模型
│   │   │   ├── Group.ts             # 组队模型
│   │   │   └── GameState.ts         # 游戏状态
│   │   ├── services/         # 服务层
│   │   │   ├── GameEngine.ts        # 游戏引擎
│   │   │   └── StorageService.ts    # 存储服务
│   │   ├── controllers/      # 控制器
│   │   │   └── GameController.ts    # 游戏控制器
│   │   └── ui/              # UI组件
│   ├── scenes/              # 场景文件
│   ├── textures/            # 纹理资源
│   └── prefabs/             # 预制体
├── settings/                # 项目设置
├── package.json            # 包配置
└── project.json            # 项目配置
```

## 🚀 快速开始

### 1. 环境要求

- Cocos Creator 3.8.0 或更高版本
- Node.js 14+ 
- TypeScript 4.5+

### 2. 导入项目

1. 打开 Cocos Creator
2. 选择 "打开项目"
3. 选择 `cocos-version` 文件夹
4. 等待项目加载完成

### 3. 运行项目

1. 在 Cocos Creator 中点击顶部的 "运行" 按钮
2. 选择目标平台（浏览器/iOS/Android）
3. 点击 "构建" 开始构建项目

### 4. 构建发布

#### Web 平台
1. 点击菜单 "项目" -> "构建发布"
2. 选择平台：Web Mobile 或 Web Desktop
3. 设置发布路径
4. 点击 "构建"

#### 移动平台
1. 点击菜单 "项目" -> "构建发布"
2. 选择平台：Android 或 iOS
3. 配置相应的平台参数
4. 点击 "构建"

## 🎮 核心功能

### 数据模型 (Models)

#### Coordinate - 三维坐标系统
```typescript
class Coordinate {
    x: number;  // 随机变量 (0-100)
    y: number;  // 当前价值 (0-200)
    z: number;  // 影响力 (10+)
}
```

#### Player - 玩家模型
```typescript
class Player {
    id: string;
    avatarConfig: AvatarConfig;
    coordinate: Coordinate;
    pixelDensity: number;      // 像素密度
    dailyChances: number;      // 每日次数
    isInGroup: boolean;        // 是否在组队
    groupId: string | null;    // 组队ID
}
```

#### GameGroup - 组队模型
```typescript
class GameGroup {
    id: string;
    memberIds: string[];
    direction: GroupDirection;  // UP | DOWN
    maxSize: number;            // 最大5人
    bonusMultiplier: number;    // 加成倍数
}
```

#### GameState - 游戏状态
```typescript
class GameState {
    players: Player[];
    groups: GameGroup[];
    currentMode: MarketMode;
    totalTicks: number;
    currentDay: number;
    topPlayerId: string;
}
```

### 游戏引擎 (GameEngine)

提供核心游戏逻辑：

- `generateInitialCoordinate()` - 生成初始坐标
- `calculateValueFluctuation()` - 计算价值波动
- `updatePlayerTick()` - 更新玩家状态
- `applyGroupBonus()` - 应用组队加成
- `mergePlayers()` - 融合玩家
- `rescueWithNewUser()` - 救援机制
- `shouldTriggerMarketAdjustment()` - 市场调整判断
- `selectRandomMarketMode()` - 选择新市场模式
- `performDailyReset()` - 每日重置
- `calculateRankings()` - 计算排名

### 游戏控制器 (GameController)

管理游戏状态和流程：

```typescript
class GameController extends Component {
    onLoad()                              // 初始化
    update(deltaTime)                     // 游戏循环
    createPlayer(avatarConfig)            // 创建玩家
    createGroup(playerId, direction)      // 创建组队
    joinGroup(playerId, groupId)          // 加入组队
    executeGroupImpact(groupId)           // 执行冲击
    mergeRescue(playerId1, playerId2)     // 融合救援
}
```

### 存储服务 (StorageService)

跨平台本地存储：

```typescript
class StorageService {
    static saveGameState(gameState)       // 保存游戏状态
    static loadGameState()                // 加载游戏状态
    static saveCurrentPlayer(player)      // 保存当前玩家
    static loadCurrentPlayer()            // 加载当前玩家
    static clearAll()                     // 清除所有数据
}
```

支持平台：
- Cocos Creator (cc.sys.localStorage)
- 微信小游戏 (wx.setStorageSync)
- Web浏览器 (localStorage)

## 🎨 UI开发指南

### 场景结构建议

1. **启动场景 (Launch)**
   - Logo显示
   - 加载资源

2. **头像创建场景 (AvatarCreation)**
   - 三步选择流程
   - 基础形象选择
   - 配饰选择
   - 颜色主题选择

3. **主游戏场景 (MainGame)**
   - 银河视图 (GalaxyView)
   - 竞赛视图 (CompetitionView)
   - 切换按钮

4. **组队场景 (GroupChat)**
   - 组队列表
   - 创建组队
   - 加入组队
   - 执行冲击

### UI组件开发

创建自定义UI组件：

```typescript
import { _decorator, Component, Node, Label } from 'cc';
import { GameController } from './controllers/GameController';

const { ccclass, property } = _decorator;

@ccclass('PlayerInfoPanel')
export class PlayerInfoPanel extends Component {
    @property(Label)
    scoreLabel: Label = null;
    
    @property(Label)
    rankLabel: Label = null;
    
    private gameController: GameController = null;
    
    onLoad() {
        // 获取GameController引用
        this.gameController = this.node.getComponent(GameController);
    }
    
    update() {
        // 更新UI显示
        const player = this.gameController.getCurrentPlayer();
        if (player) {
            this.scoreLabel.string = `分数: ${player.totalScore.toFixed(1)}`;
        }
    }
}
```

## 📱 平台适配

### iOS/Android
- 自动适配不同分辨率
- 触摸事件自动转换
- 本地存储使用原生接口

### Web
- 支持桌面和移动浏览器
- 响应式布局
- LocalStorage数据持久化

### 微信小游戏
- 使用 StorageService 的微信适配
- 支持微信登录和分享
- 云存储集成

## 🔧 开发建议

### 1. 代码组织
- 保持模型、服务、控制器分离
- 使用TypeScript类型系统
- 遵循Cocos Creator组件规范

### 2. 性能优化
- 使用对象池管理频繁创建的对象
- 合理使用节点缓存
- 避免在update中进行复杂计算

### 3. 资源管理
- 使用资源预加载
- 及时释放不用的资源
- 使用纹理图集减少DrawCall

### 4. 调试技巧
- 使用Cocos Creator调试器
- console.log查看运行时状态
- 使用断点调试TypeScript代码

## 📚 API文档

详细API文档请参考各个文件中的注释。所有类和方法都包含完整的JSDoc注释。

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork本项目
2. 创建功能分支
3. 提交代码更改
4. 发起Pull Request

## 📄 许可证

MIT License

---

**开发框架**: Cocos Creator 3.8.0  
**开发语言**: TypeScript  
**版本**: v1.0.0
