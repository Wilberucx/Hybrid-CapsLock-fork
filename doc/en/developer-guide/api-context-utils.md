# Context Utils API Reference

**Core Plugin** | `system/plugins/context_utils.ahk`

Context Utils provides centralized functions to detect system context, such as active paths, window types, and processes. It's designed as core infrastructure for other plugins that need context-aware behavior.

## 🎯 Design Philosophy

Context Utils is a **core plugin** that does NOT register keymaps. It only provides utility functions that other plugins can use to detect the current system context.

## 📚 Main Functions

### `GetActiveExplorerPath()`

Returns the path of the directory currently open in Windows Explorer.

**Parameters:** None

**Returns:** `String` - Path of the active directory, or empty string (`""`) if no Explorer window is active

**Example:**

```autohotkey
; Get current Explorer path
path := GetActiveExplorerPath()
if (path != "") {
    MsgBox("Active folder: " . path)
} else {
    MsgBox("No Explorer window active")
}

; Use in a plugin to open terminal in current folder
OpenTerminalHere() {
    path := GetActiveExplorerPath()
    if (path != "") {
        ShellExecNow("wt.exe", path, "Show")
    } else {
        ShellExecNow("wt.exe", "", "Show")
    }
}

RegisterKeymap("leader", "t", "h", "Terminal Here", OpenTerminalHere, false, 1)
```

---

### `IsTerminalWindow()`

Checks if the active window is a known terminal emulator.

**Supported Terminals:**
- Windows Terminal
- Mintty (Git Bash)
- Alacritty
- WezTerm
- CMD (legacy)
- PowerShell (legacy)

**Parameters:** None

**Returns:** `Boolean` - `true` if active window is a terminal, `false` otherwise

**Example:**

```autohotkey
; Check if we're in a terminal
if (IsTerminalWindow()) {
    MsgBox("You're in a terminal")
} else {
    MsgBox("You're not in a terminal")
}

; Use for conditional behavior
SmartPaste() {
    if (IsTerminalWindow()) {
        Send("^+v")  ; Ctrl+Shift+V in terminals
    } else {
        Send("^v")   ; Ctrl+V in other apps
    }
}
```

---

### `GetPasteShortcut()`

Returns the appropriate paste shortcut for the active window.

**Parameters:** None

**Returns:** `String` - `"^+v"` for terminals, `"^v"` for everything else

**Example:**

```autohotkey
; Smart paste
SmartPaste() {
    Send(GetPasteShortcut())
}

RegisterKeymap("vim", "p", "Paste", SmartPaste, false, 1)
```

---

### `GetActiveProcessName()`

Returns the process name of the active window.

**Parameters:** None

**Returns:** `String` - Process name (e.g., `"notepad.exe"`, `"Code.exe"`), or empty string (`""`) if cannot detect

**Example:**

```autohotkey
; Get active process
process := GetActiveProcessName()
MsgBox("Active process: " . process)

; Use for app-specific behavior
IsVSCode() {
    return (GetActiveProcessName() == "Code.exe")
}

; Use with Dynamic Layer
ActivateDynamicLayer() {
    process := GetActiveProcessName()
    if (process == "EXCEL.EXE") {
        SwitchToLayer("excel")
    } else if (process == "Code.exe") {
        SwitchToLayer("vscode")
    }
}
```

---

### `LoadHistory(key, iniFile)`

Loads history stored in an INI file.

**Parameters:**
- `key` (String): Key in the "History" section of the INI file
- `iniFile` (String): Path to the INI file

**Returns:** `Array` - Array of strings with history, or empty array if doesn't exist

**Example:**

```autohotkey
; Load folder history
GetMyDataPath() {
    dataPath := "data\\my_plugin.ini"
    SplitPath(dataPath, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    return dataPath
}

iniFile := GetMyDataPath()
history := LoadHistory("CustomFolders", iniFile)

for index, path in history {
    MsgBox("Folder " . index . ": " . path)
}
```

---

### `SaveHistory(key, value, iniFile)`

Saves a value to the history in an INI file, moving it to the top if it already exists.

**Parameters:**
- `key` (String): Key in the "History" section of the INI file
- `value` (String): Value to add to history
- `iniFile` (String): Path to the INI file

