// 微信小游戏主入口
import './game-adapter/index.js';
import { GameController } from './js/controllers/GameController.js';

// 创建canvas
const canvas = wx.createCanvas();
const ctx = canvas.getContext('2d');

// 初始化游戏控制器
const gameController = new GameController(canvas, ctx);

// 启动游戏
gameController.init();

console.log('银河竞赛 - 微信小游戏版本已启动');
