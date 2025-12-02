# Core Plugins Index

**Core Plugins** are fundamental system components that provide reusable APIs and infrastructure for other plugins.

## 🎯 Core Plugin Characteristics

- ✅ **DO NOT register keymaps** directly
- ✅ **Provide global functions** that other plugins can use
- ✅ **Load automatically** with the system
- ✅ **Location**: `system/plugins/`
- ✅ **Complete documentation** with examples

## 📚 Available Core Plugins

### 1. Shell Exec
**File**: `system/plugins/shell_exec.ahk`  
**Documentation**: [API Reference](api-shell-exec.md)

**Purpose**: Execute shell commands, scripts, and programs without showing console windows.

**Main Functions**:
- `ShellExec(command, params*)` - Execute command (returns closure)
- `ShellExecNow(command, params*)` - Execute immediately
- `ShellExecCapture(command, workingDir)` - Capture output
- `ShellExecWait(command, workingDir, timeout)` - Wait for completion
- Convenience functions: `OpenExplorer()`, `OpenCmd()`, `FlushDNS()`, etc.

**Usage Example**:
```autohotkey
; In an optional plugin
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
RegisterKeymap("leader", "t", "cmd", "Terminal", ShellExec("cmd.exe", "Show"), false, 2)
```

**Used By**: Almost all optional plugins (shell_shortcuts, git_actions, adb_actions, etc.)

---

### 2. Context Utils
**File**: `system/plugins/context_utils.ahk`  
**Documentation**: [API Reference](api-context-utils.md)

**Purpose**: Detect system context (active paths, window types, processes) and persist data in INI files.

**Main Functions**:
- `GetActiveExplorerPath()` - Get active Explorer path
- `IsTerminalWindow()` - Check if it's a terminal
- `GetPasteShortcut()` - Get appropriate paste shortcut
- `GetActiveProcessName()` - Get active process name
- `LoadHistory(key, iniFile)` - Load history from INI file
- `SaveHistory(key, value, iniFile)` - Save history to INI file

**Usage Example**:
```autohotkey
; Open terminal in current folder
OpenTerminalHere() {
    path := GetActiveExplorerPath()
    if (path != "") {
        ShellExecNow("wt.exe", path, "Show")
    }
}

; Smart paste
SmartPaste() {
    Send(GetPasteShortcut())  ; ^+v in terminals, ^v in other apps
}

; Persist history
iniFile := "data\\my_plugin.ini"
SaveHistory("RecentItems", "C:\\Users\\Documents", iniFile)
history := LoadHistory("RecentItems", iniFile)
```

**Used By**: folder_actions, adb_actions, dynamic_layer, custom plugins

---

### 3. Dynamic Layer
**File**: `system/plugins/dynamic_layer.ahk`  
**Documentation**: [API Reference](api-dynamic-layer.md)

**Purpose**: Automatically activate layers based on the active application.

**Main Functions**:
- `ActivateDynamicLayer()` - Activate layer for current process
- `ToggleDynamicLayer()` - Enable/disable system
- `ShowBindProcessGui()` - GUI to assign layers to processes
- `ShowBindingsListGui()` - View configured bindings

**Usage Example**:
```autohotkey
; Configured in keymap.ahk
#HotIf (DYNAMIC_LAYER_ENABLED)
F23:: ActivateDynamicLayer()  ; Tap CapsLock activates process layer
#HotIf

; Binding management
RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 7)
RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 9)
```

**Used By**: Layer system, user configuration

---

### 4. Hybrid Actions
**File**: `system/plugins/hybrid_actions.ahk`  
**Documentation**: [API Reference](api-hybrid-actions.md)

**Purpose**: Manage system lifecycle (reload, pause, restart).

**Main Functions**:
- `ReloadHybridScript()` - Reload complete system
- `RestartKanataOnly()` - Restart only Kanata
- `ExitHybridScript()` - Exit the system
- `PauseHybridScript()` - Pause/resume with auto-resume
- `OpenConfigFolder()` - Open config folder
- `ViewLogFile()` - View log file

**Usage Example**:
```autohotkey
; Configured in keymap.ahk
RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 5)
RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 4)
RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
```

**Used By**: System management, debugging

---

### 5. Welcome Screen
**File**: `system/plugins/welcome_screen.ahk`  
**Documentation**: [README](../../../system/plugins/no_include/welcome_screen_README.md)

**Purpose**: Display an animated welcome screen on startup with system information and tips.

**Main Functions**:
- `ShowWelcomeScreen()` - Display welcome screen with system info
- `ShowQuickTip(message, icon)` - Show temporary notification tooltip

**Features**:
- Auto-start on script load (800ms delay)
- NerdFont icon support
- Fade animations
- Configurable via `HybridConfig.welcome`
- Can be disabled in configuration

