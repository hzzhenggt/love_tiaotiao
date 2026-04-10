# 版本变更记录

| 状态 | 类型 | 编号 | 描述 | 优先级 | 日期 |
|------|------|------|------|--------|------|
| ✅ | feature | F001 | 设备信息面板抽取为独立 edevice 模块，浮动按钮交互 | 高 | 2026-04-10 |
| ✅ | feature | F002 | 通用模块化测试启动器 start_test.bat + conf.lua 路径注入 | 高 | 2026-04-10 |
| ✅ | feature | F003 | edevice 浮动按钮支持按住拖动 | 中 | 2026-04-10 |

## 详细记录

### F001 - edevice 独立模块
- 从 `test/main.lua` 的 panel 逻辑中抽取设备信息采集和面板绘制
- 创建 `edevice/init.lua` 独立模块，可通过 `require("edevice")` 在任意 LÖVE2D 项目中复用
- 实现右下角浮动按钮（蓝色半透明圆形），点击展开/收起设备信息面板
- 面板半透明深色背景，圆角矩形，从按钮上方弹出
- 支持鼠标和触摸事件
- `test/main.lua` 已重构为使用 edevice 模块

### F002 - 通用模块化测试启动器
- `start_test.bat` 通用化，通过环境变量 `LOVE_MODULES_PATH` 传递 modules 路径
- `test/conf.lua` 在 LÖVE 启动前自动将 modules/ 注入 `package.path`
- 支持 `start_test.bat [目录]` 参数，默认测试 test 目录
- 将来新增模块只需放入 modules/ 即可被任意测试项目 require

### F003 - edevice 浮动按钮拖动
- 按住按钮拖动可自由移动位置，松开后定位
- 短按（移动 < 4px）切换展开/收起，长按拖动不触发切换
- 拖动时按钮高亮，位置自动限制在屏幕内
- 面板跟随按钮位置，上方放不下时自动切换到下方
- 同时支持鼠标和触摸
