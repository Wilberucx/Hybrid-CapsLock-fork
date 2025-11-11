# Implementación de V Logic Mini-Layer en Excel Layer

Lígica deprecada, pendiente por refactorización completa.

Fecha: 2025-01-XX
Componente: `src/layer/excel_layer.ahk`, `src/core/mappings.ahk`

## Contexto

La capa Excel necesitaba una manera rápida de acceder a comandos de selección sin ocupar teclas individuales para cada función. Se implementó una **mini-capa temporal V Logic** que se activa con `v` y permite:

- `vr` → Seleccionar fila completa (Shift+Space)
- `vc` → Seleccionar columna completa (Ctrl+Space)
- `vv` → Activar modo VV (visual selection con hjkl)

Esta implementación sigue el patrón ya establecido en NVIM layer con `gg` y `:` (colon mode).

## Problema encontrado

### Síntoma inicial

Al presionar `vr`, la acción **no se ejecutaba** correctamente:

- `vv` y `vc` funcionaban bien
- `vr` no seleccionaba la fila (Shift+Space no llegaba a Excel)
- El tooltip "ROW SELECTED" no aparecía

### Causa raíz: Conflicto de InputLevel

La causa fue un **conflicto de prioridad de InputLevel** entre los hotkeys dinámicos y los de la mini-capa:

1. **Hotkeys dinámicos del INI** (`config/excel_layer.ini`):
   - `r=send:^y` (Redo) se registraba con InputLevel 0 (por defecto en `ApplyExcelMappings()`)
2. **Mini-capa V Logic** (`src/layer/excel_layer.ahk`):
   - Los hotkeys `*r::`, `*c::`, `*v::` estaban bajo `#InputLevel 2` (línea 92)

3. **Problema de prioridad en AHK v2**:
   - Los hotkeys con **menor InputLevel tienen prioridad** sobre los de mayor nivel
   - Al presionar `r` dentro de V Logic, el hotkey dinámico (InputLevel 0) se disparaba **antes** que el de la mini-capa (InputLevel 2)
   - Resultado: se enviaba `^y` (Redo) en lugar de `+{Space}` (seleccionar fila)

### Por qué `vc` y `vv` funcionaban

- `c` no tenía conflicto porque `c=send:^u` en el INI no interfería visualmente (ambos ejecutaban sin problema aparente)
- `v` estaba **vacío** en el INI (`v=`), por lo que no había hotkey dinámico que interfiriera

## Solución implementada

### Fix en `src/core/mappings.ahk`

Se modificó `ApplyExcelMappings()` para registrar los hotkeys dinámicos con **InputLevel 1**, permitiendo que la mini-capa V Logic (InputLevel 2) tenga prioridad:

**Antes:**

```ahk
ApplyExcelMappings(mappings) {
    global _excelRegisteredHotkeys
    UnregisterExcelMappings()
    if (mappings.Count = 0)
        return
    global excelStaticEnabled
    excelStaticEnabled := false
    HotIf((*) => (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelAppAllowedGuard()))
    for key, action in mappings.OwnProps() {
        hk := key
        Hotkey(hk, (*) => ExecuteAction("excel", action), "On")
        _excelRegisteredHotkeys.Push(hk)
    }
    HotIf()
}
```

**Después:**

```ahk
ApplyExcelMappings(mappings) {
    global _excelRegisteredHotkeys
    UnregisterExcelMappings()
    if (mappings.Count = 0)
        return
    global excelStaticEnabled
    excelStaticEnabled := false
    ; Use InputLevel 1 to match static Excel hotkeys and allow minicapa V Logic (InputLevel 2) to override
    #InputLevel 1
    HotIf((*) => (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelAppAllowedGuard()))
    for key, action in mappings.OwnProps() {
        hk := key
        Hotkey(hk, (*) => ExecuteAction("excel", action), "On")
        _excelRegisteredHotkeys.Push(hk)
    }
    HotIf()
    #InputLevel 0
}
```

### Jerarquía de InputLevels resultante

```
Excel Layer:
├─ InputLevel 0: [Reservado para sistema/otros]
├─ InputLevel 1: Hotkeys estáticos y dinámicos de Excel (línea 16, mappings.ahk)
└─ InputLevel 2: Mini-capas (V Logic, VV Mode) - MÁXIMA PRIORIDAD (línea 92, 143)
```

Esta jerarquía garantiza que:

