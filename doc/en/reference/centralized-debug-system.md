# Sistema de Debug Centralizado - HybridCapsLock v2.0

## 🎯 Objetivo

El nuevo sistema de debug centralizado (`src/core/Debug_log.ahk`) unifica y mejora el logging en toda la aplicación, proporcionando:

- ✅ **Control centralizado** del debug desde `config/settings.ahk`
- ✅ **Funciones especializadas** para diferentes tipos de logging
- ✅ **Manejo automático de errores** con contexto completo
- ✅ **Compatibilidad** con el sistema anterior
- ✅ **Logging inteligente** con formateo automático de objetos

## 🛠️ Configuración

### Habilitar/Deshabilitar Debug

Edita `config/settings.ahk` línea 13:

```ahk
AppConfig := {
    name: "HybridCapsLock",
    version: "6.3",
    debug_mode: true,  // ← true para habilitar, false para deshabilitar
    // ...
}
```

## 📚 Funciones Disponibles

### 🔧 Funciones Básicas

#### `LogDebug(message, category)`
**Condicional** - solo registra cuando `debug_mode = true`
```ahk
LogDebug("Usuario presionó F23", "NVIM")
LogDebug("Procesando keymap: " . keymapName, LogCategory.KEYMAP)
// Solo aparece si debug_mode = true
```

#### `LogInfo(message, category)`
**Siempre registra** - información importante
```ahk
LogInfo("HybridCapsLock v6.3 iniciado", LogCategory.INIT)
LogInfo("Configuración cargada correctamente", LogCategory.CONFIG)
// Siempre aparece
```

#### `LogError(message, category)`
**Siempre registra** - errores críticos
```ahk
LogError("No se pudo cargar layer: " . layerName, LogCategory.LAYER)
LogError("Archivo de configuración no encontrado", LogCategory.CONFIG)
```

#### `LogWarning(message, category)`
**Siempre registra** - advertencias importantes
```ahk
LogWarning("Función obsoleta utilizada", LogCategory.WARNING)
LogWarning("Configuración incompleta detectada", LogCategory.CONFIG)
```

### 🚀 Funciones Especializadas

#### `LogFunctionEntry(functionName, params)` / `LogFunctionExit(functionName, result)`
Tracing automático de funciones:
```ahk
MiFunction(param1, param2) {
    LogFunctionEntry("MiFunction", param1 . ", " . param2)
    
    // ... lógica de la función
    resultado := "éxito"
    
    LogFunctionExit("MiFunction", resultado)
    return resultado
}
```

#### `LogErrorWithContext(message, functionName, errorObject)`
Logging de errores con contexto completo:
```ahk
try {
    // operación que puede fallar
    CargarArchivo(rutaArchivo)
} catch as e {
    LogErrorWithContext("Error al cargar archivo", "CargarArchivo", e)
    // Output: [ERROR] ERROR en CargarArchivo: Error al cargar archivo | Detalles: File not found | Línea: 45
}
```

#### `LogVariable(varName, varValue, category)`
Logging de variables con formateo automático:
```ahk
miArray := ["elemento1", "elemento2", "elemento3"]
miObjeto := {nombre: "test", id: 123, activo: true}

LogVariable("miArray", miArray)
// Output: [VARIABLE] miArray = [elemento1, elemento2, elemento3]

LogVariable("miObjeto", miObjeto)
// Output: [VARIABLE] miObjeto = {nombre: test, id: 123, activo: true}
```

#### `LogLayerEvent(layerName, action, details)`
Logging especializado para eventos de capas:
```ahk
LogLayerEvent("nvim", "activate", "Usuario presionó F23")
LogLayerEvent("excel", "deactivate", "Timeout alcanzado")
// Output: [LAYER] Layer 'nvim' → activate | Usuario presionó F23
```

#### `LogKeyEvent(key, action, context)`
Logging especializado para eventos de teclas:
```ahk
LogKeyEvent("Esc", "pressed", "nvim_layer_active")
LogKeyEvent("Ctrl+c", "copy_action", "excel_context")
// Output: [KEY] Tecla 'Esc' → pressed | Contexto: nvim_layer_active
```

#### `SafeExecute(functionName, callback, errorHandler)`
Wrapper que ejecuta código con logging automático:
```ahk
resultado := SafeExecute("OperacionRiesgosa", () => {
    // código que podría lanzar excepción
    return ProcesarDatos()
}, (e) => {
    // manejador de error opcional
    LogWarning("Usando valor por defecto debido a error", "FALLBACK")
    return "valor_por_defecto"
})
```

### 🎛️ Control del Sistema

#### `EnableDebugTemporarily()` / `DisableDebugTemporarily()`
Control temporal sin reiniciar:
```ahk
EnableDebugTemporarily()    // Habilitar solo para esta sesión
LogDebug("Esto ahora se verá", "TEST")
DisableDebugTemporarily()   // Deshabilitar temporalmente
LogDebug("Esto no se verá", "TEST")
```

