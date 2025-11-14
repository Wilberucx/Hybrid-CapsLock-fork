# 🚀 HybridCapsLock Quick Installation Guide

## Option 1: One-Line PowerShell Install (Recommended)

```powershell
# Download and run installer (requires PowerShell)
iwr -useb https://raw.githubusercontent.com/Wilberucx/Hybrid-CapsLock-fork/main/install.ps1 | iex
```

**What this does:**
- ✅ Downloads AutoHotkey v2 automatically
- ✅ Downloads Kanata automatically  
- ✅ Installs HybridCapsLock to `%LOCALAPPDATA%\HybridCapsLock`
- ✅ Creates desktop shortcut
- ✅ Sets up auto-startup
- ✅ Verifies all dependencies

---

## Option 2: Portable Release (No Installation)

1. **Download:** [HybridCapsLock-Portable.zip](https://github.com/Wilberucx/Hybrid-CapsLock-fork/releases)
2. **Extract** to any folder
3. **Install AutoHotkey v2:** [Download here](https://www.autohotkey.com/download/ahk-v2.exe)
4. **Run:** Double-click `HybridCapslock.ahk`

---

## Option 3: Manual Clone + Install Script

```bash
# Clone repository
git clone https://github.com/Wilberucx/Hybrid-CapsLock-fork.git
cd HybridCapsLock

# Run installer
.\install.ps1
```

---

## Installation Options

| Method | Best For | Dependencies | Auto-Startup | 
|--------|----------|--------------|---------------|
| **PowerShell One-Line** | Most users | ✅ Auto | ✅ Yes |
| **Portable Release** | Testing/Temporary | 🔧 Manual | ❌ No |
| **Manual Clone** | Developers | 🔧 Manual | 🔧 Optional |

---

## Advanced Installation

```powershell
# Portable installation (current directory)
.\install.ps1 -Portable

# Developer mode (no auto-startup, no shortcuts)
.\install.ps1 -DevMode

# Skip Kanata (AutoHotkey only)
.\install.ps1 -NoKanata

# Custom installation path
.\install.ps1 -InstallPath "C:\MyTools\HybridCapsLock"

# Silent installation
.\install.ps1 -Quiet
```

---

## Verification

After installation, verify everything works:

```powershell
# Check if HybridCapsLock is running
Get-Process | Where-Object { $_.ProcessName -like "*AutoHotkey*" }

# Check dependency status (HybridCapsLock verifies automatically)
.\HybridCapslock.ahk  # Will show dependency dialog if anything is missing
```

---

## Troubleshooting

**❌ PowerShell execution policy error:**
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

**❌ AutoHotkey not found:**
- Install manually: https://www.autohotkey.com/download/ahk-v2.exe
- Or use portable release

**❌ Kanata not working:**
```powershell
# Install without Kanata
.\install.ps1 -NoKanata
```

**❌ Permission denied:**
```powershell
# Run as administrator or use portable
.\install.ps1 -Portable
```

---

## Next Steps

1. **📚 Read documentation:** `doc\README.md`
2. **⚙️ Configure settings:** `config\settings.ahk`
3. **🎨 Customize colors:** `config\colorscheme.ahk`
4. **⌨️ Setup keymaps:** `config\kanata.kbd`

---

## Uninstall

```powershell
# Remove HybridCapsLock
Remove-Item "$env:LOCALAPPDATA\HybridCapsLock" -Recurse -Force

# Remove shortcuts
Remove-Item "$env:USERPROFILE\Desktop\HybridCapsLock.lnk" -Force
Remove-Item "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\HybridCapsLock.lnk" -Force
```

---

**Need help?** Check the [full documentation](doc/README.md) or [troubleshooting guide](doc/en/reference/debug-system.md).