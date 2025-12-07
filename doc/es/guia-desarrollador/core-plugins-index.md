# Índice de Core Plugins

Los **Core Plugins** son componentes fundamentales del sistema que proveen APIs e infraestructura reutilizable para otros plugins y configuraciones de usuario.

## 🎯 Características de los Core Plugins

- ✅ **NO registran keymaps** directamente
- ✅ **Proveen funciones globales** que otros plugins pueden usar
- ✅ **Se cargan automáticamente** con el sistema
- ✅ **Ubicación**: `system/plugins/`
- ✅ **Documentación completa** con ejemplos

## 📚 Core Plugins Disponibles

### 1. Shell Exec
**Archivo**: `system/plugins/shell_exec.ahk`  
**Documentación**: [API Reference](api-shell-exec.md)

**Propósito**: Ejecutar comandos de shell, scripts y programas sin mostrar ventanas de consola.

**Funciones Principales**:
- `ShellExec(command, params*)` - Ejecutar comando (retorna closure)
- `ShellExecNow(command, params*)` - Ejecutar inmediatamente
- `ShellExecCapture(command, workingDir)` - Capturar salida
- `ShellExecWait(command, workingDir, timeout)` - Esperar completación
- Funciones de conveniencia: `OpenExplorer()`, `OpenCmd()`, `FlushDNS()`, etc.

**Ejemplo de Uso**:
```autohotkey
; En un plugin opcional
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
RegisterKeymap("leader", "t", "cmd", "Terminal", ShellExec("cmd.exe", "Show"), false, 2)
```

**Usado Por**: Casi todos los plugins opcionales (shell_shortcuts, git_actions, adb_actions, etc.)

---

### 2. Context Utils
**Archivo**: `system/plugins/context_utils.ahk`  
**Documentación**: [API Reference](api-context-utils.md)

**Propósito**: Detectar contexto del sistema (rutas activas, tipos de ventanas, procesos) y persistir datos en archivos INI.

**Funciones Principales**:
- `GetActiveExplorerPath()` - Obtener ruta de Explorer activo
- `IsTerminalWindow()` - Verificar si es terminal
- `GetPasteShortcut()` - Obtener atajo de pegado apropiado
- `GetActiveProcessName()` - Obtener nombre del proceso activo
- `LoadHistory(key, iniFile)` - Cargar historial desde archivo INI
- `SaveHistory(key, value, iniFile)` - Guardar historial en archivo INI

**Ejemplo de Uso**:
```autohotkey
; Abrir terminal en carpeta actual
OpenTerminalHere() {
    path := GetActiveExplorerPath()
    if (path != "") {
        ShellExecNow("wt.exe", path, "Show")
    }
}

; Pegar de manera inteligente
SmartPaste() {
    Send(GetPasteShortcut())  ; ^+v en terminales, ^v en otras apps
}

; Persistir historial
iniFile := "data\\my_plugin.ini"
SaveHistory("RecentItems", "C:\\Users\\Documents", iniFile)
history := LoadHistory("RecentItems", iniFile)
```

**Usado Por**: folder_actions, adb_actions, dynamic_layer, plugins personalizados

---

### 3. Dynamic Layer
**Archivo**: `system/plugins/dynamic_layer.ahk`  
**Documentación**: [API Reference](api-dynamic-layer.md)

**Propósito**: Activar capas automáticamente según la aplicación activa.

**Funciones Principales**:
- `ActivateDynamicLayer()` - Activar capa para proceso actual
- `ToggleDynamicLayer()` - Activar/desactivar sistema
- `ShowBindProcessGui()` - GUI para asignar capas a procesos
- `ShowBindingsListGui()` - Ver bindings configurados

**Ejemplo de Uso**:
```autohotkey
; Configurado en keymap.ahk
#HotIf (DYNAMIC_LAYER_ENABLED)
F23:: ActivateDynamicLayer()  ; Tap CapsLock activa capa del proceso
#HotIf

; Gestión de bindings
RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 7)
RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 9)
```

**Usado Por**: Sistema de capas, configuración de usuario

---

### 4. Hybrid Actions
**Archivo**: `system/plugins/hybrid_actions.ahk`  
**Documentación**: [API Reference](api-hybrid-actions.md)

**Propósito**: Gestionar el ciclo de vida del sistema (reload, pause, restart).

