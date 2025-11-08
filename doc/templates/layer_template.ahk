; ==============================
; PERSISTENT LAYER TEMPLATE
; ==============================
; Use this template to create new persistent layers (modes) with customizable exit keys.
; This template provides a base structure compatible with the Hybrid-CapsLock architecture.
;
; FEATURES:
; - Persistent mode (stays active until exit key is pressed)
; - Configurable exit key (default: Esc, but can be Shift+n, etc.)
; - Help system with '?' toggle
; - C# tooltip integration
; - Whitelist/Blacklist app filtering
; - Compatible with dynamic config loading
;
; INSTRUCTIONS:
; 1. Copy this file to a new file (e.g., my_layer.ahk)
; 2. Replace LAYER_NAME with your layer name (e.g., Excel, Database, Editor)
; 3. Replace LAYER_KEY with your activation key (used in leader menu or standalone hotkey)
; 4. Configure EXIT_KEY combination (examples: 's', '+n' for Shift+n, '^q' for Ctrl+q)
; 5. Define your layer's hotkeys in the designated section
; 6. Update help text with your layer's commands
; 7. Include the new file in init.ahk
; 8. Register activation in command_system_init.ahk or as standalone hotkey
;
; ARCHITECTURE NOTES:
; - Uses #HotIf context to activate only when layer is active
; - Respects CapsLock physical state (inactive when CapsLock physically pressed)
; - InputLevel 1 for normal hotkeys, InputLevel 2 for sub-modes/mini-layers
; - Compatible with tooltip_csharp for modern UI
; - Optional config file: config/LAYER_NAME_layer.ini
;
; ==============================

; ==============================
; CONFIGURATION - EDIT THIS SECTION
; ==============================

; Layer name (used for global variables and display)
; Replace LAYER_NAME with your layer name (e.g., "Excel", "Database", "Editor")
LAYER_NAME := "MyLayer"  ; ← CHANGE THIS

; Global variables - DO NOT EDIT (auto-generated from LAYER_NAME)
%LAYER_NAME . "LayerEnabled"% := true   ; Feature flag (can be toggled in config)
%LAYER_NAME . "LayerActive"% := false   ; Layer state (on/off)
%LAYER_NAME . "HelpActive"% := false    ; Help menu state
%LAYER_NAME . "StaticEnabled"% := true  ; Static hotkeys enabled (vs dynamic from config)

; Create shortcuts for easier access
global layerEnabled := %LAYER_NAME . "LayerEnabled"%
global layerActive := %LAYER_NAME . "LayerActive"%
global layerHelpActive := %LAYER_NAME . "HelpActive"%
global layerStaticEnabled := %LAYER_NAME . "StaticEnabled"%

; ==============================
; OPTIONAL: DYNAMIC CONFIG LOADING
; ==============================
; Uncomment to load mappings from config/LAYER_NAME_layer.ini
; try {
;     global LAYER_NAMEMappings
;     LAYER_NAMEMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\" . LAYER_NAME . "_layer.ini", "Normal", "order")
;     if (LAYER_NAMEMappings.Count > 0)
;         ApplyGenericMappings(LAYER_NAME . "_normal", LAYER_NAMEMappings, (*) => (layerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed()))
; } catch {
; }

; ==============================
; LAYER ACTIVATION
; ==============================
; This function can be called from:
; - Leader menu (RegisterKeymapFlat in command_system_init.ahk)
; - Standalone hotkey (e.g., F20::ActivateMyLayer())
; - Other layers or scripts

ActivateMyLayer() {
    global layerActive
    layerActive := true
    ShowLayerStatus(true)
}

DeactivateMyLayer() {
    global layerActive
    layerActive := false
    ShowLayerStatus(false)
}

ToggleMyLayer() {
    global layerActive
    if (layerActive) {
        DeactivateMyLayer()
    } else {
        ActivateMyLayer()
    }
}

; ==============================
; LAYER HOTKEYS
; ==============================
; Context: Active only when:
; - layerEnabled is true (feature flag)
; - layerActive is true (layer is on)
; - CapsLock is NOT physically pressed
; - App is allowed (whitelist/blacklist filter)

#InputLevel 1
#HotIf (layerStaticEnabled ? (layerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed()) : false)

; ==============================
; DEFINE YOUR LAYER'S HOTKEYS HERE
; ==============================
; Examples:
; h::Send("{Left}")           ; Vim-style navigation
; j::Send("{Down}")
; k::Send("{Up}")
; l::Send("{Right}")
; y::Send("^c")               ; Yank (copy)
; p::Send("^v")               ; Paste
; u::Send("^z")               ; Undo
; r::Send("^y")               ; Redo
; f::Send("^f")               ; Find
; w::Send("^s")               ; Write (save)

; Example: Navigation keys
; h::Send("{Left}")
; j::Send("{Down}")
; k::Send("{Up}")
; l::Send("{Right}")

; Example: Editing keys
; y::Send("^c")  ; Copy
; p::Send("^v")  ; Paste
; u::Send("^z")  ; Undo

; ADD YOUR HOTKEYS HERE:
; key::Action


; ==============================
; EXIT KEY (CONFIGURABLE)
; ==============================
; Default: Escape key
; Common alternatives:
; - 's' for same-key toggle (press 's' to enter and exit)
; - '+n' for Shift+n (used in Excel layer)
; - '^q' for Ctrl+q
; - 'q' for simple q key

; Default exit with Escape
Esc:: {
    global layerActive
    DeactivateMyLayer()
    SetTempStatus(LAYER_NAME . " LAYER OFF", 1500)
}

; OPTIONAL: Add custom exit key here
; Example for Shift+n:
; +n:: {
;     global layerActive
;     DeactivateMyLayer()
;     SetTempStatus(LAYER_NAME . " LAYER OFF", 1500)
; }

