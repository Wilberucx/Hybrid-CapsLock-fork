# Guía de Migración - Sistema de Logs v2.0

## 🎯 Objetivo

Migrar todos los `OutputDebug()` directos al nuevo sistema centralizado de logging para que respeten la configuración `debug_mode` y `log_level`.

## 📊 Estado Actual

**Con `debug_mode: false`**, DebugView muestra **264 líneas de log**, pero deberían ser solo ~10-20 líneas de nivel INFO.

### Archivos con OutputDebug directo (que NO respetan debug_mode):

```
✅ = Migrado
❌ = Pendiente

❌ src/ui/tooltip_csharp_integration.ahk     (~200 logs verbose)
❌ src/core/keymap_registry.ahk              (~50 logs verbose)  
❌ src/layer/scroll_layer.ahk                (~10 logs)
❌ src/layer/nvim_layer.ahk                  (~10 logs)
❌ src/layer/leader_router.ahk               (~5 logs)
❌ src/layer/visual_layer.ahk                (~5 logs)
❌ src/actions/sendinfo_actions.ahk          (~2 logs)
```

## 🔄 Cómo Migrar

### Paso 1: Reemplazar OutputDebug simple

```ahk
// ❌ ANTES - Siempre se muestra
OutputDebug("[Tooltip] Theme loaded: " . theme.name)
OutputDebug("[LayerSwitcher] Activating layer: " . layerName)

// ✅ DESPUÉS - Solo si DEBUG activo
Log.d("Theme loaded: " . theme.name, "TOOLTIP")
Log.d("Activating layer: " . layerName, "LAYER")
```

### Paso 2: Reemplazar OutputDebug con newlines

```ahk
// ❌ ANTES
OutputDebug("[Tooltip] Theme loaded`n")

// ✅ DESPUÉS (sin `n, el sistema ya lo agrega)
Log.d("Theme loaded", "TOOLTIP")
```

### Paso 3: Niveles según importancia

```ahk
// Información importante del sistema (siempre visible)
OutputDebug("[Leader] ActivateLeaderLayer() - Activating")
→ Log.i("ActivateLeaderLayer() - Activating", "LEADER")

// Debug de desarrollo (solo con debug_mode: true)
OutputDebug("[LayerListener] Key pressed: " . key)
→ Log.d("Key pressed: " . key, "LAYER")

// Trace de ejecución muy detallado (solo con log_level: TRACE)
OutputDebug("[LayerListener] ========================================")
→ Log.t("========================================", "LAYER")

// Errores (siempre visibles)
OutputDebug("[Visual] ERROR showing help: " . e.Message)
→ Log.e("Error showing help: " . e.Message, "VISUAL")

// Warnings
OutputDebug("[Tooltip] WARNING: theme.style is empty!")
→ Log.w("theme.style is empty", "TOOLTIP")
```

### Paso 4: Operaciones costosas (lazy evaluation)

```ahk
// ❌ ANTES - ToString se ejecuta siempre (caro!)
OutputDebug("[Debug] Object: " . ToString(bigObject))

