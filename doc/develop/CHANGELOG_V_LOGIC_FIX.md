# Changelog: Fix V Logic Mini-Layer en Excel Layer

**Fecha**: 2025-01-XX  
**Tipo**: Bugfix + Documentación  
**Componentes afectados**: 
- `src/core/mappings.ahk`
- `src/ui/tooltips_native_wrapper.ahk`
- `src/ui/tooltip_csharp_integration.ahk`
- `doc/EXCEL_LAYER.md`
- `doc/develop/excel_v_logic_mini_layer.md` (nuevo)

---

## 🐛 Problema identificado

La combinación `vr` en Excel layer no funcionaba correctamente, mientras que `vc` y `vv` sí lo hacían.

### Síntomas
- Al presionar `v` seguido de `r`, no se seleccionaba la fila completa
- El comando `Shift+Space` no llegaba a Excel
- El tooltip "ROW SELECTED" no aparecía
- En su lugar, se ejecutaba `Ctrl+Y` (Redo)

### Causa raíz
**Conflicto de InputLevel entre hotkeys dinámicos y mini-capa:**

1. Los hotkeys dinámicos del INI (`r=send:^y`) se registraban con **InputLevel 0** (por defecto)
2. La mini-capa V Logic usaba **InputLevel 2** para sus hotkeys
3. En AHK v2, los InputLevels más bajos tienen **prioridad** sobre los más altos
4. Resultado: el hotkey dinámico de `r` se disparaba antes que el de la mini-capa

---

## ✅ Solución implementada

### 1. Fix en `src/core/mappings.ahk`

**Cambio en `ApplyExcelMappings()`:**

Se agregó `#InputLevel 1` antes de registrar los hotkeys dinámicos, y se restaura a `#InputLevel 0` después:

```ahk
ApplyExcelMappings(mappings) {
    global _excelRegisteredHotkeys
    UnregisterExcelMappings()
    if (mappings.Count = 0)
        return
    global excelStaticEnabled
    excelStaticEnabled := false
    
    ; ✨ NUEVO: Use InputLevel 1 to match static Excel hotkeys 
    ; and allow minicapa V Logic (InputLevel 2) to override
    #InputLevel 1
    
    HotIf((*) => (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelAppAllowedGuard()))
    for key, action in mappings.OwnProps() {
        hk := key
        Hotkey(hk, (*) => ExecuteAction("excel", action), "On")
        _excelRegisteredHotkeys.Push(hk)
    }
    HotIf()
    
    ; ✨ NUEVO: Restaurar InputLevel por defecto
    #InputLevel 0
}
```

**Impacto:**
- Los hotkeys dinámicos ahora tienen InputLevel 1 (igual que los estáticos)
- Las mini-capas (InputLevel 2) tienen prioridad sobre ellos
- Se resuelve el conflicto de teclas compartidas

### 2. Mejora en tooltips de clipboard (`src/ui/tooltip_csharp_integration.ahk`)

**Cambio en `ShowCopyNotificationCS()`:**

Se refactorizó para usar la API avanzada y evitar colisiones con tooltips persistentes de NVIM/Visual/Excel:

```ahk
ShowCopyNotificationCS() {
    ; Bottom-right, navigation-less clipboard status with short timeout
    ; Additionally, if a persistent layer (NVIM/Visual/Excel) is active, restore it after the toast ends
    global ConfigIni
    global isNvimLayerActive, VisualMode, excelLayerActive

    to := CleanIniValue(IniRead(ConfigIni, "Tooltips", "status_notification_timeout", ""))
    if (to = "" || to = "ERROR") {
        to := 1200
    } else {
        to := Integer(Trim(to))
        if (to > 1200)
            to := 1200
        if (to < 400)
            to := 400
    }

    ; Build command directly to avoid any default navigation injection
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "CLIPBOARD"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := to

    items := []
    it := Map()
    it["key"] := "<"
    it["description"] := "COPIED"
    items.Push(it)
    cmd["items"] := items

    ; Apply theme styling and position
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]

    StartTooltipApp()
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)

    ; Determine which persistent to restore (if any), then schedule it after the toast
    active := ""
    if (IsSet(isNvimLayerActive) && isNvimLayerActive) {
        if (IsSet(VisualMode) && VisualMode)
            active := "visual"
        else
            active := "nvim"
    } else if (IsSet(excelLayerActive) && excelLayerActive) {
        active := "excel"
    }
    if (active != "") {
        delay := to + 120
        SetTimer(() => RestorePersistentAfterCopy(active), -delay)
    }
}

RestorePersistentAfterCopy(which) {
    try {
        switch which {
            case "visual":
                ShowVisualLayerToggleCS(true)
            case "nvim":
                ShowNvimLayerToggleCS(true)
            case "excel":
                ShowExcelLayerToggleCS(true)
        }
    } catch {
    }
}
```

**Mejoras:**
- Sin barra de navegación ("Esc: Close")
- Layout bottom-right list (consistente con NVIM/Visual)
- Timeout corto forzado (400-1200ms)
- Restaura automáticamente el tooltip persistente de la capa activa (NVIM/Visual/Excel)