1. Las mini-capas temporales tienen prioridad sobre los hotkeys normales de Excel
2. Los hotkeys de Excel tienen prioridad sobre otros layers/aplicaciones
3. No hay conflictos entre teclas compartidas en diferentes contextos

## Implementación de V Logic en excel_layer.ahk

### Estado global de la mini-capa

```ahk
global VLogicActive := false
```

### Activación de la mini-capa (líneas 68-76)

```ahk
*v:: {
    global VLogicActive, VVModeActive
    if (!VVModeActive) {
        VLogicActive := true
        to := GetEffectiveTimeout("excel")
        try SetTimer(VLogicTimeout, -to*1000)
    }
}
```

**Importante:**

- `GetEffectiveTimeout("excel")` retorna **segundos**
- `SetTimer` con valores negativos espera **milisegundos**
- Por eso se multiplica por 1000: `to*1000`

### Hotkeys de la mini-capa (líneas 92-135)

Estos hotkeys solo están activos cuando `VLogicActive = true`:

```ahk
#InputLevel 2
#HotIf (excelStaticEnabled ? (excelLayerActive && VLogicActive && !GetKeyState("CapsLock", "P") && ExcelAppAllowedGuard()) : false)

*r:: {
    ; Seleccionar fila completa (Shift+Space)
    VLogicCancel()
    OutputDebug("Excel V Logic: Selecting full ROW (Shift+Space)")
    Send("+{Space}")
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("EXCEL", "ROW SELECTED")
    } else {
        ShowCenteredToolTip("ROW SELECTED")
        SetTimer(() => RemoveToolTip(), -800)
    }
}

*c:: {
    ; Seleccionar columna completa (Ctrl+Space)
    VLogicCancel()
    OutputDebug("Excel V Logic: Selecting full COLUMN (Ctrl+Space)")
    Send("^{Space}")
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("EXCEL", "COLUMN SELECTED")
    } else {
        ShowCenteredToolTip("COLUMN SELECTED")
        SetTimer(() => RemoveToolTip(), -800)
    }
}

*v:: {
    ; Activar modo VV (visual selection)
    VLogicCancel()
    ToggleVVMode(true)
}

#HotIf
```

### Funciones de control (líneas 303-312)

```ahk
VLogicCancel() {
    global VLogicActive
    VLogicActive := false
}

VLogicTimeout() {
    VLogicCancel()
}
```

## Pruebas de funcionamiento

### Escenario 1: Selección de fila (`vr`)

1. Activar Excel layer (`leader → n`)
2. Presionar `v` (entra en V Logic mini-capa, timeout ~3s)
3. Presionar `r` → Debería:
   - Enviar `Shift+Space` a Excel
   - Seleccionar la fila completa
   - Mostrar tooltip "EXCEL: ROW SELECTED"
   - Salir de V Logic

### Escenario 2: Selección de columna (`vc`)

1. Activar Excel layer
2. Presionar `v`
3. Presionar `c` → Debería:
   - Enviar `Ctrl+Space` a Excel
   - Seleccionar la columna completa
   - Mostrar tooltip "EXCEL: COLUMN SELECTED"
   - Salir de V Logic

### Escenario 3: Modo visual (`vv`)

1. Activar Excel layer
2. Presionar `v`
3. Presionar `v` → Debería:
   - Activar modo VV
   - Mostrar tooltip "Excel VV" persistente
   - Permitir navegación con hjkl (con Shift para seleccionar)
   - Salir de V Logic

### Escenario 4: Timeout de V Logic

1. Activar Excel layer
2. Presionar `v`
3. Esperar ~3 segundos sin presionar nada
4. Resultado: V Logic se cancela automáticamente

### Escenario 5: Tecla `r` fuera de V Logic

1. Activar Excel layer
2. **Sin presionar `v`**, presionar `r` directamente
3. Resultado: Envía `Ctrl+Y` (Redo), acción normal de `r` en Excel layer

## Consideraciones de diseño

### 1. Patrón consistente con otras mini-capas

V Logic sigue el mismo patrón que:

- **NVIM `gg`**: Primera `g` activa mini-capa, segunda `g` ejecuta acción
- **NVIM `:`**: Activa colon mode para comandos extendidos
- **Excel VV mode**: `vv` activa modo visual con hjkl

### 2. Separación de contextos con #HotIf

Cada bloque de hotkeys tiene condiciones exclusivas:

