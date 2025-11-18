# 📚 Índice de Documentación - Sistema de Logging v2.0

**Versión:** 2.0  
**Última Actualización:** 2024-11-18  
**Estado:** ✅ Producción

---

## 🎯 ¿Qué Documento Necesito?

### 👨‍💻 Soy Desarrollador - ¿Cómo lo uso?

**→ Lee primero:** [Referencia Rápida](./Referencia-Rapida-Logging.md)

Esta guía te da:
- Tabla de decisión rápida (¿qué nivel usar?)
- API en 5 minutos
- Patrones comunes
- Antipatrones a evitar

**Tiempo de lectura:** ~5 minutos

---

### 📖 Quiero la Documentación Completa

**→ Lee:** [Sistema de Logs Completo](./Sistema-de-Logs.md)

Esta guía incluye:
- Todas las características
- Configuración detallada
- API completa (nueva y legacy)
- Ejemplos por escenario
- Mejores prácticas
- Comparativa antes/después

**Tiempo de lectura:** ~15 minutos

---

### 🔧 Necesito Migrar Código Antiguo

**→ Lee:** [Guía de Migración](./Migracion-Logs.md)

Esta guía cubre:
- Tabla de archivos a migrar
- Cómo reemplazar OutputDebug
- Criterios para elegir niveles
- Plan de migración por fases
- Verificación post-migración

**Tiempo de lectura:** ~10 minutos

---

### 🏗️ Necesito Entender la Implementación

**→ Lee:** [Debug_log.ahk README](../../src/core/Debug_log.ahk.README.md)

Esta guía técnica incluye:
- Arquitectura del sistema
- Explicación de cada clase
- Detalles de implementación
- Optimizaciones de performance
- Testing y benchmarks

**Tiempo de lectura:** ~20 minutos

---

### 📋 Solo Necesito la Referencia del API

**→ Lee:** [README del Sistema de Debug](../../src/core/README_Debug_System.md)

Referencia rápida con:
- API completa (nueva y legacy)
- Configuración
- Compatibilidad
- DebugView setup

**Tiempo de lectura:** ~5 minutos

---

## 📁 Estructura de Documentación

```
doc/es/
├── INDICE-DOCUMENTACION-LOGGING.md      ← Estás aquí
├── Referencia-Rapida-Logging.md         ← ⭐ Empieza aquí
├── Sistema-de-Logs.md                   ← Documentación completa
└── Migracion-Logs.md                    ← Para migrar código

src/core/
├── Debug_log.ahk                        ← Código fuente
├── Debug_log.ahk.README.md              ← Documentación técnica
└── README_Debug_System.md               ← Referencia API
```

---

## 🎓 Rutas de Aprendizaje

### Ruta 1: Usuario Rápido (10 minutos)

1. [Referencia Rápida](./Referencia-Rapida-Logging.md) - 5 min
2. Probar en tu código - 5 min

**Resultado:** Puedes usar el sistema básicamente

---

### Ruta 2: Desarrollador Completo (30 minutos)

1. [Referencia Rápida](./Referencia-Rapida-Logging.md) - 5 min
2. [Sistema de Logs Completo](./Sistema-de-Logs.md) - 15 min
3. [README del Sistema](../../src/core/README_Debug_System.md) - 5 min
4. Probar en tu código - 5 min

**Resultado:** Dominas el sistema completo

---

### Ruta 3: Migrador (30 minutos)

1. [Guía de Migración](./Migracion-Logs.md) - 10 min
2. [Referencia Rápida](./Referencia-Rapida-Logging.md) - 5 min
3. Migrar primer archivo - 10 min
4. Verificar con DebugView - 5 min

**Resultado:** Puedes migrar código legacy

---

### Ruta 4: Arquitecto/Revisor (60 minutos)

1. [Sistema de Logs Completo](./Sistema-de-Logs.md) - 15 min
2. [Debug_log.ahk README](../../src/core/Debug_log.ahk.README.md) - 20 min
3. [Código Fuente](../../src/core/Debug_log.ahk) - 20 min
4. Testing manual - 5 min

**Resultado:** Entiendes la implementación completa

---

## 🚀 Quick Start (3 minutos)

### Paso 1: Configuración (30 segundos)

Edita `config/settings.ahk`:

```ahk
AppConfig := {
    debug_mode: false,        // true para desarrollo
    log_level: "INFO",        // TRACE, DEBUG, INFO, WARNING, ERROR, OFF
    // ...
}
```

### Paso 2: Usar en tu código (1 minuto)

```ahk
// API nueva (recomendada)
Log.i("Sistema iniciado", "INIT")           // INFO - siempre visible
Log.d("Variable x = " . x, "DEBUG")         // DEBUG - solo en dev
Log.e("Error: " . e.Message, "ERROR")       // ERROR - siempre visible

// API legacy (compatible)
LogInfo("Sistema iniciado", "INIT")
LogDebug("Variable x = " . x, "DEBUG")
LogError("Error: " . e.Message, "ERROR")
```

### Paso 3: Ver logs (1 minuto)

