$dest = Join-Path $PSScriptRoot "git"
$zipFile = Join-Path $PSScriptRoot "mingit.zip"

if (-not (Test-Path $dest)) {
    New-Item -ItemType Directory -Force -Path $dest | Out-Null
}

$url = "https://github.com/git-for-windows/git/releases/download/v2.44.0.windows.1/MinGit-2.44.0-64-bit.zip"
Write-Host "Downloading MinGit from $url ..." -ForegroundColor Cyan
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Invoke-WebRequest -Uri $url -OutFile $zipFile

Write-Host "Extracting MinGit to $dest ..." -ForegroundColor Green
Expand-Archive -Path $zipFile -DestinationPath $dest -Force
Remove-Item $zipFile -Force
Write-Host "MinGit setup complete!" -ForegroundColor Green
