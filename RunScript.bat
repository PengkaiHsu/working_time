@echo off
powershell.exe -NoProfile -ExecutionPolicy Bypass -File ".\CalculateWorkingTime.ps1" %1
pause >nul