# Crear Nuevas Capas Persistentes

## Resumen

Esta guía explica cómo crear nuevas capas persistentes usando el sistema unificado de keymaps.

## Pasos Básicos

### 1. Crear el Archivo de Capa

Crea un nuevo archivo en `src/layer/` con el nombre de tu capa:

```ahk
; src/layer/mi_capa.ahk

; ============================================================================
; Mi Capa - Descripción breve
; ============================================================================

global MI_CAPA_ACTIVE := false

; ============================================================================
; Inicialización
; ============================================================================

InitMiCapa() {
    ; Registrar keymaps
    RegisterKeymaps("mi_capa", [
        {key: "h", desc: "Acción izquierda", action: "Send {Left}"},
        {key: "j", desc: "Acción abajo", action: "Send {Down}"},
        {key: "k", desc: "Acción arriba", action: "Send {Up}"},
        {key: "l", desc: "Acción derecha", action: "Send {Right}"}
    ])
    
    OutputDebug("Mi Capa inicializada")
}

; ============================================================================
; Activación/Desactivación
; ============================================================================

ActivateMiCapa() {
    if (MI_CAPA_ACTIVE) {
        return
    }
    
    MI_CAPA_ACTIVE := true
    ActivateLayer("mi_capa")
    
    ; Mostrar tooltip
    ShowLayerTooltip("MI CAPA ACTIVA")
    
    OutputDebug("Mi Capa activada")
}

DeactivateMiCapa() {
    if (!MI_CAPA_ACTIVE) {
        return
    }
    
    MI_CAPA_ACTIVE := false
    DeactivateLayer("mi_capa")
    
    ; Ocultar tooltip
    HideLayerTooltip()
    
    OutputDebug("Mi Capa desactivada")
}

ToggleMiCapa() {
    if (MI_CAPA_ACTIVE) {
        DeactivateMiCapa()
    } else {
        ActivateMiCapa()
    }
}

; ============================================================================
; Llamar inicialización
; ============================================================================

InitMiCapa()
```

### 2. El Auto-Loader se Encarga del Resto

¡Eso es todo! El sistema auto-loader:
- Detectará automáticamente tu archivo en `src/layer/`
- Lo incluirá en el siguiente reload
- Llamará a `InitMiCapa()` automáticamente

### 3. Asignar Hotkey de Activación

Edita `config/keymap.ahk` para agregar un hotkey que active tu capa:

```ahk
; Activar Mi Capa con F13
F13::ToggleMiCapa()
```

O usa Kanata para mapear una combinación de teclas a F13.

## Características Avanzadas

### Keymaps Contextuales

Puedes hacer que los keymaps solo funcionen en ciertas aplicaciones:

```ahk
RegisterKeymaps("mi_capa", [
    {
        key: "s", 
        desc: "Guardar", 
        action: "Send ^s",
        context: "ahk_exe code.exe"  ; Solo en VS Code
    }
])
```

### Acciones Personalizadas

En lugar de `Send`, puedes llamar funciones:

```ahk
RegisterKeymaps("mi_capa", [
    {
        key: "g", 
        desc: "Acción personalizada", 
        action: () => MiFuncionPersonalizada()
    }
])

MiFuncionPersonalizada() {
    MsgBox("¡Hola desde mi capa!")
}
```

### Mini-Capas

Puedes crear mini-capas temporales dentro de tu capa:

```ahk
; En mi_capa.ahk
RegisterKeymaps("mi_capa", [
    {key: "g", desc: "Prefijo G", action: () => ActivateMiniG()}
])

ActivateMiniG() {
    ; Activar mini-capa temporal con timeout
    Input, OutputVar, L1 T2  ; Esperar 1 tecla, timeout 2s
    
    if (OutputVar = "g") {
        Send {Home}  ; gg = ir al inicio
    } else if (OutputVar = "e") {
        Send {End}   ; ge = ir al final
    }
}
```

## Sistema Declarativo

El sistema usa un enfoque declarativo inspirado en `lazy.nvim` y `which-key`:

- **Separación de responsabilidades**: La definición de keymaps está separada de la implementación
- **Auto-documentación**: Cada keymap incluye su descripción
- **Tooltips automáticos**: El sistema genera tooltips basándose en las descripciones
- **Validación**: El sistema verifica que no haya conflictos de teclas

## Funciones Disponibles

Ver la [Referencia de Funciones de Capas](referencia-funciones-capas.md) para la lista completa de funciones helper disponibles.

## Ejemplos

- **[Capa Nvim](../../es/guia-usuario/capa-nvim.md)** - Navegación estilo Vim
- **[Capa Excel](../../es/guia-usuario/capa-excel.md)** - Productividad en Excel

## Mejores Prácticas

1. **Usa nombres descriptivos** - `mi_capa_productividad` es mejor que `layer1`
2. **Documenta cada keymap** - Las descripciones ayudan a recordar los atajos
3. **Agrupa funcionalidad** - No mezcles navegación con acciones de texto
4. **Prueba exhaustivamente** - Verifica que no haya conflictos con otras capas
5. **Usa el sistema declarativo** - No crees hotkeys manuales si puedes usar `RegisterKeymaps()`

## Troubleshooting

### La capa no se activa

1. Verifica que el archivo esté en `src/layer/` (no en `src/layer/no_include/`)
2. Reload HybridCapslock con `Ctrl+Alt+R`
3. Revisa el log: `OutputDebug` muestra mensajes en DebugView

### Los keymaps no funcionan

1. Verifica que la capa esté activa: `OutputDebug("Capa activa: " . MI_CAPA_ACTIVE)`
2. Verifica que no haya conflictos con otras capas
3. Usa el [Sistema de Debug](../../en/reference/debug-system.md)

---

**Ver también:**
- **[Sistema de Keymaps](sistema-keymaps.md)** - Documentación del sistema unificado
- **[Referencia de Funciones](referencia-funciones-capas.md)** - API completa
- **[Sistema Auto-Loader](../guia-desarrollador/sistema-auto-loader.md)** - Cómo funciona la carga automática

**[🌍 View in English](../../en/developer-guide/creating-layers.md)** | **[← Volver al Índice](../README.md)**
