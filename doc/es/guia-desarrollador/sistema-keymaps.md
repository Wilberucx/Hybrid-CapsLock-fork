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

### 2. Sintaxis de Modificadores Estilo Vim (¡Nuevo!)

Ahora puedes usar sintaxis de modificadores estilo Vim para mejor legibilidad:

```ahk
; Sintaxis estilo Vim (recomendado para modificadores)
RegisterKeymap("leader", "<C-s>", "Guardar Todo", SaveAllFunc, false, 1)
RegisterKeymap("leader", "<S-C-a>", "Avanzado", AdvancedFunc, false, 2)
RegisterKeymap("leader", "<A-S-k>", "Especial", SpecialFunc, false, 3)

; Funciona también con triggers
RegisterTrigger("<C-F1>", ShowHelp, "AppActive")
```

**Mapeo de Modificadores:**
- `C` → Ctrl (`^`)
- `S` → Shift (`+`)
- `A` → Alt (`!`)

La UI mostrará la sintaxis original legible (`<C-a>`) mientras la ejecución usa el formato de AutoHotkey (`^a`).

### 3. Ayuda Dinámica de Layers

Presiona `?` en cualquier layer activo para ver todos los keybindings disponibles automáticamente:

```ahk
; ¡No requiere configuración! Funciona automáticamente en todos los layers
; Mientras estés en cualquier layer, presiona ? para ver ayuda
; Presiona Esc para cerrar la ayuda (el layer permanece activo)
```

Las categorías también muestran ayuda después de un timeout de 500ms para mejor descubrimiento.

### 4. Función clave: ListenForLayerKeymaps()

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

Usa `RegisterLayer(id, display_name, color_hex_background, color_hex_text)` para crear nuevos layers, más información en [layers](../guia-usuario/layers.md)

## Registro Declarativo de Triggers

Usa `RegisterTrigger()` para un registro limpio y declarativo de hotkeys globales:

```ahk
; Forma antigua (verbosa, no recomendada)
#SuspendExempt
#HotIf (LeaderLayerEnabled)
F24:: ActivateLeaderLayer()
#HotIf
#SuspendExempt False

; Forma nueva (declarativa, recomendada)
RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")
RegisterTrigger("F23", ActivateDynamicLayer, "DYNAMIC_LAYER_ENABLED")

; Funciona con sintaxis de modificadores también
RegisterTrigger("<C-F1>", ShowHelp)
```

**Beneficios:**
- Código más limpio y legible
- Manejo automático de SuspendExempt
- Consistente con el estilo de `RegisterKeymap()`
- Soporta sintaxis de modificadores estilo Vim

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
; F24 DEBE ser trigger (punto de entrada global)
RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")

; 's' PUEDE ser keymap (acción dentro de leader)
RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false)  // ← Usa el sistema
```

**Regla:**

- **Triggers = Entry points** (activan layers desde fuera)
- **Keymaps = Functions** (funcionan dentro de layers)

F24 es la puerta de entrada. La puerta no puede estar dentro de la casa que abre.

## Triggers Contextuales (Avanzado)

### Problema: Teclas Modificadoras y Limitaciones de InputHook

`RegisterKeymap()` usa `InputHook` internamente, el cual **no puede capturar combinaciones de modificadores** como `Ctrl+R`, `Alt+S`, etc. Solo captura:
- Teclas simples: `a`, `b`, `1`, `Escape`
- Combinaciones con Shift: `A` (mayúscula), `!` (Shift+1)

**InputHook NO PUEDE capturar:**
- `Ctrl+R`
- `Alt+S`
- `Ctrl+Shift+X`

### Solución: Triggers Contextuales con Detección Manual de Layer

Usá `RegisterTrigger()` para teclas modificadoras con detección manual del contexto de layer:

```ahk
; ❌ MAL: Esto no va a funcionar (limitación de InputHook)
RegisterKeymap("vim", "^r", "Rehacer", VimRedo)  // Ctrl+R nunca se captura

; ✅ BIEN: Usá RegisterTrigger con detección de contexto
RegisterTrigger("^r", CtrlRContextual, "")

CtrlRContextual() {
    global CurrentActiveLayer
    
    switch CurrentActiveLayer {
        case "vim":
            VimRedo()          // Ctrl+Y en vim
        case "explorer":
            Send("{F5}")       // Refresh en explorer
        default:
            Send("^r")         // Passthrough a la aplicación
    }
}
```

### Mejores Prácticas para Triggers Contextuales

#### 1. ⚠️ **UN TRIGGER POR COMBINACIÓN DE TECLAS**

**CRÍTICO:** Solo registrá UN `RegisterTrigger()` por combinación de hotkey. Múltiples registros causan conflictos:

```ahk
; ❌ MAL: Colisión de hotkeys (gana el último)
// En vim_actions.ahk:
RegisterTrigger("^r", VimCtrlR, "")

