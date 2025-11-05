# Capa de Comandos (Líder: leader → `c`)

Navegación y salida

- Esc: salir completamente de la paleta de comandos desde cualquier nivel (EXIT total)
- Backspace: volver al menú anterior (back inteligente). Si estás en una categoría, regresa a COMMAND PALETTE; si estás en COMMAND PALETTE, regresa al Leader.
- Backslash (\): reservado para back, pero puede no funcionar en todos los contextos; se estandariza Backspace como tecla de back.

Cómo se logró el back inteligente

- Con tooltips C# deshabilitados para entrada (tooltip_handles_input=false), el router de Leader mantiene un bucle dedicado (LeaderCommandsMenuLoop) que intercepta Esc/Backspace/"\" y retorna "EXIT" o "BACK" según corresponda, evitando que "\" llegue a los ejecutores como opción desconocida.
- Con tooltips C# habilitados para entrada, la navegación usa una pila (breadcrumb) que permite volver exactamente al menú anterior.

> Referencia rápida
>
> - Configuración: config/commands.ini
> - Confirmaciones: ver “Confirmaciones — Modelo de Configuración” en doc/CONFIGURATION.md y “Precedencia de Confirmación (Commands)” en este documento
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

Esta capa proporciona un **command palette jerárquico** que permite ejecutar scripts, comandos de terminal, comandos de PowerShell y aplicaciones directamente desde el teclado, organizados en categorías para una navegación más intuitiva.

## 🎯 Cómo Acceder

1. **Activa el Líder:** Presiona `leader`
2. **Entra en Capa Comandos:** Presiona `c`
3. **Selecciona categoría:** Presiona una tecla de categoría (s, n, g, m, f, w, v, o, a)
4. **Ejecuta comando:** Presiona la tecla del comando específico

## 🎮 Navegación en el Menú

- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú anterior
- **Timeout:** 10 segundos de inactividad cierra automáticamente

## 📋 Categorías Disponibles

### 🖥️ System Commands (s)

| Tecla | Comando            | Descripción                       |
| ----- | ------------------ | --------------------------------- |
| `s`   | **System Info**    | Información detallada del sistema |
| `t`   | **Task Manager**   | Administrador de tareas           |
| `v`   | **Services**       | Administrador de servicios        |
| `e`   | **Event Viewer**   | Visor de eventos                  |
| `d`   | **Device Manager** | Administrador de dispositivos     |
| `c`   | **Disk Cleanup**   | Limpieza de disco                 |

### 🌐 Network Commands (n)

| Tecla | Comando          | Descripción                       |
| ----- | ---------------- | --------------------------------- |
| `i`   | **IP Config**    | Configuración de red completa     |
| `p`   | **Ping Test**    | Test de conectividad a Google     |
| `n`   | **Network Info** | Información de conexiones activas |

### 🔧 Git Commands (g)

| Tecla | Comando          | Descripción                       |
| ----- | ---------------- | --------------------------------- |
| `s`   | **Git Status**   | Estado del repositorio            |
| `l`   | **Git Log**      | Historial de commits (últimos 10) |
| `b`   | **Git Branches** | Lista de ramas locales y remotas  |
| `d`   | **Git Diff**     | Diferencias no confirmadas        |
| `a`   | **Git Add All**  | Agregar todos los archivos        |
| `p`   | **Git Pull**     | Actualizar desde remoto           |

### 📊 Monitoring Commands (m)

| Tecla | Comando          | Descripción                    |
| ----- | ---------------- | ------------------------------ |
| `p`   | **Process List** | Lista de procesos activos      |
| `s`   | **Service List** | Lista de servicios del sistema |
| `d`   | **Disk Space**   | Espacio en disco disponible    |
| `m`   | **Memory Usage** | Uso de memoria RAM             |
| `c`   | **CPU Usage**    | Uso del procesador             |

### 📁 Folder Access (f)

| Tecla | Comando           | Descripción                       |
| ----- | ----------------- | --------------------------------- |
| `t`   | **Temp Folder**   | Carpeta temporal del sistema      |
| `a`   | **AppData**       | Datos de aplicaciones del usuario |
| `p`   | **Program Files** | Archivos de programa              |
| `u`   | **User Profile**  | Perfil del usuario actual         |
| `d`   | **Desktop**       | Escritorio del usuario            |
| `s`   | **System32**      | Carpeta del sistema Windows       |

> Nota: "Windows Commands (w)" fue integrado en "System Commands (s)".

### 🖥️ System Commands (s)

