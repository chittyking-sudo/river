import { _decorator, Component } from 'cc';
import { GameState } from '../models/GameState';
import { Player } from '../models/Player';
import { GameGroup, GroupDirection } from '../models/Group';
import { MarketMode } from '../models/MarketMode';
import { GameEngine } from '../services/GameEngine';
import { StorageService } from '../services/StorageService';
import { AvatarConfig } from '../models/AvatarConfig';

const { ccclass, property } = _decorator;

/**
 * 游戏控制器 - 管理游戏状态和逻辑
 */
@ccclass('GameController')
export class GameController extends Component {
    private gameState: GameState = new GameState();
    private currentPlayer: Player | null = null;
    private gameEngine: GameEngine = new GameEngine();
    private tickTimer: number = 0;
    private readonly TICK_INTERVAL: number = 3.0; // 3秒一个Tick

    /**
     * 初始化游戏
     */
    onLoad() {
        // 尝试加载保存的数据
        const savedState = StorageService.loadGameState();
        const savedPlayer = StorageService.loadCurrentPlayer();

        if (savedState) {
            this.gameState = savedState;
            console.log('已加载游戏状态');
        } else {
            // 初始化演示数据
            this.initializeDemoPlayers();
        }

        if (savedPlayer) {
            this.currentPlayer = savedPlayer;
            console.log('已加载当前玩家');
        }
    }

    /**
     * 游戏循环更新
     */
    update(deltaTime: number) {
        this.tickTimer += deltaTime;

        if (this.tickTimer >= this.TICK_INTERVAL) {
            this.tickTimer = 0;
            this.performTick();
        }
    }

    /**
     * 执行Tick更新
     */
    private performTick() {
        // 更新所有玩家
        const updatedPlayers = this.gameState.players.map(player =>
            this.gameEngine.updatePlayerTick(player, this.gameState.currentMode)
        );

        this.gameState = this.gameState.copyWith({
            players: updatedPlayers,
            totalTicks: this.gameState.totalTicks + 1
        });

        // 检查市场调整
        const extremePlayers = this.gameEngine.countExtremePlayers(this.gameState.players);
        if (this.gameEngine.shouldTriggerMarketAdjustment(this.gameState.playerCount, extremePlayers)) {
            const newMode = this.gameEngine.selectRandomMarketMode();
            this.gameState = this.gameState.copyWith({ currentMode: newMode });
            console.log('市场模式已切换:', newMode);
        }

        // 保存状态
        StorageService.saveGameState(this.gameState);
    }

    /**
     * 创建新玩家
     */
    createPlayer(avatarConfig: AvatarConfig): Player {
        const player = new Player(
            this.generatePlayerId(),
            avatarConfig,
            this.gameEngine.generateInitialCoordinate()
        );

        this.currentPlayer = player;
        this.gameState.players.push(player);

        StorageService.saveCurrentPlayer(player);
        StorageService.saveGameState(this.gameState);

        return player;
    }

    /**
     * 创建组队
     */
    createGroup(playerId: string, direction: GroupDirection): GameGroup | null {
        const player = this.gameState.findPlayer(playerId);
        if (!player || player.dailyChances <= 0 || player.isInGroup) {
            return null;
        }

        const group = new GameGroup(
            this.generateGroupId(),
            [playerId],
            direction
        );

        // 更新玩家状态
        const updatedPlayer = player.copyWith({
            isInGroup: true,
            groupId: group.id
        });

        this.updatePlayer(updatedPlayer);
        this.gameState.groups.push(group);

        StorageService.saveGameState(this.gameState);

        return group;
    }

    /**
     * 加入组队
     */
    joinGroup(playerId: string, groupId: string): boolean {
        const player = this.gameState.findPlayer(playerId);
        const group = this.gameState.findGroup(groupId);

        if (!player || !group || !group.canJoin || player.dailyChances <= 0) {
            return false;
        }

        // 更新组队成员
        group.memberIds.push(playerId);

        // 更新玩家状态
        const updatedPlayer = player.copyWith({
            isInGroup: true,
            groupId: group.id
        });

        this.updatePlayer(updatedPlayer);
        StorageService.saveGameState(this.gameState);

        return true;
    }

    /**
     * 执行组队冲击
     */
    executeGroupImpact(groupId: string): boolean {
        const group = this.gameState.findGroup(groupId);
        if (!group || group.memberCount < 2) {
            return false;
        }

        // 对所有成员应用加成
        group.memberIds.forEach(memberId => {
            const player = this.gameState.findPlayer(memberId);
            if (player) {
                const updatedPlayer = this.gameEngine.applyGroupBonus(
                    player,
                    group,
                    group.direction
                );
                this.updatePlayer(updatedPlayer);
            }
        });

        // 标记组队为非活跃
        const updatedGroup = group.copyWith({ isActive: false });
        this.updateGroup(updatedGroup);

        StorageService.saveGameState(this.gameState);

        return true;
    }

    /**
     * 融合救援
     */
    mergeRescue(playerId1: string, playerId2: string): Player | null {
        const player1 = this.gameState.findPlayer(playerId1);
        const player2 = this.gameState.findPlayer(playerId2);

        if (!player1 || !player2) {
            return null;
        }

        const mergedPlayer = this.gameEngine.mergePlayers(player1, player2);
        this.updatePlayer(mergedPlayer);

        // 移除第二个玩家
        this.gameState.players = this.gameState.players.filter(p => p.id !== playerId2);

        StorageService.saveGameState(this.gameState);

        return mergedPlayer;
    }

    /**
     * 初始化演示玩家
     */
    private initializeDemoPlayers() {
        for (let i = 0; i < 20; i++) {
            const avatarConfig = new AvatarConfig(
                Math.floor(Math.random() * 3),
                Math.floor(Math.random() * 3),
                Math.floor(Math.random() * 3)
            );

            const player = new Player(
                this.generatePlayerId(),
                avatarConfig,
                this.gameEngine.generateInitialCoordinate()
            );

            this.gameState.players.push(player);
        }

        console.log('已初始化20个演示玩家');
        StorageService.saveGameState(this.gameState);
    }

    /**
     * 更新玩家
     */
    private updatePlayer(player: Player) {
        const index = this.gameState.players.findIndex(p => p.id === player.id);
        if (index !== -1) {
            this.gameState.players[index] = player;
        }

        if (this.currentPlayer && this.currentPlayer.id === player.id) {
            this.currentPlayer = player;
            StorageService.saveCurrentPlayer(player);
        }
    }

    /**
     * 更新组队
     */
    private updateGroup(group: GameGroup) {
        const index = this.gameState.groups.findIndex(g => g.id === group.id);
        if (index !== -1) {
            this.gameState.groups[index] = group;
        }
    }

    /**
     * 生成玩家ID
     */
    private generatePlayerId(): string {
        return `player_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
    }

    /**
     * 生成组队ID
     */
    private generateGroupId(): string {
        return `group_${Date.now()}_${Math.random().toString(36).substring(2, 9)}`;
    }

    /**
     * 获取游戏状态
     */
    getGameState(): GameState {
        return this.gameState;
    }

    /**
     * 获取当前玩家
     */
    getCurrentPlayer(): Player | null {
        return this.currentPlayer;
    }
}
