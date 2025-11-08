# 🎯 Concepto de Layers - Arquitectura Evolucionada

## 🔑 Definición de Layer

Un **Layer** es un **modo persistente** que cambia completamente el comportamiento del teclado mientras está activo.

---

## 📊 Tipos de Layers

### **1. Layers Persistentes (Modos Verdaderos)** 🔵

**Características:**
- ✅ Permanecen activos indefinidamente
- ✅ Cambian TODAS las teclas mientras están activos
- ✅ Se desactivan con ESC (o tecla configurable de exit)
- ✅ No tienen timeout automático

**Ejemplos:**

```
nvim_layer:
  ├── Modo activo: hjkl navega, y/p edita, v entra visual mode
  ├── Salida: ESC o F23 (toggle)
  └── Análogo: Modo Normal de Vim

excel_layer:
  ├── Modo activo: hjkl navega celdas, f inserta fórmula
  ├── Salida: ESC o toggle
  └── Análogo: Modo Excel con navegación Vim

scroll_layer:
  ├── Modo activo: hjkl scroll la ventana
  ├── Salida: ESC o toggle
  └── Análogo: Modo Scroll persistente
```

---

### **2. Mini-Layers (Command Palettes)** 🟢

**Características:**
- ✅ Esperan UNA acción
- ✅ Si la tecla no existe, no hacen nada (o muestran error)
- ✅ Salen automáticamente después de ejecutar
- ✅ Tienen timeout y ESC
- ✅ Permiten navegación jerárquica (back con Backspace)

**Ejemplos:**

```
Leader Menu (raíz):
  ├── Espera: w/c/p/t/i/...
  ├── Salida: ESC, timeout, o después de ejecutar acción
  ├── Back: No aplica (es raíz)
  └── Análogo: Command Palette de VSCode

Commands (c):
  ├── Espera: s/h/g/m/... (categorías)
  ├── Salida: ESC, timeout, Backspace (vuelve a Leader)
  └── Jerárquico: c → a → d (3 niveles)

Windows (w):
  ├── Espera: m/2/x/... (acciones)
  ├── Salida: ESC, timeout, Backspace (vuelve a Leader)
  └── Ejecuta y sale: NO persiste
```

---

## 🎨 Comparación Visual

### **Layer Persistente (nvim_layer):**

```
Estado Normal → Presiona F23 (CapsLock tap)
                ↓
              [NVIM LAYER ON]
                ↓
        ┌──────────────────┐
        │  h: ←            │
        │  j: ↓            │
        │  k: ↑            │
        │  l: →            │
        │  y: yank         │
        │  v: visual mode  │
        │  ...             │
        │  ESC: SALIR      │  ← Única forma de salir
        └──────────────────┘
                ↓
        Presiona ESC
                ↓
              [NVIM LAYER OFF]
                ↓
        Estado Normal
```

### **Mini-Layer (Commands):**

```
Estado Normal → <leader> c (Commands)
                ↓
        ┌──────────────────┐
        │  s: System       │
        │  a: ADB          │
        │  g: Git          │
        │  ESC: SALIR      │
        │  Backspace: BACK │
        │  Timeout: SALIR  │
        └──────────────────┘
                ↓
        Presiona 'a' (ADB)
                ↓
        ┌──────────────────┐
        │  d: List Devices │
        │  s: Shell        │
        │  ESC: SALIR      │
        │  Backspace: BACK │
        └──────────────────┘
                ↓
        Presiona 'd'
                ↓
        [Ejecuta ADBListDevices()]
                ↓
        [SALE AUTOMÁTICAMENTE]
                ↓
        Estado Normal
```

---

## 🏗️ Arquitectura de Archivos

### **Layers Persistentes:**

```
src/layer/
├── nvim_layer.ahk        ← Layer persistente (modo Vim)
│   ├── Toggle: F23
│   ├── Salida: ESC
│   └── Usa: vim_nav.ahk, vim_visual.ahk, vim_edit.ahk
│
├── excel_layer.ahk       ← Layer persistente (modo Excel)
│   ├── Toggle: <leader> n
│   ├── Salida: ESC
│   └── Usa: vim_nav.ahk, excel_actions.ahk
│
└── scroll_layer.ahk      ← Layer persistente (modo Scroll)
    ├── Toggle: <leader> s
    ├── Salida: ESC
    └── Usa: Scroll functions
```

### **Mini-Layers (Command Palettes):**

