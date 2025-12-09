; ===================================================================
; INTEGRACIÓN C# TOOLTIP PARA HYBRIDCAPSLOCK v2.1
; ===================================================================
; Integration file to replace basic tooltips with C# + WPF
; Incluir este archivo en HybridCapsLock.ahk con: #Include tooltip_csharp_integration.ahk
;
; TooltipApp v2.1 Features:
; - NerdFont icon support (use Chr() for Unicode glyphs)
; - Animation system (fade, slide with easing functions)
; - Multi-monitor positioning with DPI awareness
; - Multi-window support (unique IDs for independent tooltips)
; - Granular configuration: layout, window, animation objects
;
; Documentation: See tooltip_doc/Tooltip_Api_Protocol.md for full API reference

; ===================================================================
; VARIABLES GLOBALES NECESARIAS
; ===================================================================

; Definir rutas de configuración si no están definidas (Neovim-style: ahk/config/)
if (!IsSet(ConfigIni)) {
    global ConfigIni := A_ScriptDir . "\ahk\config\configuration.ini"
}

; Global variables for tooltip configuration (lazy-loaded)
global tooltipConfig := unset

; Global state variables
global tooltipMenuActive := false
global tooltipCurrentTitle := ""

; Lazy loader for tooltipConfig (prevents initialization order issues)
GetTooltipConfig() {
    global tooltipConfig
    if (!IsSet(tooltipConfig)) {
        tooltipConfig := ReadTooltipConfig()
    }
    return tooltipConfig
}


; ===================================================================
; FUNCIONES DE CONFIGURACIÓN
; ===================================================================

; Global helper to clean values read from INI (removes comments ; and spaces)
CleanIniValue(value) {
    if (InStr(value, ";")) {
        value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
    }
    return Trim(value)
}

; Function to read tooltip configuration (HybridConfig only)
ReadTooltipConfig() {
    global HybridConfig
    
    ; DEFENSIVE: Check if HybridConfig exists, is an object, AND has tooltips property
    if (!IsSet(HybridConfig)) {
        ; HybridConfig not loaded yet - use fallback
        return GetFallbackTooltipConfig()
    }
    
    if (!IsObject(HybridConfig)) {
        ; HybridConfig is not an object - use fallback
        return GetFallbackTooltipConfig()
    }
    
    if (!HybridConfig.HasOwnProp("tooltips")) {
        ; tooltips property doesn't exist - use fallback
        return GetFallbackTooltipConfig()
    }
    
    ; Now safely try to read the config
    try {
        tooltipObj := HybridConfig.tooltips
        
        ; Verify it's an object before accessing nested properties
        if (!IsObject(tooltipObj)) {
            return GetFallbackTooltipConfig()
        }
        
        ; Create proper object with base Object class (AHK v2 compatible)
        config := {
            enabled: true,
            handleInput: false,
            optionsTimeout: 10000,
            statusTimeout: 2000,
            autoHide: true,
            persistent: false,
            fadeAnimation: true,
            clickThrough: true,
            exePath: "",
            menuLayout: "grid"
        }
        
        ; Override with values from HybridConfig if they exist
        if (tooltipObj.HasOwnProp("enabled"))
            config.enabled := tooltipObj.enabled
        if (tooltipObj.HasOwnProp("handles_input"))
            config.handleInput := tooltipObj.handles_input
        
        ; Timeouts with nested object check
        if (tooltipObj.HasOwnProp("timeouts") && IsObject(tooltipObj.timeouts)) {
            if (tooltipObj.timeouts.HasOwnProp("options_menu"))
                config.optionsTimeout := tooltipObj.timeouts.options_menu
            if (tooltipObj.timeouts.HasOwnProp("status_notification"))
                config.statusTimeout := tooltipObj.timeouts.status_notification
        }
        
        ; Features with nested object check
        if (tooltipObj.HasOwnProp("features") && IsObject(tooltipObj.features)) {
            if (tooltipObj.features.HasOwnProp("auto_hide_on_action"))
                config.autoHide := tooltipObj.features.auto_hide_on_action
            if (tooltipObj.features.HasOwnProp("persistent_menus"))
                config.persistent := tooltipObj.features.persistent_menus
            if (tooltipObj.features.HasOwnProp("fade_animation"))
                config.fadeAnimation := tooltipObj.features.fade_animation
            if (tooltipObj.features.HasOwnProp("click_through"))
                config.clickThrough := tooltipObj.features.click_through
        }
        
        ; exe_path with proper check
        if (tooltipObj.HasOwnProp("exe_path"))
            config.exePath := tooltipObj.exe_path
        
        ; Layout with nested object check
        if (tooltipObj.HasOwnProp("layout") && IsObject(tooltipObj.layout)) {
            if (tooltipObj.layout.HasOwnProp("menu_layout"))
                config.menuLayout := tooltipObj.layout.menu_layout
        }
        
        return config
    } catch as e {
        ; If any error occurs during reading, use fallback
        return GetFallbackTooltipConfig()
    }
}

