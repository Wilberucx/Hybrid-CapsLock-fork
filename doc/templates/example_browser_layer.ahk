; ==============================
; PERSISTENT LAYER TEMPLATE - BROWSER EXAMPLE
; ==============================
; This is an example created by following the layer_template.ahk instructions.
; It demonstrates how to create a Browser Navigation Layer step by step.
;
; STEPS FOLLOWED (from PERSISTENT_LAYER_TEMPLATE.md):
; 1. Copied layer_template.ahk to example_browser_layer.ahk
; 2. Changed LAYER_NAME from "MyLayer" to "Browser"
; 3. Defined browser-specific hotkeys in the designated section
; 4. Kept default Esc exit (added q as alternate)
; 5. Customized help text for browser commands
; 6. Ready to include in init.ahk and register in command_system_init.ahk
;
; ==============================

; ==============================
; CONFIGURATION - EDIT THIS SECTION
; ==============================

; Layer name (used for global variables and display)
; Replace LAYER_NAME with your layer name (e.g., "Excel", "Database", "Editor")
LAYER_NAME := "Browser"  ; ← CHANGED FROM "MyLayer"

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
; Uncomment to load mappings from config/Browser_layer.ini
; try {
;     global BrowserMappings
;     BrowserMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\Browser_layer.ini", "Normal", "order")
;     if (BrowserMappings.Count > 0)
;         ApplyGenericMappings("Browser_normal", BrowserMappings, (*) => (layerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed()))
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
; Browser-specific navigation and shortcuts

; Navigation
h::Send("!{Left}")      ; Back
l::Send("!{Right}")     ; Forward
j::Send("{WheelDown}")  ; Scroll down
k::Send("{WheelUp}")    ; Scroll up
g::Send("^{Home}")      ; Go to top
+g::Send("^{End}")      ; Go to bottom (Shift+g = G)

; Tab management
t::Send("^t")           ; New tab
w::Send("^w")           ; Close tab
[::Send("^+{Tab}")      ; Previous tab
]::Send("^{Tab}")       ; Next tab
+t::Send("^+t")         ; Reopen closed tab (Shift+t)

; Page actions
r::Send("^r")           ; Reload
f::Send("^f")           ; Find
o::Send("^l")           ; Open URL bar
b::Send("^d")           ; Bookmark
s::Send("^s")           ; Save page

; Zoom
=::Send("^{NumpadAdd}") ; Zoom in
-::Send("^{NumpadSub}") ; Zoom out
0::Send("^0")           ; Reset zoom

; Developer tools
i::Send("{F12}")        ; DevTools
+i::Send("^+i")         ; Inspect element

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
; Alternate exit with q (Vim-style)
q:: {
    global layerActive
    DeactivateMyLayer()
    SetTempStatus(LAYER_NAME . " LAYER OFF", 1500)
}

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
    helpItems := "h:Back|l:Forward|j:Down|k:Up|t:New Tab|w:Close|r:Reload|f:Find|o:URL bar|b:Bookmark|?:Help"
    
    ; EDIT THIS: Customize your help text
    title := StrUpper(LAYER_NAME) . " HELP"
    footer := "ESC/q: Exit Layer"  ; Adjust based on your exit key
    
    try ShowCSharpOptionsMenu(title, helpItems, footer)
}

; Native Tooltip Help (fallback)
ShowLayerHelpNative() {
    ; EDIT THIS: Customize your help text
    helpText := LAYER_NAME . " LAYER HELP:`n"
    helpText .= "h: Back | l: Forward`n"
    helpText .= "j: Scroll Down | k: Scroll Up`n"
    helpText .= "g: Top | G: Bottom`n"
    helpText .= "t: New Tab | w: Close Tab`n"
    helpText .= "[: Prev Tab | ]: Next Tab`n"
    helpText .= "r: Reload | f: Find`n"
    helpText .= "o: URL bar | b: Bookmark`n"
    helpText .= "s: Save | i: DevTools`n"
    helpText .= "?: Toggle Help`n"
    helpText .= "ESC/q: Exit Layer"  ; Adjust based on your exit key
    
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
; Config file: config/Browser_layer.ini
; [Settings]
; whitelist=chrome.exe,firefox.exe,msedge.exe
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
; Not needed for this simple browser layer example
; See template for patterns and examples

; ==============================
; TEMPLATE END
; ==============================
; Remember to:
; 1. Include this file in init.ahk: #Include src/layer/example_browser_layer.ahk
; 2. Register activation in command_system_init.ahk:
;    RegisterKeymapFlat("leader", "b", "Browser Layer", ActivateMyLayer, false, 5)
; 3. Create optional config file: config/Browser_layer.ini
;    [Settings]
;    whitelist=chrome.exe,firefox.exe,msedge.exe,brave.exe
; 4. Test activation, hotkeys, exit keys (Esc and q), and help system
