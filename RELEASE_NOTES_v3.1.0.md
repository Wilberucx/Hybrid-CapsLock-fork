# 🚀 HybridCapsLock v3.1.0 - Major Feature Release

**Release Date:** January 10, 2025

---

## 📋 Overview

This release represents a significant milestone with **20+ commits** introducing a unified notification system, native Kanata management, comprehensive window management, and critical bug fixes for layer navigation. This is a **minor version** release with substantial new features while maintaining full backward compatibility.

**Highlights:**
- ✅ **2 New Core Plugins** (notification system + Kanata manager)
- ✅ **3 Enhanced Action Plugins** (windows manager, explorer, lazygit)
- ✅ **Critical Navigation Fixes** (layer history preservation)
- ✅ **Comprehensive Documentation** (homerow mods, defensive patterns)
- ✅ **Native Windows Dialogs** (replacing tooltip confirmations)

---

## 🎯 What's New

### 🔔 Unified Notification System

**New Core Plugin:** `system/plugins/notification.ahk`

A centralized API for all plugin feedback with visual hierarchy and animations.

```autohotkey
ShowTooltipFeedback("Operation completed!", "success")
ShowTooltipFeedback("Warning: Low battery", "warning", 3000)
ShowTooltipFeedback("File not found", "error")
```

**Features:**
- 🎨 **5 Feedback Types** with auto icons: `info` (💡), `success` (✅), `warning` (⚠️), `error` (❌), `confirm` (❓)
- 🎬 **Animated Notifications** using TooltipApp slide_left from top_right
- 🎨 **NerdFont Icon Support** for visual hierarchy
- ⏱️ **Configurable Timeouts** (default: 2000ms)
- 🔄 **Graceful Fallback** to native ToolTip if TooltipApp unavailable
- 🎨 **Theme-Aware** styling

---

### 🎛️ Kanata Manager Plugin

**New Core Plugin:** `system/plugins/kanata_manager.ahk`

Native AutoHotkey v2 implementation replacing VBScript dependencies.

**Key Improvements:**
- ✅ **Native AHK v2** - No more VBScript files
- ✅ **Pre-Start Validation** - Config checked with `--check` before launch
- ✅ **Smart Path Detection** - Searches common locations automatically
- ✅ **9 Error Types** with contextual dialogs and fix suggestions
- ✅ **Crash Detection** - Monitors process health after start
- ✅ **Enhanced API**: `KanataToggle()`, `KanataShowStatus()`, `KanataStartWithRetry()`

**Configuration:**
```autohotkey
HybridConfig.kanata := {
    enabled: true,
    exePath: "kanata.exe",
    configFile: "ahk\config\kanata.kbd",
    autoStart: true,
    fallbackPaths: [/* ... */]
}
```

**What Was Removed:**
- ❌ 3 VBScript files (`start_kanata.vbs`, `stop_kanata.vbs`, `restart_kanata.vbs`)
- ❌ `system/core/kanata_launcher.ahk`
- ❌ `system/core/kanata/` directory
- ❌ `kanata-info/` reference directory

**Net Result:** -6 files, +1 robust plugin (742 lines with comprehensive error handling)

---

### 🪟 Windows Manager Plugin

**New Action Plugin:** `doc/plugins/windows_manager.ahk`

Comprehensive window and tab management with vim-style navigation.

**Entry Point:** `Leader → w`

**Features:**
- **Window Control**: 
  - `wd` - Close active window
  - `wm` - Toggle minimize
  - `wM` - Force minimize
- **Window Navigation**: 
  - `wH` / `wL` - Previous/Next window
  - `wl` - Smart window list with hjkl navigation
- **Tab Manager**: 
  - `wbd` - Close tab
  - `wbn` - New tab
- **Smart List**: Uses Task View (Win+Tab) for window switching

---

### 🐛 Critical Bug Fixes

#### Layer Navigation History Preserved

**The Problem:**
```
vim layer → vim_visual layer → press ESC
❌ Before: Exited all layers (returned to base)
✅ After: Correctly returns to vim layer
```

