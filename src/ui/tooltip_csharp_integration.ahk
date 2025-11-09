; ===================================================================
; INTEGRACIÓN C# TOOLTIP PARA HYBRIDCAPSLOCK v2
; ===================================================================
; Archivo de integración para reemplazar tooltips básicos con C# + WPF
; Incluir este archivo en HybridCapsLock.ahk con: #Include tooltip_csharp_integration.ahk

; ===================================================================
; VARIABLES GLOBALES NECESARIAS
; ===================================================================

; Definir rutas de configuración si no están definidas
if (!IsSet(ConfigIni)) {
    global ConfigIni := A_ScriptDir . "\config\configuration.ini"
}
if (!IsSet(ProgramsIni)) {
    global ProgramsIni := A_ScriptDir . "\config\programs.ini"
}
if (!IsSet(InfoIni)) {
    global InfoIni := A_ScriptDir . "\config\information.ini"
}
if (!IsSet(TimestampsIni)) {
    global TimestampsIni := A_ScriptDir . "\config\timestamps.ini"
}
if (!IsSet(CommandsIni)) {
    global CommandsIni := A_ScriptDir . "\config\commands.ini"
}

; Variables globales para configuración de tooltips
global tooltipConfig := ReadTooltipConfig()

; Stop/kills the TooltipApp process if running
; duplicate removed

; ===================================================================
; FUNCIONES DE CONFIGURACIÓN
; ===================================================================

; Helper global para limpiar valores leídos del INI (remueve comentarios ; y espacios)
CleanIniValue(value) {
    if (InStr(value, ";")) {
        value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
    }
    return Trim(value)
}

; Función para leer configuración de tooltips desde configuration.ini
ReadTooltipConfig() {
    global ConfigIni
    
    config := {}
    
    ; Función helper para limpiar valores leídos (remover comentarios)
    CleanIniValue(value) {
        ; Remover comentarios (todo después de ;)
        if (InStr(value, ";")) {
            value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
        }
        return Trim(value)
    }
    
    ; Leer y limpiar valores
    enabledValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "enable_csharp_tooltips", "true"))
    config.enabled := enabledValue = "true"
    
    ; Whether tooltip layer should also handle input (hotkeys) instead of InputHook
    handleInputValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_handles_input", "false"))
    config.handleInput := handleInputValue = "true"
    
    optionsTimeoutValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "options_menu_timeout", "10000"))
    config.optionsTimeout := Integer(optionsTimeoutValue)
    
    statusTimeoutValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "status_notification_timeout", "2000"))
    config.statusTimeout := Integer(statusTimeoutValue)
    
    autoHideValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "auto_hide_on_action", "true"))
    config.autoHide := autoHideValue = "true"
    
    persistentValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "persistent_menus", "false"))
    config.persistent := persistentValue = "true"
    
    fadeAnimationValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_fade_animation", "true"))
    config.fadeAnimation := fadeAnimationValue = "true"
    
    clickThroughValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_click_through", "true"))
    config.clickThrough := clickThroughValue = "true"

    ; Ruta opcional del ejecutable TooltipApp
    exePathValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "tooltip_exe_path", ""))
    config.exePath := exePathValue
    
    ; Layout for option menus: grid (default) or list_vertical
   layoutValue := CleanIniValue(IniRead(ConfigIni, "Tooltips", "menu_layout", "grid"))
   config.menuLayout := StrLower(layoutValue)

    return config
}

; ===================================================================
; ESCRITURA ROBUSTA DEL JSON (ATÓMICA + THROTTLE)
; ===================================================================

; Ruta del archivo JSON principal (alineada a A_ScriptDir)
GetTooltipJsonPath() {
    return A_ScriptDir . "\tooltip_commands.json"
}

; Escritura atómica: escribe a .tmp y luego hace move para evitar lecturas parciales
WriteFileAtomic(path, content) {
    tmp := path . ".tmp"
    try {
        FileDelete(tmp)
    }
    FileAppend(content, tmp)
    ; Move con overwrite (1) para reemplazo seguro
    FileMove(tmp, path, 1)
}

; Estado para debounce de escritura
global tooltipJsonPending := ""
global tooltipDebounceMs := 100

ScheduleTooltipJsonWrite(json) {
    global tooltipJsonPending, tooltipDebounceMs
    tooltipJsonPending := json
    ; Reiniciar timer one-shot para consolidar múltiples escrituras
    SetTimer(DebouncedTooltipWrite, 0)
    SetTimer(DebouncedTooltipWrite, -tooltipDebounceMs)
}

DebouncedTooltipWrite() {
    global tooltipJsonPending
    if (tooltipJsonPending != "") {
        WriteFileAtomic(GetTooltipJsonPath(), tooltipJsonPending)
    }
}

; (JsonEscape helper defined later once)
; ===================================================================
; FUNCIONES PRINCIPALES DE TOOLTIP C#




; ===================================================================

; Función principal para mostrar tooltip C# (con timeout personalizado)
ShowCSharpTooltip(title, items, navigation := "", timeout := 0) {
    ; Decide layout based on configuration
    global tooltipConfig
    tooltipType := (tooltipConfig.menuLayout = "list_vertical") ? "bottom_right_list" : "leader"
    return ShowCSharpTooltipWithType(title, items, navigation, timeout, tooltipType)
}

