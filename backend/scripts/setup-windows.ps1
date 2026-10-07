# Creates Shifter DB user/database, runs migrations, starts API.
# Usage: .\scripts\setup-windows.ps1 -PostgresPassword "your_postgres_password"

param(
  [Parameter(Mandatory = $true)]
  [string]$PostgresPassword
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
$psql = @(
  "C:\Program Files\PostgreSQL\18\bin\psql.exe",
  "C:\Program Files\PostgreSQL\15\bin\psql.exe"
) | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $psql) {
  Write-Error "psql.exe not found. Install PostgreSQL or add it to PATH."
}

$env:PGPASSWORD = $PostgresPassword
$sql = Join-Path $PSScriptRoot "setup.sql"
& $psql -U postgres -h localhost -f $sql

Set-Location $root
npm install
npm run db:migrate
Write-Host "Backend ready. Run: npm run dev"