; Helper function to return fallback config (DRY principle)
GetFallbackTooltipConfig() {
    return {
        enabled: true,
        handleInput: false,
        optionsTimeout: 10000,
        statusTimeout: 2000,
        autoHide: true,
        persistent: false,
        fadeAnimation: true,
        clickThrough: true,
        exePath: "",
        menuLayout: "grid"
    }
}

; ===================================================================
; COMUNICACIÓN NAMED PIPE (NUEVO PROTOCOLO)
; ===================================================================

; Enviar JSON crudo al Named Pipe
Tooltip_SendRaw(json) {
    pipeName := "\\.\pipe\TooltipPipe"
    try {
        ; Abrir pipe en modo escritura
        ; Nota: FileOpen con ruta de pipe funciona en v2
        pipe := FileOpen(pipeName, "w", "UTF-8")
        if (pipe) {
            pipe.Write(json . "`n")
            pipe.Close()
        }
    } catch as e {
        ; Fallo silencioso o log si es necesario
        Log.e("Error writing to pipe: " . e.Message, "TOOLTIP")
    }
}

; Wrapper para compatibilidad con código existente que usaba ScheduleTooltipJsonWrite
ScheduleTooltipJsonWrite(json) {
    Tooltip_SendRaw(json)
}

; (JsonEscape helper defined later once)
; ===================================================================
; FUNCIONES PRINCIPALES DE TOOLTIP C#




; ===================================================================

; Función principal para mostrar tooltip C# (con timeout personalizado)
ShowCSharpTooltip(title, items, navigation := "", timeout := 0) {
    ; Decide layout based on configuration
    config := GetTooltipConfig()
    tooltipType := (config.menuLayout = "list_vertical") ? "bottom_right_list" : "leader"
    return ShowCSharpTooltipWithType(title, items, navigation, timeout, tooltipType)
}

