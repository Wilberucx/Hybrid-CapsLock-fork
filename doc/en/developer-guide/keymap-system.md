# Unified Keymap System

## Philosophy

**One system** for all types of layers:

- **Leader** (temporal/hierarchical) - Navigation with timeout
- **Persistent Layers** (RegisterLayers) - No timeout, remain active

Both use the **same infrastructure**:

- `KeymapRegistry` - Single storage
- `ExecuteKeymapAtPath()` - Single execution
- `RegisterKeymap()` - Single registration

## Components

### 1. keymap_registry.ahk

#### For Leader

```ahk
RegisterKeymap("leader", "s", "Scroll Layer", ActivateScrollLayer, false)
NavigateHierarchical("leader")  // Loop with timeout
```

#### For Persistent Layers

```ahk
RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false)
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
ListenForLayerKeymaps("scroll", "isScrollLayerActive")  // Loop without timeout
```

### 2. Vim-Style Modifier Keys (New!)

You can now use Vim-style modifier syntax for better readability:

```ahk
; Vim-style syntax (recommended for modifiers)
RegisterKeymap("leader", "<C-s>", "Save All", SaveAllFunc, false, 1)
RegisterKeymap("leader", "<S-C-a>", "Advanced", AdvancedFunc, false, 2)
RegisterKeymap("leader", "<A-S-k>", "Special", SpecialFunc, false, 3)

; Works with triggers too
RegisterTrigger("<C-F1>", ShowHelp, "AppActive")
```

**Modifier Mapping:**
- `C` → Ctrl (`^`)
- `S` → Shift (`+`)
- `A` → Alt (`!`)

The UI will display the original readable syntax (`<C-a>`) while execution uses AutoHotkey format (`^a`).

### 3. Dynamic Layer Help

Press `?` in any active layer to see all available keybindings automatically:

```ahk
; No configuration needed! Works in all layers automatically
; While in any layer, press ? to see help
; Press Esc to close help (layer remains active)
```

Categories also show help after 500ms timeout for better discoverability.

### 4. Key Function: ListenForLayerKeymaps()

```ahk
ListenForLayerKeymaps(layerName, layerActiveVarName) {
    Loop {
        // Check if layer is still active
        if (!%layerActiveVarName%)
            break

        // Wait for input (no timeout)
        ih := InputHook("L1", "{Escape}")
        ih.Wait()

        key := ih.Input

        // Execute using the SAME infrastructure as leader
        ExecuteKeymapAtPath(layerName, key)
    }
}
```

#### config/keymap.ahk

File where keymaps are centralized.

```ahk
InitializeCategoryKeymaps() {
    // ... other keymaps ...

    ; Scroll layer keymaps (actions from scroll_actions.ahk)
    RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false)
    RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
    RegisterKeymap("scroll", "k", "Scroll Up", ScrollUp, false)
    RegisterKeymap("scroll", "l", "Scroll Right", ScrollRight, false)
    RegisterKeymap("scroll", "s", "Exit", ScrollExit, false)
    RegisterKeymap("scroll", "Escape", "Exit", ScrollExit, false)
}
```

## Differences: Leader vs Persistent Layers

| Aspect | Leader | Persistent Layers |
| --- | --- | --- |
| **Duration** | Temporal (with timeout) | Permanent (until exit) |
| **Navigation** | Hierarchical (categories) | Flat (only actions) |
| **Function** | `NavigateHierarchical()` | `ListenForLayerKeymaps()` |
| **Timeout** | Yes (configurable) | No |
| **Storage** | `KeymapRegistry["leader"]` | `KeymapRegistry["scroll"]` |
| **Execution** | `ExecuteKeymapAtPath()` | `ExecuteKeymapAtPath()` |

## Separation: Actions vs Layers

### Key Concept

**Layers = Context** | **Plugins = Reusable functions**

#### src/actions/ - Generic reusable actions

```ahk
; scroll_actions.ahk - Can be used in any layer
ScrollUp() => Send("{WheelUp}")
ScrollDown() => Send("{WheelDown}")
```

### Same Key, Different Layers, Different Actions

```ahk
; 'i' does different things depending on context
RegisterKeymap("nvim", "i", "Insert Mode", NvimEnterInsert, false)
RegisterKeymap("excel", "i", "Edit Cell", ExcelEditCell, false)  // ← F2 + exit layer
RegisterKeymap("visual", "i", "Inner Object", VisualInnerObject, false)

; 'j' also depends on context
RegisterKeymap("nvim", "j", "Move Down", VimMoveDown, false)
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
```

**The layer defines WHAT each key does.**

## Dynamic Layer Creation

Use `RegisterLayer(id, display_name, color_hex_background, color_hex_text)` to create new layers, more information in [layers](../user-guide/layers.md)

## Declarative Trigger Registration

Use `RegisterTrigger()` for clean, declarative global hotkey registration:

```ahk
; Old way (verbose, not recommended)
#SuspendExempt
#HotIf (LeaderLayerEnabled)
F24:: ActivateLeaderLayer()
#HotIf
#SuspendExempt False

; New way (declarative, recommended)
RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")
RegisterTrigger("F23", ActivateDynamicLayer, "DYNAMIC_LAYER_ENABLED")

; Works with modifier syntax too
RegisterTrigger("<C-F1>", ShowHelp)
```

**Benefits:**
- Cleaner, more readable code
- Automatic SuspendExempt handling
- Consistent with `RegisterKeymap()` style
- Supports Vim-style modifier syntax

## Hotkeys vs Keymaps

### Why can't F24 be a keymap?

**F24 is the EXTERNAL TRIGGER** that activates leader from outside the system:

```
Kanata (hardware) → F24 → ActivateLeaderLayer() → NavigateHierarchical()
                     ↑                               ↑
                  HOTKEY                         USES KEYMAPS
```

**Keymaps only work INSIDE active layers:**

```ahk
; F24 MUST be trigger (global entry point)
RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")

; 's' CAN be keymap (action inside leader)
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false)  // ← Uses the system
```

**Rule:**

- **Triggers = Entry points** (activate layers from outside)
- **Keymaps = Functions** (work inside layers)

F24 is the entry door. The door can't be inside the house it opens.
