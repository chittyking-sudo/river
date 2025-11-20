# 🌌 银河竞赛 - 微信小游戏版本

这是《银河竞赛》的微信小游戏版本，使用原生JavaScript开发，支持在微信中直接运行。

## 📁 项目结构

```
wechat-minigame/
├── js/
│   ├── models/              # 数据模型
│   ├── services/            # 服务层
│   │   └── StorageService.js    # 本地存储服务
│   ├── controllers/         # 控制器
│   │   └── GameController.js    # 游戏控制器
│   └── ui/                 # UI组件
├── assets/
│   ├── images/             # 图片资源
│   └── sounds/             # 音频资源
├── game-adapter/           # 微信小游戏适配层
│   └── index.js           # 适配器主文件
├── game.js                # 游戏入口
├── game.json              # 游戏配置
└── project.config.json    # 项目配置
```

## 🚀 快速开始

### 1. 环境要求

- 微信开发者工具 (最新稳定版)
- Node.js 14+ (可选，用于开发工具)

### 2. 导入项目

1. 下载并安装微信开发者工具
2. 打开微信开发者工具
3. 选择 "小游戏" -> "导入项目"
4. 选择 `wechat-minigame` 文件夹
5. 填写AppID（测试可用测试号）

### 3. 运行项目

1. 在微信开发者工具中点击 "编译"
2. 在模拟器中查看效果
3. 点击 "真机调试" 在手机上测试

### 4. 发布上线

1. 完善游戏信息和配置
2. 在微信开发者工具中点击 "上传"
3. 登录微信公众平台
4. 提交审核
5. 审核通过后发布

## 🎮 核心功能

### 游戏适配层 (game-adapter)

提供与浏览器环境兼容的API：

```javascript
// Canvas适配
global.canvas = wx.createCanvas();
global.document = { createElement, getElementById, ... };

// 动画循环适配
global.requestAnimationFrame = ...;
global.cancelAnimationFrame = ...;

// 存储适配
global.localStorage = {
    getItem: wx.getStorageSync,
    setItem: wx.setStorageSync,
    ...
};

// 网络请求适配
global.XMLHttpRequest = ...;

// 图片和音频适配
global.Image = ...;
global.Audio = ...;
```

### 游戏控制器 (GameController)

```javascript
class GameController {
    constructor(canvas, ctx)     // 构造函数
    init()                       // 初始化游戏
    loadGameData()              // 加载游戏数据
    initializeDemoData()        // 初始化演示数据
    startGameLoop()             // 开始游戏循环
    update(deltaTime)           // 更新游戏逻辑
    performTick()               // 执行Tick更新
    updatePlayerValue(player)   // 更新玩家价值
    checkMarketAdjustment()     // 检查市场调整
    render()                    // 渲染游戏画面
    createPlayer(avatarConfig)  // 创建新玩家
    saveGameState()             // 保存游戏状态
}
```

### 本地存储服务 (StorageService)

```javascript
class StorageService {
    static saveGameState(gameState)      // 保存游戏状态
    static loadGameState()               // 加载游戏状态
    static saveCurrentPlayer(player)     // 保存当前玩家
    static loadCurrentPlayer()           // 加载当前玩家
    static clearAll()                    // 清除所有数据
}
```

## 📱 微信小游戏特性

### 1. 性能优化

#### Canvas绘制优化
```javascript
// 使用离屏Canvas
const offscreenCanvas = wx.createCanvas();
// 绘制到离屏Canvas
// ...
// 一次性绘制到主Canvas
ctx.drawImage(offscreenCanvas, 0, 0);
```

#### 减少重绘
```javascript
// 只在数据变化时重绘
if (this.needsRedraw) {
    this.render();
    this.needsRedraw = false;
}
```

### 2. 触摸交互

```javascript
// 触摸事件监听
wx.onTouchStart((event) => {
    const touch = event.touches[0];
    this.handleTouchStart(touch.clientX, touch.clientY);
});

wx.onTouchMove((event) => {
    const touch = event.touches[0];
    this.handleTouchMove(touch.clientX, touch.clientY);
});

wx.onTouchEnd((event) => {
    this.handleTouchEnd();
});
```

### 3. 资源加载

```javascript
// 图片加载
const image = wx.createImage();
image.onload = () => {
    console.log('图片加载完成');
};
image.src = 'images/avatar.png';

// 音频播放
const audio = wx.createInnerAudioContext();
audio.src = 'sounds/bgm.mp3';
audio.play();
```

### 4. 本地存储

