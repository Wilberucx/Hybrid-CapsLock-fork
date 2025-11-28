# Referencia API Dynamic Layer

**Core Plugin** | `system/plugins/dynamic_layer.ahk`

Dynamic Layer proporciona un sistema para activar capas automáticamente según la aplicación activa. Permite asignar capas específicas a procesos y activarlas con un simple tap de CapsLock.

## 🎯 Filosofía de Diseño

Dynamic Layer es un **core plugin** que:
- Gestiona bindings entre procesos y capas
- Persiste configuración en JSON
- Provee GUIs para gestión de bindings
- Se integra con el sistema de capas

## 📚 Funciones Principales

### `ActivateDynamicLayer()`

Activa manualmente la capa asignada al proceso actual.

**Parámetros:** Ninguno

**Retorna:** `Boolean` - `true` si se activó una capa, `false` en caso contrario

**Comportamiento:**
1. Obtiene el proceso activo usando `GetActiveProcessName()`
2. Busca en `data/layer_bindings.json` si hay una capa asignada
3. Si existe, activa esa capa con `SwitchToLayer()`
4. Muestra tooltip con resultado

**Ejemplo:**

```autohotkey
; Activar capa para proceso actual
ActivateDynamicLayer()

; Usar en keymap (ya está configurado en keymap.ahk)
#HotIf (DYNAMIC_LAYER_ENABLED)
F23:: ActivateDynamicLayer()  ; Tap CapsLock
#HotIf

; Usar en Leader menu
RegisterKeymap("leader", "d", "Dynamic Layer", ActivateDynamicLayer, false, 1)
```

**Mensajes de Tooltip:**
- `"Dynamic Layer system is disabled"` - Si `DYNAMIC_LAYER_ENABLED` es false
- `"Unable to detect active process"` - Si no se puede obtener el proceso
- `"No layer bound to: [proceso]"` - Si no hay capa asignada
- Activa la capa si todo es correcto

---

### `ToggleDynamicLayer()`

Activa o desactiva el sistema Dynamic Layer globalmente.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
- Cambia el valor de `DYNAMIC_LAYER_ENABLED`
- Muestra tooltip con estado actual

**Ejemplo:**

```autohotkey
; Toggle del sistema
ToggleDynamicLayer()

; Usar en keymap
RegisterKeymap("leader", "h", "t", "Toggle Dynamic Layer", ToggleDynamicLayer, false, 8)
```

**Estados:**
- `"Dynamic Layer: ENABLED"` - Sistema activado
- `"Dynamic Layer: DISABLED"` - Sistema desactivado

---

### `ShowBindProcessGui()`

Muestra GUI para asignar una capa al proceso actualmente activo.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
1. Detecta el proceso activo
2. Carga capas disponibles desde `data/layers.json`
3. Muestra GUI con lista de capas
4. Permite seleccionar y asignar capa al proceso
5. Guarda binding en `data/layer_bindings.json`

**Ejemplo:**

```autohotkey
; Abrir GUI para registrar proceso
ShowBindProcessGui()

; Usar en keymap
RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 7)
```

**Flujo de Usuario:**
1. Abre la aplicación que quieres configurar (ej: Excel)
2. Presiona `Leader → h → r`
3. Selecciona la capa de la lista (ej: "excel")
4. Click en "Bind"
5. Ahora tap CapsLock en Excel activará la capa de Excel

---

### `ShowBindingsListGui()`

Muestra GUI con lista de todos los bindings configurados.

**Parámetros:** Ninguno

**Retorna:** Void

**Comportamiento:**
1. Carga bindings desde `data/layer_bindings.json`
2. Carga nombres de capas desde `data/layers.json`
3. Muestra lista con formato: `proceso → nombre_capa`

**Ejemplo:**

```autohotkey
; Ver bindings configurados
ShowBindingsListGui()

; Usar en keymap
RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 9)
```

**Ejemplo de Salida:**
```
EXCEL.EXE → Excel Layer
Code.exe → VS Code Layer
chrome.exe → Browser Layer
```

---

## 🗂️ Sistema de Persistencia

### Archivos JSON

#### `data/layer_bindings.json`

Almacena los bindings entre procesos y capas.

**Formato:**
```json
{
  "EXCEL.EXE": "excel",
  "Code.exe": "vscode",
  "chrome.exe": "browser"
}
```

#### `data/layers.json`

