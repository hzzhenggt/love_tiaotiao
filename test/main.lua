-- ==========================================================================
-- LÖVE2D Debug Overlay - 调试信息覆盖层
-- 网格背景、坐标系 + edevice 浮动设备信息面板
-- ==========================================================================

local edevice = require("edevice")

-- DebugOverlay 主控制器状态表
local overlay = {
    visible = true,
    font = nil,
    fontSize = 12,
    gridSize = 50,
    gridColor = {1, 1, 1, 0.15},
    labelColor = {1, 1, 1, 0.6},
}

-- Grid_Renderer 网格渲染器
local grid = {}

-- Coordinate_Display 坐标系显示
local coords = {}

-- ========================================================================
-- overlay 方法
-- ========================================================================

function overlay.load()
    overlay.font = love.graphics.newFont(overlay.fontSize)
    edevice.load()
end

function overlay.draw()
    if not overlay.visible then return end

    grid.draw(overlay.gridSize)
    love.graphics.setColor(1, 1, 1, 1)

    coords.draw(overlay.gridSize, overlay.font)
    love.graphics.setColor(1, 1, 1, 1)

    -- edevice 浮动面板（独立绘制，不受 overlay.visible 以外的控制）
    edevice.draw()
    love.graphics.setColor(1, 1, 1, 1)
end

function overlay.keypressed(key)
    if key == "f12" then
        overlay.visible = not overlay.visible
    end
end

-- ========================================================================
-- grid / coords 组件
-- ========================================================================

function grid.draw(gridSize)
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1, 0.15)
    for x = gridSize, w, gridSize do
        love.graphics.line(x, 0, x, h)
    end
    for y = gridSize, h, gridSize do
        love.graphics.line(0, y, w, y)
    end
end

function coords.draw(gridSize, font)
    love.graphics.setFont(font)
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1, 0.6)

    for x = gridSize, w, gridSize do
        love.graphics.print(tostring(x), x + 2, 2)
    end
    for y = gridSize, h, gridSize do
        love.graphics.print(tostring(y), 2, y + 2)
    end

    love.graphics.circle("fill", 0, 0, 3)
end

-- ========================================================================
-- LÖVE2D 回调
-- ========================================================================

function love.load()
    overlay.load()
end

function love.update(dt)
    edevice.update(dt)
end

function love.draw()
    overlay.draw()
end

function love.keypressed(key)
    overlay.keypressed(key)
end

function love.mousepressed(x, y, button)
    edevice.mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    edevice.mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    edevice.mousemoved(x, y, dx, dy)
end

function love.touchpressed(id, x, y)
    edevice.touchpressed(id, x, y)
end

function love.touchmoved(id, x, y)
    edevice.touchmoved(id, x, y)
end

function love.touchreleased(id, x, y)
    edevice.touchreleased(id, x, y)
end

-- ========================================================================
-- 导出供测试使用
-- ========================================================================
if not love then
    return { overlay = overlay, grid = grid, coords = coords }
end
