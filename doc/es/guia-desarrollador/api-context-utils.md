# Referencia API Context Utils

**Core Plugin** | `system/plugins/context_utils.ahk`

Context Utils proporciona funciones centralizadas para detectar el contexto del sistema, como rutas activas, tipos de ventanas y procesos. Está diseñado como infraestructura central para otros plugins que necesitan comportamiento context-aware.

## 🎯 Filosofía de Diseño

Context Utils es un **core plugin** que NO registra keymaps. Solo provee funciones de utilidad que otros plugins pueden usar para detectar el contexto actual del sistema.

## 📚 Funciones Principales

### `GetActiveExplorerPath()`

Retorna la ruta del directorio actualmente abierto en Windows Explorer.

**Parámetros:** Ninguno

**Retorna:** `String` - Ruta del directorio activo, o cadena vacía (`""`) si no hay ventana de Explorer activa

**Ejemplo:**

```autohotkey
; Obtener ruta actual de Explorer
path := GetActiveExplorerPath()
if (path != "") {
    MsgBox("Carpeta activa: " . path)
} else {
    MsgBox("No hay ventana de Explorer activa")
}

; Usar en un plugin para abrir terminal en carpeta actual
OpenTerminalHere() {
    path := GetActiveExplorerPath()
    if (path != "") {
        ShellExecNow("wt.exe", path, "Show")
    } else {
        ShellExecNow("wt.exe", "", "Show")
    }
}

RegisterKeymap("leader", "t", "h", "Terminal Here", OpenTerminalHere, false, 1)
```

---

### `GetSelectedExplorerItem()`

Retorna la ruta completa del archivo o carpeta actualmente seleccionado en Windows Explorer.

**Parámetros:** Ninguno

**Retorna:** `String` - Ruta completa del elemento seleccionado, o cadena vacía (`""`) si no hay elemento seleccionado o no hay ventana de Explorer activa

**Técnico:** Usa COM (`Shell.Application`) para consultar la ventana de Explorer activa por el elemento seleccionado.

**Ejemplo:**

```autohotkey
; Obtener archivo/carpeta seleccionado en Explorer
selectedItem := GetSelectedExplorerItem()
if (selectedItem != "") {
    MsgBox("Seleccionado: " . selectedItem)
} else {
    MsgBox("No hay elemento seleccionado en Explorer")
}

; Copiar ruta del elemento seleccionado
CopySelectedItemPath() {
    path := GetSelectedExplorerItem()
    if (path != "") {
        A_Clipboard := path
        ShowQuickTip("¡Ruta copiada!", "")
    }
}

RegisterKeymap("explorer", "c", "p", "Copiar Ruta", CopySelectedItemPath, false, 1)
```

---

### `IsTerminalWindow()`

Verifica si la ventana activa es un emulador de terminal conocido.

**Terminales Soportados:**
- Windows Terminal
- Mintty (Git Bash)
- Alacritty
- WezTerm
- CMD (legacy)
- PowerShell (legacy)

**Parámetros:** Ninguno

**Retorna:** `Boolean` - `true` si la ventana activa es un terminal, `false` en caso contrario

**Ejemplo:**

```autohotkey
; Verificar si estamos en terminal
if (IsTerminalWindow()) {
    MsgBox("Estás en un terminal")
} else {
    MsgBox("No estás en un terminal")
}

; Usar para comportamiento condicional
SmartPaste() {
    if (IsTerminalWindow()) {
        Send("^+v")  ; Ctrl+Shift+V en terminales
    } else {
        Send("^v")   ; Ctrl+V en otras aplicaciones
    }
}
```

---

### `GetPasteShortcut()`

Retorna el atajo de pegado apropiado para la ventana activa.

**Parámetros:** Ninguno

**Retorna:** `String` - `"^+v"` para terminales, `"^v"` para todo lo demás

**Ejemplo:**

```autohotkey
; Pegar de manera inteligente
SmartPaste() {
    Send(GetPasteShortcut())
}

RegisterKeymap("vim", "p", "Paste", SmartPaste, false, 1)
```