| Tecla | Comando                   | Descripción                          |
| ----- | ------------------------- | ------------------------------------ |
| `s`   | **System Info**           | Información del sistema (systeminfo) |
| `t`   | **Task Manager**          | Administrador de tareas              |
| `v`   | **Services**              | Servicios del sistema                |
| `d`   | **Device Manager**        | Administrador de dispositivos        |
| `c`   | **Disk Cleanup**          | Liberador de espacio en disco        |
| `h`   | **Toggle Hidden Files**   | Mostrar/ocultar archivos ocultos     |
| `r`   | **Registry Editor**       | Editor del registro                  |
| `e`   | **Event Viewer**          | Visor de eventos                     |
| `E`   | **Environment Variables** | Variables de entorno                 |

### 🔐 [VaultFlow](https://github.com/Wilberucx/vaultflow) Commands (v)

| Tecla | Comando              | Descripción                |
| ----- | -------------------- | -------------------------- |
| `v`   | **Launch VaultFlow** | Ejecutar comando VaultFlow |

### ⚡ Power Options (o)

### 🧩 Hybrid Management (h)

- R - Reload HybridCapsLock (confirma)
- p - Pause Hybrid (suspende hotkeys, auto-resume configurable; reanuda al pulsar Leader)
- l - View log file
- c - Open config folder
- v - Show version info
- s - Show System Status
- e - Exit Script

| Tecla | Comando       | Descripción          |
| ----- | ------------- | -------------------- |
| `s`   | **Sleep**     | Suspender el sistema |
| `h`   | **Hibernate** | Hibernar el sistema  |
| `r`   | **Restart**   | Reiniciar el sistema |
| `u`   | **Shutdown**  | Apagar el sistema    |

### 📱 ADB Tools (a)

| Tecla | Comando            | Descripción                        |
| ----- | ------------------ | ---------------------------------- |
| `d`   | **ADB Devices**    | Listar dispositivos conectados     |
| `x`   | **ADB Disconnect** | Desconectar todos los dispositivos |
| `s`   | **ADB Shell**      | Abrir shell de Android             |
| `l`   | **ADB Logcat**     | Ver logs del dispositivo           |
| `r`   | **ADB Reboot**     | Reiniciar dispositivo Android      |

## 🔧 Personalización de Tooltips

### Editar Tooltips Existentes

Los tooltips se configuran en `commands.ini` en la sección `[MenuDisplay]`. Cada línea sigue el formato:

```ini
[MenuDisplay]
# Menú principal
main_line1=SYSTEM:
main_line2=s - System Commands  n - Network Commands
main_line3=g - Git Commands     m - Monitoring Commands
main_line4=f - Folder Access    w - Windows Commands
main_line5=
main_line6=CUSTOM:
main_line7=v - VaultFlow        o - Power Options
main_line8=a - ADB Tools

# Submenús por categoría
system_line1=s - System Info
system_line2=t - Task Manager
system_line3=v - Services
system_line4=e - Event Viewer
system_line5=d - Device Manager
system_line6=c - Disk Cleanup

network_line1=i - IP Config
network_line2=p - Ping Test
network_line3=n - Network Info

git_line1=s - Git Status
git_line2=l - Git Log
git_line3=b - Git Branches
git_line4=d - Git Diff
git_line5=a - Git Add All
git_line6=p - Git Pull
```

### Agregar Nuevas Líneas

Para agregar una nueva opción al tooltip:

```ini
# Ejemplo: Agregar comando al menú de sistema
system_line7=x - Mi Nuevo Comando
```

### Personalizar Texto

Puedes cambiar cualquier texto del tooltip:

```ini
# Cambiar de inglés a español
system_line1=s - Información del Sistema
system_line2=t - Administrador de Tareas
network_line1=i - Configuración IP
git_line1=s - Estado de Git
```

### Reorganizar Menús

Puedes reorganizar completamente los menús:

```ini
# Ejemplo: Reorganizar menú principal
main_line1=DESARROLLO:
main_line2=g - Git Commands     n - Network Commands
main_line3=
main_line4=SISTEMA:
main_line5=s - System Commands  m - Monitoring Commands
main_line6=f - Folder Access    w - Windows Commands
```

## 🚀 Agregar Nuevos Comandos

### Paso 1: Actualizar el Tooltip

Primero, agrega la nueva opción al tooltip en `commands.ini`:

```ini
[MenuDisplay]
system_line7=x - Mi Comando Personalizado
```

### Paso 2: Modificar la Función de Ejecución

En `HybridCapsLock.ahk`, localiza la función correspondiente y agrega el nuevo caso:

```autohotkey
ExecuteSystemCommand(cmd) {
    Switch cmd {
        Case "s":
            Run("cmd.exe /k systeminfo")
        Case "t":
            Run, taskmgr.exe
        Case "v":
            Run, services.msc
        Case "e":
            Run("eventvwr.msc")
        Case "d":
            Run, devmgmt.msc
        Case "c":
            Run("cleanmgr.exe")
        Case "x":  ; Tu nuevo comando
            Run, notepad.exe
    }
    ShowCommandExecuted("System", cmd)
    return
}
```

