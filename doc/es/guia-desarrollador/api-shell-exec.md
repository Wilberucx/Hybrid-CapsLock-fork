# Referencia API Shell Exec

**Core Plugin** | `system/plugins/shell_exec.ahk`

Shell Exec proporciona una API completa para ejecutar comandos de shell, scripts y programas sin mostrar ventanas de consola. Está diseñado como infraestructura central para otros plugins y configuraciones de usuario.

## 🎯 Filosofía de Diseño

Shell Exec sigue el **patrón closure** (similar a `SendInfo()`), haciéndolo perfecto para usar con `RegisterKeymap`:

```autohotkey
; ✅ Correcto - Retorna un closure
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; ❌ Incorrecto - Ejecuta inmediatamente
RegisterKeymap("leader", "p", "e", "Explorer", ShellExecNow("explorer.exe"), false, 1)
```

## 📚 Funciones Principales

### `ShellExec(command, param2?, param3?, param4?)`

**Función principal para uso en RegisterKeymap.** Retorna un closure que se ejecuta cuando es llamado.

**Detección Inteligente de Parámetros:**
- **Estados de ventana**: `"Hide"`, `"Show"`, `"Min"`, `"Max"`, `"Minimize"`, `"Maximize"`
- **Directorio de trabajo**: Cualquier ruta que contenga `\` o `/` o letra de unidad (`C:`)
- **Archivo de configuración**: Archivos con extensiones `.kbd`, `.json`, `.cfg`, `.conf`, `.ini`, `.xml`, `.yml`, `.yaml`, `.txt`
- **Parámetros adicionales**: Cualquier otra cosa se trata como parámetro del comando

**Parámetros:**
- `command` - Comando a ejecutar (exe, bat, vbs, ahk, o comando directo)
- `param2` - Opcional: directorio de trabajo, estado de ventana, o archivo config (auto-detectado)
- `param3` - Opcional: directorio de trabajo, estado de ventana, o archivo config (auto-detectado)
- `param4` - Opcional: directorio de trabajo, estado de ventana, o archivo config (auto-detectado)

**Retorna:** `Function` - Closure que ejecuta el comando cuando es llamado

**Ejemplos:**

```autohotkey
; Comando simple
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; Con estado de ventana
RegisterKeymap("leader", "t", "cmd", "Terminal", ShellExec("cmd.exe", "Show"), false, 1)

; Con directorio de trabajo
RegisterKeymap("leader", "g", "s", "Git Status", ShellExec("git status", "C:\\Projects"), false, 1)

; Con archivo de configuración
RegisterKeymap("leader", "k", "r", "Reload Kanata", ShellExec("kanata.exe", "kanata.kbd"), false, 1)

; Complejo: directorio de trabajo + estado de ventana
RegisterKeymap("leader", "d", "b", "Build", ShellExec("build.bat", "C:\\Projects", "Show"), false, 1)
```

---

### `ShellExecNow(command, param2?, param3?, param4?)`

**Función interna para ejecución inmediata.** NO usar directamente en RegisterKeymap.

**Parámetros:** Igual que `ShellExec()`

**Retorna:** `Boolean` - `true` si la ejecución fue exitosa, `false` en caso contrario

**Caso de Uso:** Cuando necesitas ejecución inmediata dentro del cuerpo de una función:

```autohotkey
MyCustomFunction() {
    result := ShellExecNow("git status", A_WorkingDir)
    if (result) {
        ShowCenteredToolTip("Comando Git ejecutado")
    }
}
```

---

## 🎨 Funciones Variantes

### Variantes de Estado de Ventana

Wrappers de conveniencia que preestablecen el estado de la ventana:

```autohotkey
ShellExecVisible(command, workingDir := "")
ShellExecMinimized(command, workingDir := "")
ShellExecMaximized(command, workingDir := "")
```

**Ejemplos:**

```autohotkey
RegisterKeymap("leader", "t", "p", "PowerShell", ShellExecVisible("powershell.exe"), false, 1)
RegisterKeymap("leader", "b", "c", "Compile", ShellExecMinimized("compile.bat"), false, 2)
```

---

### Variantes de Tipo de Archivo

Funciones especializadas para tipos de script específicos:

```autohotkey
ExecuteVBS(vbsPath, workingDir := "")
ExecuteBatch(batPath, workingDir := "")
ExecuteAHK(ahkPath, workingDir := "")
```

**Ejemplos:**

```autohotkey
RegisterKeymap("leader", "s", "v", "Run VBS", ExecuteVBS("scripts\\setup.vbs"), false, 1)
RegisterKeymap("leader", "s", "b", "Run Batch", ExecuteBatch("scripts\\deploy.bat", "C:\\Deploy"), false, 2)
```

---

## 🔧 Funciones Avanzadas

### `ShellExecCapture(command, workingDir?)`

Ejecuta el comando y captura su salida.

**Parámetros:**
- `command` - Comando a ejecutar
- `workingDir` - Directorio de trabajo opcional

**Retorna:** `String` - Salida del comando, o cadena vacía en caso de error

**Ejemplos:**

```autohotkey
; Capturar git status
output := ShellExecCapture("git status")
MsgBox(output)

