# Guía: LAYER_NAME vs LAYER_ID en el Template

## ⚠️ Problema Común

Al usar el template `doc/templates/template_layer.ahk`, es fácil confundir cuándo usar mayúsculas vs minúsculas en los nombres de capa.

## 📋 Regla Simple

### LAYER_NAME (PascalCase) - Para código/funciones
Usa **PascalCase** (primera letra mayúscula) para:
- ✅ Nombres de funciones: `ActivateExcelLayer()`, `OnExcelLayerActivate()`
- ✅ Nombres de variables: `isExcelLayerActive`, `excelLayerEnabled`
- ✅ Prefijos de funciones: `ExcelExit()`, `ExcelDoSomething()`
- ✅ Logs y comentarios: `OutputDebug("[Excel] ...")`

### LAYER_ID (lowercase) - Para identificadores del sistema
Usa **minúsculas** para:
- ✅ `SwitchToLayer("excel", originLayer)` ← Identificador de sistema
- ✅ `ListenForLayerKeymaps("excel", "isExcelLayerActive")` ← Identificador de sistema
- ✅ `RegisterKeymap("excel", "h", ...)` ← Identificador de sistema
- ✅ En `data/layer_registry.ini`: `excel=src\layer\excel_layer.ahk`

## 🎯 Ejemplo Completo: Excel Layer

```autohotkey
; LAYER_NAME = "Excel" (para funciones)
; LAYER_ID = "excel" (para sistema)

; ✅ CORRECTO
ActivateExcelLayer(originLayer := "leader") {
    result := SwitchToLayer("excel", originLayer)  // minúscula aquí
    return result
}

OnExcelLayerActivate() {
    global isExcelLayerActive  // PascalCase en variable
    isExcelLayerActive := true
    ListenForLayerKeymaps("excel", "isExcelLayerActive")  // minúscula aquí
}

; En config/keymap.ahk:
RegisterKeymap("excel", "h", "Move Left", VimMoveLeft, false, 20)  // minúscula aquí
```

```autohotkey
; ❌ INCORRECTO (lo que causó el bug)
ActivateExcelLayer(originLayer := "leader") {
    result := SwitchToLayer("Excel", originLayer)  // ❌ Mayúscula incorrecta
    return result
}

OnExcelLayerActivate() {
    ListenForLayerKeymaps("Excel", "isExcelLayerActive")  // ❌ Mayúscula incorrecta
}
```

## 🔧 Proceso Recomendado al Usar el Template

1. **Copia el template**:
   ```bash
   cp doc/templates/template_layer.ahk src/layer/mylayer_layer.ahk
   ```

2. **Define tus nombres**:
   - LAYER_NAME = `"MyLayer"` (PascalCase - para funciones)
   - LAYER_ID = `"mylayer"` (lowercase - para sistema)
   - LAYER_DISPLAY = `"My Layer"` (amigable - para UI)

3. **Reemplaza en orden**:
   
   a) Primero busca y reemplaza `LAYER_ID` → `mylayer` (minúscula)
   ```vim
   :%s/LAYER_ID/mylayer/g
   ```
   
   b) Luego busca y reemplaza `LAYER_NAME` → `MyLayer` (PascalCase)
   ```vim
   :%s/LAYER_NAME/MyLayer/g
   ```
   
   c) Finalmente reemplaza `LAYER_DISPLAY` → `My Layer`
   ```vim
   :%s/LAYER_DISPLAY/My Layer/g
   ```

4. **Verifica los lugares críticos** (busca el emoji ⚠️ en el template):
   - `SwitchToLayer("mylayer", ...)` ← debe ser minúscula
   - `ListenForLayerKeymaps("mylayer", ...)` ← debe ser minúscula
   - `RegisterKeymap("mylayer", ...)` ← debe ser minúscula

## 🐛 Debugging

Si tu capa no funciona, verifica:

1. **OutputDebug logs**:
   ```
   [LayerListener] ERROR: Layer not found in KeymapRegistry: Excel
   ```
   → Significa que estás usando "Excel" pero registraste "excel"

2. **Revisa consistencia**:
   ```bash
   # Busca todas las referencias en tu archivo
   grep -n "Excel\|excel" src/layer/excel_layer.ahk
   ```

