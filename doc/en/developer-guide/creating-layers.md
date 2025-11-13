# Creating New Persistent Layers

## Overview

This guide explains how to create new persistent layers using the unified keymap system.

## Quick Start

### 1. Use the Template

Copy the layer template:
```bash
cp src/layer/_layer_template.ahk src/layer/mylayer_layer.ahk
```

### 2. Replace Placeholders

Replace these placeholders in your new file:
- `LAYER_NAME` → Your layer name in lowercase (e.g., `scroll`, `nvim`, `excel`)
- `LAYER_DISPLAY` → Friendly display name (e.g., `Scroll Layer`, `Nvim Layer`)

**Example for "scroll" layer:**
```ahk
# Before
global LAYER_NAMELayerEnabled := true
global isLAYER_NAMELayerActive := false
ActivateLAYER_NAMELayer()

# After
global scrollLayerEnabled := true
global isScrollLayerActive := false
ActivateScrollLayer()
```

### 3. Quick Replace Script

Use this sed command (Linux/WSL/Git Bash):
```bash
# Replace LAYER_NAME with "myname" and LAYER_DISPLAY with "MyName Layer"
sed -e 's/LAYER_NAME/myname/g' -e 's/LAYER_DISPLAY/MyName Layer/g' \
    src/layer/_layer_template.ahk > src/layer/myname_layer.ahk
```

## File Structure

### Layer File (`src/layer/{name}_layer.ahk`)

```ahk
; Configuration
global {name}LayerEnabled := true
global is{Name}LayerActive := false

; Activation
Activate{Name}Layer(originLayer := "leader") {
    SwitchToLayer("{name}", originLayer)
}

; Hooks
On{Name}LayerActivate() {
    is{Name}LayerActive := true
    ListenForLayerKeymaps("{name}", "is{Name}LayerActive")
    is{Name}LayerActive := false
}

On{Name}LayerDeactivate() {
    is{Name}LayerActive := false
}

; Actions
{Name}Exit() {
    is{Name}LayerActive := false
    ReturnToPreviousLayer()
}
```

### Actions File (`src/actions/{name}_actions.ahk`)

Create reusable actions:
```ahk
; Generic actions that can be used from any layer
{Name}DoSomething() {
    ; Implementation
}
```

### Keymap Registration (`config/keymap.ahk`)

Register keymaps in `InitializeCategoryKeymaps()`:
```ahk
; In leader menu
RegisterKeymap("leader", "x", "My Layer", ActivateMyNameLayer, false)

; Layer keymaps (inline or separate function)
RegisterKeymap("myname", "h", "Do Something", MyNameDoSomething, false)
RegisterKeymap("myname", "Escape", "Exit Layer", MyNameExit, false)
```

## Naming Conventions

| Element | Pattern | Example (scroll) | Example (nvim) |
|---------|---------|------------------|----------------|
| Layer name (lowercase) | `{name}` | `scroll` | `nvim` |
| Display name (Title Case) | `{Name}` | `Scroll` | `Nvim` |
| Enabled flag | `{name}LayerEnabled` | `scrollLayerEnabled` | `nvimLayerEnabled` |
| Active state | `is{Name}LayerActive` | `isScrollLayerActive` | `isNvimLayerActive` |
| Activation function | `Activate{Name}Layer()` | `ActivateScrollLayer()` | `ActivateNvimLayer()` |
| Activate hook | `On{Name}LayerActivate()` | `OnScrollLayerActivate()` | `OnNvimLayerActivate()` |
| Deactivate hook | `On{Name}LayerDeactivate()` | `OnScrollLayerDeactivate()` | `OnNvimLayerDeactivate()` |
| Exit action | `{Name}Exit()` | `ScrollExit()` | `NvimExit()` |
| Generic actions | `{Name}{Action}()` | `ScrollUp()` | `NvimMoveLeft()` |

## Integration Checklist

- [ ] Create layer file from template
- [ ] Replace LAYER_NAME and LAYER_DISPLAY placeholders
- [ ] Implement layer-specific actions
- [ ] Create reusable actions in `src/actions/`
- [ ] Register keymaps in `config/keymap.ahk`
- [ ] Add layer activation to leader menu (if needed)
- [ ] Test layer activation
- [ ] Test all keymaps
- [ ] Test layer exit (Escape and custom exit key)
- [ ] Test layer switching from other layers