**Funciones Principales**:
- `ReloadHybridScript()` - Recargar sistema completo
- `RestartKanataOnly()` - Reiniciar solo Kanata
- `ExitHybridScript()` - Salir del sistema
- `PauseHybridScript()` - Pausar/reanudar con auto-resume
- `OpenConfigFolder()` - Abrir carpeta de configuración
- `ViewLogFile()` - Ver archivo de log

**Ejemplo de Uso**:
```autohotkey
; Configurado en keymap.ahk
RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 5)
RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 4)
RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
```

**Usado Por**: Gestión del sistema, debugging

---

### 5. Welcome Screen
**Archivo**: `system/plugins/welcome_screen.ahk`  
**Documentación**: [README](../../../system/plugins/no_include/welcome_screen_README.md)

**Propósito**: Mostrar una pantalla de bienvenida animada al iniciar con información del sistema y consejos.

**Funciones Principales**:
- `ShowWelcomeScreen()` - Mostrar pantalla de bienvenida con información del sistema
- `ShowQuickTip(message, icon)` - Mostrar tooltip de notificación temporal

**Características**:
- Auto-inicio al cargar el script (delay de 800ms)
- Soporte de iconos NerdFont
- Animaciones de fade
- Configurable vía `HybridConfig.welcome`
- Se puede deshabilitar en configuración

**Ejemplo de Uso**:
```autohotkey
; Mostrar una notificación rápida
ShowQuickTip("✓ ¡Configuración guardada!", "")

; La pantalla de bienvenida se ejecuta automáticamente al iniciar
; Para deshabilitarla, configurar:
; HybridConfig.welcome := { enabled: false }
```

**Usado Por**: Experiencia de inicio, notificaciones de usuario

---

## 🔄 Cómo Funcionan los Core Plugins

### Ciclo de Carga

```
1. HybridCapslock.ahk inicia
   ↓
2. system/core/auto_loader.ahk escanea system/plugins/
   ↓
3. Inyecta #Include en init.ahk
   ↓
4. Core plugins se cargan en espacio global
   ↓
5. Funciones disponibles para todos los plugins
```

### Patrón de Uso

```autohotkey
; Core Plugin (system/plugins/mi_core.ahk)
MiFuncionCore(param) {
    return () => MiFuncionCoreNow(param)
}

MiFuncionCoreNow(param) {
    ; Implementación
}

; Optional Plugin (doc/plugins/mi_plugin.ahk)
RegisterKeymap("leader", "x", "Mi Acción", MiFuncionCore("valor"), false, 1)

; User Config (ahk/config/keymap.ahk)
RegisterKeymap("leader", "y", "Otra Acción", MiFuncionCore("otro"), false, 2)
```

---

## 🎨 Patrones Comunes

### Patrón 1: Combinar Context + Shell Exec

```autohotkey
; Abrir terminal en carpeta actual de Explorer
OpenTerminalHere() {
    path := GetActiveExplorerPath()  ; Context Utils
    if (path != "") {
        return ShellExec("wt.exe", path, "Show")  ; Shell Exec
    }
    return ShellExec("wt.exe", "", "Show")
}
```

### Patrón 2: Dynamic Layer + Context

```autohotkey
; Activar capa según proceso
ActivateDynamicLayer() {
    process := GetActiveProcessName()  ; Context Utils
    layerId := GetLayerForProcess(process)  ; Dynamic Layer
    if (layerId != "") {
        SwitchToLayer(layerId)
    }
}
```

### Patrón 3: Gestión del Sistema

```autohotkey
; Workflow de desarrollo
; 1. Editar código
; 2. ReloadHybridScript()  ; Hybrid Actions
; 3. ViewLogFile()  ; Hybrid Actions (si hay errores)
```

---

## 📋 Comparación de Core Plugins

| Plugin | Tipo de Retorno | Uso Principal | Complejidad |
|--------|-----------------|---------------|-------------|
| **shell_exec** | Closures | Ejecutar comandos | Media |
| **context_utils** | Datos (strings, bools, arrays) | Detectar contexto y persistir datos | Baja |
| **dynamic_layer** | Acciones (void) | Gestión de capas | Alta |
| **hybrid_actions** | Acciones (void) | Gestión del sistema | Baja |

---

### 6. Kanata Manager
**Archivo**: `system/plugins/kanata_manager.ahk`  
**Documentación**: Documentación inline en el archivo del plugin

