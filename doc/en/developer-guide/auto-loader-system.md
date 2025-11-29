# Auto-Loader System - Usage Guide

## Overview

The **Auto-Loader** is a system that automatically detects and loads code modules without needing to manually edit `#Include` files. It greatly simplifies development by allowing you to add new functionality just by creating a file in the correct location.

## 🎯 Benefits

### Before Auto-Loader ❌

```ahk
; You had to manually edit init.ahk:
#Include ahk/plugins/my_plugin.ahk
#Include ahk/plugins/my_other_plugin.ahk
```

### With Auto-Loader ✅

1. Create `ahk/plugins/my_plugin.ahk`
2. Reload (`leader -> h -> R`)
3. Done! It's automatically loaded

## 📂 Monitored Folders

The auto-loader searches for `.ahk` files in:

- **`ahk/plugins`** - Plugins to extend functionality
- **`system/plugins`** - Core system plugins necessary for the system

## 🚫 `no_include/` Folder

To **disable** a module without deleting it:

```
ahk/plugins/
├── my_plugin.ahk          ✅ Loads
├── my_other_plugin.ahk    ✅ Loads
└── no_include/
    └── experimental_plugin.ahk    ❌ Does NOT load
```

This is useful for:

- **Iterative development** - Temporarily disable work-in-progress code
- **Debugging** - Isolate problems by disabling modules
- **Backup** - Save old versions without deleting them

## 🔧 How It Works

### 1. File Scanning

At startup, `system/core/auto_loader.ahk` executes:

```ahk
; Search all .ahk in ahk/plugins/
Loop Files, ahk/plugins/*.ahk {
    if (InStr(A_LoopFileFullPath, "no_include")) {
        continue  ; Skip files in no_include/
    }
    #Include %A_LoopFileFullPath%
}
```

### 2. Automatic Inclusion

Each found file is included with `#Include`, equivalent to:

```ahk
#Include ahk/plugins/my_plugin.ahk
#Include ahk/plugins/my_other_plugin.ahk
; ... etc
```

## 📝 Conventions

### File Names

- **Lowercase snake_case**: `my_module.ahk`, `git_actions.ahk`
- **No spaces or special characters**

### Plugin Structure

Each plugin should follow this structure:

```
Insert plugin structure here
```

### Module Won't Load

**Checklist:**

1. ✅ Is the file in `ahk/plugins/`?
2. ✅ Does the file end in `.ahk`?
3. ✅ Is it NOT inside `no_include/`?
4. ✅ Did you reload after creating the file? (`leader -> h -> R`)
5. ✅ Does the file have valid syntax? (syntax errors prevent loading)
6. ✅ Does the file have Register Keymaps or Register Categories that don't conflict with existing keybindings?

### Syntax Errors

If a file has errors, **the entire system fails to load**. To debug:

1. Move the file to `no_include/`
2. Reload
3. Fix the error
4. Move the file back
5. Reload

## 🚀 Use Cases

### Sharing Plugins

Plugins are **self-contained**. To share:

1. Copy the `.ahk` file
2. Recipient places it in `ahk/plugins`
3. Reload
4. It works!

No need to modify other files.

## ⚠️ Limitations

### Load Order

Files load in **alphabetical order**. If a module depends on another:

```ahk
; a_base.ahk loads before z_dependent.ahk
; Use numeric prefixes if you need fine control:
; 01_plugin.ahk
```

### Circular Dependencies

Avoid circular dependencies:

❌ **Bad:**

```
plugin_a.ahk calls FunctionB()
plugin_b.ahk calls FunctionA()
```

_Recommendations: If they depend on another plugin, make sure to comment it at the beginning of the plugin file_

✅ **Good:**

```
plugin_a.ahk uses system/plugins/helpers_2.ahk
plugin_b.ahk uses system/plugins/helpers.ahk
core/helpers.ahk doesn't depend on layers
```

### Performance

Each additional file increases load time. For large projects:

- Use `no_include/` for unused modules
- Consider combining small related plugins
- Consider using core plugin functions in `system/plugins/`
- Overhead is minimal (<100ms per file on modern hardware)
