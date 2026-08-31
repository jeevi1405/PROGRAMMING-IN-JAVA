# PowerShell build & compile script for Smart Campus Parking System
$ErrorActionPreference = "Stop"

$jdkPath = "C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"
if (-not (Test-Path "$jdkPath\javac.exe")) {
    $javac = Get-Command javac -ErrorAction SilentlyContinue
    if ($javac) {
        $jdkPath = Split-Path $javac.Source
    } else {
        Write-Error "javac.exe not found! Please verify JDK installation."
        exit 1
    }
}

Write-Host "Using JDK at: $jdkPath" -ForegroundColor Cyan

if (-not (Test-Path "bin")) {
    New-Item -ItemType Directory -Path "bin" | Out-Null
}

$javaFiles = Get-ChildItem -Path "src" -Recurse -Filter "*.java" | Select-Object -ExpandProperty FullName
Write-Host "Found $($javaFiles.Count) Java source files to compile..." -ForegroundColor Yellow

$classpath = "lib/mysql-connector-j-9.3.0.jar;src"

& "$jdkPath\javac.exe" -encoding UTF-8 -cp $classpath -d "bin" $javaFiles

if ($LASTEXITCODE -eq 0) {
    Write-Host "Compilation SUCCESSFUL! (Output directory: bin/)" -ForegroundColor Green
} else {
    Write-Host "Compilation FAILED with exit code $LASTEXITCODE" -ForegroundColor Red
}
