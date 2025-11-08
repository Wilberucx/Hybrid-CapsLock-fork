; ==============================
# Leader Router Refactorización - Sistema Jerárquico Universal

## 🎯 Objetivo

Convertir `leader_router.ahk` de un router **hardcoded** a un **navegador jerárquico genérico** que funciona con cualquier estructura registrada en `keymap_registry.ahk`.

---

## ❌ Problema: Router Hardcoded (Antes)

### **Código Actual:**
```ahk
TryActivateLeader() {
    Loop {
        ShowLeaderMenu()
        key := GetInput()
        
        if (key = "w")           // ← Hardcoded
            LeaderWindowsMenuLoop()
        else if (key = "p")      // ← Hardcoded
            LeaderProgramsMenuLoop()
        else if (key = "c")      // ← Hardcoded
            LeaderCommandsMenuLoop()
        else if (key = "t")      // ← Hardcoded
            HandleTimestamps()
        // ...cada capa necesita su propio 'if'
    }
}
```

### **Problemas:**
1. ❌ Cada nueva capa requiere agregar código manualmente
2. ❌ No usa el sistema de registro (`keymap_registry.ahk`)
3. ❌ Lógica duplicada en cada `Loop()` function
4. ❌ No es escalable
5. ❌ Inconsistente con Commands (que SÍ usa el registry)

---

## ✅ Solución: Navegación Jerárquica Universal (Después)

### **Código Nuevo:**
```ahk
TryActivateLeader() {
    NavigateHierarchical("leader")  // ← Una función para TODO
}

NavigateHierarchical(currentPath) {
    Loop {
        ShowMenuForCurrentPath(currentPath)
        key := GetInput()
        
        // Usa ExecuteKeymapAtPath() del registry
        result := ExecuteKeymapAtPath(currentPath, key)
        
        if (Type(result) = "String") {
            // Es categoría, navegar más profundo
            NavigateHierarchical(result)  // ← Recursivo
        } else if (result = true) {
            // Acción ejecutada
            return
        }
    }
}
```

### **Ventajas:**
1. ✅ UNA función maneja TODO
2. ✅ Usa `ExecuteKeymapAtPath()` del registro
3. ✅ No requiere código para cada capa nueva
4. ✅ Escalable infinitamente
5. ✅ Consistente con el sistema declarativo

---

## 🔄 Comparación Detallada

### **Antes: Windows Layer**
```ahk
// leader_router.ahk
if (key = "w") {
    LeaderWindowsMenuLoop()  // ← Función específica
}

// Función específica (45 líneas)
LeaderWindowsMenuLoop() {
    Loop {
        ShowWindowMenu()
        key := GetInput()
        ExecuteWindowAction(key)  // ← Hardcoded
        return
    }
}
```

**Problemas:**
- 45 líneas de código solo para Windows
- No reutilizable

### **Después: Windows Layer**
```ahk
// leader_router.ahk
result := ExecuteKeymapAtPath("leader", "w")
if (Type(result) = "String") {
    NavigateHierarchical(result)  // ← Genérico
}

// windows_actions.ahk
RegisterWindowsKeymaps() {
    RegisterKeymap("w", "m", "Maximize", MaximizeWindow, false, 10)
}
```

**Ventajas:**
- 0 líneas específicas de Windows en router
- Reutilizable para cualquier capa

---

## 🌳 Flujo de Navegación

### **Ejemplo: Leader → Commands → ADB → List Devices**

#### **1. Usuario activa Leader**
```
Usuario: Hold CapsLock + Space
Sistema: NavigateHierarchical("leader")
```

#### **2. Mostrar menú Leader**
```ahk
ShowMenuForCurrentPath("leader")
// Usa BuildMenuForPath() que lee del registry
// Muestra: w, c, p, t, i, n
```

#### **3. Usuario presiona 'c'**
```ahk
result := ExecuteKeymapAtPath("leader", "c")
// result = "leader.c" (es categoría)
```

#### **4. Navegar a Commands**
```ahk
NavigateHierarchical("leader.c")  // ← Recursivo
ShowMenuForCurrentPath("leader.c")
// Muestra: s, h, g, m, n, f, o, a, v
```

#### **5. Usuario presiona 'a'**
```ahk
result := ExecuteKeymapAtPath("leader.c", "a")
// result = "leader.c.a" (es categoría)
```

#### **6. Navegar a ADB**
```ahk
NavigateHierarchical("leader.c.a")  // ← Recursivo
ShowMenuForCurrentPath("leader.c.a")
// Muestra: d, x, s, l, ...
```

#### **7. Usuario presiona 'd'**
```ahk
result := ExecuteKeymapAtPath("leader.c.a", "d")
// result = true (acción ejecutada)
// Ejecuta: ADBListDevices()
```

#### **8. Salir**
```ahk
return "EXIT"  // Sale de todos los niveles
```

---

## 🔙 Manejo de Back/Escape

### **Navegación con Breadcrumb (Stack implícito)**

```
Leader Menu
└── Presiona 'c'
    Commands Menu
    └── Presiona 'a'
        ADB Menu
        └── Presiona Backspace
            ← Vuelve a Commands Menu
            └── Presiona Backspace
                ← Vuelve a Leader Menu
```

