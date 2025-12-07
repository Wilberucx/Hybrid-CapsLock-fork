# HybridCapsLock Layer System

> 📍 **Navegación**: [Inicio](../../../README.md) > Guía de Usuario > Sistema de Capas

HybridCapsLock uses a powerful "Registry Layer" system that allows you to create custom layers directly in your configuration or each plugins without needing separate files.

## Concept

A **Layer** is a state where your keyboard behaves differently. For example:

- **Scroll Layer**: `h,j,k,l` become arrow keys or scroll actions.
- **Numpad Layer**: `u,i,o` become `7,8,9`.

## How to Create a Layer

The layers can be defined in `ahk/config/keymap.ahk` or plugins files. You only need two functions:

### 1. Register the Layer

Define the layer's ID, display name, and color of pills and text(for the status indicator).

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

; Exit the layer (Standard pattern - returns to previous layer)
RegisterKeymap("gaming", "Escape", "Exit", ReturnToPreviousLayer)

; Alternative: Force exit to base state (ignores history)
; RegisterKeymap("gaming", "q", "Force Quit", ExitCurrentLayer)
```

### 3. Create an Entry Point

Define how to enter this layer from the "Leader" menu (or any other layer).

```autohotkey
; SwitchToLayer(layer_id) activates the layer
RegisterKeymap("leader", "g", "Gaming Mode", () => SwitchToLayer("gaming"))
```

## 🎓 Tutorial: Tu Primera Capa Personalizada

Vamos a crear una capa de **"Quick Notes"** que te permita insertar snippets de texto rápidamente.

### Paso 1: Crea el archivo del plugin

Crea un nuevo archivo: `ahk/plugins/quick_notes.ahk`

### Paso 2: Registra la capa

```autohotkey
; quick_notes.ahk

; 1. Registrar la capa con color verde
RegisterLayer("notes", "QUICK NOTES", "#10B981", "#FFFFFF")

; 2. Definir las acciones de la capa
RegisterKeymap("notes", "m", "Meeting Notes", () => Send("📝 Meeting Notes:`n`n"))
RegisterKeymap("notes", "t", "TODO", () => Send("☐ TODO: "))
RegisterKeymap("notes", "d", "Date", () => Send(FormatTime(, "yyyy-MM-dd")))
RegisterKeymap("notes", "s", "Signature", () => Send("`n`nBest regards,`nYour Name"))

; 3. Salir de la capa
RegisterKeymap("notes", "Escape", "Exit", ReturnToPreviousLayer)
RegisterKeymap("notes", "q", "Exit", ReturnToPreviousLayer)

; 4. Crear punto de entrada desde Leader
RegisterKeymap("leader", "n", "Quick Notes", () => SwitchToLayer("notes"))
```

### Paso 3: Recarga el sistema

Presiona `Leader → h → R` para recargar HybridCapsLock.

### Paso 4: Prueba tu capa

1. Abre cualquier editor de texto
2. Presiona `Leader` (CapsLock + Space)
3. Presiona `n` para entrar a Quick Notes
4. Presiona `m` para insertar "Meeting Notes"
5. Presiona `Escape` para salir

🎉 **¡Acabas de crear tu primera capa personalizada!**

## Advanced Features

### Hierarchical Menus

You can create sub-menus within a layer using `RegisterCategoryKeymap`.

```autohotkey
RegisterCategoryKeymap("gaming", "w", "Weapons", 1)
RegisterKeymap("gaming", "w", "1", "Primary", EquipPrimary, false, 1)
```

### Automatic Help

Pressing `?` (if you register it) or using the Leader menu automatically generates a help tooltip showing all available keys in the current layer.

### Status Indicator

When a layer is active, a colored "pill" appears on the screen (using the color you defined) to remind you which mode you are in.

## 🔧 Ejemplo Completo: Capa de Desarrollo

Aquí tienes un ejemplo más completo de una capa para desarrollo:

```autohotkey
; dev_tools.ahk

; Registrar capa
RegisterLayer("dev", "DEV TOOLS", "#3B82F6", "#FFFFFF")

; Categoría: Git
RegisterCategoryKeymap("dev", "g", "Git Commands", 1)
RegisterKeymap("dev", "g", "s", "Git Status", () => RunGitCommand("status"), false, 1)
RegisterKeymap("dev", "g", "p", "Git Push", () => RunGitCommand("push"), false, 1)
RegisterKeymap("dev", "g", "l", "Git Log", () => RunGitCommand("log -10"), false, 1)

; Categoría: Terminal
RegisterCategoryKeymap("dev", "t", "Terminal", 2)
RegisterKeymap("dev", "t", "o", "Open Terminal", () => Run("wt.exe"), true, 2)
RegisterKeymap("dev", "t", "c", "Open CMD", () => Run("cmd.exe"), true, 2)

; Categoría: Editors
RegisterCategoryKeymap("dev", "e", "Editors", 3)
RegisterKeymap("dev", "e", "v", "VS Code", () => Run("code ."), true, 3)
RegisterKeymap("dev", "e", "n", "Notepad++", () => Run("notepad++"), true, 3)

; Salida
RegisterKeymap("dev", "Escape", "Exit", ReturnToPreviousLayer)

; Entrada desde Leader
RegisterKeymap("leader", "d", "Dev Tools", () => SwitchToLayer("dev"))

; Función auxiliar
RunGitCommand(cmd) {
    Run("wt.exe git " . cmd)
}
```

## 🐛 Troubleshooting

### Problema: La capa no aparece en el menú

**Solución**: Verifica que hayas llamado `RegisterKeymap("leader", ...)` para crear el punto de entrada.

### Problema: Las teclas no funcionan

**Solución**: 
1. Verifica que el `layer_id` sea exactamente el mismo en `RegisterLayer` y `RegisterKeymap`
2. Recarga el sistema con `Leader → h → R`

### Problema: El color no se muestra

**Solución**: Asegúrate de usar el formato hexadecimal correcto: `"#RRGGBB"`

### Problema: Conflicto con otras capas

**Solución**: Usa `layer_id` únicos para cada capa. No uses nombres como "leader", "vim", "excel" que ya están en uso.

## Legacy vs Modern

- **Old Way**: Creating `ahk/layers/my_layer.ahk` with complex `OnActivate` hooks. (Deprecated)
- **New Way**: Just `RegisterLayer` and `RegisterKeymap` in your config. Simple, clean, and powerful.

---

## 📖 Siguiente Paso

Ahora que sabes crear capas, aprende a dominar el **Modo Líder** para organizar todas tus funcionalidades:

**→ [Modo Líder](modo-lider.md)**

---

<div align="center">

[← Anterior: Instalación](instalacion.md) | [Volver al Inicio](../../../README.md) | [Siguiente: Modo Líder →](modo-lider.md)

</div>
