@echo off
chcp 65001 >nul
REM ============================================================
REM  通用 LÖVE2D Android APK 打包器
REM  用法: build_apk.bat [项目目录]
REM  默认: test
REM
REM  原理:
REM    1. 将项目目录 + modules/ 合并打包为 game.love (zip)
REM    2. 将 game.love 追加到 love-android.apk 末尾
REM    3. 输出可安装的 APK
REM
REM  要求:
REM    - asserts\love-11.5-android.apk 已存在
REM    - 系统有 PowerShell 5.0+（Windows 10 自带）
REM ============================================================

setlocal enabledelayedexpansion

set "PROJECT_DIR=%~1"
if "%PROJECT_DIR%"=="" set "PROJECT_DIR=test"

set "SCRIPT_DIR=%~dp0"
set "MODULES_DIR=%SCRIPT_DIR%modules"
set "BASE_APK=%SCRIPT_DIR%asserts\love-11.5-android.apk"
set "BUILD_DIR=%SCRIPT_DIR%build"
set "STAGE_DIR=%BUILD_DIR%\stage"
set "LOVE_FILE=%BUILD_DIR%\game.love"
set "OUTPUT_APK=%BUILD_DIR%\%PROJECT_DIR%-debug.apk"

echo ============================================================
echo  LOVE2D Android APK Builder
echo ============================================================
echo  Project  : %PROJECT_DIR%
echo  Modules  : %MODULES_DIR%
echo  Base APK : %BASE_APK%
echo  Output   : %OUTPUT_APK%
echo ============================================================
echo.

REM --- 检查基础 APK ---
if not exist "%BASE_APK%" (
    echo [ERROR] Base APK not found: %BASE_APK%
    echo         Please download love-11.5-android.apk to asserts\
    goto :fail
)

REM --- 检查项目目录 ---
if not exist "%SCRIPT_DIR%%PROJECT_DIR%\main.lua" (
    echo [ERROR] main.lua not found in %PROJECT_DIR%\
    goto :fail
)

REM --- 清理并创建构建目录 ---
echo [1/5] Preparing build directory...
if exist "%BUILD_DIR%" rmdir /s /q "%BUILD_DIR%"
mkdir "%BUILD_DIR%"
mkdir "%STAGE_DIR%"

REM --- 复制项目文件到暂存区 ---
echo [2/5] Copying project files...
xcopy "%SCRIPT_DIR%%PROJECT_DIR%\*" "%STAGE_DIR%\" /s /e /q /y >nul

REM --- 复制 modules 到暂存区 ---
if exist "%MODULES_DIR%" (
    echo [3/5] Copying modules...
    mkdir "%STAGE_DIR%\modules" 2>nul
    xcopy "%MODULES_DIR%\*" "%STAGE_DIR%\modules\" /s /e /q /y >nul
) else (
    echo [3/5] No modules directory found, skipping...
)

REM --- 修补 conf.lua：注入 Android 兼容的模块路径 ---
echo [4/5] Patching conf.lua for Android...
powershell -NoProfile -Command ^
    "$confPath = '%STAGE_DIR%\conf.lua';" ^
    "if (Test-Path $confPath) {" ^
    "  $content = Get-Content $confPath -Raw -Encoding UTF8;" ^
    "  $patch = @'" ^
    "" ^
    "-- [Android patch] modules in .love archive" ^
    "if not os.getenv('LOVE_MODULES_PATH') then" ^
    "    package.path = 'modules/?.lua;modules/?/init.lua;' .. package.path" ^
    "end" ^
    "'@;" ^
    "  $marker = '-- 注入 modules 目录到 package.path';" ^
    "  if ($content -match [regex]::Escape($marker)) {" ^
    "    $content = $content -replace [regex]::Escape($marker), ($patch + \"`n\" + $marker);" ^
    "  } else {" ^
    "    $content = $patch + \"`n`n\" + $content;" ^
    "  }" ^
    "  [System.IO.File]::WriteAllText($confPath, $content, [System.Text.Encoding]::UTF8);" ^
    "  Write-Host '  conf.lua patched.';" ^
    "} else {" ^
    "  $fallback = 'package.path = \"\"modules/?.lua;modules/?/init.lua;\"\" .. package.path';" ^
    "  [System.IO.File]::WriteAllText($confPath, $fallback, [System.Text.Encoding]::UTF8);" ^
    "  Write-Host '  conf.lua created with module path.';" ^
    "}"

REM --- 打包 game.love (zip) ---
echo [5/5] Building game.love and APK...
powershell -NoProfile -Command ^
    "Add-Type -AssemblyName System.IO.Compression.FileSystem;" ^
    "[System.IO.Compression.ZipFile]::CreateFromDirectory('%STAGE_DIR%', '%LOVE_FILE%');" ^
    "Write-Host '  game.love created.';"

if not exist "%LOVE_FILE%" (
    echo [ERROR] Failed to create game.love
    goto :fail
)

REM --- 合并: base APK + game.love = output APK ---
copy /b "%BASE_APK%" + "%LOVE_FILE%" "%OUTPUT_APK%" >nul

if exist "%OUTPUT_APK%" (
    echo.
    echo ============================================================
    echo  BUILD SUCCESS!
    echo  Output: %OUTPUT_APK%
    echo ============================================================
    echo.
    echo  Install to device:
    echo    adb install -r "%OUTPUT_APK%"
    echo.
) else (
    echo [ERROR] Failed to create APK
    goto :fail
)

goto :end

:fail
echo.
echo BUILD FAILED!
echo.

:end
endlocal
pause
