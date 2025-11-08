# Arquitectura del Directorio `src/`

## 🎯 Overview

El directorio `src/` contiene toda la lógica modular de HybridCapsLock, organizada en 4 subdirectorios principales que separan claramente las responsabilidades:

```
src/
├── actions/        ← Funciones reutilizables (building blocks)
├── core/           ← Sistema central (config, registry, auto-loader)
├── layer/          ← Capas/Modos persistentes (nvim, excel, scroll)
└── ui/             ← Interfaz de usuario (tooltips, notificaciones)
```

---

## 📦 `src/actions/` - Funciones Reutilizables

### **Definición**
Funciones **puras y reutilizables** que NO dependen de contexto específico. Son los "building blocks" que pueden ser usados por múltiples layers.

### **Características**
- ✅ **Independientes**: No saben en qué layer se usan
- ✅ **Reutilizables**: Pueden ser llamadas desde cualquier layer
- ✅ **Sin estado global**: No dependen de variables específicas de un layer
- ✅ **Una responsabilidad**: Cada función hace UNA cosa específica

### **Tipos de Actions**

#### **1. Vim Actions (navegación estilo Vim)**
- **`vim_nav.ahk`**: Navegación básica sin selección
  - `VimMoveLeft()`, `VimMoveRight()`, `VimMoveUp()`, `VimMoveDown()`
  - `VimWordForward()`, `VimWordBackward()`, `VimEndOfWord()`
  - `VimStartOfLine()`, `VimEndOfLine()`
  - `VimTopOfFile()`, `VimBottomOfFile()`

- **`vim_visual.ahk`**: Navegación con selección (Shift+arrows)
  - `VimVisualMoveLeft()`, `VimVisualMoveRight()`, etc.
  - `VimVisualWordForward()`, `VimVisualWordBackward()`
  - `VimVisualTopOfFile()`, `VimVisualBottomOfFile()`

- **`vim_edit.ahk`**: Operaciones de edición
  - `VimYank()`, `VimPaste()`, `VimPastePlain()`
  - `VimUndo()`, `VimRedo()`
  - `VimDeleteCurrentWord()`, `VimDeleteCurrentLine()`
  - `VimCopyCurrentWord()`, `VimCopyCurrentLine()`

#### **2. Domain-Specific Actions**
- **`windows_actions.ahk`**: Gestión de ventanas
  - `MaximizeWindow()`, `MinimizeWindow()`, `CloseWindow()`
  - `SwitchToVirtualDesktop()`, `CreateVirtualDesktop()`
  - `MoveWindowToDesktop()`, `SnapWindowLeft()`, `SnapWindowRight()`

- **`system_actions.ahk`**: Comandos del sistema
  - `OpenTaskManager()`, `OpenSettings()`, `OpenSystemInfo()`
  - `RestartComputer()`, `ShutdownComputer()`, `LockScreen()`

- **`git_actions.ahk`**: Operaciones Git
  - `GitStatus()`, `GitCommit()`, `GitPush()`, `GitPull()`
  - `GitCheckoutBranch()`, `GitCreateBranch()`

- **`network_actions.ahk`**: Operaciones de red
  - `PingHost()`, `ShowIPConfig()`, `FlushDNS()`
  - `CheckNetworkConnectivity()`, `RestartNetwork()`

- **`power_actions.ahk`**: Gestión de energía
  - `Sleep()`, `Hibernate()`, `Restart()`, `Shutdown()`
  - `ChangePowerPlan()`, `LockAndSleep()`

- **`monitoring_actions.ahk`**: Monitoreo del sistema
  - `ShowCPUUsage()`, `ShowMemoryUsage()`, `ShowDiskSpace()`
  - `OpenResourceMonitor()`, `OpenPerformanceMonitor()`

- **`folder_actions.ahk`**: Navegación de carpetas
  - `OpenDocuments()`, `OpenDownloads()`, `OpenDesktop()`
  - `OpenProgramFiles()`, `OpenAppData()`, `OpenTemp()`

- **`adb_actions.ahk`**: Android Debug Bridge
  - `ADBDevices()`, `ADBConnect()`, `ADBScreenshot()`
  - `ADBInstallAPK()`, `ADBLogcat()`

- **`vaultflow_actions.ahk`**: Acciones específicas de VaultFlow (proyecto)
  - Funciones personalizadas del proyecto

- **`hybrid_actions.ahk`**: Acciones del sistema Hybrid
  - `PauseHybrid()`, `ResumeHybrid()`, `ReloadHybrid()`
  - `RestartKanata()`, `ShowHybridConfig()`

