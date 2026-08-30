@echo off
cd /d "%~dp0"
echo Launching Neon Stack with console output...
echo Project: %~dp0.
"C:\Users\9am6s\tools\godot\Godot_v4.7.2-stable_win64_console.exe" --path "%~dp0."
echo.
echo Exit code: %ERRORLEVEL%
pause
