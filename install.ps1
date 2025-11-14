# ===============================
# HybridCapsLock PowerShell Installer
# Repository: https://github.com/Wilberucx/Hybrid-CapsLock-fork
# ===============================
# Instala automáticamente HybridCapsLock y sus dependencias
# Uso: 
#   .\install.ps1                    # Instalación normal
#   .\install.ps1 -DevMode           # Modo desarrollador
#   .\install.ps1 -Portable          # Instalación portable

[CmdletBinding()]
param(
    [switch]$DevMode,
    [switch]$Portable,
    [switch]$Force,
    [string]$InstallPath = "",
    [switch]$NoKanata,
    [switch]$Quiet
)

# ===== CONFIGURACIÓN =====
$ErrorActionPreference = "Stop"
$ScriptVersion = "1.0.0"

# URLs de descarga
$KanataLatestAPI = "https://api.github.com/repos/jtroo/kanata/releases/latest"
$AutoHotkeyDownloadURL = "https://www.autohotkey.com/download/ahk-v2.exe"

# Rutas de instalación
if ($InstallPath -eq "") {
    if ($Portable) {
        $InstallPath = $PSScriptRoot
    } else {
        $InstallPath = "$env:LOCALAPPDATA\HybridCapsLock"
    }
}

$BinPath = "$InstallPath\bin"
$BackupPath = "$InstallPath\backup"

# ===== FUNCIONES =====

function Write-Status {
    param([string]$Message, [string]$Level = "Info")
    
    if ($Quiet) { return }
    
    $color = switch ($Level) {
        "Success" { "Green" }
        "Warning" { "Yellow" }
        "Error" { "Red" }
        default { "Cyan" }
    }
    
    Write-Host "[$Level] $Message" -ForegroundColor $color
}

