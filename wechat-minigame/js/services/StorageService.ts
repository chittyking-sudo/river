import { GameState } from "../models/GameState";
import { Player } from "../models/Player";

/**
 * 本地存储服务
 * 支持Cocos Creator和微信小游戏
 */
export class StorageService {
    private static readonly GAME_STATE_KEY = 'galaxy_race_game_state';
    private static readonly CURRENT_PLAYER_KEY = 'galaxy_race_current_player';

    /**
     * 保存游戏状态
     */
    static saveGameState(gameState: GameState): void {
        try {
            const json = JSON.stringify(gameState.toJson());
            if (typeof wx !== 'undefined') {
                // 微信小游戏环境
                wx.setStorageSync(this.GAME_STATE_KEY, json);
            } else if (typeof cc !== 'undefined' && cc.sys && cc.sys.localStorage) {
                // Cocos Creator环境
                cc.sys.localStorage.setItem(this.GAME_STATE_KEY, json);
            } else {
                // Web环境
                localStorage.setItem(this.GAME_STATE_KEY, json);
            }
            console.log('游戏状态已保存');
        } catch (e) {
            console.error('保存游戏状态失败:', e);
        }
    }

    /**
     * 加载游戏状态
     */
    static loadGameState(): GameState | null {
        try {
            let json: string | null = null;
            
            if (typeof wx !== 'undefined') {
                // 微信小游戏环境
                json = wx.getStorageSync(this.GAME_STATE_KEY);
            } else if (typeof cc !== 'undefined' && cc.sys && cc.sys.localStorage) {
                // Cocos Creator环境
                json = cc.sys.localStorage.getItem(this.GAME_STATE_KEY);
            } else {
                // Web环境
                json = localStorage.getItem(this.GAME_STATE_KEY);
            }

            if (json) {
                const data = JSON.parse(json);
                console.log('游戏状态已加载');
                return GameState.fromJson(data);
            }
        } catch (e) {
            console.error('加载游戏状态失败:', e);
        }
        return null;
    }

    /**
     * 保存当前玩家
     */
    static saveCurrentPlayer(player: Player): void {
        try {
            const json = JSON.stringify(player.toJson());
            if (typeof wx !== 'undefined') {
                wx.setStorageSync(this.CURRENT_PLAYER_KEY, json);
            } else if (typeof cc !== 'undefined' && cc.sys && cc.sys.localStorage) {
                cc.sys.localStorage.setItem(this.CURRENT_PLAYER_KEY, json);
            } else {
                localStorage.setItem(this.CURRENT_PLAYER_KEY, json);
            }
            console.log('当前玩家已保存');
        } catch (e) {
            console.error('保存当前玩家失败:', e);
        }
    }

    /**
     * 加载当前玩家
     */
    static loadCurrentPlayer(): Player | null {
        try {
            let json: string | null = null;
            
            if (typeof wx !== 'undefined') {
                json = wx.getStorageSync(this.CURRENT_PLAYER_KEY);
            } else if (typeof cc !== 'undefined' && cc.sys && cc.sys.localStorage) {
                json = cc.sys.localStorage.getItem(this.CURRENT_PLAYER_KEY);
            } else {
                json = localStorage.getItem(this.CURRENT_PLAYER_KEY);
            }

            if (json) {
                const data = JSON.parse(json);
                console.log('当前玩家已加载');
                return Player.fromJson(data);
            }
        } catch (e) {
            console.error('加载当前玩家失败:', e);
        }
        return null;
    }

    /**
     * 清除所有数据
     */
    static clearAll(): void {
        try {
            if (typeof wx !== 'undefined') {
                wx.removeStorageSync(this.GAME_STATE_KEY);
                wx.removeStorageSync(this.CURRENT_PLAYER_KEY);
            } else if (typeof cc !== 'undefined' && cc.sys && cc.sys.localStorage) {
                cc.sys.localStorage.removeItem(this.GAME_STATE_KEY);
                cc.sys.localStorage.removeItem(this.CURRENT_PLAYER_KEY);
            } else {
                localStorage.removeItem(this.GAME_STATE_KEY);
                localStorage.removeItem(this.CURRENT_PLAYER_KEY);
            }
            console.log('所有数据已清除');
        } catch (e) {
            console.error('清除数据失败:', e);
        }
    }
}
