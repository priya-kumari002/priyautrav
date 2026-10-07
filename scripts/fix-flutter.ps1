# Run in PowerShell: D:\priyautrav\scripts\fix-flutter.ps1
# Fixes "pub upgrade" / "path not found" when C: drive is full.

$ErrorActionPreference = "Stop"
. "$PSScriptRoot\env.ps1"

$root = "D:\priyautrav"
$local = Join-Path $root "localappdata"
New-Item -ItemType Directory -Force -Path $local | Out-Null
$env:LOCALAPPDATA = $local
$env:APPDATA = $local
$env:USERPROFILE = $root

Write-Host "C: free GB:" ([math]::Round((Get-PSDrive C).Free/1GB, 2))
Write-Host "Using TEMP=$env:TEMP PUB_CACHE=$env:PUB_CACHE"

# Remove broken git-clone SDK (flutter.bat without dart-sdk)
@(
  (Join-Path $root "tools\flutter"),
  "D:\Utrav_NextGen\tools\flutter"
) | ForEach-Object {
  if (Test-Path $_) {
    Write-Host "Removing broken SDK: $_"
    Remove-Item $_ -Recurse -Force -ErrorAction SilentlyContinue
  }
}

& "$PSScriptRoot\install-flutter.ps1"

$flutterBat = Join-Path $root "tools\flutter\bin\flutter.bat"
if (-not (Test-Path $flutterBat)) { throw "Flutter install failed." }

& $flutterBat --version
& $flutterBat doctor

Write-Host ""
Write-Host "OK. Every new terminal, run FIRST:"
Write-Host "  . D:\priyautrav\scripts\env.ps1"
Write-Host "Then:"
Write-Host "  cd D:\priyautrav\mobile"
Write-Host "  flutter pub get"
Write-Host "  flutter run"