---

### `GetActiveProcessName()`

Retorna el nombre del proceso de la ventana activa.

**Parámetros:** Ninguno

**Retorna:** `String` - Nombre del proceso (ej: `"notepad.exe"`, `"Code.exe"`), o cadena vacía (`""`) si no se puede detectar

**Ejemplo:**

```autohotkey
; Obtener proceso activo
process := GetActiveProcessName()
MsgBox("Proceso activo: " . process)

; Usar para comportamiento específico por aplicación
IsVSCode() {
    return (GetActiveProcessName() == "Code.exe")
}

; Usar con Dynamic Layer
ActivateDynamicLayer() {
    process := GetActiveProcessName()
    if (process == "EXCEL.EXE") {
        SwitchToLayer("excel")
    } else if (process == "Code.exe") {
        SwitchToLayer("vscode")
    }
}
```

---

### `LoadHistory(key, iniFile)`

Carga el historial almacenado en un archivo INI.

**Parámetros:**
- `key` (String): Clave en la sección "History" del archivo INI
- `iniFile` (String): Ruta al archivo INI

**Retorna:** `Array` - Array de strings con el historial, o array vacío si no existe

**Ejemplo:**

```autohotkey
; Cargar historial de carpetas
GetMyDataPath() {
    dataPath := "data\\my_plugin.ini"
    SplitPath(dataPath, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    return dataPath
}

iniFile := GetMyDataPath()
history := LoadHistory("CustomFolders", iniFile)

for index, path in history {
    MsgBox("Carpeta " . index . ": " . path)
}
```

---

### `SaveHistory(key, value, iniFile)`

Guarda un valor en el historial de un archivo INI, moviéndolo al tope si ya existe.

**Parámetros:**
- `key` (String): Clave en la sección "History" del archivo INI
- `value` (String): Valor a agregar al historial
- `iniFile` (String): Ruta al archivo INI

**Comportamiento:**
- Elimina el valor si ya existe en el historial
- Inserta el valor en la primera posición
- Mantiene un máximo de 10 items
- Guarda automáticamente en el archivo INI

**Ejemplo:**

```autohotkey
; Guardar carpeta en historial
iniFile := GetMyDataPath()
SaveHistory("CustomFolders", "C:\\Users\\Documents", iniFile)

; El historial ahora tiene "C:\\Users\\Documents" en la posición 1

; Cargar y mostrar historial actualizado
history := LoadHistory("CustomFolders", iniFile)
MsgBox("Última carpeta: " . history[1])
```

---

## 🎨 Patrones de Uso Comunes

### Patrón 1: Comportamiento Context-Aware

```autohotkey
; Función que se adapta según la aplicación
SmartAction() {
    process := GetActiveProcessName()
    
    if (process == "EXCEL.EXE") {
        Send("{Down}")  ; En Excel, navegar celda
    } else if (IsTerminalWindow()) {
        Send("^c")      ; En terminal, copiar
    } else {
        Send("^v")      ; En otras apps, pegar
    }
}
```

### Patrón 2: Abrir Terminal en Carpeta Actual

```autohotkey
; Plugin: terminal_here.ahk
OpenTerminalInCurrentFolder() {
    path := GetActiveExplorerPath()
    
    if (path != "") {
        ; Hay Explorer activo, abrir terminal ahí
        ShellExecNow("wt.exe", path, "Show")
    } else {
        ; No hay Explorer, abrir en home
        ShellExecNow("wt.exe", A_MyDocuments, "Show")
    }
}

RegisterKeymap("leader", "t", "h", "Terminal Here", OpenTerminalInCurrentFolder, false, 1)
```

### Patrón 3: Copiar Ruta Actual

```autohotkey
; Plugin: copy_path.ahk
CopyCurrentPath() {
    path := GetActiveExplorerPath()
    
    if (path != "") {
        A_Clipboard := path
        ShowCenteredToolTip("Ruta copiada: " . path)
        SetTimer(() => RemoveToolTip(), -2000)
    } else {
        ShowCenteredToolTip("No hay ventana de Explorer activa")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

RegisterKeymap("leader", "f", "y", "Copy Path", CopyCurrentPath, false, 1)
```

