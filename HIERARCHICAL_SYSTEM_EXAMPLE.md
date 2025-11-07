# 🌳 Sistema Jerárquico - Ejemplo de Uso

## 🎯 Concepto

Sistema que permite anidar categorías dentro de categorías, con rutas completas especificadas en el registro.

---

## 📝 Sintaxis

### **Registrar Categoría (sin acción, solo abre otro menú)**

```ahk
RegisterCategoryKeymap(path..., title, order)
```

**Ejemplo:**
```ahk
RegisterCategoryKeymap("c", "Commands", 1)              // Leader → c (Commands)
RegisterCategoryKeymap("c", "a", "ADB Tools", 1)        // Commands → a (ADB)
```

### **Registrar Acción (ejecuta función)**

```ahk
RegisterKeymap(path..., description, actionFunc, needsConfirm, order)
```

**Ejemplo:**
```ahk
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
//              │    │    │
//           Leader  │    └── Acción en ADB
//                   └── Categoría ADB en Commands
```

---

## 🌳 Ejemplo Completo: Estructura Actual

### **Migración de la estructura Commands actual:**

```ahk
; ==============================
; LEADER MENU
; ==============================

; Categoría principal "Commands" en Leader
RegisterCategoryKeymap("c", "Commands", 3)

; ==============================
; SUBCATEGORÍAS EN COMMANDS
; ==============================

RegisterCategoryKeymap("c", "s", "System Commands", 1)
RegisterCategoryKeymap("c", "h", "Hybrid Management", 2)
RegisterCategoryKeymap("c", "g", "Git Commands", 3)
RegisterCategoryKeymap("c", "m", "Monitoring Commands", 4)
RegisterCategoryKeymap("c", "n", "Network Commands", 5)
RegisterCategoryKeymap("c", "f", "Folder Access", 6)
RegisterCategoryKeymap("c", "o", "Power Options", 7)
RegisterCategoryKeymap("c", "a", "ADB Tools", 8)
RegisterCategoryKeymap("c", "v", "VaultFlow", 9)

; ==============================
; ACCIONES EN SYSTEM (c → s)
; ==============================

RegisterKeymap("c", "s", "s", "System Info", ShowSystemInfo, false, 1)
RegisterKeymap("c", "s", "t", "Task Manager", ShowTaskManager, false, 2)
RegisterKeymap("c", "s", "v", "Services", ShowServicesManager, false, 3)
RegisterKeymap("c", "s", "e", "Event Viewer", ShowEventViewer, false, 4)

; ==============================
; ACCIONES EN ADB (c → a)
; ==============================

RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
RegisterKeymap("c", "a", "x", "Disconnect", ADBDisconnect, false, 2)
RegisterKeymap("c", "a", "s", "Shell", ADBShell, false, 3)
RegisterKeymap("c", "a", "l", "Logcat", ADBLogcat, false, 4)

; ==============================
; ACCIONES EN GIT (c → g)
; ==============================

RegisterKeymap("c", "g", "s", "Status", GitStatus, false, 1)
RegisterKeymap("c", "g", "l", "Log", GitLog, false, 2)
RegisterKeymap("c", "g", "b", "Branches", GitBranches, false, 3)
RegisterKeymap("c", "g", "a", "Add All", GitAddAll, true, 4)   // Con confirmación
```

---

## 🎨 Navegación Resultante

```
Leader Menu
├── p - Programs
├── w - Windows
├── c - Commands (categoría) ← Presionar 'c'
│   ├── s - System Commands (categoría) ← Presionar 's'
│   │   ├── s - System Info (acción)
│   │   ├── t - Task Manager (acción)
│   │   ├── v - Services (acción)
│   │   └── e - Event Viewer (acción)
│   ├── a - ADB Tools (categoría) ← Presionar 'a'
│   │   ├── d - List Devices (acción)
│   │   ├── x - Disconnect (acción)
│   │   ├── s - Shell (acción)
│   │   └── l - Logcat (acción)
│   └── g - Git Commands (categoría)
│       ├── s - Status (acción)
│       ├── l - Log (acción)
│       └── ...
└── ...
```

---

## 🔄 Flujo de Usuario

### **Ejemplo 1: Ejecutar "List Devices"**

```
1. Usuario: Hold CapsLock + Space (activa Leader)
2. Sistema: Muestra Leader Menu
3. Usuario: Presiona 'c'
4. Sistema: Muestra Commands submenu (s, h, g, m, n, f, o, a, v)
5. Usuario: Presiona 'a'
6. Sistema: Muestra ADB Tools submenu (d, x, s, l, ...)
7. Usuario: Presiona 'd'
8. Sistema: Ejecuta ADBListDevices()
```

**Ruta completa:** `Leader → c → a → d`

**Código:**
```ahk
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
```

---

## 🎯 Ejemplo 2: Categoría con Acciones Directas

Si quieres que **Windows** tenga acciones directamente (sin subcategorías):

