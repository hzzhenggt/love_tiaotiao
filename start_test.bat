@echo off
chcp 65001 >nul
REM ============================================================
REM  通用 LÖVE2D 模块化测试启动器
REM  用法: start_test.bat [测试项目目录]
REM  默认: test
REM  自动将 modules/ 目录注入 Lua package.path
REM ============================================================

setlocal

set "LOVE_EXE=%~dp0love-11.5-win64\love.exe"
set "MODULES_DIR=%~dp0modules"
set "TEST_DIR=%~1"

if "%TEST_DIR%"=="" set "TEST_DIR=test"

REM 设置环境变量，让 conf.lua 读取 modules 路径
set "LOVE_MODULES_PATH=%MODULES_DIR%"

echo [start_test] LOVE_EXE   = %LOVE_EXE%
echo [start_test] MODULES    = %MODULES_DIR%
echo [start_test] TEST_DIR   = %TEST_DIR%
echo.

"%LOVE_EXE%" "%TEST_DIR%"

endlocal
pause
