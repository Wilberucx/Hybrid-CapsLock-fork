# 🏗️ Arquitectura Jerárquica Completa - Resumen

## 🎯 Visión Implementada

Sistema **declarativo jerárquico** estilo which-key de Neovim, con separación elegante entre:
- **Funciones reutilizables** (`src/actions/vim_nav.ahk`)
- **Funciones específicas** (`src/actions/*_actions.ahk`)
- **Capas compositoras** (`src/layer/*_layer.ahk`)

---

## 📁 Estructura de Archivos

```
src/
├── actions/                        ← ACCIONES (Building Blocks)
│   ├── vim_nav.ahk                 ← ✨ Navegación pura (hjkl, w/b/e, gg/G, ^/$)
│   │                                  USADO EN: nvim_layer, excel_layer, etc.
│   ├── vim_visual.ahk              ← ✨ Navegación con selección (Shift+hjkl, visual mode)
│   │                                  USADO EN: nvim_layer (modo v), excel_layer
│   ├── vim_edit.ahk                ← ✨ Operaciones de edición (yank/delete/paste/undo)
│   │                                  USADO EN: nvim_layer, excel_layer
│   │
│   ├── windows_actions.ahk         ← ⚙️ Window management (splits, maximize, blind switch)
│   │                                  ESPECÍFICO: Solo para windows_layer
│   │
│   ├── system_actions.ahk          ← ⚙️ System commands (JER commit c → s → t)
│   ├── hybrid_actions.ahk          ← ⚙️ Hybrid management (JER c → h → R)
│   ├── git_actions.ahk             ← ⚙️ Git commands (JERÁRQUICO c → g → s)
│   ├── monitoring_actions.ahk      ← ⚙️ Monitoring (JERÁRQUICO c → m → p)
│   ├── network_actions.ahk         ← ⚙️ Network (JERÁRQUICO c → n → i)
│   ├── folder_actions.ahk          ← ⚙️ Folders (JERÁRQUICO c → f → t)
│   ├── power_actions.ahk           ← ⚙️ Power (JERÁRQUICO c → o → l)
│   ├── adb_actions.ahk             ← ⚙️ ADB Tools (JERÁRQUICO c → a → d)
│   └── vaultflow_actions.ahk       ← ⚙️ VaultFlow (JERÁRQUICO c → v → v)
│
├── core/
│   ├── keymap_registry.ahk         ← 🎛️ Sistema de registro (DUAL: flat + jerárquico)
│   └── command_system_init.ahk     ← 🎛️ Inicialización (registra todas las capas)
│
└── layer/                          ← CAPAS (Composición + Routing)
    ├── nvim_layer.ahk              ← 📝 Usa: vim_nav.ahk
    ├── excel_layer.ahk             ← 📊 Usa: vim_nav.ahk + excel_actions.ahk
    ├── windows_layer.ahk           ← 🪟 Usa: windows_actions.ahk
    └── leader_router.ahk           ← 🎯 Router jerárquico universal
```

---

## 🎨 Tipos de Funciones

### **1. Funciones Reutilizables** ✨

**A) Navegación Pura** - `src/actions/vim_nav.ahk`

**Características:**
- ✅ Simples (1-2 líneas)
- ✅ Sin estado interno
- ✅ Sin selección
- ✅ Usables en 2+ capas

**Ejemplos:**
```ahk
VimMoveLeft() { Send("{Left}") }
VimMoveDown() { Send("{Down}") }
VimWordForward() { Send("^{Right}") }
VimTopOfFile() { Send("^{Home}") }
```

**Usado en:**
- `nvim_layer.ahk` → Navegación de texto (modo normal)
- `excel_layer.ahk` → Navegación de celdas
- Futuras capas con navegación

---

**B) Visual Mode** - `src/actions/vim_visual.ahk`

**Características:**
- ✅ Navegación CON selección (Shift+)
- ✅ Para modo Visual de Vim
- ✅ Reutilizable

**Ejemplos:**
```ahk
VimVisualMoveLeft() { Send("+{Left}") }
VimVisualMoveDown() { Send("+{Down}") }
VimVisualWordForward() { Send("+^{Right}") }
```

**Usado en:**
- `nvim_layer.ahk` → Modo visual (v/V)
- `excel_layer.ahk` → Selección de rangos de celdas

