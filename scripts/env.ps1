# Dot-source in PowerShell: . D:\priyautrav\scripts\env.ps1
$root = "D:\priyautrav"
New-Item -ItemType Directory -Force -Path "$root\temp", "$root\.pub-cache" | Out-Null
# Keep Flutter/npm temp OFF full C: drive
$env:TEMP = "$root\temp"
$env:TMP = "$root\temp"
$env:PUB_CACHE = "$root\.pub-cache"
$env:FLUTTER_STORAGE_BASE_URL = "https://storage.googleapis.com"
$local = Join-Path $root "localappdata"
New-Item -ItemType Directory -Force -Path $local | Out-Null
$env:LOCALAPPDATA = $local
$env:APPDATA = $local

$flutter = Join-Path $root "tools\flutter\bin"
if (Test-Path $flutter) {
  $env:FLUTTER_ROOT = Join-Path $root "tools\flutter"
  $env:Path = "$flutter;C:\Program Files\Git\cmd;" + $env:Path
  git config --global --add safe.directory "D:/priyautrav/tools/flutter" 2>$null
}
Write-Host "Project root: $root"
Write-Host "Flutter: $(if (Test-Path $flutter) { 'D:\priyautrav\tools\flutter' } else { 'NOT FOUND - run install-flutter.ps1' })"