### Paso 3: Actualizar el Input

Agrega la nueva tecla al Input de la categoría:

```autohotkey
# Buscar esta línea en el código:
Input, _sysCmd, L1 T10, {Escape}{Backspace}, s,t,v,e,d,c

# Cambiar a:
ih := InputHook("L1 T10", "{Escape}{Backspace}")
ih.Start()
ih.Wait()
_sysCmd := ih.Input
```

## 🆕 Agregar Nueva Categoría

### Paso 1: Agregar al Menú Principal

En `commands.ini`, agrega la nueva categoría al menú principal:

```ini
[MenuDisplay]
main_line9=x - Mi Nueva Categoría
```

### Paso 2: Crear Tooltip de la Categoría

```ini
[MenuDisplay]
micategoria_line1=a - Mi Primer Comando
micategoria_line2=b - Mi Segundo Comando
micategoria_line3=c - Mi Tercer Comando
```

### Paso 3: Crear Función de Menú

En `HybridCapsLock.ahk`, agrega la nueva función:

```autohotkey
ShowMiCategoriaCommandsMenu() {
    global CommandsIni
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 90
    MenuText := "MI CATEGORIA`n"
    MenuText .= "`n"

    Loop, 10 {
        lineContent := IniRead(CommandsIni, "MenuDisplay", "micategoria_line" . A_Index, "")
        if (lineContent != "ERROR" && lineContent != "") {
            MenuText .= lineContent . "`n"
        }
    }

    MenuText .= "`n"
    MenuText .= "[Backspace: Back] [Esc: Exit]"
    ToolTip(MenuText, ToolTipX, ToolTipY)
    return
}
```

### Paso 4: Crear Función de Ejecución

```autohotkey
ExecuteMiCategoriaCommand(cmd) {
    Switch cmd {
        Case "a":
            Run("cmd.exe /k echo \"Mi Primer Comando\"")
        Case "b":
            Run, notepad.exe
        Case "c":
            Run("calc.exe")
    }
    ShowCommandExecuted("MiCategoria", cmd)
    return
}
```

### Paso 5: Integrar en el Switch Principal

En la función principal de comandos, agrega el nuevo caso:

```autohotkey
# Buscar esta línea:
Input, _cmdCategory, L1 T10, {Escape}{Backspace}, s,n,g,m,f,w,v,o,a

# Cambiar a:
ih := InputHook("L1 T10", "{Escape}{Backspace}")
ih.Start()
ih.Wait()
_cmdCategory := ih.Input

# Agregar al Switch:
Case "x": ; Mi Nueva Categoría
    ShowMiCategoriaCommandsMenu()
    ih := InputHook("L1 T10", "{Escape}{Backspace}")
ih.Start()
ih.Wait()
_miCmd := ih.Input

    if (ErrorLevel = "Timeout" || ErrorLevel = "EndKey:Escape") {
        _exitLeader := true
    } else if (ErrorLevel = "EndKey:Backspace") {
        continue ; Back to commands menu
    } else {
        ExecuteMiCategoriaCommand(_miCmd)
        _exitLeader := true
    }
```

## 📝 Tipos de Comandos Soportados

### Comandos CMD

```autohotkey
Run("cmd.exe /k ipconfig /all")
```

### Comandos PowerShell

```autohotkey
Run("powershell.exe -Command \"Get-Process | Sort-Object CPU\"")
```

### Ejecutables Directos

```autohotkey
Run, taskmgr.exe
Run, notepad.exe
```

### Scripts

```autohotkey
Run("C:\\Scripts\\mi_script.bat")
Run("powershell.exe -File \"C:\\Scripts\\mi_script.ps1\"")
```

### Archivos MSC (Consolas de Windows)

```autohotkey
Run, services.msc
Run, devmgmt.msc
```

## ⚙️ Configuración y Confirmaciones

### Precedencia de Confirmación (Commands)

Orden (mayor a menor):

1. Global: `configuration.ini` → `[Behavior]` → `show_confirmation_global`
2. Categoría: `commands.ini` → `[CategorySettings]` `<Friendly>_show_confirmation`
   - `true`: fuerza confirmación para toda la categoría (omite per-command)
   - `false`: delega a per-command
3. Per-command (listas): `commands.ini` → `[Confirmations.<Friendly>]`
   - `confirm_keys`: teclas que DEBEN confirmar (case-sensitive)
   - `no_confirm_keys`: teclas que NO deben confirmar
   - Compatibilidad extendida: alias `key_ascii_<ord>` → `key_<char>` → clave raw
4. Default de capa: `commands.ini` → `[Settings]` → `show_confirmation`
5. Fallback: `power=true`, otros `false`

Ejemplos:

```ini
[Behavior]
show_confirmation_global=false

[CategorySettings]
PowerOptions_show_confirmation=true

[Confirmations.HybridManagement]
confirm_keys=R

