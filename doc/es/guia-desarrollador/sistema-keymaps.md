# Sistema Unificado de Keymaps

## Filosofía

**Un solo sistema** para todos los tipos de layers:

- **Leader** (temporal/jerárquico) - Navegación con timeout
- **Persistent Layers** (RegisterLayers) - Sin timeout, permanecen activas

Ambos usan la **misma infraestructura**:

- `KeymapRegistry` - Storage único
- `ExecuteKeymapAtPath()` - Ejecución única
- `RegisterKeymap()` - Registro único

## Componentes

### 1. keymap_registry.ahk

#### Para Leader

```ahk
RegisterKeymap("leader", "s", "Scroll Layer", ActivateScrollLayer, false)
NavigateHierarchical("leader")  // Loop con timeout
```

#### Para Persistent Layers

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

#### config/keymap.ahk

Archivo donde se centraliza los keymaps.

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

## Diferencias: Leader vs Persistent Layers

| Aspecto        | Leader                     | Persistent Layers          |
| -------------- | -------------------------- | -------------------------- |
| **Duración**   | Temporal (con timeout)     | Permanente (hasta salir)   |
| **Navegación** | Jerárquica (categorías)    | Plana (solo acciones)      |
| **Función**    | `NavigateHierarchical()`   | `ListenForLayerKeymaps()`  |
| **Timeout**    | Sí (configurable)          | No                         |
| **Storage**    | `KeymapRegistry["leader"]` | `KeymapRegistry["scroll"]` |
| **Ejecución**  | `ExecuteKeymapAtPath()`    | `ExecuteKeymapAtPath()`    |

## Separación: Acciones vs Layers

### Concepto Clave

**Layers = Contexto** | **Plugins = Funciones reutilizables**

#### src/actions/ - Acciones genéricas reutilizables

```ahk
; scroll_actions.ahk - Pueden usarse en cualquier layer
ScrollUp() => Send("{WheelUp}")
ScrollDown() => Send("{WheelDown}")
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

Usa `RegisterLayer(id, display_name, color_hex_background, color_hex_text)` para crear nuevos layers, más información en [layers](doc/es/guia-usuario/layers.md)

## Hotkeys vs Keymaps

### ¿Por qué F24 no puede ser un keymap?

**F24 es el TRIGGER EXTERNO** que activa leader desde fuera del sistema:

```
Kanata (hardware) → F24 → ActivateLeaderLayer() → NavigateHierarchical()
                    ↑                               ↑
                 HOTKEY                         USA KEYMAPS
```

**Keymaps solo funcionan DENTRO de layers activos:**

```ahk
; F24 DEBE ser hotkey (global trigger)
F24:: ActivateLeaderLayer()  // ← Activa el sistema

; 's' PUEDE ser keymap (acción dentro de leader)
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false)  // ← Usa el sistema
```

**Regla:**

- **Hotkeys = Entry points** (activan layers)
- **Keymaps = Functions** (funcionan dentro de layers)

F24 es la puerta de entrada. La puerta no puede estar dentro de la casa que abre.
