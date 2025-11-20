# 🌌 银河竞赛 - Cocos Creator & 微信小游戏版本

这是《银河竞赛》的 **Cocos Creator** 版本和 **微信小游戏** 版本的转换实现。

## 📦 项目概览

从原始的 Flutter 版本，我们创建了两个完整可用的游戏版本：

### 1️⃣ Cocos Creator 版本
📁 目录：`cocos-version/`

- ✅ 使用 TypeScript 开发
- ✅ 支持多平台（Web、iOS、Android）
- ✅ 完整的类型系统和IDE支持
- ✅ 组件化开发模式
- ✅ 可视化编辑器支持

### 2️⃣ 微信小游戏版本
📁 目录：`wechat-minigame/`

- ✅ 使用原生 JavaScript 开发
- ✅ 针对微信平台优化
- ✅ 完整的微信API适配
- ✅ 支持分享、授权等社交功能
- ✅ 轻量级运行时

## 🎯 核心特性对比

| 特性 | Cocos Creator | 微信小游戏 |
|------|---------------|------------|
| 开发语言 | TypeScript | JavaScript |
| 平台支持 | Web/iOS/Android | 微信 |
| 开发工具 | Cocos Creator | 微信开发者工具 |
| 组件系统 | ✅ | ❌ (手动实现) |
| 可视化编辑 | ✅ | ❌ |
| 类型检查 | ✅ | ❌ |
| 热更新 | ✅ | ✅ |
| 分享功能 | 需接入 | ✅ 原生支持 |
| 包体大小 | 较大 | 很小 |
| 性能 | 优秀 | 优秀 |

## 📂 项目结构

```
webapp/
├── cocos-version/              # Cocos Creator版本
│   ├── assets/
│   │   ├── scripts/
│   │   │   ├── models/        # 数据模型 (TypeScript)
│   │   │   ├── services/      # 服务层 (TypeScript)
│   │   │   ├── controllers/   # 控制器 (TypeScript)
│   │   │   └── ui/           # UI组件 (TypeScript)
│   │   ├── scenes/           # Cocos场景文件
│   │   ├── textures/         # 纹理资源
│   │   └── prefabs/          # 预制体
│   ├── package.json
│   ├── project.json
│   └── README.md             # Cocos版本详细文档
│
└── wechat-minigame/           # 微信小游戏版本
    ├── js/
    │   ├── models/           # 数据模型 (JavaScript)
    │   ├── services/         # 服务层 (JavaScript)
    │   ├── controllers/      # 控制器 (JavaScript)
    │   └── ui/              # UI组件 (JavaScript)
    ├── assets/
    │   ├── images/          # 图片资源
    │   └── sounds/          # 音频资源
    ├── game-adapter/        # 微信小游戏适配层
    ├── game.js              # 游戏入口
    ├── game.json            # 游戏配置
    ├── project.config.json  # 项目配置
    └── README.md            # 微信版本详细文档
```

## 🔄 核心模块说明

### 数据模型 (Models)

两个版本共享相同的数据结构：

#### Coordinate - 三维坐标
```
X轴: 随机变量 (0-100) - 不可控因素
Y轴: 当前价值 (0-200) - 核心竞争指标
Z轴: 影响力 (10+) - 长期积累值
```

#### Player - 玩家
- id: 唯一标识
- avatarConfig: 头像配置
- coordinate: 三维坐标
- pixelDensity: 像素密度 (100, 50, 25, ...)
- dailyChances: 每日次数 (0-1)
- isInGroup: 是否在组队
- groupId: 组队ID

#### Group - 组队
- id: 组队标识
- memberIds: 成员列表 (2-5人)
- direction: 冲击方向 (UP/DOWN)
- bonusMultiplier: 加成倍数 (1.5x-3.0x)

#### GameState - 游戏状态
- players: 所有玩家
- groups: 所有组队
- currentMode: 市场模式
- totalTicks: 总Tick数
- currentDay: 当前天数
- topPlayerId: 榜首玩家

#### MarketMode - 市场模式
- NORMAL: 正常模式 (波动系数1.0)
- ACCELERATED: 波动加快 (波动系数1.5)
- BULLISH: 剧烈上涨 (波动系数2.0, 趋势+0.5)
- BEARISH: 剧烈下跌 (波动系数2.0, 趋势-0.5)
- STABLE: 平稳期 (波动系数0.5)

### 游戏引擎 (GameEngine)

核心游戏逻辑实现：

1. **价值波动算法**
   ```
   fluctuation = baseFluctuation * randomFactor * volatilityFactor
   trend = currentValue * trendBias * 0.1
   newValue = currentValue + fluctuation + trend
   ```

2. **组队加成计算**
   ```
   baseChange = currentValue * 0.1
   actualChange = baseChange * bonusMultiplier * direction
   influenceGrowth = bonusMultiplier * 2
   ```

3. **融合机制**
   ```
   newCoordinate = (coord1 + coord2) / 2
   newDensity = ((density1 + density2) / 2) / 2
   ```

4. **救援机制**
   ```
   触发条件: totalScore < medianScore * 0.9
   新价值: medianScore * 0.5
   影响力: +5
   ```

### 存储服务 (StorageService)

跨平台本地存储适配：

| 平台 | 实现方式 |
|------|---------|
| Cocos Creator | cc.sys.localStorage |
| 微信小游戏 | wx.setStorageSync |
| Web浏览器 | localStorage |

