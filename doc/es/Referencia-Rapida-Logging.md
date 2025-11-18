# Referencia Rápida - Sistema de Logging v2.0

## 📋 Tabla de Decisión Rápida

| Situación | Usar | Ejemplo |
|-----------|------|---------|
| Sistema iniciado/configurado | `Log.i()` | `Log.i("HybridCapsLock iniciado", "INIT")` |
| Activar/desactivar layer | `Log.i()` | `Log.i("Nvim layer activado", "NVIM")` |
| Estado interno/variable | `Log.d()` | `Log.d("Variable x = " . x, "DEBUG")` |
| Tecla procesada | `Log.d()` | `Log.d("Key pressed: h", "LAYER")` |
| Entry/exit de función | `Log.t()` | `Log.t("→ MiFunción()", "TRACE")` |
| Líneas separadoras | `Log.t()` | `Log.t("========================================", "LAYER")` |
| Fallback a default | `Log.w()` | `Log.w("Config no encontrada, usando default", "CONFIG")` |
| Error en try/catch | `Log.e()` | `Log.e("Error: " . e.Message, "ERROR")` |
| Operación costosa | `Log.debug()` | `Log.debug(() => ToString(obj))` |

## 🎯 API Rápida

### Métodos Cortos (Recomendado)

```ahk
Log.t(mensaje, contexto)  // TRACE   - Solo con log_level: "TRACE"
Log.d(mensaje, contexto)  // DEBUG   - Solo con debug_mode: true o log_level: "DEBUG"
Log.i(mensaje, contexto)  // INFO    - Siempre visible (default)
Log.w(mensaje, contexto)  // WARNING - Siempre visible
Log.e(mensaje, contexto)  // ERROR   - Siempre visible
```

### Lazy Evaluation (Para Operaciones Caras)

```ahk
Log.trace(callback, contexto)  // TRACE con lazy eval
Log.debug(callback, contexto)  // DEBUG con lazy eval
```

**Ejemplo:**
```ahk
// ❌ MALO - ToString se ejecuta siempre
Log.d("Object: " . ToString(bigObject), "DEBUG")

// ✅ BUENO - Callback solo se ejecuta si DEBUG está activo
Log.debug(() => "Object: " . ToString(bigObject), "DEBUG")
```

## 🏷️ Categorías Predefinidas

```ahk
LogCategory.TRACE      // "TRACE"
LogCategory.DEBUG      // "DEBUG"
LogCategory.INFO       // "INFO"
LogCategory.WARNING    // "WARNING"
LogCategory.ERROR      // "ERROR"
LogCategory.LAYER      // "LAYER"
LogCategory.KEY        // "KEY"
LogCategory.CONFIG     // "CONFIG"
LogCategory.INIT       // "INIT"
LogCategory.NVIM       // "NVIM"
LogCategory.EXCEL      // "EXCEL"
LogCategory.LEADER     // "LEADER"
LogCategory.TOOLTIP    // "TOOLTIP"
LogCategory.REGISTRY   // "REGISTRY"
LogCategory.VAR        // "VAR"
LogCategory.SYSTEM     // "SYSTEM"
```

**Uso:**
```ahk
Log.d("Layer activada", LogCategory.LAYER)
Log.i("Iniciando sistema", LogCategory.INIT)
```

## ⚙️ Configuración

### En config/settings.ahk:

```ahk
AppConfig := {
    debug_mode: false,        // true = activa DEBUG automáticamente
    log_level: "INFO",        // TRACE, DEBUG, INFO, WARNING, ERROR, OFF
    // ...
}
```

### Niveles Disponibles:

| Nivel | Valor | Cuándo Usar | Cantidad de Logs |
|-------|-------|-------------|------------------|
| `TRACE` | 0 | Debugging muy profundo | ~200+ líneas |
| `DEBUG` | 1 | Desarrollo y diagnóstico | ~50-100 líneas |
| `INFO` | 2 | Producción normal (default) | ~10-15 líneas |
| `WARNING` | 3 | Solo advertencias + errores | ~5 líneas |
| `ERROR` | 4 | Solo errores críticos | ~2 líneas |
| `OFF` | 99 | Sin logs | 0 líneas |

## 🔧 Control Dinámico

