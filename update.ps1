# ===================================================================
# HybridCapsLock - Update Script (Neovim-style)
# ===================================================================
# This script updates the system/ directory while preserving your
# personal ahk/ configuration (like Neovim updates).
#
# What it does:
# 1. Creates a backup of your ahk/ directory (safety first)
# 2. Downloads/extracts the new version
# 3. Replaces system/ directory with updated version
# 4. Preserves init.ahk if you haven't modified it
# 5. Keeps your ahk/ directory untouched
# 6. Updates root files (HybridCapslock.ahk, README.md, etc.)
#
# Usage:
#   .\update.ps1                           # Download from GitHub releases
#   .\update.ps1 -LocalZip "path\to.zip"   # Install from local file
#   .\update.ps1 -Version "v6.4"           # Install specific version
# ===================================================================

param(
    [string]$LocalZip = "",
    [string]$Version = "latest",
    [switch]$SkipBackup = $false
)

$ErrorActionPreference = "Stop"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# ===================================================================
# CONFIGURATION
# ===================================================================

$GitHubRepo = "Wilberucx/Hybrid-CapsLock-fork"
$BackupDir = Join-Path $ScriptDir "backup_ahk_$(Get-Date -Format 'yyyyMMdd_HHmmss')"
$TempDir = Join-Path $env:TEMP "HybridCapsLock_Update"
$UpdateLogFile = Join-Path $ScriptDir "update_log.txt"

# ===================================================================
# LOGGING
# ===================================================================

function Write-Log {
    param([string]$Message, [string]$Type = "INFO")
    
    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Type] $Message"
    
    switch ($Type) {
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        default { Write-Host $LogMessage }
    }
    
    Add-Content -Path $UpdateLogFile -Value $LogMessage
}

# ===================================================================
# BACKUP
# ===================================================================

function New-AhkBackup {
    if ($SkipBackup) {
        Write-Log "Backup skipped by user" "WARNING"
        return $true
    }
    
    Write-Log "Creating backup of ahk/ directory..." "INFO"
    
    $ahkDir = Join-Path $ScriptDir "ahk"
    
    if (!(Test-Path $ahkDir)) {
        Write-Log "No ahk/ directory found, skipping backup" "INFO"
        return $true
    }
    
    try {
        New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null
        Copy-Item -Path $ahkDir -Destination (Join-Path $BackupDir "ahk") -Recurse -Force
        
        Write-Log "Backup created at: $BackupDir" "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Backup failed: $_" "ERROR"
        return $false
    }
}

# ===================================================================
# DOWNLOAD
# ===================================================================

function Get-LatestRelease {
    Write-Log "Fetching latest release from GitHub..." "INFO"
    
    try {
        $apiUrl = "https://api.github.com/repos/$GitHubRepo/releases/latest"
        $release = Invoke-RestMethod -Uri $apiUrl
        
        Write-Log "Latest version: $($release.tag_name)" "SUCCESS"
        return $release
    }
    catch {
        Write-Log "Failed to fetch release: $_" "ERROR"
        return $null
    }
}

function Get-SpecificRelease {
    param([string]$Version)
    
    Write-Log "Fetching version $Version from GitHub..." "INFO"
    
    try {
        $apiUrl = "https://api.github.com/repos/$GitHubRepo/releases/tags/$Version"
        $release = Invoke-RestMethod -Uri $apiUrl
        
        Write-Log "Found version: $($release.tag_name)" "SUCCESS"
        return $release
    }
    catch {
        Write-Log "Failed to fetch version $Version : $_" "ERROR"
        return $null
    }
}

