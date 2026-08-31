# PowerShell Run script for Smart Campus Parking System
$jdkPath = "C:\Users\JEEVAN KUMAR\AppData\Local\Programs\Eclipse Adoptium\jdk-25.0.4.7-hotspot\bin"
if (-not (Test-Path "$jdkPath\java.exe")) {
    $java = Get-Command java -ErrorAction SilentlyContinue
    if ($java) {
        $jdkPath = Split-Path $java.Source
    }
}

Write-Host "===============================================================================" -ForegroundColor Cyan
Write-Host "  Launching Smart Campus Parking & Traffic Management System (CSA09)           " -ForegroundColor Green
Write-Host "===============================================================================" -ForegroundColor Cyan

& "$jdkPath\java.exe" -cp "bin;lib/mysql-connector-j-9.3.0.jar" com.campus.parking.Main
