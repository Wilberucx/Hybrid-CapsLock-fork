# Sistema Auto-Loader - Guía de Uso

## Descripción General

El **Auto-Loader** es un sistema que detecta y carga automáticamente módulos de código sin necesidad de editar manualmente los archivos `#Include`. Simplifica enormemente el desarrollo al permitir agregar nuevas funcionalidades con solo crear un archivo en la ubicación correcta.

## 🎯 Beneficios

### Antes del Auto-Loader ❌

```ahk
; Tenías que editar init.ahk manualmente:
#Include ahk/plugins/my_plugin.ahk
#Include ahk/plugins/my_other_plugin.ahk
```

### Con Auto-Loader ✅

1. Crea `ahk/plugins/my_plugin.ahk`
2. Reload (`leader -> h -> R`)
3. ¡Listo! Ya está cargada automáticamente

## 📂 Carpetas Monitoreadas

El auto-loader busca archivos `.ahk` en:

- **`ahk/plugins`** - Plugins para extender funcionalidad
- **`system/plugins`** - Plugins core del sistema necesarios para el sistema

## 🚫 Carpeta `no_include/`

Para **deshabilitar** un módulo sin borrarlo:

```
ahk/plugins/
├── my_plugin.ahk          ✅ Se carga
├── my_other_plugin.ahk         ✅ Se carga
└── no_include/
    └── experimental_plugin.ahk    ❌ NO se carga
```

Esto es útil para:

- **Desarrollo iterativo** - Deshabilitar temporalmente código en progreso
- **Debugging** - Aislar problemas deshabilitando módulos
- **Backup** - Guardar versiones antiguas sin borrarlas

## 🔧 Cómo Funciona

### 1. Escaneo de Archivos

Al inicio, `system/core/auto_loader.ahk` ejecuta:

```ahk
; Buscar todos los .ahk en ahk/plugins/
Loop Files, ahk/plugins/*.ahk {
    if (InStr(A_LoopFileFullPath, "no_include")) {
        continue  ; Saltar archivos en no_include/
    }
    #Include %A_LoopFileFullPath%
}
```

### 2. Inclusión Automática

Cada archivo encontrado se incluye con `#Include`, equivalente a:

```ahk
#Include ahk/plugins/my_plugin.ahk
#Include ahk/plugins/my_other_plugin.ahk
; ... etc
```

## 📝 Convenciones

### Nombres de Archivo

- **Snake_case con minúsculas**: `mi_modulo.ahk`, `git_actions.ahk`, ``
- **Sin espacios ni caracteres especiales**

### Estructura de Plugins

Cada plugins debe seguir esta estructura:

```
Insertar estructura de plugins aquí
```

### El Módulo no se Carga

**Checklist:**

1. ✅ ¿El archivo está en `ahk/plugins/`?
2. ✅ ¿El archivo termina en `.ahk`?
3. ✅ ¿NO está dentro de `no_include/`?
4. ✅ ¿Hiciste reload después de crear el archivo? (`leader -> h -> R`)
5. ✅ ¿El archivo tiene sintaxis válida? (errores de sintaxis impiden la carga)
6. ✅ ¿El archivo tiene los Register Keymaps o Register Categories que no coincide con keybindngs existentes?

### Errores de Sintaxis

Si un archivo tiene errores, **todo el sistema falla al cargar**. Para debug:

1. Mueve el archivo a `no_include/`
2. Reload
3. Corrige el error
4. Mueve de vuelta el archivo
5. Reload

## 🚀 Casos de Uso

### Compartir Plugins

Los plugins son **auto-contenidos**. Para compartir:

1. Copia el archivo `.ahk`
2. El receptor lo coloca en `ahk/plugins`
3. Reload
4. ¡Funciona!

Sin necesidad de modificar otros archivos.

## ⚠️ Limitaciones

### Orden de Carga

Los archivos se cargan en **orden alfabético**. Si un módulo depende de otro:

```ahk
; a_base.ahk se carga antes que z_dependiente.ahk
; Usa prefijos numéricos si necesitas control fino:
; 01_plugin.ahk
```

### Dependencias Circulares

Evita dependencias circulares:

❌ **Mal:**

```
plugin_a.ahk llama a FunctionB()
plugin_b.ahk llama a FunctionA()

```

_Recomendaciones: Si se dependen de otro plugin, asegúrate de comentarlo al inicio del archivo del plugin_
✅ **Bien:**

```
plugin_a.ahk usa system/plugins/helpers_2.ahk
plugin_b.ahk usa system/plugins/helpers.ahk
core/helpers.ahk no depende de layers
```

### Rendimiento

Cada archivo adicional aumenta el tiempo de carga. Para proyectos grandes:

- Usa `no_include/` para módulos no utilizados
- Considera combinar plugin pequeños relacionados
- Considera usar las funciones de los plugins core en `system/plugins/`
- El overhead es mínimo (<100ms por archivo en hardware moderno)
