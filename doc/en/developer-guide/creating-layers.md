# 🛠️ Creating Layers

This guide explains how to create and manage layers in HybridCapsLock using the centralized registry system.

## Basic Concepts

The system is based on three main functions:

1. **`RegisterLayer`**: Defines the *identity* of the layer (name, color, ID).
2. **`RegisterKeymap`**: Defines *what each key does* within that layer.
3. **`RegisterCategoryKeymap`**: Creates organized *submenus* within a layer.

---

## 1. Register the Layer (`RegisterLayer`)

Before assigning keys, you must register the layer. This is crucial because the system uses this information to:
- Display the correct name in the interface.
- Paint visual indicators (pills) with the correct color.
- **Persistence**: Save the configuration in `data/layers.json` so other tools (like the configuration UI) know this layer exists.

### Syntax

```autohotkey
RegisterLayer(layerId, displayName, color, textColor, suppressUnmapped)
```

- **`layerId`** (string): Unique internal identifier (e.g., `"gaming"`, `"photoshop"`).
- **`displayName`** (string): Human-readable name the user will see (e.g., `"GAMING MODE"`).
- **`color`** (string): Background color of the indicator in HEX format (e.g., `"#FF0000"`).
- **`textColor`** (string): Text color of the indicator (optional, default `"#ffffff"`).
- **`suppressUnmapped`** (boolean): Controls unmapped key behavior (optional, default `true`)
  - `true`: Only mapped keys work, unmapped keys are blocked (default behavior)
  - `false`: Unmapped keys pass through to the application

### Examples

```autohotkey
; Standard layer (blocks all unmapped keys)
RegisterLayer("gaming", "GAMING MODE", "#FF5555", "#FFFFFF")

; Passthrough layer (only intercepts specific keys)
RegisterLayer("vim", "VIM MODE", "#7F9C5D", "#ffffff", false)
```

**When to use `suppressUnmapped := false`:**
- Vim-style layers that only need to intercept ESC or specific commands
- Layers where you want normal typing to work while intercepting shortcuts
- Text editing contexts where blocking unmapped keys would be disruptive

---

## 2. Assign Keys (`RegisterKeymap`)

Once the layer is registered, you can assign behaviors to it.

### Syntax

```autohotkey
RegisterKeymap(layerId, key, description, action, [confirm], [order])
```

- **`layerId`**: The ID you defined in `RegisterLayer`.
- **`key`**: The key to map (e.g., `"w"`, `"Esc"`, or `"<C-s>"` for Ctrl+s).
- **`description`**: Text that will appear in the help menu/tooltip.
- **`action`**: The function to execute. Can be an existing function or a lambda `() => ...`.
- **`confirm`** (bool, optional): If `true`, will ask for confirmation before executing.
- **`order`** (int, optional): To order items in the menu (1 appears first).

### Examples

```autohotkey
; Simple action
RegisterKeymap("gaming", "w", "Move Up", () => Send("{Up}"), false, 1)

; Calling an existing function
RegisterKeymap("gaming", "r", "Reload", ReloadWeapon, false, 2)

; Action with confirmation
RegisterKeymap("gaming", "q", "Quit Game", () => WinClose("A"), true, 9)

; Using Vim-style modifier syntax (recommended for modifiers)
RegisterKeymap("gaming", "<C-s>", "Quick Save", QuickSave, false, 3)
RegisterKeymap("gaming", "<S-C-r>", "Force Reload", ForceReload, false, 4)
```

### Built-in Layer Help

Press `?` in any active layer to automatically see all registered keymaps! No configuration needed.

---

## 3. Hierarchical Menus (`RegisterCategoryKeymap`)

If you have many actions, you can organize them into submenus.

### Syntax

```autohotkey
RegisterCategoryKeymap(layerId, key, title, [order])
```

- **`layerId`**: The parent layer.
- **`key`**: The key that opens the submenu.
- **`title`**: The submenu title.

### Example

Imagine you want a "Weapons" menu within your Gaming layer:

```autohotkey
; 1. Create the category (the "folder")
RegisterCategoryKeymap("gaming", "a", "Weapons Menu", 3)

; 2. Assign keys INSIDE that category
; Note how key arguments accumulate: "a", "1"
RegisterKeymap("gaming", "a", "1", "Primary Weapon", EquipPrimary, false, 1)
RegisterKeymap("gaming", "a", "2", "Secondary Weapon", EquipSecondary, false, 2)
```

This creates a structure: `Gaming Layer` -> press `a` -> `Weapons Menu` -> press `1` -> `EquipPrimary`.

---

## 4. Activate the Layer

Finally, you need a way to enter your layer. Usually this is done from the `leader` layer (the default layer).

```autohotkey
; Helper function to switch layers
SwitchToGaming() {
    SwitchToLayer("gaming")
}

; Assign in the Leader menu
RegisterKeymap("leader", "g", "Enter Gaming Mode", SwitchToGaming, false, 5)
```

## Flow Summary

1. **Define**: `RegisterLayer("my_layer", ...)`
2. **Populate**: `RegisterKeymap("my_layer", ...)`
3. **Connect**: `RegisterKeymap("leader", ..., SwitchToLayer("my_layer"))`

And that's it! The system takes care of managing menus, tooltips, and persistence automatically.
