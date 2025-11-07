# Windows Package Script for Zerova OQC Report
# This script builds the Windows release and packages it with all assets and config

$ErrorActionPreference = "Stop"

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Zerova OQC Report - Windows Package" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host ""

# Get version from pubspec.yaml
$pubspecContent = Get-Content "pubspec.yaml" -Raw
if ($pubspecContent -match 'version:\s*([\d.]+)\+(\d+)') {
    $version = $matches[1]
    $buildNumber = $matches[2]
    $fullVersion = "$version+$buildNumber"
    Write-Host "Version: $fullVersion" -ForegroundColor Green
} else {
    $fullVersion = "2.2.0+1"
    Write-Host "Using default version: $fullVersion" -ForegroundColor Yellow
}

# Check if build exists
$releaseDir = "build\windows\x64\runner\Release"
$exePath = "$releaseDir\zerova_oqc_report.exe"

if (-not (Test-Path $exePath)) {
    Write-Host "`nBuild not found. Building Windows release..." -ForegroundColor Yellow
    flutter build windows --release
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Build failed!" -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "`nUsing existing build..." -ForegroundColor Green
    $buildTime = (Get-Item $exePath).LastWriteTime
    Write-Host "  Build time: $buildTime" -ForegroundColor Gray
}

# Define paths (already defined above, but ensure it's set)
if (-not $releaseDir) {
    $releaseDir = "build\windows\x64\runner\Release"
}
$packageDir = "dist\Zerova_OQC_Report_$version"
$zipFile = "dist\Zerova_OQC_Report_v${version}_Windows.zip"

# Create package directory
Write-Host "`nCreating package directory..." -ForegroundColor Yellow
if (Test-Path $packageDir) {
    Remove-Item -Path $packageDir -Recurse -Force
}
New-Item -ItemType Directory -Path $packageDir -Force | Out-Null

# Copy all files from Release directory
Write-Host "Copying application files..." -ForegroundColor Yellow
Copy-Item -Path "$releaseDir\*" -Destination $packageDir -Recurse -Force

# Copy config.json to root (as backup)
Write-Host "Copying config.json to package root..." -ForegroundColor Yellow
if (Test-Path "config.json") {
    Copy-Item -Path "config.json" -Destination "$packageDir\config.json" -Force
    Write-Host "  ✓ config.json copied" -ForegroundColor Green
} else {
    Write-Host "  ⚠ config.json not found in root, using assets version only" -ForegroundColor Yellow
}

# Verify assets
Write-Host "`nVerifying assets..." -ForegroundColor Yellow
$requiredAssets = @(
    "$packageDir\data\flutter_assets\assets\config.json",
    "$packageDir\data\flutter_assets\assets\logo.png",
    "$packageDir\data\flutter_assets\assets\translations\zh-TW.json",
    "$packageDir\data\flutter_assets\assets\translations\en-US.json",
    "$packageDir\data\flutter_assets\assets\translations\ja-JP.json",
    "$packageDir\data\flutter_assets\assets\translations\vi-VN.json"
)

$allAssetsOk = $true
foreach ($asset in $requiredAssets) {
    if (Test-Path $asset) {
        Write-Host "  ✓ $(Split-Path $asset -Leaf)" -ForegroundColor Green
    } else {
        Write-Host "  ✗ Missing: $asset" -ForegroundColor Red
        $allAssetsOk = $false
    }
}

if (-not $allAssetsOk) {
    Write-Host "`nWarning: Some assets are missing!" -ForegroundColor Red
}

# Create ZIP package
Write-Host "`nCreating ZIP package..." -ForegroundColor Yellow
if (Test-Path $zipFile) {
    Remove-Item -Path $zipFile -Force
}

# Create dist directory if not exists
$distDir = "dist"
if (-not (Test-Path $distDir)) {
    New-Item -ItemType Directory -Path $distDir -Force | Out-Null
}

# Compress package directory
Compress-Archive -Path $packageDir -DestinationPath $zipFile -Force

# Get package size
$zipSize = (Get-Item $zipFile).Length / 1MB
Write-Host "  ✓ Package created: $zipFile" -ForegroundColor Green
Write-Host "  ✓ Package size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Green

# Create README for package
$readmeContent = @"
# Zerova OQC Report System v$version

## Installation Instructions

1. Extract all files from this package to a folder (e.g., C:\Program Files\Zerova_OQC_Report)
2. Run `zerova_oqc_report.exe` to start the application

## Contents

- zerova_oqc_report.exe - Main application executable
- data\ - Application data and assets (including config.json)
- *.dll - Required library files
- config.json - Configuration file (backup copy)

## Configuration

The application uses `assets/config.json` from the data folder. If needed, you can also place a `config.json` file in the same directory as the executable.

## System Requirements

- Windows 10 or later
- Microsoft Visual C++ Redistributable (usually installed automatically)

## Version

$fullVersion

Build Date: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@

$readmePath = "$packageDir\README.txt"
$readmeContent | Out-File -FilePath $readmePath -Encoding UTF8

Write-Host "`n=========================================" -ForegroundColor Cyan
Write-Host "Package Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Package location: $zipFile" -ForegroundColor Green
Write-Host "Extracted location: $packageDir" -ForegroundColor Green
Write-Host "`nYou can distribute the ZIP file or the extracted folder." -ForegroundColor Yellow
Write-Host ""

