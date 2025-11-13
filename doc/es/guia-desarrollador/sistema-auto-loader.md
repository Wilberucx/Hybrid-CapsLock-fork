# Sistema Auto-Loader - Guía de Uso

## Descripción General

El **Auto-Loader** es un sistema que detecta y carga automáticamente módulos de código sin necesidad de editar manualmente los archivos `#Include`. Simplifica enormemente el desarrollo al permitir agregar nuevas funcionalidades con solo crear un archivo en la ubicación correcta.

## 🎯 Beneficios

### Antes del Auto-Loader ❌
```ahk
; Tenías que editar init.ahk manualmente:
#Include src/layer/nvim_layer.ahk
#Include src/layer/excel_layer.ahk
#Include src/layer/scroll_layer.ahk
#Include src/layer/MI_NUEVA_CAPA.ahk  ; Agregar manualmente
```

### Con Auto-Loader ✅
1. Crea `src/layer/mi_nueva_capa.ahk`
2. Reload (`Ctrl+Alt+R`)
3. ¡Listo! Ya está cargada automáticamente

## 📂 Carpetas Monitoreadas

El auto-loader busca archivos `.ahk` en:

- **`src/layer/`** - Implementaciones de capas (nvim, excel, scroll, etc.)
- **`src/actions/`** - Módulos de acciones (git, adb, power, etc.)

## 🚫 Carpeta `no_include/`

Para **deshabilitar** un módulo sin borrarlo:

```
src/layer/
├── nvim_layer.ahk          ✅ Se carga
├── excel_layer.ahk         ✅ Se carga
└── no_include/
    └── experimental.ahk    ❌ NO se carga
```

Esto es útil para:
- **Desarrollo iterativo** - Deshabilitar temporalmente código en progreso
- **Debugging** - Aislar problemas deshabilitando módulos
- **Backup** - Guardar versiones antiguas sin borrarlas

## 🔧 Cómo Funciona

### 1. Escaneo de Archivos

Al inicio, `src/core/auto_loader.ahk` ejecuta:

```ahk
; Buscar todos los .ahk en src/layer/
Loop Files, src/layer/*.ahk {
    if (InStr(A_LoopFileFullPath, "no_include")) {
        continue  ; Saltar archivos en no_include/
    }
    #Include %A_LoopFileFullPath%
}
```

### 2. Inclusión Automática

Cada archivo encontrado se incluye con `#Include`, equivalente a:

```ahk
#Include src/layer/nvim_layer.ahk
#Include src/layer/excel_layer.ahk
; ... etc
```

### 3. Inicialización

Los archivos incluidos deben tener una función `Init*()` que se llama automáticamente:

```ahk
; En mi_capa.ahk
InitMiCapa() {
    RegisterKeymaps("mi_capa", [...])
    OutputDebug("Mi Capa inicializada")
}

; Se llama automáticamente al cargar
```

## 📝 Convenciones

### Nombres de Archivo

- **Snake_case con minúsculas**: `nvim_layer.ahk`, `git_actions.ahk`
- **Sufijo descriptivo**: `*_layer.ahk` para capas, `*_actions.ahk` para acciones
- **Sin espacios ni caracteres especiales**

### Estructura de Archivo

Cada archivo debe seguir esta estructura:

```ahk
; ============================================================================
; Nombre del Módulo - Descripción breve
; ============================================================================

; Variables globales
global MI_VARIABLE := false

; ============================================================================
; Inicialización
; ============================================================================

InitMiModulo() {
    ; Configuración inicial
    ; Registro de keymaps
    ; OutputDebug para logging
}

; ============================================================================
; Funciones Públicas
; ============================================================================

MiFuncionPublica() {
    ; Implementación
}

; ============================================================================
; Funciones Privadas (helpers)
; ============================================================================

MiFuncionPrivada() {
    ; Helpers internos
}

; ============================================================================
; Llamar inicialización
; ============================================================================

InitMiModulo()
```

## 🔍 Debugging

### Verificar qué Archivos se Cargan

Agrega `OutputDebug` en tu función `Init*()`:

```ahk
InitMiCapa() {
    OutputDebug("=== MI CAPA CARGADA ===")
    ; ... resto del código
}
```

Usa [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview) para ver los mensajes.

### El Módulo no se Carga

**Checklist:**
1. ✅ ¿El archivo está en `src/layer/` o `src/actions/`?
2. ✅ ¿El archivo termina en `.ahk`?
3. ✅ ¿NO está dentro de `no_include/`?
4. ✅ ¿Hiciste reload después de crear el archivo? (`Ctrl+Alt+R`)
5. ✅ ¿El archivo tiene sintaxis válida? (errores de sintaxis impiden la carga)

### Errores de Sintaxis

Si un archivo tiene errores, **todo el sistema falla al cargar**. Para debug:

1. Mueve el archivo a `no_include/`
2. Reload
3. Corrige el error
4. Mueve de vuelta el archivo
5. Reload

## 🚀 Casos de Uso

### Desarrollo de Nueva Funcionalidad

```bash
# 1. Crear archivo
echo "InitMiFeature() {
    OutputDebug('Mi feature cargada')
}" > src/actions/mi_feature.ahk

# 2. Reload
Ctrl+Alt+R

# 3. Verificar en DebugView
# Deberías ver: "Mi feature cargada"
```

### Experimentación

```bash
# Crear versión experimental
cp src/layer/nvim_layer.ahk src/layer/nvim_layer_v2.ahk

# Deshabilitar original
mv src/layer/nvim_layer.ahk src/layer/no_include/

# Reload y probar v2
Ctrl+Alt+R

# Volver a la original si no funciona
mv src/layer/no_include/nvim_layer.ahk src/layer/
rm src/layer/nvim_layer_v2.ahk
Ctrl+Alt+R
```

### Compartir Módulos

Los módulos son **auto-contenidos**. Para compartir:

1. Copia el archivo `.ahk`
2. El receptor lo coloca en `src/layer/` o `src/actions/`
3. Reload
4. ¡Funciona!

Sin necesidad de modificar otros archivos.

## ⚠️ Limitaciones

### Orden de Carga

Los archivos se cargan en **orden alfabético**. Si un módulo depende de otro:

```ahk
; a_base.ahk se carga antes que z_dependiente.ahk
; Usa prefijos numéricos si necesitas control fino:
; 01_core.ahk
; 02_layers.ahk
; 03_ui.ahk
```

### Dependencias Circulares

Evita dependencias circulares:

❌ **Mal:**
```
layer_a.ahk llama a FunctionB()
layer_b.ahk llama a FunctionA()
```

✅ **Bien:**
```
layer_a.ahk usa core/helpers.ahk
layer_b.ahk usa core/helpers.ahk
core/helpers.ahk no depende de layers
```

### Rendimiento

Cada archivo adicional aumenta el tiempo de carga. Para proyectos grandes:

- Usa `no_include/` para módulos no utilizados
- Considera combinar módulos pequeños relacionados
- El overhead es mínimo (<100ms por archivo en hardware moderno)

## 📚 Ver También

- **[Crear Nuevas Capas](crear-capas.md)** - Guía para crear capas personalizadas
- **[Sistema de Keymaps](sistema-keymaps.md)** - Sistema unificado de registro
- **[Sistema de Debug](../../en/reference/debug-system.md)** - Herramientas de debugging

---

**[🌍 View in English](../../en/developer-guide/auto-loader-system.md)** | **[← Volver al Índice](../README.md)**