**What Was Fixed:**
- `ReturnToPreviousLayer()` now respects layer hierarchy
- `SwitchToLayer()` auto-preserves `CurrentActiveLayer` as `PreviousLayer`
- Modal layer switching (vim visual mode, window selection) works correctly
- Navigation history maintained across all plugin transitions

#### New API Function

```autohotkey
ExitCurrentLayer()  ; Unconditional exit to base state (ignoring history)
```

Use when you explicitly want to exit all layers, not return to previous.

---

### 📝 Native Confirmation Dialogs

**Changed:** Replaced tooltip-based confirmations with standard Windows MsgBox

**Before:**
```
Tooltip confirmation → could be missed
```

**After:**
```
MsgBox with Yes/No/Cancel → keyboard accessible (Y/N/Esc)
```

**Benefits:**
- ✅ More visible and modal
- ✅ Keyboard accessible
- ✅ Simplified architecture
- ✅ Reduced code duplication

**Safety Maintained:**
- Critical actions (shutdown, restart) still require confirmation by default
- Non-destructive actions (like CloseActiveWindow) instant by default

---

### 📚 Documentation Enhancements

#### Homerow Mods Guide

**New Documentation:**
- `doc/en/user-guide/homerow-mods.md`
- `doc/es/guia-usuario/homerow-mods.md`

Comprehensive 663-line guides covering:
- What are homerow mods and why use them
- Implementation strategies (Kanata vs AutoHotkey)
- Timing configuration and tuning
- Practical examples and troubleshooting

#### Defensive Programming Patterns

**New Documentation:**
- `doc/en/developer-guide/defensive-programming-patterns.md`
- `doc/es/guia-desarrollador/patrones-programacion-defensiva.md`

323-line guides covering best practices for robust plugin development.

---

## 📦 Enhanced Plugins

### Explorer Actions Plugin

**Improvements:**
- Vim-style navigation in Windows Explorer
- Quick actions: rename (`r`), add file/folder (`a`), edit file (`e`)
- Tab manager category (`b`) with window operations
- Copy path actions category (`c`)
- Toggle hidden files (`.`)
- **Entry Point:** `Leader → e → x`

### LazyGit Plugin

**New Plugin:** `doc/plugins/lazygit_actions.ahk`

Integration with LazyGit terminal UI for Git operations.

### Git Actions Improvements

Enhanced with better error handling and feedback using new notification system.

---

## 🔧 Technical Changes

### API Enhancements

#### New Functions
```autohotkey
; Notification API
ShowTooltipFeedback(message, type := "info", timeout := 2000)

; Layer Management
ExitCurrentLayer()  ; Unconditional exit

; Kanata Management
KanataToggle()
KanataShowStatus(duration := 1500)
KanataStartWithRetry(maxRetries := 3, retryDelay := 1000)
KanataGetStatus()
KanataGetPID()
```

#### Improved Functions
```autohotkey
; SwitchToLayer now auto-preserves history
SwitchToLayer(layerName)  ; originLayer parameter optional

; ReturnToPreviousLayer now respects hierarchy
ReturnToPreviousLayer()  ; Fixed nested layer returns
```

---

## 🔄 Migration Guide

### For End Users

**No action required!** This release is 100% backward compatible.

**Optional:**
- Update your `settings.ahk` if you want custom Kanata paths:
  ```autohotkey
  HybridConfig.kanata.exePath := "C:\custom\path\kanata.exe"
  HybridConfig.kanata.autoStart := false
  ```

### For Plugin Developers

**Recommended:**
- Use new `ShowTooltipFeedback()` instead of custom tooltip code
- Migrate to `ShowUnifiedConfirmation()` for user confirmations
- Use new Kanata API functions (legacy aliases still work)

**Deprecated (still functional):**
```autohotkey
; Old → New
StartKanataIfNeeded() → KanataStart()
StopKanata() → KanataStop()
RestartKanata() → KanataRestart()
IsKanataRunning() → KanataIsRunning()
```

---

## 📊 Statistics

**Git Changes:**
- **Commits:** 20
- **Files Changed:** 43
- **Lines Added:** 4,630
- **Lines Removed:** 291
- **Net Gain:** +4,339 lines

**Files:**
- **Removed:** 7 files (VBScript legacy + references)
- **Added:** 10+ new documentation files
- **Enhanced:** 15+ existing plugins