**Behavior:**
- Removes the value if it already exists in history
- Inserts the value at the first position
- Maintains a maximum of 10 items
- Automatically saves to the INI file

**Example:**

```autohotkey
; Save folder to history
iniFile := GetMyDataPath()
SaveHistory("CustomFolders", "C:\\Users\\Documents", iniFile)

; History now has "C:\\Users\\Documents" at position 1

; Load and show updated history
history := LoadHistory("CustomFolders", iniFile)
MsgBox("Last folder: " . history[1])
```

---

## 🎨 Common Usage Patterns

### Pattern 1: Context-Aware Behavior

```autohotkey
; Function that adapts based on application
SmartAction() {
    process := GetActiveProcessName()
    
    if (process == "EXCEL.EXE") {
        Send("{Down}")  ; In Excel, navigate cell
    } else if (IsTerminalWindow()) {
        Send("^c")      ; In terminal, copy
    } else {
        Send("^v")      ; In other apps, paste
    }
}
```

### Pattern 2: Open Terminal in Current Folder

```autohotkey
; Plugin: terminal_here.ahk
OpenTerminalInCurrentFolder() {
    path := GetActiveExplorerPath()
    
    if (path != "") {
        ; Explorer is active, open terminal there
        ShellExecNow("wt.exe", path, "Show")
    } else {
        ; No Explorer, open in home
        ShellExecNow("wt.exe", A_MyDocuments, "Show")
    }
}

RegisterKeymap("leader", "t", "h", "Terminal Here", OpenTerminalInCurrentFolder, false, 1)
```

### Pattern 3: Copy Current Path

```autohotkey
; Plugin: copy_path.ahk
CopyCurrentPath() {
    path := GetActiveExplorerPath()
    
    if (path != "") {
        A_Clipboard := path
        ShowCenteredToolTip("Path copied: " . path)
        SetTimer(() => RemoveToolTip(), -2000)
    } else {
        ShowCenteredToolTip("No Explorer window active")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

RegisterKeymap("leader", "f", "y", "Copy Path", CopyCurrentPath, false, 1)
```

---

## 📋 Best Practices

### 1. Always Check Return Values

```autohotkey
; ✅ Good - check before using
path := GetActiveExplorerPath()
if (path != "") {
    ; Use path
}

; ❌ Bad - assumes there's always a value
path := GetActiveExplorerPath()
Run("explorer.exe " . path)  ; Fails if path is empty
```

### 2. Use IsTerminalWindow() for Specific Shortcuts

```autohotkey
; ✅ Good - adapts shortcut based on context
Paste() {
    Send(GetPasteShortcut())
}

; ❌ Bad - assumes it's always Ctrl+V
Paste() {
    Send("^v")  ; Doesn't work in terminals
}
```

### 3. Combine with ShellExec for Maximum Flexibility

```autohotkey
; ✅ Good - uses context + shell exec
OpenTerminalHere() {
    path := GetActiveExplorerPath()
    if (path != "") {
        return ShellExec("wt.exe", path, "Show")
    }
    return ShellExec("wt.exe", "", "Show")
}
```

---

## 🔍 Debugging

Context Utils integrates with the logging system:

```autohotkey
; Enable debug logging
Log.SetLevel("DEBUG")

; Test functions
process := GetActiveProcessName()
Log.d("Active process: " . process, "CONTEXT")

path := GetActiveExplorerPath()
Log.d("Explorer path: " . path, "CONTEXT")

isTerminal := IsTerminalWindow()
Log.d("Is terminal: " . isTerminal, "CONTEXT")
```

---

## 🆚 Comparison with Other Core Plugins

| Plugin | Purpose | Returns |
|--------|---------|---------|
| **context_utils** | Detect system context and persist data | Information (strings, booleans, arrays) |
| **shell_exec** | Execute commands | Closures for RegisterKeymap |
| **dynamic_layer** | Activate layers by process | Actions (void) |
| **hybrid_actions** | System management | Actions (void) |

---

## 📖 See Also

- [Plugin Architecture](plugin-architecture.md) - How core plugins work
- [Shell Exec API](api-shell-exec.md) - Execute commands with context
- [Dynamic Layer](../../../system/plugins/dynamic_layer.ahk) - Use GetActiveProcessName() for layers
- [Folder Actions Plugin](../../plugins/folder_actions.ahk) - Example using GetActiveExplorerPath()