#### **3. Layer Helpers (específicos de un layer)**
- **`nvim_layer_helpers.ahk`**: Funciones SOLO para nvim_layer
  - `NvimDirectionalSend()` - Con soporte de VisualMode
  - `NvimWordJumpHelper()` - Con soporte de VisualMode
  - `ColonLogic*()` - Sistema :wq
  - `GLogic*()` - Sistema gg
  - `NvimShowHelp()`, `VisualShowHelp()`

### **Cuándo Crear un Action**
- ✅ La función se usa en **2+ layers diferentes**
- ✅ La función es **genérica** (no depende de estado específico)
- ✅ La función hace **UNA cosa específica**
- ✅ La función puede ser **probada independientemente**

### **Cuándo NO crear un Action**
- ❌ La función solo se usa en **un layer específico** → Va en el layer
- ❌ La función depende de **estado global del layer** → Va en helpers
- ❌ La función es un **wrapper trivial** → Define inline en el layer

### **Ejemplo de Uso**
```ahk
; En nvim_layer.ahk
#Include src\actions\vim_nav.ahk
#Include src\actions\vim_edit.ahk

#HotIf (isNvimLayerActive)
h::VimMoveLeft()        ; Reutiliza vim_nav.ahk
j::VimMoveDown()
y::VimYank()            ; Reutiliza vim_edit.ahk
p::VimPaste()
#HotIf

; En excel_layer.ahk
#Include src\actions\vim_nav.ahk

#HotIf (excelLayerActive)
h::VimMoveLeft()        ; REUTILIZA la misma función
j::VimMoveDown()
#HotIf
```

---

## ⚙️ `src/core/` - Sistema Central

### **Definición**
Módulos fundamentales que proveen la **infraestructura base** del sistema. Son cargados primero y usados por todos los demás componentes.

### **Módulos Core**

#### **1. `globals.ahk`**
- Variables globales compartidas por todo el sistema
- Estados de capas: `isNvimLayerActive`, `excelLayerActive`, `VisualMode`
- Flags de configuración: `nvimLayerEnabled`, `debug_mode`
- Estados temporales: `_tempEditMode`, `leaderActive`

#### **2. `config.ahk`**
- Carga de archivos `.ini` (configuración)
- `LoadLayerFlags()` - Lee config/global.ini
- `GetEffectiveTimeout()` - Obtiene timeouts configurables
- Parser de configuración para cada layer

#### **3. `persistence.ahk`**
- Guardado de estado entre sesiones
- `SaveLayerState()` - Guarda estado de layers
- `LoadLayerState()` - Restaura estado al inicio
- Memoria de configuraciones del usuario

#### **4. `keymap_registry.ahk`**
- **Registro declarativo de keymaps** (sistema which-key)
- `RegisterKeymap()` - Registra acción o categoría
- `RegisterKeymapFlat()` - Registro simplificado
- `RegisterCategoryKeymap()` - Registra categoría
- `ExecuteKeymapAtPath()` - Ejecuta keymap por path
- `KeymapRegistry` - Map global de todos los keymaps

#### **5. `command_system_init.ahk`**
- Inicialización del sistema declarativo
- `InitializeCommandSystem()` - Setup completo
- Llama a todos los `Register*Keymaps()` de actions
- Conecta actions con el leader menu

#### **6. `mappings.ahk`**
- Sistema de mappings dinámicos (opcional)
- `LoadSimpleMappings()` - Carga desde .ini
- `ApplyGenericMappings()` - Aplica hotkeys dinámicos
- Permite customización sin tocar código

#### **7. `kanata_launcher.ahk`**
- Lanzador de Kanata (teclado remapper)
- `StartKanataIfNeeded()` - Inicia Kanata al arrancar
- `RestartKanata()` - Reinicia proceso de Kanata
- Integración con hardware-level remapping

#### **8. `confirmations.ahk`**
- Diálogos de confirmación para acciones peligrosas
- `ConfirmAction()` - Pide confirmación al usuario
- Usado en shutdown, restart, delete, etc.

#### **9. `auto_loader.ahk`** ⭐ NUEVO
- **Auto-discovery de actions y layers**
- `AutoLoaderInit()` - Escanea y auto-incluye archivos
- `GetHardcodedIncludes()` - Detecta includes manuales
- `DetectChanges()` - Encuentra archivos nuevos/eliminados
- `ApplyChanges()` - Actualiza init.ahk automáticamente
- Memoria JSON: `data/auto_loader_memory.json`
- **Elimina duplicación** de includes hardcoded