// En explorer_actions.ahk:
RegisterTrigger("^r", ExplorerCtrlR, "")  // ¡Sobrescribe el anterior!

; ✅ BIEN: Un solo trigger unificado en keymap.ahk
RegisterTrigger("^r", CtrlRContextual, "")

CtrlRContextual() {
    global CurrentActiveLayer
    switch CurrentActiveLayer {
        case "vim": VimRedo()
        case "explorer": Send("{F5}")
        default: Send("^r")
    }
}
```

#### 2. 📍 **Centralizar en keymap.ahk**

Para evitar colisiones y mantener claridad:
- **Teclas simples en layers** → Usá `RegisterKeymap()` en plugins
- **Teclas modificadoras con contexto** → Usá `RegisterTrigger()` unificado en `keymap.ahk`

```ahk
; En ahk/config/keymap.ahk:
RegisterTrigger("^r", CtrlRContextual, "")
RegisterTrigger("^s", CtrlSContextual, "")
RegisterTrigger("^w", CtrlWContextual, "")

; En plugins (vim_actions.ahk, explorer_actions.ahk):
; Solo registrá keymaps de teclas simples
RegisterKeymap("vim", "r", "Reemplazar", VimReplace)
RegisterKeymap("vim", "u", "Deshacer", VimUndo)
```

#### 3. 🔄 **Siempre Proporcionar Fallback**

Siempre incluí un caso `default` para hacer passthrough del hotkey cuando ningún layer coincide:

```ahk
CtrlRContextual() {
    global CurrentActiveLayer
    
    switch CurrentActiveLayer {
        case "vim": VimRedo()
        case "excel": ReloadWorkbook()
        default:
            Send("^r")  // ← IMPORTANTE: Passthrough a la app
    }
}
```

#### 4. 🚫 **Evitar Loops Infinitos**

**Problema potencial:** `Send("^r")` dentro de un hotkey `^r` puede crear loops infinitos.

**Protección de AutoHotkey:** AHK tiene protección interna contra reentry, pero no es 100% confiable.

**Solución robusta (si ocurren loops):** Modificar `RegisterTrigger` para usar el prefijo `$`:

```ahk
; En system/core/keymap_registry.ahk línea 943:
Hotkey("$" . parsedKey, (*) => action(), "S")  // $ previene que Send() retriggeree
```

El prefijo `$` hace que el hotkey **solo se active desde input físico del teclado**, no desde `Send()`.

### Resumen de Arquitectura

```
┌─────────────────────────────────────────────────────────┐
│                   INPUT DEL USUARIO                     │
└─────────────────────────────────────────────────────────┘
                          │
                ┌─────────┴─────────┐
                │                   │
         Tecla Simple         Tecla Modificadora
         (a, j, k)             (Ctrl+R, Alt+S)
                │                   │
                ▼                   ▼
         ┌─────────────┐     ┌──────────────┐
         │ InputHook   │     │ Hotkey()     │
         │ (en layer)  │     │ (global)     │
         └─────────────┘     └──────────────┘
                │                   │
                ▼                   ▼
    ┌────────────────────┐  ┌──────────────────────┐
    │ RegisterKeymap()   │  │ RegisterTrigger()    │
    │ ExecuteKeymapAtPath│  │ + Detección Contexto │
    └────────────────────┘  └──────────────────────┘
                │                   │
                └─────────┬─────────┘
                          ▼
                   ┌─────────────┐
                   │   ACCIÓN    │
                   └─────────────┘
```

### Ejemplo del Mundo Real

Desde `keymap.ahk`:

```ahk
; Triggers globales del sistema (sin contexto)
RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")
RegisterTrigger("F23", ActivateDynamicLayer, "DYNAMIC_LAYER_ENABLED")

; Teclas modificadoras con contexto
RegisterTrigger("^r", CtrlRContextual, "")

CtrlRContextual() {
    global CurrentActiveLayer
    
    switch CurrentActiveLayer {
        case "vim":
            VimRedo()           // De vim_actions.ahk
        case "explorer":
            Send("{F5}")        // Refresh Explorer
        default:
            Send("^r")          // Passthrough
    }
}
```

Desde `vim_actions.ahk`:

```ahk
; Teclas simples (funcionan vía InputHook en layer)
RegisterKeymap("vim", "r", "Reemplazar", VimReplace)
RegisterKeymap("vim", "u", "Deshacer", VimUndo)
RegisterKeymap("vim", "j", "Abajo", VimDown)
RegisterKeymap("vim", "k", "Arriba", VimUp)

; Teclas modificadoras manejadas en keymap.ahk vía RegisterTrigger
; (ver CtrlRContextual arriba)
```
