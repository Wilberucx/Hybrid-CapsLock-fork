# ===============================
# HybridCapsLock Portable Release Creator
# ===============================
# Crea un paquete portable de HybridCapsLock
# con todas las dependencias incluidas

[CmdletBinding()]
param(
    [string]$Version = "2.0.0",
    [string]$OutputDir = ".\releases",
    [switch]$IncludeKanata,
    [switch]$SkipAutoHotkey
)

$ErrorActionPreference = "Stop"

# ===== CONFIGURACIÓN =====
$ReleaseName = "HybridCapsLock-v$Version-Portable"
$ReleaseDir = "$OutputDir\$ReleaseName"
$ZipFile = "$OutputDir\$ReleaseName.zip"

# URLs de descarga
$KanataLatestAPI = "https://api.github.com/repos/jtroo/kanata/releases/latest"

Write-Host "Creating HybridCapsLock Portable Release v$Version" -ForegroundColor Magenta
Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta

# ===== LIMPIAR Y CREAR ESTRUCTURA =====
if (Test-Path $ReleaseDir) {
    Remove-Item $ReleaseDir -Recurse -Force
}
if (Test-Path $ZipFile) {
    Remove-Item $ZipFile -Force
}

New-Item -Path $ReleaseDir -ItemType Directory -Force | Out-Null
New-Item -Path "$ReleaseDir\bin" -ItemType Directory -Force | Out-Null

Write-Host "✓ Created release directory: $ReleaseDir" -ForegroundColor Green

# ===== COPIAR ARCHIVOS PRINCIPALES =====
$filesToCopy = @{
    "HybridCapslock.ahk" = "HybridCapslock.ahk"
    "init.ahk" = "init.ahk" 
    "README.md" = "README.md"
    "CHANGELOG.md" = "CHANGELOG.md"
    "install.ps1" = "install.ps1"
}

$directoriesToCopy = @("config", "src", "data", "doc", "scripts")

# Copiar archivos principales
foreach ($file in $filesToCopy.Keys) {
    if (Test-Path $file) {
        Copy-Item $file "$ReleaseDir\$($filesToCopy[$file])" -Force
        Write-Host "✓ Copied: $file" -ForegroundColor Green
    } else {
        Write-Host "⚠ Missing: $file" -ForegroundColor Yellow
    }
}

# Copiar directorios
foreach ($dir in $directoriesToCopy) {
    if (Test-Path $dir) {
        Copy-Item $dir "$ReleaseDir\$dir" -Recurse -Force
        Write-Host "✓ Copied directory: $dir" -ForegroundColor Green
    } else {
        Write-Host "⚠ Missing directory: $dir" -ForegroundColor Yellow
    }
}

# ===== DESCARGAR DEPENDENCIAS =====

