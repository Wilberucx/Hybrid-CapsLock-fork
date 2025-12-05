# Referencia API Hybrid Actions

**Core Plugin** | `system/plugins/hybrid_actions.ahk`

Hybrid Actions proporciona funciones para gestionar el sistema Hybrid CapsLock: recargar, pausar, reiniciar Kanata, y acceder a configuración y logs.

## 🎯 Filosofía de Diseño

Hybrid Actions es un **core plugin** que:
- Provee funciones atómicas de gestión del sistema
- Se integra con tooltips C# cuando están disponibles
- Maneja el ciclo de vida de Kanata y AutoHotkey
- Implementa sistema de pause/resume

## 📚 Funciones Principales

### `ReloadHybridScript()`

Recarga completamente el sistema (Kanata + AutoHotkey).

**Parámetros:** Ninguno

**Retorna:** Void (termina el script actual)

**Comportamiento:**
1. Muestra notificación "RELOADING..."
2. Detiene TooltipApp si está corriendo
3. Reinicia Kanata si estaba corriendo (vía `KanataRestart()` del plugin kanata_manager)
4. Reinicia AutoHotkey
5. Sale del script actual

**Ejemplo:**

```autohotkey
; Recargar sistema completo
ReloadHybridScript()

; Usar en keymap
RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 5)
```

**Cuándo Usar:**
- Después de editar archivos de configuración
- Después de instalar/remover plugins
- Después de cambiar keymaps
- Para aplicar cambios en kanata.kbd

---

### `RestartKanataOnly()`

Reinicia solo Kanata, sin reiniciar AutoHotkey.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
1. Muestra notificación "RESTARTING KANATA..."
2. Llama a `RestartKanata()` (función del core)
3. Muestra notificación "KANATA RESTARTED"

**Ejemplo:**

```autohotkey
; Reiniciar solo Kanata
RestartKanataOnly()

; Usar en keymap
RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 4)
```

**Cuándo Usar:**
- Después de editar kanata.kbd
- Cuando Kanata deja de responder
- Para aplicar cambios en configuración de Kanata

---

### `ExitHybridScript()`

Sale completamente del sistema (Kanata + AutoHotkey).

**Parámetros:** Ninguno

**Retorna:** Void (termina el script)

**Comportamiento:**
1. Muestra notificación "EXITING..."
2. Detiene TooltipApp si está corriendo
3. Detiene Kanata si estaba corriendo
4. Sale de AutoHotkey

**Ejemplo:**

```autohotkey
; Salir del sistema
ExitHybridScript()

; Usar en keymap
RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 6)
```

**Cuándo Usar:**
- Para cerrar completamente el sistema
- Antes de actualizar archivos del sistema
- Para troubleshooting

---

### `PauseHybridScript()`

Pausa/reanuda el sistema con auto-resume configurable.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
1. Si no está pausado: Suspende AutoHotkey y programa auto-resume
2. Si está pausado: Reanuda inmediatamente

**Variables Globales:**
- `hybridPauseActive` - Boolean indicando si está pausado
- `hybridPauseMinutes` - Minutos hasta auto-resume (default: 10)

**Ejemplo:**

```autohotkey
; Pausar/reanudar sistema
PauseHybridScript()

; Usar en keymap
RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)

; Configurar tiempo de auto-resume en settings.ahk
global hybridPauseMinutes := 15  ; 15 minutos
```

**Estados:**
- `"SUSPENDED Xm — press Leader to resume"` - Sistema pausado
- `"RESUMED"` - Reanudado manualmente
- `"RESUMED (auto)"` - Reanudado automáticamente

**Cuándo Usar:**
- Durante presentaciones
- Cuando necesitas usar el teclado normalmente
- Para evitar activaciones accidentales

---

### `OpenConfigFolder()`

Abre la carpeta de configuración en Explorer.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
- Abre `ahk/config/` en Windows Explorer

**Ejemplo:**

```autohotkey
; Abrir carpeta de config
OpenConfigFolder()

; Usar en keymap
RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 3)
```

---

### `ViewLogFile()`

Abre el archivo de log en Notepad.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
1. Verifica si existe `hybrid_log.txt`
2. Si existe, lo abre en Notepad
3. Si no existe, muestra tooltip

**Ejemplo:**

```autohotkey
; Ver logs
ViewLogFile()

; Usar en keymap
RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 2)
```

