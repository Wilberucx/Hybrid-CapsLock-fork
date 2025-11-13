# Hotkeys vs Keymaps: Understanding the Difference

## Quick Answer

**Can F24 be moved to RegisterKeymap()?**
❌ **No** - F24 must remain a direct hotkey.

**Why?**
- F24 is a **GLOBAL TRIGGER** (activates leader from outside)
- RegisterKeymap() is for **ACTIONS INSIDE LAYERS** (only work when layer is active)

## The Hierarchy

```
┌─────────────────────────────────────────────┐
│  GLOBAL SCOPE (Always listening)            │
│                                              │
│  F24::                        ← Hotkey       │
│    ActivateLeaderLayer()                     │
│                                              │
├─────────────────────────────────────────────┤
│  LEADER LAYER (Temporal, hierarchical)      │
│                                              │
│  NavigateHierarchical("leader")              │
│    's' → ActivateScrollLayer()  ← Keymap     │
│    'e' → ActivateExcelLayer()   ← Keymap     │
│                                              │
├─────────────────────────────────────────────┤
│  SCROLL LAYER (Persistent)                  │
│                                              │
│  ListenForLayerKeymaps("scroll", ...)        │
│    'j' → ScrollDown()           ← Keymap     │
│    'k' → ScrollUp()             ← Keymap     │
│    'Escape' → ScrollExit()      ← Keymap     │
│                                              │
└─────────────────────────────────────────────┘
```

## Types of Key Bindings

### 1. Hotkeys (Direct, Global)

**Definition:** Keys that work **anytime**, regardless of layer state.

**Syntax:** `Key:: Function()`

**Examples:**
```ahk
; In leader_router.ahk
F24:: ActivateLeaderLayer()  // ← Works ALWAYS (when enabled)

; In nvim_layer.ahk (legacy, being removed)
#HotIf (isNvimLayerActive)
h::VimMoveLeft()             // ← Only when nvim active
#HotIf
```

**When to use:**
- External triggers (F24 from Kanata)
- System-level shortcuts (Ctrl+Alt+Something)
- Layer activation from global scope

### 2. Keymaps (Registered, Contextual)

**Definition:** Keys that work **only inside a specific layer**.

**Syntax:** `RegisterKeymap(layer, key, desc, action, confirm)`

**Examples:**
```ahk
; In config/keymap.ahk
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false)  // ← Only in leader
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)      // ← Only in scroll
RegisterKeymap("nvim", "j", "Move Down", VimMoveDown, false)         // ← Only in nvim
```

**When to use:**
- Actions inside leader menu
- Actions inside persistent layers (scroll, nvim, excel)
- Context-dependent behaviors

## Comparison Table

| Aspect | Hotkey | Keymap |
|--------|--------|--------|
| **Scope** | Global (or #HotIf condition) | Layer-specific |
| **Activation** | Direct (AutoHotkey hotkey) | Via InputHook + ExecuteKeymapAtPath() |
| **Registration** | `Key:: Function()` | `RegisterKeymap(layer, key, ...)` |
| **Location** | In layer file (hardcoded) | In config/keymap.ahk (centralized) |
| **Tooltip** | Manual | Automatic from registry |
| **Flexibility** | Fixed at load time | Dynamic, can be modified |

## Why F24 Cannot Be a Keymap

### F24's Role
```
User presses: CapsLock + Space
    ↓
Kanata sends: F24
    ↓
AutoHotkey receives: F24 key event
    ↓
Hotkey triggers: F24:: ActivateLeaderLayer()
    ↓
Leader activates: NavigateHierarchical("leader")
    ↓
Now keymaps work: 's' → ActivateScrollLayer()
```

### If F24 Were a Keymap
```ahk
RegisterKeymap("???", "F24", "Activate Leader", ActivateLeaderLayer, false)
                 ↑
          What layer?
          
- Can't be "leader" - leader isn't active yet!
- Can't be "scroll" - scroll isn't active either!
- Can't be global - keymaps don't have global scope!
```

**F24 is the key that STARTS the keymap system.**
**It can't be inside the system it's starting.**

## The Layer Pattern

### Entry Points (Hotkeys)

```ahk
; leader_router.ahk - Entry from Kanata
F24:: ActivateLeaderLayer()

; nvim_layer.ahk - Entry from Windows hotkey (being migrated)
#HotIf (isNvimLayerActive)
h::VimMoveLeft()
#HotIf

; Better: Make Windows hotkey trigger activation
^!n:: ActivateNvimLayer()  // ← Global trigger
// Then inside nvim layer:
RegisterKeymap("nvim", "h", "Move Left", VimMoveLeft, false)
```

### Actions Inside Layers (Keymaps)

```ahk
; config/keymap.ahk - Actions INSIDE layers
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false)
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
RegisterKeymap("nvim", "h", "Move Left", VimMoveLeft, false)
```

## Migration Pattern

### Before (Old Pattern - Hotkeys)
```ahk
; scroll_layer.ahk
#HotIf (isScrollLayerActive)
j::Send("{WheelDown}")      // ← Hardcoded hotkey
k::Send("{WheelUp}")        // ← Hardcoded hotkey
#HotIf
```

### After (New Pattern - Keymaps)
```ahk
; src/actions/scroll_actions.ahk
ScrollDown() => Send("{WheelDown}")
ScrollUp() => Send("{WheelUp}")

; config/keymap.ahk
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)  // ← Centralized
RegisterKeymap("scroll", "k", "Scroll Up", ScrollUp, false)      // ← Centralized

; scroll_layer.ahk
OnScrollLayerActivate() {
    isScrollLayerActive := true
    ListenForLayerKeymaps("scroll", "isScrollLayerActive")  // ← Generic system
}
```

## Special Cases

### Leader is Special

Leader is a **temporal, hierarchical layer**:
- Activated by F24 (external trigger)
- Uses timeout
- Has subcategories (tree structure)
- Exits automatically after action

### Persistent Layers

Scroll, nvim, excel are **persistent, flat layers**:
- Activated from leader menu or other triggers
- No timeout (stay active)
- Flat structure (no subcategories)
- Exit manually with Escape or specific key

### Both Use Same System

Despite differences, both use:
- `RegisterKeymap()` for registration
- `ExecuteKeymapAtPath()` for execution
- `KeymapRegistry` for storage

## Summary

| You Want To... | Use This | Example |
|----------------|----------|---------|
| Trigger from Kanata (F24) | Direct Hotkey | `F24:: ActivateLeaderLayer()` |
| Global shortcut | Direct Hotkey | `^!n:: ActivateNvimLayer()` |
| Action in leader menu | Keymap | `RegisterKeymap("leader", "s", ...)` |
| Action in persistent layer | Keymap | `RegisterKeymap("scroll", "j", ...)` |
| Same key, different layers | Multiple Keymaps | `RegisterKeymap("nvim", "j", ...)` + `RegisterKeymap("scroll", "j", ...)` |

## Key Principle

**Hotkeys = Entry Points (triggers)**
**Keymaps = Actions Inside (behaviors)**

F24 is the front door. You can't put the front door inside the house.