#### `IsDebugEnabled()`
Verificar estado actual:
```ahk
if (IsDebugEnabled()) {
    // código que solo se ejecuta en modo debug
    LogDebug("Ejecutando código de debug", "CONDITIONAL")
}
```

## 🏷️ Categorías Predefinidas

Usa `LogCategory` para categorías consistentes:

```ahk
LogCategory.DEBUG      // "DEBUG"
LogCategory.INFO       // "INFO"
LogCategory.ERROR      // "ERROR"
LogCategory.WARNING    // "WARNING"
LogCategory.LAYER      // "LAYER"
LogCategory.KEY        // "KEY"
LogCategory.CONFIG     // "CONFIG"
LogCategory.INIT       // "INIT"
LogCategory.NVIM       // "NVIM"
LogCategory.EXCEL      // "EXCEL"
LogCategory.LEADER     // "LEADER"
LogCategory.TOOLTIP    // "TOOLTIP"
LogCategory.REGISTRY   // "REGISTRY"
// ... y más
```

**Ejemplo de uso:**
```ahk
LogDebug("Capa activada", LogCategory.LAYER)
LogInfo("Iniciando sistema", LogCategory.INIT)
LogError("Falló carga de config", LogCategory.CONFIG)
```

## 📱 Visualizar Logs

### Windows - DebugView
1. Descargar [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview)
2. Ejecutar DebugView
3. Habilitar: Capture → Capture Win32
4. Ejecutar HybridCapsLock
5. Ver logs en tiempo real con timestamps

### VSCode
1. Instalar extensión "AutoHotkey v2 Language Support"
2. Abrir panel Output (Ctrl+Shift+U)
3. Seleccionar "AutoHotkey v2" del dropdown
4. Ver logs en tiempo real

## 🔄 Migración del Sistema Anterior

### ❌ Estilo Anterior (Ya no recomendado)
```ahk
OutputDebug("[LAYER] Activando nvim layer\n")
DebugLog("Debug message", "CATEGORY")  // Sistema legacy
```

### ✅ Estilo Nuevo (Recomendado)
```ahk
LogInfo("Activando nvim layer", LogCategory.LAYER)
LogDebug("Debug message", LogCategory.DEBUG)
```

### 🔧 Compatibilidad
El sistema mantiene **compatibilidad completa** con las funciones anteriores:
- `DebugLog()` → redirige a `LogDebug()`
- `InfoLog()` → redirige a `LogInfo()`
- `ErrorLog()` → redirige a `LogError()`

## 💡 Mejores Prácticas

### ✅ Hacer
```ahk
// Usar categorías predefinidas
LogDebug("Mensaje claro", LogCategory.NVIM)

// Incluir contexto útil
LogLayerEvent("nvim", "activate", "F23 presionado por usuario")

// Usar SafeExecute para operaciones riesgosas
SafeExecute("CargarConfig", () => LoadConfig())

// Logging de entrada/salida para funciones importantes
LogFunctionEntry("ProcessKeymap", keymapName)
```

### ❌ Evitar
```ahk
// Categorías inconsistentes
LogDebug("Mensaje", "categoria_cualquiera")

// Mensajes poco descriptivos
LogDebug("algo", "DEBUG")

// Logging manual de errores (usa LogErrorWithContext)
try {
    // ...
} catch as e {
    LogError("Error: " . e.Message)  // Falta contexto
}
```

## 🎯 Beneficios

- ✅ **Sin overhead** en producción (`debug_mode = false`)
- ✅ **Flexibilidad** total para habilitar/deshabilitar logging
- ✅ **Categorización** clara para filtrado fácil
- ✅ **Formateo automático** de objetos complejos
- ✅ **Manejo robusto** de errores con contexto
- ✅ **Compatibilidad** con sistema existente
- ✅ **Timestamps** automáticos para mejor trazabilidad

## 📋 Ejemplo Completo

```ahk
; Incluir el sistema (ya incluido automáticamente)
; #Include src\core\Debug_log.ahk

MiNuevaFuncion(parametros) {
    LogFunctionEntry("MiNuevaFuncion", ToString(parametros))
    
    try {
        ; Logging de variables importantes
        LogVariable("parametros", parametros, "INPUT")
        
        ; Procesamiento
        if (parametros.HasOwnProp("layer")) {
            LogLayerEvent(parametros.layer, "processing", "Validando parámetros")
        }
        
        ; Resultado
        resultado := ProcesarParametros(parametros)
        LogFunctionExit("MiNuevaFuncion", "success")
        return resultado
        
    } catch as e {
        LogErrorWithContext("Procesamiento falló", "MiNuevaFuncion", e)
        return false
    }
}
```

## 🚀 Futuras Mejoras

- [ ] Niveles de logging (TRACE, DEBUG, INFO, WARN, ERROR)
- [ ] Filtrado por categoría en tiempo real
- [ ] Salida opcional a archivo de log
- [ ] Integración con profiling de rendimiento
- [ ] Breakpoints condicionales vía flags de debug