function Test-AdminRights {
    $currentUser = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = New-Object Security.Principal.WindowsPrincipal($currentUser)
    return $principal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

function Install-AutoHotkey {
    Write-Status "Checking AutoHotkey v2 installation..."
    
    # Verificar si ya está instalado
    $ahkPaths = @(
        "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey.exe",
        "${env:LOCALAPPDATA}\Programs\AutoHotkey\v2\AutoHotkey.exe",
        "$BinPath\AutoHotkey.exe"
    )
    
    foreach ($path in $ahkPaths) {
        if (Test-Path $path) {
            Write-Status "AutoHotkey v2 found at: $path" "Success"
            return $true
        }
    }
    
    # Descargar e instalar AutoHotkey v2
    Write-Status "AutoHotkey v2 not found. Downloading..."
    
    $tempFile = "$env:TEMP\AutoHotkey_v2_Setup.exe"
    
    try {
        Invoke-WebRequest -Uri $AutoHotkeyDownloadURL -OutFile $tempFile -UseBasicParsing
        Write-Status "AutoHotkey v2 downloaded. Installing..."
        
        if ($Portable) {
            # Para instalación portable, extraer a bin/
            New-Item -Path $BinPath -ItemType Directory -Force | Out-Null
            # Nota: El installer de AHK v2 requiere instalación estándar
            Write-Status "For portable installation, please install AutoHotkey v2 manually" "Warning"
            return $false
        } else {
            # Instalar automáticamente
            $process = Start-Process -FilePath $tempFile -ArgumentList "/S" -Wait -PassThru
            if ($process.ExitCode -eq 0) {
                Write-Status "AutoHotkey v2 installed successfully!" "Success"
                return $true
            } else {
                Write-Status "AutoHotkey v2 installation failed" "Error"
                return $false
            }
        }
    }
    catch {
        Write-Status "Failed to download AutoHotkey v2: $($_.Exception.Message)" "Error"
        return $false
    }
    finally {
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
    }
}

function Install-Kanata {
    if ($NoKanata) {
        Write-Status "Skipping Kanata installation (--NoKanata specified)"
        return $true
    }
    
    Write-Status "Checking Kanata installation..."
    
    # Verificar si ya está disponible
    if (Get-Command "kanata" -ErrorAction SilentlyContinue) {
        Write-Status "Kanata found in system PATH" "Success"
        return $true
    }
    
    $kanataPath = "$BinPath\kanata.exe"
    if (Test-Path $kanataPath) {
        Write-Status "Kanata found at: $kanataPath" "Success"
        return $true
    }
    
    # Descargar Kanata
    Write-Status "Kanata not found. Downloading latest release..."
    
    try {
        # Obtener la última release
        $release = Invoke-RestMethod -Uri $KanataLatestAPI -UseBasicParsing
        
        # Encontrar el asset para Windows x86_64
        $asset = $release.assets | Where-Object { $_.name -match "kanata.*windows.*x86_64.*\.exe$" } | Select-Object -First 1
        
        if (-not $asset) {
            Write-Status "Could not find Windows x86_64 release for Kanata" "Error"
            return $false
        }
        
        Write-Status "Downloading Kanata $($release.tag_name)..."
        
        New-Item -Path $BinPath -ItemType Directory -Force | Out-Null
        Invoke-WebRequest -Uri $asset.browser_download_url -OutFile $kanataPath -UseBasicParsing
        
        # Verificar descarga
        if (Test-Path $kanataPath) {
            Write-Status "Kanata $($release.tag_name) downloaded successfully!" "Success"
            return $true
        } else {
            Write-Status "Kanata download verification failed" "Error"
            return $false
        }
    }
    catch {
        Write-Status "Failed to download Kanata: $($_.Exception.Message)" "Error"
        return $false
    }
}

function Setup-HybridCapsLock {
    Write-Status "Setting up HybridCapsLock..."
    
    if (-not $Portable -and $InstallPath -ne $PSScriptRoot) {
        # Copiar archivos a directorio de instalación
        Write-Status "Copying HybridCapsLock files to $InstallPath..."
        
        New-Item -Path $InstallPath -ItemType Directory -Force | Out-Null
        
        # Copiar archivos principales
        $filesToCopy = @(
            "*.ahk", "*.md", "*.json",
            "config", "src", "data", "doc", "scripts"
        )
        
        foreach ($pattern in $filesToCopy) {
            $items = Get-ChildItem $PSScriptRoot -Name $pattern -Recurse
            foreach ($item in $items) {
                $source = Join-Path $PSScriptRoot $item
                $destination = Join-Path $InstallPath $item
                
                $destDir = Split-Path $destination -Parent
                New-Item -Path $destDir -ItemType Directory -Force | Out-Null
                
                Copy-Item $source $destination -Force
            }
        }
    }
    
    # Crear acceso directo en el escritorio (si no es modo desarrollador)
    if (-not $DevMode -and -not $Portable) {
        $desktopPath = [Environment]::GetFolderPath("Desktop")
        $shortcutPath = "$desktopPath\HybridCapsLock.lnk"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = "$InstallPath\HybridCapslock.ahk"
        $shortcut.WorkingDirectory = $InstallPath
        $shortcut.Description = "HybridCapsLock - Advanced Keyboard Customization"
        $shortcut.Save()
        
        Write-Status "Desktop shortcut created" "Success"
    }
    
    # Configurar startup automático (si no es modo desarrollador)
    if (-not $DevMode -and -not $Portable) {
        $startupPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup"
        $startupShortcut = "$startupPath\HybridCapsLock.lnk"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($startupShortcut)
        $shortcut.TargetPath = "$InstallPath\HybridCapslock.ahk"
        $shortcut.WorkingDirectory = $InstallPath
        $shortcut.Description = "HybridCapsLock - Auto Start"
        $shortcut.Save()
        
        Write-Status "Auto-startup configured" "Success"
    }
    
    return $true
}

function Show-InstallSummary {
    Write-Host "`n" -NoNewline
    Write-Host "═══════════════════════════════════════" -ForegroundColor Green
    Write-Host "🎉 HybridCapsLock Installation Complete!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "📁 Installation Path: $InstallPath" -ForegroundColor Cyan
    Write-Host "🔧 Mode: " -NoNewline -ForegroundColor Cyan
    
    if ($DevMode) {
        Write-Host "Developer Mode" -ForegroundColor Yellow
    } elseif ($Portable) {
        Write-Host "Portable" -ForegroundColor Blue
    } else {
        Write-Host "Standard Installation" -ForegroundColor Green
    }
    
    Write-Host ""
    Write-Host "Next steps:" -ForegroundColor White
    
    if ($Portable -or $DevMode) {
        Write-Host "• Run: .\HybridCapslock.ahk" -ForegroundColor Gray
    } else {
        Write-Host "• Use desktop shortcut or startup menu" -ForegroundColor Gray
    }
    
    Write-Host "• Read documentation: .\doc\README.md" -ForegroundColor Gray
    Write-Host "• Configure settings: .\config\settings.ahk" -ForegroundColor Gray
    
    if (-not $NoKanata) {
        Write-Host "• Configure Kanata: .\config\kanata.kbd" -ForegroundColor Gray
    }
    
    Write-Host ""
    Write-Host "🔗 Documentation: https://github.com/your-repo/doc/README.md" -ForegroundColor Blue
    Write-Host ""
}

# ===== MAIN INSTALLATION =====

try {
    Write-Host "HybridCapsLock PowerShell Installer v$ScriptVersion" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════════" -ForegroundColor Magenta
    Write-Host ""
    
    # Verificar permisos de administrador para instalación estándar
    if (-not $Portable -and -not $DevMode -and -not (Test-AdminRights)) {
        Write-Status "Standard installation requires administrator rights." "Warning"
        Write-Status "Rerun as administrator or use -Portable flag" "Warning"
        exit 1
    }
    
    Write-Status "Installing to: $InstallPath"
    
    # Crear backup si existe instalación previa
    if (Test-Path $InstallPath -and -not $Force) {
        Write-Status "Previous installation detected. Creating backup..."
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupDir = "$BackupPath\backup_$timestamp"
        New-Item -Path $backupDir -ItemType Directory -Force | Out-Null
        Copy-Item "$InstallPath\*" $backupDir -Recurse -Force
        Write-Status "Backup created at: $backupDir" "Success"
    }
    
    # Instalar dependencias
    $ahkSuccess = Install-AutoHotkey
    $kanataSuccess = Install-Kanata
    
    # Configurar HybridCapsLock
    $setupSuccess = Setup-HybridCapsLock
    
    if ($ahkSuccess -and $kanataSuccess -and $setupSuccess) {
        Show-InstallSummary
        
        # Preguntar si quiere ejecutar ahora
        if (-not $Quiet) {
            $response = Read-Host "`nStart HybridCapsLock now? (y/n)"
            if ($response -eq "y" -or $response -eq "Y") {
                Start-Process -FilePath "$InstallPath\HybridCapslock.ahk" -WorkingDirectory $InstallPath
            }
        }
        
        exit 0
    } else {
        Write-Status "Installation completed with some issues. Check the output above." "Warning"
        exit 1
    }
}
catch {
    Write-Status "Installation failed: $($_.Exception.Message)" "Error"
    exit 1
}