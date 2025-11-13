# 🚨 CAMBIO IMPORTANTE: Nuevo Punto de Entrada

## ⚠️ **ACCIÓN REQUERIDA para usuarios existentes:**

### 🔄 **Antes (Versión anterior):**
```bash
# Ejecutabas directamente:
init.ahk
```

### ✅ **Ahora (Nueva versión):**
```bash
# SIEMPRE ejecuta esto en su lugar:
HybridCapslock.ahk
```

## 🎯 **¿Por qué el cambio?**

**Problema anterior:** El auto-loader ejecutaba **DESPUÉS** de que AutoHotkey necesitara los archivos, causando errores de "variable no definida".

**Solución:** Ahora `HybridCapslock.ahk` ejecuta el auto-loader como **preprocesador** ANTES de lanzar `init.ahk`.

## 🛠️ **¿Qué hace HybridCapslock.ahk?**

1. **🔍 Escanea** `src/actions/` y `src/layer/` automáticamente
2. **📝 Actualiza** las secciones AUTO-LOADED en `init.ahk`
3. **🚀 Ejecuta** `init.ahk` (aplicación principal)
4. **🔄 Mantiene** la memoria JSON de archivos incluidos

## 📋 **Archivos afectados:**

| Archivo | Rol | ¿Ejecutar directamente? |
|---------|-----|------------------------|
| `HybridCapslock.ahk` | **Punto de entrada principal** | ✅ **SÍ - Ejecuta este** |
| `init.ahk` | Aplicación principal (auto-actualizada) | ❌ **NO - Ejecutado automáticamente** |
| `src/core/auto_loader.ahk` | Sistema auto-loader | ❌ **NO - Incluido automáticamente** |

## 🎯 **Para usuarios avanzados:**

### Accesos directos y automation:
```bash
# Actualiza tus scripts para usar:
& "C:\ruta\a\HybridCapslock.ahk"

# En lugar de:
& "C:\ruta\a\init.ahk"  # ❌ Ya no usar
```

### Startup de Windows:
Si tienes un acceso directo en la carpeta de inicio (`shell:startup`), **actualízalo** para que apunte a `HybridCapslock.ahk`.

## ✅ **Beneficios del nuevo sistema:**

- ✅ **Sin errores** de variables no definidas
- ✅ **Auto-detección** de nuevos archivos .ahk
- ✅ **Carpetas no_include** para desarrollo
- ✅ **Mismo comportamiento** de usuario final
- ✅ **Detección automática** de archivos eliminados

## 🔗 **Documentación relacionada:**

- **[Auto-Loader Usage Guide](../developer-guide/auto-loader-system.md)** - Guía completa del sistema
- **[Getting Started](../getting-started/quick-start.md)** - Actualizado con nuevos comandos
- **[README principal](../README.md)** - Actualizado con nuevo punto de entrada