### 3. Feedback visual de copiado en NVIM (`src/ui/tooltips_native_wrapper.ahk`)

**Cambio en `ShowCopyNotification()`:**

Se agregó un movimiento Up/Down del cursor para emular el feedback de yank de Vim:

```ahk
ShowCopyNotification() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCopyNotificationCS()
    } else {
        ShowCenteredToolTip("COPIED")
        SetTimer(() => RemoveToolTip(), -800)
    }
    ; Post-copy motion to emulate NVIM yank feedback: move cursor Up/Down when NVIM layer is active
    try {
        global isNvimLayerActive, ConfigIni
        if (IsSet(isNvimLayerActive) && isNvimLayerActive) {
            Sleep 30
            Send("{Up}")
            ; Optionally return cursor with Down after Up (NVIM-like yank feedback)
            ret := "true"
            try ret := IniRead(ConfigIni, "Nvim", "yank_feedback_return", "true")
            if (StrLower(Trim(ret)) = "true") {
                Sleep 25
                Send("{Down}")
            }
        }
    }
}
```

**Comportamiento:**
- Solo activo cuando NVIM layer está activo
- Envía Up y luego Down para dar feedback visual sin mover el cursor
- Configurable vía `[Nvim] yank_feedback_return=true/false` en `configuration.ini`

---

## 📚 Documentación creada/actualizada

### 1. Nuevo documento técnico: `doc/develop/excel_v_logic_mini_layer.md`

Documentación completa de la implementación de V Logic mini-layer, incluyendo:
- Contexto y motivación
- Problema encontrado y causa raíz (conflicto de InputLevel)
- Solución implementada con código
- Jerarquía de InputLevels en Excel layer
- Implementación detallada en `excel_layer.ahk`
- Escenarios de prueba
- Consideraciones de diseño
- Debugging y diagnóstico
- Futuras mejoras

### 2. Actualización de `doc/EXCEL_LAYER.md`

Se mejoró la sección de "Funciones de Selección Avanzadas (Minicapas)" con:
- Explicación más detallada de cómo funciona V Logic
- Instrucciones paso a paso para usar la mini-capa
- Referencia al documento técnico de implementación

---

## 🎯 Resultado final

### Jerarquía de InputLevels en Excel Layer

```
Excel Layer:
├─ InputLevel 0: [Sistema/otros]
├─ InputLevel 1: Hotkeys estáticos y dinámicos de Excel
└─ InputLevel 2: Mini-capas (V Logic, VV Mode) - MÁXIMA PRIORIDAD
```

### Funcionamiento correcto de V Logic

✅ **`vr`** → Selecciona fila completa (Shift+Space)  
✅ **`vc`** → Selecciona columna completa (Ctrl+Space)  
✅ **`vv`** → Activa modo VV (visual selection con hjkl)  
✅ **`r` (sin `v`)**  → Envía Ctrl+Y (Redo) como hotkey normal

### Tooltips mejorados

✅ **Clipboard COPIED** → Bottom-right, sin navegación, timeout corto, restaura tooltip persistente  
✅ **NVIM yank** → Feedback visual Up/Down al copiar en NVIM layer

---

## 🔍 Patrón clave aprendido

**Cuando se implementan mini-capas o sub-modos en AHK v2:**

1. Las mini-capas deben usar un **InputLevel mayor** que los hotkeys normales
2. Los hotkeys dinámicos deben registrarse con un **InputLevel explícito** (no usar el 0 por defecto)
3. La jerarquía debe ser: `Sistema (0) < Hotkeys normales (1) < Mini-capas (2)`

Este patrón es replicable para futuras mini-capas en otros layers (Commands, Programs, etc.).

---

## 🧪 Testing recomendado

### Test 1: V Logic funciona correctamente
1. Activar Excel layer (`leader → n`)
2. Presionar `v` + `r` → Debe seleccionar fila completa
3. Presionar `v` + `c` → Debe seleccionar columna completa
4. Presionar `v` + `v` → Debe activar modo VV

### Test 2: Hotkeys normales no afectados
1. Activar Excel layer
2. Presionar `r` (sin `v`) → Debe ejecutar Redo (Ctrl+Y)
3. Presionar `c` (sin `v`) → Debe ejecutar su acción normal

### Test 3: Tooltips de clipboard
1. Con NVIM/Visual/Excel activo, copiar algo (Ctrl+C o `y`)
2. Debe mostrar "CLIPBOARD COPIED" en bottom-right sin navegación
3. Debe restaurar el tooltip persistente de la capa activa

### Test 4: NVIM yank feedback
1. Activar NVIM layer
2. Copiar algo (`y`)
3. Debe ver el cursor moverse Up y Down brevemente

---

## 📝 Notas adicionales

- Este fix no afecta a otros layers (NVIM, Commands, etc.)
- El patrón de InputLevel es extensible a futuros layers con mini-capas
- La documentación técnica sirve como referencia para implementaciones similares
- Los tooltips C# ahora tienen mejor manejo de estados persistentes vs. notificaciones temporales

---

**Autor**: Sistema HybridCapsLock  
**Revisado por**: Usuario  
**Estado**: ✅ Implementado y documentado  
**Version**: HybridCapsLock v2.0+