; Capturar con directorio de trabajo
output := ShellExecCapture("dir", "C:\\Projects")

; Usar en una función
ShowGitStatus() {
    status := ShellExecCapture("git status")
    ShowCenteredToolTip(status)
}
```

---

### `ShellExecWait(command, workingDir?, timeout?)`

Ejecuta el comando y espera a que termine.

**Parámetros:**
- `command` - Comando a ejecutar
- `workingDir` - Directorio de trabajo opcional
- `timeout` - Timeout opcional en milisegundos (0 = sin timeout)

**Retorna:** `Integer` - Código de salida del proceso, o `-1` en caso de error/timeout

**Ejemplos:**

```autohotkey
; Esperar a que termine el comando
exitCode := ShellExecWait("build.bat")
if (exitCode == 0) {
    ShowCenteredToolTip("Build exitoso!")
}

; Con timeout (5 segundos)
exitCode := ShellExecWait("long-running-task.exe", "", 5000)
if (exitCode == -1) {
    ShowCenteredToolTip("Comando excedió el tiempo límite")
}
```

---

## 🛠️ Funciones de Conveniencia

Funciones predefinidas para operaciones comunes del sistema:

### Utilidades del Sistema

```autohotkey
OpenExplorer(path := "")
OpenCmd(path := "")
OpenPowerShell(path := "")
OpenTaskManager()
OpenControlPanel()
OpenDeviceManager()
OpenEventViewer()
OpenSystemInfo()
OpenRegistryEditor()
```

### Comandos de Red

```autohotkey
FlushDNS()
RenewIP()
```

### Recopilación de Información

```autohotkey
CheckPing(target := "8.8.8.8")
GetSystemInfo()
ListProcesses()
```

**Ejemplos:**

```autohotkey
; Abrir Explorer en carpeta específica
RegisterKeymap("leader", "f", "d", "Downloads", () => OpenExplorer(A_MyDocuments . "\\Downloads"), false, 1)

; Abrir CMD en carpeta de proyecto
RegisterKeymap("leader", "t", "p", "Project CMD", () => OpenCmd("C:\\Projects\\MyApp"), false, 1)

; Diagnóstico de red
RegisterKeymap("leader", "n", "f", "Flush DNS", FlushDNS, false, 1)
RegisterKeymap("leader", "n", "p", "Ping Google", () => MsgBox(CheckPing("8.8.8.8")), false, 2)
```

---

## 🎯 Lógica de Ejecución Inteligente

Shell Exec detecta automáticamente los tipos de archivo y usa el ejecutor apropiado:

| Tipo de Archivo | Ejecutor | Ejemplo |
|-----------|----------|---------|
| `.vbs` | `wscript.exe` | `ShellExec("script.vbs")` |
| `.bat`, `.cmd` | `cmd.exe /c` | `ShellExec("build.bat")` |
| `.ahk` | `AutoHotkey.exe` | `ShellExec("helper.ahk")` |
| `.exe` | Ejecución directa | `ShellExec("notepad.exe")` |
| Sin extensión | Ejecución directa | `ShellExec("explorer")` |
| Otro | `cmd.exe /c` | `ShellExec("custom.sh")` |

---

## 📋 Buenas Prácticas

### 1. Siempre usa ShellExec() para RegisterKeymap

```autohotkey
; ✅ Correcto
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; ❌ Incorrecto - ejecuta inmediatamente
RegisterKeymap("leader", "p", "e", "Explorer", ShellExecNow("explorer.exe"), false, 1)
```

### 2. Usa Rutas Absolutas para Scripts

```autohotkey
; ✅ Bien - ruta absoluta
ShellExec(A_ScriptDir . "\\scripts\\deploy.bat")

