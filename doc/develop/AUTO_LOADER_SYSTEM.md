# Auto-Loader System - Dynamic Actions & Layers Discovery

## 🎯 Overview

El **Auto-Loader** es un sistema que automáticamente detecta, incluye y gestiona archivos `.ahk` de actions y layers, eliminando la necesidad de editar manualmente `init.ahk` cada vez que creas un nuevo archivo.

---

## ✨ Características

- 🔍 **Escaneo automático** de `src/actions/` y `src/layer/` en cada inicio
- 💾 **Memoria JSON** para rastrear archivos incluidos previamente
- ✏️ **Auto-include** en `init.ahk` de nuevos archivos detectados
- 🛡️ **Sistema de seguridad** con carpetas `no_include/` para archivos incompletos
- 🧹 **Limpieza automática** de includes de archivos eliminados
- 📊 **Notificaciones** cuando se detectan cambios

---

## 🏗️ Arquitectura

### **Componentes**

```
src/core/auto_loader.ahk          ← Lógica principal
data/auto_loader_memory.json      ← Memoria de archivos incluidos
init.ahk                          ← Auto-actualizado con marcadores
src/actions/                      ← Escaneo de actions
src/actions/no_include/           ← Actions excluidos
src/layer/                        ← Escaneo de layers
src/layer/no_include/             ← Layers excluidos
```

### **Flujo de Operación**

```
1. Startup (init.ahk ejecuta AutoLoaderInit())
        ↓
2. Cargar memoria JSON (archivos previos)
        ↓
3. Escanear directorios (src/actions/, src/layer/)
        ↓
4. Excluir archivos en no_include/
        ↓
5. Detectar cambios (nuevos, eliminados)
        ↓
6. Actualizar init.ahk si hay cambios
        ↓
7. Guardar nueva memoria JSON
        ↓
8. Mostrar notificación
```

---

## 📋 Uso Básico

### **Crear un Nuevo Action**

```bash
# 1. Crear archivo en src/actions/
echo "; My new action" > src/actions/my_action.ahk

# 2. Reiniciar HybridCapsLock
# Auto-loader detecta el archivo y lo incluye automáticamente

# 3. Verificar en init.ahk
# Verás: #Include src\actions\my_action.ahk
```

### **Crear una Nueva Capa**

```bash
# 1. Copiar template
cp doc/templates/layer_template.ahk src/layer/database_layer.ahk

# 2. Editar LAYER_NAME y hotkeys

# 3. Reiniciar HybridCapsLock
# Auto-loader detecta y lo incluye automáticamente
```

### **Desactivar Temporalmente**

```bash
# Mover a no_include/
mv src/actions/buggy_action.ahk src/actions/no_include/

# En el próximo reinicio, se elimina automáticamente de init.ahk
```

### **Reactivar**

```bash
# Mover de vuelta
mv src/actions/no_include/fixed_action.ahk src/actions/

# En el próximo reinicio, se incluye automáticamente en init.ahk
```

---

## 🔧 Configuración

### **Variables Globales** (en `auto_loader.ahk`)

```ahk
; Activar/desactivar auto-loader
global AUTO_LOADER_ENABLED := true

; Rutas de archivos
global AUTO_LOADER_MEMORY_FILE := A_ScriptDir . "\data\auto_loader_memory.json"
global AUTO_LOADER_INIT_FILE := A_ScriptDir . "\init.ahk"

; Directorios de escaneo
global AUTO_LOADER_ACTIONS_DIR := A_ScriptDir . "\src\actions"
global AUTO_LOADER_LAYERS_DIR := A_ScriptDir . "\src\layer"

; Directorios de exclusión
global AUTO_LOADER_ACTIONS_NO_INCLUDE := A_ScriptDir . "\src\actions\no_include"
global AUTO_LOADER_LAYERS_NO_INCLUDE := A_ScriptDir . "\src\layer\no_include"

; Marcadores en init.ahk
global AUTO_LOADER_ACTIONS_MARKER_START := "; ===== AUTO-LOADED ACTIONS START ====="
global AUTO_LOADER_ACTIONS_MARKER_END := "; ===== AUTO-LOADED ACTIONS END ====="
global AUTO_LOADER_LAYERS_MARKER_START := "; ===== AUTO-LOADED LAYERS START ====="
global AUTO_LOADER_LAYERS_MARKER_END := "; ===== AUTO-LOADED LAYERS END ====="
```

