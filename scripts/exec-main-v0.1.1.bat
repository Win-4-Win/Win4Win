@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0exec-main-v0.1.1.ps1" %*
exit /b %errorlevel%
