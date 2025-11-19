# 🔧 Sistema de Debug Centralizado - HybridCapsLock

## 📁 Archivos del Sistema

- **`Debug_log.ahk`** - Sistema principal de logging centralizado
- **`globals.ahk`** - Incluye el sistema y mantiene compatibilidad con funciones legacy
- **`../config/settings.ahk`** - Configuración de `debug_mode` (línea 13)

## 🚀 Uso Rápido

### Configurar Debug
```ahk
// En config/settings.ahk línea 13:
debug_mode: true,  // true = logging activo, false = solo errores/info
```

### Logging Básico
```ahk
LogDebug("Mensaje de desarrollo", LogCategory.DEBUG)    // Solo si debug_mode = true
LogInfo("Información importante", LogCategory.INFO)     // Siempre
LogError("Error crítico", LogCategory.ERROR)           // Siempre
LogWarning("Advertencia", LogCategory.WARNING)         // Siempre
```

### Logging Especializado
```ahk
LogLayerEvent("nvim", "activate", "Usuario presionó F23")
LogKeyEvent("Esc", "pressed", "nvim_context")
LogVariable("miVar", miVar)  // Formateo automático
LogErrorWithContext("Falló operación", "MiFunction", errorObj)
```

### Wrapper Seguro
```ahk
result := SafeExecute("OperationName", () => {
    // código que puede fallar
    return ProcessData()
})
```

## 🔄 Migración

Las funciones anteriores siguen funcionando pero redirigen al nuevo sistema:
- `DebugLog()` → `LogDebug()`
- `InfoLog()` → `LogInfo()`
- `ErrorLog()` → `LogError()`

## 📖 Documentación Completa

Ver: `doc/en/reference/centralized-debug-system.md`

## ⚡ Beneficios Principales

- ✅ Control centralizado desde configuración
- ✅ Sin overhead en producción
- ✅ Logging especializado para diferentes eventos
- ✅ Manejo automático de errores con contexto
- ✅ Formateo inteligente de objetos y arrays
- ✅ Compatibilidad total con sistema anterior
- ✅ Timestamps automáticos