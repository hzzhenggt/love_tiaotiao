-- ==========================================================================
-- conf.lua - LÖVE2D 配置 & 模块路径注入
-- 由 start_test.bat 设置 LOVE_MODULES_PATH 环境变量
-- 自动将 modules/ 下所有子目录加入 package.path
-- ==========================================================================

-- 注入 modules 目录到 package.path
local modulesPath = os.getenv("LOVE_MODULES_PATH")
if modulesPath then
    -- 规范化路径分隔符
    modulesPath = modulesPath:gsub("\\", "/")
    -- 去掉末尾斜杠
    if modulesPath:sub(-1) == "/" then
        modulesPath = modulesPath:sub(1, -2)
    end
    -- 添加两种搜索模式：
    --   modules/?.lua          -> require("edevice") 找 modules/edevice.lua
    --   modules/?/init.lua     -> require("edevice") 找 modules/edevice/init.lua
    package.path = modulesPath .. "/?.lua;"
              .. modulesPath .. "/?/init.lua;"
              .. package.path
end

function love.conf(t)
    t.title = "LÖVE2D Module Test"
    t.version = "11.5"
    t.console = true  -- 开启控制台方便调试
end