1. Descargar [DebugView](https://docs.microsoft.com/en-us/sysinternals/downloads/debugview)
2. Ejecutar como administrador
3. Capture > Capture Global Win32
4. Ver logs en tiempo real

**¡Listo!** Ya estás usando el sistema de logging v2.0

---

## 📊 Comparativa de Documentos

| Documento | Audiencia | Tiempo | Nivel | Contenido |
|-----------|-----------|--------|-------|-----------|
| [Referencia Rápida](./Referencia-Rapida-Logging.md) | Desarrolladores | ~5 min | Básico | Uso práctico |
| [Sistema Completo](./Sistema-de-Logs.md) | Todos | ~15 min | Intermedio | Todo incluido |
| [Guía Migración](./Migracion-Logs.md) | Mantenedores | ~10 min | Intermedio | Migrar código |
| [Debug_log.ahk README](../../src/core/Debug_log.ahk.README.md) | Arquitectos | ~20 min | Avanzado | Implementación |
| [README Sistema](../../src/core/README_Debug_System.md) | Desarrolladores | ~5 min | Básico | API reference |

---

## 🎯 Casos de Uso

### Caso 1: "Quiero empezar a usar el sistema"

**→** [Referencia Rápida](./Referencia-Rapida-Logging.md)

---

### Caso 2: "No entiendo qué nivel usar"

**→** [Referencia Rápida - Tabla de Decisión](./Referencia-Rapida-Logging.md#-tabla-de-decisión-rápida)

---

### Caso 3: "Quiero migrar OutputDebug a Log"

**→** [Guía de Migración](./Migracion-Logs.md)

---

### Caso 4: "¿Cómo configuro los niveles?"

**→** [Sistema Completo - Configuración](./Sistema-de-Logs.md#️-configuración)

---

### Caso 5: "Necesito optimizar performance"

**→** [Sistema Completo - Lazy Evaluation](./Sistema-de-Logs.md#lazy-evaluation-operaciones-costosas)

---

### Caso 6: "¿Cómo funciona internamente?"

**→** [Debug_log.ahk README](../../src/core/Debug_log.ahk.README.md)

---

### Caso 7: "Quiero ver ejemplos reales"

**→** [Referencia Rápida - Ejemplos Reales](./Referencia-Rapida-Logging.md#-ejemplos-reales-del-proyecto)

---

### Caso 8: "Necesito la API completa"

**→** [README Sistema - API](../../src/core/README_Debug_System.md#-api-completa)

---

## 🔍 Búsqueda Rápida

### Quiero buscar...

- **"Cómo usar Log.d()"** → [Referencia Rápida - API](./Referencia-Rapida-Logging.md#-api-rápida)
- **"Diferencia entre DEBUG e INFO"** → [Sistema Completo - Niveles](./Sistema-de-Logs.md#niveles-de-más-a-menos-verbose)
- **"Lazy evaluation"** → [Referencia Rápida - Pattern 5](./Referencia-Rapida-Logging.md#pattern-5-lazy-para-arraysobjetos)
- **"Migrar OutputDebug"** → [Guía Migración - Paso 1](./Migracion-Logs.md#paso-1-reemplazar-outputdebug-simple)
- **"LogCategory constantes"** → [Referencia Rápida - Categorías](./Referencia-Rapida-Logging.md#️-categorías-predefinidas)
- **"Configurar debug_mode"** → [Sistema Completo - Configuración](./Sistema-de-Logs.md#️-configuración)
- **"DebugView setup"** → [Sistema Completo - DebugView](./Sistema-de-Logs.md#-debugging-con-debugview)
- **"ToString() función"** → [Debug_log.ahk README - ToString](../../src/core/Debug_log.ahk.README.md#tostring-mejorado)
- **"Performance benchmarks"** → [Debug_log.ahk README - Performance](../../src/core/Debug_log.ahk.README.md#performance)

---

## 💡 Tips por Rol

### Si eres: Desarrollador Junior

1. Lee: [Referencia Rápida](./Referencia-Rapida-Logging.md)
2. Usa: API nueva (`Log.d()`, `Log.i()`, etc.)
3. Sigue: [Tabla de Decisión](./Referencia-Rapida-Logging.md#-tabla-de-decisión-rápida)

---

### Si eres: Desarrollador Senior

1. Lee: [Sistema Completo](./Sistema-de-Logs.md)
2. Aprende: Lazy evaluation y performance
3. Usa: Constantes `LogCategory` siempre

---

### Si eres: Mantenedor

1. Lee: [Guía de Migración](./Migracion-Logs.md)
2. Migra: Archivos core primero
3. Verifica: Con DebugView post-migración

---

### Si eres: Arquitecto/Reviewer

1. Lee: [Debug_log.ahk README](../../src/core/Debug_log.ahk.README.md)
2. Entiende: Performance y trade-offs
3. Revisa: Código fuente del sistema

---

## 📞 Ayuda y Soporte

### ❓ Preguntas Frecuentes

**P: ¿El sistema es compatible con código viejo?**  
R: Sí, 100% compatible. Todo el código legacy sigue funcionando.

**P: ¿Debo migrar todo mi código?**  
R: No es obligatorio, pero recomendado para código nuevo.

**P: ¿Qué pasa si uso debug_mode: false?**  
R: Solo verás logs de nivel INFO, WARNING y ERROR (~10 líneas en lugar de ~264).

**P: ¿Cómo hago lazy evaluation?**  
R: Usa `Log.debug(() => "texto costoso")` en lugar de `Log.d("texto costoso")`.

**P: ¿Puedo cambiar el nivel en runtime?**  
R: Sí, usa `Log.SetLevel("DEBUG")` o `EnableDebugTemporarily()`.

---

### 🐛 Problemas Comunes

**Problema:** "Mis logs no aparecen"  
**Solución:** Verifica que `debug_mode` o `log_level` permitan ese nivel de log.

**Problema:** "Demasiados logs en producción"  
**Solución:** Usa `log_level: "INFO"` en config/settings.ahk

**Problema:** "Performance lento"  
**Solución:** Usa lazy evaluation para operaciones costosas: `Log.debug(() => ToString(obj))`

---

## 🎉 ¡Estás Listo!

Ahora tienes acceso a toda la documentación del sistema de logging v2.0. Empieza por la [Referencia Rápida](./Referencia-Rapida-Logging.md) y avanza según tu necesidad.

**¡Happy Logging!** 🚀