function Get-UpdatePackage {
    param([string]$LocalZipPath, [string]$Version)
    
    # Clean temp directory
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
    }
    New-Item -ItemType Directory -Path $TempDir -Force | Out-Null
    
    if ($LocalZipPath -ne "") {
        # Use local zip file
        Write-Log "Using local file: $LocalZipPath" "INFO"
        
        if (!(Test-Path $LocalZipPath)) {
            Write-Log "Local file not found: $LocalZipPath" "ERROR"
            return $null
        }
        
        $zipPath = $LocalZipPath
    }
    else {
        # Download from GitHub
        if ($Version -eq "latest") {
            $release = Get-LatestRelease
        } else {
            $release = Get-SpecificRelease -Version $Version
        }
        
        if ($null -eq $release) {
            return $null
        }
        
        # Find the portable release asset
        $asset = $release.assets | Where-Object { $_.name -like "*Portable.zip" } | Select-Object -First 1
        
        if ($null -eq $asset) {
            Write-Log "No portable release found in $($release.tag_name)" "ERROR"
            return $null
        }
        
        Write-Log "Downloading: $($asset.name)" "INFO"
        $zipPath = Join-Path $TempDir $asset.name
        
        try {
            Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $zipPath
            Write-Log "Download complete" "SUCCESS"
        }
        catch {
            Write-Log "Download failed: $_" "ERROR"
            return $null
        }
    }
    
    # Extract zip
    Write-Log "Extracting update package..." "INFO"
    $extractPath = Join-Path $TempDir "extracted"
    
    try {
        Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
        Write-Log "Extraction complete" "SUCCESS"
        return $extractPath
    }
    catch {
        Write-Log "Extraction failed: $_" "ERROR"
        return $null
    }
}

# ===================================================================
# UPDATE
# ===================================================================

function Invoke-Update {
    param([string]$SourceDir)
    
    Write-Log "Applying update..." "INFO"
    
    try {
        # Update system/ directory
        Write-Log "Updating system/ directory..." "INFO"
        $sourceSystem = Join-Path $SourceDir "system"
        $targetSystem = Join-Path $ScriptDir "system"
        
        if (Test-Path $sourceSystem) {
            if (Test-Path $targetSystem) {
                Remove-Item -Path $targetSystem -Recurse -Force
            }
            Copy-Item -Path $sourceSystem -Destination $targetSystem -Recurse -Force
            Write-Log "  system/ updated" "SUCCESS"
        } else {
            Write-Log "  No system/ directory in update package" "WARNING"
        }
        
        # Update root files
        Write-Log "Updating root files..." "INFO"
        $rootFiles = @("HybridCapslock.ahk", "README.md", "CHANGELOG.md", "global.json")
        
        foreach ($file in $rootFiles) {
            $sourcePath = Join-Path $SourceDir $file
            $targetPath = Join-Path $ScriptDir $file
            
            if (Test-Path $sourcePath) {
                Copy-Item -Path $sourcePath -Destination $targetPath -Force
                Write-Log "  Updated: $file" "SUCCESS"
            }
        }
        
        # Update init.ahk (only if user hasn't modified it)
        $sourceInit = Join-Path $SourceDir "init.ahk"
        $targetInit = Join-Path $ScriptDir "init.ahk"
        
        if (Test-Path $sourceInit) {
            Write-Log "Checking init.ahk..." "INFO"
            
            # Simple check: if file sizes are very different, user probably modified it
            $sourceSize = (Get-Item $sourceInit).Length
            $targetSize = (Get-Item $targetInit).Length
            $sizeDiff = [Math]::Abs($sourceSize - $targetSize)
            
            if ($sizeDiff -lt 500) {
                Copy-Item -Path $sourceInit -Destination $targetInit -Force
                Write-Log "  init.ahk updated (no custom changes detected)" "SUCCESS"
            } else {
                Write-Log "  init.ahk NOT updated (appears to have custom changes)" "WARNING"
                Write-Log "  You may want to manually merge changes from:" "WARNING"
                Write-Log "    $sourceInit" "WARNING"
            }
        }
        
        # Update doc/ if exists
        $sourceDoc = Join-Path $SourceDir "doc"
        $targetDoc = Join-Path $ScriptDir "doc"
        
        if (Test-Path $sourceDoc) {
            if (Test-Path $targetDoc) {
                Remove-Item -Path $targetDoc -Recurse -Force
            }
            Copy-Item -Path $sourceDoc -Destination $targetDoc -Recurse -Force
            Write-Log "  doc/ updated" "SUCCESS"
        }
        
        # NOTE: ahk/ directory is NEVER touched during updates
        Write-Log "Your ahk/ directory remains untouched (as intended)" "SUCCESS"
        
        return $true
    }
    catch {
        Write-Log "Update failed: $_" "ERROR"
        return $false
    }
}

