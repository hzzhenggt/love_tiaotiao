# 实现计划：LÖVE2D 调试信息覆盖层

## 概述

基于单文件模块化架构，在 `test/main.lua` 中实现调试覆盖层。按组件逐步构建：先搭建主控制器骨架和 LÖVE2D 回调，再依次实现网格渲染、坐标显示、信息面板，最后整合并完善交互逻辑。属性测试放在 `test/test_properties.lua` 中。

## Tasks

- [x] 1. 搭建主控制器骨架与 LÖVE2D 回调
  - [x] 1.1 创建 `test/main.lua`，定义 overlay 状态表（visible、font、fontSize、gridSize、颜色配置等）
    - 初始化 `overlay.visible = true`（默认可见）
    - 定义 grid、coords、panel 三个 local table 作为组件容器
    - 实现 `love.load()` 回调，调用 `overlay.load()` 初始化字体资源
    - 实现 `love.draw()` 回调，根据 `overlay.visible` 决定是否调用各组件 draw
    - 实现 `love.keypressed(key)` 回调，F12 键切换 `overlay.visible`
    - _需求: 9.1, 9.3, 9.5_

- [x] 2. 实现 Grid_Renderer 网格渲染
  - [x] 2.1 实现 `grid.draw(gridSize)` 函数
    - 使用 `love.graphics.getDimensions()` 获取窗口尺寸
    - 设置半透明颜色（alpha 0.15）绘制垂直和水平网格线
    - 使用 `love.graphics.line()` 从 gridSize 开始以 gridSize 为步长绘制
    - 确保网格线覆盖整个窗口区域
    - _需求: 1.1, 1.2, 1.3, 1.4_

  - [x] 2.2 编写属性测试：网格线位置覆盖整个窗口
    - **Property 1: 网格线位置覆盖整个窗口**
    - 随机生成窗口尺寸 w∈[1,4000]、h∈[1,4000]、gridSize∈[10,200]
    - 验证垂直线 x 坐标集合覆盖从 gridSize 到小于 w 的所有步长值
    - 验证水平线 y 坐标集合覆盖从 gridSize 到小于 h 的所有步长值
    - **验证: 需求 1.1, 1.3**

- [x] 3. 实现 Coordinate_Display 坐标系显示
  - [x] 3.1 实现 `coords.draw(gridSize, font)` 函数
    - 沿窗口顶部在每个网格线位置绘制 X 轴坐标标签（整数像素值）
    - 沿窗口左侧在每个网格线位置绘制 Y 轴坐标标签（整数像素值）
    - 在原点 (0,0) 处绘制特殊标识（小圆点）
    - 使用半透明颜色绘制标签文字
    - _需求: 2.1, 2.2, 2.3, 2.4, 2.5_

  - [x] 3.2 编写属性测试：坐标轴标签与网格位置一致
    - **Property 2: 坐标轴标签与网格位置一致**
    - 随机生成窗口尺寸和网格间距
    - 验证 X 轴标签位置为 gridSize 的整数倍，标签数值等于像素坐标
    - 验证 Y 轴标签同理
    - **验证: 需求 2.1, 2.2, 2.3**

- [x] 4. 检查点 - 确保网格和坐标系正常渲染
  - 确保所有测试通过，如有疑问请询问用户。

