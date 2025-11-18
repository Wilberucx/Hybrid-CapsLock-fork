# Confirmation System

The HybridCapsLock confirmation system provides unified confirmation dialogs that automatically adapt to the active tooltip system (native or C#).

## 📋 Overview

The system automatically detects if C# tooltips are enabled and presents confirmations using the appropriate interface:

- **With C# tooltips**: Styled menu with visual theme
- **Without C# tooltips**: Simple native tooltip as fallback

## ⚙️ Configuration

### Enable C# Tooltips

To use styled confirmations, edit `config/settings.ahk`:

```ahk
TooltipConfig := {
    enabled: true,        // ← Change to true to enable
    handles_input: true,  // ← Allows Y/N hotkeys
    exe_path: "src/ui/TooltipApp.exe"
}
```

### Recommended Configuration

```ahk
TooltipConfig := {
    enabled: true,
    handles_input: true,
    exe_path: "src/ui/TooltipApp.exe"
}
```

## 🎯 Actions Requiring Confirmation

The following actions show confirmation dialogs:

| Action | Combination | Description |
|--------|------------|-------------|
| **Reload Script** | `leader + h + R` | Restarts HybridCapsLock |
| **Exit Script** | `leader + h + e` | Closes HybridCapsLock |
| **Git Add All** | `leader + c + g + a` | Executes git add . |
| **Git Pull** | `leader + c + g + p` | Executes git pull |
| **Sign Out** | `leader + o + o` | Signs out current user |
| **Restart System** | `leader + o + r` | Restarts the system |
| **Shutdown System** | `leader + o + S` | Shuts down the system |

## 🎨 User Interfaces

### Confirmation with C# Tooltips

When C# tooltips are enabled:

```
┌─────────────────────────┐
│     CONFIRM ACTION      │
├─────────────────────────┤
│ ▶ Restart System        │
│ ─────────────────────── │
│ Y ✓ Confirm             │
│ N ✗ Cancel              │
└─────────────────────────┘
```

**Controls:**
- `Y` or `y` → Confirm action
- `N`, `n`, or `Esc` → Cancel action
- Timeout: 10 seconds

### Confirmation with Native Tooltips

When C# tooltips are disabled:

```
Execute: Restart System?
[y: Yes] [n/Esc: No]
```

**Controls:**
- `Y` or `y` → Confirm action  
- `N`, `n`, or `Esc` → Cancel action
- Timeout: 3 seconds

## 🔧 Technical Implementation

### Main Function

```ahk
ShowUnifiedConfirmation(description)
```

This function:
1. **Detects** the active tooltip system
2. **Presents** the appropriate interface
3. **Captures** user input
4. **Returns** `true` (confirmed) or `false` (cancelled)

### Detection Logic

```ahk
// Detection priority:
if (IsSet(HybridConfig) && HybridConfig.tooltips.enabled) {
    // Use C# tooltips
} else if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    // Use C# tooltips (legacy)
} else {
    // Use native tooltips
}
```

### Code Locations

- **Main function**: `src/core/keymap_registry.ahk` → `ShowUnifiedConfirmation()`
- **Integration**: `src/core/keymap_registry.ahk` → `ExecuteKeymapAtPath()`
- **C# Hotkeys**: `src/ui/tooltip_csharp_integration.ahk` → `HandleConfirmationSelection()`

## 🐛 Debug and Logging

The system includes detailed logging for diagnostics:

```
[2024-12-19 10:15:30] ShowUnifiedConfirmation -> C# Confirmation | Restart System
[2024-12-19 10:15:32] HandleConfirmationSelection -> C# Hotkey Result | User selected | Result: CONFIRMED
```

**Log file**: `tmp_rovodev_confirmation_debug.log` (if debug is enabled)

## ⚠️ Troubleshooting

### Issue: Confirmation Not Appearing

**Cause**: Keymap doesn't have `confirm: true`

**Solution**: Check in `config/keymap.ahk`:
```ahk
RegisterKeymap("category", "key", "Description", ActionFunction, true) // ← confirm flag
```

### Issue: "Unknown Option" with C# Tooltips

**Cause**: `handles_input: false` in configuration

**Solution**: Change to `handles_input: true` in `config/settings.ahk`

### Issue: Wrong Position

**Cause**: Position configuration in theme

**Solution**: Check theme configuration in `config/colorscheme.ahk`

## 📚 See Also

- [Keymap System](keymap-system.md)
- [Tooltip System](../developer-guide/tooltip-system.md)
- [Configuration](../getting-started/configuration.md)