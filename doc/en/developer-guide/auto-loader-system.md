# Auto-Loader System Usage Guide

## Overview
The HybridCapsLock auto-loader automatically manages `#Include` statements for files in:
- `src/actions/` - Action functions and helpers
- `src/layer/` - Layer implementations

## How to Use

### 🚀 Starting HybridCapsLock
```bash
# Execute this file to start HybridCapsLock:
HybridCapslock.ahk

# DON'T execute init.ahk directly!
# init.ahk is auto-managed by the preprocessor
```

### 📁 File Organization

#### Auto-Included Files
Files in these directories are automatically included:
```
src/actions/
├── my_new_action.ahk      ← Auto-included
├── helper_functions.ahk   ← Auto-included
└── no_include/
    └── work_in_progress.ahk  ← NOT included

src/layer/
├── my_new_layer.ahk       ← Auto-included
├── experimental_layer.ahk ← Auto-included
└── no_include/
    └── broken_layer.ahk      ← NOT included
```

#### Development Workflow
1. **Create new files** in `src/actions/` or `src/layer/`
2. **Run `HybridCapslock.ahk`** - auto-loader detects changes
3. **Check `init.ahk`** - new files added to AUTO-LOADED sections
4. **Your functions are now available!**

### 🚫 Excluding Files from Auto-Loading

#### Temporary Exclusion (Development)
Move files to `no_include/` folders:
```bash
# Exclude from auto-loading:
mv src/actions/broken_feature.ahk src/actions/no_include/

# Re-include when ready:
mv src/actions/no_include/fixed_feature.ahk src/actions/
```

#### Permanent Manual Control
Add manual `#Include` statements **outside** the AUTO-LOADED sections in `init.ahk`:

```autohotkey
; Manual includes (managed by you)
#Include src\actions\special_action.ahk

; ===== AUTO-LOADED ACTIONS START =====
; (Auto-managed - don't edit this section)
#Include src\actions\auto_action1.ahk
#Include src\actions\auto_action2.ahk
; ===== AUTO-LOADED ACTIONS END =====
```

## Auto-Loader Sections in init.ahk

The auto-loader manages these specific sections:

```autohotkey
; ===== AUTO-LOADED ACTIONS START =====
#Include src\actions\nvim_layer_helpers.ahk
; Files added/removed automatically
; ===== AUTO-LOADED ACTIONS END =====

; ===== AUTO-LOADED LAYERS START =====
#Include src\layer\insert_layer.ahk
#Include src\layer\visual_layer.ahk
; Files added/removed automatically
; ===== AUTO-LOADED LAYERS END =====
```

**⚠️ Important:** Don't manually edit these sections - they're overwritten automatically!

## Configuration

Enable/disable auto-loading in `src/core/auto_loader.ahk`:
```autohotkey
global AUTO_LOADER_ENABLED := true  ; Set to false to disable
```

## Memory and Registry

The auto-loader creates these files:
- `data/auto_loader_memory.json` - Tracks included files
- `data/layer_registry.ini` - Maps layer names to files

## Troubleshooting

### "Variable not used" warnings
- Make sure you're running `HybridCapslock.ahk`, not `init.ahk`
- Check that your files are in the correct directories
- Verify files aren't in `no_include/` folders

### Files not auto-included
- Check file extension is `.ahk`
- Ensure files aren't in `no_include/` folders
- Look for errors in OutputDebug logs

### Auto-loader not working
- Verify `AUTO_LOADER_ENABLED := true` in auto_loader.ahk
- Check that `HybridCapslock.ahk` includes the auto_loader
- Ensure `init.ahk` has the correct AUTO-LOADED markers

## Best Practices

1. **Always start with `HybridCapslock.ahk`**
2. **Use `no_include/` for work-in-progress files**
3. **Don't manually edit AUTO-LOADED sections**
4. **Keep manual includes outside AUTO-LOADED sections**
5. **Use descriptive filenames ending in `.ahk`**