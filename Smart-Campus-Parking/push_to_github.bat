@echo off
TITLE Upload to GitHub - Smart Campus Parking
echo ===============================================================================
echo   Pushing Smart Campus Parking & Traffic Management System to GitHub
echo   Repository: https://github.com/jeevi1405/Smart-Campus-Parking-JAVA.git
echo ===============================================================================
echo.

set "REPO_URL=https://github.com/jeevi1405/Smart-Campus-Parking-JAVA.git"

:: Find Git in portable tools or standard paths
set "GIT_CMD=tools\git\cmd\git.exe"
if not exist "%GIT_CMD%" (
    if exist "C:\Program Files\Git\cmd\git.exe" (
        set "GIT_CMD=C:\Program Files\Git\cmd\git.exe"
    ) else (
        set "GIT_CMD=git"
    )
)

echo Using Git: "%GIT_CMD%"

"%GIT_CMD%" init
"%GIT_CMD%" config user.name "jeevi1405"
"%GIT_CMD%" config user.email "jeevi1405@users.noreply.github.com"

echo Adding files...
"%GIT_CMD%" add -A

echo Committing files...
"%GIT_CMD%" commit -m "Complete Smart Campus Parking & Traffic Management System (CSA09 Java AWT/Swing and JDBC)"

"%GIT_CMD%" branch -M main

"%GIT_CMD%" remote remove origin 2>nul
"%GIT_CMD%" remote add origin %REPO_URL%

echo.
echo Pushing to GitHub repository...
"%GIT_CMD%" push -u origin main

if %ERRORLEVEL% NEQ 0 (
    echo.
    echo [NOTICE] If prompted, please complete GitHub sign-in in the popup browser window.
)

echo.
echo ===============================================================================
echo   Done! Check your repository: %REPO_URL%
echo ===============================================================================
pause
