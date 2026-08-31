# SIMATS Engineering - Skill Progress Analytics Web Application Runner
$jdkBin = "C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"
$javac = if (Test-Path "$jdkBin\javac.exe") { "$jdkBin\javac.exe" } else { "javac" }
$java = if (Test-Path "$jdkBin\java.exe") { "$jdkBin\java.exe" } else { "java" }

if (-not (Test-Path "bin")) {
    New-Item -ItemType Directory -Path "bin" | Out-Null
}

Write-Host "Compiling Java sources..." -ForegroundColor Cyan
& $javac -d bin -sourcepath src src/com/simats/analytics/model/*.java src/com/simats/analytics/dao/*.java src/com/simats/analytics/service/*.java src/com/simats/analytics/server/*.java src/com/simats/analytics/test/*.java

if ($LASTEXITCODE -ne 0) {
    Write-Host "Compilation failed!" -ForegroundColor Red
    exit $LASTEXITCODE
}

Write-Host "Compilation successful!" -ForegroundColor Green
Write-Host "Running Test Suite..." -ForegroundColor Yellow
& $java -cp bin com.simats.analytics.test.AppTestSuite

Write-Host "Starting Java Web Application Server on http://localhost:8080..." -ForegroundColor Green
& $java -cp bin com.simats.analytics.server.AppServer 8080
