# 📦 Installation Guide

> 📍 **Navigation**: [Home](../../../README.md) > User Guide > Installation

Complete installation instructions for HybridCapslock on Windows.

---

## Prerequisites

Before installing HybridCapslock, make sure you have:

- **Windows 10 or 11** (64-bit recommended)
- **Administrator Privileges** (recommended for Kanata, not always required)
- **AutoHotkey v2.0+** - [Download here](https://www.autohotkey.com/)
- **Kanata** - [Download here](https://github.com/jtroo/kanata/releases)
- Basic command line knowledge (optional but helpful)

---

## Step-by-Step Installation

### Step 1: Install AutoHotkey v2

1. **Download AutoHotkey v2.0+**
   - Go to [autohotkey.com](https://www.autohotkey.com/)
   - Download the latest v2.0 installer (NOT v1.1)

2. **Run the installer**
   - Double-click the downloaded `.exe` file
   - Follow the installation wizard
   - Choose "Express Installation" for default settings

3. **Verify installation**

   ```powershell
   # Open PowerShell and run:
   autohotkey --version

   # Should display something like:
   # AutoHotkey v2.0.18
   ```

---

### Step 2: Install Kanata

1. **Download Kanata**
   - Go to [Kanata Releases](https://github.com/jtroo/kanata/releases)
   - Download the Windows version of `kanata`

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
cd C:\Users\YourUser\Documents
git clone https://github.com/yourusername/HybridCapslock.git
cd HybridCapslock
```

#### Option B: Manual Download

1. Go to the [GitHub repository](https://github.com/Wilberucx/HybridCapslock)
2. Click "Code" → "Download ZIP"
3. Extract to desired location (e.g., `C:\Users\YourUser\Documents\HybridCapslock`)

---

### Step 4: Configure Kanata Path

Edit `config/settings.ahk` to point to your Kanata installation:

```ahk
; Path to Kanata executable
global KanataPath := "C:\Program Files\Kanata\kanata.exe"

; Path to Kanata config
global KanataConfigPath := A_ScriptDir . "\config\kanata.kbd"
```

**Note**: If you installed Kanata in a different location, update `KanataPath` accordingly.

---

### Step 5: First Launch

1. **Navigate to HybridCapslock directory**

   ```powershell
   cd C:\Users\YourUser\Documents\HybridCapslock
   ```

2. **Launch HybridCapslock**
   - Double-click `HybridCapslock.ahk`
   - Or via command line: `autohotkey HybridCapslock.ahk`

3. **Verify it's working**
   - Check system tray for HybridCapslock icon
   - Kanata should start automatically in the background
   - Test homerow mods: Hold `a` (should act as Ctrl)

---

### Step 6: Plugin Installation (Optional)

The system comes "clean" by default, with only the system manager (`system/plugins/hybrid_actions.ahk`). To add extra functionality, you must install the plugins you want.

1. **Explore Available Plugins**
   - Visit the plugins section in the repository: [Plugin List](../../plugins/README.md)
   - Or navigate on GitHub to `doc/plugins`.

2. **Install a Plugin**
   - Download the `.ahk` file you want.
   - Place it in the `ahk/plugins` folder of your installation.

   **Example: Install Vim actions**
   - Download `vim_actions.ahk`.
   - Copy to `ahk/plugins/vim_actions.ahk`.

3. **Restart HybridCapsLock**
   - Use the shortcut `Leader + h + R` (if configured) or restart the script manually.
   - The system will automatically detect the new plugin and load its shortcuts.

---

## Verification Tests

### Test 1: Vim Navigation (Basic Setup)

Open Notepad and try:

1. **Hold down `CapsLock`** (don't release)
2. While holding it, press `j` → Cursor moves down (↓)
3. Press `k` → Cursor moves up (↑)
4. Press `h` → Cursor moves left (←)
5. Press `l` → Cursor moves right (→)
6. **Release `CapsLock`**

✅ **Success**: You can navigate without using arrow keys!

### Test 2: Leader Mode

1. **Hold `CapsLock` + press `Space`**
2. A visual menu should appear on screen
3. Press `Esc` to exit

✅ **Success**: Leader mode is working!

---

## Troubleshooting

### Kanata doesn't start

**Symptoms**: No homerow mods, CapsLock behaves normally

**Solutions**:
1. Check if Kanata is running in Task Manager
2. Verify `KanataPath` in `config/settings.ahk`
3. Try running Kanata manually: `"C:\Program Files\Kanata\kanata.exe" -c "path\to\kanata.kbd"`
4. Check Windows Event Viewer for errors

### AutoHotkey script won't run

**Symptoms**: Double-clicking `HybridCapslock.ahk` does nothing

**Solutions**:
1. Verify AutoHotkey v2 is installed: `autohotkey --version`
2. Right-click `HybridCapslock.ahk` → "Run Script"
3. Check for syntax errors in log file

### Homerow mods trigger too easily/slowly

**Solution**: Edit `config/kanata.kbd` and adjust timing:

```lisp
(defcfg
  process-unmapped-keys yes
  danger-enable-cmd yes
  sequence-timeout 2000
  sequence-input-mode visible-backspaced
  sequence-backtrack-modcancel yes
  
  ;; Adjust these values:
  tap-timeout 200        ;; Increase if triggers too easily
  hold-timeout 200       ;; Decrease for faster response
)
```

---

## Next Steps

Now that you have HybridCapsLock installed:

1. **Learn the basics**: Read the [Key Concepts](concepts.md) guide
2. **Explore Leader Mode**: Check out the [Leader Mode](leader-mode.md) documentation
3. **Install plugins**: Browse the [Plugin Catalog](../../plugins/README.md)
4. **Customize**: Edit `ahk/config/keymap.ahk` to add your own shortcuts

---

<div align="center">

[← Previous: Concepts](concepts.md) | [Back to Home](../../../README.md) | [Next: Leader Mode →](leader-mode.md)

</div>
