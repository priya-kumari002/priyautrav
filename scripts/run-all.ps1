param(
  [Parameter(Mandatory = $true)]
  [string]$PostgresPassword
)

$ErrorActionPreference = "Stop"
$repo = "D:\priyautrav"
$flutterBin = Join-Path $repo "tools\flutter\bin"
. (Join-Path $repo "scripts\env.ps1")

& (Join-Path $repo "backend\scripts\setup-windows.ps1") -PostgresPassword $PostgresPassword

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$repo\backend'; npm run dev"

if (Test-Path $flutterBin) {
  $env:Path = "$flutterBin;" + $env:Path
  Set-Location (Join-Path $repo "mobile")
  flutter pub get
  Write-Host "Run the app: flutter run -d windows   (or -d android / chrome)"
} else {
  Write-Host "Flutter SDK: install or use tools/flutter (see README)."
}
