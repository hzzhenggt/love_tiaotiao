# 需求文档

## 简介

为 LÖVE2D 游戏引擎创建一个调试信息覆盖模板（Debug Overlay），用于在游戏运行时以半透明覆盖层的形式显示网格背景、坐标系、系统信息（Lua 版本、LuaJIT 信息、内存使用量、CPU 信息、CPU 使用率、设备信息）等调试数据。该模板作为开发阶段的测试工具，帮助开发者快速了解运行环境和性能状态。

## 术语表

- **Debug_Overlay**: 调试信息覆盖层，在游戏画面上方以半透明方式渲染调试信息的模块
- **Grid_Renderer**: 网格渲染器，负责在游戏背景上绘制等间距网格线的组件
- **Coordinate_Display**: 坐标系显示组件，负责在网格上标注坐标刻度和原点的组件
- **Info_Panel**: 信息面板，负责在屏幕固定区域显示系统和性能信息的组件
- **LÖVE2D**: 基于 Lua 的 2D 游戏引擎框架，提供 love.graphics、love.timer 等 API
- **LuaJIT**: Lua 语言的即时编译器实现，LÖVE2D 默认使用的 Lua 运行时
- **Frame_Rate**: 帧率，每秒渲染的画面帧数（FPS）

## 需求

### 需求 1：网格背景渲染

**用户故事：** 作为游戏开发者，我想在游戏画面上看到等间距的网格线，以便直观地判断游戏对象的位置和大小。

#### 验收标准

1. WHEN the Debug_Overlay is active, THE Grid_Renderer SHALL draw horizontal and vertical grid lines across the entire game window at a fixed interval of 50 pixels
2. THE Grid_Renderer SHALL render grid lines using a semi-transparent color (alpha value between 0.1 and 0.3) to avoid obscuring game content
3. WHEN the game window is resized, THE Grid_Renderer SHALL recalculate and redraw grid lines to cover the new window dimensions
4. THE Grid_Renderer SHALL render grid lines behind all other overlay elements

### 需求 2：坐标系显示

**用户故事：** 作为游戏开发者，我想在网格上看到坐标刻度标注，以便快速定位屏幕上的像素坐标。

#### 验收标准

1. WHEN the Debug_Overlay is active, THE Coordinate_Display SHALL draw X axis labels along the top edge of the window at each grid line intersection
2. WHEN the Debug_Overlay is active, THE Coordinate_Display SHALL draw Y axis labels along the left edge of the window at each grid line intersection
3. THE Coordinate_Display SHALL display coordinate values in pixel units as integer numbers
4. THE Coordinate_Display SHALL mark the origin point (0, 0) at the top-left corner of the window with a distinct visual indicator
5. THE Coordinate_Display SHALL render axis labels using a readable font size between 10 and 14 pixels

### 需求 3：Lua 版本信息显示

**用户故事：** 作为游戏开发者，我想看到当前运行的 Lua 版本号，以便确认运行环境是否符合预期。

#### 验收标准

1. THE Info_Panel SHALL display the current Lua version string obtained from the global _VERSION variable
2. THE Info_Panel SHALL display the Lua version information with the label "Lua Version" followed by the version string

### 需求 4：LuaJIT 信息显示

**用户故事：** 作为游戏开发者，我想看到 LuaJIT 的版本和状态信息，以便确认 JIT 编译器是否正常工作。

#### 验收标准

1. WHEN LuaJIT is available, THE Info_Panel SHALL display the LuaJIT version string obtained from the jit.version variable
2. WHEN LuaJIT is available, THE Info_Panel SHALL display the JIT compilation status (enabled or disabled)
3. IF LuaJIT is not available, THEN THE Info_Panel SHALL display "LuaJIT: N/A" as the status text

### 需求 5：Lua 内存使用量显示

**用户故事：** 作为游戏开发者，我想实时看到 Lua 虚拟机的内存使用量，以便监控内存泄漏和优化内存使用。

#### 验收标准

1. THE Info_Panel SHALL display the current Lua memory usage obtained from collectgarbage("count") in kilobytes (KB)
2. THE Info_Panel SHALL update the displayed memory usage value on every frame
3. THE Info_Panel SHALL format the memory value to two decimal places followed by the unit "KB"
4. WHEN the memory usage exceeds 1024 KB, THE Info_Panel SHALL additionally display the value converted to megabytes (MB) with two decimal places

### 需求 6：CPU 信息显示

**用户故事：** 作为游戏开发者，我想看到当前设备的 CPU 处理器核心数信息，以便了解运行环境的硬件能力。

#### 验收标准

1. THE Info_Panel SHALL display the number of logical processor cores obtained from love.system.getProcessorCount()
2. THE Info_Panel SHALL display the processor count with the label "CPU Cores"

### 需求 7：CPU 使用率显示（帧时间）

**用户故事：** 作为游戏开发者，我想看到当前的帧率和帧时间信息，以便评估游戏的性能表现。

#### 验收标准

1. THE Info_Panel SHALL display the current frames per second (FPS) obtained from love.timer.getFPS()
2. THE Info_Panel SHALL display the average delta time per frame obtained from love.timer.getAverageDelta() in milliseconds with two decimal places
3. THE Info_Panel SHALL update FPS and delta time values on every frame
4. THE Info_Panel SHALL display the FPS value with the label "FPS" and the delta time with the label "Frame Time"

### 需求 8：设备信息显示

**用户故事：** 作为游戏开发者，我想看到当前设备的操作系统和图形渲染器信息，以便了解运行平台的特性。

#### 验收标准

1. THE Info_Panel SHALL display the operating system name obtained from love.system.getOS()
2. THE Info_Panel SHALL display the LÖVE2D engine version obtained from love.getVersion()
3. THE Info_Panel SHALL display the graphics renderer name, version, vendor, and device obtained from love.graphics.getRendererInfo()
4. THE Info_Panel SHALL display each piece of device information on a separate line with a descriptive label

### 需求 9：覆盖层整体布局与交互

**用户故事：** 作为游戏开发者，我想通过快捷键控制调试覆盖层的显示和隐藏，以便在需要时查看调试信息而不影响正常开发。

#### 验收标准

1. WHEN the user presses the F12 key, THE Debug_Overlay SHALL toggle between visible and hidden states
2. WHILE the Debug_Overlay is visible, THE Info_Panel SHALL be rendered in a fixed position at the top-right corner of the window with a semi-transparent dark background
3. THE Info_Panel SHALL render all text using a monospaced or clearly readable font with sufficient contrast against the background
4. THE Debug_Overlay SHALL render all overlay elements at a consistent 60 FPS without causing the host game frame rate to drop by more than 5%
5. WHEN the game starts, THE Debug_Overlay SHALL default to the visible state