```
src/layer/
├── leader_router.ahk     ← Router jerárquico universal
│   ├── Activa: F24 (Hold CapsLock + Space)
│   ├── Navega: NavigateHierarchical(path)
│   └── Usa: keymap_registry.ahk
│
└── (Otros *_layer.ahk obsoletos, se migrarán)

src/actions/
├── windows_actions.ahk   ← Acciones de Windows (mini-layer)
├── system_actions.ahk    ← Acciones de System (mini-layer)
└── ...                   ← Cada uno define sus keymaps declarativos
```

---

## 🎓 Principios de Diseño

### **1. Layers Persistentes = Comportamiento Total**

```ahk
// nvim_layer.ahk
#HotIf (isNvimLayerActive)  // ← Cambio global de comportamiento
h::VimMoveLeft()
j::VimMoveDown()
y::VimYank()
v::ActivateVisualMode()
ESC::DeactivateNvimLayer()  // ← Salida explícita
#HotIf
```

### **2. Mini-Layers = Paletas de Comandos**

```ahk
// leader_router.ahk
NavigateHierarchical("leader.c.a") {
    Loop {
        ShowMenu()          // Muestra opciones
        key := GetInput()   // Espera UNA tecla
        
        if (key = "ESC")
            return "EXIT"   // ← Sale
        
        result := ExecuteKeymapAtPath(path, key)
        
        if (result = true)
            return "EXIT"   // ← Ejecutó y sale automáticamente
    }
}
```

### **3. Consistencia en Salida**

**Todas las layers/mini-layers:**
- ✅ **ESC** siempre sale (puede configurarse)
- ✅ **Backspace** vuelve atrás (en mini-layers jerárquicos)
- ✅ **Timeout** opcional (solo mini-layers)

---

## 💡 Ejemplos de Uso

### **Ejemplo 1: Nvim Layer (Persistente)**

```
1. Usuario presiona F23 (CapsLock tap)
2. nvim_layer se activa
3. Usuario usa hjkl, w/b/e, yy, dd, etc.
4. Layer sigue activo
5. Usuario presiona ESC
6. nvim_layer se desactiva
```

**Código:**
```ahk
*F23:: {
    global isNvimLayerActive
    isNvimLayerActive := !isNvimLayerActive
    ShowNvimLayerStatus(isNvimLayerActive)
}

#HotIf (isNvimLayerActive)
h::VimMoveLeft()
ESC::{
    global isNvimLayerActive
    isNvimLayerActive := false
}
#HotIf
```

---

### **Ejemplo 2: Commands (Mini-Layer)**

```
1. Usuario presiona <leader> c
2. Muestra menú de Commands
3. Usuario presiona 'a' (ADB)
4. Muestra menú de ADB
5. Usuario presiona 'd' (List Devices)
6. Ejecuta ADBListDevices()
7. Sale automáticamente
```

**Código:**
```ahk
NavigateHierarchical("leader") {
    key := GetInput()
    
    if (key = "c") {
        result := NavigateHierarchical("leader.c")  // Recursión
    }
}

// Registrado en windows_actions.ahk:
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
```

---

## 🔄 Migración de Concepto

### **Antes (Confuso):**
```
¿Commands es una layer?
¿Windows es una layer?
¿Timestamps es una layer?
```

**Problema:** Todo se llamaba "layer" pero funcionaba diferente.

### **Ahora (Claro):**

**Layers Verdaderos (Persistentes):**
- nvim_layer
- excel_layer
- scroll_layer

**Mini-Layers (Command Palettes):**
- Leader Menu (raíz)
  - Windows (w)
  - Commands (c)
    - System (s)
    - ADB (a)
  - Programs (p)
  - Timestamps (t)
  - Information (i)

---

## ✅ Consistencia Lograda

### **Todas las Layers/Mini-Layers:**

1. **ESC siempre funciona** (salir)
2. **Backspace vuelve atrás** (mini-layers jerárquicos)
3. **Timeout opcional** (solo mini-layers)
4. **Feedback visual** (tooltips muestran estado)
5. **Navegación clara** (recursiva o plana)

### **Sistema Unificado:**

```
Todas usan keymap_registry para declarar comportamiento
Todas tienen salida consistente (ESC)
Todas pueden ser extendidas fácilmente
```

---

## 🎉 Resultado Final

Con este concepto evolucionado:

✅ **Claridad** - Sabes qué es un layer persistente vs mini-layer  
✅ **Consistencia** - Todas siguen las mismas reglas de salida  
✅ **Extensibilidad** - Agregar nueva layer/mini-layer es trivial  
✅ **Mantenibilidad** - Sistema declarativo unificado  

**Arquitectura pulida y conceptualmente sólida implementada.** 🚀
