# Unlock build directory script
# Run with Administrator privileges

Write-Host "=== Zerova OQC Report Build Unlocker ===" -ForegroundColor Cyan
Write-Host ""

# Stop all potential processes
$processes = @("zerova_oqc_report", "cppwinrt", "nuget", "MSBuild", "devenv", "VBCSCompiler")
foreach ($proc in $processes) {
    $running = Get-Process -Name $proc -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host "Stopping $proc..." -ForegroundColor Yellow
        Stop-Process -Name $proc -Force -ErrorAction SilentlyContinue
    }
}

Write-Host "Waiting 5 seconds..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

# Try to remove build directory
Write-Host "Attempting to remove build directory..." -ForegroundColor Yellow
Remove-Item -Path "build" -Recurse -Force -ErrorAction SilentlyContinue

if (Test-Path "build") {
    Write-Host "❌ Build directory still locked." -ForegroundColor Red
    Write-Host ""
    Write-Host "Please try one of these solutions:" -ForegroundColor Yellow
    Write-Host "1. Close Cursor/VS Code completely" -ForegroundColor White
    Write-Host "2. Wait 2-3 minutes for Windows Defender to finish scanning" -ForegroundColor White
    Write-Host "3. Restart your computer" -ForegroundColor White
    Write-Host "4. Add build directory to Windows Defender exclusions (requires admin):" -ForegroundColor White
    Write-Host "   Run PowerShell as Administrator and execute:" -ForegroundColor Cyan
    Write-Host "   Add-MpPreference -ExclusionPath '$PWD\build'" -ForegroundColor Gray
} else {
    Write-Host "✓ Build directory removed successfully!" -ForegroundColor Green
    Write-Host "You can now run: flutter run -d windows" -ForegroundColor Cyan
}

