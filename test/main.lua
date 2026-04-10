-- ==========================================================================
-- LÖVE2D Debug Overlay - 调试信息覆盖层
-- 单文件模块化实现：网格背景、坐标系、系统信息面板
-- ==========================================================================

-- DebugOverlay 主控制器状态表
local overlay = {
    visible = true,                    -- 默认可见（需求 9.5）
    font = nil,                        -- 等宽字体对象（love.load 时创建）
    fontSize = 12,                     -- 字体大小（像素）
    gridSize = 50,                     -- 网格间距（像素）
    gridColor = {1, 1, 1, 0.15},      -- 网格线颜色 RGBA
    labelColor = {1, 1, 1, 0.6},      -- 坐标标签颜色
    panelBg = {0, 0, 0, 0.7},         -- 面板背景颜色
    panelTextColor = {1, 1, 1, 0.9},  -- 面板文字颜色
    panelPadding = 10,                 -- 面板内边距
    panelMargin = 10,                  -- 面板外边距
}

-- Grid_Renderer 网格渲染器
local grid = {}

-- Coordinate_Display 坐标系显示
local coords = {}

-- Info_Panel 信息面板
local panel = {}

-- ========================================================================
-- overlay 方法
-- ========================================================================

--- 初始化字体等资源，在 love.load 中调用
function overlay.load()
    overlay.font = love.graphics.newFont(overlay.fontSize)
end

--- 按层级渲染所有组件，在 love.draw 中调用
function overlay.draw()
    if not overlay.visible then
        return
    end
    -- 渲染层级：grid（最底层）→ coords → panel（最顶层）
    grid.draw(overlay.gridSize)
    love.graphics.setColor(1, 1, 1, 1)

    coords.draw(overlay.gridSize, overlay.font)
    love.graphics.setColor(1, 1, 1, 1)

    panel.draw(overlay.font)
    love.graphics.setColor(1, 1, 1, 1)
end

--- 处理按键事件，F12 切换可见性（需求 9.1）
function overlay.keypressed(key)
    if key == "f12" then
        overlay.visible = not overlay.visible
    end
end

-- ========================================================================
-- 组件 stub 函数（后续任务中实现）
-- ========================================================================

--- 绘制网格线（Task 2.1 实现）
function grid.draw(gridSize)
    local w, h = love.graphics.getDimensions()
    love.graphics.setColor(1, 1, 1, 0.15)
    -- 垂直线
    for x = gridSize, w, gridSize do
        love.graphics.line(x, 0, x, h)
    end
    -- 水平线
    for y = gridSize, h, gridSize do
        love.graphics.line(0, y, w, y)
    end
end

--- 绘制坐标轴标签（Task 3.1 实现）
function coords.draw(gridSize, font)
    love.graphics.setFont(font)
    local w, h = love.graphics.getDimensions()

    -- 半透明标签颜色
    love.graphics.setColor(1, 1, 1, 0.6)

    -- X 轴标签：沿窗口顶部，每个网格线位置打印 x 值
    for x = gridSize, w, gridSize do
        love.graphics.print(tostring(x), x + 2, 2)
    end

    -- Y 轴标签：沿窗口左侧，每个网格线位置打印 y 值
    for y = gridSize, h, gridSize do
        love.graphics.print(tostring(y), 2, y + 2)
    end

    -- 原点标记：在 (0,0) 处绘制小圆点
    love.graphics.circle("fill", 0, 0, 3)
end

--- 格式化内存值（纯函数，供属性测试使用）
--- @param memKB number 内存使用量（KB）
--- @return string 格式化后的字符串
function panel.formatMemory(memKB)
    local str = string.format("%.2f KB", memKB)
    if memKB > 1024 then
        str = str .. string.format(" (%.2f MB)", memKB / 1024)
    end
    return str
end

--- 格式化帧时间（纯函数，供属性测试使用）
--- @param deltaSec number 帧时间（秒）
--- @return string 格式化后的字符串
function panel.formatFrameTime(deltaSec)
    return string.format("%.2f ms", deltaSec * 1000)
end

