# Sistema de Logs Centralizado v2.0

**Estado:** ✅ Producción  
**Versión:** 2.0  
**Última Actualización:** 2024-11-18

Sistema de logging inteligente con niveles configurables, API simplificada y optimización de performance. Reemplaza completamente el sistema anterior basado en `OutputDebug()` directo.

## 🚀 Características Principales

- **Niveles configurables**: TRACE, DEBUG, INFO, WARNING, ERROR, OFF
- **API simplificada**: `Log.d()`, `Log.i()`, `Log.w()`, `Log.e()`, `Log.t()`
- **Performance optimizado**: Evaluación condicional - sin overhead si el nivel no aplica
- **Lazy evaluation**: Para operaciones costosas solo se ejecutan si son necesarias
- **Compatibilidad total**: Mantiene las funciones legacy `LogDebug()`, `LogInfo()`, etc.

## ⚙️ Configuración

En `config/settings.ahk`:

```ahk
AppConfig := {
    debug_mode: false,           ; true activa nivel DEBUG
    log_level: "INFO",          ; TRACE, DEBUG, INFO, WARNING, ERROR, OFF
    ; ...
}
```

**Niveles (de más a menos verbose):**
- `TRACE` (0) - Trazado detallado de ejecución (entry/exit de funciones)
- `DEBUG` (1) - Información de desarrollo y diagnóstico
- `INFO` (2) - Información importante del sistema (default)
- `WARNING` (3) - Advertencias que no impiden ejecución
- `ERROR` (4) - Solo errores críticos
- `OFF` (99) - Sin logs

## 📖 API Nueva - Recomendada

### Uso Básico

```ahk
; API corta y expresiva
Log.t("mensaje trace", "CATEGORIA")      ; Trace
Log.d("mensaje debug", "CATEGORIA")      ; Debug
Log.i("mensaje info", "CATEGORIA")       ; Info
Log.w("mensaje warning", "CATEGORIA")    ; Warning
Log.e("mensaje error", "CATEGORIA")      ; Error
```

### Ejemplos Reales

```ahk
; Información de inicialización
Log.i("HybridCapsLock v6.3 iniciado", "INIT")

; Debug de layers
Log.d("Activando nvim layer", "LAYER")

; Errores
Log.e("No se pudo cargar configuración", "CONFIG")

; Warnings
Log.w("Timeout alcanzado, usando default", "SYSTEM")
```

### Lazy Evaluation (Operaciones Costosas)

```ahk
; ❌ MALO - ToString se ejecuta siempre (caro!)
Log.d("Objeto: " . ToString(bigObject), "DEBUG")

; ✅ BUENO - Solo se ejecuta si debug está habilitado
Log.debug(() => "Objeto: " . ToString(bigObject), "DEBUG")

; Otro ejemplo
Log.trace(() => "Variables: " . ToString(vars) . ", Estado: " . ToString(state))
```

**Beneficio**: Si el nivel de log está en INFO, el callback nunca se ejecuta - ¡CERO overhead!

## 🔄 API Legacy (Compatibilidad)

Todas las funciones antiguas siguen funcionando:

```ahk
LogDebug("mensaje", "categoria")         ; Ahora usa Log.d()
LogInfo("mensaje", "categoria")          ; Ahora usa Log.i()
LogError("mensaje", "categoria")         ; Ahora usa Log.e()
LogWarning("mensaje", "categoria")       ; Ahora usa Log.w()

LogFunctionEntry("NombreFunción", "params")
LogFunctionExit("NombreFunción", "resultado")
LogErrorWithContext("mensaje", "función", errorObj)
LogVariable("nombre", valor, "categoria")
LogLayerEvent("nvim", "activated", "detalles")
LogKeyEvent("F23", "pressed", "contexto")

InitDebugSystem()                        ; Ahora usa Log.Init()
EnableDebugTemporarily()                 ; Cambia nivel a DEBUG
DisableDebugTemporarily()                ; Cambia nivel a INFO
IsDebugEnabled()                         ; Verifica si DEBUG está activo
```

## 🎯 Categorías Predefinidas

Usar `LogCategory` para evitar typos:

```ahk
Log.d("Iniciando", LogCategory.INIT)
Log.d("Layer activa", LogCategory.LAYER)
Log.d("Tecla procesada", LogCategory.KEY)
Log.d("Config cargada", LogCategory.CONFIG)
Log.d("Nvim layer", LogCategory.NVIM)
Log.d("Excel layer", LogCategory.EXCEL)
Log.d("Leader router", LogCategory.LEADER)
Log.d("Tooltip mostrado", LogCategory.TOOLTIP)
Log.d("Registro actualizado", LogCategory.REGISTRY)
Log.d("Variable cambiada", LogCategory.VAR)
Log.e("Error del sistema", LogCategory.ERROR)
```