# ===================================================================
# VERIFICATION
# ===================================================================

function Test-UpdateResult {
    Write-Log "Verifying update..." "INFO"
    
    $errors = @()
    
    # Check critical directories
    $criticalDirs = @("system", "system/core", "system/ui", "system/actions", "system/layers")
    
    foreach ($dir in $criticalDirs) {
        $path = Join-Path $ScriptDir $dir
        if (!(Test-Path $path)) {
            $errors += "Missing directory: $dir"
        }
    }
    
    # Check critical files
    $criticalFiles = @("HybridCapslock.ahk", "init.ahk", "system/core/auto_loader.ahk")
    
    foreach ($file in $criticalFiles) {
        $path = Join-Path $ScriptDir $file
        if (!(Test-Path $path)) {
            $errors += "Missing file: $file"
        }
    }
    
    if ($errors.Count -gt 0) {
        Write-Log "Verification failed with errors:" "ERROR"
        foreach ($error in $errors) {
            Write-Log "  - $error" "ERROR"
        }
        return $false
    }
    
    Write-Log "Verification passed" "SUCCESS"
    return $true
}

# ===================================================================
# MAIN
# ===================================================================

function Main {
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host "HybridCapsLock - Update Script" -ForegroundColor Cyan
    Write-Host "=============================================" -ForegroundColor Cyan
    Write-Host ""
    
    # Initialize log
    "Update started at $(Get-Date)" | Set-Content -Path $UpdateLogFile
    
    # Create backup of ahk/
    if (!(New-AhkBackup)) {
        Write-Log "Backup failed, aborting update" "ERROR"
        return
    }
    
    # Download/prepare update package
    $updateSource = Get-UpdatePackage -LocalZipPath $LocalZip -Version $Version
    
    if ($null -eq $updateSource) {
        Write-Log "Failed to get update package, aborting" "ERROR"
        return
    }
    
    # Apply update
    if (!(Invoke-Update -SourceDir $updateSource)) {
        Write-Log "Update failed" "ERROR"
        Write-Log "Your ahk/ backup is available at: $BackupDir" "WARNING"
        return
    }
    
    # Verify
    if (!(Test-UpdateResult)) {
        Write-Log "Update verification failed" "ERROR"
        return
    }
    
    # Cleanup
    if (Test-Path $TempDir) {
        Remove-Item -Path $TempDir -Recurse -Force
        Write-Log "Cleaned up temporary files" "INFO"
    }
    
    Write-Host ""
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host "Update completed successfully!" -ForegroundColor Green
    Write-Host "=============================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "What was updated:" -ForegroundColor Cyan
    Write-Host "  ✓ system/ directory (core, ui, actions, layers)" -ForegroundColor White
    Write-Host "  ✓ HybridCapslock.ahk, README.md, CHANGELOG.md" -ForegroundColor White
    Write-Host "  ✓ Documentation (doc/)" -ForegroundColor White
    Write-Host ""
    Write-Host "What was preserved:" -ForegroundColor Cyan
    Write-Host "  ✓ Your ahk/ directory (config, actions, layers)" -ForegroundColor White
    Write-Host "  ✓ Your data/ directory (logs, settings)" -ForegroundColor White
    Write-Host ""
    Write-Host "Backup location: $BackupDir" -ForegroundColor Yellow
    Write-Host "Log file: $UpdateLogFile" -ForegroundColor Yellow
    Write-Host ""
}

# Run main
Main
