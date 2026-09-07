@echo off
setlocal enabledelayedexpansion
title Push to GitHub: gdhiman117/Happy-Teachers-Day-Dr-Noor
cd /d "%~dp0"
set PATH=C:\Users\gdhim\AppData\Local\Programs\Git\cmd;%PATH%

echo =========================================================================
echo   Push Dr. Mohammad Faisal Noor Tribute Website to GitHub
echo   Repository: https://github.com/gdhiman117/Happy-Teachers-Day-Dr-Noor
echo =========================================================================
echo.
echo Choose your authentication method:
echo.
echo   [1] Enter GitHub Personal Access Token (PAT) [Recommended if token not linked]
echo   [2] Browser Sign-In (Git Credential Manager)
echo.
set /p auth_choice="Select (1 or 2, default is 1): "

if "%auth_choice%"=="2" (
    echo.
    echo Using standard Git Credential Manager...
    git remote remove origin >nul 2>&1
    git remote add origin https://github.com/gdhiman117/Happy-Teachers-Day-Dr-Noor.git
) else (
    echo.
    echo If you need a token, create one here in 10 seconds:
    echo https://github.com/settings/tokens/new?scopes=repo
    echo.
    set /p mytoken="Paste your GitHub Personal Access Token: "
    if "!mytoken!"=="" (
        echo No token entered. Exiting.
        pause
        exit /b 1
    )
    git remote remove origin >nul 2>&1
    git remote add origin https://!mytoken!@github.com/gdhiman117/Happy-Teachers-Day-Dr-Noor.git
)

echo.
echo Pushing website files and videos to GitHub (main branch)...
git branch -M main
git push -u origin main

if %ERRORLEVEL% equ 0 (
    echo.
    echo =========================================================================
    echo   SUCCESS! Website pushed to GitHub successfully!
    echo =========================================================================
    echo.
    echo Opening GitHub Pages Settings...
    start https://github.com/gdhiman117/Happy-Teachers-Day-Dr-Noor/settings/pages
    echo.
    echo Your site will be LIVE at:
    echo https://gdhiman117.github.io/Happy-Teachers-Day-Dr-Noor/
    echo =========================================================================
) else (
    echo.
    echo -------------------------------------------------------------------------
    echo Push failed. Please verify that your token has 'repo' permissions.
    echo -------------------------------------------------------------------------
)

echo.
pause