# Descargar Kanata si se solicita
if ($IncludeKanata) {
    Write-Host "`nDownloading Kanata..." -ForegroundColor Cyan
    
    try {
        $release = Invoke-RestMethod -Uri $KanataLatestAPI -UseBasicParsing
        $asset = $release.assets | Where-Object { $_.name -match "kanata.*windows.*x86_64.*\.exe$" } | Select-Object -First 1
        
        if ($asset) {
            $kanataPath = "$ReleaseDir\bin\kanata.exe"
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $kanataPath -UseBasicParsing
            Write-Host "✓ Downloaded Kanata $($release.tag_name)" -ForegroundColor Green
        } else {
            Write-Host "⚠ Could not find Kanata Windows release" -ForegroundColor Yellow
        }
    }
    catch {
        Write-Host "✗ Failed to download Kanata: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# ===== CREAR ARCHIVOS DE INICIO RÁPIDO =====

# Quick Start batch file
$quickStartBat = @"
@echo off
echo Starting HybridCapsLock...
echo.
echo If this is your first time:
echo 1. Read README.md for setup instructions
echo 2. Configure settings in config\settings.ahk
echo 3. Customize keymaps in config\kanata.kbd
echo.
pause
start "" "HybridCapslock.ahk"
"@

Set-Content -Path "$ReleaseDir\Quick-Start.bat" -Value $quickStartBat -Encoding ASCII
Write-Host "✓ Created Quick-Start.bat" -ForegroundColor Green

# Installation README
$portableReadme = @"
# HybridCapsLock Portable v$Version

## 🚀 Quick Start

1. **First Time Setup:**
   - Run ``Quick-Start.bat`` for guided setup
   - Or double-click ``HybridCapslock.ahk`` to start immediately

2. **Dependencies:**
   - **AutoHotkey v2**: Download from https://www.autohotkey.com/download/ahk-v2.exe
   - **Kanata** (optional): $(if ($IncludeKanata) { "Included in bin\ folder" } else { "Download from https://github.com/jtroo/kanata/releases" })

3. **Configuration:**
   - Settings: ``config\settings.ahk``
   - Keymaps: ``config\kanata.kbd``
   - Colors: ``config\colorscheme.ahk``

## 📚 Documentation

- **Full Documentation**: ``doc\README.md``
- **Quick Start Guide**: ``doc\en\getting-started\quick-start.md``
- **User Guide**: ``doc\en\user-guide\``
- **Developer Guide**: ``doc\en\developer-guide\``

## 🛠 Installation Options

### Option 1: Portable (Current)
- Extract and run directly
- No system installation required
- Keep all files in this folder

### Option 2: Full Installation
- Run: ``install.ps1``
- Installs to system with auto-startup
- Downloads dependencies automatically

### Option 3: Manual Installation
- Copy files to desired location
- Install AutoHotkey v2 and Kanata manually
- Create shortcuts as needed

## 🔧 Troubleshooting

If HybridCapsLock doesn't start:
1. Ensure AutoHotkey v2 is installed
2. Check dependency_check.log for errors
3. Run ``HybridCapslock.ahk`` from command line to see error messages

## 📞 Support

- Documentation: ``doc\README.md``
- GitHub Issues: https://github.com/Wilberucx/Hybrid-CapsLock-fork/issues
- Troubleshooting: ``doc\en\reference\debug-system.md``

---

Created: $(Get-Date)
Version: $Version
Package Type: Portable Release
"@

Set-Content -Path "$ReleaseDir\README-PORTABLE.md" -Value $portableReadme -Encoding UTF8
Write-Host "✓ Created README-PORTABLE.md" -ForegroundColor Green

# ===== CREAR ARCHIVO ZIP =====
Write-Host "`nCreating ZIP package..." -ForegroundColor Cyan

Add-Type -AssemblyName System.IO.Compression.FileSystem
[System.IO.Compression.ZipFile]::CreateFromDirectory($ReleaseDir, $ZipFile)

$zipSize = (Get-Item $ZipFile).Length / 1MB
Write-Host "✓ Created ZIP: $ZipFile ($([math]::Round($zipSize, 2)) MB)" -ForegroundColor Green

# ===== RESUMEN =====
Write-Host "`n" -NoNewline
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host "🎉 Portable Release Created Successfully!" -ForegroundColor Green  
Write-Host "═══════════════════════════════════════" -ForegroundColor Green
Write-Host ""
Write-Host "📦 Package: $ZipFile" -ForegroundColor Cyan
Write-Host "📁 Size: $([math]::Round($zipSize, 2)) MB" -ForegroundColor Cyan
Write-Host "🏷️  Version: v$Version" -ForegroundColor Cyan
Write-Host ""
Write-Host "Contents:" -ForegroundColor White
Write-Host "• HybridCapsLock core files ✓" -ForegroundColor Green
Write-Host "• Complete documentation ✓" -ForegroundColor Green
Write-Host "• Configuration templates ✓" -ForegroundColor Green
Write-Host "• PowerShell installer ✓" -ForegroundColor Green
if ($IncludeKanata) {
    Write-Host "• Kanata binary ✓" -ForegroundColor Green
} else {
    Write-Host "• Kanata binary ➤ Download separately" -ForegroundColor Yellow
}
if (!$SkipAutoHotkey) {
    Write-Host "• AutoHotkey ➤ User must install" -ForegroundColor Yellow
}
Write-Host ""
Write-Host "Next steps:" -ForegroundColor White
Write-Host "• Upload ZIP to GitHub Releases" -ForegroundColor Gray
Write-Host "• Update download links in documentation" -ForegroundColor Gray
Write-Host "• Test installation on clean system" -ForegroundColor Gray
Write-Host ""