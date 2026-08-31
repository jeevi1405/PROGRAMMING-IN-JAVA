# Push to GitHub Script
$repoUrl = "https://github.com/jeevi1405/Smart-Campus-Parking-JAVA.git"

$gitExe = "git"
$paths = @(
    "C:\Program Files\Git\cmd\git.exe",
    "C:\Program Files\Git\bin\git.exe",
    "$env:LOCALAPPDATA\Programs\Git\cmd\git.exe"
)

foreach ($p in $paths) {
    if (Test-Path $p) {
        $gitExe = $p
        break
    }
}

Write-Host "Using Git: $gitExe" -ForegroundColor Cyan

& $gitExe init
& $gitExe config user.name "jeevi1405"
& $gitExe config user.email "jeevi1405@users.noreply.github.com"
& $gitExe add -A
& $gitExe commit -m "Complete Smart Campus Parking & Traffic Management System (CSA09 Java & JDBC)"
& $gitExe branch -M main
& $gitExe remote remove origin 2>$null
& $gitExe remote add origin $repoUrl

Write-Host "Pushing to GitHub repository $repoUrl ..." -ForegroundColor Green
& $gitExe push -u origin main