3. **Compara con capas que funcionan**:
   - `scroll_layer.ahk` usa `"scroll"` (minúscula)
   - `nvim_layer.ahk` usa `"nvim"` (minúscula)

## 💡 Sistema de Tooltips Dinámicos

El template incluye DOS tipos de tooltips:

### 1. **Help Tooltip** (Dinánico - Muestra todos los keymaps)

Lee automáticamente todos los keymaps registrados y los muestra cuando presionas `?`.

#### Cómo funciona:

1. **Registras tus keymaps** en `config/keymap.ahk`:
   ```autohotkey
   RegisterKeymap("excel", "h", "Move Left", VimMoveLeft, false, 20)
   RegisterKeymap("excel", "?", "Toggle Help", ExcelToggleHelp, false, 100)
   ```

2. **El sistema genera el tooltip automáticamente** cuando presionas `?`:
   - Lee todos los keymaps de `KeymapRegistry` para tu layer
   - Genera un tooltip con C# (si está habilitado) o nativo
   - Muestra: `h - Move Left`, `? - Toggle Help`, etc.

3. **No necesitas escribir el menú manualmente** - se actualiza solo cuando agregas/modificas keymaps

#### Funciones clave:

- `GenerateCategoryItemsForPath("layer_id")` - Genera items para tooltip C#
- `BuildMenuForPath("layer_id", "Title")` - Genera texto para tooltip nativo
- `ShowBottomRightListTooltip(title, items, footer, timeout)` - Muestra tooltip C#

#### Ejemplo:

```autohotkey
ExcelShowHelp() {
    global tooltipConfig, ExcelHelpActive
    items := GenerateCategoryItemsForPath("excel")  // Lee keymaps automáticamente
    ShowBottomRightListTooltip("EXCEL LAYER HELP", items, "?: Close", 8000)
}
```

### 2. **Status Tooltip** (Persistente - Indicador de estado activo)

Muestra un indicador persistente en la esquina inferior derecha mientras la capa está activa.

#### Cómo funciona:

1. **Cuando la capa se activa**, muestra tooltip persistente:
   - **C# Tooltip** (si está habilitado): `[Excel] ? help` - permanece visible (timeout=0)
   - **Native Tooltip** (fallback): `◉ EXCEL` - desaparece después de 900ms

2. **Cuando la capa se desactiva**, oculta el tooltip

3. **Después de cerrar el help**, restaura el tooltip de estado

#### Estructura:

Necesitas implementar DOS funciones en los archivos de UI:

**En `src/ui/tooltips_native_wrapper.ahk`** (fallback nativo):
```autohotkey
ShowExcelLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowExcelLayerToggleCS(isActive)
    } else {
        ShowCenteredToolTip(isActive ? "◉ EXCEL" : "○ EXCEL")
        SetTimer(() => RemoveToolTip(), -900)
    }
}
```

**En `src/ui/tooltip_csharp_integration.ahk`** (C# tooltip):
```autohotkey
ShowExcelLayerToggleCS(isActive) {
    try HideCSharpTooltip()
    Sleep 30
    StartTooltipApp()
    if (!isActive) {
        try HideCSharpTooltip()
        return
    }
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Excel"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := 0  ; persistent while layer is active
    items := []
    it := Map()
    it["key"] := "?"
    it["description"] := "help"
    items.Push(it)
    cmd["items"] := items
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
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}
```

#### Uso en la capa:

```autohotkey
OnExcelLayerActivate() {
    ShowExcelLayerStatus(true)  // Muestra indicador persistente
    ListenForLayerKeymaps("excel", "isExcelLayerActive")
    ShowExcelLayerStatus(false)  // Oculta cuando termina
}

ExcelCloseHelp() {
    HideCSharpTooltip()
    if (isExcelLayerActive) {
        ShowExcelLayerStatus(true)  // Restaura indicador después del help
    }
}
```

## 📚 Referencias

- Template: `doc/templates/template_layer.ahk`
- Ejemplo funcional: `src/layer/scroll_layer.ahk`, `src/layer/nvim_layer.ahk`
- Sistema de keymaps: `src/core/keymap_registry.ahk`
- Sistema de tooltips: `src/ui/tooltip_csharp_integration.ahk`
- Documentación: `doc/CREATING_NEW_LAYERS.md`
