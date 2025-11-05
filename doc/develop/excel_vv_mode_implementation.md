# Excel VV Mode Implementation - Visual Selection Mode

## Overview

The VV (Visual-Visual) mode in Excel Layer provides Vim-like visual selection using `hjkl` keys, similar to the visual mode in Nvim Layer. This document explains the implementation, challenges encountered, and the solution.

## Problem Statement

Initially, the VV mode was activating correctly (showing "VISUAL SELECTION MODE ON") but the `hjkl` keys were **not** being captured by the VV mode hotkeys. Instead, they were sending regular arrow keys without Shift, meaning **no selection was being extended**.

### Root Cause

The issue was a **hotkey context precedence conflict**. The `hjkl` keys were defined in two different `#HotIf` contexts:

1. **Excel Layer Normal Context** (lines ~16-50):
   ```autohotkey
   #HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed()) : false)
   h::Send("{Left}")
   j::Send("{Down}")
   k::Send("{Up}")
   l::Send("{Right}")
   ```

2. **VV Mode Context** (lines ~139-156):
   ```autohotkey
   #HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && VVModeActive) : false)
   h::ExcelVVDirectionalSend("Left")
   j::ExcelVVDirectionalSend("Down")
   k::ExcelVVDirectionalSend("Up")
   l::ExcelVVDirectionalSend("Right")
   ```

**The problem:** The first context did NOT check for `VVModeActive`, so it was capturing the keys even when VV mode was active. AutoHotkey gives precedence to the first matching context, so the VV mode hotkeys were never reached.

## Solution

Add `&& !VVModeActive` to all Excel Layer normal contexts to ensure they are **disabled** when VV mode is active.

### Changes Made

#### 1. Main Excel Layer Context (Line 16)

**Before:**
```autohotkey
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed()) : false)
```

**After:**
```autohotkey
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VVModeActive) : false)
```

This affects all hotkeys in the main Excel Layer section, including:
- `hjkl` (navigation)
- `y` (yank/copy)
- `p` (paste)
- Numpad mappings
- Other Excel functions

#### 2. V Logic Start Context (Line 79)

**Before:**
```autohotkey
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VLogicActive) : false)
v::VLogicStart()
```

**After:**
```autohotkey
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VLogicActive && !VVModeActive) : false)
v::VLogicStart()
```

This prevents accidentally re-entering V Logic while in VV mode.

#### 3. Help Toggle Context (Line 81)

**Before:**
```autohotkey
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed()) : false)
```

**After:**
```autohotkey
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VVModeActive) : false)
```

This ensures help can still be toggled but won't interfere with VV mode.

## VV Mode Implementation Details

### Activation Flow

1. Press `v` (enters V Logic mini-layer)
2. Press `v` again (activates VV mode)
3. `VVModeActive` is set to `true`
4. All Excel Layer normal hotkeys are disabled (`!VVModeActive` condition)
5. VV mode hotkeys become active (`VVModeActive` condition)

### Key Features

#### Navigation with Selection (hjkl)

Uses the helper function `ExcelVVDirectionalSend()` which:
- Detects current modifiers (Ctrl, Alt, Shift)
- **Always adds Shift** to extend selection
- Respects modifier combinations (e.g., Ctrl+Shift for block selection)

```autohotkey
ExcelVVDirectionalSend(dir) {
    global VVModeActive
    mods := ""
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("Shift", "P")
        mods .= "+"
    
    ; Always ensure Shift is present in VV mode
    if (VVModeActive && !InStr(mods, "+"))
        mods .= "+"
    
    SendInput(mods . "{" . dir . "}")
}
```

#### Vim-like Actions in VV Mode

- **`y`** - Yank (copy) selection and exit VV mode
- **`d`** - Delete selection and exit VV mode
- **`p`** - Paste over selection and exit VV mode
- **`Esc`** or **`Enter`** - Exit VV mode without action

### Debug Features

During implementation, debug output was added:
- Tooltip showing what command is being sent (e.g., "VV: +{Left}")
- OutputDebug logging for troubleshooting
- F9 debug hotkey to check variable states (in V Logic context)