Generado automáticamente por `RegisterLayer()`, contiene metadata de todas las capas.

**Formato:**
```json
{
  "layers": [
    {"id": "excel", "name": "Excel Layer"},
    {"id": "vscode", "name": "VS Code Layer"}
  ],
  "lastUpdate": "2025-11-28T01:00:00"
}
```

---

## 🎨 Patrones de Uso

### Patrón 1: Configurar Capa para Aplicación

```autohotkey
; 1. Crear la capa
RegisterLayer("excel", "EXCEL", "#10B981", "#FFFFFF")
RegisterKeymap("excel", "j", "Down Cell", () => Send("{Down}"), false, 1)
RegisterKeymap("excel", "k", "Up Cell", () => Send("{Up}"), false, 2)

; 2. Abrir Excel
; 3. Presionar Leader → h → r
; 4. Seleccionar "excel" de la lista
; 5. Click "Bind"

; Ahora tap CapsLock en Excel activará la capa de Excel
```

### Patrón 2: Verificar Bindings Actuales

```autohotkey
; Ver qué procesos tienen capas asignadas
ShowBindingsListGui()

; O programáticamente
bindings := LoadLayerBindings()
for process, layerId in bindings {
    MsgBox(process . " → " . layerId)
}
```

### Patrón 3: Activación Manual

```autohotkey
; Activar capa del proceso actual sin tap CapsLock
ActivateDynamicLayer()

; Útil para testing o debugging
```

---

## 🔧 Funciones Internas

### `LoadLayerBindings()`

Carga bindings desde JSON.

**Retorna:** `Map` - Mapa de proceso → layerId

### `SaveLayerBindings(bindings)`

Guarda bindings a JSON.

**Parámetros:**
- `bindings` - Map de proceso → layerId

### `LoadAvailableLayers()`

Carga metadata de capas desde JSON.

**Retorna:** `Map` - Mapa de layerId → nombre

### `GetLayerForProcess(processName)`

Obtiene la capa asignada a un proceso.

**Parámetros:**
- `processName` - Nombre del proceso (ej: "EXCEL.EXE")

**Retorna:** `String` - ID de la capa, o `""` si no hay binding

---

## 📋 Buenas Prácticas

### 1. Crea la Capa Antes de Asignarla

```autohotkey
; ✅ Bien - capa existe
RegisterLayer("excel", "EXCEL", "#10B981", "#FFFFFF")
; ... registrar keymaps ...
; Ahora asignar con GUI

; ❌ Mal - asignar capa que no existe
; ShowBindProcessGui() → seleccionar capa inexistente
```

### 2. Usa Nombres de Proceso Exactos

Los nombres de proceso son case-sensitive:
- ✅ `"EXCEL.EXE"` (correcto)
- ❌ `"excel.exe"` (puede no funcionar)

Usa `GetActiveProcessName()` para verificar el nombre exacto.

### 3. Desactiva el Sistema si No lo Usas

```autohotkey
; Si no usas Dynamic Layer, desactívalo
global DYNAMIC_LAYER_ENABLED := false
```

---

## 🔍 Debugging

```autohotkey
; Habilitar logging
Log.SetLevel("DEBUG")

; Probar detección de proceso
process := GetActiveProcessName()
Log.d("Proceso activo: " . process, "DYNAMIC_LAYER")

; Probar binding
layerId := GetLayerForProcess(process)
Log.d("Capa asignada: " . layerId, "DYNAMIC_LAYER")

; Probar activación
result := ActivateDynamicLayer()
Log.d("Activación exitosa: " . result, "DYNAMIC_LAYER")
```

---

## 🆚 Comparación con Otros Sistemas

| Aspecto | Dynamic Layer | Capas Manuales |
|---------|---------------|----------------|
| **Activación** | Automática (tap CapsLock) | Manual (Leader → tecla) |
| **Configuración** | GUI visual | Código en keymap.ahk |
| **Persistencia** | JSON automático | Código estático |
| **Flexibilidad** | Por proceso | Por necesidad |

---

## 📖 Ver También

- [API Context Utils](api-context-utils.md) - `GetActiveProcessName()` usado por Dynamic Layer
- [Sistema de Capas](../guia-usuario/layers.md) - Cómo crear capas
- [Conceptos Clave](../guia-usuario/conceptos.md) - Explicación del sistema Dynamic Layer