### **Orden de Carga (Crítico)**
```ahk
1. kanata_launcher.ahk    ← Inicia Kanata primero
2. globals.ahk            ← Variables globales
3. config.ahk             ← Carga configuración
4. persistence.ahk        ← Restaura estado
5. confirmations.ahk      ← Diálogos
6. keymap_registry.ahk    ← Registro de keymaps
7. mappings.ahk           ← Mappings dinámicos
8. auto_loader.ahk        ← Auto-discovery
```

### **Responsabilidades**
- ✅ Proveer infraestructura base
- ✅ Gestionar estado global
- ✅ Cargar y guardar configuración
- ✅ Registrar sistema de keymaps
- ✅ Auto-descubrir y cargar módulos

---

## 🎭 `src/layer/` - Capas/Modos Persistentes

### **Definición**
**Capas modales** que cambian el comportamiento del teclado según el contexto. Similar a los modos de Vim (Normal, Insert, Visual).

### **Tipos de Layers**

#### **1. Persistent Layers (Modos Persistentes)**
Permanecen activos hasta que el usuario los desactive explícitamente.

##### **`nvim_layer.ahk`** - Navegación estilo Vim
- **Activación**: F23 (CapsLock tap desde Kanata) - toggle
- **Exit**: F23 de nuevo (toggle off)
- **Características**:
  - Navegación hjkl persistente
  - Visual Mode (v) para selección
  - Insert Mode (i/I) temporal
  - Colon Commands (:w, :q, :wq)
  - G Logic (gg para top)
  - Word jumps (w/b/e)
- **Usa**: `vim_nav.ahk`, `vim_edit.ahk`, `vim_visual.ahk`, `nvim_layer_helpers.ahk`

##### **`excel_layer.ahk`** - Navegación en Excel
- **Activación**: Desde leader menu o shortcut
- **Exit**: Shift+n (customizable)
- **Características**:
  - Numpad en mano izquierda (qweasd = 456789)
  - Navegación hjkl en celdas
  - Visual mode para selección de rangos (vv/vr/vc)
  - Funciones de Excel (F2, Ctrl+G, etc.)
- **Específico**: Solo activo en Excel/Calc

##### **`scroll_layer.ahk`** - Scroll rápido
- **Activación**: Leader -> s
- **Exit**: s de nuevo (same-key toggle)
- **Características**:
  - j/k para scroll vertical
  - h/l para scroll horizontal
- **Simple**: Solo scrolling

#### **2. Mini-Layers (Navegación Temporal)**
Se activan temporalmente y auto-cierran con timeout o acción.

##### **`leader_router.ahk`** - Leader Menu (which-key)
- **Activación**: Hold CapsLock + Space (F24 desde Kanata)
- **Exit**: Timeout, Escape, o ejecutar acción
- **Características**:
  - Navegación jerárquica (categorías + acciones)
  - Auto-generado desde KeymapRegistry
  - Tooltips C# con menú visual
  - Back con Backspace o `\`
- **100% Genérico**: Lee del registry, zero hardcoding

##### **`windows_layer.ahk`** - Gestión de ventanas
- **Activación**: Leader -> w
- **Características**:
  - Keymaps para maximizar, minimizar, cerrar
  - Snap windows (left/right/corners)
  - Virtual desktops
  - Zoom controls
- **Registrado en**: `command_system_init.ahk`

##### **`commands_layer.ahk`** - Comandos del sistema
- **Activación**: Leader -> c
- **Características**:
  - Lanzar CMD, PowerShell, Terminal
  - Comandos de sistema rápidos
  - Menú jerárquico de comandos

##### **`programs_layer.ahk`** - Lanzador de apps
- **Activación**: Leader -> p
- **Características**:
  - Shortcuts a aplicaciones frecuentes
  - Configurable vía .ini

##### **`timestamps_layer.ahk`** - Inserción de fechas
- **Activación**: Leader -> t
- **Características**:
  - Múltiples formatos de fecha/hora
  - Timestamps ISO, US, EU, etc.

##### **`information_layer.ahk`** - Snippets personales
- **Activación**: Leader -> i
- **Características**:
  - Información personal (email, teléfono)
  - Snippets de texto frecuentes
  - Configurable en .ini

#### **3. Utility Layers**

##### **`window_shortcuts.ahk`** - Shortcuts globales
- Atajos de teclado siempre activos
- No es modal, siempre disponible

### **Estructura de un Layer**

Siguiendo el **template** (`doc/templates/layer_template.ahk`):

```ahk
; Configuración
LAYER_NAME := "MyLayer"
global myLayerEnabled := true
global myLayerActive := false

