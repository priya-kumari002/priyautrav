# Downloads official Flutter ZIP to D: (~1.5 GB). Needs ~3 GB free on D:
. "$PSScriptRoot\env.ps1"
$ErrorActionPreference = "Stop"
$root = "D:\priyautrav"
$zip = Join-Path $root "temp\flutter_windows.zip"
$dest = Join-Path $root "tools"
$flutterDir = Join-Path $dest "flutter"

$dart = Join-Path $flutterDir "bin\cache\dart-sdk\bin\dart.exe"
if ((Test-Path (Join-Path $flutterDir "bin\flutter.bat")) -and (Test-Path $dart)) {
  Write-Host "Flutter already at $flutterDir"
  exit 0
}

Remove-Item $flutterDir -Recurse -Force -ErrorAction SilentlyContinue
New-Item -ItemType Directory -Force -Path (Split-Path $zip), $dest | Out-Null

$url = "https://storage.googleapis.com/flutter_infra_release/releases/stable/windows/flutter_windows_3.24.5-stable.zip"
Write-Host "Downloading Flutter to D:\priyautrav\temp ..."
curl.exe -L $url -o $zip
Write-Host "Extracting to D:\priyautrav\tools ..."
Expand-Archive -Path $zip -DestinationPath $dest -Force
Remove-Item $zip -Force
Write-Host "Done. Run: . D:\priyautrav\scripts\env.ps1 ; flutter doctor"