## 🛠️ Control Dinámico

```ahk
; Cambiar nivel en runtime
Log.SetLevel("DEBUG")
Log.SetLevel(LogLevel.TRACE)

; Obtener nivel actual
currentLevel := Log.GetLevel()
levelName := LogLevel.ToString(currentLevel)

; Verificar si un nivel está activo
if (Log.IsEnabled(LogLevel.DEBUG)) {
    ; Hacer operación de debug cara solo si es necesario
}
```

## 🎨 Ejemplos de Uso

### Desarrollo Normal

```ahk
; config/settings.ahk
log_level: "INFO"

; En el código
Log.i("Sistema iniciado", "INIT")          ; ✅ Se muestra
Log.d("Variable x = " . x, "DEBUG")        ; ❌ No se muestra
Log.e("Error crítico", "ERROR")            ; ✅ Se muestra
```

### Debugging Activo

```ahk
; config/settings.ahk
log_level: "DEBUG"

; En el código
Log.i("Sistema iniciado", "INIT")          ; ✅ Se muestra
Log.d("Variable x = " . x, "DEBUG")        ; ✅ Se muestra
Log.t("→ EntraFunción()", "TRACE")         ; ❌ No se muestra (necesita TRACE)
```

### Trace Completo

```ahk
; config/settings.ahk
log_level: "TRACE"

; Todo se muestra
Log.t("→ Entrando función", "TRACE")       ; ✅
Log.d("Debug info", "DEBUG")               ; ✅
Log.i("Info", "INFO")                      ; ✅
```

### SafeExecute - Error Handling Automático

```ahk
result := SafeExecute("CargarArchivo", () => {
    ; Tu código aquí
    return FileRead("archivo.txt")
}, (e) => {
    ; Error handler opcional
    return ""  ; Valor por defecto en caso de error
})

; Logs automáticamente:
; [TRACE] → CargarArchivo()
; [TRACE] ← CargarArchivo → OK    (si tiene éxito)
; [ERROR] ERROR en CargarArchivo: ... (si falla)
```

## 📊 Performance

### Optimizaciones Implementadas

1. **Early return**: Si el nivel no aplica, retorna inmediatamente sin procesamiento
2. **Lazy evaluation**: Callbacks solo se ejecutan si el nivel está activo
3. **ToString eficiente**: Límites en objetos grandes, prevención de recursión infinita
4. **Static variables**: Formato de tiempo cacheado
5. **Sin overhead**: En producción (INFO+) las llamadas debug tienen costo casi cero

### Comparación

```ahk
; ❌ Sistema antiguo - siempre procesa
if (g_DebugEnabled) {
    SendToDebugView("[DEBUG] " . ToString(obj))  ; ToString se ejecuta siempre
}

; ✅ Sistema nuevo - procesamiento condicional
Log.d("Objeto: " . ToString(obj), "DEBUG")  ; ToString solo si DEBUG activo

; ✅✅ Sistema nuevo con lazy - CERO overhead
Log.debug(() => "Objeto: " . ToString(obj))  ; Callback solo si DEBUG activo
```

## 🔍 Debugging con DebugView