; Example for same-key toggle (e.g., 's' to enter and exit):
; s:: {
;     global layerActive
;     ToggleMyLayer()
; }

; ==============================
; HELP SYSTEM
; ==============================
; Toggle help with '?' (Shift+/)
; Shows available commands for this layer

+vkBF:: (layerHelpActive ? LayerCloseHelp() : LayerShowHelp())
+SC035:: (layerHelpActive ? LayerCloseHelp() : LayerShowHelp())
?:: (layerHelpActive ? LayerCloseHelp() : LayerShowHelp())

#HotIf

; ==============================
; HELP FUNCTIONS
; ==============================

LayerShowHelp() {
    global tooltipConfig, layerHelpActive
    try HideCSharpTooltip()
    Sleep 30
    layerHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(LayerHelpAutoClose, -to)
    
    ; Show help (C# tooltip or native)
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowLayerHelpCS()
        } else {
            ShowLayerHelpNative()
        }
    } catch {
        ShowLayerHelpNative()
    }
}

LayerHelpAutoClose() {
    global layerHelpActive
    if (layerHelpActive)
        LayerCloseHelp()
}

LayerCloseHelp() {
    global layerActive, layerHelpActive
    try SetTimer(LayerHelpAutoClose, 0)
    try HideCSharpTooltip()
    layerHelpActive := false
    if (layerActive) {
        try ShowLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}

; C# Tooltip Help (modern UI)
ShowLayerHelpCS() {
    ; Define your help items here
    ; Format: "key:description|key:description"
    helpItems := "h:Left|j:Down|k:Up|l:Right|y:Copy|p:Paste|u:Undo|?:Help"
    
    ; EDIT THIS: Customize your help text
    title := StrUpper(LAYER_NAME) . " HELP"
    footer := "ESC: Close Help"  ; Adjust based on your exit key
    
    try ShowCSharpOptionsMenu(title, helpItems, footer)
}

; Native Tooltip Help (fallback)
ShowLayerHelpNative() {
    ; EDIT THIS: Customize your help text
    helpText := LAYER_NAME . " LAYER HELP:`n"
    helpText .= "h/j/k/l: Navigate (Vim-style)`n"
    helpText .= "y: Copy`n"
    helpText .= "p: Paste`n"
    helpText .= "u: Undo`n"
    helpText .= "?: Toggle Help`n"
    helpText .= "ESC: Exit Layer"  ; Adjust based on your exit key
    
    ShowCenteredToolTip(helpText)
}

; ==============================
; STATUS FUNCTIONS
; ==============================

ShowLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowLayerToggleCS(isActive)
    } else {
        ToolTip(isActive ? (LAYER_NAME . " LAYER ON") : (LAYER_NAME . " LAYER OFF"))
        SetTimer(() => ToolTip(), -1200)
    }
}

; C# Tooltip Status (modern UI)
ShowLayerToggleCS(isActive) {
    try {
        if (isActive) {
            ; EDIT THIS: Customize your ON status text
            title := StrUpper(LAYER_NAME) . " ON"
            message := "Press ? for help"
            ShowCSharpStatusNotification(title, message)
        } else {
            ; EDIT THIS: Customize your OFF status text
            ShowCSharpStatusNotification(StrUpper(LAYER_NAME), "OFF")
        }
    }
}

; ==============================
; APP FILTERING (WHITELIST/BLACKLIST)
; ==============================
; Optional: Restrict layer to specific applications
; Config file: config/LAYER_NAME_layer.ini
; [Settings]
; whitelist=chrome.exe,firefox.exe,excel.exe
; blacklist=notepad.exe,cmd.exe

LayerAppAllowed() {
    try {
        ini := A_ScriptDir . "\\config\\" . LAYER_NAME . "_layer.ini"
        wl := IniRead(ini, "Settings", "whitelist", "")
        bl := IniRead(ini, "Settings", "blacklist", "")
        proc := WinGetProcessName("A")
        if (bl != "" && InStr("," . StrLower(bl) . ",", "," . StrLower(proc) . ","))
            return false
        if (wl = "")
            return true
        return InStr("," . StrLower(wl) . ",", "," . StrLower(proc) . ",")
    } catch {
        return true
    }
}

; ==============================
; SUB-MODES / MINI-LAYERS (OPTIONAL)
; ==============================
; Use InputLevel 2 for temporary sub-modes within your layer
; Example: Visual mode, Command mode, etc.
;
; Pattern:
; 1. Define a global flag (e.g., global SubModeActive := false)
; 2. Create an entry hotkey that sets the flag to true
; 3. Define hotkeys with #InputLevel 2 and #HotIf (SubModeActive && layerActive)
; 4. Provide exit mechanism (Esc, Enter, or auto-timeout)
;
; Example:
; global SubModeActive := false
;
; #HotIf (layerActive && !SubModeActive)
; v:: {  ; Enter sub-mode with 'v'
;     global SubModeActive
;     SubModeActive := true
;     ShowSubModeStatus(true)
; }
; #HotIf
;
; #InputLevel 2
; #HotIf (layerActive && SubModeActive)
; h::Send("+{Left}")   ; Sub-mode specific behavior
; Esc:: {
;     global SubModeActive
;     SubModeActive := false
;     ShowSubModeStatus(false)
; }
; #HotIf
; #InputLevel 1

; ==============================
; TEMPLATE END
; ==============================
; Remember to:
; 1. Include this file in init.ahk: #Include src/layer/my_layer.ahk
; 2. Register activation in command_system_init.ahk or create standalone hotkey
; 3. Create optional config file: config/LAYER_NAME_layer.ini
; 4. Test activation, hotkeys, exit, and help system
