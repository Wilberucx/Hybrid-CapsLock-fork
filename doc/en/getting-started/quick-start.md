# 🚀 Quick Start Guide

Get HybridCapslock up and running in 5 minutes!

---

## Prerequisites

- **Windows 10/11** (64-bit recommended)
- **AutoHotkey v2.0+** - [Download here](https://www.autohotkey.com/)
- **Kanata** - [Download here](https://github.com/jtroo/kanata/releases)
- Basic knowledge of keyboard shortcuts

---

## 📦 Installation

### Step 1: Install AutoHotkey v2

1. Download AutoHotkey v2.0+ from [autohotkey.com](https://www.autohotkey.com/)
2. Run the installer
3. Verify installation: Open Command Prompt and type `autohotkey --version`

### Step 2: Install Kanata

1. Download the latest Kanata release for Windows
2. Extract `kanata.exe` to a permanent location (e.g., `C:\Program Files\Kanata\`)
3. Note the path - you'll need it for configuration

### Step 3: Clone HybridCapslock

```bash
git clone https://github.com/yourusername/HybridCapslock.git
cd HybridCapslock
```

Or download as ZIP and extract.

### Step 4: Configure Kanata Path

Edit `config/settings.ahk` and set your Kanata path:

```ahk
; Path to Kanata executable
global KanataPath := "C:\Program Files\Kanata\kanata.exe"
```

---

## ▶️ First Launch

### Option 1: Double-Click (Easiest)

1. Double-click `HybridCapslock.ahk` in the root directory
2. You should see a tray icon appear
3. Kanata will start automatically in the background

### Option 2: Command Line

```bash
autohotkey HybridCapslock.ahk
```

---

## ✅ Verify It's Working

### Test Homerow Mods

1. Open any text editor (Notepad, VS Code, etc.)
2. **Hold `a` key** (should act as Alt)
3. **Hold `s` key** (should act as Shift)
4. **Hold `d` key** (should act as Ctrl)
5. **Hold `f` key** (should act as Win)

If keys work normally when **tapped** but act as modifiers when **held**, it's working! ✨

### Test Nvim Layer

1. Press **CapsLock** to enter Nvim layer
2. Press `h/j/k/l` to move cursor (left/down/up/right)
3. You should see a tooltip showing "NVIM Layer Active"
4. Press **CapsLock** again to exit

---

## 🎮 Essential Shortcuts

### Global Shortcuts

| Shortcut | Action |
|----------|--------|
| `CapsLock` | Toggle Nvim Layer (Vim navigation) |
| `Space + Space` | Leader Mode (show all commands) |
| `Ctrl+Alt+R` | Reload HybridCapslock |
| `Ctrl+Alt+K` | Restart Kanata |

### Homerow Mods (when held)

| Key | Modifier |
|-----|----------|
| `a` | Alt |
| `s` | Shift |
| `d` | Ctrl |
| `f` | Win |
| `j` | Win |
| `k` | Ctrl |
| `l` | Shift |
| `;` | Alt |

### Nvim Layer (CapsLock active)

| Key | Action |
|-----|--------|
| `h` | Left |
| `j` | Down |
| `k` | Up |
| `l` | Right |
| `w` | Next word |
| `b` | Previous word |
| `0` | Line start |
| `$` | Line end |

---

## 🔧 Next Steps

### Customize Your Setup

1. **[Configuration Guide](configuration.md)** - Learn about all configuration options
2. **[Homerow Mods](../user-guide/homerow-mods.md)** - Master modifier keys
3. **[Leader Mode](../user-guide/leader-mode.md)** - Discover powerful shortcuts

### Explore Layers

- **[Nvim Layer](../user-guide/nvim-layer.md)** - Vim-style navigation
- **[Excel Layer](../user-guide/excel-layer.md)** - Excel productivity boost

### For Developers

- **[Creating New Layers](../developer-guide/creating-layers.md)** - Build custom layers
- **[Auto-Loader System](../developer-guide/auto-loader-system.md)** - Understand module loading

---

## 🐛 Troubleshooting

### Kanata Won't Start

**Problem**: Kanata fails to launch or crashes immediately.

**Solutions**:
1. Verify `KanataPath` in `config/settings.ahk` is correct
2. Check if `../../../config/kanata.kbd` is valid
3. Run Kanata manually: `kanata.exe -c ../../../config/kanata.kbd`
4. Check Windows Event Viewer for errors

### Keys Not Working

**Problem**: Homerow mods or layers don't respond.

**Solutions**:
1. Verify AutoHotkey v2 is installed (not v1.1)
2. Check if HybridCapslock is running (tray icon should be visible)
3. Reload: Press `Ctrl+Alt+R`
4. Check `data/layer_state.ini` - might be corrupted

### Timing Issues with Homerow Mods

**Problem**: Keys trigger too fast/slow when holding.

**Solutions**:
1. Adjust timing in `../../../config/kanata.kbd`:
   ```kbd
   (defsrc
     caps a s d f j k l scln
   )
   (deflayer base
     @cap @a @s @d @f @j @k @l @;
   )
   (defalias
     a (tap-hold 200 150 a lalt)  ; Increase first number (tap time)
     s (tap-hold 200 150 s lsft)
     ;; ... adjust as needed
   )
   ```
2. Experiment with values: 150-250ms usually works well

### High CPU Usage

**Problem**: AutoHotkey or Kanata using excessive CPU.

**Solutions**:
1. Check for infinite loops in custom layers
2. Disable tooltip animations in `config/settings.ahk`:
   ```ahk
   global EnableTooltips := false
   ```
3. Review recent changes - might be a custom script issue

---

## 📚 Learn More

- **[Full Documentation Index](../README.md)**
- **[Configuration Reference](configuration.md)**
- **[Debug System](../reference/debug-system.md)** - Advanced troubleshooting

---

## 💡 Tips for Beginners

1. **Start Small**: Don't customize everything at once. Master homerow mods first!
2. **Practice Daily**: Muscle memory takes 1-2 weeks to develop
3. **Use Tooltips**: Visual feedback helps while learning
4. **Join Community**: Share tips and get help (if available)

---

**Ready to customize?** → [Configuration Guide](configuration.md)

**Want to understand the system?** → [Architecture Overview](../reference/declarative-system.md)

---

**[🌍 Ver en Español](../../es/primeros-pasos/inicio-rapido.md)** | **[← Back to Index](../README.md)**
