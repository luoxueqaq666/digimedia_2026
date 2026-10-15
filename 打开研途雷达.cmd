@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0start-background.ps1"
if errorlevel 1 (
  echo Startup failed. Please check the logs folder.
  pause
  exit /b 1
)
start "" "http://127.0.0.1:4321/"