### **Deshabilitar Auto-Loader**

Si prefieres gestión manual:

```ahk
; En auto_loader.ahk
global AUTO_LOADER_ENABLED := false
```

---

## 📄 Estructura de Memoria JSON

`data/auto_loader_memory.json`:

```json
{
  "version": "1.0",
  "lastUpdate": "20251108000000",
  "actions": [
    {"name": "my_action.ahk", "path": "src\\actions\\my_action.ahk", "fullPath": "C:\\...\\my_action.ahk"},
    {"name": "another_action.ahk", "path": "src\\actions\\another_action.ahk", "fullPath": "C:\\...\\another_action.ahk"}
  ],
  "layers": [
    {"name": "database_layer.ahk", "path": "src\\layer\\database_layer.ahk", "fullPath": "C:\\...\\database_layer.ahk"}
  ]
}
```

---

## 🛡️ Sistema de Seguridad: no_include/

### **Propósito**

Las carpetas `no_include/` permiten tener archivos `.ahk` que **NO** son incluidos automáticamente:

- **Desarrollo**: Archivos incompletos o en testing
- **Desactivación temporal**: Deshabilitar features sin eliminar código
- **Backups**: Guardar versiones antiguas
- **Experimentación**: Probar nuevas implementaciones

### **Ubicaciones**

```
src/actions/no_include/          ← Actions desactivados
src/layer/no_include/            ← Layers desactivados
```

### **Comportamiento**

1. **Auto-loader ignora** archivos en `no_include/`
2. **No se generan** `#Include` para estos archivos
3. **No están disponibles** en runtime
4. **Documentación** incluida en cada carpeta (README.md)

### **Casos de Uso**

#### **Desarrollo Incremental**
```bash
# Crear en no_include/ mientras desarrollas
src/actions/no_include/wip_database.ahk

# Probar, debuggear, iterar

# Cuando esté listo, mover a src/actions/
mv src/actions/no_include/wip_database.ahk src/actions/database_actions.ahk
```

#### **Desactivar Feature Buggeada**
```bash
# Encontraste bug en production
mv src/layer/excel_layer.ahk src/layer/no_include/

# Reiniciar (feature desactivada)
# Arreglar bug
# Mover de vuelta y reiniciar
```

#### **Testing A/B**
```bash
# Versión actual
src/layer/scroll_layer.ahk

# Nueva implementación en testing
src/layer/no_include/scroll_layer_v2.ahk

# Para probar v2:
mv src/layer/scroll_layer.ahk src/layer/no_include/scroll_layer_v1_backup.ahk
mv src/layer/no_include/scroll_layer_v2.ahk src/layer/scroll_layer.ahk
# Reiniciar
```

---

## 🔍 Detección de Cambios

### **Tipos de Cambios Detectados**

1. **Nuevos archivos**
   - Archivo no existe en memoria
   - Se genera nuevo `#Include`
   
2. **Archivos eliminados**
   - Archivo en memoria pero ya no existe
   - Se elimina `#Include` correspondiente
   
