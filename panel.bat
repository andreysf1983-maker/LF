@echo off
REM ==========================================================================
REM  LEGIONFORGE :: PANEL.bat - запуск веб-панели администратора и конфигуратора
REM  Читает триггер legionforge.bin, готовит портативный Node.js, собирает
REM  /web_panel и открывает браузер. Консоль остаётся открытой со статусом.
REM ==========================================================================
setlocal ENABLEEXTENSIONS
chcp 65001 >nul
title LEGIONFORGE :: Web Panel
color 0A

set "LF_ROOT=%~dp0"
if "%LF_ROOT:~-1%"=="\" set "LF_ROOT=%LF_ROOT:~0,-1%"
set "LF_PANEL=%LF_ROOT%\web_panel"
set "LF_PORT=3000"

echo.
echo   ====================================================================
echo    LEGIONFORGE :: ВЕБ-ПАНЕЛЬ АДМИНИСТРАТОРА И КОНФИГУРАТОР СБОРКИ
echo   ====================================================================
echo.

if not exist "%LF_ROOT%\legionforge.bin" (
    echo [ОШИБКА] Не найден триггер legionforge.bin - панель не может стартовать.
    pause & exit /b 1
)
echo [1/5] Триггер legionforge.bin найден и проверен.
for /f "usebackq tokens=1,* delims==" %%A in ("%LF_ROOT%\legionforge.bin") do (
    if /i "%%A"=="PANEL_PORT" set "LF_PORT=%%B"
    if /i "%%A"=="PANEL_MODE" set "LF_MODE=%%B"
)
echo       Режим панели : %LF_MODE%
echo       Порт панели   : %LF_PORT%

echo [2/5] Проверяю портативный Node.js ...
if not exist "%LF_ROOT%\tools\nodejs\node.exe" (
    echo       Скачиваю Portable Node.js 20 LTS ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%LF_ROOT%\tools\download_tools.ps1" -Only nodejs
)
set "PATH=%LF_ROOT%\tools\nodejs;%PATH%"

echo [3/5] Синхронизирую исходники панели и устанавливаю зависимости ...
call "%LF_ROOT%\tools\sync_panel_root.bat"

pushd "%LF_PANEL%"
if not exist "node_modules" (
    call "%LF_ROOT%\tools\nodejs\npm.cmd" install --no-audit --no-fund
) else (
    echo       node_modules уже установлены - пропускаю.
)

echo [4/5] Собираю панель (production build) ...
call "%LF_ROOT%\tools\nodejs\npm.cmd" run build

echo [5/5] Запускаю локальный сервер панели ...
echo.
echo   ====================================================================
echo    ПАНЕЛЬ РАБОТАЕТ:  http://127.0.0.1:%LF_PORT%
echo    Не закрывайте это окно - оно держит процесс панели.
echo    Остановить панель: нажмите Ctrl+C или закройте окно.
echo   ====================================================================
echo.
start "" "http://127.0.0.1:%LF_PORT%"
call "%LF_ROOT%\tools\nodejs\npm.cmd" run start
popd
endlocal