These can be removed or kept for troubleshooting.

## Comparison with Nvim Layer

The VV mode implementation mirrors the visual mode in `nvim_layer.ahk`:

### Similarities
- Uses a helper function (`ExcelVVDirectionalSend` vs `NvimDirectionalSend`)
- Automatically adds Shift modifier for selection
- Respects other modifiers (Ctrl, Alt)
- Uses `#InputLevel 2` for VV mode context

### Differences
- Excel VV mode has explicit actions (`y`, `d`, `p`) that exit the mode
- Nvim visual mode is more complex with multiple visual modes (character, line, block)
- Excel VV mode uses `SendInput()` for more reliable input in Excel

## Testing Checklist

To verify VV mode is working correctly:

- [ ] Activate Excel Layer (Leader → n)
- [ ] Enter VV mode (press `vv`)
- [ ] See tooltip: "VISUAL SELECTION MODE ON - VVModeActive=1"
- [ ] Press `h` - selection extends left, tooltip shows "VV: +{Left}"
- [ ] Press `j` - selection extends down, tooltip shows "VV: +{Down}"
- [ ] Press `k` - selection extends up, tooltip shows "VV: +{Up}"
- [ ] Press `l` - selection extends right, tooltip shows "VV: +{Right}"
- [ ] Press `Ctrl+h` - selection extends by block/word left
- [ ] Press `y` - selection is copied, VV mode exits
- [ ] Re-enter VV mode, select cells, press `d` - selection is deleted
- [ ] Re-enter VV mode, select cells, press `p` - paste over selection
- [ ] Press `Esc` - VV mode exits without action
- [ ] Normal Excel Layer keys (`hjkl`, `y`, `p`) work when NOT in VV mode

## Known Limitations

1. **Excel must not be in edit mode** - If you're editing a cell (pressed F2), the arrow keys will move the cursor within the cell instead of selecting. Press Esc first to exit edit mode.

2. **Selection behavior depends on Excel settings** - Excel's selection behavior can be affected by:
   - Extend Selection mode (F8)
   - Add to Selection mode (Shift+F8)
   - Scroll Lock state

3. **Debug tooltips may be distracting** - Consider removing or making them optional for production use.

## Future Enhancements

Potential improvements:
- [ ] Add visual line mode (`V`) - select entire rows
- [ ] Add visual block mode (`Ctrl+v`) - columnar selection
- [ ] Add more Vim-like commands (`x` for cut, `c` for change, etc.)
- [ ] Visual feedback in tooltip showing selection size/range
- [ ] Option to disable debug tooltips via config

## Related Files

- `src/layer/excel_layer.ahk` - Main implementation
- `src/layer/nvim_layer.ahk` - Reference implementation for visual mode
- `config/excel_layer.ini` - Configuration for Excel Layer
- `doc/EXCEL_LAYER.md` - User documentation for Excel Layer

## Lessons Learned

### AutoHotkey Context Precedence

When multiple `#HotIf` contexts match, AutoHotkey uses the **first matching context** in the order they appear in the script. To implement "sub-modes" like VV mode:

1. **Explicitly exclude the sub-mode** from parent contexts using `&& !SubModeActive`
2. **Use higher InputLevel** for sub-mode contexts (`#InputLevel 2`)
3. **Test context matching** with debug outputs and tooltips

### Debugging Techniques Used

1. **Visible tooltips** - Show what's being sent in real-time
2. **OutputDebug** - Log to debugger (use DebugView or VSCode)
3. **State inspection hotkey** - F9 to check all variable states
4. **Simplified test scripts** - Isolated test files to verify behavior

### Importance of Mode Exclusion

The key insight: **Parent contexts must explicitly exclude child mode states**, otherwise they will capture hotkeys before the child context can. This is especially important when:
- Using the same keys in different modes
- Implementing mini-layers or sub-modes
- Building hierarchical input systems

## Author Notes

This implementation was developed to provide a consistent Vim-like experience across both Nvim and Excel layers. The VV mode makes cell selection more efficient and intuitive for users familiar with Vim motions.