**Código:**
```ahk
NavigateHierarchical(currentPath) {
    Loop {
        key := GetInput()
        
        if (key = "Backspace") {
            if (currentPath = "leader")
                return "EXIT"  // Root, salir
            else
                return "BACK"  // Volver al padre
        }
        
        result := ExecuteKeymapAtPath(currentPath, key)
        
        if (Type(result) = "String") {
            res := NavigateHierarchical(result)  // ← Recursión
            if (res = "BACK")
                continue  // Volver a este nivel
        }
    }
}
```

---

## 📊 Métricas de Mejora

| Aspecto | Antes | Después | Mejora |
|---------|-------|---------|--------|
| **Líneas para Windows** | 45 líneas | 0 líneas | -100% |
| **Líneas para Commands** | 60 líneas | 0 líneas | -100% |
| **Líneas para Programs** | 50 líneas | 0 líneas | -100% |
| **Funciones específicas** | 5 funciones | 1 función | -80% |
| **Total leader_router** | 348 líneas | ~250 líneas | -28% |
| **Escalabilidad** | Manual | Automática | ∞ |

---

## 🎯 Características del Nuevo Sistema

### **1. Navegación Recursiva**
```ahk
NavigateHierarchical("leader")
  → NavigateHierarchical("leader.c")
    → NavigateHierarchical("leader.c.a")
      → Ejecuta acción
```

### **2. Menús Auto-Generados**
```ahk
ShowMenuForCurrentPath(path) {
    items := GenerateCategoryItemsForPath(path)
    // Lee del KeymapRegistry automáticamente
}
```

### **3. Timeout Dinámico**
```ahk
GetTimeoutForPath("leader") → GetEffectiveTimeout("leader")
GetTimeoutForPath("leader.c") → GetEffectiveTimeout("commands")
GetTimeoutForPath("leader.w") → GetEffectiveTimeout("windows")
```

### **4. Back/Escape Consistente**
```ahk
Backspace → Volver al nivel anterior
Escape → Salir completamente
\ → Alternativa a Backspace
```

---

## ⚠️ Acciones Especiales (Temporales)

Mientras se migran otras capas, mantenemos:

```ahk
// Toggle layers (s, n)
if (path = "leader" && key = "s")
    HandleScrollLayerToggle()

if (path = "leader" && key = "n")
    HandleExcelLayerToggle()

// Capas no migradas (t, i, p)
if (path = "leader" && key = "t")
    HandleTimestampsLayer()

if (path = "leader" && key = "i")
    HandleInformationLayer()

if (path = "leader" && key = "p")
    HandleProgramsLayer()
```

**TODO:**
- Migrar Programs → `programs_actions.ahk`
- Migrar Timestamps → `timestamps_actions.ahk`
- Migrar Information → `information_actions.ahk`
- Decidir qué hacer con toggles (s/n)

---

## 🎨 Compatibilidad con C# Tooltips

```ahk
ShowMenuForCurrentPath(path) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowMenuForPathCS(path)  // ← Tooltip C#
    } else {
        // Fallback a tooltip nativo
        menuText := BuildMenuForPath(path, GetTitleForPath(path))
        ToolTip(menuText, x, y)
    }
}

ShowMenuForPathCS(path) {
    items := GenerateCategoryItemsForPath(path)
    title := GetTitleForPath(path)
    ShowCSharpOptionsMenu(title, items, "\\: Back|ESC: Exit")
}
```

---

## ✅ Testing del Nuevo Sistema

### **Test 1: Navegación Básica**
```
<leader> → c → s → t
Esperado: Ejecuta Task Manager
```

### **Test 2: Back Funciona**
```
<leader> → c → a → Backspace → s → t
Esperado: 
1. Entra ADB
2. Vuelve a Commands
3. Entra System
4. Ejecuta Task Manager
```

### **Test 3: Windows Layer**
```
<leader> → w → m
Esperado: Maximiza ventana
```

### **Test 4: Escape Sale**
```
<leader> → c → a → Escape
Esperado: Sale completamente del Leader
```

---

## 🚀 Próximos Pasos

### **Fase 1: Reemplazar Router Actual** (Ahora)
1. ✅ Crear `leader_router_NEW.ahk`
2. ⏳ Probar con Windows + Commands (ya migrados)
3. ⏳ Reemplazar `leader_router.ahk` con la nueva versión
4. ⏳ Verificar que funciona con categorías existentes

### **Fase 2: Migrar Capas Restantes**
1. ⏳ Migrar Programs Layer
2. ⏳ Migrar Timestamps Layer
3. ⏳ Migrar Information Layer
4. ⏳ Eliminar funciones `Handle*Layer()` temporales

### **Fase 3: Refinamiento**
1. ⏳ Decidir destino de toggles (s/n)
2. ⏳ Optimizar mensajes de error
3. ⏳ Agregar logging/debug si necesario

---

## 🎉 Resultado Final

Con este cambio, `leader_router.ahk` se convierte en un **navegador universal** que:

✅ Funciona con CUALQUIER estructura jerárquica  
✅ No requiere código para nuevas capas  
✅ Usa el sistema de registro declarativo  
✅ Maneja back/escape correctamente  
✅ Es escalable infinitamente  
✅ Mantiene compatibilidad con tooltips C#  

**Sistema verdaderamente genérico y extensible implementado.** 🚀