**Usage Example**:
```autohotkey
; Show a quick notification
ShowQuickTip("✓ Settings saved!", "")

; Welcome screen runs automatically on startup
; To disable, set in config:
; HybridConfig.welcome := { enabled: false }
```

**Used By**: Startup experience, user notifications

---

## 🔄 How Core Plugins Work

### Load Cycle

```
1. HybridCapslock.ahk starts
   ↓
2. system/core/auto_loader.ahk scans system/plugins/
   ↓
3. Injects #Include in init.ahk
   ↓
4. Core plugins load into global space
   ↓
5. Functions available to all plugins
```

### Usage Pattern

```autohotkey
; Core Plugin (system/plugins/my_core.ahk)
MyCoreFunction(param) {
    return () => MyCoreFunctionNow(param)
}

MyCoreFunctionNow(param) {
    ; Implementation
}

; Optional Plugin (doc/plugins/my_plugin.ahk)
RegisterKeymap("leader", "x", "My Action", MyCoreFunction("value"), false, 1)

; User Config (ahk/config/keymap.ahk)
RegisterKeymap("leader", "y", "Other Action", MyCoreFunction("other"), false, 2)
```

---

## 🎨 Common Patterns

### Pattern 1: Combine Context + Shell Exec

```autohotkey
; Open terminal in current folder
OpenTerminalHere() {
    path := GetActiveExplorerPath()  ; Context Utils
    if (path != "") {
        return ShellExec("wt.exe", path, "Show")  ; Shell Exec
    }
    return ShellExec("wt.exe", "", "Show")
}
```

### Pattern 2: Dynamic Layer + Context

```autohotkey
; Activate layer based on process
ActivateDynamicLayer() {
    process := GetActiveProcessName()  ; Context Utils
    layerId := GetLayerForProcess(process)  ; Dynamic Layer
    if (layerId != "") {
        SwitchToLayer(layerId)
    }
}
```

### Pattern 3: System Management

```autohotkey
; Development workflow
; 1. Edit code
; 2. ReloadHybridScript()  ; Hybrid Actions
; 3. ViewLogFile()  ; Hybrid Actions (if errors)
```

---

## 📋 Core Plugin Comparison

| Plugin | Return Type | Main Use | Complexity |
|--------|-------------|----------|------------|
| **shell_exec** | Closures | Execute commands | Medium |
| **context_utils** | Data (strings, bools, arrays) | Detect context and persist data | Low |
| **dynamic_layer** | Actions (void) | Layer management | High |
| **hybrid_actions** | Actions (void) | System management | Low |

---

## 🆚 Core vs Optional Plugins

| Aspect | Core Plugins | Optional Plugins |
|--------|--------------|------------------|
| **Location** | `system/plugins/` | `doc/plugins/` → `ahk/plugins/` |
| **Purpose** | Provide APIs | Provide user-facing functionality |
| **Keymaps** | DO NOT register | DO register |
| **Loading** | Automatic | User decides |
| **Examples** | shell_exec, context_utils | git_actions, folder_actions |

---

## 🔍 When to Create a Core Plugin

Create a core plugin if:

✅ **Provides reusable functionality** that multiple plugins will need  
✅ **Is fundamental infrastructure** for the system  
✅ **Has NO specific user keymaps**  
✅ **Follows the closure pattern** for RegisterKeymap

**Example**: If multiple plugins need to execute commands → `shell_exec.ahk` (core)

Create an optional plugin if:

✅ **Provides specific functionality** for end users  
✅ **Registers keymaps** that the user will use directly  
✅ **Uses core plugin APIs** to implement functionality  
✅ **Is optional** based on user needs

**Example**: Shortcuts to open programs → `shell_shortcuts.ahk` (optional)

---

## 📖 Additional Resources

### Architecture Documentation
- [Plugin Architecture](plugin-architecture.md) - How the plugin system works
- [Auto-Loader System](auto-loader-system.md) - How plugins load
- [Keymap System](keymap-system.md) - How to register keymaps

### Development Guides
- [Creating Layers](creating-layers.md) - Use core plugins to create layers
- [API References](#) - Detailed documentation for each core plugin

### Usage Examples
- [Optional Plugin Catalog](../../plugins/README.md) - See how core plugins are used
- [Folder Actions](../../plugins/folder_actions.ahk) - Example using context_utils
- [Shell Shortcuts](../../plugins/shell_shortcuts.ahk) - Example using shell_exec

---

## 🎯 Next Steps

1. **Review API References** for each core plugin
2. **Study optional plugins** to see usage patterns
3. **Experiment** combining core plugins in your own plugins
4. **Contribute** by creating new optional plugins that use these APIs

---

<div align="center">

**Ready to create your own plugin?**

[Creating Layers →](creating-layers.md) | [Architecture →](plugin-architecture.md)

</div>