---

**C) Operaciones de Edición** - `src/actions/vim_edit.ahk`

**Características:**
- ✅ Operaciones sobre texto (no navegación)
- ✅ Yank/Delete/Paste/Undo
- ✅ Reutilizable

**Ejemplos:**
```ahk
VimYank() { Send("^c") }
VimDelete() { Send("^x") }
VimPaste() { Send("^v") }
VimUndo() { Send("^z") }
```

**Usado en:**
- `nvim_layer.ahk` → Edición de texto
- `excel_layer.ahk` → Copy/paste en celdas

---

### **2. Funciones Específicas** ⚙️

**Ubicación:** `src/actions/*_actions.ahk` (uno por dominio)

**Características:**
- ❌ Lógica compleja (loops, timing, estado)
- ❌ Solo útil en UNA capa
- ✅ Dominio específico

**Ejemplos:**

```ahk
// windows_actions.ahk
Split5050() {
    Send("#{Left}")
    Sleep(100)  // ← Timing específico
    Send("#{Right}")
    ShowCommandExecuted("Windows", "Split 50/50")
}

StartPersistentBlindSwitch() {
    // ← Loop complejo, solo para Windows Layer
    Loop {
        key := GetInput()
        if (key = "j")
            Send("!{Tab}")
        // ...
    }
}
```

---

## 🌳 Jerarquía Implementada

### **Estructura Actual:**

```
Leader Menu (raíz)
├── w - Windows (NUEVO - jerárquico)
│   ├── 2 - Split 50/50
│   ├── 3 - Split 33/67
│   ├── 4 - Quarter Split
│   ├── m - Maximize
│   ├── - - Minimize
│   ├── x - Close
│   ├── h - Snap Left
│   ├── l - Snap Right
│   ├── d - Draw Mode
│   ├── z - Zoom Mode
│   ├── b - Blind Switch
│   └── n - New Desktop
│
└── c - Commands (MIGRADO - jerárquico)
    ├── s - System
    │   ├── s - System Info
    │   ├── t - Task Manager
    │   ├── v - Services
    │   └── ... (10 comandos)
    │
    ├── h - Hybrid
    │   ├── R - Reload Script
    │   ├── k - Restart Kanata
    │   └── ... (8 comandos)
    │
    ├── g - Git
    │   ├── s - Status
    │   ├── l - Log
    │   └── ... (6 comandos)
    │
    ├── m - Monitoring
    ├── n - Network
    ├── f - Folder
    ├── o - Power
    ├── a - ADB
    └── v - VaultFlow
```

---

## 📝 Sintaxis de Registro

### **Jerárquica (3+ niveles):**

```ahk
// Leader → w → m (Maximize)
RegisterKeymap("w", "m", "Maximize", MaximizeWindow, false, 10)
//              │    │    └── Acción
//              │    └── Key en Windows
//              └── Key en Leader

// Leader → c → a → d (ADB List Devices)
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
//              │    │    │
//           Leader  │    └── Acción en ADB
//                   └── Categoría ADB en Commands
```

### **Categorías:**

```ahk
// Categoría en Leader
RegisterCategoryKeymap("w", "Windows", 1)

// Subcategoría en Commands
RegisterCategoryKeymap("c", "a", "ADB Tools", 8)
```

---

## 🔄 Flujo de Navegación

### **Ejemplo: Ejecutar "List Devices"**

```
1. Usuario: <leader> (Hold CapsLock + Space)
2. Sistema: Muestra Leader Menu
   - w - Windows
   - c - Commands
   
3. Usuario: Presiona 'c'
4. Sistema: Muestra Commands submenu
   - s - System
   - a - ADB
   - g - Git
   
5. Usuario: Presiona 'a'
6. Sistema: Muestra ADB Tools submenu
   - d - List Devices
   - s - Shell
   
7. Usuario: Presiona 'd'
8. Sistema: Ejecuta ADBListDevices()
```

**Ruta completa:** `Leader → c → a → d`

**Código:**
```ahk
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
```

---

## 💡 Ejemplo de Reutilización

### **vim_nav.ahk + vim_visual.ahk + vim_edit.ahk (definido UNA VEZ):**

