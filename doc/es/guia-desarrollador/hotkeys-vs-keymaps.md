# Hotkeys vs Keymaps: Entendiendo la Diferencia

## Resumen

En HybridCapslock existen dos formas de definir atajos de teclado: **Hotkeys tradicionales de AHK** y **Keymaps declarativos**. Esta guía explica cuándo usar cada uno.

---

## 🎯 Hotkeys Tradicionales (AHK)

### ¿Qué son?

Los hotkeys tradicionales son la forma nativa de AutoHotkey de definir atajos:

```ahk
; Hotkey tradicional
^c::Send {Ctrl down}c{Ctrl up}  ; Ctrl+C

; Hotkey con función
F1::MiFuncion()

; Hotkey contextual
#IfWinActive ahk_exe chrome.exe
^t::MsgBox("Ctrl+T en Chrome")
#IfWinActive
```

### ¿Cuándo usar?

✅ **Usar Hotkeys cuando:**
- El atajo es **global** (funciona en todo el sistema)
- El atajo es **simple** (una tecla → una acción)
- No necesitas tooltips o documentación
- Es un atajo de activación de capa (ej: `F13::ToggleNvimLayer()`)

### Ventajas
- ✅ Directo y simple
- ✅ Documentación oficial abundante
- ✅ Contexto con `#IfWinActive`
- ✅ Modificadores nativos (`^`, `!`, `+`, `#`)

### Desventajas
- ❌ No auto-documentado
- ❌ Sin tooltips automáticos
- ❌ Difícil gestionar muchos atajos
- ❌ Sin validación de conflictos

---

## 🗺️ Keymaps Declarativos

### ¿Qué son?

Los keymaps son parte del sistema declarativo de HybridCapslock:

```ahk
RegisterKeymaps("nvim", [
    {key: "h", desc: "Mover izquierda", action: "Send {Left}"},
    {key: "j", desc: "Mover abajo", action: "Send {Down}"},
    {key: "k", desc: "Mover arriba", action: "Send {Up}"},
    {key: "l", desc: "Mover derecha", action: "Send {Right}"}
])
```

### ¿Cuándo usar?

✅ **Usar Keymaps cuando:**
- El atajo es parte de una **capa modal**
- Necesitas **tooltips** que muestren las teclas disponibles
- Quieres **auto-documentación**
- Tienes **muchos atajos relacionados** (>5)
- La capa se activa/desactiva dinámicamente

### Ventajas
- ✅ Auto-documentado (descripción incluida)
- ✅ Tooltips automáticos
- ✅ Validación de conflictos
- ✅ Separación clara de responsabilidades
- ✅ Fácil de mantener y extender

### Desventajas
- ❌ Más verboso que hotkeys simples
- ❌ Requiere entender el sistema de capas
- ❌ Solo funciona con capas (no global)

---

## 🔄 Comparación Directa

### Ejemplo: Navegación Vim

**Con Hotkeys Tradicionales:**
```ahk
; En algún archivo .ahk
h::Send {Left}
j::Send {Down}
k::Send {Up}
l::Send {Right}

; Problema: ¡Ahora no puedes escribir h, j, k, l!
```

**Con Keymaps Declarativos:**
```ahk
; En nvim_layer.ahk
RegisterKeymaps("nvim", [
    {key: "h", desc: "Left", action: "Send {Left}"},
    {key: "j", desc: "Down", action: "Send {Down}"},
    {key: "k", desc: "Up", action: "Send {Up}"},
    {key: "l", desc: "Right", action: "Send {Right}"}
])

; Solución: Solo funcionan cuando la capa Nvim está activa
; Puedes escribir hjkl normalmente cuando la capa está desactivada
```

---

## 🎭 Casos de Uso

### Caso 1: Activar una Capa

**Usar Hotkey:**
```ahk
CapsLock::ToggleNvimLayer()
```

