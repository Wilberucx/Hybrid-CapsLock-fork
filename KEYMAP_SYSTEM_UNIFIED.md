# Sistema Unificado de Keymaps

## Filosofía

**Un solo sistema** para todos los tipos de layers:
- **Leader** (temporal/jerárquico) - Navegación con timeout
- **Persistent Layers** (scroll, nvim, excel, etc.) - Sin timeout, permanecen activas

Ambos usan la **misma infraestructura**:
- `KeymapRegistry` - Storage único
- `ExecuteKeymapAtPath()` - Ejecución única
- `RegisterKeymap()` - Registro único

## Componentes

### 1. keymap_registry.ahk

#### Para Leader (ya existía):
```ahk
RegisterKeymap("leader", "s", "Scroll Layer", ActivateScrollLayer, false)
NavigateHierarchical("leader")  // Loop con timeout
```

#### Para Persistent Layers (nuevo):
```ahk
RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false)
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
ListenForLayerKeymaps("scroll", "isScrollLayerActive")  // Loop sin timeout
```

### 2. Función clave: ListenForLayerKeymaps()

```ahk
ListenForLayerKeymaps(layerName, layerActiveVarName) {
    Loop {
        // Verificar si layer sigue activa
        if (!%layerActiveVarName%)
            break
        
        // Esperar input (sin timeout)
        ih := InputHook("L1", "{Escape}")
        ih.Wait()
        
        key := ih.Input
        
        // Ejecutar usando la MISMA infraestructura que leader
        ExecuteKeymapAtPath(layerName, key)
    }
}
```

## Implementación: Scroll Layer

### Antes (❌ Hardcoded):
```ahk
#HotIf (scrollLayerActive)
h::Send("+{WheelUp}")
j::Send("{WheelDown}")
k::Send("{WheelUp}")
l::Send("+{WheelDown}")
#HotIf
```

### Después (✅ Declarativo):

#### src/actions/scroll_actions.ahk:
```ahk
; Reusable scroll actions
ScrollUp() => Send("{WheelUp}")
ScrollDown() => Send("{WheelDown}")
ScrollLeft() => Send("+{WheelUp}")
ScrollRight() => Send("+{WheelDown}")
```

#### src/layer/scroll_layer.ahk:
```ahk
; Layer-specific control (no duplicated actions)
ScrollExit() {
    isScrollLayerActive := false
    ReturnToPreviousLayer()
}

; Hook de activación
OnScrollLayerActivate() {
    isScrollLayerActive := true
    ListenForLayerKeymaps("scroll", "isScrollLayerActive")  // ← Usa el sistema existente
    isScrollLayerActive := false
}
```

#### config/keymap.ahk:
```ahk
InitializeCategoryKeymaps() {
    // ... otros keymaps ...
    
    ; Scroll layer keymaps (actions from scroll_actions.ahk)
    RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false)
    RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
    RegisterKeymap("scroll", "k", "Scroll Up", ScrollUp, false)
    RegisterKeymap("scroll", "l", "Scroll Right", ScrollRight, false)
    RegisterKeymap("scroll", "s", "Exit", ScrollExit, false)
    RegisterKeymap("scroll", "Escape", "Exit", ScrollExit, false)
}
```

## Ventajas

1. **Single Source of Truth**: RegisterKeymap() define TODO (tecla, nombre, función)
2. **Sin duplicación**: No más #HotIf + comentarios separados
3. **Tooltips automáticos**: El sistema puede generar ayuda desde el registry
4. **Consistencia**: Mismo patrón para todas las layers
5. **Menos código**: 87 líneas de `ListenForLayerKeymaps()` vs 300+ de `dynamic_hotkeys.ahk`
6. **Reusa infraestructura**: ExecuteKeymapAtPath() ya está probado
7. **Acciones reutilizables**: ScrollUp() se puede usar en cualquier layer
8. **Escape funciona**: Ejecuta el keymap registrado en lugar de salir directamente
9. **Template para layers**: Crear nuevos layers es copiar y reemplazar nombres

