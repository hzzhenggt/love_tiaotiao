# edevice - 设备信息浮动面板

## 概述
LÖVE2D 独立模块，提供一个可拖动的浮动按钮，点击展开半透明设备信息面板，支持一键复制信息到剪贴板。适用于开发调试阶段快速查看运行环境。

## 使用方式
```lua
local edevice = require("edevice")

function love.load()
    edevice.load()
end

function love.update(dt)
    edevice.update(dt)
end

function love.draw()
    edevice.draw()
end

function love.mousepressed(x, y, btn)
    edevice.mousepressed(x, y, btn)
end

function love.mousereleased(x, y, btn)
    edevice.mousereleased(x, y, btn)
end

function love.mousemoved(x, y, dx, dy)
    edevice.mousemoved(x, y, dx, dy)
end

-- 触摸设备（Android/iOS）
function love.touchpressed(id, x, y)
    edevice.touchpressed(id, x, y)
end

function love.touchreleased(id, x, y)
    edevice.touchreleased(id, x, y)
end

function love.touchmoved(id, x, y)
    edevice.touchmoved(id, x, y)
end
```

## API 参考

| 函数 | 参数 | 返回值 | 说明 |
|------|------|--------|------|
| `edevice.load(options?)` | `options` table（可选） | 无 | 初始化字体和状态。options 支持 `fontSize`、`expanded` |
| `edevice.update(dt)` | `dt` number | 无 | 更新内部计时器（Copy 按钮闪烁） |
| `edevice.draw()` | 无 | 无 | 绘制浮动按钮和面板 |
| `edevice.mousepressed(x, y, btn)` | 坐标 + 按钮 | boolean | 鼠标按下，返回是否消费事件 |
| `edevice.mousereleased(x, y, btn)` | 坐标 + 按钮 | boolean | 鼠标释放 |
| `edevice.mousemoved(x, y, dx, dy)` | 坐标 + 偏移 | boolean | 鼠标移动（拖动） |
| `edevice.touchpressed(id, x, y)` | 触摸ID + 坐标 | boolean | 触摸按下 |
| `edevice.touchreleased(id, x, y)` | 触摸ID + 坐标 | boolean | 触摸释放 |
| `edevice.touchmoved(id, x, y)` | 触摸ID + 坐标 | boolean | 触摸移动（拖动） |
| `edevice.collectInfo()` | 无 | table | 返回 `{label, value}` 数组，包含所有设备信息 |
| `edevice.formatMemory(memKB)` | number | string | 格式化内存值 |
| `edevice.formatFrameTime(deltaSec)` | number | string | 格式化帧时间 |

## 配置项

| 属性 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `fontSize` | number | 12 | 字体大小 |
| `panelBg` | table | `{0,0,0,0.65}` | 面板背景色 RGBA |
| `textColor` | table | `{1,1,1,0.9}` | 文字颜色 |
| `padding` | number | 10 | 面板内边距 |
| `margin` | number | 10 | 面板外边距 |
| `btnRadius` | number | 22 | 浮动按钮半径 |
| `btnColor` | table | `{0.2,0.6,1.0,0.7}` | 按钮颜色 |
| `btnMargin` | number | 16 | 按钮距屏幕边缘距离 |

## 采集的信息
- Lua Version、LuaJIT 版本、JIT 状态
- 内存使用量（KB/MB）
- CPU 核心数、FPS、帧时间
- 操作系统、LÖVE 版本
- 渲染器、GL 版本、GPU 厂商、GPU 设备

## 交互行为
- **短按**按钮：展开/收起信息面板
- **按住拖动**按钮：自由移动位置（阈值 4px 区分点击和拖动）
- **Copy 按钮**：面板展开时右下角，点击复制所有信息到剪贴板，闪绿 0.6 秒反馈

## 依赖
- LÖVE 11.5+
- 使用的 API：`love.graphics`、`love.system`、`love.timer`、`love.getVersion`

## 设计决策
- 按钮默认右下角，拖动后记住位置，不持久化（重启回到默认）
- 面板优先在按钮上方展开，空间不足时自动翻到下方
- 拖动阈值 4px 避免手指抖动误判为拖动
- Copy 使用 `love.system.setClipboardText`，Android 上也可用

## 变更记录
| 日期 | 变更内容 |
|------|----------|
| 2026-04-10 | 初始版本：浮动按钮、展开/收起、设备信息采集 |
| 2026-04-10 | 增加按住拖动功能 |
| 2026-04-10 | 增加 Copy 按钮 |
