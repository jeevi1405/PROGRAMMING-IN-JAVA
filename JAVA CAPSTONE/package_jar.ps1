# Package standalone executable JAR
$jdkBin = "C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"
$javac = if (Test-Path "$jdkBin\javac.exe") { "$jdkBin\javac.exe" } else { "javac" }
$jar = if (Test-Path "$jdkBin\jar.exe") { "$jdkBin\jar.exe" } else { "jar" }

Write-Host "Compiling source files..." -ForegroundColor Cyan
if (-not (Test-Path "bin")) { New-Item -ItemType Directory -Path "bin" | Out-Null }
& $javac -d bin -sourcepath src src/com/simats/analytics/model/*.java src/com/simats/analytics/dao/*.java src/com/simats/analytics/service/*.java src/com/simats/analytics/server/*.java src/com/simats/analytics/test/*.java

Write-Host "Creating Manifest file..." -ForegroundColor Cyan
Set-Content -Path "manifest.txt" -Value "Main-Class: com.simats.analytics.server.AppServer`n"

Write-Host "Packaging skill-analytics.jar..." -ForegroundColor Yellow
& $jar cfm skill-analytics.jar manifest.txt -C bin .

if (Test-Path "skill-analytics.jar") {
    Write-Host "SUCCESS: skill-analytics.jar generated successfully!" -ForegroundColor Green
    Write-Host "You can now run it anywhere with: java -jar skill-analytics.jar" -ForegroundColor White
} else {
    Write-Host "Packaging failed." -ForegroundColor Red
}
