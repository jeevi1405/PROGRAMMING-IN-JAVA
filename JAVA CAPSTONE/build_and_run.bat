@echo off
echo =====================================================================
echo  SIMATS Engineering - Skill Progress Analytics Web Application
echo  Course: Java Programming (CSA0925)
echo  Compiling Java Source Files with OpenJDK...
echo =====================================================================

set "JDK_BIN=C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"

if exist "%JDK_BIN%\javac.exe" (
    set "JAVAC=%JDK_BIN%\javac.exe"
    set "JAVA=%JDK_BIN%\java.exe"
) else (
    set "JAVAC=javac"
    set "JAVA=java"
)

if not exist bin mkdir bin

echo Compiling Java source files...
"%JAVAC%" -d bin -sourcepath src src/com/simats/analytics/model/*.java src/com/simats/analytics/dao/*.java src/com/simats/analytics/service/*.java src/com/simats/analytics/server/*.java src/com/simats/analytics/test/*.java

if %ERRORLEVEL% NEQ 0 (
    echo [ERROR] Compilation failed.
    pause
    exit /b %ERRORLEVEL%
)

echo [SUCCESS] Compilation completed successfully.
echo.
echo Running Automated Test Suite (Slide 12)...
"%JAVA%" -cp bin com.simats.analytics.test.AppTestSuite
echo.
echo =====================================================================
echo Starting Java Web Application Server on http://localhost:8080
echo =====================================================================
"%JAVA%" -cp bin com.simats.analytics.server.AppServer 8080