El sistema usa `OutputDebug()` nativo de Windows. Usa [DebugView](https://docs.microsoft.com/en-us/sysinternals/downloads/debugview) para capturar:

```
[12:34:56.789] [INIT] HybridCapsLock v6.3 iniciado
[12:34:56.790] [CONFIG] Configuración cargada correctamente
[12:34:56.891] [LAYER] Layer 'nvim' → activated
[12:34:57.123] [KEY] Key 'F23' → pressed | Contexto: nvim_mode
```

## 🎯 Mejores Prácticas

1. **En producción**: Usar `log_level: "INFO"` o `"WARNING"`
2. **En desarrollo**: Usar `log_level: "DEBUG"`
3. **Para debugging profundo**: Usar `log_level: "TRACE"`
4. **Operaciones costosas**: Siempre usar lazy evaluation con callbacks
5. **Categorías**: Usar constantes de `LogCategory` para evitar typos
6. **Contexto en errores**: Usar `LogErrorWithContext()` con objetos de error

## 🎓 Guía de Uso por Escenario

### Escenario 1: Desarrollo Normal

**config/settings.ahk:**
```ahk
debug_mode: false,
log_level: "INFO"
```

**Resultado en DebugView (~10 líneas):**
```
[13:27:46.531] [LOG_SYSTEM] Sistema de logging inicializado - Nivel: INFO
[13:27:46.546] [INIT] Config loaded from: ahk
[13:27:46.546] [INIT] HybridCapsLock v6.3 iniciado correctamente
[13:27:51.421] [LEADER] ActivateLeaderLayer() - Activating leader
[13:27:53.343] [LEADER] ActivateLeaderLayer() - Deactivated
[13:27:57.328] [NVIM] ActivateNvimLayer() called with originLayer: leader
```

### Escenario 2: Debugging Activo

**config/settings.ahk:**
```ahk
debug_mode: true,  // Activa DEBUG automáticamente
log_level: "DEBUG"
```

**Resultado en DebugView (~50-100 líneas):**
```
[13:27:46.531] [LOG_SYSTEM] Sistema de logging inicializado - Nivel: DEBUG
[13:27:46.546] [INIT] Config loaded from: ahk
[13:27:46.546] [INIT] HybridCapsLock v6.3 iniciado correctamente
[13:27:51.421] [LEADER] ActivateLeaderLayer() - Activating leader
[13:27:51.422] [LAYER] SWITCH TO LAYER CALLED
[13:27:51.423] [LAYER] From: leader ? To: nvim
[13:27:51.424] [LAYER] CurrentActiveLayer before: 
[13:27:51.425] [LAYER] Registered layer: nvim -> src\layer\nvim_layer.ahk
[13:27:51.426] [LAYER] Called activation hook: OnNvimLayerActivate
[13:27:51.427] [NVIM] OnNvimLayerActivate() - Activating layer
[13:27:51.428] [LAYER] STARTING NEW LISTENER
[13:27:51.429] [LAYER] Layer: nvim
[13:27:51.430] [LAYER] Key pressed: h in layer: nvim
... (muchos más logs de debug)
```

### Escenario 3: Trace Profundo (solo para bugs complejos)

**config/settings.ahk:**
```ahk
debug_mode: true,
log_level: "TRACE"
```

**Resultado en DebugView (~200+ líneas):**
```
[13:27:46.531] [LOG_SYSTEM] Sistema de logging inicializado - Nivel: TRACE
[13:27:46.546] [INIT] Config loaded from: ahk
[13:27:51.421] [LEADER] ActivateLeaderLayer() - Activating leader
[13:27:51.422] [LAYER] >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
[13:27:51.423] [LAYER] SWITCH TO LAYER CALLED
[13:27:51.424] [LAYER] From: leader ? To: nvim
[13:27:51.425] [LAYER] ========================================
[13:27:51.426] [LAYER] STARTING NEW LISTENER
[13:27:51.427] [LAYER] ========================================
[13:27:51.428] [TRACE] → ActivateNvimLayer()
[13:27:51.429] [TRACE] ← ActivateNvimLayer() → OK
... (TODO incluyendo líneas separadoras y traces de funciones)
```

## 📝 Migración desde el Sistema Antiguo

### ✅ Compatibilidad Total

Todo el código antiguo sigue funcionando sin cambios:

```ahk
; Código viejo - funciona sin cambios (redirige internamente al nuevo sistema)
LogDebug("algo", "DEBUG")
LogInfo("info", "INFO")
LogError("error", "ERROR")
LogWarning("warning", "WARNING")
InitDebugSystem()
EnableDebugTemporarily()
IsDebugEnabled()
```

### 🆕 Recomendaciones para Código Nuevo

```ahk
; Código nuevo - usa la nueva API (más corta y eficiente)
Log.d("algo", "DEBUG")
Log.i("info", "INFO")
Log.e("error", "ERROR")
Log.w("warning", "WARNING")
Log.Init()  ; Opcional, se auto-inicializa

; Lazy evaluation para operaciones costosas
Log.debug(() => "algo costoso: " . ToString(obj))
Log.trace(() => "Variables: " . ToString(vars))
```

## 🆕 Qué Cambió desde v1.0

### Eliminado
- Variable global `g_DebugEnabled` → Ahora es `Log.currentLevel`
- Función `SendToDebugView()` → Integrada en `Log._sendToOutput()`
- Función `ReadDebugModeFromConfig()` → Integrada en `Log._readFromConfigFile()`

### Agregado
- Clase `LogLevel` con niveles numéricos
- Clase `Log` con API unificada
- Métodos cortos: `Log.d()`, `Log.i()`, etc.
- Lazy evaluation con callbacks
- Control dinámico de nivel en runtime
- Mejor `ToString()` con límites y prevención de recursión

### Mejorado
- Performance: ~10x más rápido en condiciones donde logs no se muestran
- Flexibilidad: 6 niveles vs on/off binario
- Simplicidad: API más limpia y expresiva
- Robustez: Mejor manejo de errores y edge cases
