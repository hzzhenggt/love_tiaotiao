-- ==========================================================================
-- edevice - LÖVE2D 设备信息浮动面板模块
-- 独立模块，可在任意 LÖVE2D 项目中 require 使用
-- 支持：浮动按钮、点击展开/收起、按住拖动
-- 用法：
--   local edevice = require("edevice")
--   function love.load() edevice.load() end
--   function love.draw() edevice.draw() end
--   function love.mousepressed(x, y, btn) edevice.mousepressed(x, y, btn) end
--   function love.mousereleased(x, y, btn) edevice.mousereleased(x, y, btn) end
--   function love.mousemoved(x, y, dx, dy) edevice.mousemoved(x, y, dx, dy) end
--   function love.touchpressed(id, x, y) edevice.touchpressed(id, x, y) end
--   function love.touchreleased(id, x, y) edevice.touchreleased(id, x, y) end
--   function love.touchmoved(id, x, y) edevice.touchmoved(id, x, y) end
-- ==========================================================================

local edevice = {
    -- 状态
    expanded = false,
    font = nil,

    -- 外观配置
    fontSize = 12,
    panelBg = {0, 0, 0, 0.65},
    textColor = {1, 1, 1, 0.9},
    padding = 10,
    margin = 10,

    -- 浮动按钮配置
    btnRadius = 22,
    btnColor = {0.2, 0.6, 1.0, 0.7},
    btnDragColor = {0.3, 0.7, 1.0, 0.9},  -- 拖动时高亮
    btnIconColor = {1, 1, 1, 0.95},
    btnMargin = 16,

    -- 按钮位置（可拖动，nil 表示使用默认右下角）
    _btnX = nil,
    _btnY = nil,

    -- 拖动状态
    _dragging = false,
    _dragOffsetX = 0,
    _dragOffsetY = 0,
    _dragMoved = false,       -- 本次按下是否产生了移动
    _dragThreshold = 4,       -- 移动超过此像素才算拖动（区分点击）
    _pressX = 0,
    _pressY = 0,

    -- 触摸拖动
    _touchId = nil,

    -- 面板缓存
    _panelRect = nil,
}

-- ========================================================================
-- 信息采集
-- ========================================================================

function edevice.formatMemory(memKB)
    local str = string.format("%.2f KB", memKB)
    if memKB > 1024 then
        str = str .. string.format(" (%.2f MB)", memKB / 1024)
    end
    return str
end

function edevice.formatFrameTime(deltaSec)
    return string.format("%.2f ms", deltaSec * 1000)
end

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
    -- 默认位置：右下角
    edevice._btnX = nil
    edevice._btnY = nil
end

-- ========================================================================
-- 位置计算
-- ========================================================================

--- 获取按钮中心坐标（默认右下角，拖动后为自定义位置）
local function getBtnCenter()
    if edevice._btnX and edevice._btnY then
        return edevice._btnX, edevice._btnY
    end
    local w, h = love.graphics.getDimensions()
    return w - edevice.btnMargin - edevice.btnRadius,
           h - edevice.btnMargin - edevice.btnRadius
end

--- 将按钮位置限制在屏幕内
local function clampBtn(bx, by)
    local w, h = love.graphics.getDimensions()
    local r = edevice.btnRadius
    bx = math.max(r, math.min(w - r, bx))
    by = math.max(r, math.min(h - r, by))
    return bx, by
end

local function isInsideCircle(px, py, cx, cy, r)
    return (px - cx) ^ 2 + (py - cy) ^ 2 <= r ^ 2
end

-- ========================================================================
-- 绘制
-- ========================================================================

local function drawButton()
    local bx, by = getBtnCenter()
    local r = edevice.btnRadius

    -- 拖动时高亮
    if edevice._dragging then
        love.graphics.setColor(edevice.btnDragColor)
    else
        love.graphics.setColor(edevice.btnColor)
    end
    love.graphics.circle("fill", bx, by, r)

    -- 图标
    love.graphics.setColor(edevice.btnIconColor)
    if edevice.expanded then
        local s = r * 0.4
        love.graphics.setLineWidth(2)
        love.graphics.line(bx - s, by - s, bx + s, by + s)
        love.graphics.line(bx + s, by - s, bx - s, by + s)
        love.graphics.setLineWidth(1)
    else
        love.graphics.setFont(edevice.font)
        local text = "i"
        local tw = edevice.font:getWidth(text)
        local th = edevice.font:getHeight()
        love.graphics.print(text, bx - tw / 2, by - th / 2)
    end