; Activación/Desactivación
ActivateMyLayer() { ... }
DeactivateMyLayer() { ... }

; Hotkeys (solo activos cuando layer está ON)
#HotIf (myLayerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed())
h::VimMoveLeft()    ; Usa actions reutilizables
j::VimMoveDown()
; ...
#HotIf

; Exit key configurable
Esc::DeactivateMyLayer()

; Help system
?::LayerShowHelp()

; App filtering
LayerAppAllowed() { ... }
```

### **Diferencia: Persistent vs Mini-Layer**

| Aspecto | Persistent Layer | Mini-Layer (Leader) |
|---------|-----------------|---------------------|
| **Duración** | Hasta exit explícito | Timeout o acción |
| **Exit** | Key específico (Esc, Shift+n) | Timeout, acción ejecutada |
| **Ejemplo** | NVIM, Excel, Scroll | Windows, Commands, Programs |
| **Tooltip** | Status persistente | Menú de opciones |
| **Uso** | Workflow extendido | Acción rápida |

### **Cuándo Crear un Layer**
- ✅ Necesitas un **conjunto de hotkeys relacionados**
- ✅ Los hotkeys solo tienen sentido en **cierto contexto**
- ✅ Quieres un **modo persistente** (como Vim modes)
- ✅ Necesitas **context-aware behavior**

### **Cuándo NO crear un Layer**
- ❌ Solo 1-2 hotkeys → Usa `window_shortcuts.ahk`
- ❌ Acción única → Usa action + register en leader menu
- ❌ Siempre activo → No es modal, no es layer

---

## 🎨 `src/ui/` - Interfaz de Usuario

### **Definición**
Módulos que gestionan la **presentación visual** y notificaciones al usuario.

### **Módulos UI**

#### **1. `tooltip_csharp_integration.ahk`**
- **Integración con tooltip_csharp.exe** (aplicación C#)
- Tooltips modernos con diseño profesional
- `ShowCSharpOptionsMenu()` - Menú tipo which-key
- `ShowCSharpStatusNotification()` - Notificaciones de estado
- `ShowBottomRightListTooltip()` - Lista en esquina
- `HideCSharpTooltip()` - Ocultar tooltip
- `StartTooltipApp()` - Iniciar proceso C#

#### **2. `tooltips_native_wrapper.ahk`**
- **Wrapper para tooltips nativos de AHK** (fallback)
- `ShowCenteredToolTip()` - Tooltip centrado
- `ShowNvimLayerStatus()` - Status de NVIM layer
- `ShowVisualModeStatus()` - Status de Visual Mode
- `ShowExcelLayerStatus()` - Status de Excel layer
- `RemoveToolTip()` - Limpiar tooltip
- `SetTempStatus()` - Mensaje temporal

#### **3. `scroll_tooltip_integration.ahk`**
- Tooltips específicos para scroll layer
- `ShowScrollLayerStatus()` - Status de scroll
- Integración con C# si disponible

### **Sistema de Tooltips**

#### **Prioridad:**
```
1. C# Tooltips (si tooltip_csharp.exe está disponible)
   ↓
2. Native AHK Tooltips (fallback)
```

#### **Código Típico:**
```ahk
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    ShowCSharpStatusNotification("LAYER", "ACTIVE")
} else {
    ShowCenteredToolTip("LAYER ACTIVE")
    SetTimer(() => RemoveToolTip(), -1500)
}
```

### **Tipos de Tooltips**

#### **1. Status Notifications** (esquina superior derecha)
```ahk
ShowCSharpStatusNotification("NVIM", "ON")
ShowCSharpStatusNotification("EXCEL", "LAYER ACTIVE")
```

#### **2. Options Menu** (centro, estilo which-key)
```ahk
ShowCSharpOptionsMenu(
    "WINDOWS",                           ; Título
    "m:Maximize|n:Minimize|c:Close",     ; Items
    "ESC: Cancel"                         ; Footer
)
```

#### **3. Bottom Right List** (esquina inferior derecha)
```ahk
ShowBottomRightListTooltip(
    "CMD",                    ; Título
    "w:Save|q:Quit|wq:Both", ; Items
    "Enter: Execute",         ; Footer
    0                         ; Timeout (0 = persistente)
)
```

#### **4. Centered Tooltip** (centro, nativo)
```ahk
ShowCenteredToolTip("MESSAGE TEXT")
SetTimer(() => RemoveToolTip(), -1500)
```

### **Configuración**
```ahk
; En config/global.ini o similar
[Tooltips]
enabled=true              ; Usar C# tooltips
optionsTimeout=8000       ; Timeout para menús (ms)
statusTimeout=2000        ; Timeout para notificaciones
```

### **Responsabilidades**
- ✅ Mostrar información visual al usuario
- ✅ Menús de navegación (which-key style)
- ✅ Notificaciones de estado
- ✅ Feedback de acciones
- ✅ Help systems

---

## 🏗️ Arquitectura General

### **Flujo de Carga (init.ahk)**
```
1. Core (infraestructura)
   ├── kanata_launcher
   ├── globals
   ├── config
   ├── persistence
   ├── keymap_registry
   ├── mappings
   └── auto_loader ⭐