**Date:** 2024
**Version:** HybridCapsLock v2.0+

## Modern Tooltip Integration (Update)

### C# Tooltip System Integration

The VV mode now uses the modern C# tooltip system for a consistent visual experience across all layers.

#### New Functions Added to `tooltip_csharp_integration.ahk`

1. **`ShowExcelVVModeToggleCS(isActive)`** - Shows/hides the VV mode indicator
   - When active: Displays "Excel VV" with help hint (?)
   - When inactive: Restores the Excel layer tooltip
   - Uses "warning" accent color to distinguish from normal Excel mode
   - Persistent (timeout_ms: 0) while VV mode is active

2. **`ShowExcelVVHelpCS()`** - Displays VV mode help menu
   - Lists all available commands (h/j/k/l for selection, y/d/p for actions)
   - Uses bottom-right list layout for consistency
   - Auto-dismisses after configured timeout (default 8000ms)

3. **Updated `ShowExcelHelpCS()`** - Added "vv:Visual mode" to Excel help

#### VV Mode Tooltip Behavior

**Activation (`vv`):**
```autohotkey
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try ShowExcelVVModeToggleCS(true)
} else {
    ToolTip("VISUAL SELECTION MODE (hjkl to select, Esc/Enter to exit)")
}
```

**Exit (Esc/Enter):**
```autohotkey
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try ShowExcelVVModeToggleCS(false)  // Restores Excel layer tooltip
} else {
    ToolTip("VISUAL SELECTION OFF")
}
```

**Copy Action (`y`):**
```autohotkey
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try ShowCopyNotificationCS()  // Uses standard copy notification
} else {
    ToolTip("COPIED - VV MODE OFF")
}
```

**Delete Action (`d`):**
```autohotkey
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try {
        ShowCSharpStatusNotification("EXCEL VV", "DELETED")
        SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
    }
}
```

**Paste Action (`p`):**
```autohotkey
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try {
        ShowCSharpStatusNotification("EXCEL VV", "PASTED")
        SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
    }
}
```

**Help (`?` / Shift+/):**
```autohotkey
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try ShowExcelVVHelpCS()
} else {
    ToolTip("VV HELP:...")
}
```

### Visual Consistency

The VV mode tooltips maintain visual consistency with:
- **Nvim Layer** - Same bottom-right list layout and help hint (?)
- **Visual Mode** - Similar activation/deactivation pattern
- **Excel Layer** - Seamless transition between Excel and VV tooltips
- **System Notifications** - Copy/Delete/Paste use standard notification style

### Fallback Support

All tooltip functions include native fallback when C# tooltips are disabled:
- Simple `ToolTip()` calls with centered positioning
- Automatic cleanup with `SetTimer(() => ToolTip(), -duration)`
- Same functionality, different visual presentation

### Configuration

VV mode tooltips respect the global tooltip configuration from `config/configuration.ini`:
- `[Tooltips] enabled` - Enable/disable C# tooltips
- `[Tooltips] status_notification_timeout` - Duration for status messages
- `[Tooltips] options_timeout` - Duration for help menus
- `[TooltipTheme]` - Colors, positioning, opacity, etc.

### Benefits of Modern Tooltips

✅ **Professional appearance** - Consistent with Nvim/Visual layers
✅ **Better visibility** - Themed colors and configurable positioning
✅ **Reduced clutter** - Smart tooltip replacement instead of overlap
✅ **User-friendly** - Integrated help system with `?` key
✅ **Configurable** - Respects user theme and timeout preferences
✅ **Graceful degradation** - Falls back to native tooltips if C# app unavailable

### Updated User Experience Flow

1. User activates Excel Layer → Sees "Excel" tooltip with (? help)
2. User presses `vv` → Tooltip changes to "Excel VV" with warning accent
3. User presses `?` → Full help menu appears temporarily
4. User selects cells with `hjkl` → No tooltip spam, clean experience
5. User presses `y` → "COPIED" notification appears briefly
6. VV mode exits → Excel layer tooltip automatically restored

This creates a smooth, professional experience that feels like a unified system rather than disconnected features.

