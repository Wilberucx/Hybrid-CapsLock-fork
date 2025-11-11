# Debug System - HybridCapsLock

## Overview

The debug system provides centralized control over development logging in HybridCapsLock. When `debug_mode` is enabled, verbose logging helps developers trace execution flow, troubleshoot issues, and understand system behavior.

## Configuration

### Enable Debug Mode

Edit `config/settings.ahk`:

```ahk
AppConfig := {
    name: "HybridCapsLock",
    version: "6.3",
    debug_mode: true,  // ← Set to true to enable debug logging
    // ...
}
```

### Runtime Toggle

Debug mode is loaded at startup from `HybridConfig.app.debug_mode`. To change it:

1. Edit `config/settings.ahk`
2. Reload the script (Leader → h → R)

## Logging Functions

Three logging functions are available (defined in `src/core/globals.ahk`):

### 1. DebugLog(message, category)

**Conditional logging** - only logs when `debug_mode = true`

Use for: Development traces, verbose information, debugging

```ahk
DebugLog("F23 received, toggling NVIM layer", "NVIM")
// Output: [NVIM] F23 received, toggling NVIM layer

DebugLog("Processing keymap: " . keymapName, "KEYMAP")
// Output: [KEYMAP] Processing keymap: leader.h.r
```

### 2. InfoLog(message, category)

**Always logs** - regardless of debug_mode

Use for: Important milestones, initialization, configuration loading

```ahk
InfoLog("Config loaded from: ahk", "INIT")
// Output: [INIT] Config loaded from: ahk

InfoLog("Layer registry loaded: " . LayerRegistry.Count . " layers", "REGISTRY")
// Output: [REGISTRY] Layer registry loaded: 6 layers
```

### 3. ErrorLog(message, category)

**Always logs** - regardless of debug_mode

Use for: Errors, warnings, critical issues

```ahk
ErrorLog("Failed to load layer: " . layerName, "LAYER")
// Output: [LAYER] Failed to load layer: custom_layer

ErrorLog("Theme loading failed: " . e.Message, "THEME")
// Output: [THEME] Theme loading failed: Too many parameters
```

## Usage Guidelines

### When to use DebugLog()

✅ **Use DebugLog() for:**
- Function entry/exit traces
- Variable state dumps
- Conditional branch information
- Loop iterations
- Development-only information

```ahk
ToggleNvimLayer() {
    DebugLog("Entering ToggleNvimLayer, current state: " . isNvimLayerActive, "NVIM")
    
    if (isNvimLayerActive) {
        DebugLog("Deactivating NVIM layer", "NVIM")
        DeactivateNvimLayer()
    } else {
        DebugLog("Activating NVIM layer", "NVIM")
        ActivateNvimLayer()
    }
}
```

### When to use InfoLog()

✅ **Use InfoLog() for:**
- System initialization
- Configuration loading
- Major state changes
- User-triggered actions
- Performance metrics

```ahk
InfoLog("HybridCapsLock v" . AppConfig.version . " starting", "INIT")
InfoLog("Loaded " . keymapCount . " keymaps from registry", "KEYMAP")
InfoLog("User activated Excel layer", "LAYER")
```

### When to use ErrorLog()

✅ **Use ErrorLog() for:**
- Exceptions caught
- File not found errors
- Invalid configuration
- Failed operations
- Runtime errors

```ahk
try {
    LoadLayerConfig(layerName)
} catch as e {
    ErrorLog("Failed to load layer config: " . e.Message, "CONFIG")
}
```

## Viewing Logs

### Windows

Use [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview) (Sysinternals):

1. Download and run DebugView
2. Enable: Capture → Capture Win32
3. Run HybridCapslock.ahk
4. See real-time logs

### VSCode

Use OutputDebug extension:

1. Install "AutoHotkey v2 Language Support"
2. Open Output panel (Ctrl+Shift+U)
3. Select "AutoHotkey v2" from dropdown
4. See logs in real-time

## Example Log Output

### With debug_mode = false (default)

```
[INIT] Config loaded from: ahk
[LayerRegistry] Registry loaded: 6 layers
[Tooltip] Theme from HybridConfig loaded successfully - 11 style properties
```

Only critical information and milestones.

### With debug_mode = true

```
[INIT] Config loaded from: ahk
[INIT] Debug mode ENABLED - verbose logging active
[NVIM] F23 received, toggling NVIM layer
[NVIM] Deactivating NVIM layer
[MAP] Unregister layer=nvim, count=45
[LAYER] Set state variable: isNvimLayerActive = false
[Tooltip] Reading theme from HybridConfig
[Tooltip] Theme name: Tokyo Night
[Tooltip] Theme from HybridConfig loaded successfully - 11 style properties
[Tooltip] Theme style applied: 11 properties
```

Detailed execution traces for debugging.

## Migration Guide

### Old Style (Direct OutputDebug)

```ahk
OutputDebug("[LAYER] Activating nvim layer\n")
```

### New Style (Using Debug System)

```ahk
DebugLog("Activating nvim layer", "LAYER")
```

### Decision Tree

```
Is this always important? (errors, init, critical info)
├─ Yes → Use InfoLog() or ErrorLog()
└─ No → Is this only useful during development?
    └─ Yes → Use DebugLog()
```

## Best Practices

1. **Use meaningful categories**: "NVIM", "LAYER", "KEYMAP", "CONFIG", etc.
2. **Keep messages concise**: One line per log
3. **Include context**: Variable values, state, parameters
4. **Use consistent formatting**: Category prefix, clear action
5. **Avoid sensitive data**: Don't log passwords, API keys, etc.

## Benefits

✅ **Performance**: No logging overhead in production (debug_mode = false)
✅ **Flexibility**: Toggle verbose logging without code changes
✅ **Clarity**: Categorized logs are easier to filter and understand
✅ **Consistency**: Standardized logging across entire codebase
✅ **Debugging**: Detailed traces help diagnose complex issues

## Future Enhancements

Planned improvements:

- [ ] Log levels (TRACE, DEBUG, INFO, WARN, ERROR)
- [ ] Log filtering by category
- [ ] Log file output (optional)
- [ ] Performance profiling integration
- [ ] Conditional breakpoints via debug flags