3. **Archivos movidos a no_include/**
   - Detectado como "eliminado"
   - Se elimina `#Include`
   
4. **Archivos movidos de no_include/**
   - Detectado como "nuevo"
   - Se genera `#Include`

### **Log de Detección**

El auto-loader registra en `OutputDebug`:

```
[AutoLoader] Starting scan...
[AutoLoader] Scanned src\actions: found 13 files
[AutoLoader] Excluded: wip_feature.ahk
[AutoLoader] Scanned src\layer: found 10 files
[AutoLoader] Changes detected:
  New actions: 1
  Removed actions: 0
  New layers: 0
  Removed layers: 1
[AutoLoader] Changes applied successfully
[AutoLoader] Memory saved successfully
```

---

## 📝 Marcadores en init.ahk

El auto-loader utiliza marcadores especiales en `init.ahk` para saber dónde insertar los `#Include`:

### **Marcadores de Actions**

```ahk
; ===== AUTO-LOADED ACTIONS START =====
#Include src\actions\my_new_action.ahk
#Include src\actions\another_action.ahk
; ===== AUTO-LOADED ACTIONS END =====
```

### **Marcadores de Layers**

```ahk
; ===== AUTO-LOADED LAYERS START =====
#Include src\layer\database_layer.ahk
#Include src\layer\browser_layer.ahk
; ===== AUTO-LOADED LAYERS END =====
```

### **⚠️ Importante**

- **NO edites** manualmente entre los marcadores
- **NO elimines** los marcadores
- Si los marcadores se pierden, el auto-loader mostrará warning

---

## 🚀 Flujo de Trabajo Completo

### **Escenario: Crear Nueva Action**

```bash
# 1. Crear archivo
cat > src/actions/spotify_actions.ahk << 'EOF'
; Spotify controls
PlayPauseSpotify() {
    Send("{Media_Play_Pause}")
}

NextTrackSpotify() {
    Send("{Media_Next}")
}

RegisterSpotifyKeymaps() {
    RegisterKeymapFlat("leader.m", "p", "Play/Pause", PlayPauseSpotify, false, 1)
    RegisterKeymapFlat("leader.m", "n", "Next Track", NextTrackSpotify, false, 2)
}
EOF

# 2. Reiniciar HybridCapsLock
# Auto-loader detecta spotify_actions.ahk

# 3. Verificar cambios
cat data/auto_loader_memory.json
# Verás spotify_actions.ahk en la lista

cat init.ahk | grep spotify
# Verás: #Include src\actions\spotify_actions.ahk

# 4. Registrar keymaps en command_system_init.ahk
# (Agregar manualmente)
RegisterCategoryKeymap("m", "Music", 6)
RegisterSpotifyKeymaps()

# 5. Probar
# <Leader> -> m -> p (Play/Pause)
```

### **Escenario: Desactivar Action Temporalmente**

```bash
# 1. Encontraste bug en git_actions.ahk
# 2. Mover a no_include/
mv src/actions/git_actions.ahk src/actions/no_include/

# 3. Reiniciar HybridCapsLock
# Auto-loader detecta que git_actions.ahk ya no está

# 4. Verificar
cat init.ahk | grep git_actions
# Ya no aparece

# 5. Trabajar en el fix
vim src/actions/no_include/git_actions.ahk

# 6. Cuando esté arreglado, mover de vuelta
mv src/actions/no_include/git_actions.ahk src/actions/

# 7. Reiniciar
# Auto-loader lo detecta como "nuevo" y lo incluye
```

---

## 🎓 Buenas Prácticas

### **1. Nombrado Consistente**

```ahk
; Actions: *_actions.ahk
spotify_actions.ahk
youtube_actions.ahk
vscode_actions.ahk

; Layers: *_layer.ahk
database_layer.ahk
browser_layer.ahk
terminal_layer.ahk
```

### **2. Usar no_include/ Durante Desarrollo**

```bash
# Crear directamente en no_include/
touch src/actions/no_include/experimental_feature.ahk

# Desarrollar sin afectar sistema
# Cuando esté listo, mover a src/actions/
```

### **3. Prefijos para Archivos Desactivados**

```ahk
; En no_include/
_disabled_old_feature.ahk
_wip_new_layer.ahk
_backup_old_version.ahk
```

### **4. Documentar Estado**

```ahk
; En archivos de no_include/
; DESACTIVADO: Bug en Windows 11 - necesita fix
; Fecha: 2025-11-08
; TODO: Resolver conflicto con Excel layer

MyBuggyFunction() {
    ; ...
}
```

### **5. Limpiar Regularmente**

```bash
# Eliminar backups viejos
rm src/actions/no_include/_backup_*.ahk

# Revisar archivos WIP
ls src/layer/no_include/_wip_*.ahk
```

---

## 🐛 Troubleshooting

### **Auto-loader no detecta cambios**

**Causa**: `AUTO_LOADER_ENABLED := false`

**Solución**: Cambiar a `true` en `auto_loader.ahk`

---

### **Archivo no se incluye**

**Causa**: Está en carpeta `no_include/`

**Solución**: Mover a carpeta padre
```bash
mv src/actions/no_include/my_action.ahk src/actions/
```

---

### **Error "Markers not found"**

**Causa**: Marcadores eliminados o modificados en `init.ahk`

**Solución**: Restaurar marcadores:
```ahk
; ===== AUTO-LOADED ACTIONS START =====
; ===== AUTO-LOADED ACTIONS END =====

; ===== AUTO-LOADED LAYERS START =====
; ===== AUTO-LOADED LAYERS END =====
```

---

### **Memoria JSON corrupta**

**Causa**: Archivo JSON malformado

**Solución**: Eliminar y regenerar
```bash
rm data/auto_loader_memory.json
# Reiniciar HybridCapsLock (crea nuevo)
```

---

### **Includes duplicados**

**Causa**: Archivo incluido manualmente Y por auto-loader

**Solución**: 
1. Eliminar include manual de `init.ahk`
2. O mover archivo a `no_include/` si quieres gestión manual

---

## 📊 Estadísticas y Monitoreo

### **Ver qué está incluido**

```bash
# Leer memoria JSON
cat data/auto_loader_memory.json | jq '.actions[].name'
cat data/auto_loader_memory.json | jq '.layers[].name'

# Ver includes en init.ahk
grep -A 50 "AUTO-LOADED ACTIONS START" init.ahk
grep -A 50 "AUTO-LOADED LAYERS START" init.ahk
```

### **Ver qué está excluido**

```bash
# Actions desactivados
ls src/actions/no_include/*.ahk

# Layers desactivados
ls src/layer/no_include/*.ahk
```

### **OutputDebug Logs**

Usar herramienta como [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview):

```
[AutoLoader] Starting scan...
[AutoLoader] Scanned src\actions: found 15 files
[AutoLoader] No changes detected
```

---

## 🔮 Futuro y Extensiones

### **Posibles Mejoras**

1. **Hot-reload**: Recargar archivos sin reiniciar completo
2. **Dependencias**: Auto-detectar orden de include según dependencias
3. **Validación**: Verificar sintaxis antes de incluir
4. **UI**: Panel de control para activar/desactivar visualmente
5. **Versionado**: Trackear cambios en archivos incluidos

---

## 📚 Ver También

- **[Layer Templates](../templates/)** - Plantillas para crear capas
- **[PERSISTENT_LAYER_TEMPLATE.md](PERSISTENT_LAYER_TEMPLATE.md)** - Guía de capas persistentes
- **[GENERIC_ROUTER_ARCHITECTURE.md](GENERIC_ROUTER_ARCHITECTURE.md)** - Sistema de leader menu

---

## ✅ Checklist de Uso

Cuando crees un nuevo archivo:
- [ ] Crear en carpeta correcta (`src/actions/` o `src/layer/`)
- [ ] O crear en `no_include/` si aún no está listo
- [ ] Reiniciar HybridCapsLock
- [ ] Verificar que se incluye en `init.ahk`
- [ ] Verificar en memoria JSON
- [ ] Registrar keymaps si es necesario
- [ ] Probar funcionalidad

---

**¡El auto-loader hace que agregar nuevas features sea trivial!** 🚀
