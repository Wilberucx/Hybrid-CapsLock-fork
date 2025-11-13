# Refactor: Sistema de Layers Consistente

## 🎯 Objetivo
Hacer que **todos los layers sean explícitos** en el sistema de registro de keymaps, eliminando la inconsistencia donde "leader" se agregaba automáticamente en algunos casos pero no en otros.

## 🔄 Cambios Realizados

### 1. **src/core/keymap_registry.ahk**

#### Eliminado
- Variable global `LeaderRoot := "leader"` 
- Auto-agregado de "leader" en funciones de registro

#### Modificado

**RegisterCategoryKeymap()** - Ahora requiere layer explícito:
```ahk
; ANTES (inconsistente):
RegisterCategoryKeymap("h", "Hybrid Management", 1)
RegisterCategoryKeymap("c", "a", "ADB Tools", 1)

; DESPUÉS (consistente):
RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
RegisterCategoryKeymap("leader", "c", "a", "ADB Tools", 1)
RegisterCategoryKeymap("scroll", "advanced", "Advanced Scroll", 1)  ; ← Preparado para otros layers
```

**RegisterKeymap()** - SIEMPRE requiere layer explícito:
```ahk
; ANTES (inconsistente - algunas veces con "leader", otras no):
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)  ; ← Requería "leader"
RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)  ; ← Auto-agregaba "leader"

; DESPUÉS (consistente - TODAS requieren layer):
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)
RegisterKeymap("leader", "c", "a", "d", "List Devices", ADBListDevices, false, 1)
RegisterKeymap("scroll", "h", "Scroll Up", WheelScrollUp, false, 1)  ; ← Preparado para otros layers
```

**RegisterKeymapHierarchical()** - Actualizada la firma:
```ahk
; ANTES:
RegisterKeymapHierarchical(pathKeys, description, actionFunc, needsConfirm, order)

; DESPUÉS:
RegisterKeymapHierarchical(layer, pathKeys, description, actionFunc, needsConfirm, order)
```

### 2. **config/keymap.ahk**

Actualizado **TODAS las líneas** para usar sintaxis consistente:

#### Categorías nivel 1:
```ahk
RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
RegisterCategoryKeymap("leader", "t", "Timestamps", 2)
RegisterCategoryKeymap("leader", "c", "Commands", 3)
```

#### Categorías multinivel:
```ahk
RegisterCategoryKeymap("leader", "c", "s", "System Commands", 1)
RegisterCategoryKeymap("leader", "c", "g", "Git Commands", 3)
RegisterCategoryKeymap("leader", "t", "d", "Date Formats", 1)
```

#### Keymaps (ya estaban correctos):
```ahk
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
RegisterKeymap("leader", "c", "g", "s", "Status", GitStatus, false, 1)
```

## ✅ Filosofía del Sistema Refactorizado

### **Layer siempre explícito**
El primer parámetro de TODAS las funciones de registro es el layer/context:
- `"leader"` → Menú principal (CapsLock + Space)
- `"scroll"` → Scroll layer (futuro)
- `"nvim"` → Nvim layer (futuro)
- `"excel"` → Excel layer (futuro)

### **Consistencia total**
No hay auto-agregado de prefijos. Lo que escribes es lo que obtienes.

### **Preparado para múltiples layers**
Ahora es trivial agregar mapeos en otros layers:
```ahk
; Mapeos en scroll layer
RegisterKeymap("scroll", "h", "Scroll Up", WheelScrollUp, false, 1)
RegisterKeymap("scroll", "j", "Scroll Down", WheelScrollDown, false, 1)

; Categorías en scroll layer
RegisterCategoryKeymap("scroll", "a", "Advanced", 1)
RegisterKeymap("scroll", "a", "f", "Fast Scroll", FastScroll, false, 1)
```

## 📋 Sintaxis Unificada

### 1. Registrar Categoría (submenu):
```ahk
RegisterCategoryKeymap(layer, key(s)..., title, [order])

Ejemplos:
  RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
  RegisterCategoryKeymap("leader", "c", "s", "System Commands", 1)
  RegisterCategoryKeymap("scroll", "advanced", "Advanced", 1)
```

### 2. Registrar Keymap (acción):
```ahk
RegisterKeymap(layer, key(s)..., desc, action, [confirm], [order])

Ejemplos:
  RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)
  RegisterKeymap("leader", "c", "g", "s", "Status", GitStatus, false, 1)
  RegisterKeymap("scroll", "h", "Scroll Up", WheelScrollUp, false, 1)
```

## 🔮 Visión Futura

Con este refactor, ahora es posible:

1. **Mapear teclas en cualquier layer**:
   ```ahk
   ; En scroll layer
   RegisterKeymap("scroll", "h", "Scroll Up", WheelScrollUp, false, 1)
   RegisterKeymap("scroll", "j", "Scroll Down", WheelScrollDown, false, 1)
   
   ; En nvim layer
   RegisterKeymap("nvim", "g", "g", "Go to top", GoToTop, false, 1)
   
   ; En excel layer
   RegisterKeymap("excel", "f", "r", "Fill Right", FillRight, false, 1)
   ```

2. **Crear jerarquías en cualquier layer**:
   ```ahk
   RegisterCategoryKeymap("scroll", "a", "Advanced", 1)
   RegisterKeymap("scroll", "a", "f", "Fast Scroll", FastScroll, false, 1)
   RegisterKeymap("scroll", "a", "s", "Smooth Scroll", SmoothScroll, false, 1)
   ```

3. **Todo es uniforme y predecible**:
   - ✅ No hay "magic" de auto-agregado de prefijos
   - ✅ Lo que escribes es exactamente el path que se registra
   - ✅ Todos los layers siguen las mismas reglas

## 🧪 Compatibilidad

### Deprecated (pero mantenido)
- `RegisterKeymapFlat()` - Marcada como DEPRECATED
- Sistema flat legacy con `RegisterCategory()` - Mantiene compatibilidad

### Migración
Todo el código nuevo debe usar:
1. `RegisterCategoryKeymap(layer, ...)`
2. `RegisterKeymap(layer, ...)`

## 📝 Notas de Implementación

### Estado de KeymapRegistry
```ahk
global KeymapRegistry := Map()  ; Estructura: layer.path → Map de teclas

Ejemplo:
  KeymapRegistry["leader"]["s"] = {key: "s", desc: "Scroll", action: ...}
  KeymapRegistry["leader.c"]["g"] = {key: "g", path: "leader.c.g", isCategory: true, ...}
  KeymapRegistry["leader.c.g"]["s"] = {key: "s", desc: "Status", action: GitStatus, ...}
  KeymapRegistry["scroll"]["h"] = {key: "h", desc: "Scroll Up", action: ...}
```

### Navigation
La navegación sigue igual, pero ahora todo es explícito:
```ahk
NavigateHierarchical("leader")  ; Inicia en layer "leader"
NavigateHierarchical("scroll")  ; Podría iniciar en layer "scroll" (futuro)
```

## ✨ Beneficios

1. **Consistencia**: Todas las funciones usan la misma sintaxis
2. **Claridad**: No hay auto-agregados ocultos
3. **Escalabilidad**: Fácil agregar nuevos layers
4. **Mantenibilidad**: El código es más predecible y fácil de entender
5. **Inspiración Neovim**: Sigue el patrón which-key pero más explícito

---

**Fecha**: 2025-11-11
**Autor**: Refactor del sistema de layers
**Estado**: ✅ Completado
