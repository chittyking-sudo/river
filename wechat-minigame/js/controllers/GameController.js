/**
 * 游戏控制器 - 微信小游戏版本
 */
export class GameController {
    constructor(canvas, ctx) {
        this.canvas = canvas;
        this.ctx = ctx;
        this.gameState = null;
        this.currentPlayer = null;
        this.tickTimer = 0;
        this.TICK_INTERVAL = 3000; // 3秒一个Tick (毫秒)
        this.lastTime = Date.now();
    }

    /**
     * 初始化游戏
     */
    init() {
        console.log('初始化游戏控制器');
        
        // 加载游戏状态
        this.loadGameData();
        
        // 开始游戏循环
        this.startGameLoop();
        
        // 渲染初始界面
        this.render();
    }

    /**
     * 加载游戏数据
     */
    loadGameData() {
        try {
            const savedState = wx.getStorageSync('galaxy_race_game_state');
            const savedPlayer = wx.getStorageSync('galaxy_race_current_player');
            
            if (savedState) {
                this.gameState = JSON.parse(savedState);
                console.log('已加载游戏状态');
            } else {
                this.initializeDemoData();
            }
            
            if (savedPlayer) {
                this.currentPlayer = JSON.parse(savedPlayer);
                console.log('已加载当前玩家');
            }
        } catch (e) {
            console.error('加载游戏数据失败:', e);
            this.initializeDemoData();
        }
    }

