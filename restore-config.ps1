# Restore config.json from template
# Run this script if config.json is accidentally deleted after merge

$configPath = "assets/config.json"
$templatePath = "config.template.json"

if (Test-Path $configPath) {
    Write-Host "✓ config.json already exists" -ForegroundColor Green
} else {
    if (Test-Path $templatePath) {
        Copy-Item $templatePath $configPath
        Write-Host "✓ Created config.json from template" -ForegroundColor Yellow
        Write-Host "⚠ Please edit assets/config.json with your credentials" -ForegroundColor Yellow
    } else {
        Write-Host "✗ Template not found: $templatePath" -ForegroundColor Red
    }
}