### Patrón 4: Detección de Aplicación para Dynamic Layer

```autohotkey
; Usado internamente por dynamic_layer.ahk
GetLayerForCurrentApp() {
    process := GetActiveProcessName()
    bindings := LoadLayerBindings()  ; Desde dynamic_layer.ahk
    
    if (bindings.Has(process)) {
        return bindings[process]
    }
    return ""
}
```

### Patrón 5: Persistencia de Historial

```autohotkey
; Plugin: my_plugin.ahk
GetMyDataPath() {
    dataPath := "data\\my_plugin.ini"
    SplitPath(dataPath, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    return dataPath
}

ShowRecentItems() {
    iniFile := GetMyDataPath()
    history := LoadHistory("RecentItems", iniFile)
    
    ; Mostrar en GUI
    g := Gui(, "Recent Items")
    lb := g.Add("ListBox", "w400 h200", history)
    g.Show()
}

SaveRecentItem(item) {
    iniFile := GetMyDataPath()
    SaveHistory("RecentItems", item, iniFile)
}

RegisterKeymap("leader", "r", "h", "Recent Items", ShowRecentItems, false, 1)
```

---

## 📋 Buenas Prácticas

### 1. Siempre Verifica Valores de Retorno

```autohotkey
; ✅ Bien - verifica antes de usar
path := GetActiveExplorerPath()
if (path != "") {
    ; Usar path
}

; ❌ Mal - asume que siempre hay valor
path := GetActiveExplorerPath()
Run("explorer.exe " . path)  ; Falla si path está vacío
```

### 2. Usa IsTerminalWindow() para Atajos Específicos

```autohotkey
; ✅ Bien - adapta el atajo según contexto
Paste() {
    Send(GetPasteShortcut())
}

; ❌ Mal - asume que siempre es Ctrl+V
Paste() {
    Send("^v")  ; No funciona en terminales
}
```

### 3. Combina con ShellExec para Máxima Flexibilidad

```autohotkey
; ✅ Bien - usa context + shell exec
OpenTerminalHere() {
    path := GetActiveExplorerPath()
    if (path != "") {
        return ShellExec("wt.exe", path, "Show")
    }
    return ShellExec("wt.exe", "", "Show")
}
```

---

## 🔍 Debugging

Context Utils se integra con el sistema de logging:

```autohotkey
; Habilitar debug logging
Log.SetLevel("DEBUG")

; Probar funciones
process := GetActiveProcessName()
Log.d("Proceso activo: " . process, "CONTEXT")

path := GetActiveExplorerPath()
Log.d("Ruta Explorer: " . path, "CONTEXT")

isTerminal := IsTerminalWindow()
Log.d("Es terminal: " . isTerminal, "CONTEXT")
```

---

## 🆚 Comparación con Otros Core Plugins

| Plugin | Propósito | Retorna |
|--------|-----------|---------|
| **context_utils** | Detectar contexto del sistema y persistir datos | Información (strings, booleans, arrays) |
| **shell_exec** | Ejecutar comandos | Closures para RegisterKeymap |
| **dynamic_layer** | Activar capas por proceso | Acciones (void) |
| **hybrid_actions** | Gestión del sistema | Acciones (void) |

---

## 📖 Ver También

- [Arquitectura de Plugins](arquitectura-plugins.md) - Cómo funcionan los core plugins
- [API Shell Exec](api-shell-exec.md) - Ejecutar comandos con contexto
- [Dynamic Layer](../../../system/plugins/dynamic_layer.ahk) - Usar GetActiveProcessName() para capas
- [Folder Actions Plugin](../../plugins/folder_actions.ahk) - Ejemplo de uso de GetActiveExplorerPath()
- [Explorer Actions Plugin](../../plugins/explorer_actions.ahk) - Ejemplo de uso de GetSelectedExplorerItem()
