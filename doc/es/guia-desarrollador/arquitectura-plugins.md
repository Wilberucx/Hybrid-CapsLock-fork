# Arquitectura del Sistema de Plugins

Este documento explica los detalles técnicos de cómo funciona el sistema de plugins en HybridCapsLock, diseñado para desarrolladores que quieran extender la funcionalidad del sistema.

## 🔄 Ciclo de Vida y Carga

El sistema de plugins se basa en un concepto fundamental: **Carga Global Automática**.

### 1. Detección (Auto-Loader)
Al iniciar `HybridCapslock.ahk`, el módulo `system/core/auto_loader.ahk` escanea dos directorios en busca de archivos `.ahk`:
1.  `ahk/plugins/` (Plugins de Usuario - Prioridad Alta)
2.  `system/plugins/` (Plugins del Sistema - Prioridad Baja)

### 🔌 Core Plugins vs Optional Plugins

El sistema distingue entre dos tipos de plugins:

**Core Plugins** (`system/plugins/`)
- **Propósito**: Proveer APIs e infraestructura reutilizable para otros plugins
- **Características**:
  - NO registran keymaps directamente
  - Proveen funciones globales que otros plugins pueden usar
  - Se cargan automáticamente con el sistema
  - Ejemplos: `shell_exec.ahk`, `hybrid_actions.ahk`, `scroll_actions.ahk`

**Optional Plugins** (`doc/plugins/` → `ahk/plugins/`)
- **Propósito**: Proveer funcionalidad user-facing y keymaps específicos
- **Características**:
  - Registran keymaps para el usuario final
  - Usan las APIs de los core plugins
  - El usuario decide cuáles instalar
  - Ejemplos: `shell_shortcuts.ahk`, `git_actions.ahk`, `adb_actions.ahk`

**Ejemplo de Separación:**
```autohotkey
; ❌ ANTES: shell_exec.ahk (todo en uno)
; - Provee API ShellExec()
; - Registra keymaps para programas
; - Mezcla infraestructura con user-facing features

; ✅ AHORA: Separado en dos archivos
; system/plugins/shell_exec.ahk (CORE)
ShellExec(command, params*) {
    return () => ShellExecNow(command, params*)
}

; doc/plugins/shell_shortcuts.ahk (OPTIONAL)
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
```

**Ventajas de esta separación:**
- Core plugins permanecen limpios y enfocados en API
- Usuarios pueden personalizar optional plugins sin tocar el core
- Mejor modularidad y mantenibilidad
- Sigue el principio de separación de responsabilidades

### 🕵️‍♂️ Mecanismo de Prioridad (Shadowing)

La prioridad se basa en el **NOMBRE DEL ARCHIVO**.

*   **Caso 1: Archivo Único**
    *   Si existe `ahk/plugins/mi_plugin.ahk`, se carga.
    *   Si existe `system/plugins/core.ahk`, se carga.

*   **Caso 2: Conflicto de Nombres (Override)**
    *   Si existen `ahk/plugins/git.ahk` Y `system/plugins/git.ahk`...
    *   ⚠️ El sistema **IGNORA** el archivo de `system/` y solo carga el de `ahk/`.
    *   Esto te permite "reemplazar" completamente un plugin del sistema simplemente creando un archivo con el mismo nombre en tu carpeta de usuario.

### 2. Inyección (init.ahk)
El auto-loader modifica dinámicamente el archivo `init.ahk` para inyectar directivas `#Include` para cada plugin encontrado.

```autohotkey
; init.ahk (Generado automáticamente)
; ===== AUTO-LOADED PLUGINS START =====
#Include ahk\plugins\mi_plugin.ahk
#Include system\plugins\git_actions.ahk
; ===== AUTO-LOADED PLUGINS END =====
```

### 3. Ejecución (Global Scope)
Cuando AHK ejecuta `init.ahk`, procesa estos `#Include` **antes** de cargar la configuración de usuario (`ahk/config/keymap.ahk`).

**Consecuencia Crítica:**
Todas las funciones, clases y variables globales definidas en tus plugins se cargan en el **Espacio de Nombres Global (Global Namespace)**.

## 🧠 ¿Por qué esto es importante?

### Disponibilidad Inmediata
Como los plugins se cargan *antes* que `keymap.ahk`, puedes usar sus funciones directamente en tus mapeos sin necesidad de importarlas manualmente.

**Ejemplo:**
*   `ahk/plugins/mi_plugin.ahk` define `MiFuncion()`.
*   `ahk/config/keymap.ahk` puede llamar a `RegisterKeymap(..., MiFuncion)` directamente.

**Ejemplo con Core Plugin:**
*   `system/plugins/shell_exec.ahk` define `ShellExec()` (core API).
*   `doc/plugins/shell_shortcuts.ahk` usa `ShellExec()` para registrar keymaps.
*   `ahk/config/keymap.ahk` también puede usar `ShellExec()` directamente.

```autohotkey
; En ahk/config/keymap.ahk
RegisterKeymap("leader", "p", "v", "VS Code", ShellExec("code.exe"), false, 1)
RegisterKeymap("leader", "i", "e", "Email", SendInfo("user@example.com"), false, 1)
```

### Desacoplamiento (Decoupling)
Esto permite que tu configuración de teclas (`keymap.ahk`) sea independiente de la implementación de las funciones.
*   Si borras el plugin, la función deja de existir, pero `keymap.ahk` no "rompe" la carga inicial (solo fallará si intentas ejecutar esa tecla específica).
*   Si comentas el mapeo en `keymap.ahk`, la función sigue existiendo en memoria, lista para ser usada por otro componente (ej. un comando de consola o otro layer).

## ⚠️ Buenas Prácticas

Dado que todo comparte el mismo espacio de nombres global, sigue estas reglas para evitar conflictos:

1.  **Nombres Únicos**: Usa prefijos si es posible.
    *   ✅ `GitCommit()`, `VimMoveH()`
    *   ❌ `Commit()`, `Move()`
2.  **Variables Globales**: Minimiza su uso. Si necesitas estado, usa clases estáticas o variables `static` dentro de funciones.
3.  **No Bloquear**: El código fuera de funciones en un plugin se ejecuta al inicio. No pongas `MsgBox` o bucles infinitos en el cuerpo principal del script.

## 🧪 Ejemplo de Flujo

1.  Creas `ahk/plugins/spotify.ahk` con la función `SpotifyPlay()`.
2.  Reinicias HybridCapsLock.
3.  El sistema detecta el archivo e inyecta `#Include ahk\plugins\spotify.ahk` en `init.ahk`.
4.  Ahora `SpotifyPlay()` es una función global del sistema.
5.  En `keymap.ahk`, asignas `Leader + s + p` a `SpotifyPlay`.
6.  ¡Listo!

## 🛠️ Debugging

Si una función de un plugin no parece estar disponible:
1.  Revisa `init.ahk` y busca la sección `AUTO-LOADED PLUGINS`. ¿Aparece tu archivo ahí?
2.  Si no aparece, asegúrate de que el archivo esté en `ahk/plugins/` y tenga extensión `.ahk`.
3.  Revisa el log de depuración (si está activado) para ver si hubo errores de sintaxis al cargar el plugin.
