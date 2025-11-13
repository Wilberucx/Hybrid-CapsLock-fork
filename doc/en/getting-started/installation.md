# 📦 Installation Guide

Complete installation instructions for HybridCapslock on Windows.

---

## Prerequisites

Before installing HybridCapslock, ensure you have:

- **Windows 10 or 11** (64-bit recommended)
- **Administrator privileges** (required for Kanata driver installation)
- **AutoHotkey v2.0+** - [Download here](https://www.autohotkey.com/)
- **Kanata** - [Download here](https://github.com/jtroo/kanata/releases)
- Basic knowledge of command line (optional but helpful)

---

## Step-by-Step Installation

### Step 1: Install AutoHotkey v2

1. **Download AutoHotkey v2.0+**
   - Go to [autohotkey.com](https://www.autohotkey.com/)
   - Download the latest v2.0 installer (NOT v1.1)

2. **Run the installer**
   - Double-click the downloaded `.exe`
   - Follow the installation wizard
   - Choose "Express Installation" for default settings

3. **Verify installation**

   ```powershell
   # Open PowerShell and run:
   autohotkey --version

   # Should output something like:
   # AutoHotkey v2.0.18
   ```

---

### Step 2: Install Kanata

1. **Download Kanata**
   - Go to [Kanata Releases](https://github.com/jtroo/kanata/releases)
   - Download `kanata_wintercept.exe` for Windows

2. **Create Kanata directory**

   ```powershell
   # Create directory in Program Files
   New-Item -Path "C:\Program Files\Kanata" -ItemType Directory -Force

   # Move kanata.exe to the directory
   Move-Item kanata_wintercept.exe "C:\Program Files\Kanata\kanata.exe"
   ```

---

### Step 3: Download HybridCapslock

#### Option A: Using Git (Recommended)

```bash
cd C:\Users\YourUsername\Documents
git clone https://github.com/yourusername/HybridCapslock.git
cd HybridCapslock
```

#### Option B: Manual Download

1. Go to the [GitHub repository](https://github.com/yourusername/HybridCapslock)
2. Click "Code" → "Download ZIP"
3. Extract to desired location (e.g., `C:\Users\YourUsername\Documents\HybridCapslock`)

---

### Step 4: Configure Kanata Path

Edit `config/settings.ahk` to point to your Kanata installation:

```ahk
; Path to Kanata executable
global KanataPath := "C:\Program Files\Kanata\kanata.exe"

; Path to Kanata config
global KanataConfigPath := A_ScriptDir . "\config\../../../config/kanata.kbd"
```

**Note**: If you installed Kanata in a different location, update `KanataPath` accordingly.

---

### Step 5: First Launch

1. **Navigate to HybridCapslock directory**

   ```powershell
   cd C:\Users\YourUsername\Documents\HybridCapslock
   ```

2. **Launch HybridCapslock**
   - Double-click `HybridCapslock.ahk`
   - Or via command line: `autohotkey HybridCapslock.ahk`

3. **Verify it's running**
   - Check system tray for HybridCapslock icon
   - Kanata should start automatically in the background
   - Test homerow mods: Hold `a` (should act as Ctrl)

---

## Verification Tests

### Test 1: Homerow Mods

Open Notepad and test:

1. **Hold `a`** → Should act as Ctrl (try Ctrl+A to select all)
2. **Hold `s`** → Should act as Alt (try Alt+Tab)
3. **Hold `d`** → Should act as Win (try Win+E to open Explorer)
4. **Hold `f`** → Should act as Shift (try Shift+Arrow to select text)

If you can **tap** these keys to type normally but they act as modifiers when **held**, it's working! ✅

### Test 2: Nvim Layer

1. **Tap CapsLock** → Should show "NVIM Layer Active" tooltip
2. Press `h/j/k/l` → Should move cursor (left/down/up/right)
3. **Tap Escape** → Layer deactivates, tooltip disappears

### Test 3: Leader Mode

1. Hold **CapsLock + Space** → Should show leader menu
2. Try some shortcuts (varies by configuration)

If all tests pass, installation is complete! 🎉

---

## Optional: Start on Windows Boot

### Method 1: Startup Folder (Recommended)

1. **Create shortcut**
   - Right-click `HybridCapslock.ahk`
   - Select "Create shortcut"

2. **Move to Startup folder**

   ```powershell
   # Open Startup folder
   explorer shell:startup

   # Move the shortcut there
   ```

### Method 2: Task Scheduler (Advanced)

1. Open Task Scheduler
2. Create Basic Task
3. Name: "HybridCapslock"
4. Trigger: "When I log on"
5. Action: "Start a program"
6. Program: `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
7. Arguments: `"C:\Users\YourUsername\Documents\HybridCapslock\HybridCapslock.ahk"`
8. Check "Run with highest privileges"

---

## Troubleshooting

### Issue: AutoHotkey v2 not found

**Symptoms**: Error "AutoHotkey v2 is required"

**Solutions**:

1. Verify you installed **v2.0+** (not v1.1)
2. Check installation path: `C:\Program Files\AutoHotkey\v2\`
3. Reinstall AutoHotkey v2
4. Add AutoHotkey to PATH environment variable

---

### Issue: Keys not working

**Symptoms**: Homerow mods don't trigger, layers don't activate

**Solutions**:

1. Check if both HybridCapslock and Kanata are running
2. Verify `KanataPath` in `config/settings.ahk` is correct
3. Test Kanata alone: `kanata.exe --cfg config\../../../config/kanata.kbd`
4. Check for conflicting keyboard software (e.g., other AHK scripts)
5. Try reloading: `Ctrl+Alt+R`

---

### Issue: High CPU usage

**Symptoms**: AutoHotkey or Kanata consuming excessive CPU

**Solutions**:

1. Disable debug mode in `config/settings.ahk`:

   ```ahk
   global DEBUG_MODE := false
   ```

2. Disable tooltips temporarily:

   ```ahk
   global EnableTooltips := false
   ```

3. Check for infinite loops in custom layers
4. Update to latest version

---

### Issue: Antivirus blocking

**Symptoms**: Windows Defender or antivirus blocks Kanata

**Solutions**:

1. Add Kanata to antivirus exclusions:
   - Windows Security → Virus & threat protection → Exclusions
   - Add `C:\Program Files\Kanata\kanata.exe`
2. Download Kanata from official GitHub releases only
3. Verify file signature (if available)

---

## Uninstallation

### Remove HybridCapslock

1. Stop HybridCapslock (right-click tray icon → Exit)
2. Delete HybridCapslock folder
3. Remove startup shortcut (if created)

### Remove Kanata

1. Stop Kanata
2. Delete Kanata folder

### Remove AutoHotkey

1. Use Windows "Add or Remove Programs"
2. Find "AutoHotkey v2"
3. Click "Uninstall"

---

## Next Steps

After successful installation:

1. **[Quick Start Guide](../getting-started/quick-start.md)** - Learn essential shortcuts
2. **[Configuration Guide](configuration.md)** - Customize to your needs
3. **[Homerow Mods Guide](../user-guide/homerow-mods.md)** - Master modifier keys
4. **[Creating Layers](../developer-guide/creating-layers.md)** - Build custom layers

---

## System Requirements

### Minimum

- Windows 10 (1903 or later)
- 2 GB RAM
- 100 MB free disk space

### Recommended

- Windows 11
- 4 GB RAM
- SSD for better performance

### Supported Keyboards

- Standard QWERTY keyboards
- ISO/ANSI layouts
- Laptop keyboards
- External keyboards
- **Not tested**: Non-QWERTY layouts (Dvorak, Colemak, etc.)

---

**Need help?** Check the [Troubleshooting Section](../reference/debug-system.md) or [Quick Start Guide](../getting-started/quick-start.md).

**[🌍 Ver en Español](../../es/primeros-pasos/instalacion.md)** | **[← Back to Index](../README.md)**
