@echo off
title Dr. Mohammad Faisal Noor - Teacher's Day Tribute Site
echo =========================================================================
echo   Launching Teacher's Day Tribute Portal for Dr. Mohammad Faisal Noor
echo   LM Thapar School of Management (LMTSM)
echo =========================================================================
echo.
echo Starting local video streaming server on Port 3002...
start http://localhost:3002/
powershell -ExecutionPolicy Bypass -File "%~dp0tribute-server.ps1" -Port 3002
pause
