# 🎨 银河竞赛 - UI界面层和视觉音效层添加完整指南

## 📋 目录

1. [总体概览](#总体概览)
2. [Cocos Creator版本 - UI实现](#cocos-creator版本---ui实现)
3. [Cocos Creator版本 - 音效实现](#cocos-creator版本---音效实现)
4. [微信小游戏版本 - UI实现](#微信小游戏版本---ui实现)
5. [微信小游戏版本 - 音效实现](#微信小游戏版本---音效实现)
6. [资源准备清单](#资源准备清单)
7. [完整实现示例](#完整实现示例)

---

## 总体概览

### 需要实现的界面

| 界面 | 功能说明 | 优先级 |
|------|---------|--------|
| 启动界面 | Logo展示、加载进度 | P0 |
| 头像创建 | 三步选择流程 | P0 |
| 主界面A | 银河视图（3D可视化） | P0 |
| 主界面B | 竞赛视图（排行榜） | P0 |
| 组队面板 | 创建/加入组队 | P1 |
| 救援面板 | 邀请/融合选择 | P1 |
| 设置面板 | 音效、帮助、关于 | P2 |

### 需要实现的音效

| 音效类型 | 触发场景 | 格式建议 |
|---------|---------|---------|
| 背景音乐 | 游戏主循环 | MP3/OGG |
| 按钮点击 | UI交互 | WAV |
| 组队成功 | 创建/加入组队 | WAV |
| 冲击音效 | 执行冲击 | WAV |
| 分数变化 | 价值波动 | WAV |
| 警告音效 | 分数过低 | WAV |
| 成就音效 | 排名提升 | WAV |

---

## Cocos Creator版本 - UI实现

### 1. 项目结构规划

```
cocos-version/
├── assets/
│   ├── scripts/
│   │   ├── ui/                    # UI组件目录 ⭐ 新增
│   │   │   ├── StartupUI.ts      # 启动界面
│   │   │   ├── AvatarCreationUI.ts # 头像创建界面
│   │   │   ├── GalaxyViewUI.ts   # 银河视图
│   │   │   ├── RaceViewUI.ts     # 竞赛视图
│   │   │   ├── GroupPanelUI.ts   # 组队面板
│   │   │   ├── RescuePanelUI.ts  # 救援面板
│   │   │   └── SettingsUI.ts     # 设置面板
│   │   └── ...
│   ├── scenes/
│   │   ├── Startup.scene         # 启动场景
│   │   ├── AvatarCreation.scene  # 头像创建场景
│   │   ├── MainGame.scene        # 主游戏场景
│   │   └── ...
│   ├── prefabs/                  # 预制体 ⭐ 新增
│   │   ├── PlayerDot.prefab      # 玩家点预制体
│   │   ├── GroupPanel.prefab     # 组队面板预制体
│   │   ├── RescuePanel.prefab    # 救援面板预制体
│   │   └── ...
│   ├── textures/                 # 纹理资源 ⭐ 新增
│   │   ├── ui/
│   │   │   ├── button_normal.png
│   │   │   ├── button_pressed.png
│   │   │   ├── panel_bg.png
│   │   │   └── ...
│   │   ├── avatars/
│   │   │   ├── face_round.png
│   │   │   ├── face_square.png
│   │   │   └── ...
│   │   └── effects/
│   │       ├── star.png
│   │       └── glow.png
│   ├── audio/                    # 音频资源 ⭐ 新增
│   │   ├── bgm/
│   │   │   └── main_theme.mp3
│   │   └── sfx/
│   │       ├── click.wav
│   │       ├── group_join.wav
│   │       └── ...
│   └── fonts/                    # 字体资源 ⭐ 新增
│       └── pixel_font.ttf
```

### 2. 启动界面实现

#### 创建场景文件：`Startup.scene`

在Cocos Creator编辑器中：
1. 新建场景：`Startup.scene`
2. 创建Canvas节点
3. 添加子节点结构：

```
Canvas
├── Background (Sprite)         # 背景
├── Logo (Sprite)              # Logo
├── LoadingBar (ProgressBar)   # 加载进度条
└── StartButton (Button)       # 开始按钮
```

#### 创建UI组件：`StartupUI.ts`

```typescript
import { _decorator, Component, Node, ProgressBar, Button, director, AudioSource } from 'cc';
import { StorageService } from '../services/StorageService';

const { ccclass, property } = _decorator;

@ccclass('StartupUI')
export class StartupUI extends Component {
    @property(ProgressBar)
    loadingBar: ProgressBar = null;
    
    @property(Button)
    startButton: Button = null;
    
    @property(AudioSource)
    bgmSource: AudioSource = null;

    private loadProgress: number = 0;
    private isLoading: boolean = true;

    onLoad() {
        this.startButton.node.active = false;
        this.loadAssets();
    }

    start() {
        // 播放背景音乐
        if (this.bgmSource) {
            this.bgmSource.play();
        }
    }

    async loadAssets() {
        // 模拟资源加载
        const totalSteps = 10;
        
        for (let i = 0; i <= totalSteps; i++) {
            await this.delay(200);
            this.loadProgress = i / totalSteps;
            this.updateLoadingBar();
        }
        
        this.isLoading = false;
        this.onLoadComplete();
    }

    updateLoadingBar() {
        if (this.loadingBar) {
            this.loadingBar.progress = this.loadProgress;
        }
    }

    onLoadComplete() {
        this.loadingBar.node.active = false;
        this.startButton.node.active = true;
        this.startButton.node.on('click', this.onStartClick, this);
    }

    onStartClick() {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        // 检查是否已有玩家数据
        const currentPlayer = StorageService.loadCurrentPlayer();
        
        if (currentPlayer) {
            // 已有玩家，直接进入游戏
            director.loadScene('MainGame');
        } else {
            // 新玩家，进入头像创建
            director.loadScene('AvatarCreation');
        }
    }

    private delay(ms: number): Promise<void> {
        return new Promise(resolve => setTimeout(resolve, ms));
    }
}
```

### 3. 头像创建界面实现

#### 场景结构：`AvatarCreation.scene`

```
Canvas
├── Background
├── StepIndicator (Label)       # "第1步/共3步"
├── Title (Label)               # "选择基础形象"
├── OptionsContainer (Layout)   # 选项容器
│   ├── Option1 (Button + Sprite)
│   ├── Option2 (Button + Sprite)
│   └── Option3 (Button + Sprite)
├── PreviewArea (Node)          # 预览区域
│   └── AvatarPreview (Sprite)
├── BackButton (Button)         # 返回按钮
└── NextButton (Button)         # 下一步按钮
```

#### UI组件：`AvatarCreationUI.ts`

```typescript
import { _decorator, Component, Node, Label, Button, Sprite, Layout, director } from 'cc';
import { AvatarConfig } from '../models/AvatarConfig';
import { GameController } from '../controllers/GameController';

const { ccclass, property } = _decorator;

@ccclass('AvatarCreationUI')
export class AvatarCreationUI extends Component {
    @property(Label)
    stepIndicator: Label = null;
    
    @property(Label)
    titleLabel: Label = null;
    
    @property(Node)
    optionsContainer: Node = null;
    
    @property(Sprite)
    avatarPreview: Sprite = null;
    
    @property(Button)
    backButton: Button = null;
    
    @property(Button)
    nextButton: Button = null;

    private currentStep: number = 0; // 0=基础形象, 1=配饰, 2=颜色
    private selections: number[] = [0, 0, 0]; // 存储三步的选择

    private readonly STEP_TITLES = [
        "选择基础形象",
        "选择配饰",
        "选择颜色主题"
    ];

    private readonly STEP_OPTIONS = [
        ["圆脸", "方脸", "椭圆脸"],
        ["帽子", "眼镜", "胡子"],
        ["蓝色", "红色", "绿色"]
    ];

    onLoad() {
        this.backButton.node.on('click', this.onBackClick, this);
        this.nextButton.node.on('click', this.onNextClick, this);
        
        this.updateUI();
        this.createOptions();
    }

    updateUI() {
        // 更新步骤指示器
        this.stepIndicator.string = `第${this.currentStep + 1}步 / 共3步`;
        
        // 更新标题
        this.titleLabel.string = this.STEP_TITLES[this.currentStep];
        
        // 更新按钮状态
        this.backButton.interactable = this.currentStep > 0;
        this.nextButton.node.getComponentInChildren(Label).string = 
            this.currentStep === 2 ? "完成" : "下一步";
        
        // 更新预览
        this.updatePreview();
    }

    createOptions() {
        // 清空现有选项
        this.optionsContainer.removeAllChildren();
        
        const options = this.STEP_OPTIONS[this.currentStep];
        
        options.forEach((optionText, index) => {
            const optionNode = this.createOptionButton(optionText, index);
            this.optionsContainer.addChild(optionNode);
        });
        
        // 刷新布局
        const layout = this.optionsContainer.getComponent(Layout);
        if (layout) {
            layout.updateLayout();
        }
    }

    createOptionButton(text: string, index: number): Node {
        // 创建按钮节点
        const btnNode = new Node(`Option_${index}`);
        const button = btnNode.addComponent(Button);
        const sprite = btnNode.addComponent(Sprite);
        
        // 添加标签
        const labelNode = new Node('Label');
        const label = labelNode.addComponent(Label);
        label.string = text;
        labelNode.parent = btnNode;
        
        // 绑定点击事件
        btnNode.on('click', () => {
            this.onOptionSelect(index);
        });
        
        // 高亮已选中的选项
        if (this.selections[this.currentStep] === index) {
            button.interactable = false;
        }
        
        return btnNode;
    }

    onOptionSelect(index: number) {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        this.selections[this.currentStep] = index;
        this.updateUI();
        this.createOptions(); // 重新创建以更新选中状态
    }

    updatePreview() {
        // 根据当前选择更新头像预览
        // 这里需要实现头像生成逻辑
        // 可以加载对应的Sprite资源
        
        console.log('当前选择:', this.selections);
    }

    onBackClick() {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        if (this.currentStep > 0) {
            this.currentStep--;
            this.updateUI();
            this.createOptions();
        }
    }

    onNextClick() {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        if (this.currentStep < 2) {
            // 进入下一步
            this.currentStep++;
            this.updateUI();
            this.createOptions();
        } else {
            // 完成头像创建
            this.completeAvatarCreation();
        }
    }

    completeAvatarCreation() {
        // 创建头像配置
        const avatarConfig = new AvatarConfig(
            this.selections[0],
            this.selections[1],
            this.selections[2]
        );
        
        // 创建玩家（需要获取GameController实例）
        // 这里可以通过单例模式或场景数据传递
        console.log('头像创建完成:', avatarConfig);
        
        // 进入主游戏场景
        director.loadScene('MainGame');
    }
}
```

### 4. 银河视图界面实现

#### 场景结构：`MainGame.scene` - Galaxy View

```
Canvas
├── GalaxyView (Node)           # 银河视图根节点
│   ├── Background (Sprite)     # 黑色背景
│   ├── StarsContainer (Node)   # 星星容器（所有玩家点）
│   │   └── PlayerDots (动态生成)
│   ├── Sun (Node)              # 太阳（榜首玩家）
│   │   ├── Glow (Sprite)      # 光晕效果
│   │   └── Avatar (Sprite)     # 榜首头像
│   ├── TopBar (Node)           # 顶部信息栏
│   │   ├── ModeLabel (Label)   # 市场模式
│   │   └── DayLabel (Label)    # 游戏天数
│   └── BottomBar (Node)        # 底部信息栏
│       ├── PlayerCount (Label) # 玩家总数
│       └── MedianScore (Label) # 中位数分数
├── SwitchViewButton (Button)   # 切换视图按钮
└── MenuButton (Button)         # 菜单按钮
```

#### UI组件：`GalaxyViewUI.ts`

```typescript
import { _decorator, Component, Node, Label, Sprite, Button, Prefab, instantiate, Vec3, Color } from 'cc';
import { GameController } from '../controllers/GameController';
import { Player } from '../models/Player';
import { GameState } from '../models/GameState';

const { ccclass, property } = _decorator;

@ccclass('GalaxyViewUI')
export class GalaxyViewUI extends Component {
    @property(Node)
    starsContainer: Node = null;
    
    @property(Node)
    sun: Node = null;
    
    @property(Sprite)
    sunAvatar: Sprite = null;
    
    @property(Label)
    modeLabel: Label = null;
    
    @property(Label)
    dayLabel: Label = null;
    
    @property(Label)
    playerCountLabel: Label = null;
    
    @property(Label)
    medianScoreLabel: Label = null;
    
    @property(Prefab)
    playerDotPrefab: Prefab = null;
    
    @property(GameController)
    gameController: GameController = null;

    private playerDots: Map<string, Node> = new Map();
    
    // 3D坐标到2D屏幕的映射参数
    private readonly SCREEN_WIDTH = 800;
    private readonly SCREEN_HEIGHT = 600;
    private readonly SCALE_FACTOR = 5;

    onLoad() {
        if (!this.gameController) {
            this.gameController = this.node.getComponent(GameController);
        }
    }

    start() {
        this.initializeView();
        
        // 每秒更新一次显示
        this.schedule(this.updateView, 1.0);
    }

    initializeView() {
        this.updateView();
    }

    updateView() {
        const gameState = this.gameController.getGameState();
        
        if (!gameState) return;
        
        // 更新顶部信息
        this.updateTopBar(gameState);
        
        // 更新底部信息
        this.updateBottomBar(gameState);
        
        // 更新玩家点
        this.updatePlayerDots(gameState);
        
        // 更新太阳（榜首）
        this.updateSun(gameState);
    }

    updateTopBar(gameState: GameState) {
        // 市场模式
        const modeNames = {
            0: "正常模式",
            1: "波动加快",
            2: "剧烈上涨",
            3: "剧烈下跌",
            4: "平稳期"
        };
        this.modeLabel.string = `市场: ${modeNames[gameState.currentMode]}`;
        
        // 游戏天数
        this.dayLabel.string = `第${gameState.currentDay}天`;
    }

    updateBottomBar(gameState: GameState) {
        // 玩家总数
        this.playerCountLabel.string = `玩家: ${gameState.players.length}`;
        
        // 中位数分数
        this.medianScoreLabel.string = `中位数: ${gameState.medianScore.toFixed(1)}`;
    }

    updatePlayerDots(gameState: GameState) {
        // 移除不存在的玩家点
        const currentPlayerIds = new Set(gameState.players.map(p => p.id));
        
        for (const [playerId, dotNode] of this.playerDots.entries()) {
            if (!currentPlayerIds.has(playerId)) {
                dotNode.removeFromParent();
                this.playerDots.delete(playerId);
            }
        }
        
        // 更新或创建玩家点
        gameState.players.forEach(player => {
            let dotNode = this.playerDots.get(player.id);
            
            if (!dotNode && this.playerDotPrefab) {
                // 创建新玩家点
                dotNode = instantiate(this.playerDotPrefab);
                dotNode.parent = this.starsContainer;
                this.playerDots.set(player.id, dotNode);
            }
            
            if (dotNode) {
                this.updatePlayerDot(dotNode, player);
            }
        });
    }

    updatePlayerDot(dotNode: Node, player: Player) {
        // 将3D坐标映射到2D屏幕
        const screenPos = this.coordinateToScreen(
            player.coordinate.x,
            player.coordinate.y,
            player.coordinate.z
        );
        
        dotNode.setPosition(screenPos);
        
        // 根据像素密度调整透明度
        const sprite = dotNode.getComponent(Sprite);
        if (sprite) {
            const color = sprite.color.clone();
            color.a = Math.floor(255 * player.pixelDensity / 100);
            sprite.color = color;
        }
        
        // 根据分数调整大小
        const scale = 1.0 + (player.totalScore / 1000);
        dotNode.setScale(new Vec3(scale, scale, 1));
    }

    coordinateToScreen(x: number, y: number, z: number): Vec3 {
        // 简单的3D到2D投影
        // X轴: 左右位置
        // Y轴: 上下位置
        // Z轴: 影响大小和颜色深度
        
        const screenX = (x - 50) * this.SCALE_FACTOR;
        const screenY = (y - 100) * this.SCALE_FACTOR;
        
        return new Vec3(screenX, screenY, 0);
    }

    updateSun(gameState: GameState) {
        if (!gameState.topPlayerId) return;
        
        const topPlayer = gameState.players.find(p => p.id === gameState.topPlayerId);
        
        if (topPlayer && this.sunAvatar) {
            // 更新太阳头像
            // 这里需要根据topPlayer.avatarConfig加载对应的头像图片
            console.log('榜首玩家:', topPlayer.id);
        }
    }

    onDestroy() {
        this.unschedule(this.updateView);
    }
}
```

### 5. 竞赛视图界面实现

#### UI组件：`RaceViewUI.ts`

```typescript
import { _decorator, Component, Node, Label, ScrollView, Button, Layout, Prefab, instantiate } from 'cc';
import { GameController } from '../controllers/GameController';
import { Player } from '../models/Player';

const { ccclass, property } = _decorator;

@ccclass('RaceViewUI')
export class RaceViewUI extends Component {
    @property(ScrollView)
    leaderboardScrollView: ScrollView = null;
    
    @property(Node)
    leaderboardContent: Node = null;
    
    @property(Prefab)
    rankItemPrefab: Prefab = null;
    
    // 个人属性面板
    @property(Label)
    currentValueLabel: Label = null;
    
    @property(Label)
    influenceLabel: Label = null;
    
    @property(Label)
    totalScoreLabel: Label = null;
    
    @property(Label)
    dailyChancesLabel: Label = null;
    
    @property(Label)
    pixelDensityLabel: Label = null;
    
    @property(Button)
    groupImpactButton: Button = null;
    
    @property(Button)
    rescueButton: Button = null;
    
    @property(GameController)
    gameController: GameController = null;

    onLoad() {
        if (!this.gameController) {
            this.gameController = this.node.getComponent(GameController);
        }
        
        this.groupImpactButton.node.on('click', this.onGroupImpactClick, this);
        this.rescueButton.node.on('click', this.onRescueClick, this);
    }

    start() {
        this.updateView();
        this.schedule(this.updateView, 1.0);
    }

    updateView() {
        this.updateLeaderboard();
        this.updatePlayerStats();
    }

    updateLeaderboard() {
        // 清空排行榜
        this.leaderboardContent.removeAllChildren();
        
        const gameState = this.gameController.getGameState();
        if (!gameState) return;
        
        // 获取排行榜（前10名）
        const sortedPlayers = gameState.players
            .slice()
            .sort((a, b) => b.totalScore - a.totalScore)
            .slice(0, 10);
        
        // 创建排行项
        sortedPlayers.forEach((player, index) => {
            const rankItem = this.createRankItem(player, index + 1);
            this.leaderboardContent.addChild(rankItem);
        });
        
        // 刷新布局
        const layout = this.leaderboardContent.getComponent(Layout);
        if (layout) {
            layout.updateLayout();
        }
    }

    createRankItem(player: Player, rank: number): Node {
        if (!this.rankItemPrefab) {
            // 如果没有预制体，创建简单节点
            const item = new Node(`Rank_${rank}`);
            const label = item.addComponent(Label);
            label.string = `${rank}. ${player.id.substring(0, 8)} - ${player.totalScore.toFixed(1)}`;
            return item;
        }
        
        const item = instantiate(this.rankItemPrefab);
        
        // 设置排名
        const rankLabel = item.getChildByName('Rank').getComponent(Label);
        if (rankLabel) {
            rankLabel.string = `${rank}`;
        }
        
        // 设置玩家ID
        const idLabel = item.getChildByName('PlayerId').getComponent(Label);
        if (idLabel) {
            idLabel.string = player.id.substring(0, 8);
        }
        
        // 设置分数
        const scoreLabel = item.getChildByName('Score').getComponent(Label);
        if (scoreLabel) {
            scoreLabel.string = player.totalScore.toFixed(1);
        }
        
        return item;
    }

    updatePlayerStats() {
        const currentPlayer = this.gameController.getCurrentPlayer();
        
        if (!currentPlayer) return;
        
        // 更新属性标签
        this.currentValueLabel.string = currentPlayer.coordinate.y.toFixed(1);
        this.influenceLabel.string = currentPlayer.coordinate.z.toFixed(1);
        this.totalScoreLabel.string = currentPlayer.totalScore.toFixed(1);
        this.dailyChancesLabel.string = `${currentPlayer.dailyChances}/1`;
        this.pixelDensityLabel.string = `${currentPlayer.pixelDensity.toFixed(0)}%`;
        
        // 更新按钮状态
        this.groupImpactButton.interactable = currentPlayer.dailyChances > 0 && !currentPlayer.isInGroup;
        
        // 检查是否需要救援
        const gameState = this.gameController.getGameState();
        const needsRescue = currentPlayer.totalScore < gameState.medianScore * 0.9;
        this.rescueButton.node.active = needsRescue;
    }

    onGroupImpactClick() {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        // 显示组队面板
        console.log('打开组队面板');
        // this.showGroupPanel();
    }

    onRescueClick() {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        // 显示救援面板
        console.log('打开救援面板');
        // this.showRescuePanel();
    }

    onDestroy() {
        this.unschedule(this.updateView);
    }
}
```

### 6. 组队面板实现

#### UI组件：`GroupPanelUI.ts`

```typescript
import { _decorator, Component, Node, Label, Button, ScrollView, Layout, Prefab, instantiate } from 'cc';
import { GameController } from '../controllers/GameController';
import { Group, GroupDirection } from '../models/Group';

const { ccclass, property } = _decorator;

@ccclass('GroupPanelUI')
export class GroupPanelUI extends Component {
    @property(Node)
    panelRoot: Node = null;
    
    @property(Button)
    upDirectionButton: Button = null;
    
    @property(Button)
    downDirectionButton: Button = null;
    
    @property(Button)
    createGroupButton: Button = null;
    
    @property(ScrollView)
    groupListScrollView: ScrollView = null;
    
    @property(Node)
    groupListContent: Node = null;
    
    @property(Prefab)
    groupItemPrefab: Prefab = null;
    
    @property(Button)
    closeButton: Button = null;
    
    @property(GameController)
    gameController: GameController = null;

    private selectedDirection: GroupDirection = GroupDirection.UP;

    onLoad() {
        this.panelRoot.active = false;
        
        this.upDirectionButton.node.on('click', () => this.selectDirection(GroupDirection.UP), this);
        this.downDirectionButton.node.on('click', () => this.selectDirection(GroupDirection.DOWN), this);
        this.createGroupButton.node.on('click', this.onCreateGroup, this);
        this.closeButton.node.on('click', this.hide, this);
    }

    show() {
        this.panelRoot.active = true;
        this.updateGroupList();
        this.schedule(this.updateGroupList, 1.0);
    }

    hide() {
        this.panelRoot.active = false;
        this.unschedule(this.updateGroupList);
    }

    selectDirection(direction: GroupDirection) {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        this.selectedDirection = direction;
        
        // 更新按钮状态
        this.upDirectionButton.interactable = direction !== GroupDirection.UP;
        this.downDirectionButton.interactable = direction !== GroupDirection.DOWN;
    }

    onCreateGroup() {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        const currentPlayer = this.gameController.getCurrentPlayer();
        
        if (!currentPlayer) {
            console.error('没有当前玩家');
            return;
        }
        
        if (currentPlayer.dailyChances <= 0) {
            console.error('今日次数已用完');
            return;
        }
        
        if (currentPlayer.isInGroup) {
            console.error('已在组队中');
            return;
        }
        
        // 创建组队
        const group = this.gameController.createGroup(currentPlayer.id, this.selectedDirection);
        
        if (group) {
            // 播放成功音效
            // AudioManager.playSfx('group_join');
            console.log('组队创建成功:', group.id);
            this.updateGroupList();
        }
    }

    updateGroupList() {
        // 清空列表
        this.groupListContent.removeAllChildren();
        
        const gameState = this.gameController.getGameState();
        if (!gameState) return;
        
        // 获取所有活跃组队
        const activeGroups = gameState.groups.filter(g => 
            g.memberIds.length < g.maxSize
        );
        
        // 创建组队项
        activeGroups.forEach(group => {
            const groupItem = this.createGroupItem(group);
            this.groupListContent.addChild(groupItem);
        });
        
        // 刷新布局
        const layout = this.groupListContent.getComponent(Layout);
        if (layout) {
            layout.updateLayout();
        }
    }

    createGroupItem(group: Group): Node {
        const item = instantiate(this.groupItemPrefab);
        
        // 设置组队信息
        const infoLabel = item.getChildByName('Info').getComponent(Label);
        if (infoLabel) {
            const direction = group.direction === GroupDirection.UP ? "向上" : "向下";
            const members = group.memberIds.length;
            const maxSize = group.maxSize;
            const multiplier = group.bonusMultiplier.toFixed(1);
            
            infoLabel.string = `${direction} | ${members}/${maxSize}人 | ${multiplier}x加成`;
        }
        
        // 添加加入按钮
        const joinButton = item.getChildByName('JoinButton').getComponent(Button);
        if (joinButton) {
            joinButton.node.on('click', () => {
                this.onJoinGroup(group.id);
            });
            
            // 如果组队已满，禁用按钮
            joinButton.interactable = group.memberIds.length < group.maxSize;
        }
        
        return item;
    }

    onJoinGroup(groupId: string) {
        // 播放点击音效
        // AudioManager.playSfx('click');
        
        const currentPlayer = this.gameController.getCurrentPlayer();
        
        if (!currentPlayer) {
            console.error('没有当前玩家');
            return;
        }
        
        const success = this.gameController.joinGroup(currentPlayer.id, groupId);
        
        if (success) {
            // 播放成功音效
            // AudioManager.playSfx('group_join');
            console.log('加入组队成功');
            this.updateGroupList();
        } else {
            console.error('加入组队失败');
        }
    }
}
```

---

## Cocos Creator版本 - 音效实现

### 1. 音频管理器实现

创建文件：`AudioManager.ts`

```typescript
import { _decorator, Component, AudioSource, AudioClip, resources, Node } from 'cc';

const { ccclass } = _decorator;

@ccclass('AudioManager')
export class AudioManager extends Component {
    private static instance: AudioManager = null;
    
    private bgmSource: AudioSource = null;
    private sfxSource: AudioSource = null;
    
    private bgmVolume: number = 0.5;
    private sfxVolume: number = 0.8;
    private isBgmEnabled: boolean = true;
    private isSfxEnabled: boolean = true;
    
    // 音效缓存
    private sfxCache: Map<string, AudioClip> = new Map();

    static getInstance(): AudioManager {
        if (!AudioManager.instance) {
            // 创建持久节点
            const node = new Node('AudioManager');
            AudioManager.instance = node.addComponent(AudioManager);
            // 设置为持久节点，不会被场景切换销毁
            // game.addPersistRootNode(node);
        }
        return AudioManager.instance;
    }

    onLoad() {
        if (AudioManager.instance && AudioManager.instance !== this) {
            this.node.destroy();
            return;
        }
        
        AudioManager.instance = this;
        
        // 创建BGM音源
        const bgmNode = new Node('BGM');
        bgmNode.parent = this.node;
        this.bgmSource = bgmNode.addComponent(AudioSource);
        this.bgmSource.loop = true;
        this.bgmSource.volume = this.bgmVolume;
        
        // 创建SFX音源
        const sfxNode = new Node('SFX');
        sfxNode.parent = this.node;
        this.sfxSource = sfxNode.addComponent(AudioSource);
        this.sfxSource.loop = false;
        this.sfxSource.volume = this.sfxVolume;
        
        // 从本地存储加载音频设置
        this.loadSettings();
    }

    // ==================== BGM管理 ====================

    playBgm(clipName: string) {
        if (!this.isBgmEnabled) return;
        
        resources.load(`audio/bgm/${clipName}`, AudioClip, (err, clip) => {
            if (err) {
                console.error('加载BGM失败:', err);
                return;
            }
            
            if (this.bgmSource.clip === clip && this.bgmSource.playing) {
                return; // 已经在播放相同的BGM
            }
            
            this.bgmSource.clip = clip;
            this.bgmSource.play();
        });
    }

    stopBgm() {
        if (this.bgmSource) {
            this.bgmSource.stop();
        }
    }

    pauseBgm() {
        if (this.bgmSource) {
            this.bgmSource.pause();
        }
    }

    resumeBgm() {
        if (this.bgmSource && this.isBgmEnabled) {
            this.bgmSource.play();
        }
    }

    setBgmVolume(volume: number) {
        this.bgmVolume = Math.max(0, Math.min(1, volume));
        if (this.bgmSource) {
            this.bgmSource.volume = this.bgmVolume;
        }
        this.saveSettings();
    }

    toggleBgm() {
        this.isBgmEnabled = !this.isBgmEnabled;
        
        if (this.isBgmEnabled) {
            this.resumeBgm();
        } else {
            this.pauseBgm();
        }
        
        this.saveSettings();
    }

    // ==================== SFX管理 ====================

    playSfx(clipName: string) {
        if (!this.isSfxEnabled) return;
        
        const cached = this.sfxCache.get(clipName);
        
        if (cached) {
            this.sfxSource.playOneShot(cached);
        } else {
            resources.load(`audio/sfx/${clipName}`, AudioClip, (err, clip) => {
                if (err) {
                    console.error('加载SFX失败:', err);
                    return;
                }
                
                this.sfxCache.set(clipName, clip);
                this.sfxSource.playOneShot(clip);
            });
        }
    }

    setSfxVolume(volume: number) {
        this.sfxVolume = Math.max(0, Math.min(1, volume));
        if (this.sfxSource) {
            this.sfxSource.volume = this.sfxVolume;
        }
        this.saveSettings();
    }

    toggleSfx() {
        this.isSfxEnabled = !this.isSfxEnabled;
        this.saveSettings();
    }

    // ==================== 设置持久化 ====================

    private loadSettings() {
        const settings = localStorage.getItem('audio_settings');
        if (settings) {
            const parsed = JSON.parse(settings);
            this.bgmVolume = parsed.bgmVolume ?? 0.5;
            this.sfxVolume = parsed.sfxVolume ?? 0.8;
            this.isBgmEnabled = parsed.isBgmEnabled ?? true;
            this.isSfxEnabled = parsed.isSfxEnabled ?? true;
            
            if (this.bgmSource) {
                this.bgmSource.volume = this.bgmVolume;
            }
            if (this.sfxSource) {
                this.sfxSource.volume = this.sfxVolume;
            }
        }
    }

    private saveSettings() {
        const settings = {
            bgmVolume: this.bgmVolume,
            sfxVolume: this.sfxVolume,
            isBgmEnabled: this.isBgmEnabled,
            isSfxEnabled: this.isSfxEnabled
        };
        localStorage.setItem('audio_settings', JSON.stringify(settings));
    }
}
```

### 2. 使用音频管理器

在任何组件中使用：

```typescript
import { AudioManager } from './AudioManager';

// 播放背景音乐
AudioManager.getInstance().playBgm('main_theme');

// 播放音效
AudioManager.getInstance().playSfx('click');
AudioManager.getInstance().playSfx('group_join');
AudioManager.getInstance().playSfx('impact');

// 调整音量
AudioManager.getInstance().setBgmVolume(0.5);
AudioManager.getInstance().setSfxVolume(0.8);

// 切换开关
AudioManager.getInstance().toggleBgm();
AudioManager.getInstance().toggleSfx();
```

---

## 微信小游戏版本 - UI实现

### 1. Canvas绘制系统

创建文件：`wechat-minigame/js/ui/CanvasRenderer.js`

```javascript
/**
 * Canvas渲染器
 * 负责所有UI的绘制
 */
class CanvasRenderer {
    constructor(canvas) {
        this.canvas = canvas;
        this.ctx = canvas.getContext('2d');
        this.width = canvas.width;
        this.height = canvas.height;
        
        // 颜色配置
        this.colors = {
            background: '#000000',
            foreground: '#FFFFFF',
            primary: '#FFD700',    // 金色
            success: '#4CAF50',    // 绿色
            danger: '#F44336',     // 红色
            warning: '#FF9800',    // 琥珀色
            gray: '#9E9E9E'
        };
        
        // 字体配置
        this.fonts = {
            title: '32px Arial',
            subtitle: '24px Arial',
            body: '18px Arial',
            small: '14px Arial'
        };
    }

    // ==================== 基础绘制 ====================

    clear() {
        this.ctx.fillStyle = this.colors.background;
        this.ctx.fillRect(0, 0, this.width, this.height);
    }

    drawText(text, x, y, options = {}) {
        const {
            font = this.fonts.body,
            color = this.colors.foreground,
            align = 'left',
            baseline = 'top'
        } = options;
        
        this.ctx.font = font;
        this.ctx.fillStyle = color;
        this.ctx.textAlign = align;
        this.ctx.textBaseline = baseline;
        this.ctx.fillText(text, x, y);
    }

    drawRect(x, y, width, height, options = {}) {
        const {
            fillColor = null,
            strokeColor = null,
            lineWidth = 1
        } = options;
        
        if (fillColor) {
            this.ctx.fillStyle = fillColor;
            this.ctx.fillRect(x, y, width, height);
        }
        
        if (strokeColor) {
            this.ctx.strokeStyle = strokeColor;
            this.ctx.lineWidth = lineWidth;
            this.ctx.strokeRect(x, y, width, height);
        }
    }

    drawCircle(x, y, radius, options = {}) {
        const {
            fillColor = null,
            strokeColor = null,
            lineWidth = 1
        } = options;
        
        this.ctx.beginPath();
        this.ctx.arc(x, y, radius, 0, Math.PI * 2);
        
        if (fillColor) {
            this.ctx.fillStyle = fillColor;
            this.ctx.fill();
        }
        
        if (strokeColor) {
            this.ctx.strokeStyle = strokeColor;
            this.ctx.lineWidth = lineWidth;
            this.ctx.stroke();
        }
    }

    drawButton(x, y, width, height, text, options = {}) {
        const {
            bgColor = this.colors.primary,
            textColor = this.colors.background,
            font = this.fonts.body,
            pressed = false
        } = options;
        
        // 绘制按钮背景
        const offset = pressed ? 2 : 0;
        this.drawRect(x + offset, y + offset, width, height, {
            fillColor: bgColor,
            strokeColor: this.colors.foreground,
            lineWidth: 2
        });
        
        // 绘制按钮文字
        this.drawText(text, x + width / 2 + offset, y + height / 2 + offset, {
            font: font,
            color: textColor,
            align: 'center',
            baseline: 'middle'
        });
    }

    // ==================== 高级UI组件 ====================

    drawPanel(x, y, width, height, title = null) {
        // 绘制面板背景
        this.drawRect(x, y, width, height, {
            fillColor: 'rgba(0, 0, 0, 0.8)',
            strokeColor: this.colors.foreground,
            lineWidth: 2
        });
        
        // 绘制标题
        if (title) {
            this.drawRect(x, y, width, 40, {
                fillColor: this.colors.primary
            });
            
            this.drawText(title, x + width / 2, y + 20, {
                font: this.fonts.subtitle,
                color: this.colors.background,
                align: 'center',
                baseline: 'middle'
            });
        }
    }

    drawProgressBar(x, y, width, height, progress, options = {}) {
        const {
            bgColor = this.colors.gray,
            fillColor = this.colors.primary
        } = options;
        
        // 绘制背景
        this.drawRect(x, y, width, height, {
            fillColor: bgColor
        });
        
        // 绘制进度
        const fillWidth = width * Math.max(0, Math.min(1, progress));
        this.drawRect(x, y, fillWidth, height, {
            fillColor: fillColor
        });
        
        // 绘制边框
        this.drawRect(x, y, width, height, {
            strokeColor: this.colors.foreground,
            lineWidth: 2
        });
    }

    drawScrollableList(x, y, width, height, items, scrollOffset = 0, selectedIndex = -1) {
        const itemHeight = 50;
        const visibleItems = Math.floor(height / itemHeight);
        
        // 绘制背景
        this.drawPanel(x, y, width, height);
        
        // 绘制列表项
        const startIndex = Math.floor(scrollOffset / itemHeight);
        const endIndex = Math.min(items.length, startIndex + visibleItems + 1);
        
        for (let i = startIndex; i < endIndex; i++) {
            const itemY = y + (i * itemHeight) - scrollOffset;
            
            if (itemY + itemHeight < y || itemY > y + height) {
                continue; // 不在可见区域
            }
            
            // 高亮选中项
            if (i === selectedIndex) {
                this.drawRect(x, itemY, width, itemHeight, {
                    fillColor: 'rgba(255, 215, 0, 0.3)'
                });
            }
            
            // 绘制分隔线
            if (i > startIndex) {
                this.drawRect(x, itemY, width, 1, {
                    fillColor: this.colors.gray
                });
            }
            
            // 绘制文本
            this.drawText(items[i], x + 10, itemY + itemHeight / 2, {
                baseline: 'middle'
            });
        }
    }

    // ==================== 游戏特定UI ====================

    drawPlayerDot(x, y, player) {
        const radius = 3 + (player.totalScore / 500);
        const alpha = player.pixelDensity / 100;
        
        this.drawCircle(x, y, radius, {
            fillColor: `rgba(255, 255, 255, ${alpha})`
        });
    }

    drawSun(x, y, radius, topPlayer) {
        // 绘制光晕
        const gradient = this.ctx.createRadialGradient(x, y, 0, x, y, radius * 1.5);
        gradient.addColorStop(0, 'rgba(255, 215, 0, 0.8)');
        gradient.addColorStop(0.5, 'rgba(255, 215, 0, 0.4)');
        gradient.addColorStop(1, 'rgba(255, 215, 0, 0)');
        
        this.ctx.fillStyle = gradient;
        this.ctx.beginPath();
        this.ctx.arc(x, y, radius * 1.5, 0, Math.PI * 2);
        this.ctx.fill();
        
        // 绘制太阳主体
        this.drawCircle(x, y, radius, {
            fillColor: this.colors.primary
        });
        
        // 绘制玩家头像（简化版）
        if (topPlayer) {
            this.drawText('👑', x, y, {
                font: this.fonts.title,
                align: 'center',
                baseline: 'middle'
            });
        }
    }

    drawLeaderboard(x, y, width, height, players) {
        this.drawPanel(x, y, width, height, '排行榜');
        
        const contentY = y + 50;
        const itemHeight = 40;
        
        players.slice(0, 10).forEach((player, index) => {
            const itemY = contentY + index * itemHeight;
            
            // 排名
            this.drawText(`${index + 1}`, x + 20, itemY + itemHeight / 2, {
                font: this.fonts.subtitle,
                color: index < 3 ? this.colors.primary : this.colors.foreground,
                baseline: 'middle'
            });
            
            // 玩家ID
            this.drawText(player.id.substring(0, 8), x + 60, itemY + itemHeight / 2, {
                baseline: 'middle'
            });
            
            // 分数
            this.drawText(player.totalScore.toFixed(1), x + width - 80, itemY + itemHeight / 2, {
                color: this.colors.primary,
                align: 'right',
                baseline: 'middle'
            });
        });
    }

    drawPlayerStats(x, y, width, height, player, gameState) {
        this.drawPanel(x, y, width, height, '个人属性');
        
        const contentY = y + 50;
        const lineHeight = 35;
        let currentY = contentY + 20;
        
        const stats = [
            { label: '当前价值', value: player.coordinate.y.toFixed(1), color: this.colors.foreground },
            { label: '影响力', value: player.coordinate.z.toFixed(1), color: this.colors.foreground },
            { label: '综合分数', value: player.totalScore.toFixed(1), color: this.colors.primary },
            { label: '今日次数', value: `${player.dailyChances}/1`, color: this.colors.foreground },
            { label: '像素密度', value: `${player.pixelDensity}%`, color: this.colors.foreground }
        ];
        
        stats.forEach(stat => {
            this.drawText(stat.label + ':', x + 20, currentY, {
                font: this.fonts.body
            });
            
            this.drawText(stat.value, x + width - 20, currentY, {
                font: this.fonts.body,
                color: stat.color,
                align: 'right'
            });
            
            currentY += lineHeight;
        });
        
        // 组队冲击按钮
        const btnY = currentY + 20;
        this.drawButton(x + 20, btnY, width - 40, 50, '组队冲击', {
            bgColor: player.dailyChances > 0 ? this.colors.success : this.colors.gray
        });
        
        // 救援按钮（分数过低时显示）
        const needsRescue = player.totalScore < gameState.medianScore * 0.9;
        if (needsRescue) {
            this.drawButton(x + 20, btnY + 60, width - 40, 50, '请求救援', {
                bgColor: this.colors.danger
            });
        }
    }
}

// 导出
if (typeof module !== 'undefined' && module.exports) {
    module.exports = CanvasRenderer;
}
```

### 2. UI管理器

创建文件：`wechat-minigame/js/ui/UIManager.js`

```javascript
/**
 * UI管理器
 * 管理所有界面的显示和切换
 */
class UIManager {
    constructor(canvas, gameController) {
        this.canvas = canvas;
        this.gameController = gameController;
        this.renderer = new CanvasRenderer(canvas);
        
        // 当前视图
        this.currentView = 'startup'; // startup, avatarCreation, galaxy, race
        
        // 头像创建状态
        this.avatarStep = 0;
        this.avatarSelections = [0, 0, 0];
        
        // 触摸状态
        this.touchHandlers = new Map();
        
        this.init();
    }

    init() {
        // 绑定触摸事件
        wx.onTouchStart(this.handleTouchStart.bind(this));
        wx.onTouchMove(this.handleTouchMove.bind(this));
        wx.onTouchEnd(this.handleTouchEnd.bind(this));
    }

    // ==================== 视图切换 ====================

    switchView(viewName) {
        console.log('切换视图:', viewName);
        this.currentView = viewName;
        this.touchHandlers.clear();
        this.render();
    }

    // ==================== 渲染入口 ====================

    render() {
        this.renderer.clear();
        
        switch (this.currentView) {
            case 'startup':
                this.renderStartup();
                break;
            case 'avatarCreation':
                this.renderAvatarCreation();
                break;
            case 'galaxy':
                this.renderGalaxyView();
                break;
            case 'race':
                this.renderRaceView();
                break;
        }
    }

    // ==================== 启动界面 ====================

    renderStartup() {
        const width = this.canvas.width;
        const height = this.canvas.height;
        
        // 绘制Logo
        this.renderer.drawText('🌌 银河竞赛', width / 2, height / 3, {
            font: '48px Arial',
            color: this.renderer.colors.primary,
            align: 'center',
            baseline: 'middle'
        });
        
        // 绘制副标题
        this.renderer.drawText('Galaxy Race', width / 2, height / 3 + 60, {
            font: this.renderer.fonts.subtitle,
            color: this.renderer.colors.foreground,
            align: 'center',
            baseline: 'middle'
        });
        
        // 绘制开始按钮
        const btnWidth = 200;
        const btnHeight = 60;
        const btnX = (width - btnWidth) / 2;
        const btnY = height * 2 / 3;
        
        this.renderer.drawButton(btnX, btnY, btnWidth, btnHeight, '开始游戏');
        
        // 注册按钮触摸区域
        this.touchHandlers.set('startButton', {
            x: btnX,
            y: btnY,
            width: btnWidth,
            height: btnHeight,
            onTap: () => {
                // 检查是否有玩家数据
                const currentPlayer = this.gameController.getCurrentPlayer();
                if (currentPlayer) {
                    this.switchView('galaxy');
                } else {
                    this.switchView('avatarCreation');
                }
            }
        });
    }

    // ==================== 头像创建界面 ====================

    renderAvatarCreation() {
        const width = this.canvas.width;
        const height = this.canvas.height;
        
        const stepTitles = ['选择基础形象', '选择配饰', '选择颜色主题'];
        const stepOptions = [
            ['圆脸', '方脸', '椭圆脸'],
            ['帽子', '眼镜', '胡子'],
            ['蓝色', '红色', '绿色']
        ];
        
        // 绘制标题
        this.renderer.drawText(stepTitles[this.avatarStep], width / 2, 80, {
            font: this.renderer.fonts.title,
            color: this.renderer.colors.primary,
            align: 'center'
        });
        
        // 绘制步骤指示器
        this.renderer.drawText(`第${this.avatarStep + 1}步 / 共3步`, width / 2, 130, {
            font: this.renderer.fonts.body,
            color: this.renderer.colors.foreground,
            align: 'center'
        });
        
        // 绘制选项按钮
        const options = stepOptions[this.avatarStep];
        const btnWidth = 150;
        const btnHeight = 60;
        const spacing = 30;
        const totalWidth = options.length * btnWidth + (options.length - 1) * spacing;
        const startX = (width - totalWidth) / 2;
        const btnY = height / 2 - 30;
        
        options.forEach((option, index) => {
            const btnX = startX + index * (btnWidth + spacing);
            const isSelected = this.avatarSelections[this.avatarStep] === index;
            
            this.renderer.drawButton(btnX, btnY, btnWidth, btnHeight, option, {
                bgColor: isSelected ? this.renderer.colors.primary : this.renderer.colors.gray
            });
            
            // 注册触摸区域
            this.touchHandlers.set(`option_${index}`, {
                x: btnX,
                y: btnY,
                width: btnWidth,
                height: btnHeight,
                onTap: () => {
                    this.avatarSelections[this.avatarStep] = index;
                    this.render();
                }
            });
        });
        
        // 绘制导航按钮
        const navBtnWidth = 100;
        const navBtnHeight = 50;
        const navY = height - 100;
        
        // 返回按钮
        if (this.avatarStep > 0) {
            this.renderer.drawButton(50, navY, navBtnWidth, navBtnHeight, '返回');
            
            this.touchHandlers.set('backButton', {
                x: 50,
                y: navY,
                width: navBtnWidth,
                height: navBtnHeight,
                onTap: () => {
                    this.avatarStep--;
                    this.render();
                }
            });
        }
        
        // 下一步/完成按钮
        const nextBtnText = this.avatarStep === 2 ? '完成' : '下一步';
        const nextBtnX = width - 50 - navBtnWidth;
        
        this.renderer.drawButton(nextBtnX, navY, navBtnWidth, navBtnHeight, nextBtnText);
        
        this.touchHandlers.set('nextButton', {
            x: nextBtnX,
            y: navY,
            width: navBtnWidth,
            height: navBtnHeight,
            onTap: () => {
                if (this.avatarStep < 2) {
                    this.avatarStep++;
                    this.render();
                } else {
                    this.completeAvatarCreation();
                }
            }
        });
    }

    completeAvatarCreation() {
        // 创建头像配置
        const avatarConfig = {
            baseAvatar: this.avatarSelections[0],
            accessory: this.avatarSelections[1],
            colorTheme: this.avatarSelections[2]
        };
        
        // 创建玩家
        this.gameController.createPlayer(avatarConfig);
        
        // 进入银河视图
        this.switchView('galaxy');
    }

    // ==================== 银河视图 ====================

    renderGalaxyView() {
        const width = this.canvas.width;
        const height = this.canvas.height;
        const gameState = this.gameController.getGameState();
        
        if (!gameState) return;
        
        // 绘制顶部信息栏
        const modeNames = ['正常模式', '波动加快', '剧烈上涨', '剧烈下跌', '平稳期'];
        this.renderer.drawText(`市场: ${modeNames[gameState.currentMode]}`, 20, 20, {
            font: this.renderer.fonts.body
        });
        
        this.renderer.drawText(`第${gameState.currentDay}天`, width - 20, 20, {
            font: this.renderer.fonts.body,
            align: 'right'
        });
        
        // 绘制底部信息栏
        this.renderer.drawText(`玩家: ${gameState.players.length}`, 20, height - 40, {
            font: this.renderer.fonts.body
        });
        
        this.renderer.drawText(`中位数: ${gameState.medianScore.toFixed(1)}`, width - 20, height - 40, {
            font: this.renderer.fonts.body,
            align: 'right'
        });
        
        // 绘制太阳（榜首）
        const sunX = width - 100;
        const sunY = 100;
        const topPlayer = gameState.players.find(p => p.id === gameState.topPlayerId);
        this.renderer.drawSun(sunX, sunY, 40, topPlayer);
        
        // 绘制所有玩家点
        const galaxyX = width / 4;
        const galaxyY = height / 2;
        const scale = 4;
        
        gameState.players.forEach(player => {
            const x = galaxyX + (player.coordinate.x - 50) * scale;
            const y = galaxyY - (player.coordinate.y - 100) * scale;
            
            this.renderer.drawPlayerDot(x, y, player);
        });
        
        // 绘制切换视图按钮
        const btnWidth = 120;
        const btnHeight = 50;
        this.renderer.drawButton(width / 2 - btnWidth / 2, height - 80, btnWidth, btnHeight, '排行榜');
        
        this.touchHandlers.set('switchView', {
            x: width / 2 - btnWidth / 2,
            y: height - 80,
            width: btnWidth,
            height: btnHeight,
            onTap: () => {
                this.switchView('race');
            }
        });
    }

    // ==================== 竞赛视图 ====================

    renderRaceView() {
        const width = this.canvas.width;
        const height = this.canvas.height;
        const gameState = this.gameController.getGameState();
        const currentPlayer = this.gameController.getCurrentPlayer();
        
        if (!gameState || !currentPlayer) return;
        
        // 排序玩家
        const sortedPlayers = gameState.players
            .slice()
            .sort((a, b) => b.totalScore - a.totalScore);
        
        // 绘制排行榜（左侧）
        const leaderboardWidth = width * 0.45;
        this.renderer.drawLeaderboard(20, 20, leaderboardWidth, height - 120, sortedPlayers);
        
        // 绘制个人属性面板（右侧）
        const statsX = leaderboardWidth + 40;
        const statsWidth = width - statsX - 20;
        this.renderer.drawPlayerStats(statsX, 20, statsWidth, height - 120, currentPlayer, gameState);
        
        // 绘制切换视图按钮
        const btnWidth = 120;
        const btnHeight = 50;
        this.renderer.drawButton(width / 2 - btnWidth / 2, height - 80, btnWidth, btnHeight, '银河视图');
        
        this.touchHandlers.set('switchView', {
            x: width / 2 - btnWidth / 2,
            y: height - 80,
            width: btnWidth,
            height: btnHeight,
            onTap: () => {
                this.switchView('galaxy');
            }
        });
    }

    // ==================== 触摸事件处理 ====================

    handleTouchStart(event) {
        const touch = event.touches[0];
        this.checkTouchHandlers(touch.clientX, touch.clientY, 'onTouchStart');
    }

    handleTouchMove(event) {
        const touch = event.touches[0];
        this.checkTouchHandlers(touch.clientX, touch.clientY, 'onTouchMove');
    }

    handleTouchEnd(event) {
        const touch = event.changedTouches[0];
        this.checkTouchHandlers(touch.clientX, touch.clientY, 'onTap');
    }

    checkTouchHandlers(x, y, eventType) {
        for (const [key, handler] of this.touchHandlers.entries()) {
            if (this.isPointInRect(x, y, handler)) {
                if (handler[eventType]) {
                    handler[eventType]();
                }
                break;
            }
        }
    }

    isPointInRect(x, y, rect) {
        return x >= rect.x && x <= rect.x + rect.width &&
               y >= rect.y && y <= rect.y + rect.height;
    }
}

// 导出
if (typeof module !== 'undefined' && module.exports) {
    module.exports = UIManager;
}
```

---

## 微信小游戏版本 - 音效实现

### 创建音频管理器

创建文件：`wechat-minigame/js/managers/AudioManager.js`

```javascript
/**
 * 微信小游戏音频管理器
 */
class AudioManager {
    constructor() {
        this.bgmAudio = null;
        this.sfxAudios = new Map();
        
        this.bgmVolume = 0.5;
        this.sfxVolume = 0.8;
        this.isBgmEnabled = true;
        this.isSfxEnabled = true;
        
        this.loadSettings();
    }

    // ==================== BGM管理 ====================

    playBgm(src) {
        if (!this.isBgmEnabled) return;
        
        if (this.bgmAudio) {
            this.bgmAudio.stop();
            this.bgmAudio.destroy();
        }
        
        this.bgmAudio = wx.createInnerAudioContext();
        this.bgmAudio.src = src;
        this.bgmAudio.loop = true;
        this.bgmAudio.volume = this.bgmVolume;
        
        this.bgmAudio.onError((res) => {
            console.error('BGM播放失败:', res);
        });
        
        this.bgmAudio.play();
    }

    stopBgm() {
        if (this.bgmAudio) {
            this.bgmAudio.stop();
        }
    }

    pauseBgm() {
        if (this.bgmAudio) {
            this.bgmAudio.pause();
        }
    }

    resumeBgm() {
        if (this.bgmAudio && this.isBgmEnabled) {
            this.bgmAudio.play();
        }
    }

    setBgmVolume(volume) {
        this.bgmVolume = Math.max(0, Math.min(1, volume));
        if (this.bgmAudio) {
            this.bgmAudio.volume = this.bgmVolume;
        }
        this.saveSettings();
    }

    toggleBgm() {
        this.isBgmEnabled = !this.isBgmEnabled;
        
        if (this.isBgmEnabled) {
            this.resumeBgm();
        } else {
            this.pauseBgm();
        }
        
        this.saveSettings();
    }

    // ==================== SFX管理 ====================

    playSfx(src) {
        if (!this.isSfxEnabled) return;
        
        // 创建新的音频实例
        const audio = wx.createInnerAudioContext();
        audio.src = src;
        audio.volume = this.sfxVolume;
        
        audio.onEnded(() => {
            audio.destroy();
        });
        
        audio.onError((res) => {
            console.error('SFX播放失败:', res);
            audio.destroy();
        });
        
        audio.play();
    }

    setSfxVolume(volume) {
        this.sfxVolume = Math.max(0, Math.min(1, volume));
        this.saveSettings();
    }

    toggleSfx() {
        this.isSfxEnabled = !this.isSfxEnabled;
        this.saveSettings();
    }

    // ==================== 设置持久化 ====================

    loadSettings() {
        try {
            const settings = wx.getStorageSync('audio_settings');
            if (settings) {
                this.bgmVolume = settings.bgmVolume ?? 0.5;
                this.sfxVolume = settings.sfxVolume ?? 0.8;
                this.isBgmEnabled = settings.isBgmEnabled ?? true;
                this.isSfxEnabled = settings.isSfxEnabled ?? true;
            }
        } catch (e) {
            console.error('加载音频设置失败:', e);
        }
    }

    saveSettings() {
        try {
            wx.setStorageSync('audio_settings', {
                bgmVolume: this.bgmVolume,
                sfxVolume: this.sfxVolume,
                isBgmEnabled: this.isBgmEnabled,
                isSfxEnabled: this.isSfxEnabled
            });
        } catch (e) {
            console.error('保存音频设置失败:', e);
        }
    }

    // ==================== 清理资源 ====================

    destroy() {
        if (this.bgmAudio) {
            this.bgmAudio.destroy();
            this.bgmAudio = null;
        }
        
        for (const audio of this.sfxAudios.values()) {
            audio.destroy();
        }
        this.sfxAudios.clear();
    }
}

// 导出
if (typeof module !== 'undefined' && module.exports) {
    module.exports = AudioManager;
}
```

---

## 资源准备清单

### 图片资源

#### UI界面资源
```
assets/textures/ui/
├── button_normal.png           (200x60px, 按钮正常状态)
├── button_pressed.png          (200x60px, 按钮按下状态)
├── button_disabled.png         (200x60px, 按钮禁用状态)
├── panel_bg.png                (800x600px, 面板背景)
├── progress_bg.png             (400x30px, 进度条背景)
├── progress_fill.png           (400x30px, 进度条填充)
└── icon_close.png              (40x40px, 关闭图标)
```

#### 头像资源
```
assets/textures/avatars/
├── face_round.png              (100x100px, 圆脸)
├── face_square.png             (100x100px, 方脸)
├── face_oval.png               (100x100px, 椭圆脸)
├── accessory_hat.png           (100x100px, 帽子)
├── accessory_glasses.png       (100x100px, 眼镜)
├── accessory_beard.png         (100x100px, 胡子)
├── color_blue.png              (100x100px, 蓝色滤镜)
├── color_red.png               (100x100px, 红色滤镜)
└── color_green.png             (100x100px, 绿色滤镜)
```

#### 特效资源
```
assets/textures/effects/
├── star.png                    (20x20px, 星星)
├── glow.png                    (200x200px, 光晕)
├── particle.png                (10x10px, 粒子)
└── sun.png                     (200x200px, 太阳)
```

### 音频资源

#### 背景音乐
```
assets/audio/bgm/
└── main_theme.mp3              (循环播放, 时长2-3分钟, 比特率128kbps)
```

#### 音效
```
assets/audio/sfx/
├── click.wav                   (按钮点击, 0.1秒)
├── group_join.wav              (加入组队, 0.3秒)
├── impact.wav                  (冲击音效, 0.5秒)
├── score_up.wav                (分数上升, 0.3秒)
├── score_down.wav              (分数下降, 0.3秒)
├── warning.wav                 (警告音效, 0.5秒)
└── achievement.wav             (成就音效, 1秒)
```

### 字体资源
```
assets/fonts/
└── pixel_font.ttf              (像素风格字体)
```

---

## 完整实现示例

### Cocos Creator完整游戏入口

修改文件：`cocos-version/assets/scripts/Main.ts`

```typescript
import { _decorator, Component, director } from 'cc';
import { AudioManager } from './managers/AudioManager';

const { ccclass } = _decorator;

@ccclass('Main')
export class Main extends Component {
    onLoad() {
        // 初始化音频管理器
        AudioManager.getInstance();
        
        // 加载启动场景
        director.loadScene('Startup');
    }
}
```

### 微信小游戏完整游戏入口

修改文件：`wechat-minigame/game.js`

```javascript
// 导入适配器
import './game-adapter/index.js';

// 导入核心类
import GameController from './js/controllers/GameController.js';
import UIManager from './js/ui/UIManager.js';
import AudioManager from './js/managers/AudioManager.js';
import CanvasRenderer from './js/ui/CanvasRenderer.js';

// 创建Canvas
const canvas = wx.createCanvas();

// 初始化游戏控制器
const gameController = new GameController();

// 初始化音频管理器
const audioManager = new AudioManager();

// 初始化UI管理器
const uiManager = new UIManager(canvas, gameController);

// 播放背景音乐
audioManager.playBgm('assets/audio/bgm/main_theme.mp3');

// 游戏主循环
let lastTime = Date.now();
let tickTimer = 0;
const TICK_INTERVAL = 3000; // 3秒一个Tick

function gameLoop() {
    const now = Date.now();
    const deltaTime = now - lastTime;
    lastTime = now;
    
    // 更新游戏逻辑
    tickTimer += deltaTime;
    if (tickTimer >= TICK_INTERVAL) {
        gameController.performTick();
        tickTimer = 0;
    }
    
    // 渲染UI
    uiManager.render();
    
    // 请求下一帧
    requestAnimationFrame(gameLoop);
}

// 启动游戏循环
gameLoop();

// 监听游戏隐藏/显示
wx.onShow(() => {
    console.log('游戏进入前台');
    audioManager.resumeBgm();
});

wx.onHide(() => {
    console.log('游戏进入后台');
    audioManager.pauseBgm();
    gameController.saveGameState();
});
```

---

## 总结

本指南提供了Cocos Creator和微信小游戏两个版本的完整UI和音效实现方案：

### Cocos Creator版本特点
✅ 使用TypeScript，类型安全  
✅ 组件化开发，可视化编辑  
✅ 强大的场景管理和资源管理  
✅ 完整的音频系统支持  

### 微信小游戏版本特点
✅ 纯JavaScript实现，轻量级  
✅ Canvas直接绘制，性能优秀  
✅ 原生微信API集成  
✅ 快速启动和加载  

### 下一步工作
1. 准备所需的图片、音频、字体资源
2. 按照代码示例实现各个UI组件
3. 测试和调试UI交互
4. 优化性能和用户体验
5. 添加更多游戏功能和特效

---

**祝开发顺利！🎉**
