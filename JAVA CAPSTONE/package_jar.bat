@echo off
set "JDK_BIN=C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"

if exist "%JDK_BIN%\jar.exe" (
    set "JAVAC=%JDK_BIN%\javac.exe"
    set "JAR=%JDK_BIN%\jar.exe"
) else (
    set "JAVAC=javac"
    set "JAR=jar"
)

if not exist bin mkdir bin

echo Compiling Java source files...
"%JAVAC%" -d bin -sourcepath src src/com/simats/analytics/model/*.java src/com/simats/analytics/dao/*.java src/com/simats/analytics/service/*.java src/com/simats/analytics/server/*.java src/com/simats/analytics/test/*.java

echo Main-Class: com.simats.analytics.server.AppServer> manifest.txt

echo Packaging into executable skill-analytics.jar...
"%JAR%" cfm skill-analytics.jar manifest.txt -C bin .

if exist skill-analytics.jar (
    echo.
    echo ==========================================================
    echo [SUCCESS] skill-analytics.jar created successfully!
    echo Run it with: java -jar skill-analytics.jar
    echo ==========================================================
) else (
    echo [ERROR] JAR creation failed.
)
pause