**Propósito**: Gestionar el ciclo de vida de Kanata (start, stop, restart, toggle) usando funciones nativas de AutoHotkey v2.

**Funciones Principales**:
- `KanataStart()` - Iniciar Kanata con detección automática y validación
- `KanataStop()` - Detener proceso de Kanata
- `KanataRestart()` - Reiniciar Kanata (stop + start)
- `KanataToggle()` - Alternar Kanata on/off
- `KanataIsRunning()` - Verificar si Kanata está corriendo
- `KanataShowStatus(duration := 1500)` - Mostrar estado de Kanata en tooltip
- `KanataGetStatus()` - Obtener string de estado legible
- `KanataGetPID()` - Obtener ID de proceso de Kanata
- `KanataStartWithRetry(maxRetries := 3, retryDelay := 1000)` - Iniciar con lógica de reintentos

**Funciones Legacy (Deprecated pero funcionales):**
> **DEPRECATED:** Las siguientes funciones se mantienen por compatibilidad:
> - `StartKanataIfNeeded()` → Usar `KanataStart()` en su lugar
> - `StopKanata()` → Usar `KanataStop()` en su lugar
> - `RestartKanata()` → Usar `KanataRestart()` en su lugar
> - `IsKanataRunning()` → Usar `KanataIsRunning()` en su lugar

**Configuración** (`ahk/config/settings.ahk`):
```autohotkey
HybridConfig.kanata := {
    enabled: true,
    exePath: "kanata.exe",           ; Auto-detectado si no se encuentra
    configFile: "ahk\config\kanata.kbd",
    startDelay: 500,
    autoStart: true,
    fallbackPaths: [
        A_ScriptDir . "\bin\kanata.exe",
        A_ScriptDir . "\kanata.exe",
        "C:\Program Files\kanata\kanata.exe",
        A_AppData . "\..\Local\kanata\kanata.exe"
    ]
}
```

**Ejemplo de Uso**:
```autohotkey
; Iniciar Kanata con auto-detección y validación
KanataStart()  ; Valida config primero, luego inicia

; Verificar estado
if (KanataIsRunning()) {
    MsgBox("Kanata está corriendo con PID: " . KanataGetPID())
}

; Alternar on/off
KanataToggle()

; Mostrar estado en tooltip (2 segundos)
KanataShowStatus(2000)

; Iniciar con lógica de reintentos (5 intentos, 2 segundos entre reintentos)
KanataStartWithRetry(5, 2000)

; Configurado en keymap.ahk (vía hybrid_actions.ahk)
RegisterKeymap("leader", "h", "k", "t", "Toggle Kanata", (*) => KanataToggle())
RegisterKeymap("leader", "h", "k", "s", "Kanata Status", (*) => KanataShowStatus())
```

**Cómo Funciona KanataStart()**:
1. Verifica si Kanata ya está corriendo (retorna true si es así)
2. Verifica que el archivo de config existe
3. **Valida config** con `kanata.exe --cfg config.kbd --check`
4. Parsea output de validación en busca de errores (9 tipos)
5. Si encuentra errores, muestra diálogo contextual y aborta
6. Si validación pasa, inicia Kanata en background (oculto)
7. Monitorea proceso por crashes inmediatos (verifica dos veces)
8. Retorna true en éxito, false en fallo

**Ejemplos de Diálogos de Error**:
- **Error de Sintaxis**: Muestra número de línea, mensaje de error, snippet de contexto y sugerencias
- **Conflicto de Puerto**: Muestra qué puerto está en uso y sugiere soluciones
- **Archivo No Encontrado**: Muestra instrucciones de instalación y configuración de PATH
- **Detección de Crash**: Detecta si el proceso muere inmediatamente después de iniciar

**Características Clave**:
- **AHK v2 Nativo**: Sin dependencias de VBScript externos
- **Auto-detección**: Busca en ubicaciones comunes por `kanata.exe` con rutas de fallback
- **Pre-validación**: Valida config con flag `--check` antes de iniciar
- **Manejo Avanzado de Errores**: Parsing inteligente de errores con 9 tipos:
  - `SYNTAX_ERROR`: Errores de sintaxis con números de línea y contexto
  - `PORT_IN_USE`: Conflictos de puerto de red
  - `INVALID_KEY`: Definiciones de teclas inválidas
  - `NOT_FOUND`: kanata.exe no encontrado
  - `FILE_ERROR`: Errores de acceso al archivo de config
  - `NO_OUTPUT`: Detección de crash inmediato
  - `RUNTIME_ERROR`: Excepciones de runtime