- [x] 5. 实现 Info_Panel 信息面板
  - [x] 5.1 实现 `panel.collectInfo()` 信息采集函数
    - 采集 Lua 版本（`_VERSION`）
    - 采集 LuaJIT 版本和状态（通过 `type(jit) == "table"` 安全检测，不可用时显示 "N/A"）
    - 采集内存使用量（`collectgarbage("count")`），格式化为 KB，超过 1024 KB 时附加 MB 显示
    - 采集 CPU 核心数（`love.system.getProcessorCount()`）
    - 采集 FPS（`love.timer.getFPS()`）和帧时间（`love.timer.getAverageDelta()` 转毫秒）
    - 采集操作系统（`love.system.getOS()`）、LÖVE 版本（`love.getVersion()`）
    - 采集渲染器信息（`love.graphics.getRendererInfo()`）：name、version、vendor、device
    - 返回 `{label, value}` 对的数组
    - _需求: 3.1, 3.2, 4.1, 4.2, 4.3, 5.1, 5.2, 5.3, 5.4, 6.1, 6.2, 7.1, 7.2, 7.3, 7.4, 8.1, 8.2, 8.3, 8.4_

  - [x] 5.2 实现 `panel.draw(font)` 面板渲染函数
    - 计算面板宽度（基于最长文本行）和高度（基于行数）
    - 在右上角绘制半透明深色背景矩形（`love.graphics.rectangle`）
    - 面板 x 坐标 = windowWidth - panelWidth - margin
    - 逐行绘制 label: value 格式的信息文本
    - 使用等宽字体，确保文字与背景有足够对比度
    - _需求: 9.2, 9.3_

  - [x] 5.3 编写属性测试：内存格式化与单位转换
    - **Property 3: 内存格式化与单位转换**
    - 随机生成正浮点数 memKB∈[0.01, 100000]
    - 验证输出始终包含 "X.XX KB" 格式
    - 验证当 memKB > 1024 时输出包含 "Y.YY MB"
    - **验证: 需求 5.1, 5.3, 5.4**

  - [x] 5.4 编写属性测试：帧时间秒转毫秒格式化
    - **Property 4: 帧时间秒转毫秒格式化**
    - 随机生成非负浮点数 deltaSec∈[0, 1.0]
    - 验证输出为 "X.XX ms" 格式，X.XX = deltaSec × 1000 保留两位小数
    - **验证: 需求 7.2**

  - [x] 5.5 编写属性测试：信息面板右上角定位
    - **Property 6: 信息面板右上角定位**
    - 随机生成 windowWidth∈[100,4000]、panelWidth∈[50,500]、margin∈[0,50]
    - 验证面板 x 坐标 = windowWidth - panelWidth - margin
    - **验证: 需求 9.2**

- [x] 6. 检查点 - 确保信息面板数据采集和渲染正常
  - 确保所有测试通过，如有疑问请询问用户。

- [x] 7. 实现 F12 切换与整体集成
  - [x] 7.1 完善 `overlay.keypressed(key)` 中的 F12 切换逻辑
    - 确保按下 F12 时 `overlay.visible = not overlay.visible`
    - 确保 `love.draw()` 中根据 visible 状态正确跳过或执行渲染
    - _需求: 9.1, 9.5_

  - [x] 7.2 整合所有组件的渲染顺序
    - 在 `overlay.draw()` 中按层级调用：grid.draw → coords.draw → panel.draw
    - 确保网格在最底层，面板在最顶层
    - 每次绘制后重置颜色（`love.graphics.setColor(1, 1, 1, 1)`）
    - _需求: 1.4, 9.4_

  - [x] 7.3 编写属性测试：F12 切换可见性的往返性
    - **Property 5: F12 切换可见性的往返性**
    - 随机生成布尔值 visible
    - 验证一次切换后 visible 变为 not visible
    - 验证两次切换后恢复为原始值
    - **验证: 需求 9.1**

- [x] 8. 搭建属性测试框架与运行器
  - [x] 8.1 创建 `test/test_properties.lua`，实现简易属性测试运行器
    - 实现 `checkProperty(name, numTests, generator, property)` 函数
    - 每个属性至少运行 100 次随机迭代
    - 失败时输出属性名、测试编号、错误信息和输入值
    - 将所有 Property 1-6 的测试用例集成到该文件中
    - 提取 `test/main.lua` 中的纯计算函数供测试调用
    - _需求: 全部（通过属性验证覆盖）_

- [x] 9. 最终检查点 - 确保所有功能和测试完整
  - 确保所有测试通过，如有疑问请询问用户。

## 备注

- 带 `*` 标记的任务为可选任务，可跳过以加速 MVP 开发
- 每个任务引用了具体的需求编号，确保可追溯性
- 检查点任务用于阶段性验证，确保增量开发的正确性
- 属性测试验证通用正确性属性，单元测试验证具体示例和边界情况
- 所有代码实现在 `test/main.lua` 中，属性测试在 `test/test_properties.lua` 中
