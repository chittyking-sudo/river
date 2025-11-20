/**
 * 本地存储服务 - 微信小游戏版本
 */
export class StorageService {
    static GAME_STATE_KEY = 'galaxy_race_game_state';
    static CURRENT_PLAYER_KEY = 'galaxy_race_current_player';

    /**
     * 保存游戏状态
     */
    static saveGameState(gameState) {
        try {
            const json = JSON.stringify(gameState.toJson());
            wx.setStorageSync(this.GAME_STATE_KEY, json);
            console.log('游戏状态已保存');
        } catch (e) {
            console.error('保存游戏状态失败:', e);
        }
    }

    /**
     * 加载游戏状态
     */
    static loadGameState() {
        try {
            const json = wx.getStorageSync(this.GAME_STATE_KEY);
            if (json) {
                const data = JSON.parse(json);
                console.log('游戏状态已加载');
                // 需要在GameState中实现fromJson静态方法
                return data;
            }
        } catch (e) {
            console.error('加载游戏状态失败:', e);
        }
        return null;
    }

    /**
     * 保存当前玩家
     */
    static saveCurrentPlayer(player) {
        try {
            const json = JSON.stringify(player.toJson());
            wx.setStorageSync(this.CURRENT_PLAYER_KEY, json);
            console.log('当前玩家已保存');
        } catch (e) {
            console.error('保存当前玩家失败:', e);
        }
    }

    /**
     * 加载当前玩家
     */
    static loadCurrentPlayer() {
        try {
            const json = wx.getStorageSync(this.CURRENT_PLAYER_KEY);
            if (json) {
                const data = JSON.parse(json);
                console.log('当前玩家已加载');
                return data;
            }
        } catch (e) {
            console.error('加载当前玩家失败:', e);
        }
        return null;
    }

    /**
     * 清除所有数据
     */
    static clearAll() {
        try {
            wx.removeStorageSync(this.GAME_STATE_KEY);
            wx.removeStorageSync(this.CURRENT_PLAYER_KEY);
            console.log('所有数据已清除');
        } catch (e) {
            console.error('清除数据失败:', e);
        }
    }
}
