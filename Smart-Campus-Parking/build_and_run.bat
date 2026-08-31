@echo off
TITLE Smart Campus Parking and Traffic Management System (CSA09)
echo ===============================================================================
echo   Smart Campus Parking and Traffic Management System
echo   Course: CSA09 - Programming in Java (CO4: GUI/Swing, CO5: JDBC/SQL)
echo   SDG Mapping: SDG 9 (Infrastructure), SDG 11 (Cities), SDG 13 (Climate Action)
echo ===============================================================================
echo.

set "JDK_BIN=C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"

if not exist "%JDK_BIN%\javac.exe" (
    echo [WARNING] Default JDK path not found, searching system PATH...
    where javac >nul 2>nul
    if %ERRORLEVEL% NEQ 0 (
        echo [ERROR] No Java JDK compiler found in system PATH.
        pause
        exit /b 1
    )
    set "JAVAC_CMD=javac"
    set "JAVA_CMD=java"
) else (
    set "JAVAC_CMD=%JDK_BIN%\javac.exe"
    set "JAVA_CMD=%JDK_BIN%\java.exe"
)

if not exist "bin" mkdir bin

echo [1/2] Compiling Java source files...
powershell -ExecutionPolicy Bypass -File compile.ps1
if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed!
    pause
    exit /b %ERRORLEVEL%
)

echo.
echo [2/2] Launching Application GUI...
echo Classpath: bin;lib/mysql-connector-j-9.3.0.jar
"%JAVA_CMD%" -cp "bin;lib/mysql-connector-j-9.3.0.jar" com.campus.parking.Main

pause
