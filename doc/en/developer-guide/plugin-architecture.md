# Plugin System Architecture

This document explains the technical details of how the plugin system works in HybridCapsLock, designed for developers who want to extend the system's functionality.

## 🔄 Lifecycle and Loading

The plugin system is based on a fundamental concept: **Automatic Global Loading**.

### 1. Detection (Auto-Loader)
When starting `HybridCapslock.ahk`, the `system/core/auto_loader.ahk` module scans two directories for `.ahk` files:
1. `ahk/plugins/` (User Plugins - High Priority)
2. `system/plugins/` (System Plugins - Low Priority)

### 🔌 Core Plugins vs Optional Plugins

The system distinguishes between two types of plugins:

**Core Plugins** (`system/plugins/`)
- **Purpose**: Provide reusable APIs and infrastructure for other plugins
- **Characteristics**:
  - DO NOT register keymaps directly
  - Provide global functions that other plugins can use
  - Load automatically with the system
  - Examples: `shell_exec.ahk`, `hybrid_actions.ahk`, `scroll_actions.ahk`

**Optional Plugins** (`doc/plugins/` → `ahk/plugins/`)
- **Purpose**: Provide user-facing functionality and specific keymaps
- **Characteristics**:
  - Register keymaps for the end user
  - Use core plugin APIs
  - User decides which to install
  - Examples: `shell_shortcuts.ahk`, `git_actions.ahk`, `adb_actions.ahk`

**Separation Example:**
```autohotkey
; ❌ BEFORE: shell_exec.ahk (all-in-one)
; - Provides ShellExec() API
; - Registers keymaps for programs
; - Mixes infrastructure with user-facing features

; ✅ NOW: Separated into two files
; system/plugins/shell_exec.ahk (CORE)
ShellExec(command, params*) {
    return () => ShellExecNow(command, params*)
}

; doc/plugins/shell_shortcuts.ahk (OPTIONAL)
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
```

**Advantages of this separation:**
- Core plugins remain clean and focused on API
- Users can customize optional plugins without touching the core
- Better modularity and maintainability
- Follows the separation of concerns principle

### 🕵️‍♂️ Priority Mechanism (Shadowing)

Priority is based on **FILE NAME**.

- **Case 1: Unique File**
  - If `ahk/plugins/my_plugin.ahk` exists, it loads.
  - If `system/plugins/core.ahk` exists, it loads.

- **Case 2: Name Conflict (Override)**
  - If both `ahk/plugins/git.ahk` AND `system/plugins/git.ahk` exist...
  - ⚠️ The system **IGNORES** the file from `system/` and only loads from `ahk/`.
  - This allows you to completely "replace" a system plugin by simply creating a file with the same name in your user folder.

### 2. Injection (init.ahk)
The auto-loader dynamically modifies the `init.ahk` file to inject `#Include` directives for each found plugin.

```autohotkey
; init.ahk (Auto-generated)
; ===== AUTO-LOADED PLUGINS START =====
#Include ahk\\plugins\\my_plugin.ahk
#Include system\\plugins\\git_actions.ahk
; ===== AUTO-LOADED PLUGINS END =====
```

### 3. Execution (Global Scope)
When AHK executes `init.ahk`, it processes these `#Include` **before** loading user configuration (`ahk/config/keymap.ahk`).

**Critical Consequence:**
All functions, classes, and global variables defined in your plugins load into the **Global Namespace**.

## 🧠 Why is this important?

### Immediate Availability
Since plugins load *before* `keymap.ahk`, you can use their functions directly in your mappings without manually importing them.

**Example:**
- `ahk/plugins/my_plugin.ahk` defines `MyFunction()`.
- `ahk/config/keymap.ahk` can call `RegisterKeymap(..., MyFunction)` directly.

**Example with Core Plugin:**
- `system/plugins/shell_exec.ahk` defines `ShellExec()` (core API).
- `doc/plugins/shell_shortcuts.ahk` uses `ShellExec()` to register keymaps.
- `ahk/config/keymap.ahk` can also use `ShellExec()` directly.

```autohotkey
; In ahk/config/keymap.ahk
RegisterKeymap("leader", "p", "v", "VS Code", ShellExec("code.exe"), false, 1)
RegisterKeymap("leader", "i", "e", "Email", SendInfo("user@example.com"), false, 1)
```

### Decoupling
This allows your key configuration (`keymap.ahk`) to be independent of function implementation.
- If you delete the plugin, the function ceases to exist, but `keymap.ahk` doesn't "break" the initial load (it will only fail if you try to execute that specific key).
- If you comment out the mapping in `keymap.ahk`, the function still exists in memory, ready to be used by another component (e.g., a console command or another layer).

## ⚠️ Best Practices

Since everything shares the same global namespace, follow these rules to avoid conflicts:

1. **Unique Names**: Use prefixes if possible.
   - ✅ `GitCommit()`, `VimMoveH()`
   - ❌ `Commit()`, `Move()`
2. **Global Variables**: Minimize their use. If you need state, use static classes or `static` variables inside functions.
3. **Don't Block**: Code outside functions in a plugin executes at startup. Don't put `MsgBox` or infinite loops in the main script body.

## 🧪 Example Flow

1. You create `ahk/plugins/spotify.ahk` with the `SpotifyPlay()` function.
2. You restart HybridCapsLock.
3. The system detects the file and injects `#Include ahk\\plugins\\spotify.ahk` into `init.ahk`.
4. Now `SpotifyPlay()` is a global system function.
5. In `keymap.ahk`, you assign `Leader + s + p` to `SpotifyPlay`.
6. Done!

## 🛠️ Debugging

If a plugin function doesn't seem to be available:
1. Check `init.ahk` and look for the `AUTO-LOADED PLUGINS` section. Does your file appear there?
2. If it doesn't appear, make sure the file is in `ahk/plugins/` and has the `.ahk` extension.
3. Check the debug log (if enabled) to see if there were syntax errors when loading the plugin.