; Tooltip tipo lista anclado abajo a la derecha (C#)
ShowBottomRightListTooltip(title, items, navigation := "", timeout := 0) {
    return ShowCSharpTooltipWithType(title, items, navigation, timeout, "bottom_right_list")
}

ShowCSharpTooltipWithType(title, items, navigation := "", timeout := 0, tooltipType := "leader") {
    config := GetTooltipConfig()
    ; Enforce layout from INI: if list_vertical is configured, always use bottom_right_list for menus
    if (config.menuLayout = "list_vertical" && tooltipType = "leader") {
        tooltipType := "bottom_right_list"
    }

    ; Ensure C# app is running before writing JSON (lazy start)
    StartTooltipApp()
    
    ; Si no se especifica timeout, usar el de opciones por defecto
    if (timeout = 0) {
        timeout := config.optionsTimeout
    }
    
    ; Si persistent_menus está habilitado, usar timeout muy largo
    if (config.persistent) {
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

    ; === NEW: Layout object (v2.1 API) ===
    ; Use new layout object structure for better organization
    if (theme.window.Has("layout") || theme.window.Has("columns")) {
        cmd["layout"] := Map()
        if (theme.window.Has("layout"))
            cmd["layout"]["mode"] := theme.window["layout"]
        if (theme.window.Has("columns") && theme.window["columns"] > 0)
            cmd["layout"]["columns"] := theme.window["columns"]
    }

    ; Si tooltipType implica lista, forzar layout=list
    if (tooltipType = "bottom_right_list") {
        if (!cmd.Has("layout"))
            cmd["layout"] := Map()
        cmd["layout"]["mode"] := "list"
    }

    ; Copiar estilo y posición desde tema (si existen)
    if (theme.style.Count) {
        cmd["style"] := theme.style
        Log.d("Theme style applied: " . theme.style.Count . " properties", "TOOLTIP")
    } else {
        Log.w("theme.style is empty", "TOOLTIP")
    }
    if (theme.position.Count)
        cmd["position"] := theme.position

    ; === NEW: Window object (v2.1 API) ===
    ; Group window-level properties in window object
    if (theme.window.Has("topmost") || theme.window.Has("click_through") || theme.window.Has("opacity")) {
        cmd["window"] := Map()
        if (theme.window.Has("topmost"))
            cmd["window"]["topmost"] := theme.window["topmost"]
        if (theme.window.Has("click_through"))
            cmd["window"]["click_through"] := theme.window["click_through"]
        if (theme.window.Has("opacity"))
            cmd["window"]["opacity"] := theme.window["opacity"]
    }

    ; === NEW: Animation support (v2.1 API) ===
    ; Add default fade animation if enabled in config
    if (config.fadeAnimation) {
        cmd["animation"] := Map()
        cmd["animation"]["type"] := "fade"
        cmd["animation"]["duration_ms"] := 200
        cmd["animation"]["easing"] := "ease_out"
    }

    ; Compatibilidad: incluir tooltip_type explícito (DEPRECATED but supported)
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
    config := GetTooltipConfig()
    items := "status:" . message
    ShowCSharpTooltip(title, items, "Esc: Close", config.statusTimeout)
}

; Función para iniciar la aplicación C# tooltip
IsAbsolutePath(p) {
    return RegExMatch(p, "i)^[A-Z]:\\|^\\\\|^/")
}

StartTooltipApp() {
    config := GetTooltipConfig()
    
    ; DEFENSIVE: Verify config is a valid object with exePath property
    if (!IsObject(config)) {
        ; Config is not an object, force fallback
        config := GetFallbackTooltipConfig()
    }
    
    if (!config.HasOwnProp("exePath")) {
        ; exePath property missing, force fallback
        config := GetFallbackTooltipConfig()
    }
    
    ; Verificar si ya está ejecutándose
    if (!ProcessExist("TooltipApp.exe")) {
        ; Intentar ejecutar desde diferentes ubicaciones
        if (config.exePath != "" && config.exePath) {
            exePath := config.exePath
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
global tooltipCurrentPath := ""

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

TooltipNavPush(path, title) {
    global tooltipNavStack
    ; Check if top is same to avoid duplicates
    if (tooltipNavStack.Length > 0) {
        top := tooltipNavStack[tooltipNavStack.Length]
        if (top.path == path)
            return
    }
    tooltipNavStack.Push({path: path, title: title})
}

TooltipShowById(navItem) {
    ShowMenuForPath(navItem.path, navItem.title)
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
; Central dispatcher for option selection
HandleTooltipSelection(key) {
    global tooltipMenuActive, tooltipCurrentTitle, tooltipCurrentPath
    
    ; Debug
    Log.d("Selection - path=" . tooltipCurrentPath . " key=" . key, "TOOLTIP")

    if (key = "ESC") {
        HideCSharpTooltip()
        tooltipMenuActive := false
        return
    }
    
    if (key = "\\") {
        TooltipNavBackCS()
        return
    }

    ; Dynamic lookup using KeymapRegistry
    ; We need to find the item in the current path
    keymaps := GetKeymapsForPath(tooltipCurrentPath)
    
    if (keymaps.Has(key)) {
        item := keymaps[key]
        
        if (item["isCategory"]) {
            ; It's a category -> Navigate to it
            ShowMenuForPath(item["path"], item["desc"])
        } else {
            ; It's an action -> Execute it
            HideCSharpTooltip() ; Hide first usually
            tooltipMenuActive := false
            
            if (item["confirm"]) {
                if (!ShowUnifiedConfirmation(item["desc"])) {
                    return ; Cancelled
                }
            }
            
            try {
                item["action"]()
            } catch as e {
                Log.e("Error executing action for key " . key . ": " . e.Message, "TOOLTIP")
                ShowCSharpStatusNotification("ERROR", "Action failed")
            }
        }
    } else {
        Log.d("Unknown key in " . tooltipCurrentPath . ": " . key, "TOOLTIP")
    }
}

; Ensure ShowCSharpOptionsMenu marks menu as active and remembers title
; (we hook by wrapping ShowCSharpOptionsMenu via a helper)
Original_ShowCSharpOptionsMenu(title, items, navigation := "", timeout := 0) {
    config := GetTooltipConfig()
    if (timeout = 0) {
        timeout := config.optionsTimeout
    }
    ; Force layout decision here as well, so every options menu respects INI layout
    tooltipType := (config.menuLayout = "list_vertical") ? "bottom_right_list" : "leader"
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
; Context helpers for scoping hotkeys
TooltipInMenu() {
    global tooltipMenuActive
    config := GetTooltipConfig()
    return tooltipMenuActive && config.handleInput
}

; Handle confirmation selection (Y/N)
HandleConfirmationSelection(confirmed) {
    global confirmationResult, confirmationActive
    confirmationResult := confirmed
    confirmationActive := false
    HideCSharpTooltip()
    
}

TooltipInConfirmationMode() {
    global tooltipMenuActive, tooltipCurrentTitle
    config := GetTooltipConfig()
    return tooltipMenuActive && config.handleInput && (tooltipCurrentTitle = "CONFIRMATION")
}

#HotIf TooltipInConfirmationMode()
y::HandleConfirmationSelection(true)
n::HandleConfirmationSelection(false)
Esc::HandleConfirmationSelection(false)
#HotIf

; Leader menu hotkeys (only on LEADER MODE)
; Generic menu hotkeys (active whenever a tooltip menu is open)
#HotIf TooltipInMenu()
a::HandleTooltipSelection("a")
b::HandleTooltipSelection("b")
c::HandleTooltipSelection("c")
d::HandleTooltipSelection("d")
e::HandleTooltipSelection("e")
f::HandleTooltipSelection("f")
g::HandleTooltipSelection("g")
h::HandleTooltipSelection("h")
i::HandleTooltipSelection("i")
j::HandleTooltipSelection("j")
k::HandleTooltipSelection("k")
l::HandleTooltipSelection("l")
m::HandleTooltipSelection("m")
n::HandleTooltipSelection("n")
o::HandleTooltipSelection("o")
p::HandleTooltipSelection("p")
q::HandleTooltipSelection("q")
r::HandleTooltipSelection("r")
s::HandleTooltipSelection("s")
t::HandleTooltipSelection("t")
u::HandleTooltipSelection("u")
v::HandleTooltipSelection("v")
w::HandleTooltipSelection("w")
x::HandleTooltipSelection("x")
y::HandleTooltipSelection("y")
z::HandleTooltipSelection("z")
1::HandleTooltipSelection("1")
2::HandleTooltipSelection("2")
3::HandleTooltipSelection("3")
4::HandleTooltipSelection("4")
5::HandleTooltipSelection("5")
6::HandleTooltipSelection("6")
7::HandleTooltipSelection("7")
8::HandleTooltipSelection("8")
9::HandleTooltipSelection("9")
0::HandleTooltipSelection("0")
-::HandleTooltipSelection("-")
=::HandleTooltipSelection("=")
[::HandleTooltipSelection("[")
]::HandleTooltipSelection("]")
SC027::HandleTooltipSelection(";") ; ;
SC028::HandleTooltipSelection("'") ; '
,::HandleTooltipSelection(",")
.::HandleTooltipSelection(".")
/::HandleTooltipSelection("/")
\::HandleTooltipSelection("\\")
Esc::HandleTooltipSelection("ESC")
Backspace::HandleTooltipSelection("\\")
#HotIf

; ===================================================================
; REEMPLAZOS DE FUNCIONES EXISTENTES
; ===================================================================

; Reemplazar ShowLeaderModeMenu() original
; Reemplazar ShowLeaderModeMenu() original
ShowLeaderModeMenuCS() {
    ShowMenuForPath("leader", "LEADER MODE")
}

; Generic function to show menu for any path
ShowMenuForPath(path, title) {
    global tooltipCurrentPath
    tooltipCurrentPath := path
    
    TooltipNavPush(path, title)
    
    items := GenerateCategoryItemsForPath(path)
    if (items = "") {
        items := "[No items registered]"
    }
    
    ShowCSharpOptionsMenu(title, items, "BACKSPACE: Back|ESC: Exit")
}
; Estas funciones ya no son necesarias gracias al sistema genérico.


; ===================================================================
; GENERIC LAYER STATUS (NUEVO PROTOCOLO)
; ===================================================================

ShowGenericLayerStatusCS(layerId, isActive) {
    ; Si no está activo, ocultar el pill
    if (!isActive) {
        json := '{"id": "status_pill", "show": false}'
        Tooltip_SendRaw(json)
        return
    }

    ; Obtener metadata del layer (color, nombre)
    metadata := GetLayerMetadata(layerId)

    ; Construir comando para mostrar status pill persistente
    cmd := Map()
    cmd["id"] := "status_pill"
    cmd["show"] := true
    cmd["title"] := metadata["name"]
    cmd["timeout_ms"] := 0 ; Persistente
    
    ; Leer defaults de tema
    theme := ReadTooltipThemeDefaults()

    ; Posición desde tema (position_status)
    if (theme.HasOwnProp("position_status") && theme.position_status.Count > 0) {
        cmd["position"] := theme.position_status
    } else {
        ; Fallback hardcoded si falla la lectura del tema
        cmd["position"] := Map()
        cmd["position"]["anchor"] := "bottom_right"
        cmd["position"]["offset_x"] := -20
        cmd["position"]["offset_y"] := -20
    }
    
    ; Estilo distintivo para status
    cmd["style"] := Map()
    cmd["style"]["background"] := metadata["color"]
    cmd["style"]["text"] := metadata["textColor"]  ; Use dynamic text color
    cmd["style"]["padding"] := [8, 4, 8, 4]
    cmd["style"]["corner_radius"] := 4
    cmd["style"]["title_font_size"] := 10
    
    ; Enviar comando
    StartTooltipApp()
    json := SerializeJson(cmd)
    Tooltip_SendRaw(json)
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

ShowProcessTerminatedCS() {
    ShowCSharpStatusNotification("SYSTEM", "PROCESS TERMINATED")
}

ShowCommandExecutedCS(category, command) {
    ShowCSharpStatusNotification("COMMAND EXECUTED", category . " command executed: " . command)
}

; ===================================================================
; FUNCIONES ESPECÍFICAS PARA NVIM/ VISUAL/ EXCEL/ SCROLL HELP

; ===================================================================
; FUNCIONES ESPECÍFICAS ELIMINADAS (Usar ShowGenericLayerStatus)
; ===================================================================


; ===================================================================
; FUNCIONES ESPECÍFICAS PARA SUBMENÚS DE COMANDOS
; ===================================================================

; Submenú System Commands (leader → c → s)
; ===================================================================
; FUNCIONES ESPECÍFICAS ELIMINADAS (Usar ShowGenericLayerStatus)
; ===================================================================
; Las funciones ShowSystemCommandsMenuCS, ShowNetworkCommandsMenuCS, etc.
; han sido eliminadas ya que ahora se usa ShowMenuForPath de forma dinámica.


; ===================================================================
; FUNCIÓN DE LIMPIEZA
; ===================================================================

; Función para cerrar las aplicaciones C#
StopTooltipApp() {
    try {
        ProcessClose("TooltipApp.exe")
    }
    ; Cerrar todos los PowerShell que ejecutan StatusWindow
    statusTypes := ["Nvim", "Visual", "Yank"]
    for index, statusType in statusTypes {
        try {
            RunWait("powershell.exe -Command `"Get-Process | Where-Object {`$_.ProcessName -eq 'powershell' -and `$_.CommandLine -like '*StatusWindow_" . statusType . "*'} | Stop-Process -Force`"", , "Hide")
        }
    }
}

; ===================================================================
; API AVANZADA: TEMA, MERGE Y SERIALIZACIÓN JSON
; ===================================================================

; Leer tema por defecto desde configuration.ini (UPDATED: HybridConfig support)
ReadTooltipThemeDefaults() {
    global HybridConfig, ConfigIni
    
    ; Try HybridConfig theme first
    if (IsSet(HybridConfig)) {
        try {
            Log.d("Reading theme from HybridConfig", "TOOLTIP")
            theme := HybridConfig.getTheme()
            Log.d("Theme name: " . theme.name, "TOOLTIP")
            defaults := Map()
            
            ; Window properties
            defaults.window := Map()
            defaults.window["layout"] := theme.window.layout
            defaults.window["columns"] := theme.window.columns  
            defaults.window["topmost"] := theme.window.topmost
            defaults.window["click_through"] := theme.window.click_through
            defaults.window["opacity"] := theme.window.opacity
            
            ; Style - colors
            defaults.style := Map()
            defaults.style["background"] := theme.colors.background
            defaults.style["text"] := theme.colors.text
            defaults.style["border"] := theme.colors.border
            defaults.style["accent_options"] := theme.colors.accent_options
            defaults.style["accent_navigation"] := theme.colors.accent_navigation
            defaults.style["navigation_text"] := theme.colors.navigation_text
            defaults.style["success"] := theme.colors.success
            defaults.style["error"] := theme.colors.error
            
            ; Style - typography
            defaults.style["title_font_size"] := theme.typography.title_font_size
            defaults.style["item_font_size"] := theme.typography.item_font_size
            defaults.style["navigation_font_size"] := theme.typography.navigation_font_size
            
            ; Style - spacing
            defaults.style["border_thickness"] := theme.spacing.border_thickness
            defaults.style["corner_radius"] := theme.spacing.corner_radius
            defaults.style.padding := [theme.spacing.padding.left, theme.spacing.padding.top, theme.spacing.padding.right, theme.spacing.padding.bottom]
            
            ; Position
            defaults.position := Map()
            defaults.position["anchor"] := theme.position.anchor
            defaults.position["offset_x"] := theme.position.offset_x
            defaults.position["offset_x"] := theme.position.offset_x
            defaults.position["offset_y"] := theme.position.offset_y
            
            ; Extended position properties
            if (theme.position.HasOwnProp("x"))
                defaults.position["x"] := theme.position.x
            if (theme.position.HasOwnProp("y"))
                defaults.position["y"] := theme.position.y
            if (theme.position.HasOwnProp("monitor"))
                defaults.position["monitor"] := theme.position.monitor
            
            ; Status Position
            defaults.position_status := Map()
            if (theme.HasOwnProp("position_status")) {
                defaults.position_status["anchor"] := theme.position_status.anchor
                defaults.position_status["offset_x"] := theme.position_status.offset_x
                defaults.position_status["offset_y"] := theme.position_status.offset_y
                if (theme.position_status.HasOwnProp("x"))
                    defaults.position_status["x"] := theme.position_status.x
                if (theme.position_status.HasOwnProp("y"))
                    defaults.position_status["y"] := theme.position_status.y
                if (theme.position_status.HasOwnProp("monitor"))
                    defaults.position_status["monitor"] := theme.position_status.monitor
            } else {
                ; Fallback to generic position if not defined
                defaults.position_status := defaults.position.Clone()
            }
            
            ; Navigation labels
            defaults["navigation_label"] := theme.navigation.back_label . " | " . theme.navigation.exit_label
            
            Log.d("Theme from HybridConfig loaded successfully - " . defaults.style.Count . " style properties", "TOOLTIP")
            return defaults
        } catch as e {
            ; Fall through to INI
            Log.w("Error reading theme from HybridConfig: " . e.Message, "TOOLTIP")
        }
    }
    
    ; Fallback to INI
    Log.d("Using INI fallback for theme", "TOOLTIP")
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
    s := StrReplace(s, "\", "\\")
    s := StrReplace(s, '"', '\"')
    s := StrReplace(s, "`n", "\n")
    s := StrReplace(s, "`r", "\r")
    s := StrReplace(s, "`t", "\t")
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
; Construir item objects desde string items "k:desc|..." o Array
BuildItemObjects(itemsInput) {
    arr := []
    if (!IsSet(itemsInput) || itemsInput = "")
        return arr

    ; Si es un Array (nuevo soporte)
    if (IsObject(itemsInput) && HasProp(itemsInput, "Length")) {
        for _, item in itemsInput {
            if (IsObject(item)) {
                ; Ya es un objeto/mapa, usar tal cual
                arr.Push(item)
            } else {
                ; Es un string "key:desc", parsear
                seg := StrSplit(item, ":", , 2) ; Limit 2 to allow colons in description
                if (seg.Length >= 2) {
                    itm := Map()
                    itm["key"] := seg[1]
                    itm["description"] := seg[2]
                    arr.Push(itm)
                }
            }
        }
        return arr
    }

    ; Si es String (legacy)
    parts := StrSplit(itemsInput, "|")
    for _, p in parts {
        seg := StrSplit(p, ":", , 2)
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
; Construir nav array desde string "a|b|c" o Array
BuildNavArray(navInput) {
    arr := []
    theme := ReadTooltipThemeDefaults()

    if (!IsSet(navInput) || navInput = "") {
        if (theme.Has("navigation_label"))
            navInput := theme["navigation_label"]
        else
            return arr
    }

    themeParts := []
    if (theme.Has("navigation_label"))
        themeParts := StrSplit(theme["navigation_label"], "|")

    ; Si es Array (nuevo soporte)
    if (IsObject(navInput) && HasProp(navInput, "Length")) {
        for _, p in navInput {
            ; Compatibilidad: reemplazar tokens antiguos
            if (p = "\\: Back" && themeParts.Length >= 1)
                p := Trim(themeParts[1])
            else if ((p = "ESC: Exit" || p = "Esc: Exit") && themeParts.Length >= 2)
                p := Trim(themeParts[2])
            arr.Push(p)
        }
        return arr
    }

    ; Si es String (legacy)
    parts := StrSplit(navInput, "|")
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
    config := GetTooltipConfig()
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
    tooltipType := (config.menuLayout = "list_vertical") ? "bottom_right_list" : "leader"

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

; API avanzada: admite layout, columnas, estilo, posición, animación y flags (v2.1)
ShowCSharpTooltipAdvanced(title, items, navigation := "", opts := 0) {
    config := GetTooltipConfig()
    StartTooltipApp()

    ; Defaults de timeout
    timeout := (config.optionsTimeout)
    if (config.persistent)
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

    ; === NEW: Layout object (v2.1 API) ===
    if (theme.window.Has("layout") || theme.window.Has("columns")) {
        cmd["layout"] := Map()
        if (theme.window.Has("layout"))
            cmd["layout"]["mode"] := theme.window["layout"]
        if (theme.window.Has("columns") && theme.window["columns"] > 0)
            cmd["layout"]["columns"] := theme.window["columns"]
    }
    
    ; Override from opts
    if (IsObject(opts) && opts.Has("layout")) {
        if (!cmd.Has("layout"))
            cmd["layout"] := Map()
        if (IsObject(opts["layout"])) {
            ; New v2.1 style: layout is an object
            cmd["layout"] := DeepMerge(cmd["layout"], opts["layout"])
        } else {
            ; Legacy: layout is a string ("grid" or "list")
            cmd["layout"]["mode"] := opts["layout"]
        }
    }
    if (IsObject(opts) && opts.Has("columns")) {
        if (!cmd.Has("layout"))
            cmd["layout"] := Map()
        cmd["layout"]["columns"] := opts["columns"]
    }

    ; tooltip_type compat si layout=list y no definido
    if (!cmd.Has("layout") && config.menuLayout = "list_vertical") {
        cmd["layout"] := Map()
        cmd["layout"]["mode"] := "list"
    }

    ; Style merge
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (IsObject(opts) && opts.Has("style"))
        cmd["style"] := DeepMerge(cmd.Has("style") ? cmd["style"] : Map(), opts["style"])

    ; Position merge (with multi-monitor support)
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (IsObject(opts) && opts.Has("position"))
        cmd["position"] := DeepMerge(cmd.Has("position") ? cmd["position"] : Map(), opts["position"])

    ; === NEW: Window object (v2.1 API) ===
    if (theme.window.Has("topmost") || theme.window.Has("click_through") || theme.window.Has("opacity")) {
        cmd["window"] := Map()
        if (theme.window.Has("topmost"))
            cmd["window"]["topmost"] := theme.window["topmost"]
        if (theme.window.Has("click_through"))
            cmd["window"]["click_through"] := theme.window["click_through"]
        if (theme.window.Has("opacity"))
            cmd["window"]["opacity"] := theme.window["opacity"]
    }
    
    ; Override from opts
    if (IsObject(opts) && opts.Has("window")) {
        if (!cmd.Has("window"))
            cmd["window"] := Map()
        cmd["window"] := DeepMerge(cmd["window"], opts["window"])
    }
    
    ; Legacy support: direct window properties
    if (IsObject(opts)) {
        for k in ["topmost","click_through","opacity"] {
            if (opts.Has(k)) {
                if (!cmd.Has("window"))
                    cmd["window"] := Map()
                cmd["window"][k] := opts[k]
            }
        }
    }

    ; === NEW: Animation support (v2.1 API) ===
    if (IsObject(opts) && opts.Has("animation")) {
        cmd["animation"] := opts["animation"]
    } else if (config.fadeAnimation) {
        ; Default fade animation if enabled
        cmd["animation"] := Map()
        cmd["animation"]["type"] := "fade"
        cmd["animation"]["duration_ms"] := 200
        cmd["animation"]["easing"] := "ease_out"
    }

    ; === NEW: Multi-window support (v2.1 API) ===
    if (IsObject(opts) && opts.Has("id"))
        cmd["id"] := opts["id"]

    ; Back-compat: tooltip_type (DEPRECATED)
    if (IsObject(opts) && opts.Has("tooltip_type"))
        cmd["tooltip_type"] := opts["tooltip_type"]
    else if (cmd.Has("layout") && cmd["layout"].Has("mode") && StrLower(cmd["layout"]["mode"]) = "list")
        cmd["tooltip_type"] := "bottom_right_list"
    else
        cmd["tooltip_type"] := "leader"

    json := SerializeJson(cmd)
    Log.d("ShowCSharpTooltipAdvanced JSON: " . json, "TOOLTIP")
    ScheduleTooltipJsonWrite(json)
}