**Por qué:** Es global, simple, y no necesita documentación.

---

### Caso 2: Navegación dentro de una Capa

**Usar Keymaps:**
```ahk
RegisterKeymaps("nvim", [
    {key: "h", desc: "Left", action: "Send {Left}"},
    {key: "j", desc: "Down", action: "Send {Down}"}
])
```

**Por qué:** Es parte de una capa modal, necesita tooltips, y hay muchas teclas relacionadas.

---

### Caso 3: Atajo Global Simple

**Usar Hotkey:**
```ahk
^!r::Reload  ; Ctrl+Alt+R para reload
```

**Por qué:** Global, no modal, acción única.

---

### Caso 4: Menú Complejo con Muchas Opciones

**Usar Keymaps:**
```ahk
RegisterKeymaps("leader_program", [
    {key: "c", desc: "Chrome", action: () => Run("chrome.exe")},
    {key: "v", desc: "VS Code", action: () => Run("code.exe")},
    {key: "t", desc: "Terminal", action: () => Run("wt.exe")},
    {key: "n", desc: "Notepad", action: () => Run("notepad.exe")}
])
```

**Por qué:** Muchas opciones, necesita tooltip para recordar las teclas.

---

## 🏗️ Arquitectura del Sistema

### Flujo de Hotkeys Tradicionales
```
Usuario presiona Ctrl+C
    ↓
Windows detecta
    ↓
AutoHotkey intercepta
    ↓
Ejecuta acción definida en hotkey
```

### Flujo de Keymaps Declarativos
```
Usuario activa capa Nvim (CapsLock)
    ↓
ActivateLayer("nvim")
    ↓
Registra todos los keymaps de "nvim"
    ↓
Usuario presiona 'h'
    ↓
Sistema busca keymap: capa="nvim", key="h"
    ↓
Encuentra: {key: "h", action: "Send {Left}"}
    ↓
Ejecuta action
    ↓
(Opcional) Muestra tooltip con desc
```

---

## 💡 Mejores Prácticas

### 1. Usa Hotkeys para lo Simple
```ahk
; ✅ Bien: Atajo global simple
^!r::Reload

; ❌ Mal: No necesitas keymaps para esto
RegisterKeymaps("global", [
    {key: "^!r", desc: "Reload", action: () => Reload()}
])
```

### 2. Usa Keymaps para Capas Modales
```ahk
; ✅ Bien: Muchas teclas relacionadas en una capa
RegisterKeymaps("nvim", [
    {key: "h", desc: "Left", action: "Send {Left}"},
    {key: "j", desc: "Down", action: "Send {Down}"},
    ; ... más teclas
])

; ❌ Mal: Hotkeys globales que bloquean escritura
h::Send {Left}
j::Send {Down}
```

### 3. Combina Ambos Estratégicamente
```ahk
; Hotkey para activar capa
CapsLock::ToggleNvimLayer()

; Keymaps dentro de la capa
RegisterKeymaps("nvim", [
    {key: "h", desc: "Left", action: "Send {Left}"}
])
```

---

## 🔍 Debugging

### Hotkeys
```ahk
; Ver qué hotkeys están activos
ListHotkeys  ; Comando de AHK

; Ver hotkeys en una ventana
#h::ListHotkeys
```

### Keymaps
```ahk
; Ver keymaps registrados
ShowRegisteredKeymaps("nvim")

; Usar OutputDebug
OutputDebug("Keymap ejecutado: " . keymap.desc)
```

---

## 📚 Ver También

- **[Sistema de Keymaps](sistema-keymaps.md)** - Documentación completa del sistema declarativo
- **[Crear Capas](crear-capas.md)** - Guía para crear nuevas capas
- **[Referencia de Funciones](referencia-funciones-capas.md)** - API completa

---

**[🌍 View in English](../../en/developer-guide/hotkeys-vs-keymaps.md)** | **[← Volver al Índice](../README.md)**