---

## 🔧 Funciones Auxiliares

### `ToggleHybridPause()`

Función interna que implementa la lógica de pause/resume.

**Comportamiento:**
- Maneja el estado de `hybridPauseActive`
- Configura timer para auto-resume
- Muestra notificaciones apropiadas

### `HybridAutoResumeTimer()`

Callback del timer para auto-resume.

**Comportamiento:**
- Reanuda el sistema automáticamente
- Muestra notificación "RESUMED (auto)"

---

## 🎨 Patrones de Uso

### Patrón 1: Workflow de Desarrollo

```autohotkey
; 1. Editar keymap.ahk
; 2. Guardar cambios
; 3. Presionar Leader → h → R (Reload)
; 4. Probar cambios
```

### Patrón 2: Cambiar Configuración de Kanata

```autohotkey
; 1. Presionar Leader → h → c (Open Config)
; 2. Editar kanata.kbd
; 3. Guardar cambios
; 4. Presionar Leader → h → k (Restart Kanata Only)
; 5. Probar cambios
```

### Patrón 3: Debugging

```autohotkey
; 1. Presionar Leader → h → l (View Log)
; 2. Revisar errores
; 3. Hacer correcciones
; 4. Presionar Leader → h → R (Reload)
```

### Patrón 4: Pause Durante Presentación

```autohotkey
; Antes de presentar
; 1. Presionar Leader → h → p (Pause)
; 2. Presentar normalmente
; 3. Presionar Leader → h → p (Resume) o esperar auto-resume
```

---

## 📋 Buenas Prácticas

### 1. Usa Restart Kanata Only Cuando Sea Posible

```autohotkey
; ✅ Bien - solo cambios en kanata.kbd
; Leader → h → k (más rápido)

; ⚠️ Innecesario - solo cambios en kanata.kbd
; Leader → h → R (reinicia todo)
```

### 2. Configura Auto-Resume Apropiadamente

```autohotkey
; En settings.ahk o config
global hybridPauseMinutes := 10  ; Para uso general
global hybridPauseMinutes := 60  ; Para presentaciones largas
global hybridPauseMinutes := 5   ; Para pausas cortas
```

### 3. Revisa Logs Regularmente

```autohotkey
; Especialmente después de:
; - Instalar nuevos plugins
; - Cambios en configuración
; - Comportamiento inesperado
```

---

## 🔍 Debugging

### Ver Estado del Sistema

```autohotkey
; Verificar si Kanata está corriendo (usa plugin kanata_manager)
if (KanataIsRunning()) {
    MsgBox("Kanata está corriendo con PID: " . KanataGetPID())
}

; Función legacy (deprecated pero aún funciona)
if (IsKanataRunning()) {
    MsgBox("Kanata está corriendo")
}

; Verificar estado de pause
global hybridPauseActive
if (hybridPauseActive) {
    MsgBox("Sistema está pausado")
}
```

### Logs

```autohotkey
; Habilitar logging detallado
Log.SetLevel("DEBUG")

; Las funciones de hybrid_actions registran:
; - Inicio de operaciones
; - Estado de Kanata
; - Errores
```

---

## 🆚 Comparación de Funciones

| Función | Reinicia AHK | Reinicia Kanata | Cierra Todo |
|---------|--------------|-----------------|-------------|
| `ReloadHybridScript()` | ✅ | ✅ | ❌ |
| `RestartKanataOnly()` | ❌ | ✅ | ❌ |
| `ExitHybridScript()` | ❌ | ❌ | ✅ |
| `PauseHybridScript()` | Suspende | ❌ | ❌ |

---

## 🎯 Integración con Tooltips

Todas las funciones detectan automáticamente si TooltipApp está disponible:

```autohotkey
; Con TooltipApp
if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    try ShowCSharpStatusNotification("HYBRID", "RELOADING...")
}
; Sin TooltipApp
else {
    ShowCenteredToolTip("RELOADING...")
}
```

Esto permite que las funciones funcionen con o sin el sistema de tooltips C#.

---

## 📖 Ver También

- [Arquitectura de Plugins](arquitectura-plugins.md) - Cómo funcionan los core plugins
- [Sistema de Keymaps](sistema-keymaps.md) - Cómo registrar estas funciones
- [Instalación](../guia-usuario/instalacion.md) - Configuración inicial del sistema
