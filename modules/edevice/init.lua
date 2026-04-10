-- ==========================================================================
-- edevice - LÖVE2D 设备信息浮动面板模块
-- 独立模块，可在任意 LÖVE2D 项目中 require 使用
-- 用法：
--   local edevice = require("edevice")
--   function love.load() edevice.load() end
--   function love.draw() edevice.draw() end
--   function love.mousepressed(x, y, btn) edevice.mousepressed(x, y, btn) end
--   function love.touchpressed(id, x, y) edevice.touchpressed(id, x, y) end
-- ==========================================================================

local edevice = {
    -- 状态
    expanded = false,          -- 面板是否展开
    font = nil,                -- 字体对象

    -- 外观配置
    fontSize = 12,
    panelBg = {0, 0, 0, 0.65},
    textColor = {1, 1, 1, 0.9},
    padding = 10,
    margin = 10,

    -- 浮动按钮配置
    btnRadius = 22,
    btnColor = {0.2, 0.6, 1.0, 0.7},
    btnIconColor = {1, 1, 1, 0.95},
    btnMargin = 16,

    -- 内部缓存（运行时计算）
    _btnX = 0,
    _btnY = 0,
    _panelRect = nil,  -- {x, y, w, h}
}

-- ========================================================================
-- 信息采集
-- ========================================================================

--- 格式化内存值
--- @param memKB number
--- @return string
function edevice.formatMemory(memKB)
    local str = string.format("%.2f KB", memKB)
    if memKB > 1024 then
        str = str .. string.format(" (%.2f MB)", memKB / 1024)
    end
    return str
end

--- 格式化帧时间
--- @param deltaSec number
--- @return string
function edevice.formatFrameTime(deltaSec)
    return string.format("%.2f ms", deltaSec * 1000)
end

--- 采集设备/系统信息
--- @return table {label, value} 数组
function edevice.collectInfo()
    local info = {}

    info[#info + 1] = { label = "Lua Version",  value = _VERSION }

    local hasJit = type(jit) == "table"
    info[#info + 1] = { label = "LuaJIT", value = hasJit and (jit.version or "Unknown") or "N/A" }
    info[#info + 1] = { label = "JIT Status", value = hasJit and (jit.status() and "Enabled" or "Disabled") or "N/A" }

    info[#info + 1] = { label = "Memory", value = edevice.formatMemory(collectgarbage("count")) }
    info[#info + 1] = { label = "CPU Cores", value = tostring(love.system.getProcessorCount()) }
    info[#info + 1] = { label = "FPS", value = tostring(love.timer.getFPS()) }
    info[#info + 1] = { label = "Frame Time", value = edevice.formatFrameTime(love.timer.getAverageDelta()) }
    info[#info + 1] = { label = "OS", value = love.system.getOS() }

    local major, minor, revision = love.getVersion()
    info[#info + 1] = { label = "LÖVE Version", value = string.format("%d.%d.%d", major, minor, revision) }

    local name, version, vendor, device = love.graphics.getRendererInfo()
    info[#info + 1] = { label = "Renderer",   value = name }
    info[#info + 1] = { label = "GL Version", value = version }
    info[#info + 1] = { label = "GPU Vendor", value = vendor }
    info[#info + 1] = { label = "GPU Device", value = device }

    return info
end

-- ========================================================================
-- 生命周期
-- ========================================================================

function edevice.load(options)
    options = options or {}
    if options.fontSize then edevice.fontSize = options.fontSize end
    if options.expanded ~= nil then edevice.expanded = options.expanded end
    edevice.font = love.graphics.newFont(edevice.fontSize)
end

-- ========================================================================
-- 绘制
-- ========================================================================

--- 计算浮动按钮位置（右下角）
local function calcBtnPos()
    local w, h = love.graphics.getDimensions()
    edevice._btnX = w - edevice.btnMargin - edevice.btnRadius
    edevice._btnY = h - edevice.btnMargin - edevice.btnRadius
end

--- 绘制浮动按钮
local function drawButton()
    calcBtnPos()
    local bx, by, r = edevice._btnX, edevice._btnY, edevice.btnRadius

    -- 圆形背景
    love.graphics.setColor(edevice.btnColor)
    love.graphics.circle("fill", bx, by, r)

    -- 图标：展开时画 "×"，收起时画 "i"
    love.graphics.setColor(edevice.btnIconColor)
    if edevice.expanded then
        -- × 号
        local s = r * 0.4
        love.graphics.setLineWidth(2)
        love.graphics.line(bx - s, by - s, bx + s, by + s)
        love.graphics.line(bx + s, by - s, bx - s, by + s)
        love.graphics.setLineWidth(1)
    else
        -- "i" 字母
        love.graphics.setFont(edevice.font)
        local text = "i"
        local tw = edevice.font:getWidth(text)
        local th = edevice.font:getHeight()
        love.graphics.print(text, bx - tw / 2, by - th / 2)
    end
end

--- 绘制信息面板（从按钮上方展开）
local function drawPanel()
    if not edevice.expanded then return end

    love.graphics.setFont(edevice.font)
    local lines = edevice.collectInfo()
    local lineHeight = edevice.font:getHeight()

    -- 计算面板尺寸
    local maxTextWidth = 0
    for _, line in ipairs(lines) do
        local w = edevice.font:getWidth(line.label .. ": " .. line.value)
        if w > maxTextWidth then maxTextWidth = w end
    end

    local pw = maxTextWidth + 2 * edevice.padding
    local ph = #lines * lineHeight + 2 * edevice.padding

    -- 定位：按钮正上方，右对齐
    local winW, winH = love.graphics.getDimensions()
    local px = winW - pw - edevice.margin
    local py = winH - edevice.btnMargin - edevice.btnRadius * 2 - edevice.margin - ph

    -- 确保不超出屏幕
    if px < edevice.margin then px = edevice.margin end
    if py < edevice.margin then py = edevice.margin end

    edevice._panelRect = { x = px, y = py, w = pw, h = ph }

    -- 半透明背景
    love.graphics.setColor(edevice.panelBg)
    love.graphics.rectangle("fill", px, py, pw, ph, 6, 6)

    -- 文字
    love.graphics.setColor(edevice.textColor)
    for i, line in ipairs(lines) do
        love.graphics.print(
            line.label .. ": " .. line.value,
            px + edevice.padding,
            py + edevice.padding + (i - 1) * lineHeight
        )
    end
end

function edevice.draw()
    if not edevice.font then return end
    local prevFont = love.graphics.getFont()
    drawPanel()
    drawButton()
    love.graphics.setColor(1, 1, 1, 1)
    if prevFont then love.graphics.setFont(prevFont) end
end

-- ========================================================================
-- 交互
-- ========================================================================

local function isInsideCircle(px, py, cx, cy, r)
    return (px - cx) ^ 2 + (py - cy) ^ 2 <= r ^ 2
end

function edevice.mousepressed(x, y, button)
    if button ~= 1 then return false end
    calcBtnPos()
    if isInsideCircle(x, y, edevice._btnX, edevice._btnY, edevice.btnRadius) then
        edevice.expanded = not edevice.expanded
        return true  -- 事件已消费
    end
    return false
end

function edevice.touchpressed(id, x, y)
    calcBtnPos()
    if isInsideCircle(x, y, edevice._btnX, edevice._btnY, edevice.btnRadius) then
        edevice.expanded = not edevice.expanded
        return true
    end
    return false
end

return edevice
