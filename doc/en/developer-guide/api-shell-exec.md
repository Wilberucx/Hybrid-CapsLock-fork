# Shell Exec API Reference

**Core Plugin** | `system/plugins/shell_exec.ahk`

Shell Exec provides a complete API to execute shell commands, scripts, and programs without showing console windows. It's designed as core infrastructure for other plugins and user configurations.

## 🎯 Design Philosophy

Shell Exec follows the **closure pattern** (similar to `SendInfo()`), making it perfect for use with `RegisterKeymap`:

```autohotkey
; ✅ Correct - Returns a closure
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; ❌ Incorrect - Executes immediately
RegisterKeymap("leader", "p", "e", "Explorer", ShellExecNow("explorer.exe"), false, 1)
```

## 📚 Main Functions

### `ShellExec(command, param2?, param3?, param4?)`

**Main function for use in RegisterKeymap.** Returns a closure that executes when called.

**Intelligent Parameter Detection:**
- **Window states**: `"Hide"`, `"Show"`, `"Min"`, `"Max"`, `"Minimize"`, `"Maximize"`
- **Working directory**: Any path containing `\` or `/` or drive letter (`C:`)
- **Configuration file**: Files with extensions `.kbd`, `.json`, `.cfg`, `.conf`, `.ini`, `.xml`, `.yml`, `.yaml`, `.txt`
- **Additional parameters**: Anything else is treated as a command parameter

**Parameters:**
- `command` - Command to execute (exe, bat, vbs, ahk, or direct command)
- `param2` - Optional: working directory, window state, or config file (auto-detected)
- `param3` - Optional: working directory, window state, or config file (auto-detected)
- `param4` - Optional: working directory, window state, or config file (auto-detected)

**Returns:** `Function` - Closure that executes the command when called

**Examples:**

```autohotkey
; Simple command
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; With window state
RegisterKeymap("leader", "t", "cmd", "Terminal", ShellExec("cmd.exe", "Show"), false, 1)

; With working directory
RegisterKeymap("leader", "g", "s", "Git Status", ShellExec("git status", "C:\\Projects"), false, 1)

; With configuration file
RegisterKeymap("leader", "k", "r", "Reload Kanata", ShellExec("kanata.exe", "kanata.kbd"), false, 1)

; Complex: working directory + window state
RegisterKeymap("leader", "d", "b", "Build", ShellExec("build.bat", "C:\\Projects", "Show"), false, 1)
```

---

### `ShellExecNow(command, param2?, param3?, param4?)`

**Internal function for immediate execution.** DO NOT use directly in RegisterKeymap.

**Parameters:** Same as `ShellExec()`

**Returns:** `Boolean` - `true` if execution was successful, `false` otherwise

**Use Case:** When you need immediate execution within a function body:

```autohotkey
MyCustomFunction() {
    result := ShellExecNow("git status", A_WorkingDir)
    if (result) {
        ShowCenteredToolTip("Git command executed")
    }
}
```

---

## 🎨 Variant Functions

### Window State Variants

Convenience wrappers that preset the window state:

```autohotkey
ShellExecVisible(command, workingDir := "")
ShellExecMinimized(command, workingDir := "")
ShellExecMaximized(command, workingDir := "")
```

**Examples:**

```autohotkey
RegisterKeymap("leader", "t", "p", "PowerShell", ShellExecVisible("powershell.exe"), false, 1)
RegisterKeymap("leader", "b", "c", "Compile", ShellExecMinimized("compile.bat"), false, 2)
```

---

### File Type Variants

Specialized functions for specific script types:

```autohotkey
ExecuteVBS(vbsPath, workingDir := "")
ExecuteBatch(batPath, workingDir := "")
ExecuteAHK(ahkPath, workingDir := "")
```

**Examples:**

```autohotkey
RegisterKeymap("leader", "s", "v", "Run VBS", ExecuteVBS("scripts\\setup.vbs"), false, 1)
RegisterKeymap("leader", "s", "b", "Run Batch", ExecuteBatch("scripts\\deploy.bat", "C:\\Deploy"), false, 2)
```

---

## 🔧 Advanced Functions

### `ShellExecCapture(command, workingDir?)`

Executes the command and captures its output.

**Parameters:**
- `command` - Command to execute
- `workingDir` - Optional working directory

**Returns:** `String` - Command output, or empty string on error

**Examples:**

```autohotkey
; Capture git status
output := ShellExecCapture("git status")
MsgBox(output)

; Capture with working directory
output := ShellExecCapture("dir", "C:\\Projects")

; Use in a function
ShowGitStatus() {
    status := ShellExecCapture("git status")
    ShowCenteredToolTip(status)
}
```

---

### `ShellExecWait(command, workingDir?, timeout?)`

Executes the command and waits for it to finish.

**Parameters:**
- `command` - Command to execute
- `workingDir` - Optional working directory
- `timeout` - Optional timeout in milliseconds (0 = no timeout)

**Returns:** `Integer` - Process exit code, or `-1` on error/timeout

**Examples:**

```autohotkey
; Wait for command to finish
exitCode := ShellExecWait("build.bat")
if (exitCode == 0) {
    ShowCenteredToolTip("Build successful!")
}