**Code Quality:**
- **Eliminated:** VBScript dependencies
- **Reduced:** Code duplication in power actions
- **Improved:** Error handling across all plugins
- **Enhanced:** Documentation coverage

---

## 🐛 Known Issues

None reported. All automated tests passing.

---

## 🙏 Acknowledgments

This release focused on architectural improvements and developer experience while maintaining the user-facing stability and backward compatibility that HybridCapsLock users expect.

Special focus areas:
- Robustness (error handling, validation)
- Developer experience (unified APIs, better docs)
- User feedback (visual notifications, clear dialogs)

---

## 📥 Installation

### ⚠️ BREAKING CHANGE - TooltipApp Now Required

**v3.1.0 introduces a REQUIRED dependency:** TooltipApp v2.1+ is now mandatory for the notification system, welcome screen, and visual feedback. It's **included in the release package** (~156MB, self-contained .NET 6).

**Why the change?**
- Native tooltips were unreliable and lacked styling capabilities
- TooltipApp provides smooth animations, better positioning, and consistent behavior across Windows versions
- Enhanced user experience with the new animated welcome screen and layer notifications
- Unified notification API requires consistent rendering

**What's included:** The release ZIP now includes the complete `tooltip_csharp/` folder with TooltipApp.exe and all dependencies. No separate download needed.

---

### New Users

1. Download `HybridCapsLock-v3.1.0.zip` from releases (~170MB)
2. Extract to your preferred location
3. Verify `tooltip_csharp/TooltipApp.exe` exists
4. Run `HybridCapslock.ahk`
5. The dependency checker will validate all requirements

**What you'll see on first launch:**
- Animated welcome screen introducing HybridCapsLock features
- TooltipApp will start automatically in the background
- Dependency validation for AutoHotkey, Kanata, and TooltipApp

### Existing Users

**⚠️ IMPORTANT:** v3.1.0 requires TooltipApp (included in release)

1. **Backup your configuration:**
   ```bash
   # Backup your custom settings
   cp -r ahk/config/ ahk/config.backup/
   ```

2. **Extract new version** (can overwrite existing installation)

3. **CRITICAL: Verify TooltipApp is present**
   - Check that `tooltip_csharp/TooltipApp.exe` exists (~156MB)
   - This file is REQUIRED for v3.1.0+
   - It's included in the release ZIP

4. **Restore your settings:**
   ```bash
   cp ahk/config.backup/settings.ahk ahk/config/
   cp ahk/config.backup/keymap.ahk ahk/config/
   cp ahk/config.backup/kanata.kbd ahk/config/
   ```

5. **Restart HybridCapsLock**
   - You should see the new animated welcome screen
   - TooltipApp will start automatically
   - Check Task Manager to verify `TooltipApp.exe` is running

**Troubleshooting:**
- If welcome screen doesn't appear, verify TooltipApp.exe is in `tooltip_csharp/` folder
- If you get a "TooltipApp not found" error, re-download the full release ZIP
- Check dependency checker dialog for specific issues

---

**Requirements:**
- Windows 10/11 (64-bit)
- AutoHotkey v2.0+
- **TooltipApp v2.1+ (REQUIRED, ✓ included in release)** - [GitHub Repository](https://github.com/Wilberucx/TooltipApp)
- Kanata v1.6.1+ (optional, but recommended for homerow mods)
- .NET 6.0 Runtime (usually pre-installed on Windows 10/11, required by TooltipApp)

**About TooltipApp:**
TooltipApp is a self-contained .NET 6 WPF application that provides the notification and tooltip rendering system. It's developed and maintained as a separate project specifically for HybridCapsLock's visual feedback needs.

---

## 🔗 Resources

- **Documentation:** [English](doc/en/) | [Español](doc/es/)
- **Changelog:** [CHANGELOG.md](CHANGELOG.md)
- **Issues:** [GitHub Issues](https://github.com/yourusername/HybridCapsLock/issues)
- **Discussions:** [GitHub Discussions](https://github.com/yourusername/HybridCapsLock/discussions)

---

## 📝 Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete technical details.

---

**Upgrade today and experience the most robust version of HybridCapsLock yet!** 🚀