```ahk
// Cambiar nivel en runtime
Log.SetLevel("DEBUG")
Log.SetLevel(LogLevel.TRACE)

// Obtener nivel actual
nivel := Log.GetLevel()
nombreNivel := LogLevel.ToString(nivel)

// Verificar si un nivel está activo
if (Log.IsEnabled(LogLevel.DEBUG)) {
    // Hacer algo solo si DEBUG está activo
}

// Habilitar/deshabilitar temporalmente
EnableDebugTemporarily()   // Cambia a DEBUG
DisableDebugTemporarily()  // Cambia a INFO
IsDebugEnabled()           // Verifica si DEBUG activo
```

## 📝 Patrones Comunes

### Pattern 1: Layer Activation

```ahk
ActivateMyLayer(originLayer := "leader") {
    Log.i("ActivateMyLayer() called with originLayer: " . originLayer, "MYLAYER")
    result := SwitchToLayer("mylayer", originLayer)
    Log.d("SwitchToLayer result: " . (result ? "true" : "false"), "MYLAYER")
    return result
}
```

### Pattern 2: Try/Catch con Logging

```ahk
try {
    result := RiskyOperation()
    Log.d("Operation succeeded: " . result, "OPERATION")
} catch as e {
    Log.e("Error in RiskyOperation: " . e.Message, "OPERATION")
}
```

### Pattern 3: Debug de Variables

```ahk
Log.d("Current state: active=" . isActive . ", count=" . count, "STATE")
Log.debug(() => "Complex object: " . ToString(complexObj), "DEBUG")
```

### Pattern 4: Trace de Ejecución

```ahk
MiComplexFunction() {
    Log.t("→ MiComplexFunction()", "TRACE")
    
    // ... código ...
    
    Log.t("← MiComplexFunction() → OK", "TRACE")
}
```

### Pattern 5: Lazy para Arrays/Objetos

```ahk
// ❌ MALO - Construye string siempre
Log.d("Array: [" . arr[1] . ", " . arr[2] . ", ...]", "DEBUG")

// ✅ BUENO - Solo construye si DEBUG activo
Log.debug(() => "Array: " . ToString(arr), "DEBUG")
```

## 🎯 Decisión: ¿Qué Nivel Usar?

### ✅ Usa TRACE (Log.t) si:
- Es una línea separadora (`===`, `---`, `>>>`, `<<<`)
- Es entry/exit de función muy frecuente
- Es un estado intermedio en un loop
- Solo necesitas verlo cuando debuggeas algo muy específico

### ✅ Usa DEBUG (Log.d) si:
- Es información de desarrollo (variables, estados)
- Es un evento de tecla/input procesado
- Es un paso importante en la ejecución
- Es útil para entender el flujo del programa

### ✅ Usa INFO (Log.i) si:
- Es inicio/fin de sistema/componente
- Es activación/desactivación de layer
- Es una acción importante del usuario
- Quieres que se vea en producción

### ✅ Usa WARNING (Log.w) si:
- Algo salió mal pero el programa puede continuar
- Se usó un fallback o valor por defecto
- Hay una situación inusual pero manejable
- El usuario debería saber que algo no es óptimo

### ✅ Usa ERROR (Log.e) si:
- Ocurrió un error en un try/catch
- Una operación crítica falló
- El programa está en un estado inválido
- Se debe investigar el problema

## 🚫 Antipatrones (Qué NO Hacer)

### ❌ NO uses OutputDebug directo

```ahk
// ❌ MALO - No respeta configuración
OutputDebug("[MiCategoria] Mi mensaje")

// ✅ BUENO - Usa el sistema centralizado
Log.d("Mi mensaje", "MICATEGORIA")
```

### ❌ NO construyas strings costosos incondicionalmente

```ahk
// ❌ MALO - ToString se ejecuta siempre
Log.d("Object: " . ToString(bigObj), "DEBUG")

// ✅ BUENO - Solo se ejecuta si DEBUG activo
Log.debug(() => "Object: " . ToString(bigObj), "DEBUG")
```

### ❌ NO uses INFO para todo

```ahk
// ❌ MALO - Demasiado verbose en producción
Log.i("Key pressed: h", "KEY")
Log.i("Processing keymap...", "KEY")
Log.i("Keymap found", "KEY")

// ✅ BUENO - Usa DEBUG para detalles
Log.d("Key pressed: h", "KEY")
Log.d("Processing keymap...", "KEY")
Log.d("Keymap found", "KEY")
```

### ❌ NO pongas categorías inconsistentes