--- 计算面板 X 坐标（纯函数，供属性测试使用）
--- @param windowWidth number 窗口宽度
--- @param panelWidth number 面板宽度
--- @param margin number 外边距
--- @return number 面板左上角 x 坐标
function panel.calcPanelX(windowWidth, panelWidth, margin)
    return windowWidth - panelWidth - margin
end

--- 采集系统信息（Task 5.1 实现）
--- @return table {label, value} 对的数组
function panel.collectInfo()
    local info = {}

    -- 1. Lua Version
    info[#info + 1] = { label = "Lua Version",  value = _VERSION }

    -- 2. LuaJIT Version
    local hasJit = type(jit) == "table"
    if hasJit then
        info[#info + 1] = { label = "LuaJIT",  value = jit.version or "Unknown" }
    else
        info[#info + 1] = { label = "LuaJIT",  value = "N/A" }
    end

    -- 3. JIT Status
    if hasJit then
        local status = jit.status()
        info[#info + 1] = { label = "JIT Status",  value = status and "Enabled" or "Disabled" }
    else
        info[#info + 1] = { label = "JIT Status",  value = "N/A" }
    end

    -- 4. Memory
    local memKB = collectgarbage("count")
    info[#info + 1] = { label = "Memory",  value = panel.formatMemory(memKB) }

    -- 5. CPU Cores
    info[#info + 1] = { label = "CPU Cores",  value = tostring(love.system.getProcessorCount()) }

    -- 6. FPS
    info[#info + 1] = { label = "FPS",  value = tostring(love.timer.getFPS()) }

    -- 7. Frame Time
    local delta = love.timer.getAverageDelta()
    info[#info + 1] = { label = "Frame Time",  value = panel.formatFrameTime(delta) }

    -- 8. OS
    info[#info + 1] = { label = "OS",  value = love.system.getOS() }

    -- 9. LÖVE Version
    local major, minor, revision = love.getVersion()
    info[#info + 1] = { label = "LÖVE Version",  value = string.format("%d.%d.%d", major, minor, revision) }

    -- 10. Renderer Info (4 separate lines)
    local name, version, vendor, device = love.graphics.getRendererInfo()
    info[#info + 1] = { label = "Renderer",    value = name }
    info[#info + 1] = { label = "GL Version",  value = version }
    info[#info + 1] = { label = "GPU Vendor",  value = vendor }
    info[#info + 1] = { label = "GPU Device",  value = device }

    return info
end

--- 绘制信息面板（Task 5.2 实现）
function panel.draw(font)
    love.graphics.setFont(font)

    local lines = panel.collectInfo()
    local lineHeight = font:getHeight()

    -- 计算面板宽度：找最长文本行
    local maxTextWidth = 0
    for _, line in ipairs(lines) do
        local text = line.label .. ": " .. line.value
        local w = font:getWidth(text)
        if w > maxTextWidth then
            maxTextWidth = w
        end
    end

    local panelWidth  = maxTextWidth + 2 * overlay.panelPadding
    local panelHeight = #lines * lineHeight + 2 * overlay.panelPadding

    -- 右上角定位
    local x = panel.calcPanelX(love.graphics.getWidth(), panelWidth, overlay.panelMargin)
    local y = overlay.panelMargin

    -- 半透明深色背景
    love.graphics.setColor(overlay.panelBg)
    love.graphics.rectangle("fill", x, y, panelWidth, panelHeight)

    -- 逐行绘制信息文本
    love.graphics.setColor(overlay.panelTextColor)
    for i, line in ipairs(lines) do
        love.graphics.print(
            line.label .. ": " .. line.value,
            x + overlay.panelPadding,
            y + overlay.panelPadding + (i - 1) * lineHeight
        )
    end
end

-- ========================================================================
-- LÖVE2D 回调
-- ========================================================================

function love.load()
    overlay.load()
end

function love.draw()
    overlay.draw()
end

function love.keypressed(key)
    overlay.keypressed(key)
end

-- ========================================================================
-- 导出供测试使用
-- 当文件被 require 而非由 LÖVE2D 运行时，返回内部模块表
-- ========================================================================
if not love then
    return { overlay = overlay, grid = grid, coords = coords, panel = panel }
end
