# Optional: remove broken Flutter copy on C: to free space (~1+ GB)
$old = "C:\Users\utrav\Downloads\priyautrav\tools"
if (Test-Path $old) {
  Write-Host "Removing $old ..."
  Remove-Item $old -Recurse -Force -ErrorAction SilentlyContinue
  Write-Host "Use D:\priyautrav only from now on."
}