```ahk
// ❌ MALO - Inconsistente
Log.d("Layer activa", "LAYER")
Log.d("Otra capa activa", "LayerSystem")
Log.d("Capa cambiada", "layers")

// ✅ BUENO - Consistente
Log.d("Layer activa", "LAYER")
Log.d("Otra capa activa", "LAYER")
Log.d("Capa cambiada", "LAYER")

// ✅✅ MEJOR - Usa constantes
Log.d("Layer activa", LogCategory.LAYER)
```

## 📊 Comparativa: Antes vs Después

### Antes (Sistema Viejo)

```ahk
OutputDebug("[LayerSwitcher] SWITCH TO LAYER CALLED")  // Siempre visible
OutputDebug("[LayerSwitcher] From: " . origin)         // Siempre visible
OutputDebug("[LayerSwitcher] To: " . target)           // Siempre visible
```

**Resultado con debug_mode: false:** ❌ 264 líneas de ruido

### Después (Sistema Nuevo)

```ahk
Log.d("SWITCH TO LAYER CALLED", "LAYER")               // Solo si DEBUG
Log.d("From: " . origin . " ? To: " . target, "LAYER") // Solo si DEBUG
```

**Resultado con debug_mode: false:** ✅ ~10 líneas relevantes

## 🔍 Debugging con DebugView

### Instalación

1. Descargar [DebugView](https://docs.microsoft.com/en-us/sysinternals/downloads/debugview)
2. Ejecutar como administrador
3. Capture > Capture Global Win32

### Filtrado en DebugView

Para filtrar solo logs del sistema:

**Filtro Include:**
```
*[LOG_SYSTEM]*;*[INIT]*;*[LAYER]*;*[NVIM]*;*[LEADER]*
```

**Filtro Exclude:**
```
*HybridCapsLock*Starting*;*Dependencies*
```

### Búsqueda Rápida

- **Ctrl+F**: Buscar texto
- **Ctrl+L**: Limpiar pantalla
- **Ctrl+S**: Guardar log a archivo
- **F5**: Refrescar

## 📚 Referencias

- **Implementación:** `/src/core/Debug_log.ahk`
- **Configuración:** `/config/settings.ahk`
- **Documentación Completa:** `/doc/es/Sistema-de-Logs.md`
- **Guía de Migración:** `/doc/es/Migracion-Logs.md`

## 🎓 Ejemplos Reales del Proyecto

### nvim_layer.ahk
```ahk
ActivateNvimLayer(originLayer := "leader") {
    Log.i("ActivateNvimLayer() called with originLayer: " . originLayer, "NVIM")
    result := SwitchToLayer("nvim", originLayer)
    Log.d("SwitchToLayer result: " . (result ? "true" : "false"), "NVIM")
    return result
}
```

### keymap_registry.ahk
```ahk
ListenForLayerKeymaps(layerName, layerActiveVarName) {
    Log.t("========================================", "LAYER")
    Log.d("STARTING NEW LISTENER", "LAYER")
    Log.d("Layer: " . layerName, "LAYER")
    // ...
}
```

### auto_loader.ahk
```ahk
SwitchToLayer(targetLayer, originLayer := "") {
    Log.t(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", "LAYER")
    Log.d("SWITCH TO LAYER CALLED", "LAYER")
    Log.d("From: " . originLayer . " ? To: " . targetLayer, "LAYER")
    // ...
}
```

## ⚡ Tips de Performance

1. **Usa lazy evaluation para ToString()** - Ahorra ~80% de CPU cuando debug está off
2. **Evita concatenar strings en INFO** - Solo hazlo si realmente necesitas verlo en producción
3. **Usa TRACE para separadores** - No contamines DEBUG con líneas decorativas
4. **Agrupa logs relacionados** - Usa la misma categoría para filtrar fácilmente
5. **No logguees en loops** - O usa TRACE para que solo se vea en debugging profundo

## 🎯 Checklist para Pull Requests

Antes de hacer commit, verifica:

- [ ] No hay `OutputDebug()` directo en el código
- [ ] Los niveles de log son apropiados (INFO para prod, DEBUG para dev)
- [ ] Operaciones costosas usan lazy evaluation
- [ ] Las categorías son consistentes y usan `LogCategory`
- [ ] El código funciona con `debug_mode: false` (sin ruido)
- [ ] El código muestra información útil con `debug_mode: true`