```ahk
; Windows es categoría en Leader
RegisterCategoryKeymap("w", "Windows", 2)

; Acciones directas en Windows (sin subcategoría intermedia)
RegisterKeymap("w", "m", "Maximize Window", MaximizeWindow, false, 1)
RegisterKeymap("w", "n", "Minimize Window", MinimizeWindow, false, 2)
RegisterKeymap("w", "c", "Center Window", CenterWindow, false, 3)
```

**Navegación:**
```
Leader → w (Windows)
         ├── m - Maximize Window
         ├── n - Minimize Window
         └── c - Center Window
```

**Flujo:** `<leader> w m` → Ejecuta MaximizeWindow()

---

## 🌟 Ejemplo 3: Funciones Reutilizables

Para funciones como las flechas hjkl que quieres usar en múltiples contextos:

```ahk
; Definir funciones reutilizables
MoveLeft() {
    Send("{Left}")
}

MoveDown() {
    Send("{Down}")
}

MoveUp() {
    Send("{Up}")
}

MoveRight() {
    Send("{Right}")
}

; Usar en múltiples contextos
; En Nvim Layer (ya existe)
RegisterKeymap("nvim", "h", "Move Left", MoveLeft, false, 1)
RegisterKeymap("nvim", "j", "Move Down", MoveDown, false, 2)
RegisterKeymap("nvim", "k", "Move Up", MoveUp, false, 3)
RegisterKeymap("nvim", "l", "Move Right", MoveRight, false, 4)

; En Excel Layer (reutilizar)
RegisterKeymap("excel", "h", "Move Left", MoveLeft, false, 1)
RegisterKeymap("excel", "j", "Move Down", MoveDown, false, 2)
RegisterKeymap("excel", "k", "Move Up", MoveUp, false, 3)
RegisterKeymap("excel", "l", "Move Right", MoveRight, false, 4)
```

---

## 🔧 Ventajas del Sistema Jerárquico

### **✅ 1. Rutas Explícitas**

```ahk
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
//              │    │    │
//           Claridad total del path
```

### **✅ 2. Anidación Ilimitada**

```ahk
// Nivel 1
RegisterCategoryKeymap("dev", "Development", 1)

// Nivel 2
RegisterCategoryKeymap("dev", "docker", "Docker", 1)

// Nivel 3
RegisterCategoryKeymap("dev", "docker", "containers", "Containers", 1)

// Acción en nivel 3
RegisterKeymap("dev", "docker", "containers", "ls", "List", DockerPS, false, 1)

// Ruta: Leader → dev → docker → containers → ls
```

### **✅ 3. Ordenamiento por Nivel**

```ahk
// Controlar orden en cada nivel
RegisterCategoryKeymap("c", "a", "ADB Tools", 8)      // Posición 8 en Commands
RegisterKeymap("c", "a", "d", "List Devices", ..., 1) // Posición 1 en ADB
RegisterKeymap("c", "a", "r", "Reboot", ..., 99)      // Posición 99 en ADB
```

### **✅ 4. Funciones Reutilizables**

```ahk
// Una función, múltiples contextos
MoveLeft() { Send("{Left}") }

RegisterKeymap("nvim", "h", "Move Left", MoveLeft, false, 1)
RegisterKeymap("excel", "h", "Move Left", MoveLeft, false, 1)
RegisterKeymap("explorer", "h", "Move Left", MoveLeft, false, 1)
```

---

## 🚀 Próximos Pasos

1. **Implementar `keymap_registry_hierarchical.ahk`** en el sistema
2. **Migrar Commands** actual a la nueva sintaxis
3. **Migrar Programs, Windows, Timestamps, Information, Excel**
4. **Crear funciones reutilizables** (hjkl, etc.)

---

## 💡 Comparación con which-key

### **Neovim which-key:**

```lua
local wk = require("which-key")
wk.register({
  c = {
    name = "Commands",
    a = {
      name = "ADB",
      d = { "<cmd>ADBDevices<cr>", "List Devices" },
      s = { "<cmd>ADBShell<cr>", "Shell" }
    }
  }
}, { prefix = "<leader>" })
```

### **Este sistema (equivalente):**

```ahk
RegisterCategoryKeymap("c", "Commands", 1)
RegisterCategoryKeymap("c", "a", "ADB", 1)
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
RegisterKeymap("c", "a", "s", "Shell", ADBShell, false, 2)
```

**✅ IDÉNTICO en estructura y funcionalidad.**

---

## 🎊 Conclusión

Este sistema te permite crear una jerarquía **completamente personalizable** donde:

- ✅ Leader es la raíz
- ✅ Categorías pueden contener categorías
- ✅ Categorías pueden contener acciones
- ✅ Funciones son reutilizables
- ✅ Rutas completas son explícitas
- ✅ Orden controlado por nivel

**Es exactamente lo que pediste.** 🚀

¿Procedemos con la implementación?
