@echo off
setlocal
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0instalar_todo.ps1" %*
exit /b %errorlevel%
