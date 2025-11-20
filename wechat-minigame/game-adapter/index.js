/**
 * 微信小游戏适配器
 * 提供与浏览器环境兼容的全局对象
 */

// Canvas适配
const canvas = wx.createCanvas();
const gl = canvas.getContext('webgl');

// requestAnimationFrame适配
if (!global.requestAnimationFrame) {
    global.requestAnimationFrame = callback => {
        return setTimeout(() => {
            callback(Date.now());
        }, 16);
    };
}

if (!global.cancelAnimationFrame) {
    global.cancelAnimationFrame = id => {
        clearTimeout(id);
    };
}

// document适配
const document = {
    createElement: (tag) => {
        if (tag === 'canvas') {
            return canvas;
        }
        return {};
    },
    getElementById: () => canvas,
    getElementsByTagName: () => [canvas],
    createElementNS: () => ({})
};

// window适配
const window = {
    innerWidth: canvas.width,
    innerHeight: canvas.height,
    devicePixelRatio: wx.getSystemInfoSync().pixelRatio,
    
    addEventListener: (event, callback) => {
        if (event === 'touchstart') {
            wx.onTouchStart(callback);
        } else if (event === 'touchmove') {
            wx.onTouchMove(callback);
        } else if (event === 'touchend') {
            wx.onTouchEnd(callback);
        } else if (event === 'touchcancel') {
            wx.onTouchCancel(callback);
        }
    },
    
    removeEventListener: (event) => {
        if (event === 'touchstart') {
            wx.offTouchStart();
        } else if (event === 'touchmove') {
            wx.offTouchMove();
        } else if (event === 'touchend') {
            wx.offTouchEnd();
        } else if (event === 'touchcancel') {
            wx.offTouchCancel();
        }
    },
    
    requestAnimationFrame: global.requestAnimationFrame,
    cancelAnimationFrame: global.cancelAnimationFrame,
    
    performance: {
        now: () => Date.now()
    },
    
    location: {
        href: 'wechat://minigame'
    },
    
    navigator: {
        userAgent: 'wechat-minigame'
    }
};

// navigator适配
const navigator = {
    userAgent: 'wechat-minigame',
    platform: wx.getSystemInfoSync().platform
};

// localStorage适配
const localStorage = {
    getItem: (key) => {
        try {
            return wx.getStorageSync(key) || null;
        } catch (e) {
            return null;
        }
    },
    
    setItem: (key, value) => {
        try {
            wx.setStorageSync(key, value);
        } catch (e) {
            console.error('localStorage.setItem error:', e);
        }
    },
    
    removeItem: (key) => {
        try {
            wx.removeStorageSync(key);
        } catch (e) {
            console.error('localStorage.removeItem error:', e);
        }
    },
    
    clear: () => {
        try {
            wx.clearStorageSync();
        } catch (e) {
            console.error('localStorage.clear error:', e);
        }
    }
};

// Image适配
class Image {
    constructor() {
        this._image = wx.createImage();
        this.width = 0;
        this.height = 0;
        
        this._image.onload = () => {
            this.width = this._image.width;
            this.height = this._image.height;
            if (this.onload) {
                this.onload();
            }
        };
        
        this._image.onerror = (err) => {
            if (this.onerror) {
                this.onerror(err);
            }
        };
    }
    
    get src() {
        return this._image.src;
    }
    
    set src(value) {
        this._image.src = value;
    }
}

// Audio适配
class Audio {
    constructor(url) {
        this._audio = wx.createInnerAudioContext();
        if (url) {
            this._audio.src = url;
        }
    }
    
    play() {
        this._audio.play();
    }
    
    pause() {
        this._audio.pause();
    }
    
    stop() {
        this._audio.stop();
    }
    
    get src() {
        return this._audio.src;
    }
    
    set src(value) {
        this._audio.src = value;
    }
    
    get volume() {
        return this._audio.volume;
    }
    
    set volume(value) {
        this._audio.volume = value;
    }
    
    get loop() {
        return this._audio.loop;
    }
    
    set loop(value) {
        this._audio.loop = value;
    }
}

// XMLHttpRequest适配
class XMLHttpRequest {
    constructor() {
        this.method = 'GET';
        this.url = '';
        this.responseType = 'text';
        this.response = null;
        this.status = 0;
        this.onload = null;
        this.onerror = null;
        this.ontimeout = null;
    }
    
    open(method, url) {
        this.method = method;
        this.url = url;
    }
    
    send(data) {
        wx.request({
            url: this.url,
            method: this.method,
            data: data,
            responseType: this.responseType,
            success: (res) => {
                this.status = res.statusCode;
                this.response = res.data;
                if (this.onload) {
                    this.onload();
                }
            },
            fail: (err) => {
                if (this.onerror) {
                    this.onerror(err);
                }
            }
        });
    }
}

// 导出全局对象
global.canvas = canvas;
global.gl = gl;
global.document = document;
global.window = window;
global.navigator = navigator;
global.localStorage = localStorage;
global.Image = Image;
global.Audio = Audio;
global.XMLHttpRequest = XMLHttpRequest;

console.log('微信小游戏适配器已加载');