```javascript
// 同步存储
wx.setStorageSync('key', 'value');
const value = wx.getStorageSync('key');

// 异步存储
wx.setStorage({
    key: 'key',
    data: 'value',
    success: () => console.log('保存成功')
});

wx.getStorage({
    key: 'key',
    success: (res) => console.log(res.data)
});
```

### 5. 分享功能

```javascript
// 主动分享
wx.shareAppMessage({
    title: '银河竞赛',
    imageUrl: 'images/share.png',
    query: 'from=share'
});

// 被动分享监听
wx.onShareAppMessage(() => {
    return {
        title: '快来和我一起玩银河竞赛！',
        imageUrl: 'images/share.png'
    };
});
```

### 6. 用户授权

```javascript
// 获取用户信息
wx.getUserInfo({
    success: (res) => {
        console.log(res.userInfo);
        this.createPlayer(res.userInfo);
    }
});

// 获取授权
wx.authorize({
    scope: 'scope.userInfo',
    success: () => {
        console.log('授权成功');
    }
});
```

## 🎨 UI开发

### Canvas绘制基础

```javascript
// 绘制背景
ctx.fillStyle = '#000000';
ctx.fillRect(0, 0, canvas.width, canvas.height);

// 绘制文本
ctx.fillStyle = '#FFFFFF';
ctx.font = '24px Arial';
ctx.textAlign = 'center';
ctx.fillText('银河竞赛', canvas.width / 2, 50);

// 绘制圆形
ctx.beginPath();
ctx.arc(x, y, radius, 0, Math.PI * 2);
ctx.fill();

// 绘制图片
ctx.drawImage(image, x, y, width, height);
```

### 响应式布局

```javascript
// 获取屏幕信息
const systemInfo = wx.getSystemInfoSync();
const screenWidth = systemInfo.screenWidth;
const screenHeight = systemInfo.screenHeight;
const pixelRatio = systemInfo.pixelRatio;

// 设置Canvas大小
canvas.width = screenWidth * pixelRatio;
canvas.height = screenHeight * pixelRatio;

// 缩放绘制上下文
ctx.scale(pixelRatio, pixelRatio);
```

### 按钮交互

```javascript
class Button {
    constructor(x, y, width, height, text) {
        this.x = x;
        this.y = y;
        this.width = width;
        this.height = height;
        this.text = text;
    }
    
    draw(ctx) {
        ctx.fillStyle = '#4CAF50';
        ctx.fillRect(this.x, this.y, this.width, this.height);
        
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '16px Arial';
        ctx.textAlign = 'center';
        ctx.fillText(
            this.text,
            this.x + this.width / 2,
            this.y + this.height / 2 + 5
        );
    }
    
    isClicked(touchX, touchY) {
        return touchX >= this.x && 
               touchX <= this.x + this.width &&
               touchY >= this.y && 
               touchY <= this.y + this.height;
    }
}
```

## 🔧 调试技巧

### 1. 使用console.log
```javascript
console.log('游戏状态:', this.gameState);
console.warn('警告信息');
console.error('错误信息');
```

### 2. 真机调试
1. 点击微信开发者工具的 "真机调试"
2. 用微信扫描二维码
3. 在手机上查看实际效果

### 3. 性能监控
```javascript
// 显示FPS
const fps = 1000 / deltaTime;
ctx.fillText(`FPS: ${fps.toFixed(1)}`, 10, 20);

// 显示内存使用
const perfData = wx.getPerformance();
console.log('内存:', perfData.usedJSHeapSize);
```

### 4. 错误处理
```javascript
wx.onError((error) => {
    console.error('游戏错误:', error);
    // 上报错误日志
});
```

## 📊 数据统计

### 使用微信数据分析

```javascript
// 上报自定义事件
wx.reportAnalytics('game_start', {
    level: 1,
    score: 100
});

// 上报性能数据
wx.reportPerformance(1001, 50, '游戏加载时间');
```

## 🔐 安全建议

1. **不要在客户端存储敏感信息**
2. **使用HTTPS请求后端API**
3. **验证用户输入数据**
4. **定期更新游戏版本**

## 📚 参考文档

- [微信小游戏官方文档](https://developers.weixin.qq.com/minigame/dev/guide/)
- [微信小游戏API](https://developers.weixin.qq.com/minigame/dev/api/)
- [Canvas API文档](https://developer.mozilla.org/zh-CN/docs/Web/API/Canvas_API)

## 🤝 贡献指南

欢迎贡献代码！请遵循以下步骤：

1. Fork本项目
2. 创建功能分支
3. 提交代码更改
4. 发起Pull Request

## 📄 许可证

MIT License

---

**开发平台**: 微信小游戏  
**开发语言**: JavaScript  
**版本**: v1.0.0
