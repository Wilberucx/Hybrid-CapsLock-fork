# HybridCapsLock Layer System

> 📍 **Navigation**: [Home](../../../README.md) > User Guide > Layer System

HybridCapsLock uses a powerful "Registry Layer" system that allows you to create custom layers directly in your configuration or plugin files without needing separate files.

## Concept

A **Layer** is a state where your keyboard behaves differently. For example:

- **Scroll Layer**: `h,j,k,l` become arrow keys or scroll actions.
- **Numpad Layer**: `u,i,o` become `7,8,9`.

## How to Create a Layer

Layers can be defined in `ahk/config/keymap.ahk` or plugin files. You only need two functions:

### 1. Register the Layer

Define the layer's ID, display name, and color of pills and text (for the status indicator).

```autohotkey
; RegisterLayer(id, display_name, color_hex_background, color_hex_text)
RegisterLayer("gaming", "GAMING MODE", "#FF0000", "#000000")
```

### 2. Register Keymaps

Define what keys do when this layer is active.

```autohotkey
; RegisterKeymap(layer_id, key, description, action, auto_exit?, order)

; Simple action
RegisterKeymap("gaming", "w", "Move Forward", () => Send("{Up}"))

; Complex action (calling a function)
RegisterKeymap("gaming", "r", "Reload", ReloadWeaponFunction)

; Exit the layer (Standard pattern)
RegisterKeymap("gaming", "Escape", "Exit", ReturnToPreviousLayer)
```

### 3. Create an Entry Point

Define how to enter this layer from the "Leader" menu (or any other layer).

```autohotkey
; SwitchToLayer(layer_id) activates the layer
RegisterKeymap("leader", "g", "Gaming Mode", () => SwitchToLayer("gaming"))
```

## 🎓 Tutorial: Your First Custom Layer

Let's create a **"Quick Notes"** layer that allows you to insert text snippets quickly.

### Step 1: Create the plugin file

Create a new file: `ahk/plugins/quick_notes.ahk`

### Step 2: Register the layer

```autohotkey
; quick_notes.ahk

; 1. Register the layer with green color
RegisterLayer("notes", "QUICK NOTES", "#10B981", "#FFFFFF")

; 2. Define layer actions
RegisterKeymap("notes", "m", "Meeting Notes", () => Send("📝 Meeting Notes:`n`n"))
RegisterKeymap("notes", "t", "TODO", () => Send("☐ TODO: "))
RegisterKeymap("notes", "d", "Date", () => Send(FormatTime(, "yyyy-MM-dd")))
RegisterKeymap("notes", "s", "Signature", () => Send("`n`nBest regards,`nYour Name"))

; 3. Exit the layer
RegisterKeymap("notes", "Escape", "Exit", ReturnToPreviousLayer)
RegisterKeymap("notes", "q", "Exit", ReturnToPreviousLayer)

; 4. Create entry point from Leader
RegisterKeymap("leader", "n", "Quick Notes", () => SwitchToLayer("notes"))
```

### Step 3: Reload the system

Press `Leader → h → R` to reload HybridCapsLock.

### Step 4: Test your layer

1. Open any text editor
2. Press `Leader` (CapsLock + Space)
3. Press `n` to enter Quick Notes
4. Press `m` to insert "Meeting Notes"
5. Press `Escape` to exit

🎉 **You just created your first custom layer!**

## Advanced Features

### Hierarchical Menus

You can create nested menus using `RegisterCategoryKeymap`:

```autohotkey
; Create a category
RegisterCategoryKeymap("gaming", "w", "Weapons")

; Add items to the category
RegisterKeymap("gaming", "w", "1", "Primary", EquipPrimary)
RegisterKeymap("gaming", "w", "2", "Secondary", EquipSecondary)
```

### Dynamic Layers

Layers can be activated automatically based on the active application using the Dynamic Layer system. See [Concepts](concepts.md) for more information.

---

<div align="center">

[← Previous: Installation](installation.md) | [Back to Home](../../../README.md) | [Next: Leader Mode →](leader-mode.md)

</div>