// ✅ DESPUÉS - Callback solo se ejecuta si DEBUG activo
Log.debug(() => "Object: " . ToString(bigObject), "DEBUG")
```

## 📝 Tabla de Conversión Rápida

| Antes | Después | Nivel |
|-------|---------|-------|
| `OutputDebug("[Layer] Activating...")` | `Log.i("Activating...", "LAYER")` | INFO |
| `OutputDebug("[Debug] Variable x = " . x)` | `Log.d("Variable x = " . x, "DEBUG")` | DEBUG |
| `OutputDebug("[Layer] ===== START =====")` | `Log.t("===== START =====", "LAYER")` | TRACE |
| `OutputDebug("[ERROR] " . e.Message)` | `Log.e(e.Message, "ERROR")` | ERROR |
| `OutputDebug("[Warning] Using default")` | `Log.w("Using default", "WARNING")` | WARNING |

## 🎨 Categorías Recomendadas

Usar las constantes de `LogCategory`:

```ahk
Log.d("Mensaje", LogCategory.TOOLTIP)    // Tooltip system
Log.d("Mensaje", LogCategory.LAYER)      // Layer switching/activation
Log.d("Mensaje", LogCategory.KEY)        // Key events
Log.d("Mensaje", LogCategory.NVIM)       // Nvim layer
Log.d("Mensaje", LogCategory.LEADER)     // Leader mode
Log.d("Mensaje", LogCategory.EXCEL)      // Excel layer
Log.d("Mensaje", LogCategory.REGISTRY)   // Keymap registry
Log.d("Mensaje", LogCategory.CONFIG)     // Configuration
Log.d("Mensaje", LogCategory.INIT)       // Initialization
```

## 🔍 Criterios para Niveles

### TRACE (0) - Solo para debugging profundo
- Líneas separadoras (`===`, `---`, etc.)
- Entry/exit de funciones muy frecuentes
- Estados intermedios en loops
- **Ejemplo**: `Log.t("→ EntraFunción()", "TRACE")`

### DEBUG (1) - Información de desarrollo
- Variables y estados internos
- Pasos de ejecución importantes
- Eventos de teclas procesadas
- Activación/desactivación de capas
- **Ejemplo**: `Log.d("Layer activated: nvim", "LAYER")`

### INFO (2) - Información importante del sistema
- Inicialización completada
- Cambios de configuración
- Acciones del usuario importantes
- **Ejemplo**: `Log.i("HybridCapsLock v6.3 iniciado", "INIT")`

### WARNING (3) - Advertencias no críticas
- Fallbacks a valores por defecto
- Configuración faltante pero no crítica
- Timeouts alcanzados
- **Ejemplo**: `Log.w("Config no encontrada, usando default", "CONFIG")`

### ERROR (4) - Errores críticos
- Fallos de carga de archivos
- Excepciones capturadas
- Estados inválidos
- **Ejemplo**: `Log.e("No se pudo cargar layer: " . e.Message, "LAYER")`

## 📋 Plan de Migración Recomendado

### Fase 1: Archivos Core (Alta prioridad)
1. **src/core/keymap_registry.ahk** - Sistema de capas y listeners
   - Cambiar logs de LayerListener a DEBUG
   - Cambiar logs de LayerSwitcher a DEBUG
   - Mantener errores en ERROR

2. **src/ui/tooltip_csharp_integration.ahk** - Sistema de tooltips
   - Cambiar "Reading theme" a DEBUG
   - Cambiar "Theme loaded successfully" a DEBUG
   - Mantener errores y warnings en su nivel

### Fase 2: Capas (Media prioridad)
3. **src/layer/nvim_layer.ahk**
4. **src/layer/leader_router.ahk**
5. **src/layer/scroll_layer.ahk**
6. **src/layer/visual_layer.ahk**
7. **src/layer/excel_layer.ahk**

### Fase 3: Actions (Baja prioridad)
8. **src/actions/sendinfo_actions.ahk**
9. Otros archivos de actions según necesidad

## 🧪 Verificación

Después de migrar un archivo, verificar con DebugView:

### Con `debug_mode: false, log_level: "INFO"`
```
Deberías ver solo:
- Mensajes de inicialización [INIT]
- Mensajes importantes del sistema [INFO]
- Errores [ERROR]

NO deberías ver:
- [LayerListener] logs
- [LayerSwitcher] logs detallados
- [Tooltip] "Reading theme" repetidos
- [SCROLL DEBUG] logs
```

### Con `debug_mode: true` o `log_level: "DEBUG"`
```
Deberías ver TODO lo anterior MÁS:
- [LAYER] logs de activación/desactivación
- [KEY] logs de teclas procesadas
- [DEBUG] información de desarrollo
```

### Con `log_level: "TRACE"`
```
Deberías ver TODO lo anterior MÁS:
- Líneas separadoras (===, ---)
- Entry/exit de funciones
- Estados intermedios muy detallados
```

## 🎯 Resultado Esperado

**ANTES** (debug_mode: false):
```
264 líneas de log incluyendo todo el ruido de debug
```

**DESPUÉS** (debug_mode: false):
```
[12:48:45.123] [LOG_SYSTEM] Sistema de logging inicializado - Nivel: INFO
[12:48:45.456] [INIT] Config loaded from: ahk
[12:48:45.457] [INIT] HybridCapsLock v6.3 iniciado correctamente
[12:48:49.123] [LEADER] Leader layer activated
[12:48:51.456] [NVIM] Nvim layer activated
[12:48:53.789] [LEADER] Leader layer deactivated
```

**Solo 5-10 líneas** de información relevante en lugar de 264 líneas de ruido.

## 💡 Tips

1. **No migrar todo de una vez** - Hazlo por archivos
2. **Probar después de cada migración** - Verificar con DebugView
3. **Usar categorías consistentes** - Preferir constantes de `LogCategory`
4. **Documentar decisiones** - Si algo debe ser INFO vs DEBUG, documentar por qué
5. **Lazy evaluation para operaciones caras** - ToString de objetos grandes, etc.

## 📚 Recursos

- [Sistema de Logs v2.0](./Sistema-de-Logs.md) - Documentación completa
- [Debug_log.ahk](../../src/core/Debug_log.ahk) - Implementación
- [LogCategory](../../src/core/Debug_log.ahk#L322) - Constantes de categorías