## Diferencias: Leader vs Persistent Layers

| Aspecto | Leader | Persistent Layers |
|---------|--------|-------------------|
| **Duración** | Temporal (con timeout) | Permanente (hasta salir) |
| **Navegación** | Jerárquica (categorías) | Plana (solo acciones) |
| **Función** | `NavigateHierarchical()` | `ListenForLayerKeymaps()` |
| **Timeout** | Sí (configurable) | No |
| **Storage** | `KeymapRegistry["leader"]` | `KeymapRegistry["scroll"]` |
| **Ejecución** | `ExecuteKeymapAtPath()` | `ExecuteKeymapAtPath()` |

## Separación: Acciones vs Layers

### Concepto Clave

**Layers = Contexto** | **Actions = Funciones reutilizables**

#### src/actions/ - Acciones genéricas reutilizables
```ahk
; scroll_actions.ahk - Pueden usarse en cualquier layer
ScrollUp() => Send("{WheelUp}")
ScrollDown() => Send("{WheelDown}")
```

#### src/layer/ - Control del layer (contexto)
```ahk
; scroll_layer.ahk - Solo control del layer
ScrollExit() {
    isScrollLayerActive := false
    ReturnToPreviousLayer()
}
```

### Misma Tecla, Diferentes Layers, Diferentes Acciones

```ahk
; 'i' hace cosas diferentes según el contexto
RegisterKeymap("nvim", "i", "Insert Mode", NvimEnterInsert, false)
RegisterKeymap("excel", "i", "Edit Cell", ExcelEditCell, false)  // ← F2 + exit layer
RegisterKeymap("visual", "i", "Inner Object", VisualInnerObject, false)

; 'j' también depende del contexto
RegisterKeymap("nvim", "j", "Move Down", VimMoveDown, false)
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
```

**La capa define QUÉ hace cada tecla.**

## Creación Dinámica de Layers

### Template System

Usa `src/layer/_layer_template.ahk` para crear nuevos layers:

```bash
# Crear nuevo layer "excel"
sed -e 's/LAYER_NAME/excel/g' -e 's/LAYER_DISPLAY/Excel Layer/g' \
    src/layer/_layer_template.ahk > src/layer/excel_layer.ahk
```

### Patrón de Nombres

| Elemento | Patrón | Ejemplo |
|----------|--------|---------|
| Layer name | `{name}` | `scroll` |
| Enabled flag | `{name}LayerEnabled` | `scrollLayerEnabled` |
| Active state | `is{Name}LayerActive` | `isScrollLayerActive` |
| Activation | `Activate{Name}Layer()` | `ActivateScrollLayer()` |
| Hook activate | `On{Name}LayerActivate()` | `OnScrollLayerActivate()` |
| Hook deactivate | `On{Name}LayerDeactivate()` | `OnScrollLayerDeactivate()` |
| Exit action | `{Name}Exit()` | `ScrollExit()` |

**Ver:** `doc/CREATING_NEW_LAYERS.md` para guía completa

## Próximos pasos

1. ✅ Scroll layer migrado
2. ✅ Escape fix aplicado
3. ✅ Acciones movidas a actions/
4. ✅ Template system creado
5. ⏳ Nvim layer migración
6. ⏳ Excel layer migración
7. ⏳ Visual layer migración
8. ⏳ Insert layer migración

## Testing

Para probar el scroll layer:

1. Activar con `Leader + s`
2. Usar teclas: `h` (left), `j` (down), `k` (up), `l` (right)
3. Ver ayuda con `?`
4. Salir con `s` o `Escape`

Revisar logs en OutputDebug:
```
[LayerListener] Starting listener for layer: scroll
[LayerListener] Key pressed: j in layer: scroll
[LayerListener] Stopped listener for layer: scroll
```