    /**
     * 初始化演示数据
     */
    initializeDemoData() {
        this.gameState = {
            players: [],
            groups: [],
            currentMode: 0, // MarketMode.NORMAL
            totalTicks: 0,
            currentDay: 1,
            lastUpdate: new Date().toISOString(),
            topPlayerId: null
        };

        // 创建20个演示玩家
        for (let i = 0; i < 20; i++) {
            const player = {
                id: `player_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
                avatarConfig: {
                    baseAvatar: Math.floor(Math.random() * 3),
                    accessory: Math.floor(Math.random() * 3),
                    colorTheme: Math.floor(Math.random() * 3)
                },
                coordinate: {
                    x: Math.random() * 100,
                    y: 50.0 + (Math.random() - 0.5) * 20,
                    z: 10.0
                },
                pixelDensity: 100.0,
                dailyChances: 1,
                isInGroup: false,
                groupId: null,
                createdAt: new Date().toISOString(),
                lastUpdated: new Date().toISOString()
            };
            this.gameState.players.push(player);
        }

        console.log('已初始化20个演示玩家');
        this.saveGameState();
    }

    /**
     * 开始游戏循环
     */
    startGameLoop() {
        const loop = () => {
            const now = Date.now();
            const deltaTime = now - this.lastTime;
            this.lastTime = now;

            this.update(deltaTime);
            this.render();

            requestAnimationFrame(loop);
        };

        requestAnimationFrame(loop);
    }

    /**
     * 更新游戏逻辑
     */
    update(deltaTime) {
        this.tickTimer += deltaTime;

        if (this.tickTimer >= this.TICK_INTERVAL) {
            this.tickTimer = 0;
            this.performTick();
        }
    }

    /**
     * 执行Tick更新
     */
    performTick() {
        if (!this.gameState) return;

        // 更新所有玩家的价值
        this.gameState.players.forEach(player => {
            this.updatePlayerValue(player);
        });

        this.gameState.totalTicks += 1;

        // 检查市场调整
        this.checkMarketAdjustment();

        // 保存状态
        this.saveGameState();
    }

    /**
     * 更新玩家价值
     */
    updatePlayerValue(player) {
        const baseFluctuation = player.coordinate.y * 0.05;
        const randomFactor = (Math.random() - 0.5) * 2;
        
        const volatilityFactor = this.getVolatilityFactor(this.gameState.currentMode);
        const trendBias = this.getTrendBias(this.gameState.currentMode);
        
        const fluctuation = baseFluctuation * randomFactor * volatilityFactor;
        const trend = player.coordinate.y * trendBias * 0.1;
        
        player.coordinate.y = Math.max(0, Math.min(200, player.coordinate.y + fluctuation + trend));
        player.coordinate.x = Math.max(0, Math.min(100, player.coordinate.x + (Math.random() - 0.5) * 5));
        player.lastUpdated = new Date().toISOString();
    }

    /**
     * 检查市场调整
     */
    checkMarketAdjustment() {
        // 简化版市场调整逻辑
        if (Math.random() < 0.1) { // 10%概率切换市场
            const modes = [1, 2, 3, 4]; // ACCELERATED, BULLISH, BEARISH, STABLE
            this.gameState.currentMode = modes[Math.floor(Math.random() * modes.length)];
            console.log('市场模式已切换:', this.gameState.currentMode);
        }
    }

    /**
     * 获取波动系数
     */
    getVolatilityFactor(mode) {
        const factors = [1.0, 1.5, 2.0, 2.0, 0.5];
        return factors[mode] || 1.0;
    }

    /**
     * 获取趋势偏向
     */
    getTrendBias(mode) {
        const biases = [0.0, 0.0, 0.5, -0.5, 0.0];
        return biases[mode] || 0.0;
    }

    /**
     * 渲染游戏画面
     */
    render() {
        const { width, height } = this.canvas;
        
        // 清空画布
        this.ctx.fillStyle = '#000000';
        this.ctx.fillRect(0, 0, width, height);

        // 绘制标题
        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.font = '24px Arial';
        this.ctx.textAlign = 'center';
        this.ctx.fillText('银河竞赛', width / 2, 50);

        if (!this.gameState) return;

        // 绘制游戏状态信息
        this.ctx.font = '16px Arial';
        this.ctx.textAlign = 'left';
        this.ctx.fillText(`玩家数: ${this.gameState.players.length}`, 20, 100);
        this.ctx.fillText(`游戏天数: ${this.gameState.currentDay}`, 20, 130);
        this.ctx.fillText(`市场模式: ${this.getModeName(this.gameState.currentMode)}`, 20, 160);

        // 绘制玩家点（银河视图）
        const centerX = width / 2;
        const centerY = height / 2;
        const scale = 2;

        this.gameState.players.forEach(player => {
            const x = centerX + (player.coordinate.x - 50) * scale;
            const y = centerY + (player.coordinate.y - 100) * scale;
            
            this.ctx.fillStyle = '#FFFFFF';
            this.ctx.beginPath();
            this.ctx.arc(x, y, 3, 0, Math.PI * 2);
            this.ctx.fill();
        });

        // 绘制排行榜
        const sorted = [...this.gameState.players].sort((a, b) => 
            (b.coordinate.y + b.coordinate.z) - (a.coordinate.y + a.coordinate.z)
        );

        this.ctx.fillStyle = '#FFFFFF';
        this.ctx.font = '14px Arial';
        this.ctx.textAlign = 'right';
        for (let i = 0; i < Math.min(10, sorted.length); i++) {
            const player = sorted[i];
            const score = (player.coordinate.y + player.coordinate.z).toFixed(1);
            this.ctx.fillText(`${i + 1}. 分数: ${score}`, width - 20, 100 + i * 25);
        }
    }

    /**
     * 获取市场模式名称
     */
    getModeName(mode) {
        const names = ['正常', '加速', '上涨', '下跌', '平稳'];
        return names[mode] || '未知';
    }

    /**
     * 保存游戏状态
     */
    saveGameState() {
        try {
            wx.setStorageSync('galaxy_race_game_state', JSON.stringify(this.gameState));
        } catch (e) {
            console.error('保存游戏状态失败:', e);
        }
    }

    /**
     * 创建新玩家
     */
    createPlayer(avatarConfig) {
        const player = {
            id: `player_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`,
            avatarConfig: avatarConfig,
            coordinate: {
                x: Math.random() * 100,
                y: 50.0 + (Math.random() - 0.5) * 20,
                z: 10.0
            },
            pixelDensity: 100.0,
            dailyChances: 1,
            isInGroup: false,
            groupId: null,
            createdAt: new Date().toISOString(),
            lastUpdated: new Date().toISOString()
        };

        this.currentPlayer = player;
        this.gameState.players.push(player);

        wx.setStorageSync('galaxy_race_current_player', JSON.stringify(player));
        this.saveGameState();

        return player;
    }
}
