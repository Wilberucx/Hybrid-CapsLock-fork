# Referencia de Funciones para Layers

Este documento describe todas las funciones disponibles en el sistema de layers de HybridCapslock, proporcionando una guía rápida para crear y trabajar con layers dinámicos.

## 📋 Índice

1. [Funciones del Sistema Core](#funciones-del-sistema-core)
2. [Funciones del Layer (Template)](#funciones-del-layer-template)
3. [Funciones de KeymapRegistry](#funciones-de-keymapregistry)
4. [Flujo de Ejecución Completo](#flujo-de-ejecución-completo)

---

## 🔧 Funciones del Sistema Core

Estas funciones están en `src/core/auto_loader.ahk` y `src/core/keymap_registry.ahk`

### `SwitchToLayer(targetLayer, originLayer := "")`

**Ubicación:** `src/core/auto_loader.ahk`

**Propósito:** Cambiar de un layer a otro en el sistema.

**Parámetros:**
- `targetLayer` (String): Nombre del layer a activar (lowercase, ej: "excel", "scroll")
- `originLayer` (String, opcional): Layer desde donde se invoca (para saber a dónde regresar)

**Retorna:** `Boolean` - true si exitoso, false si hay error

**Qué hace:**
1. Valida que el target layer existe en LayerRegistry
2. Desactiva el layer actual (si hay uno)
3. Actualiza variables globales `CurrentActiveLayer` y `PreviousLayer`
4. Llama al hook `On{LayerName}LayerActivate()` del nuevo layer

**Ejemplo:**
```autohotkey
SwitchToLayer("excel", "leader")  ; Activa excel layer, guarda "leader" como origen
```

---

### `ReturnToPreviousLayer()`

**Ubicación:** `src/core/auto_loader.ahk`

**Propósito:** Regresar al layer anterior desde donde se invocó el layer actual.

**Parámetros:** Ninguno

**Qué hace:**
1. Si `PreviousLayer` es "" o "leader", regresa al estado base
2. Si `PreviousLayer` tiene un valor, reactiva ese layer
3. Desactiva el layer actual antes de cambiar

**Ejemplo:**
```autohotkey
ReturnToPreviousLayer()  ; Sale del layer actual y regresa al anterior
```

---

### `ListenForLayerKeymaps(layerName, layerActiveVarName)`

**Ubicación:** `src/core/keymap_registry.ahk`

**Propósito:** Loop infinito que escucha inputs del usuario y ejecuta keymaps registrados.

**Parámetros:**
- `layerName` (String): Nombre del layer en KeymapRegistry (lowercase, ej: "excel")
- `layerActiveVarName` (String): Nombre de la variable global de estado (ej: "isExcelLayerActive")

**⚠️ IMPORTANTE:**
- Esta función es **BLOQUEANTE**: no regresa hasta que el layer se desactive
- El segundo parámetro se pasa como STRING, no como variable
- La función accede a la variable usando `%nombreVariable%`

**Qué hace:**
1. Loop infinito mientras `%layerActiveVarName%` sea true
2. Espera input del usuario con `InputHook`
3. Busca la tecla presionada en `KeymapRegistry[layerName]`
4. Si encuentra keymap registrado, ejecuta la acción
5. Si es categoría, entra en navegación jerárquica
6. Cuando la variable de estado cambia a false, termina el loop

**Ejemplo:**
```autohotkey
ListenForLayerKeymaps("excel", "isExcelLayerActive")
; Esta línea se ejecuta DESPUÉS de que isExcelLayerActive = false
```

---

### `RegisterKeymap(layer, keys..., description, action, [confirm], [order])`

**Ubicación:** `src/core/keymap_registry.ahk`

**Propósito:** Registrar un keymap (combinación de tecla → acción) en el sistema.

**Parámetros:**
- `layer` (String): Layer donde se registra (SIEMPRE el primer parámetro)
- `keys...` (String): Una o más teclas (soporta paths jerárquicos)
- `description` (String): Descripción mostrada en menús
- `action` (Func): Función a ejecutar
- `confirm` (Boolean, opcional): Si requiere confirmación Y/N
- `order` (Integer, opcional): Orden en el menú (default: 999)

**Sintaxis:**
```autohotkey
; Keymap simple (un nivel)
RegisterKeymap("excel", "h", "Move Left", VimMoveLeft, false, 1)

; Keymap jerárquico (múltiples niveles)
RegisterKeymap("leader", "c", "a", "d", "List Devices", ADBListDevices, false, 1)
; Crea: leader → c → a → d

; Con confirmación
RegisterKeymap("leader", "r", "Restart", RestartSystem, true, 10)
```

**Qué hace:**
1. Extrae el layer (primer parámetro)
2. Detecta metadata al final (desc, action, confirm, order)
3. Extrae las teclas intermedias (path)
4. Registra en `KeymapRegistry` bajo el path completo
5. El keymap queda disponible para `ListenForLayerKeymaps()`

---

### `RegisterCategoryKeymap(layer, keys..., title, [order])`

**Ubicación:** `src/core/keymap_registry.ahk`

**Propósito:** Registrar una categoría (submenu) que lleva a más opciones.

**Parámetros:**
- `layer` (String): Layer donde se registra
- `keys...` (String): Una o más teclas para el path
- `title` (String): Título de la categoría
- `order` (Integer, opcional): Orden en el menú

**Ejemplo:**
```autohotkey
; Categoría simple
RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)

; Categoría jerárquica
RegisterCategoryKeymap("leader", "c", "a", "ADB Tools", 1)
```

---

### `ExecuteKeymapAtPath(path, key)`

**Ubicación:** `src/core/keymap_registry.ahk`

**Propósito:** Ejecutar un keymap registrado en un path específico.

**Parámetros:**
- `path` (String): Path en KeymapRegistry (ej: "excel", "leader.c.a")
- `key` (String): Tecla presionada

**Retorna:**
- `false` si no se encuentra el keymap
- `true` si se ejecutó una acción
- `String` (path) si es una categoría (para navegación jerárquica)

**Qué hace:**
1. Busca el keymap en `KeymapRegistry[path][key]`
2. Si es categoría, retorna el nuevo path
3. Si es acción y tiene `confirm=true`, muestra confirmación Y/N
4. Ejecuta la acción registrada

---

### `GenerateCategoryItemsForPath(path)`

**Ubicación:** `src/core/keymap_registry.ahk`

**Propósito:** Generar string con items para tooltip C# desde keymaps registrados.

**Parámetros:**
- `path` (String): Path en KeymapRegistry (ej: "excel")

**Retorna:** String formato: `"h:Move Left|j:Move Down|k:Move Up"`

**Qué hace:**
1. Lee todos los keymaps en `KeymapRegistry[path]`
2. Los ordena por `order`
3. Genera string en formato para tooltips C#

**Ejemplo:**
```autohotkey
items := GenerateCategoryItemsForPath("excel")
; Retorna: "h:Move Left|j:Move Down|k:Move Up|Escape:Exit"
```

---

### `BuildMenuForPath(path, title := "")`

**Ubicación:** `src/core/keymap_registry.ahk`

**Propósito:** Generar texto de menú para tooltips nativos.

**Parámetros:**
- `path` (String): Path en KeymapRegistry
- `title` (String, opcional): Título del menú

**Retorna:** String con saltos de línea para tooltip nativo

**Qué hace:**
1. Lee todos los keymaps en `KeymapRegistry[path]`
2. Los ordena por `order`
3. Genera texto con formato:
   ```
   TÍTULO
   
   h - Move Left
   j - Move Down
   k → Commands (categoría)
   ```

---

## 📦 Funciones del Layer (Template)

Estas funciones debes implementarlas en tu `{nombre}_layer.ahk`

### `Activate{LayerName}Layer(originLayer := "leader")`

**Propósito:** Punto de entrada público para activar el layer.

**Parámetros:**
- `originLayer` (String, opcional): Layer desde donde se invoca (default: "leader")

**Retorna:** Boolean - true si se activó, false si hubo error

**Cuándo se usa:**
- Desde leader menu: `RegisterKeymap("leader", "e", "Excel", ActivateExcelLayer, false)`
- Desde otro layer: `ActivateExcelLayer("nvim")`
- Desde hotkey global: `#e::ActivateExcelLayer()`

**Implementación típica:**
```autohotkey
ActivateExcelLayer(originLayer := "leader") {
    OutputDebug("[Excel] ActivateExcelLayer() called")
    result := SwitchToLayer("excel", originLayer)
    return result
}
```

---

### `On{LayerName}LayerActivate()`

**Propósito:** Hook llamado automáticamente por `auto_loader.ahk` cuando el layer se activa.

**⚠️ NO llamar manualmente - es un hook del sistema**

**Responsabilidades:**
1. Establecer `is{LayerName}LayerActive = true`
2. Mostrar UI de estado (tooltips)
3. Iniciar `ListenForLayerKeymaps()`
4. Cleanup post-desactivación

**Implementación típica:**
```autohotkey
OnExcelLayerActivate() {
    global isExcelLayerActive
    isExcelLayerActive := true
    
    ; Mostrar estado
    try {
        ShowExcelLayerStatus(true)
        SetTempStatus("EXCEL LAYER ON", 1500)
    }
    
    ; Iniciar listener (BLOQUEANTE)
    try {
        ListenForLayerKeymaps("excel", "isExcelLayerActive")
    }
    
    ; Cleanup (se ejecuta DESPUÉS de que el layer se desactiva)
    isExcelLayerActive := false
    try {
        ShowExcelLayerStatus(false)
        SetTempStatus("EXCEL LAYER OFF", 1500)
    }
}
```

---

### `On{LayerName}LayerDeactivate()`

**Propósito:** Hook llamado cuando el layer se desactiva explícitamente.

**Responsabilidades:**
1. Asegurar que `is{LayerName}LayerActive = false`
2. Limpiar recursos (cerrar ventanas, cancelar timers)
3. Ocultar UI del layer

**Implementación típica:**
```autohotkey
OnExcelLayerDeactivate() {
    global isExcelLayerActive, ExcelHelpActive
    isExcelLayerActive := false
    
    ; Cleanup de help si está activo
    if (IsSet(ExcelHelpActive) && ExcelHelpActive) {
        try ExcelCloseHelp()
    }
    
    try ShowExcelLayerStatus(false)
}
```

---

### `{LayerName}Exit()`

**Propósito:** Función para salir del layer y regresar al anterior.

**Implementación típica:**
```autohotkey
ExcelExit() {
    global isExcelLayerActive
    isExcelLayerActive := false
    try ReturnToPreviousLayer()
}
```

**Cómo funciona:**
1. Establece la variable de estado en `false`
2. Esto hace que `ListenForLayerKeymaps()` termine su loop
3. Llama a `ReturnToPreviousLayer()` para regresar al layer anterior

**Registro típico:**
```autohotkey
RegisterKeymap("excel", "Escape", "Exit", ExcelExit, false, 100)
```

---

### `{LayerName}ToggleHelp()`

**Propósito:** Toggle del sistema de ayuda (abre/cierra menú de ayuda).

**Implementación típica:**
```autohotkey
ExcelToggleHelp() {
    global ExcelHelpActive
    if (ExcelHelpActive)
        ExcelCloseHelp()
    else
        ExcelShowHelp()
}
```

---

### `{LayerName}ShowHelp()`

**Propósito:** Mostrar menú de ayuda con keymaps registrados.

**Qué hace:**
1. Genera menú dinámicamente desde `KeymapRegistry`
2. Muestra tooltip (C# o nativo)
3. Configura timer de auto-cierre

**Implementación típica:**
```autohotkey
ExcelShowHelp() {
    global tooltipConfig, ExcelHelpActive
    try HideCSharpTooltip()
    Sleep 30
    ExcelHelpActive := true
    
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout")) 
        ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(ExcelHelpAutoClose, -to)
    
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ; Tooltip C#
            items := GenerateCategoryItemsForPath("excel")
            ShowBottomRightListTooltip("EXCEL HELP", items, "?: Close", to)
        } else {
            ; Tooltip nativo
            menuText := BuildMenuForPath("excel", "EXCEL HELP")
            ShowCenteredToolTip(menuText)
        }
    }
}
```

---

### `{LayerName}CloseHelp()`

**Propósito:** Cerrar el sistema de ayuda y restaurar tooltip de estado.

**Implementación típica:**
```autohotkey
ExcelCloseHelp() {
    global isExcelLayerActive, ExcelHelpActive
    try SetTimer(ExcelHelpAutoClose, 0)  ; Cancelar timer
    try HideCSharpTooltip()
    ExcelHelpActive := false
    
    if (isExcelLayerActive) {
        try ShowExcelLayerStatus(true)  ; Restaurar tooltip de estado
    } else {
        try RemoveToolTip()
    }
}
```

---

## 🔄 Flujo de Ejecución Completo

### Activación de un Layer

```
Usuario presiona tecla en leader menu
    ↓
ActivateExcelLayer("leader") es llamado
    ↓
SwitchToLayer("excel", "leader") es ejecutado
    ↓
auto_loader.ahk desactiva layer actual (si hay uno)
    ↓
auto_loader.ahk actualiza CurrentActiveLayer = "excel"
auto_loader.ahk actualiza PreviousLayer = "leader"
    ↓
auto_loader.ahk llama OnExcelLayerActivate()
    ↓
OnExcelLayerActivate() ejecuta:
  - isExcelLayerActive = true
  - Muestra tooltip de estado
  - Llama ListenForLayerKeymaps("excel", "isExcelLayerActive")
    ↓
ListenForLayerKeymaps() inicia loop infinito:
  ┌─────────────────────────────────┐
  │ while (isExcelLayerActive) {    │
  │   Espera input del usuario      │
  │   Busca tecla en KeymapRegistry │
  │   Ejecuta acción registrada     │
  │ }                               │
  └─────────────────────────────────┘
    ↓
[El layer está activo, esperando inputs]
```

### Salida de un Layer

```
Usuario presiona Escape
    ↓
ListenForLayerKeymaps() detecta la tecla
    ↓
ExecuteKeymapAtPath("excel", "Escape")
    ↓
ExcelExit() es ejecutado
    ↓
isExcelLayerActive = false
    ↓
ListenForLayerKeymaps() detecta que la variable es false
    ↓
ListenForLayerKeymaps() termina el loop y regresa
    ↓
OnExcelLayerActivate() continúa ejecutando (líneas de cleanup)
    ↓
ReturnToPreviousLayer() es llamado
    ↓
Si PreviousLayer = "leader" → Regresa a estado base
Si PreviousLayer = otro layer → Reactiva ese layer
```

---

## 📝 Resumen de Variables Clave

| Variable | Tipo | Propósito |
|----------|------|-----------|
| `{LayerName}LayerEnabled` | Boolean | Feature flag para habilitar/deshabilitar layer |
| `is{LayerName}LayerActive` | Boolean | Estado actual del layer (activo/inactivo) |
| `{LayerName}HelpActive` | Boolean | Estado del sistema de ayuda |
| `CurrentActiveLayer` | String | Layer actualmente activo (global) |
| `PreviousLayer` | String | Layer desde donde se invocó el actual (global) |
| `LayerRegistry` | Map | Registro de todos los layers disponibles (global) |
| `KeymapRegistry` | Map | Registro de todos los keymaps (global) |

---

## ✅ Checklist para Crear un Nuevo Layer

1. ✓ Copiar `template_layer.ahk` a `src/layer/{nombre}_layer.ahk`
2. ✓ Reemplazar `LAYER_ID` con identificador lowercase
3. ✓ Reemplazar `LAYER_NAME` con nombre PascalCase
4. ✓ Reemplazar `LAYER_DISPLAY` con texto display
5. ✓ Implementar acciones específicas del layer
6. ✓ Registrar keymaps en `config/keymap.ahk`
7. ✓ Implementar funciones de status tooltip en UI files
8. ✓ Registrar activación en leader menu (si aplica)
9. ✓ Probar activación, keymaps y desactivación
10. ✓ Probar sistema de ayuda (tecla `?`)

---

## 🔗 Archivos Relacionados

- **Template:** `doc/templates/template_layer.ahk`
- **Ejemplos:** `src/layer/excel_layer.ahk`, `src/layer/scroll_layer.ahk`, `src/layer/nvim_layer.ahk`
- **Core:** `src/core/auto_loader.ahk`, `src/core/keymap_registry.ahk`
- **Documentación:** `doc/CREATING_NEW_LAYERS.md`, `doc/KEYMAP_SYSTEM_UNIFIED.md`