[Settings]
show_confirmation=true
[Confirmations.PowerOptions]
no_confirm_keys=s h
```

## ⚙️ Configuración Avanzada

### Custom Commands y CommandFlag (qué y cómo)

- Custom Commands (`[CustomCommands]`): definen QUÉ ejecutar (tipo:payload).
- CommandFlag (`[CommandFlag.<Nombre>]`): definen CÓMO ejecutar (terminal, admin, working_dir, env, etc.).
- Menú por categoría (`[<catKey>_category]`): cada tecla puede apuntar a una acción con `k_action=@Nombre` o `k_action=tipo:payload` inline.
- Confirmación: se controla por la jerarquía actual (global → categoría → per-key listas); no se define en CommandFlag.
- Variables opcionales (`[CustomVars]`): placeholders `{Var}` en payloads/opciones.

Ejemplo:

```ini
[CustomCommands]
GitStatus=cmd:git status

[CommandFlag.GitStatus]
terminal=conhost
keep_open=true

[t_category]
title=Tools
order=g
g=Git Status
g_action=@GitStatus
; confirmación si se desea, en la categoría:
; confirm_keys=g
```

Para detalles ver `doc/COMMANDS_CUSTOM.md`.

### Archivo commands.ini - Sección [Settings]

```ini
[Settings]
show_output=true          ; Mostrar ventana de salida
close_on_success=false    ; No cerrar automáticamente
timeout_seconds=30        ; Timeout para comandos largos
enable_custom_commands=true ; Permitir comandos personalizados
```

### Sección [CategorySettings]

```ini
[CategorySettings]
system_timeout=10         ; Timeout específico para comandos de sistema
network_timeout=10        ; Timeout para comandos de red
git_timeout=10           ; Timeout para comandos Git
show_execution_feedback=true ; Mostrar feedback de ejecución
feedback_duration=1500   ; Duración del feedback (ms)
```

## 💡 Consejos de Uso

### 🚀 Flujo Rápido

```
leader → c → s → t (Task Manager en 4 teclas)
leader → c → g → s (Git Status en 4 teclas)
leader → c → f → t (Temp folder en 4 teclas)
```

### 🎯 Comandos Frecuentes

- **Desarrollo:** `g` (Git), `n` (Network), `f` (Folders)
- **Administración:** `s` (System), `m` (Monitoring), `w` (Windows)
- **Utilidades:** `o` (Power), `a` (ADB), `v` (VaultFlow)

### ⚡ Memoria Muscular

Las teclas siguen patrones mnemotécnicos:

- `s` = **S**ystem
- `g` = **G**it
- `n` = **N**etwork
- `m` = **M**onitoring
- `f` = **F**older

## ⚠️ Solución de Problemas

### Comando No Aparece en Tooltip

1. **Verificar sintaxis:** Asegúrate de que la línea en `commands.ini` esté bien formateada
2. **Reiniciar script:** Recarga HybridCapsLock para aplicar cambios
3. **Verificar numeración:** Las líneas deben ser consecutivas (line1, line2, etc.)

### Comando No Se Ejecuta

1. **Verificar función:** Asegúrate de que el comando esté en la función Execute correspondiente
2. **Verificar Input:** La tecla debe estar incluida en el Input de la categoría
3. **Verificar permisos:** Algunos comandos requieren permisos de administrador

### Tooltip Se Ve Mal

1. **Longitud de líneas:** Mantén las líneas de tooltip relativamente cortas
2. **Alineación:** Usa espacios para alinear columnas si es necesario
3. **Líneas vacías:** Usa `main_line5=` (vacía) para agregar espacios

## 🔄 Migración y Compatibilidad

Si vienes de una versión anterior:

1. **Los comandos siguen funcionando** - La funcionalidad no ha cambiado
2. **Tooltips ahora editables** - Puedes personalizar todos los menús desde `commands.ini`
3. **Mismas teclas** - La navegación es idéntica
4. **Mejor organización** - Los tooltips están centralizados en el archivo .ini

---

## ✅ Estado de Implementación

**✅ COMPLETAMENTE IMPLEMENTADO** - La capa de comandos está totalmente funcional con tooltips editables desde `commands.ini`.

### 🎯 Funcionalidades Destacadas

- **📝 Tooltips Editables:** Todos los menús se pueden personalizar desde `commands.ini`
- **🔧 Fácil Extensión:** Agregar nuevos comandos y categorías es sencillo
- **🎨 Personalización Completa:** Cambiar texto, reorganizar menús, agregar opciones
- **⚡ Navegación Rápida:** Sistema jerárquico intuitivo con timeouts configurables
- **🔄 Compatibilidad:** Mantiene toda la funcionalidad existente

**¿Necesitas más comandos?** Sigue esta guía para agregar tus propios comandos y categorías personalizadas.