### 游戏控制器 (GameController)

统一的游戏状态管理：

- 游戏循环 (每3秒一个Tick)
- 玩家状态更新
- 市场模式切换
- 组队系统管理
- 排名计算
- 数据持久化

## 🚀 快速开始

### Cocos Creator 版本

```bash
# 1. 打开 Cocos Creator
# 2. 导入项目: cocos-version/
# 3. 点击运行按钮
# 4. 选择目标平台构建
```

详细文档：[cocos-version/README.md](./cocos-version/README.md)

### 微信小游戏版本

```bash
# 1. 打开微信开发者工具
# 2. 导入项目: wechat-minigame/
# 3. 填写AppID (可用测试号)
# 4. 点击编译运行
```

详细文档：[wechat-minigame/README.md](./wechat-minigame/README.md)

## 🎮 游戏机制

### 价值波动系统
- 每3秒自动更新所有玩家价值
- 基础波动幅度 ±5%
- 根据市场模式调整波动系数和趋势
- X轴随机变化模拟不可控因素

### 组队系统
- 创建组队选择方向（向上/向下）
- 2-5人组队，人数越多加成越高
- 加成倍数：2人(1.5x)、3人(2.0x)、4人(2.5x)、5人(3.0x)
- 执行冲击消耗每日次数，增加影响力

### 市场调整机制
- 根据玩家规模和极端值比例触发
- <100人: 20%玩家达极端值触发
- <1000人: 10%或20%触发
- ≥1000人: 1%、2%或3%触发

### 排名系统
- 综合分数 = 当前价值(Y) + 影响力(Z)
- 每日0点更新排名
- 重置所有玩家每日次数
- 清空所有组队

### 救援与融合
- 触发条件：分数 < 中位数 * 90%
- 选项1：邀请新用户（双方回归中位数）
- 选项2：融合现有用户（坐标取平均，密度减半）
- 可多次融合：100% → 50% → 25% → 12.5%...

## 🎨 开发指南

### Cocos Creator 开发

#### 创建UI组件
```typescript
import { _decorator, Component, Label } from 'cc';
import { GameController } from './controllers/GameController';

const { ccclass, property } = _decorator;

@ccclass('ScorePanel')
export class ScorePanel extends Component {
    @property(Label)
    scoreLabel: Label = null;
    
    private gameController: GameController = null;
    
    onLoad() {
        this.gameController = this.node.getComponent(GameController);
    }
    
    update() {
        const player = this.gameController.getCurrentPlayer();
        if (player) {
            this.scoreLabel.string = `${player.totalScore.toFixed(1)}`;
        }
    }
}
```

#### 场景切换
```typescript
import { director } from 'cc';

// 切换场景
director.loadScene('MainGame');

// 预加载场景
director.preloadScene('MainGame', () => {
    console.log('场景预加载完成');
});
```

### 微信小游戏开发

#### Canvas绘制
```javascript
// 绘制背景
ctx.fillStyle = '#000000';
ctx.fillRect(0, 0, canvas.width, canvas.height);

// 绘制玩家点
players.forEach(player => {
    ctx.fillStyle = '#FFFFFF';
    ctx.beginPath();
    ctx.arc(x, y, 3, 0, Math.PI * 2);
    ctx.fill();
});
```

#### 触摸交互
```javascript
wx.onTouchStart((event) => {
    const touch = event.touches[0];
    this.handleTouch(touch.clientX, touch.clientY);
});
```

#### 分享功能
```javascript
wx.shareAppMessage({
    title: '银河竞赛 - 一起来竞争吧！',
    imageUrl: 'images/share.png',
    query: 'from=share'
});
```

## 🔧 技术细节

### Cocos Creator 特性

1. **组件系统**
   - 继承 Component 基类
   - 使用装饰器定义属性
   - 生命周期函数：onLoad, start, update, onDestroy

2. **节点树**
   - 层级化管理UI
   - 通过节点路径查找
   - 父子节点关系

3. **资源管理**
   - resources.load 动态加载
   - 资源释放机制
   - AssetBundle 分包加载

4. **物理系统**
   - 2D/3D 物理引擎
   - 碰撞检测
   - 刚体模拟

### 微信小游戏特性

1. **适配器模式**
   - 提供浏览器兼容API
   - Canvas、LocalStorage、XMLHttpRequest等
   - 自动适配微信环境

2. **性能优化**
   - 离屏Canvas预渲染
   - 对象池复用
   - 分帧渲染

3. **微信API**
   - 登录授权
   - 分享转发
   - 数据上报
   - 云存储

4. **触摸事件**
   - onTouchStart/Move/End
   - 多点触控支持
   - 手势识别

## 📊 性能对比

| 指标 | Cocos Creator | 微信小游戏 |
|------|---------------|------------|
| 启动速度 | 中等 | 快 |
| 运行性能 | 优秀 | 优秀 |
| 包体大小 | 较大 (5-20MB) | 小 (1-5MB) |
| 开发效率 | 高 | 中 |
| 调试便利性 | 优秀 | 良好 |
| 跨平台能力 | 强 | 仅微信 |

## 🤝 贡献者

欢迎贡献代码和提出建议！

## 📄 许可证

MIT License

## 📞 联系方式

如有问题，请提交 Issue 或 Pull Request。

---

**原版**: Flutter  
**转换版本**: Cocos Creator + 微信小游戏  
**开发时间**: 2025  
**版本**: v1.0.0