- **Activación de V Logic** (línea 66): `!VLogicActive && !VVModeActive`
- **Dentro de V Logic** (línea 92): `VLogicActive`
- **Dentro de VV Mode** (línea 143): `VVModeActive`

Esto previene conflictos y permite que las teclas tengan diferentes funciones según el contexto activo.

### 3. InputLevel para resolver conflictos

La jerarquía de InputLevels es crítica:

- Sin ella, los hotkeys dinámicos del INI interferirían con las mini-capas
- Permite usar las mismas teclas (`r`, `c`, `v`) en diferentes contextos
- Facilita la extensibilidad (agregar más comandos a V Logic sin conflictos)

### 4. Timeout configurable

El timeout de V Logic usa `GetEffectiveTimeout("excel")`, que:

- Lee `[Excel] timeout_seconds` de `excel_layer.ini`
- Si no existe, usa `[Behavior] global_timeout_seconds` de `configuration.ini`
- Fallback por defecto: 3 segundos
- Permite ajustar la "ventana de oportunidad" según preferencias del usuario

## Debugging y diagnóstico

### OutputDebug logging

Cada acción de V Logic registra en el debugger:

```ahk
OutputDebug("Excel V Logic: Selecting full ROW (Shift+Space)")
```

Para ver estos logs:

- **Windows**: Usar [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview)
- **VSCode**: Extensión de AHK con output integrado

### Verificación de estado

Agregar hotkey temporal para inspección (útil durante desarrollo):

```ahk
F9:: {
    MsgBox("VLogicActive: " . VLogicActive . "`nVVModeActive: " . VVModeActive . "`nexcelLayerActive: " . excelLayerActive)
}
```

### Problemas comunes y soluciones

| Problema                       | Causa probable               | Solución                                                  |
| ------------------------------ | ---------------------------- | --------------------------------------------------------- |
| `vr` no funciona               | Conflicto de InputLevel      | Verificar que `ApplyExcelMappings()` use `#InputLevel 1`  |
| V Logic no se cancela          | Timeout mal configurado      | Verificar `to*1000` en `VLogicStart()`                    |
| Hotkeys no responden           | Contexto `#HotIf` incorrecto | Verificar condiciones y estado de variables globales      |
| Acciones se ejecutan dos veces | Falta `VLogicCancel()`       | Asegurar que cada acción llame a `VLogicCancel()` primero |

## Futuras mejoras

### 1. Visual feedback durante mini-capa

Mostrar un tooltip mientras V Logic está activa:

```ahk
*v:: {
    global VLogicActive, VVModeActive
    if (!VVModeActive) {
        VLogicActive := true
        ; Mostrar indicador visual
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowVLogicActiveCS() ; Nueva función a implementar
        }
        to := GetEffectiveTimeout("excel")
        try SetTimer(VLogicTimeout, -to*1000)
    }
}
```

### 2. Más comandos en V Logic

Expandir la mini-capa con más opciones:

- `vb` → Seleccionar rango (Shift+Ctrl+flechas)
- `va` → Seleccionar todo (Ctrl+A)
- `vt` → Seleccionar hasta fin de tabla (Ctrl+Shift+End)

### 3. Cancelación explícita con Esc

Agregar hotkey para salir manualmente:

```ahk
#HotIf (excelStaticEnabled ? (excelLayerActive && VLogicActive && ...) : false)
*Esc::VLogicCancel()
#HotIf
```

### 4. Configuración de timeout específico

Permitir timeout independiente para V Logic:

```ini
[Excel]
v_logic_timeout_seconds=2
```

## Conclusión

La mini-capa V Logic proporciona una interfaz compacta y eficiente para comandos de selección en Excel sin sacrificar teclas individuales. El fix de InputLevel fue crucial para resolver conflictos entre hotkeys dinámicos y mini-capas, estableciendo un patrón replicable para futuras implementaciones.

**Patrón clave aprendido**: Cuando se usan mini-capas o sub-modos, los hotkeys dinámicos deben registrarse con un InputLevel menor que las mini-capas para evitar interferencias.

---

**Autor**: Sistema HybridCapsLock  
**Fecha última actualización**: 2025-01-XX  
**Versión**: HybridCapsLock v2.0+  
**Archivos relacionados**:

- `src/layer/excel_layer.ahk`
- `src/core/mappings.ahk`
- `config/excel_layer.ini`
- `doc/EXCEL_LAYER.md`