; Tooltip tipo lista anclado abajo a la derecha (C#)
ShowBottomRightListTooltip(title, items, navigation := "", timeout := 0) {
    return ShowCSharpTooltipWithType(title, items, navigation, timeout, "bottom_right_list")
}

ShowCSharpTooltipWithType(title, items, navigation := "", timeout := 0, tooltipType := "leader") {
    global tooltipConfig
    ; Enforce layout from INI: if list_vertical is configured, always use bottom_right_list for menus
    if (tooltipConfig.menuLayout = "list_vertical" && tooltipType = "leader") {
        tooltipType := "bottom_right_list"
    }

    ; Ensure C# app is running before writing JSON (lazy start)
    StartTooltipApp()
    
    ; Si no se especifica timeout, usar el de opciones por defecto
    if (timeout = 0) {
        timeout := tooltipConfig.optionsTimeout
    }
    
    ; Si persistent_menus está habilitado, usar timeout muy largo
    if (tooltipConfig.persistent) {
        timeout := 300000  ; 5 minutos (prácticamente infinito)
    }

    ; Construir comando base usando helpers (incluye estilo/posición de INI)
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := title
    cmd["items"] := BuildItemObjects(items)
    navArr := BuildNavArray(navigation)
    if (navArr.Length)
        cmd["navigation"] := navArr
    cmd["timeout_ms"] := timeout

    ; Leer defaults de tema desde configuration.ini
    theme := ReadTooltipThemeDefaults()

    ; Aplicar layout/columns por defecto de tema
    if (theme.window.Has("layout"))
        cmd["layout"] := theme.window["layout"]
    if (theme.window.Has("columns") && theme.window["columns"] > 0)
        cmd["columns"] := theme.window["columns"]

    ; Si tooltipType implica lista, forzar layout=list
    if (tooltipType = "bottom_right_list")
        cmd["layout"] := "list"

    ; Copiar estilo y posición desde tema (si existen)
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position

    ; Flags de ventana desde tema
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]

    ; Compatibilidad: incluir tooltip_type explícito
    cmd["tooltip_type"] := tooltipType

    ; Serializar y escribir
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

; Función para ocultar tooltip C#
HideCSharpTooltip() {
    ; Resetear estado activo del menú
    global tooltipMenuActive, tooltipCurrentTitle
    tooltipMenuActive := false
    tooltipCurrentTitle := ""
    jsonData := '{"show": false}'
    ; Escribir JSON de forma atómica con debounce
    ScheduleTooltipJsonWrite(jsonData)
}

; Removed duplicate initial ShowCSharpOptionsMenu; stateful override defined later.

; Función específica para tooltips de ESTADO/NOTIFICACIONES (duración corta)
ShowCSharpStatusNotification(title, message) {
    global tooltipConfig
    items := "status:" . message
    ShowCSharpTooltip(title, items, "Esc: Close", tooltipConfig.statusTimeout)
}

; Función para iniciar la aplicación C# tooltip
IsAbsolutePath(p) {
    return RegExMatch(p, "i)^[A-Z]:\\|^\\\\|^/")
}

StartTooltipApp() {
    global tooltipConfig
    global tooltipConfig
    ; Verificar si ya está ejecutándose
    if (!ProcessExist("TooltipApp.exe")) {
        ; Intentar ejecutar desde diferentes ubicaciones
        if (tooltipConfig.exePath) {
            exePath := tooltipConfig.exePath
            if (!IsAbsolutePath(exePath))
                exePath := A_ScriptDir . "\\" . exePath
            if (FileExist(exePath))
                tooltipPaths := [ exePath ]
            else
                tooltipPaths := [
                    "tooltip_csharp\\bin\\Release\\net6.0-windows\\TooltipApp.exe",
                    A_ScriptDir . "\\TooltipApp.exe"
                ]
        } else {
            tooltipPaths := [
                A_ScriptDir . "\\tooltip_csharp\\TooltipApp.exe", ; Release path
                A_ScriptDir . "\\TooltipApp.exe", ; Custom/lightweight path
                "tooltip_csharp\\bin\\Release\\net6.0-windows\\TooltipApp.exe" ; Dev path
            ]
        }
        chosenPath := ""
        for index, path in tooltipPaths {
            if (FileExist(path)) {
                try {
                    Run('"' . path . '"', A_ScriptDir, "Hide")
                    chosenPath := path
                    Sleep(500)
                    break
                }
            }
        }
        ; Simple log para diagnosticar qué exe se lanzó
        try FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") . " Launched: " . (chosenPath != "" ? chosenPath : "<none>") . "\n", A_ScriptDir . "\\tooltip_launch.log")
    }
    return true
}

; Función separada para iniciar todas las aplicaciones de estado

; ===================================================================
; INTERACTIVE MENU HANDLING (GENERIC KEY DISPATCH)
; ===================================================================

; Global state for menu interaction
global tooltipMenuActive := false
global tooltipCurrentTitle := ""

; Breadcrumb navigation stack for intelligent back
global tooltipNavStack := []

TooltipNavReset() {
    global tooltipNavStack
    tooltipNavStack := []
}

TooltipNavTop() {
    global tooltipNavStack
    return tooltipNavStack.Length ? tooltipNavStack[tooltipNavStack.Length] : ""
}

TooltipNavPush(menuId) {
    global tooltipNavStack
    if (!tooltipNavStack.Length || tooltipNavStack[tooltipNavStack.Length] != menuId) {
        tooltipNavStack.Push(menuId)
    }
}

TooltipShowById(menuId) {
    switch menuId {
        case "LEADER": ShowLeaderModeMenuCS()
        case "PROGRAMS": ShowProgramMenuCS()
        case "WINDOWS": ShowWindowMenuCS()
        case "TIMESTAMPS": ShowTimeMenuCS()
        case "INFORMATION": ShowInformationMenuCS()
        case "COMMANDS": ShowCommandsMenuCS()
        case "CMD_s": ShowSystemCommandsMenuCS()
        case "CMD_n": ShowNetworkCommandsMenuCS()
        case "CMD_g": ShowGitCommandsMenuCS()
        case "CMD_m": ShowMonitoringCommandsMenuCS()
        case "CMD_f": ShowFolderCommandsMenuCS()
        case "CMD_o": ShowPowerOptionsCommandsMenuCS()
        case "CMD_a": ShowADBCommandsMenuCS()
        case "CMD_v": ShowVaultFlowCommandsMenuCS()
        case "CMD_h": ShowHybridManagementMenuCS()
        default:
            ; fallback to leader
            ShowLeaderModeMenuCS()
    }
}

TooltipNavBackCS() {
    global tooltipNavStack
    if (tooltipNavStack.Length > 1) {
        tooltipNavStack.Pop() ; remove current
        prev := tooltipNavStack[tooltipNavStack.Length]
        TooltipShowById(prev)
    } else {
        ; nothing to go back to, show leader for consistency
        ShowLeaderModeMenuCS()
    }
}

TooltipMenuIsActive() {
    global tooltipMenuActive
    return tooltipMenuActive
}

; Central dispatcher for option selection
HandleTooltipSelection(key) {
    global tooltipMenuActive, tooltipCurrentTitle

    ; Debug
    OutputDebug("[TOOLTIP] Selection - title=" tooltipCurrentTitle " key=" key "`n")

    if (key = "ESC") {
        HideCSharpTooltip()
        tooltipMenuActive := false
        return
    }

    if (tooltipCurrentTitle = "COMMAND PALETTE") {
        switch key {
            case "\\":
                TooltipNavBackCS()
                return
            case "s":
                ShowSystemCommandsMenuCS()
            case "n":
                ShowNetworkCommandsMenuCS()
            case "g":
                ShowGitCommandsMenuCS()
            case "m":
                ShowMonitoringCommandsMenuCS()
            case "f":
                ShowFolderCommandsMenuCS()
            case "o":
                ShowPowerOptionsCommandsMenuCS()
            case "a":
                ShowADBCommandsMenuCS()
            case "v":
                ShowVaultFlowCommandsMenuCS()
            default:
                OutputDebug("[TOOLTIP] Unknown key in COMMAND PALETTE: " key "`n")
        }
        return
    }

    if (tooltipCurrentTitle = "LEADER MODE") {
        switch key {
            case "\\":
                HideCSharpTooltip()
                tooltipMenuActive := false
                return
            case "h":
                ShowHybridManagementMenuCS()
            default:
                OutputDebug("[TOOLTIP] Unknown key in LEADER MODE: " key "`n")
        }
        return
    }

    ; Other menus can be handled here similarly, based on tooltipCurrentTitle
}

; Ensure ShowCSharpOptionsMenu marks menu as active and remembers title
; (we hook by wrapping ShowCSharpOptionsMenu via a helper)
Original_ShowCSharpOptionsMenu(title, items, navigation := "", timeout := 0) {
    if (timeout = 0) {
        timeout := tooltipConfig.optionsTimeout
    }
    global tooltipConfig
    ; Force layout decision here as well, so every options menu respects INI layout
    tooltipType := (tooltipConfig.menuLayout = "list_vertical") ? "bottom_right_list" : "leader"
    ShowCSharpTooltipWithType(title, items, navigation, timeout, tooltipType)
}

; Override previous function name to set state then call original
ShowCSharpOptionsMenu(title, items, navigation := "", timeout := 0) {
    global tooltipMenuActive, tooltipCurrentTitle
    tooltipMenuActive := true
    tooltipCurrentTitle := title
    Original_ShowCSharpOptionsMenu(title, items, navigation, timeout)
}

; Context helpers for scoping hotkeys
TooltipInLeaderMenu() {
    global tooltipMenuActive, tooltipCurrentTitle, tooltipConfig
    return tooltipMenuActive && tooltipConfig.handleInput && (tooltipCurrentTitle = "LEADER MODE")
}
TooltipInCommandsMenu() {
    global tooltipMenuActive, tooltipCurrentTitle, tooltipConfig
    return tooltipMenuActive && tooltipConfig.handleInput && (tooltipCurrentTitle = "COMMAND PALETTE")
}

; Leader menu hotkeys (only on LEADER MODE)
#HotIf TooltipInLeaderMenu()
p::HandleTooltipSelection("p")
t::HandleTooltipSelection("t")
c::HandleTooltipSelection("c")

i::HandleTooltipSelection("i")
n::HandleTooltipSelection("n")
h::HandleTooltipSelection("h")
\::HandleTooltipSelection("\\")
Esc::HandleTooltipSelection("ESC")
#HotIf

; Commands palette hotkeys (only on COMMAND PALETTE)
#HotIf TooltipInCommandsMenu()
s::HandleTooltipSelection("s")
n::HandleTooltipSelection("n")
g::HandleTooltipSelection("g")
m::HandleTooltipSelection("m")
f::HandleTooltipSelection("f")
w::HandleTooltipSelection("w")
o::HandleTooltipSelection("o")
a::HandleTooltipSelection("a")
v::HandleTooltipSelection("v")
\::HandleTooltipSelection("\\")
Esc::HandleTooltipSelection("ESC")
#HotIf

; ===================================================================
; REEMPLAZOS DE FUNCIONES EXISTENTES
; ===================================================================

; Reemplazar ShowLeaderModeMenu() original
ShowLeaderModeMenuCS() {
    TooltipNavReset()
    TooltipNavPush("LEADER")
    items := "p:Programs|t:Timestamps|c:Commands|i:Information|w:Windows|n:Excel layer|s:Scroll layer|h:Hybrid Management"
    ShowCSharpOptionsMenu("LEADER MODE", items, "ESC: Exit")
}

; Reemplazar ShowProgramMenu() original  
ShowProgramMenuCS() {
    TooltipNavPush("PROGRAMS")
    items := GenerateProgramItemsForCS()
    ShowCSharpOptionsMenu("PROGRAM LAUNCHER", items, "BACKSPACE: Back|ESC: Exit")
}

; Generate program items for C# tooltips from ProgramMapping order
GenerateProgramItemsForCS() {
    global ProgramsIni
    items := ""
    
    ; Read order from ProgramMapping
    orderStr := IniRead(ProgramsIni, "ProgramMapping", "order", "")
    if (orderStr = "" || orderStr = "ERROR") {
        ; Fallback order
        orderStr := "e i t v n o b z m w l r q p k f"
    }
    
    ; Split order into individual keys
    keys := StrSplit(orderStr, " ")
    
    ; Process keys and build items string
    Loop keys.Length {
        key := Trim(keys[A_Index])
        if (key = "")
            continue
            
        ; Get program name for this key
        programName := IniRead(ProgramsIni, "ProgramMapping", key, "")
        if (programName = "" || programName = "ERROR")
            continue
            
        ; Add to items string
        if (items != "")
            items .= "|"
        items .= key . ":" . programName
    }
    
    ; Fallback if no configuration found
    if (items == "") {
        items := "e:Explorer|i:Settings|t:Terminal|v:VisualStudio|n:Notepad|b:Vivaldi|z:Zen"
    }
    
    return items
}

; Reemplazar ShowWindowMenu() original
ShowWindowMenuCS() {
    TooltipNavPush("WINDOWS")
    items := "2:Split 50/50|3:Split 33/67|4:Quarter Split|x:Close|m:Maximize|-:Minimize|d:Draw|z:Zoom|c:Zoom with cursor|j:Next Window|k:Previous Window"
    ShowCSharpOptionsMenu("WINDOW MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowTimeMenu() original
ShowTimeMenuCS() {
    TooltipNavPush("TIMESTAMPS")
    items := "d:Date Formats|t:Time Formats|h:Date+Time Formats"
    ShowCSharpOptionsMenu("TIMESTAMP MANAGER", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowInformationMenu() original
ShowInformationMenuCS() {
    TooltipNavPush("INFORMATION")
    items := GenerateInformationItemsForCS()
    ShowCSharpOptionsMenu("INFORMATION MANAGER", items, "\\: Back|ESC: Exit")
}

; Generate information items for C# tooltips from InfoMapping order
GenerateInformationItemsForCS() {
    global InfoIni
    items := ""
    
    ; Read order from InfoMapping
    orderStr := IniRead(InfoIni, "InfoMapping", "order", "")
    if (orderStr = "" || orderStr = "ERROR") {
        ; Fallback order
        orderStr := "e n p a c w g l r"
    }
    
    ; Split order into individual keys
    keys := StrSplit(orderStr, " ")
    
    ; Process keys and build items string
    Loop keys.Length {
        key := Trim(keys[A_Index])
        if (key = "")
            continue
            
        ; Get information name for this key
        infoName := IniRead(InfoIni, "InfoMapping", key, "")
        if (infoName = "" || infoName = "ERROR")
            continue
            
        ; Add to items string
        if (items != "")
            items .= "|"
        items .= key . ":" . infoName
    }
    
    ; Fallback if no configuration found
    if (items == "") {
        items := "e:Email|n:Name|p:Phone|a:Address|c:Company|w:Website|g:GitHub|l:LinkedIn"
    }
    
    return items
}

; Reemplazar ShowCommandsMenu() original
ShowCommandsMenuCS() {
    TooltipNavPush("COMMANDS")
    
    ; Generar items desde CategoryRegistry (DINÁMICO)
    items := BuildMainMenuItemsFromRegistry()
    
    ; Fallback solo si el registry está vacío
    if (items = "") {
        items := "[No categories registered]"
    }
    
    ShowCSharpOptionsMenu("COMMAND PALETTE", items, "\\: Back|ESC: Exit")
}

; Helper: Generar items para menú principal desde CategoryRegistry
BuildMainMenuItemsFromRegistry() {
    categories := GetSortedCategories()
    
    if (categories.Length = 0)
        return ""
    
    items := ""
    for cat in categories {
        if (items != "")
            items .= "|"
        items .= cat["symbol"] . ":" . cat["title"]
    }
    
    return items
}

; ===================================================================
; SUBMENÚS DE TIMESTAMP CON C#
; ===================================================================

; Reemplazar ShowDateFormatsMenu() original
ShowDateFormatsMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde timestamps.ini
    Loop 10 {
        lineContent := IniRead(TimestampsIni, "MenuDisplay", "date_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una letra o número
                    if (StrLen(key) <= 2 && RegExMatch(key, "^[a-z0-9]+$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "d:Default|1:yyyy-MM-dd|2:dd/MM/yyyy|3:MM/dd/yyyy|4:dd-MMM-yyyy|5:ddd, dd MMM yyyy|6:yyyyMMdd"
    }
    
    ShowCSharpOptionsMenu("DATE FORMATS", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowTimeFormatsMenu() original
ShowTimeFormatsMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde timestamps.ini
    Loop 10 {
        lineContent := IniRead(TimestampsIni, "MenuDisplay", "time_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una letra o número
                    if (StrLen(key) <= 2 && RegExMatch(key, "^[a-z0-9]+$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "t:Default|1:HH:mm:ss|2:HH:mm|3:hh:mm tt|4:HHmmss|5:HH.mm.ss"
    }
    
    ShowCSharpOptionsMenu("TIME FORMATS", items, "\\: Back|ESC: Exit")
}

; Reemplazar ShowDateTimeFormatsMenu() original
ShowDateTimeFormatsMenuCS() {
    items := ""
    
    ; Leer configuración dinámica desde timestamps.ini
    Loop 10 {
        lineContent := IniRead(TimestampsIni, "MenuDisplay", "datetime_line" . A_Index, "")
        if (lineContent != "" && lineContent != "ERROR") {
            ; Método simple: dividir por múltiples espacios y procesar cada parte
            cleanLine := RegExReplace(lineContent, "\s{3,}", "|||")
            parts := StrSplit(cleanLine, "|||")
            
            ; Procesar cada parte
            for index, part in parts {
                part := Trim(part)
                if (part != "" && InStr(part, " - ")) {
                    ; Extraer key y descripción
                    dashPos := InStr(part, " - ")
                    key := Trim(SubStr(part, 1, dashPos - 1))
                    desc := Trim(SubStr(part, dashPos + 3))
                    
                    ; Validar que la key sea una letra o número
                    if (StrLen(key) <= 2 && RegExMatch(key, "^[a-z0-9]+$")) {
                        if (items != "")
                            items .= "|"
                        items .= key . ":" . desc
                    }
                }
            }
        }
    }
    
    ; Fallback si no hay configuración
    if (items == "") {
        items := "h:Default|1:yyyy-MM-dd HH:mm:ss|2:dd/MM/yyyy HH:mm|3:yyyy-MM-dd HH:mm:ss|4:yyyyMMddHHmmss|5:ddd, dd MMM yyyy HH:mm"
    }
    
    ShowCSharpOptionsMenu("DATE+TIME FORMATS", items, "\\: Back|ESC: Exit")
}

; ===================================================================
; FUNCIONES DE NOTIFICACIÓN MEJORADAS (TEMPORALES)
; ===================================================================

; Reemplazar ShowCenteredToolTip() con versión C#
ShowCenteredToolTipCS(text, duration := 0) {
    ; Usar duración de configuración si no se especifica
    if (duration = 0) {
        ShowCSharpStatusNotification("STATUS", text)
    } else {
        items := "info:" . text
        ShowCSharpTooltip("STATUS", items, "", duration)
    }
}

; Notificaciones específicas mejoradas
ShowCopyNotificationCS() {
    ; Bottom-right, navigation-less clipboard status with short timeout
    ; Additionally, if a persistent layer (NVIM/Visual/Excel) is active, restore it after the toast ends
    global ConfigIni
    global isNvimLayerActive, VisualMode, excelLayerActive

    to := CleanIniValue(IniRead(ConfigIni, "Tooltips", "status_notification_timeout", ""))
    if (to = "" || to = "ERROR") {
        to := 1200
    } else {
        to := Integer(Trim(to))
        if (to > 1200)
            to := 1200
        if (to < 400)
            to := 400
    }

    ; Build command directly to avoid any default navigation injection
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "CLIPBOARD"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := to

    items := []
    it := Map()
    it["key"] := "<"
    it["description"] := "COPIED"
    items.Push(it)
    cmd["items"] := items

    ; Apply theme styling and position
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]

    StartTooltipApp()
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)

    ; Determine which persistent to restore (if any), then schedule it after the toast
    active := ""
    if (IsSet(isNvimLayerActive) && isNvimLayerActive) {
        if (IsSet(VisualMode) && VisualMode)
            active := "visual"
        else
            active := "nvim"
    } else if (IsSet(excelLayerActive) && excelLayerActive) {
        active := "excel"
    }
    if (active != "") {
        delay := to + 120
        SetTimer(() => RestorePersistentAfterCopy(active), -delay)
    }
}

RestorePersistentAfterCopy(which) {
    try {
        switch which {
            case "visual":
                ShowVisualLayerToggleCS(true)
            case "nvim":
                ShowNvimLayerToggleCS(true)
            case "excel":
                ShowExcelLayerToggleCS(true)
        }
    } catch {
    }
}

; Short, navigation-less status tooltip for CapsLock toggle
ShowCapsLockStatusCS(stateText) {
    ; Build a tooltip like NVIM/Excel style: title, single item, no navigation
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "CapsLock"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    ; Use configured status timeout if present, otherwise 1200ms
    to := CleanIniValue(IniRead(ConfigIni, "Tooltips", "status_notification_timeout", ""))
    if (to = "" || to = "ERROR")
        to := 1200
    else
        to := Integer(Trim(to))
    cmd["timeout_ms"] := to

    items := []
    it := Map()
    it["key"] := "<"
    it["description"] := stateText
    items.Push(it)
    cmd["items"] := items

    ; Apply theme styling and position
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]

    ; Intentionally omit navigation to avoid Back/Exit hints
    StartTooltipApp()
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}


ShowExcelLayerToggleCS(isActive) {
    ; Ensure previous tooltip is hidden to avoid overlap
    try HideCSharpTooltip()
    Sleep 30
    ; Ensure app is running; proceed even if process check lags to avoid recursion
    StartTooltipApp()
    if (!isActive) {
        try HideCSharpTooltip()
        return
    }
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Excel"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := 0 ; persistent while excel is active
    ; Single item hint
    items := []
    it := Map()
    it["key"] := "?"
    it["description"] := "help"
    items.Push(it)
    cmd["items"] := items
    ; Apply theme
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

ShowProcessTerminatedCS() {
    ShowCSharpStatusNotification("SYSTEM", "PROCESS TERMINATED")
}

ShowCommandExecutedCS(category, command) {
    ShowCSharpStatusNotification("COMMAND EXECUTED", category . " command executed: " . command)
}

; ===================================================================
; FUNCIONES ESPECÍFICAS PARA NVIM/ VISUAL/ EXCEL/ SCROLL HELP

ShowNvimHelpCS() {
    global tooltipConfig
    items := "h:Move left|j:Move down|k:Move up|l:Move right|v:Visual Mode|y:Copy|p:Paste|u:Undo|x:Cut|i:Insert |I:Insert+|w:Word right|b:Word left|e:End of word|r:Redo|C-u:Scroll up 6|C-d:Scroll down 6|0:Line start|$:Line end|gg:First Line|G:Bottom Line|f:Find|::Cmd (w/q/wq)"
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    if (to < 8000)
        to := 8000
    ShowBottomRightListTooltip("NVIM HELP", items, "?: Close", to)
}

ShowVisualHelpCS() {
    global tooltipConfig
    ; Visual mode specific help
    items := "h:Extend left|j:Extend down|k:Extend up|l:Extend right|w:Extend word right|b:Extend word left|0:Extend to line start|$:Extend to line end|y:Copy selection|d:Delete selection|a:Select all|c:Change -> Insert|Esc:Exit Visual"
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    if (to < 8000)
        to := 8000
    ShowBottomRightListTooltip("VISUAL HELP", items, "?: Close", to)
}

; ===================================================================
; FUNCIONES ESPECÍFICAS PARA NVIM LAYER OPTIONS

; Build NVIM items for status from config/nvim_layer.ini [Normal]
BuildNvimStatusItems() {
    ini := A_ScriptDir . "\\config\\nvim_layer.ini"
    items := []
    try {
        order := IniRead(ini, "Normal", "order", "")
        if (order = "" || order = "ERROR")
            return items
        keys := StrSplit(order, " ")
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            spec := IniRead(ini, "Normal", k, "")
            if (spec = "" || spec = "ERROR")
                continue
            desc := NvimSpecToDescription(spec)
            itm := Map()
            itm["key"] := k
            itm["description"] := desc
            items.Push(itm)
        }
    } catch {
    }
    return items
}

NvimSpecToDescription(spec) {
    spec := Trim(spec)
    if (InStr(spec, ":")) {
        t := StrLower(Trim(SubStr(spec, 1, InStr(spec, ":") - 1)))
        v := Trim(SubStr(spec, InStr(spec, ":") + 1))
        if (t = "send") {
            ; Simple mapping for arrows and common combos
            if (RegExMatch(v, "\{Left\}", &m))
                return "Move left"
            if (RegExMatch(v, "\{Right\}", &m))
                return "Move right"
            if (RegExMatch(v, "\{Up\}", &m))
                return "Move up"
            if (RegExMatch(v, "\{Down\}", &m))
                return "Move down"
            if (InStr(v, "^v"))
                return "Paste"
            return "Send " . v
        } else if (t = "showmenu") {
            v := StrLower(v)
            if (v = "yank")
                return "Yank menu"
            if (v = "delete")
                return "Delete menu"
            return "Menu " . v
        } else if (t = "func") {
            return "Function: " . v
        }
        return t ": " v
    }
    return spec
}

ShowNvimLayerToggleCS(isActive) {
    ; Ensure app is running; if not, fallback to native tooltip
    StartTooltipApp()
    if (!ProcessExist("TooltipApp.exe")) {
        try ShowNvimLayerStatus(isActive)
        return
    }
    ; If turning OFF, simply hide the tooltip and exit (no OFF tooltip)
    if (!isActive) {
        try HideCSharpTooltip()
        return
    }
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Nvim"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    ; Read status timeout from config (string), then coerce to number safely
    ; Persist while ON (timeout 0). Use configured/short timeout when OFF.
    if (isActive) {
        statusMs := 0
    } else {
        statusMs := CleanIniValue(IniRead(ConfigIni, "Tooltips", "status_notification_timeout", ""))
        if (statusMs = "" || statusMs = "ERROR")
            statusMs := 2000
        else
            statusMs := Integer(Trim(statusMs))
    }
    cmd["timeout_ms"] := statusMs

    ; Single item: when ON show help hint, when OFF show OFF
    items := []
    it := Map()
    if (isActive) {
        it["key"] := "?"
        it["description"] := "help"
    } else {
        it["key"] := ""
        it["description"] := "OFF"
    }
    items.Push(it)
    cmd["items"] := items

    ; Apply theme and accent by state
    if (theme.style.Count) {
        style := theme.style
        if (isActive && style.Has("success"))
            style["accent_options"] := style["success"]
        else if (!isActive && style.Has("error"))
            style["accent_options"] := style["error"]
        cmd["style"] := style
    }
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]

    ; NVIM layer tooltip is not navigable; omit navigation entirely
    StartTooltipApp()
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}
; ===================================================================


; Excel Help
ShowExcelHelpCS() {
    global tooltipConfig
    ; Excel layer help with all current mappings
    items := "1:Numpad1|2:Numpad2|3:Numpad3|q:Numpad4|w:Numpad5|e:Numpad6|a:Numpad7|s:Numpad8|d:Numpad9|x:Numpad0|,:Comma|.:NumpadDot|8:Multiply (*)|9:Parentheses ()|;:NumpadSub|/:NumpadDiv|h:Left|j:Down|k:Up|l:Right|[:Prev Tab|]:Next Tab|i:Edit (F2)|I:Edit & Exit|f:Find|u:Undo|r:Redo|g:Go to top|G:Go to bottom|m:Go to cell|y:Copy|p:Paste|o:Enter|O:Shift+Enter|vr:Select row|vc:Select column|vv:Visual mode|N:Exit Excel layer"
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    if (to < 8000)
        to := 8000
    ShowBottomRightListTooltip("EXCEL HELP", items, "?: Close", to)
}

; Excel VV Mode Toggle (Visual Selection)
ShowExcelVVModeToggleCS(isActive) {
    ; Ensure app is running
    StartTooltipApp()
    if (!ProcessExist("TooltipApp.exe")) {
        ; Fallback to native tooltip
        ToolTip(isActive ? "◉ VISUAL (EXCEL)" : "○ VISUAL (EXCEL)")
        SetTimer(() => ToolTip(), -900)
        return
    }
    if (!isActive) {
        ; When exiting VV mode, restore Excel layer tooltip
        try ShowExcelLayerToggleCS(true)
        return
    }
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Visual (Excel)"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := 0 ; persistent while VV mode is active
    
    ; Show help hint
    items := []
    it := Map()
    it["key"] := "?"
    it["description"] := "help"
    items.Push(it)
    cmd["items"] := items
    
    ; Apply theme with visual accent
    if (theme.style.Count) {
        style := theme.style
        if (style.Has("warning"))
            style["accent_options"] := style["warning"]
        cmd["style"] := style
    }
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]
    
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

; Excel VV Mode Help
ShowExcelVVHelpCS() {
    global tooltipConfig
    items := "h:Select left|j:Select down|k:Select up|l:Select right|y:Copy & exit|d:Delete & exit|p:Paste & exit|Esc:Exit Visual mode"
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    if (to < 8000)
        to := 8000
    ShowBottomRightListTooltip("VISUAL (EXCEL) HELP", items, "?: Close", to)
}

; Menú de opciones Visual (v)
ShowVisualLayerToggleCS(isActive) {
    ; Ensure app is running; if not, fallback to native tooltip
    StartTooltipApp()
    if (!ProcessExist("TooltipApp.exe")) {
        try ShowVisualModeStatus(isActive)
        return
    }
    if (!isActive) {
        try HideCSharpTooltip()
        return
    }
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Visual"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := 0 ; persistent while visual is active
    ; Single item hint
    items := []
    it := Map()
    it["key"] := "?"
    it["description"] := "help"
    items.Push(it)
    cmd["items"] := items
    ; Apply theme
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

ShowVisualMenuCS() {
    items := "v:Visual Mode|l:Visual Line|b:Visual Block"
    ShowCSharpOptionsMenu("VISUAL MODE", items, "ESC: Cancel")
}

; Menú de opciones Insert (i)
ShowInsertMenuCS() {
    items := "i:Insert Mode|a:Insert After|o:Insert New Line"
    ShowCSharpOptionsMenu("INSERT MODE", items, "ESC: Cancel")
}

; Menú de opciones Replace (r)
ShowReplaceMenuCS() {
    items := "r:Replace Character|R:Replace Mode|s:Substitute"
    ShowCSharpOptionsMenu("REPLACE OPTIONS", items, "ESC: Cancel")
}

; Menú de opciones Yank (y) - Actualizado para mostrar opciones
ShowYankMenuCS() {
    items := "y:Yank Line|w:Yank Word|a:Yank All|p:Yank Paragraph"
    ShowCSharpOptionsMenu("YANK OPTIONS", items, "ESC: Cancel")
}

; Menú de opciones Delete (d) - Actualizado para mostrar opciones  
ShowDeleteMenuCS() {
    items := "d:Delete Line|w:Delete Word|a:Delete All"
    ShowCSharpOptionsMenu("DELETE OPTIONS", items, "ESC: Cancel")
}

; ===================================================================
; FUNCIONES ESPECÍFICAS PARA SUBMENÚS DE COMANDOS
; ===================================================================

; Submenú System Commands (leader → c → s)
ShowSystemCommandsMenuCS() {
    TooltipNavPush("CMD_s")
    items := GenerateCategoryItems("system")
    if (items = "") {
        MsgBox("ERROR: System commands not registered. Check RegisterSystemKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("SYSTEM COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Network Commands (leader → c → n)
ShowNetworkCommandsMenuCS() {
    TooltipNavPush("CMD_n")
    items := GenerateCategoryItems("network")
    if (items = "") {
        MsgBox("ERROR: Network commands not registered. Check RegisterNetworkKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("NETWORK COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Git Commands (leader → c → g)
ShowGitCommandsMenuCS() {
    TooltipNavPush("CMD_g")
    items := GenerateCategoryItems("git")
    if (items = "") {
        MsgBox("ERROR: Git commands not registered. Check RegisterGitKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("GIT COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Monitoring Commands (leader → c → m)
ShowMonitoringCommandsMenuCS() {
    TooltipNavPush("CMD_m")
    items := GenerateCategoryItems("monitoring")
    if (items = "") {
        MsgBox("ERROR: Monitoring commands not registered. Check RegisterMonitoringKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("MONITORING COMMANDS", items, "\\: Back|ESC: Exit")
}

; Submenú Folder Commands (leader → c → f)
ShowFolderCommandsMenuCS() {
    TooltipNavPush("CMD_f")
    items := GenerateCategoryItems("folder")
    if (items = "") {
        MsgBox("ERROR: Folder commands not registered. Check RegisterFolderKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("FOLDER ACCESS", items, "\\: Back|ESC: Exit")
}

; Submenú Power Options (leader → c → o)
ShowPowerOptionsCommandsMenuCS() {
    TooltipNavPush("CMD_o")
    items := GenerateCategoryItems("power")
    if (items = "") {
        MsgBox("ERROR: Power commands not registered. Check RegisterPowerKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("POWER OPTIONS", items, "\\: Back|ESC: Exit")
}

; Submenú ADB Tools (leader → c → a)
ShowADBCommandsMenuCS() {
    TooltipNavPush("CMD_a")
    items := GenerateCategoryItems("adb")
    if (items = "") {
        MsgBox("ERROR: ADB commands not registered. Check RegisterADBKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("ADB TOOLS", items, "\\: Back|ESC: Exit")
}

; Submenú Hybrid Management (leader → h)
ShowHybridManagementMenuCS() {
    TooltipNavPush("HYBRID")
    items := GenerateCategoryItemsForPath("leader.h")
    if (items = "") {
        MsgBox("ERROR: Hybrid commands not registered. Check RegisterHybridKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("HYBRID MANAGEMENT", items, "\\: Back|ESC: Exit")
}

; Submenú VaultFlow Commands (leader → c → v)
ShowVaultFlowCommandsMenuCS() {
    TooltipNavPush("CMD_v")
    items := GenerateCategoryItems("vaultflow")
    if (items = "") {
        MsgBox("ERROR: VaultFlow commands not registered. Check RegisterVaultFlowKeymaps() in startup.", "Keymap Registry Error", "Icon!")
        return
    }
    ShowCSharpOptionsMenu("VAULTFLOW COMMANDS", items, "\\: Back|ESC: Exit")
}

; ===================================================================
; FUNCIÓN DE LIMPIEZA
; ===================================================================

; Función para cerrar las aplicaciones C#
StopTooltipApp() {
    try {
        ProcessClose("TooltipApp.exe")
    }
    ; Cerrar todos los PowerShell que ejecutan StatusWindow
    statusTypes := ["Nvim", "Visual", "Yank", "Excel"]
    for index, statusType in statusTypes {
        try {
            RunWait("powershell.exe -Command `"Get-Process | Where-Object {`$_.ProcessName -eq 'powershell' -and `$_.CommandLine -like '*StatusWindow_" . statusType . "*'} | Stop-Process -Force`"", , "Hide")
        }
    }
    ; Limpiar archivos JSON
    try {
        FileDelete(GetTooltipJsonPath())
        FileDelete(A_ScriptDir . "\\status_nvim_commands.json")
        FileDelete(A_ScriptDir . "\\status_visual_commands.json")
        FileDelete(A_ScriptDir . "\\status_yank_commands.json")
        FileDelete(A_ScriptDir . "\\status_excel_commands.json")
    }
}

; ===================================================================
; API AVANZADA: TEMA, MERGE Y SERIALIZACIÓN JSON
; ===================================================================

; Leer tema por defecto desde configuration.ini (opcional)
ReadTooltipThemeDefaults() {
    global ConfigIni
    global ConfigIni
    defaults := Map()
    ; Layout/ventana
    defaults.window := Map()
    defaults.window["layout"] := StrLower(IniRead(ConfigIni, "TooltipWindow", "layout", ""))
    defaults.window["columns"] := Integer(IniRead(ConfigIni, "TooltipWindow", "columns", "0"))
    tw_topmost := StrLower(IniRead(ConfigIni, "TooltipWindow", "topmost", ""))
    if (tw_topmost != "")
        defaults.window["topmost"] := (tw_topmost = "true")
    tw_click := StrLower(IniRead(ConfigIni, "TooltipWindow", "click_through", ""))
    if (tw_click != "")
        defaults.window["click_through"] := (tw_click = "true")
    tw_opacity := IniRead(ConfigIni, "TooltipWindow", "opacity", "")
    if (tw_opacity != "" && tw_opacity != "ERROR")
        defaults.window["opacity"] := Number(tw_opacity)

    ; Style
    defaults.style := Map()
    for key in ["background","text","border","accent_options","accent_navigation","navigation_text","success","error"] {
        val := IniRead(ConfigIni, "TooltipStyle", key, "")
        if (val != "" && val != "ERROR")
            defaults.style[key] := val
    }
    for key in ["border_thickness","corner_radius","title_font_size","item_font_size","navigation_font_size","max_width","max_height"] {
        val := IniRead(ConfigIni, "TooltipStyle", key, "")
        if (val != "" && val != "ERROR")
            defaults.style[key] := Number(val)
    }
    pad := IniRead(ConfigIni, "TooltipStyle", "padding", "") ; formato: L,T,R,B
    if (pad != "" && pad != "ERROR") {
        parts := StrSplit(pad, [","," ","`t"]) 
        if (parts.Length >= 4) {
            defaults.style.padding := [Number(parts[1]), Number(parts[2]), Number(parts[3]), Number(parts[4])]
        }
    }

    ; Position
    defaults.position := Map()
    anc := IniRead(ConfigIni, "TooltipPosition", "anchor", "")
    if (anc != "" && anc != "ERROR")
        defaults.position["anchor"] := StrLower(anc)
    for key in ["offset_x","offset_y","x","y"] {
        val := IniRead(ConfigIni, "TooltipPosition", key, "")
        if (val != "" && val != "ERROR")
            defaults.position[key] := Number(val)
    }

    ; Navigation label override (optional) from style section
    navLbl := IniRead(ConfigIni, "TooltipStyle", "navigation_label", "")
    if (navLbl != "" && navLbl != "ERROR")
        defaults["navigation_label"] := navLbl
    return defaults
}

; Deep merge de objetos (Map/Array simple). opts sobre escribe defaults
DeepMerge(base, override) {
    if (!IsObject(base))
        return override
    if (!IsObject(override))
        return base
    for k, v in override {
        if (IsObject(v) && base.Has(k) && IsObject(base[k])) {
            base[k] := DeepMerge(base[k], v)
        } else {
            base[k] := v
        }
    }
    return base
}

; Detectar si un objeto es array secuencial 1..n
IsSequentialArray(o) {
    if (!IsObject(o))
        return false
    try {
        idx := 1
        for k, _ in o {
            if (k != idx)
                return false
            idx++
        }
        return (idx > 1)
    } catch {
        return false
    }
}

JsonEscape(s) {
    s := StrReplace(s, "\\", "\\\\")
    s := StrReplace(s, '"', '\\"')
    s := StrReplace(s, "\r", "\\r")
    s := StrReplace(s, "\n", "\\n")
    s := StrReplace(s, "\t", "\\t")
    return s
}

; Serializar a JSON (strings, números, arrays, maps). Booleans: claves conocidas emiten true/false.
SerializeJson(val, parentKey := "") {
    if (!IsObject(val)) {
        if (Type(val) = "String")
            return '"' . JsonEscape(val) . '"'
        if (Type(val) = "Integer" || Type(val) = "Float") {
            ; Si es valor 0/1 para claves booleanas, emitir true/false sin comillas
            if (parentKey != "" && (parentKey = "show" || parentKey = "topmost" || parentKey = "click_through"))
                return (val ? "true" : "false")
            return val
        }
        return '"' . JsonEscape(val) . '"'
    }
    if (IsSequentialArray(val)) {
        buf := "["
        first := true
        for _, v in val {
            if (!first)
                buf .= ","
            first := false
            buf .= SerializeJson(v)
        }
        buf .= "]"
        return buf
    } else {
        buf := "{"
        first := true
        try {
            for k, v in val {
                if (!first)
                    buf .= ","
                first := false
                buf .= '"' . JsonEscape(k) . '":' . SerializeJson(v, k)
            }
        } catch {
            ; Fallback para objetos no enumerables
            buf := "{}"
        }
        if (buf != "{}")
            buf .= "}"
        return buf
    }
}
; Construir item objects desde string items "k:desc|..."
BuildItemObjects(itemsStr) {
    arr := []
    if (itemsStr = "" || !IsSet(itemsStr))
        return arr
    parts := StrSplit(itemsStr, "|")
    for _, p in parts {
        seg := StrSplit(p, ":")
        if (seg.Length >= 2) {
            itm := Map()
            itm["key"] := seg[1]
            itm["description"] := seg[2]
            arr.Push(itm)
        }
    }
    return arr
}

; Construir nav array desde string "a|b|c"
BuildNavArray(navStr) {
    arr := []
    theme := ReadTooltipThemeDefaults()

    if (!IsSet(navStr) || navStr = "") {
        if (theme.Has("navigation_label"))
            navStr := theme["navigation_label"]
        else
            return arr
    }

    themeParts := []
    if (theme.Has("navigation_label"))
        themeParts := StrSplit(theme["navigation_label"], "|")

    parts := StrSplit(navStr, "|")
    for _, p in parts {
        ; Compatibilidad: reemplazar tokens antiguos por los del tema si están definidos
        if (p = "\\: Back" && themeParts.Length >= 1)
            p := Trim(themeParts[1])
        else if ((p = "ESC: Exit" || p = "Esc: Exit") && themeParts.Length >= 2)
            p := Trim(themeParts[2])
        arr.Push(p)
    }
    return arr
}

; Construir items de bienvenida con estado de capas y colores success/error
ShowWelcomeStatusCS() {
    global tooltipConfig
    theme := ReadTooltipThemeDefaults()

    ; Build single-line version item matching leader scheme, no navigation
    ver := CleanIniValue(IniRead(ConfigIni, "General", "script_version", ""))
    desc := (ver != "" && ver != "ERROR") ? ("Hybrid CapsLock v" . ver) : "Hybrid CapsLock"
    item := Map()
    item["key"] := ">"
    item["description"] := desc
    itemsArr := []
    itemsArr.Push(item)

    ; Decide tooltip type like leader does (respect INI menu_layout)
    tooltipType := (tooltipConfig.menuLayout = "list_vertical") ? "bottom_right_list" : "leader"

    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Hybrid CapsLock"
    cmd["items"] := itemsArr
    cmd["timeout_ms"] := 1000  ; 1s only at startup

    ; Apply layout/columns from theme
    if (theme.window.Has("layout"))
        cmd["layout"] := theme.window["layout"]
    if (theme.window.Has("columns") && theme.window["columns"] > 0)
        cmd["columns"] := theme.window["columns"]

    ; If list layout via tooltip type, enforce list
    if (tooltipType = "bottom_right_list")
        cmd["layout"] := "list"

    ; Style and position from theme (same as leader)
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position

    ; Window flags
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]

    ; Explicit type for compatibility
    cmd["tooltip_type"] := tooltipType

    ; No navigation

    StartTooltipApp()
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

; API avanzada: admite layout, columnas, estilo, posición y flags
ShowCSharpTooltipAdvanced(title, items, navigation := "", opts := 0) {
    global tooltipConfig
    StartTooltipApp()

    ; Defaults de timeout
    timeout := (tooltipConfig.optionsTimeout)
    if (tooltipConfig.persistent)
        timeout := 300000
    if (IsObject(opts) && opts.Has("timeout_ms"))
        timeout := opts["timeout_ms"]

    ; Construir comando base
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := title
    cmd["items"] := BuildItemObjects(items)
    navArr := BuildNavArray(navigation)
    if (navArr.Length)
        cmd["navigation"] := navArr
    cmd["timeout_ms"] := timeout

    ; Leer defaults de tema
    theme := ReadTooltipThemeDefaults()

    ; Aplicar window/layout defaults y opts
    if (theme.window.Has("layout"))
        cmd["layout"] := theme.window["layout"]
    if (theme.window.Has("columns") && theme.window["columns"] > 0)
        cmd["columns"] := theme.window["columns"]
    if (IsObject(opts)) {
        if (opts.Has("layout"))
            cmd["layout"] := opts["layout"]
        if (opts.Has("columns"))
            cmd["columns"] := opts["columns"]
    }

    ; tooltip_type compat si layout=list y no definido
    if (!cmd.Has("layout") && tooltipConfig.menuLayout = "list_vertical")
        cmd["layout"] := "list"

    ; Style merge
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (IsObject(opts) && opts.Has("style"))
        cmd["style"] := DeepMerge(cmd.Has("style") ? cmd["style"] : Map(), opts["style"])

    ; Position merge
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (IsObject(opts) && opts.Has("position"))
        cmd["position"] := DeepMerge(cmd.Has("position") ? cmd["position"] : Map(), opts["position"])

    ; Flags de ventana
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]
    if (IsObject(opts)) {
        for k in ["topmost","click_through","opacity"] {
            if (opts.Has(k))
                cmd[k] := opts[k]
        }
    }

    ; Back-compat: tooltip_type si layout es list
    if (IsObject(opts) && opts.Has("tooltip_type"))
        cmd["tooltip_type"] := opts["tooltip_type"]
    else if (cmd.Has("layout") && StrLower(cmd["layout"]) = "list")
        cmd["tooltip_type"] := "bottom_right_list"
    else
        cmd["tooltip_type"] := "leader"

    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

