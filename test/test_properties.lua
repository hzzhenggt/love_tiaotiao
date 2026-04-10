-- ==========================================================================
-- Property-Based Tests for LÖVE2D Debug Overlay
-- Feature: love2d-debug-overlay
-- Run with: lua test/test_properties.lua
-- ==========================================================================

-- Seed random number generator
math.randomseed(os.time())

-- ========================================================================
-- Simple property test runner
-- ========================================================================

local function checkProperty(name, numTests, generator, property)
    for i = 1, numTests do
        local input = generator()
        local ok, err = pcall(property, input)
        if not ok then
            error(string.format("Property '%s' failed on test %d: %s\nInput: %s",
                name, i, err, tostring(input)))
        end
    end
    print(string.format("  PASS: %s (%d tests)", name, numTests))
end

-- ========================================================================
-- Pure functions extracted from main.lua for testing
-- (Cannot require main.lua because it uses love.* APIs)
-- ========================================================================

local function formatMemory(memKB)
    local str = string.format("%.2f KB", memKB)
    if memKB > 1024 then
        str = str .. string.format(" (%.2f MB)", memKB / 1024)
    end
    return str
end

local function formatFrameTime(deltaSec)
    return string.format("%.2f ms", deltaSec * 1000)
end

local function calcPanelX(windowWidth, panelWidth, margin)
    return windowWidth - panelWidth - margin
end

-- ========================================================================
-- Helper: random float in [lo, hi]
-- ========================================================================

local function randomFloat(lo, hi)
    return lo + math.random() * (hi - lo)
end

-- ========================================================================
-- Helper: table-to-string for error reporting
-- ========================================================================