end

local function drawPanel()
    if not edevice.expanded then return end

    love.graphics.setFont(edevice.font)
    local lines = edevice.collectInfo()
    local lineHeight = edevice.font:getHeight()

    local maxTextWidth = 0
    for _, line in ipairs(lines) do
        local w = edevice.font:getWidth(line.label .. ": " .. line.value)
        if w > maxTextWidth then maxTextWidth = w end
    end

    local pw = maxTextWidth + 2 * edevice.padding
    local ph = #lines * lineHeight + 2 * edevice.padding

    -- 面板定位：按钮正上方
    local bx, by = getBtnCenter()
    local r = edevice.btnRadius
    local winW, winH = love.graphics.getDimensions()

    local px = bx + r - pw  -- 右对齐到按钮右边缘
    local py = by - r - edevice.margin - ph  -- 按钮上方

    -- 如果上方放不下，放到下方
    if py < edevice.margin then
        py = by + r + edevice.margin
    end
    -- 左右边界
    if px < edevice.margin then px = edevice.margin end
    if px + pw > winW - edevice.margin then px = winW - edevice.margin - pw end

    edevice._panelRect = { x = px, y = py, w = pw, h = ph }

    love.graphics.setColor(edevice.panelBg)
    love.graphics.rectangle("fill", px, py, pw, ph, 6, 6)

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
-- 鼠标交互：按住拖动 + 短按切换
-- ========================================================================

function edevice.mousepressed(x, y, button)
    if button ~= 1 then return false end
    local bx, by = getBtnCenter()
    if isInsideCircle(x, y, bx, by, edevice.btnRadius) then
        edevice._dragging = true
        edevice._dragOffsetX = bx - x
        edevice._dragOffsetY = by - y
        edevice._dragMoved = false
        edevice._pressX = x
        edevice._pressY = y
        return true
    end
    return false
end

function edevice.mousemoved(x, y, dx, dy)
    if not edevice._dragging then return false end
    -- 检查是否超过拖动阈值
    local dist = math.sqrt((x - edevice._pressX)^2 + (y - edevice._pressY)^2)
    if dist >= edevice._dragThreshold then
        edevice._dragMoved = true
    end
    if edevice._dragMoved then
        local nx, ny = clampBtn(x + edevice._dragOffsetX, y + edevice._dragOffsetY)
        edevice._btnX = nx
        edevice._btnY = ny
    end
    return true
end

function edevice.mousereleased(x, y, button)
    if button ~= 1 or not edevice._dragging then return false end
    edevice._dragging = false
    -- 没有移动 → 视为点击，切换展开/收起
    if not edevice._dragMoved then
        edevice.expanded = not edevice.expanded
    end
    return true
end

-- ========================================================================
-- 触摸交互：按住拖动 + 短按切换
-- ========================================================================

function edevice.touchpressed(id, x, y)
    if edevice._touchId then return false end
    local bx, by = getBtnCenter()
    if isInsideCircle(x, y, bx, by, edevice.btnRadius) then
        edevice._touchId = id
        edevice._dragging = true
        edevice._dragOffsetX = bx - x
        edevice._dragOffsetY = by - y
        edevice._dragMoved = false
        edevice._pressX = x
        edevice._pressY = y
        return true
    end
    return false
end

function edevice.touchmoved(id, x, y)
    if id ~= edevice._touchId or not edevice._dragging then return false end
    local dist = math.sqrt((x - edevice._pressX)^2 + (y - edevice._pressY)^2)
    if dist >= edevice._dragThreshold then
        edevice._dragMoved = true
    end
    if edevice._dragMoved then
        local nx, ny = clampBtn(x + edevice._dragOffsetX, y + edevice._dragOffsetY)
        edevice._btnX = nx
        edevice._btnY = ny
    end
    return true
end

function edevice.touchreleased(id, x, y)
    if id ~= edevice._touchId then return false end
    edevice._dragging = false
    edevice._touchId = nil
    if not edevice._dragMoved then
        edevice.expanded = not edevice.expanded
    end
    return true
end

return edevice
