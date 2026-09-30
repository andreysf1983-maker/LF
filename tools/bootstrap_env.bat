@echo off
REM ==========================================================================
REM  LEGIONFORGE :: tools/bootstrap_env.bat
REM  Проверяет наличие всех портативных утилит в /tools и докачивает недостающее.
REM  Возвращает errorlevel 0 при успехе.
REM ==========================================================================
setlocal
set "LF_ROOT=%~dp0.."
for %%I in ("%LF_ROOT%") do set "LF_ROOT=%%~fI"
set "LF_TOOLS=%LF_ROOT%\tools"
set "LF_LOGS=%LF_ROOT%\server\logs"
if not exist "%LF_LOGS%" mkdir "%LF_LOGS%"

echo        - проверяю Portable Git / CMake+Ninja / .NET 8 / Node.js /
echo          MySQL / OpenSSL / Boost / 7-Zip ...

set "LF_MISSING="
if not exist "%LF_TOOLS%\git\cmd\git.exe"          set "LF_MISSING=%LF_MISSING% git"
if not exist "%LF_TOOLS%\cmake\bin\cmake.exe"      set "LF_MISSING=%LF_MISSING% cmake"
if not exist "%LF_TOOLS%\cmake\bin\ninja.exe"      set "LF_MISSING=%LF_MISSING% ninja"
if not exist "%LF_TOOLS%\dotnet\dotnet.exe"        set "LF_MISSING=%LF_MISSING% dotnet"
if not exist "%LF_TOOLS%\nodejs\node.exe"          set "LF_MISSING=%LF_MISSING% nodejs"
if not exist "%LF_TOOLS%\mysql\bin\mysqld.exe"     set "LF_MISSING=%LF_MISSING% mysql"
if not exist "%LF_TOOLS%\openssl\bin\openssl.exe"  set "LF_MISSING=%LF_MISSING% openssl"
if not exist "%LF_TOOLS%\boost\stage\lib"          set "LF_MISSING=%LF_MISSING% boost"
if not exist "%LF_TOOLS%\7zip\7za.exe"             set "LF_MISSING=%LF_MISSING% 7zip"

if defined LF_MISSING (
    echo        Не найдено:%LF_MISSING%
    echo        Запускаю автоматическую загрузку портативных утилит ...
    powershell -NoProfile -ExecutionPolicy Bypass -File "%LF_TOOLS%\download_tools.ps1" -Only "%LF_MISSING%" >> "%LF_LOGS%\bootstrap.log" 2>&1
)

REM --- Компилятор MSVC (Visual Studio Build Tools) --------------------------
set "LF_VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if exist "%LF_VSWHERE%" (
    for /f "usebackq tokens=*" %%i in (`"%LF_VSWHERE%" -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath`) do set "LF_VS=%%i"
)
if defined LF_VS (
    echo        MSVC найден: %LF_VS%
) else (
    echo [!] MSVC не найден. Установите "Visual Studio 2022 Build Tools" с компонентом
    echo     "Разработка классических приложений на C++" или позвольте загрузчику
    echo     сделать это автоматически ^(download_tools.ps1 -Only msvc^).
)
endlocal & exit /b 0