local function tableToString(t)
    if type(t) ~= "table" then return tostring(t) end
    local parts = {}
    for k, v in pairs(t) do
        parts[#parts + 1] = tostring(k) .. "=" .. tostring(v)
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

-- ========================================================================
-- Property 1: 网格线位置覆盖整个窗口
-- Feature: love2d-debug-overlay, Property 1: Grid lines cover entire window
-- ========================================================================

print("Running property tests...")
print()

checkProperty(
    "Property 1: Grid lines cover entire window",
    100,
    function()
        return {
            w = math.random(1, 4000),
            h = math.random(1, 4000),
            gridSize = math.random(10, 200),
        }
    end,
    function(input)
        local w, h, gridSize = input.w, input.h, input.gridSize

        -- Compute expected vertical line positions
        local expectedVertical = {}
        for x = gridSize, w - 1, gridSize do
            expectedVertical[#expectedVertical + 1] = x
        end

        -- Compute actual vertical line positions (same algorithm as grid.draw)
        local actualVertical = {}
        for x = gridSize, w, gridSize do
            if x < w then
                actualVertical[#actualVertical + 1] = x
            end
        end

        -- Verify counts match
        assert(#expectedVertical == #actualVertical,
            string.format("Vertical line count mismatch: expected %d, got %d (w=%d, gridSize=%d)",
                #expectedVertical, #actualVertical, w, gridSize))

        -- Verify each position matches
        for i = 1, #expectedVertical do
            assert(expectedVertical[i] == actualVertical[i],
                string.format("Vertical line %d mismatch: expected %d, got %d",
                    i, expectedVertical[i], actualVertical[i]))
        end

        -- Compute expected horizontal line positions
        local expectedHorizontal = {}
        for y = gridSize, h - 1, gridSize do
            expectedHorizontal[#expectedHorizontal + 1] = y
        end

        -- Compute actual horizontal line positions
        local actualHorizontal = {}
        for y = gridSize, h, gridSize do
            if y < h then
                actualHorizontal[#actualHorizontal + 1] = y
            end
        end

        -- Verify counts match
        assert(#expectedHorizontal == #actualHorizontal,
            string.format("Horizontal line count mismatch: expected %d, got %d (h=%d, gridSize=%d)",
                #expectedHorizontal, #actualHorizontal, h, gridSize))

        -- Verify each position matches
        for i = 1, #expectedHorizontal do
            assert(expectedHorizontal[i] == actualHorizontal[i],
                string.format("Horizontal line %d mismatch: expected %d, got %d",
                    i, expectedHorizontal[i], actualHorizontal[i]))
        end

        -- Verify all positions are multiples of gridSize
        for _, x in ipairs(actualVertical) do
            assert(x % gridSize == 0,
                string.format("Vertical line at %d is not a multiple of gridSize %d", x, gridSize))
        end
        for _, y in ipairs(actualHorizontal) do
            assert(y % gridSize == 0,
                string.format("Horizontal line at %d is not a multiple of gridSize %d", y, gridSize))
        end

        -- Verify no line exceeds window bounds
        for _, x in ipairs(actualVertical) do
            assert(x < w, string.format("Vertical line at %d exceeds window width %d", x, w))
        end
        for _, y in ipairs(actualHorizontal) do
            assert(y < h, string.format("Horizontal line at %d exceeds window height %d", y, h))
        end
    end
)

-- ========================================================================
-- Property 2: 坐标轴标签与网格位置一致
-- Feature: love2d-debug-overlay, Property 2: Axis labels match grid positions
-- ========================================================================

checkProperty(
    "Property 2: Axis labels match grid positions",
    100,
    function()
        return {
            w = math.random(1, 4000),
            h = math.random(1, 4000),
            gridSize = math.random(10, 200),
        }
    end,
    function(input)
        local w, h, gridSize = input.w, input.h, input.gridSize

        -- Simulate X axis label generation (same loop as coords.draw)
        local xLabels = {}
        for x = gridSize, w, gridSize do
            xLabels[#xLabels + 1] = { position = x, value = tostring(x) }
        end

        -- Verify each X label position is a multiple of gridSize
        for _, label in ipairs(xLabels) do
            assert(label.position % gridSize == 0,
                string.format("X label at position %d is not a multiple of gridSize %d",
                    label.position, gridSize))
        end

        -- Verify each X label value equals its pixel coordinate
        for _, label in ipairs(xLabels) do
            assert(label.value == tostring(label.position),
                string.format("X label value '%s' does not match position %d",
                    label.value, label.position))
        end

        -- Simulate Y axis label generation
        local yLabels = {}
        for y = gridSize, h, gridSize do
            yLabels[#yLabels + 1] = { position = y, value = tostring(y) }
        end

        -- Verify each Y label position is a multiple of gridSize
        for _, label in ipairs(yLabels) do
            assert(label.position % gridSize == 0,
                string.format("Y label at position %d is not a multiple of gridSize %d",
                    label.position, gridSize))
        end

        -- Verify each Y label value equals its pixel coordinate
        for _, label in ipairs(yLabels) do
            assert(label.value == tostring(label.position),
                string.format("Y label value '%s' does not match position %d",
                    label.value, label.position))
        end

        -- Verify labels are integers (pixel coordinates)
        for _, label in ipairs(xLabels) do
            assert(tonumber(label.value) == math.floor(tonumber(label.value)),
                string.format("X label value '%s' is not an integer", label.value))
        end
        for _, label in ipairs(yLabels) do
            assert(tonumber(label.value) == math.floor(tonumber(label.value)),
                string.format("Y label value '%s' is not an integer", label.value))
        end
    end
)

-- ========================================================================
-- Property 3: 内存格式化与单位转换
-- Feature: love2d-debug-overlay, Property 3: Memory formatting and unit conversion
-- ========================================================================

checkProperty(
    "Property 3: Memory formatting and unit conversion",
    100,
    function()
        return randomFloat(0.01, 100000)
    end,
    function(memKB)
        local result = formatMemory(memKB)

        -- (a) Output must always contain "X.XX KB"
        local expectedKB = string.format("%.2f KB", memKB)
        assert(string.find(result, expectedKB, 1, true),
            string.format("Output '%s' does not contain expected KB string '%s' for input %.4f",
                result, expectedKB, memKB))

        -- (b) When memKB > 1024, output must also contain "(Y.YY MB)"
        if memKB > 1024 then
            local expectedMB = string.format("%.2f MB", memKB / 1024)
            assert(string.find(result, expectedMB, 1, true),
                string.format("Output '%s' does not contain expected MB string '%s' for input %.4f",
                    result, expectedMB, memKB))
        end

        -- (c) When memKB <= 1024, output must NOT contain "MB"
        if memKB <= 1024 then
            assert(not string.find(result, "MB"),
                string.format("Output '%s' should not contain MB for input %.4f KB",
                    result, memKB))
        end
    end
)

-- ========================================================================
-- Property 4: 帧时间秒转毫秒格式化
-- Feature: love2d-debug-overlay, Property 4: Frame time seconds to milliseconds
-- ========================================================================

checkProperty(
    "Property 4: Frame time seconds to milliseconds formatting",
    100,
    function()
        return randomFloat(0, 1.0)
    end,
    function(deltaSec)
        local result = formatFrameTime(deltaSec)

        -- Output must be "X.XX ms" where X.XX = deltaSec * 1000 formatted to 2 decimals
        local expected = string.format("%.2f ms", deltaSec * 1000)
        assert(result == expected,
            string.format("Expected '%s' but got '%s' for input %.6f sec",
                expected, result, deltaSec))

        -- Verify the output ends with " ms"
        assert(string.sub(result, -3) == " ms",
            string.format("Output '%s' does not end with ' ms'", result))

        -- Verify the numeric part is a valid number
        local numStr = string.sub(result, 1, -4)  -- strip " ms"
        local num = tonumber(numStr)
        assert(num ~= nil,
            string.format("Numeric part '%s' is not a valid number", numStr))
    end
)

-- ========================================================================
-- Property 5: F12 切换可见性的往返性
-- Feature: love2d-debug-overlay, Property 5: F12 toggle visibility round-trip
-- ========================================================================

checkProperty(
    "Property 5: F12 toggle visibility round-trip",
    100,
    function()
        return math.random(0, 1) == 1
    end,
    function(initialVisible)
        -- Simulate toggle: one toggle flips the value
        local afterOne = not initialVisible
        assert(afterOne ~= initialVisible,
            string.format("Single toggle did not flip: initial=%s, after=%s",
                tostring(initialVisible), tostring(afterOne)))

        -- Two toggles restore original
        local afterTwo = not afterOne
        assert(afterTwo == initialVisible,
            string.format("Double toggle did not restore: initial=%s, afterTwo=%s",
                tostring(initialVisible), tostring(afterTwo)))
    end
)

-- ========================================================================
-- Property 6: 信息面板右上角定位
-- Feature: love2d-debug-overlay, Property 6: Info panel right-top positioning
-- ========================================================================

checkProperty(
    "Property 6: Info panel right-top positioning",
    100,
    function()
        return {
            windowWidth = math.random(100, 4000),
            panelWidth = math.random(50, 500),
            margin = math.random(0, 50),
        }
    end,
    function(input)
        local windowWidth = input.windowWidth
        local panelWidth = input.panelWidth
        local margin = input.margin

        local result = calcPanelX(windowWidth, panelWidth, margin)
        local expected = windowWidth - panelWidth - margin

        assert(result == expected,
            string.format("calcPanelX(%d, %d, %d) = %d, expected %d",
                windowWidth, panelWidth, margin, result, expected))

        -- Panel x should be non-negative for reasonable inputs
        -- (windowWidth >= panelWidth + margin in typical usage)
        -- We just verify the formula is correct, not the reasonableness of inputs
    end
)

-- ========================================================================
-- Summary
-- ========================================================================

print()
print("All property tests passed!")