```ahk
// vim_nav.ahk - Navegación pura
VimMoveLeft() { Send("{Left}") }
VimMoveDown() { Send("{Down}") }
VimMoveUp() { Send("{Up}") }
VimMoveRight() { Send("{Right}") }

// vim_visual.ahk - Navegación con selección
VimVisualMoveLeft() { Send("+{Left}") }
VimVisualMoveDown() { Send("+{Down}") }

// vim_edit.ahk - Operaciones
VimYank() { Send("^c") }
VimPaste() { Send("^v") }
```

### **nvim_layer.ahk (REUTILIZA LOS 3):**

```ahk
#Include src\actions\vim_nav.ahk
#Include src\actions\vim_visual.ahk
#Include src\actions\vim_edit.ahk

; Normal mode
#HotIf (isNvimLayerActive && !visualMode)
h::VimMoveLeft()
j::VimMoveDown()
y::VimYank()
#HotIf

; Visual mode
#HotIf (isNvimLayerActive && visualMode)
h::VimVisualMoveLeft()
j::VimVisualMoveDown()
y::VimYank()  // ← Misma función de edición
#HotIf
```

### **excel_layer.ahk (REUTILIZA):**

```ahk
#Include src\actions\vim_nav.ahk
#Include src\actions\vim_edit.ahk

#HotIf (excelLayerActive)
h::VimMoveLeft()  // ← MISMA función que Nvim!
j::VimMoveDown()
y::VimYank()      // ← MISMA función que Nvim!
#HotIf
```

---

## ✅ Estado de Implementación

### **✅ Completado:**

1. **Sistema de registro jerárquico** (`keymap_registry.ahk`)
   - ✅ Sintaxis dual (flat + jerárquica)
   - ✅ Detección automática
   - ✅ Navegación multinivel

2. **Funciones reutilizables** (`vim_nav.ahk`)
   - ✅ Navegación hjkl
   - ✅ Palabras w/b/e
   - ✅ Línea ^/$
   - ✅ Documento gg/G
   - ✅ Visual mode (Shift+hjkl)

3. **Windows Layer** migrado
   - ✅ `windows_actions.ahk` creado
   - ✅ Funciones específicas extraídas
   - ✅ Registro jerárquico `RegisterWindowsKeymaps()`

4. **Commands Layer** migrado
   - ✅ 9 categorías en sintaxis jerárquica
   - ✅ System, Hybrid, Git, Monitoring, Network, Folder, Power, ADB, VaultFlow

5. **Inicialización**
   - ✅ `command_system_init.ahk` actualizado
   - ✅ `init.ahk` con nuevos includes
   - ✅ Registro de Windows + Commands

---

### **⏳ Pendiente:**

1. **Refactorizar nvim_layer.ahk**
   - Usar `vim_nav.ahk` en vez de hotkeys hardcoded
   
2. **Refactorizar excel_layer.ahk**
   - Reutilizar `vim_nav.ahk`
   
3. **Migrar Programs, Timestamps, Information**
   - A sistema declarativo jerárquico
   
4. **Actualizar leader_router.ahk**
   - Router genérico con navegación jerárquica universal
   - Manejo de back/escape en cada nivel

---

## 🎓 Principios de Diseño

### **1. Separation of Concerns**
```
actions/  → QUÉ hacer (funciones)
layer/    → CUÁNDO hacerlo (context + routing)
```

### **2. Reutilización Pragmática**
```
✅ SI es simple y genérico → vim_nav.ahk
❌ SI es complejo o específico → *_actions.ahk
```

### **3. Documentación Explícita**
```ahk
; REQUIERE: src/actions/vim_nav.ahk
; USADO EN: nvim_layer, excel_layer
```

### **4. Escalabilidad**
```
Agregar nueva capa = 3 pasos:
1. Crear *_actions.ahk (si tiene funciones específicas)
2. Reutilizar vim_nav.ahk (si necesita navegación)
3. Registrar en command_system_init.ahk
```

---

## 🎉 Logro

Has creado una arquitectura **elegante, escalable y reutilizable** que:

✅ Separa funciones reutilizables de específicas  
✅ Permite composición modular de capas  
✅ Soporta jerarquías multinivel  
✅ Es declarativa como which-key de Neovim  
✅ Está bien documentada y es fácil de extender  

**¡Sistema de nivel profesional implementado!** 🚀