## Example: Creating "Excel" Layer

### Step 1: Create from template
```bash
sed -e 's/LAYER_NAME/excel/g' -e 's/LAYER_DISPLAY/Excel Layer/g' \
    src/layer/_layer_template.ahk > src/layer/excel_layer.ahk
```

### Step 2: Create actions (src/actions/excel_actions.ahk)
```ahk
ExcelEditCell() => Send("{F2}")
ExcelInsertRow() => Send("^{+}")
ExcelDeleteRow() => Send("^{-}")
```

### Step 3: Add layer-specific control
```ahk
; In excel_layer.ahk
ExcelExit() {
    global isExcelLayerActive
    isExcelLayerActive := false
    ReturnToPreviousLayer()
}
```

### Step 4: Register keymaps (config/keymap.ahk)
```ahk
InitializeCategoryKeymaps() {
    ; ... other registrations ...
    
    ; Excel layer activation
    RegisterKeymap("leader", "e", "Excel Layer", ActivateExcelLayer, false)
    
    ; Excel layer keymaps
    RegisterKeymap("excel", "i", "Edit Cell", ExcelEditCell, false)
    RegisterKeymap("excel", "o", "Insert Row", ExcelInsertRow, false)
    RegisterKeymap("excel", "d", "Delete Row", ExcelDeleteRow, false)
    RegisterKeymap("excel", "Escape", "Exit Excel", ExcelExit, false)
}
```

## How It Works

### 1. Layer Activation
```
User: Leader + e
  → ActivateExcelLayer("leader")
  → SwitchToLayer("excel", "leader")
  → OnExcelLayerActivate()
  → ListenForLayerKeymaps("excel", "isExcelLayerActive")
```

### 2. Key Press Handling
```
User: i (while excel layer active)
  → ListenForLayerKeymaps() captures input
  → ExecuteKeymapAtPath("excel", "i")
  → Finds RegisterKeymap("excel", "i", ..., ExcelEditCell, ...)
  → Executes ExcelEditCell()
```

### 3. Layer Exit
```
User: Escape
  → ListenForLayerKeymaps() captures Escape
  → ExecuteKeymapAtPath("excel", "Escape")
  → Executes ExcelExit()
  → Sets isExcelLayerActive = false
  → ListenForLayerKeymaps() loop breaks
  → Returns to previous layer
```

## Key vs Layer Actions

### Same Key, Different Layers

The same key can do different things in different layers:

```ahk
; 'i' in different contexts
RegisterKeymap("nvim", "i", "Insert Mode", NvimEnterInsert, false)
RegisterKeymap("excel", "i", "Edit Cell", ExcelEditCell, false)
RegisterKeymap("visual", "i", "Inner Object", VisualInnerObject, false)
```

When 'i' is pressed:
- In nvim layer → NvimEnterInsert()
- In excel layer → ExcelEditCell()
- In visual layer → VisualInnerObject()
- In no layer → 'i' types normally

## Tips

1. **Keep layer files minimal** - Only layer control logic
2. **Put reusable actions in actions/** - Can be used from multiple layers
3. **One action, one function** - Don't combine multiple actions
4. **Test exit paths** - Always test Escape and custom exit keys
5. **Document keymaps** - Clear descriptions in RegisterKeymap()
6. **Use consistent naming** - Follow the conventions table above

## Troubleshooting

### Layer doesn't activate
- Check `ActivateXxxLayer()` is called correctly
- Verify `SwitchToLayer("name", "origin")` uses correct layer name
- Check OutputDebug logs for errors

### Keymap doesn't work
- Verify `RegisterKeymap("layername", "key", ...)` layer name matches
- Check action function exists and is spelled correctly
- Look for typos in function names
- Check OutputDebug for "Layer not found" messages

### Layer doesn't exit
- Verify Escape keymap is registered
- Check exit function sets `isXxxLayerActive = false`
- Ensure `ReturnToPreviousLayer()` is called
- Check for errors in OutputDebug

### Keys work but no confirmation
- Check the `confirm` parameter in RegisterKeymap
- `false` = no confirmation
- `true` = asks for confirmation

## Reference

- Template: `src/layer/_layer_template.ahk`
- Example: `src/layer/scroll_layer.ahk`
- System docs: `KEYMAP_SYSTEM_UNIFIED.md`