2. Actions (building blocks)
   ├── vim_nav, vim_edit, vim_visual
   ├── windows_actions
   ├── system_actions
   ├── ... (auto-loaded) ⭐
   └── nvim_layer_helpers

3. UI (presentación)
   ├── tooltip_csharp_integration
   ├── tooltips_native_wrapper
   └── scroll_tooltip_integration

4. Layers (modos)
   ├── leader_router
   ├── nvim_layer
   ├── excel_layer
   ├── windows_layer
   ├── ... (auto-loaded) ⭐
   └── scroll_layer

5. Startup Logic
   ├── AutoLoaderInit() ⭐
   ├── StartKanataIfNeeded()
   ├── Register*Keymaps()
   ├── LoadLayerState()
   └── InitializeCommandSystem()
```

### **Dependencias**

```
Layers
  ↓ usan
Actions (funciones reutilizables)
  ↓ usan
Core (infraestructura)
  ↓ usan
UI (tooltips)
```

### **Separación de Responsabilidades**

| Directorio | Responsabilidad | Ejemplo |
|------------|----------------|---------|
| **actions/** | QUÉ hacer | `VimMoveLeft()` - Envía `{Left}` |
| **core/** | Cómo configurar | `keymap_registry` - Registra keymaps |
| **layer/** | CUÁNDO hacerlo | `nvim_layer` - Solo si `isNvimLayerActive` |
| **ui/** | Cómo mostrarlo | `ShowCSharpStatusNotification()` |

---

## 🎯 Reglas de Oro

### **Actions**
1. ✅ Una responsabilidad por función
2. ✅ Sin estado global (o mínimo necesario)
3. ✅ Reutilizable en múltiples layers
4. ✅ Nombre descriptivo: `VerbNounAdjective()`

### **Core**
1. ✅ Cargado primero (antes de todo)
2. ✅ Infraestructura compartida
3. ✅ Sin lógica de negocio específica
4. ✅ Configuración centralizada

### **Layers**
1. ✅ Context-aware (#HotIf con condiciones)
2. ✅ Estado local del layer (flags, modos)
3. ✅ Usa actions, no duplica código
4. ✅ Sigue template para consistencia

### **UI**
1. ✅ Solo presentación, sin lógica de negocio
2. ✅ Fallback a nativo si C# no disponible
3. ✅ Feedback visual para todas las acciones
4. ✅ Consistencia de diseño

---

## 📚 Ver También

- **[PERSISTENT_LAYER_TEMPLATE.md](PERSISTENT_LAYER_TEMPLATE.md)** - Template para crear layers
- **[AUTO_LOADER_SYSTEM.md](AUTO_LOADER_SYSTEM.md)** - Sistema de auto-discovery
- **[GENERIC_ROUTER_ARCHITECTURE.md](GENERIC_ROUTER_ARCHITECTURE.md)** - Leader menu
- **[DECLARATIVE_SYSTEM.md](../DECLARATIVE_SYSTEM.md)** - Sistema declarativo de keymaps

---

## ✅ Checklist para Nuevos Desarrolladores

Al agregar funcionalidad, pregúntate:

- [ ] ¿Es reutilizable? → **actions/**
- [ ] ¿Es infraestructura base? → **core/**
- [ ] ¿Es un modo/contexto? → **layer/**
- [ ] ¿Es presentación visual? → **ui/**
- [ ] ¿Sigue las convenciones de naming?
- [ ] ¿Tiene documentación inline?
- [ ] ¿Está en el lugar correcto?

---

**¡Arquitectura modular, mantenible y escalable!** 🚀