- **Diálogos de Error Contextuales**: Mensajes amigables con sugerencias de solución
- **Detección de Crash de Proceso**: Monitorea si Kanata crashea después de iniciar
- **Limpieza de Códigos ANSI**: Remueve códigos de color y caracteres de box-drawing
- **Captura de Output**: Usa `shell.Exec` para capturar STDOUT/STDERR
- **Lógica de Reintentos**: Reintentos automáticos con delays configurables
- **Configurable**: Configuración centralizada en `settings.ahk`

---

### 7. Notification System
**Archivo**: `system/plugins/notification.ahk`  
**Documentación**: [API Reference](api-notification.md)

**Propósito**: Proveer un sistema unificado de retroalimentación visual animada para todos los plugins.

**Funciones Principales**:
- `ShowTooltipFeedback(message, type, timeout)` - Mostrar notificación animada

**Tipos Soportados**:
- `info` (🔵), `success` (🟢), `warning` (🟠), `error` (🔴), `confirm` (🟣)

**Ejemplo de Uso**:
```autohotkey
; Éxito
ShowTooltipFeedback("Archivo guardado", "success")

; Error
ShowTooltipFeedback("Fallo en conexión", "error", 3000)
```

**Usado Por**: Todos los plugins futuros y actualizados.

---

## 🆚 Core vs Optional Plugins

| Aspecto | Core Plugins | Optional Plugins |
|---------|--------------|------------------|
| **Ubicación** | `system/plugins/` | `doc/plugins/` → `ahk/plugins/` |
| **Propósito** | Proveer APIs | Proveer funcionalidad user-facing |
| **Keymaps** | NO registran | SÍ registran |
| **Carga** | Automática | Usuario decide |
| **Ejemplos** | shell_exec, context_utils | git_actions, folder_actions |

---

## 🔍 Cuándo Crear un Core Plugin

Crea un core plugin si:

✅ **Provee funcionalidad reutilizable** que múltiples plugins necesitarán  
✅ **Es infraestructura fundamental** del sistema  
✅ **NO tiene keymaps específicos** de usuario  
✅ **Sigue el patrón closure** para RegisterKeymap

**Ejemplo**: Si varios plugins necesitan ejecutar comandos → `shell_exec.ahk` (core)

Crea un optional plugin si:

✅ **Provee funcionalidad específica** para usuarios finales  
✅ **Registra keymaps** que el usuario usará directamente  
✅ **Usa APIs de core plugins** para implementar funcionalidad  
✅ **Es opcional** según necesidades del usuario

**Ejemplo**: Atajos para abrir programas → `shell_shortcuts.ahk` (optional)

---

## 📖 Recursos Adicionales

### Documentación de Arquitectura
- [Arquitectura de Plugins](arquitectura-plugins.md) - Cómo funciona el sistema de plugins
- [Sistema Auto-Loader](sistema-auto-loader.md) - Cómo se cargan los plugins
- [Sistema de Keymaps](sistema-keymaps.md) - Cómo registrar keymaps

### Guías de Desarrollo
- [Crear Capas](crear-capas.md) - Usar core plugins para crear capas
- [API References](#) - Documentación detallada de cada core plugin

### Ejemplos de Uso
- [Catálogo de Plugins Opcionales](../../plugins/README.md) - Ver cómo se usan los core plugins
- [Folder Actions](../../plugins/folder_actions.ahk) - Ejemplo de uso de context_utils
- [Shell Shortcuts](../../plugins/shell_shortcuts.ahk) - Ejemplo de uso de shell_exec

---

## 🎯 Próximos Pasos

1. **Revisa las API References** de cada core plugin
2. **Estudia los optional plugins** para ver patrones de uso
3. **Experimenta** combinando core plugins en tus propios plugins
4. **Contribuye** creando nuevos optional plugins que usen estas APIs

---

<div align="center">

**¿Listo para crear tu propio plugin?**

[Crear Capas →](crear-capas.md) | [Arquitectura →](arquitectura-plugins.md)

</div>