; With timeout (5 seconds)
exitCode := ShellExecWait("long-running-task.exe", "", 5000)
if (exitCode == -1) {
    ShowCenteredToolTip("Command timed out")
}
```

---

## 🛠️ Convenience Functions

Predefined functions for common system operations:

### System Utilities

```autohotkey
OpenExplorer(path := "")
OpenCmd(path := "")
OpenPowerShell(path := "")
OpenTaskManager()
OpenControlPanel()
OpenDeviceManager()
OpenEventViewer()
OpenSystemInfo()
OpenRegistryEditor()
```

### Network Commands

```autohotkey
FlushDNS()
RenewIP()
```

### Information Gathering

```autohotkey
CheckPing(target := "8.8.8.8")
GetSystemInfo()
ListProcesses()
```

**Examples:**

```autohotkey
; Open Explorer in specific folder
RegisterKeymap("leader", "f", "d", "Downloads", () => OpenExplorer(A_MyDocuments . "\\Downloads"), false, 1)

; Open CMD in project folder
RegisterKeymap("leader", "t", "p", "Project CMD", () => OpenCmd("C:\\Projects\\MyApp"), false, 1)

; Network diagnostics
RegisterKeymap("leader", "n", "f", "Flush DNS", FlushDNS, false, 1)
RegisterKeymap("leader", "n", "p", "Ping Google", () => MsgBox(CheckPing("8.8.8.8")), false, 2)
```

---

## 🎯 Intelligent Execution Logic

Shell Exec automatically detects file types and uses the appropriate executor:

| File Type | Executor | Example |
|-----------|----------|---------|
| `.vbs` | `wscript.exe` | `ShellExec("script.vbs")` |
| `.bat`, `.cmd` | `cmd.exe /c` | `ShellExec("build.bat")` |
| `.ahk` | `AutoHotkey.exe` | `ShellExec("helper.ahk")` |
| `.exe` | Direct execution | `ShellExec("notepad.exe")` |
| No extension | Direct execution | `ShellExec("explorer")` |
| Other | `cmd.exe /c` | `ShellExec("custom.sh")` |

---

## 📋 Best Practices

### 1. Always use ShellExec() for RegisterKeymap

```autohotkey
; ✅ Correct
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; ❌ Incorrect - executes immediately
RegisterKeymap("leader", "p", "e", "Explorer", ShellExecNow("explorer.exe"), false, 1)
```

### 2. Use Absolute Paths for Scripts

```autohotkey
; ✅ Good - absolute path
ShellExec(A_ScriptDir . "\\scripts\\deploy.bat")

; ⚠️ Risky - relative path (depends on working directory)
ShellExec("deploy.bat")
```

### 3. Specify Window State for Interactive Commands

```autohotkey
; ✅ Good - shows window for interactive commands
ShellExec("cmd.exe", "Show")
ShellExec("powershell.exe", "Show")

; ⚠️ Bad - hides window, user can't interact
ShellExec("cmd.exe")
```

### 4. Use ShellExecCapture to Process Output

```autohotkey
; ✅ Good - captures output for processing
GetGitBranch() {
    output := ShellExecCapture("git branch --show-current")
    return Trim(output)
}

; ❌ Bad - output is lost
ShellExecNow("git branch --show-current")
```

### 5. Handle Errors Gracefully

```autohotkey
; ✅ Good - checks return value
MyDeployFunction() {
    result := ShellExecNow("deploy.bat", "C:\\Projects")
    if (!result) {
        ShowCenteredToolTip("Deployment failed!")
        return false
    }
    ShowCenteredToolTip("Deployment successful!")
    return true
}
```

---

## 🔍 Debugging

Shell Exec integrates with the logging system:

```autohotkey
; Enable debug logging in your config
Log.SetLevel("DEBUG")

; Now all ShellExec calls will log:
; - Executed command
; - Working directory (if specified)
; - Success/failure status
; - Error messages
```

View logs with:
```autohotkey
Leader + h + l  ; View logs
```

---

## 🆚 Comparison with SendInfo Pattern

Both `ShellExec` and `SendInfo` use the **closure pattern** for RegisterKeymap compatibility:

| Aspect | ShellExec | SendInfo |
|--------|-----------|----------|
| **Purpose** | Execute commands/programs | Insert text |
| **Returns** | Closure (function) | Closure (function) |
| **Usage** | `ShellExec("cmd.exe")` | `SendInfo("text")` |
| **Immediate variant** | `ShellExecNow()` | `InsertTextHelper()` |
| **Intelligent detection** | Window state, paths, files | None (simple text) |

**Pattern Example:**

```autohotkey
; Both follow the same pattern
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
RegisterKeymap("leader", "i", "e", "Email", SendInfo("user@example.com"), false, 1)
```

---

## 📖 See Also

- [Plugin Architecture](plugin-architecture.md) - How plugins work in HybridCapsLock
- [SendInfo API](../../plugins/sendinfo_actions.ahk) - Similar closure pattern for text insertion
- [Creating Layers](creating-layers.md) - Using ShellExec in custom layers
