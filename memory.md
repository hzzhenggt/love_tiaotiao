# 项目记忆

- 模块统一放在 `modules/` 目录下，通过 `start_test.bat` + `conf.lua` 自动注入 package.path
- edevice 模块路径：`modules/edevice/init.lua`，独立的设备信息浮动面板
- test/main.lua 已重构，grid/coords 保留在 main.lua，设备信息面板由 edevice 模块提供
- test/conf.lua 读取环境变量 LOVE_MODULES_PATH 注入搜索路径
- start_test.bat 支持参数指定测试目录，默认 test，通用可复用
- build_apk.bat 打包流程：项目+modules→game.love→追加到love-android.apk，产物在 build/
- Android 打包时 conf.lua 会被自动修补，注入 modules/ 相对路径（因为 Android 无环境变量）
- CLAUDE.MD 第六章为设计文档规范，新模块/大功能必须产出 docs/<名称>.md
- docs/edevice.md 为 edevice 模块的完整设计文档