; ⚠️ Riesgoso - ruta relativa (depende del directorio de trabajo)
ShellExec("deploy.bat")
```

### 3. Especifica Estado de Ventana para Comandos Interactivos

```autohotkey
; ✅ Bien - muestra ventana para comandos interactivos
ShellExec("cmd.exe", "Show")
ShellExec("powershell.exe", "Show")

; ⚠️ Mal - oculta ventana, el usuario no puede interactuar
ShellExec("cmd.exe")
```

### 4. Usa ShellExecCapture para Procesar Salida

```autohotkey
; ✅ Bien - captura salida para procesar
GetGitBranch() {
    output := ShellExecCapture("git branch --show-current")
    return Trim(output)
}

; ❌ Mal - la salida se pierde
ShellExecNow("git branch --show-current")
```

### 5. Maneja Errores Elegantemente

```autohotkey
; ✅ Bien - verifica valor de retorno
MyDeployFunction() {
    result := ShellExecNow("deploy.bat", "C:\\Projects")
    if (!result) {
        ShowCenteredToolTip("Falló el despliegue!")
        return false
    }
    ShowCenteredToolTip("Despliegue exitoso!")
    return true
}
```

---

## 🔍 Debugging

Shell Exec se integra con el sistema de logging:

```autohotkey
; Habilitar debug logging en tu config
Log.SetLevel("DEBUG")

; Ahora todas las llamadas a ShellExec registrarán:
; - Comando ejecutado
; - Directorio de trabajo (si se especificó)
; - Estado de éxito/fallo
; - Mensajes de error
```

Ver logs con:
```autohotkey
Leader + h + l  ; Ver logs
```

---

## 🆚 Comparación con Patrón SendInfo

Tanto `ShellExec` como `SendInfo` usan el **patrón closure** para compatibilidad con RegisterKeymap:

| Aspecto | ShellExec | SendInfo |
|--------|-----------|----------|
| **Propósito** | Ejecutar comandos/programas | Insertar texto |
| **Retorna** | Closure (función) | Closure (función) |
| **Uso** | `ShellExec("cmd.exe")` | `SendInfo("text")` |
| **Variante inmediata** | `ShellExecNow()` | `InsertTextHelper()` |
| **Detección inteligente** | Estado ventana, rutas, archivos | Ninguna (texto simple) |

**Ejemplo de Patrón:**

```autohotkey
; Ambos siguen el mismo patrón
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
RegisterKeymap("leader", "i", "e", "Email", SendInfo("user@example.com"), false, 1)
```

---

## 🚀 Patrones de Uso Avanzado

### Construcción Dinámica de Comandos

```autohotkey
OpenProjectFolder(projectName) {
    path := "C:\\Projects\\" . projectName
    return ShellExec("explorer.exe", path)
}

RegisterKeymap("leader", "p", "1", "Project 1", OpenProjectFolder("MyApp"), false, 1)
RegisterKeymap("leader", "p", "2", "Project 2", OpenProjectFolder("WebSite"), false, 2)
```

### Ejecución Condicional

```autohotkey
SmartGitPush() {
    ; Verificar si está en repo git
    output := ShellExecCapture("git rev-parse --is-inside-work-tree")
    if (InStr(output, "true")) {
        ShellExecNow("git push", A_WorkingDir, "Show")
    } else {
        ShowCenteredToolTip("No estás en un repositorio git")
    }
}

RegisterKeymap("leader", "g", "p", "Git Push", SmartGitPush, false, 1)
```

### Encadenamiento de Comandos

```autohotkey
BuildAndDeploy() {
    ; Build
    exitCode := ShellExecWait("build.bat", "C:\\Projects")
    if (exitCode != 0) {
        ShowCenteredToolTip("Build falló!")
        return
    }
    
    ; Deploy
    result := ShellExecNow("deploy.bat", "C:\\Projects", "Show")
    if (result) {
        ShowCenteredToolTip("Despliegue iniciado!")
    }
}

RegisterKeymap("leader", "d", "b", "Build & Deploy", BuildAndDeploy, false, 1)
```

---

## 📖 Ver También

- [Arquitectura de Plugins](arquitectura-plugins.md) - Cómo funcionan los plugins en HybridCapsLock
- [SendInfo API](../../plugins/sendinfo_actions.ahk) - Patrón closure similar para inserción de texto
- [Creando Capas](../../guia-desarrollador/creando-capas.md) - Usando ShellExec en capas personalizadas
