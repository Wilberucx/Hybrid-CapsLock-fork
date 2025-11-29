# Hybrid Actions API Reference

**Core Plugin** | `system/plugins/hybrid_actions.ahk`

Hybrid Actions provides functions to manage the Hybrid CapsLock system: reload, pause, restart Kanata, and access configuration and logs.

## 🎯 Design Philosophy

Hybrid Actions is a **core plugin** that:
- Provides atomic system management functions
- Integrates with C# tooltips when available
- Manages the lifecycle of Kanata and AutoHotkey
- Implements pause/resume system

## 📚 Main Functions

### `ReloadHybridScript()`

Completely reloads the system (Kanata + AutoHotkey).

**Parameters:** None

**Returns:** Void (terminates current script)

**Behavior:**
1. Shows "RELOADING..." notification
2. Stops TooltipApp if running
3. Restarts Kanata if it was running
4. Restarts AutoHotkey
5. Exits current script

**Example:**

```autohotkey
; Reload complete system
ReloadHybridScript()

; Use in keymap
RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 5)
```

**When to Use:**
- After editing configuration files
- After installing/removing plugins
- After changing keymaps
- To apply changes in kanata.kbd

---

### `RestartKanataOnly()`

Restarts only Kanata, without restarting AutoHotkey.

**Parameters:** None

**Returns:** Void

**Behavior:**
1. Shows "RESTARTING KANATA..." notification
2. Calls `RestartKanata()` (core function)
3. Shows "KANATA RESTARTED" notification

**Example:**

```autohotkey
; Restart only Kanata
RestartKanataOnly()

; Use in keymap
RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 4)
```

**When to Use:**
- After editing kanata.kbd
- When Kanata stops responding
- To apply changes in Kanata configuration

---

### `ExitHybridScript()`

Completely exits the system (Kanata + AutoHotkey).

**Parameters:** None

**Returns:** Void (terminates script)

**Behavior:**
1. Shows "EXITING..." notification
2. Stops TooltipApp if running
3. Stops Kanata if it was running
4. Exits AutoHotkey

**Example:**

```autohotkey
; Exit the system
ExitHybridScript()

; Use in keymap
RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 6)
```

**When to Use:**
- To completely close the system
- Before updating system files
- For troubleshooting

---

### `PauseHybridScript()`

Pauses/resumes the system with configurable auto-resume.

**Parameters:** None

**Returns:** Void

**Behavior:**
1. If not paused: Suspends AutoHotkey and schedules auto-resume
2. If paused: Resumes immediately

**Global Variables:**
- `hybridPauseActive` - Boolean indicating if paused
- `hybridPauseMinutes` - Minutes until auto-resume (default: 10)

**Example:**

```autohotkey
; Pause/resume system
PauseHybridScript()

; Use in keymap
RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)

; Configure auto-resume time in settings.ahk
global hybridPauseMinutes := 15  ; 15 minutes
```

**States:**
- `"SUSPENDED Xm — press Leader to resume"` - System paused
- `"RESUMED"` - Manually resumed
- `"RESUMED (auto)"` - Automatically resumed

**When to Use:**
- During presentations
- When you need to use the keyboard normally
- To avoid accidental activations

---

### `OpenConfigFolder()`

Opens the configuration folder in Explorer.

**Parameters:** None

**Returns:** Void

**Behavior:**
- Opens `ahk/config/` in Windows Explorer

**Example:**

```autohotkey
; Open config folder
OpenConfigFolder()

; Use in keymap
RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 3)
```

---

### `ViewLogFile()`

Opens the log file in Notepad.

**Parameters:** None

**Returns:** Void

**Behavior:**
1. Checks if `hybrid_log.txt` exists
2. If it exists, opens it in Notepad
3. If it doesn't exist, shows tooltip

**Example:**

```autohotkey
; View logs
ViewLogFile()

; Use in keymap
RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 2)
```

---

## 🎨 Usage Patterns

### Pattern 1: Development Workflow

```autohotkey
; 1. Edit keymap.ahk
; 2. Save changes
; 3. Press Leader → h → R (Reload)
; 4. Test changes
```

### Pattern 2: Change Kanata Configuration

```autohotkey
; 1. Press Leader → h → c (Open Config)
; 2. Edit kanata.kbd
; 3. Save changes
; 4. Press Leader → h → k (Restart Kanata Only)
; 5. Test changes
```

### Pattern 3: Debugging

```autohotkey
; 1. Press Leader → h → l (View Log)
; 2. Review errors
; 3. Make corrections
; 4. Press Leader → h → R (Reload)
```

### Pattern 4: Pause During Presentation

```autohotkey
; Before presenting
; 1. Press Leader → h → p (Pause)
; 2. Present normally
; 3. Press Leader → h → p (Resume) or wait for auto-resume
```

---

## 📋 Best Practices

### 1. Use Restart Kanata Only When Possible

```autohotkey
; ✅ Good - only changes in kanata.kbd
; Leader → h → k (faster)

; ⚠️ Unnecessary - only changes in kanata.kbd
; Leader → h → R (restarts everything)
```

### 2. Configure Auto-Resume Appropriately

```autohotkey
; In settings.ahk or config
global hybridPauseMinutes := 10  ; For general use
global hybridPauseMinutes := 60  ; For long presentations
global hybridPauseMinutes := 5   ; For short pauses
```

### 3. Review Logs Regularly

```autohotkey
; Especially after:
; - Installing new plugins
; - Configuration changes
; - Unexpected behavior
```

---

## 🔍 Debugging

### View System State

```autohotkey
; Check if Kanata is running
if (IsKanataRunning()) {
    MsgBox("Kanata is running")
}

; Check pause state
global hybridPauseActive
if (hybridPauseActive) {
    MsgBox("System is paused")
}
```

### Logs

```autohotkey
; Enable detailed logging
Log.SetLevel("DEBUG")

; hybrid_actions functions log:
; - Operation start
; - Kanata state
; - Errors
```

---

## 🆚 Function Comparison

| Function | Restarts AHK | Restarts Kanata | Closes All |
|----------|--------------|-----------------|------------|
| `ReloadHybridScript()` | ✅ | ✅ | ❌ |
| `RestartKanataOnly()` | ❌ | ✅ | ❌ |
| `ExitHybridScript()` | ❌ | ❌ | ✅ |
| `PauseHybridScript()` | Suspends | ❌ | ❌ |

---

## 🎯 Integration with Tooltips

All functions automatically detect if TooltipApp is available:

```autohotkey
; With TooltipApp
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try ShowCSharpStatusNotification("HYBRID", "RELOADING...")
}
; Without TooltipApp
else {
    ShowCenteredToolTip("RELOADING...")
}
```

This allows functions to work with or without the C# tooltip system.

---

## 📖 See Also

- [Plugin Architecture](plugin-architecture.md) - How core plugins work
- [Keymap System](keymap-system.md) - How to register these functions
- [Installation](../user-guide/installation.md) - Initial system configuration
