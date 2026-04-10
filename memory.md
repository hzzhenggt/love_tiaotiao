# 项目记忆

- edevice 模块路径：`edevice/init.lua`，独立的设备信息浮动面板，require("edevice") 即可使用
- test/main.lua 已重构，grid/coords 保留在 main.lua，设备信息面板由 edevice 模块提供
- test/test_properties.lua 中的纯函数测试（formatMemory、formatFrameTime、calcPanelX）仍可独立运行
