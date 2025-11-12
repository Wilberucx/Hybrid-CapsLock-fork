; ==============================
; LAYER TEMPLATE - Dynamic Layer Creation Pattern
; ==============================
; This is a template for creating new persistent layers
; 
; INSTRUCTIONS:
; 1. Copy this file to a new file: {layerName}_layer.ahk
; 2. Replace LAYER_NAME with your layer name in PascalCase (e.g., "Scroll", "Nvim", "Excel")
;    - For functions: ActivateLAYER_NAMELayer → ActivateExcelLayer
;    - For variables: isLAYER_NAMELayerActive → isExcelLayerActive
; 3. Replace LAYER_ID with layer identifier in lowercase (e.g., "scroll", "nvim", "excel")
;    - For SwitchToLayer: SwitchToLayer("LAYER_ID", ...) → SwitchToLayer("excel", ...)
;    - For ListenForLayerKeymaps: ListenForLayerKeymaps("LAYER_ID", ...) → ListenForLayerKeymaps("excel", ...)
;    - For RegisterKeymap: RegisterKeymap("LAYER_ID", ...) → RegisterKeymap("excel", ...)
; 4. Replace LAYER_DISPLAY with friendly name (e.g., "Scroll Layer", "Nvim Layer", "Excel Layer")
; 5. Implement your layer-specific actions
; 6. Register keymaps in config/keymap.ahk
;
; EXAMPLE:
;   LAYER_NAME = "Excel" (for functions and variables)
;   LAYER_ID = "excel" (for layer system identifiers)
;   LAYER_DISPLAY = "Excel Layer"
;   → excelLayerEnabled (camelCase derived from LAYER_NAME)
;   → isExcelLayerActive
;   → ActivateExcelLayer()
;   → OnExcelLayerActivate()
;   → OnExcelLayerDeactivate()

; ==============================
; CONFIGURATION
; ==============================

global LAYER_NAMELayerEnabled := true          ; Feature flag
global isLAYER_NAMELayerActive := false        ; Layer state (managed by SwitchToLayer)

; ==============================
; ACTIVATION FUNCTION
; ==============================

ActivateLAYER_NAMELayer(originLayer := "leader") {
    OutputDebug("[LAYER_NAME] ActivateLAYER_NAMELayer() called with originLayer: " . originLayer)
    result := SwitchToLayer("LAYER_ID", originLayer)  ; ⚠️ Use lowercase LAYER_ID here!
    OutputDebug("[LAYER_NAME] SwitchToLayer result: " . (result ? "true" : "false"))
    return result
}

; ==============================
; ACTIVATION/DEACTIVATION HOOKS
; ==============================

OnLAYER_NAMELayerActivate() {
    global isLAYER_NAMELayerActive
    isLAYER_NAMELayerActive := true
    
    OutputDebug("[LAYER_NAME] OnLAYER_NAMELayerActivate() - Activating layer")
    
    ; Show status (optional - implement ShowLAYER_NAMELayerStatus if needed)
    try {
        ; ShowLAYER_NAMELayerStatus(true)
        SetTempStatus("LAYER_DISPLAY ON", 1500)
    } catch Error as e {
        OutputDebug("[LAYER_NAME] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (uses keymap_registry system)
    try {
        ListenForLayerKeymaps("LAYER_ID", "isLAYER_NAMELayerActive")  ; ⚠️ Use lowercase LAYER_ID here!
    } catch Error as e {
        OutputDebug("[LAYER_NAME] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
    
    ; When listener exits, deactivate layer
    isLAYER_NAMELayerActive := false
    try {
        ; ShowLAYER_NAMELayerStatus(false)
        SetTempStatus("LAYER_DISPLAY OFF", 1500)
    }
}

OnLAYER_NAMELayerDeactivate() {
    global isLAYER_NAMELayerActive
    isLAYER_NAMELayerActive := false
    
    ; Clean up any layer-specific state here
    OutputDebug("[LAYER_NAME] Layer deactivated")
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to this layer's control
; Generic/reusable actions should be in src/actions/

LAYER_NAMEExit() {
    global isLAYER_NAMELayerActive
    isLAYER_NAMELayerActive := false
    try ReturnToPreviousLayer()
}

; Add your layer-specific action functions here
; Example:
; LAYER_NAMEDoSomething() {
;     ; Implementation
; }

; ==============================
; HELP SYSTEM (Optional but Recommended)
; ==============================
; Dynamic help system that reads keymaps from KeymapRegistry
; Shows all registered keymaps for this layer with tooltips

global LAYER_NAMEHelpActive := false

LAYER_NAMEToggleHelp() {
    global LAYER_NAMEHelpActive
    if (LAYER_NAMEHelpActive)
        LAYER_NAMECloseHelp()
    else
        LAYER_NAMEShowHelp()
}

LAYER_NAMEShowHelp() {
    global tooltipConfig, LAYER_NAMEHelpActive
    try HideCSharpTooltip()
    Sleep 30
    LAYER_NAMEHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(LAYER_NAMEHelpAutoClose, -to)
    
    ; Generate help dynamically from KeymapRegistry
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ; Use C# tooltip with dynamic items
            items := GenerateCategoryItemsForPath("LAYER_ID")  ; ⚠️ Use lowercase LAYER_ID!
            if (items = "")
                items := "[No keymaps registered for LAYER_ID layer]"
            ShowBottomRightListTooltip("LAYER_DISPLAY HELP", items, "?: Close", to)
        } else {
            ; Fallback: native tooltip with dynamic text
            menuText := BuildMenuForPath("LAYER_ID", "LAYER_DISPLAY HELP")  ; ⚠️ Use lowercase LAYER_ID!
            if (menuText = "")
                menuText := "NO KEYMAPS REGISTERED"
            ShowCenteredToolTip(menuText)
        }
    } catch Error as e {
        OutputDebug("[LAYER_NAME] ERROR showing help: " . e.Message)
        ShowCenteredToolTip("LAYER_DISPLAY HELP: See registered keymaps in config/keymap.ahk")
    }
}

LAYER_NAMEHelpAutoClose() {
    global LAYER_NAMEHelpActive
    if (LAYER_NAMEHelpActive)
        LAYER_NAMECloseHelp()
}

LAYER_NAMECloseHelp() {
    global isLAYER_NAMELayerActive, LAYER_NAMEHelpActive
    try SetTimer(LAYER_NAMEHelpAutoClose, 0)
    try HideCSharpTooltip()
    LAYER_NAMEHelpActive := false
    if (isLAYER_NAMELayerActive) {
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                ; If you have a custom status tooltip, call it here
                ; ShowLAYER_NAMELayerToggleCS(true)
            } else {
                ShowCenteredToolTip("◉ LAYER_DISPLAY")
                SetTimer(() => RemoveToolTip(), -900)
            }
        }
    } else {
        try RemoveToolTip()
    }
}

; ==============================
; KEYMAP REGISTRATION
; ==============================
; Register in config/keymap.ahk inside InitializeCategoryKeymaps():
;
; RegisterLAYER_NAMEKeymaps() {
;     ; Basic actions
;     RegisterKeymap("LAYER_ID", "key", "Description", ActionFunction, false, 1)  ; ⚠️ Use lowercase LAYER_ID!
;     
;     ; Layer control
;     RegisterKeymap("LAYER_ID", "Escape", "Exit Layer", LAYER_NAMEExit, false, 10)
;     
;     ; Help system (if implemented)
;     RegisterKeymap("LAYER_ID", "?", "Toggle Help", LAYER_NAMEToggleHelp, false, 100)
;     
;     OutputDebug("[LAYER_NAME] Keymaps registered successfully")
; }
;
; Then call RegisterLAYER_NAMEKeymaps() in InitializeCategoryKeymaps()
;
; OR register directly in InitializeCategoryKeymaps() (simpler approach):
;     RegisterKeymap("LAYER_ID", "h", "Move Left", VimMoveLeft, false, 20)  ; ⚠️ lowercase LAYER_ID!
;     RegisterKeymap("LAYER_ID", "j", "Move Down", VimMoveDown, false, 21)
;     RegisterKeymap("LAYER_ID", "Escape", "Exit Layer", LAYER_NAMEExit, false, 30)
;     RegisterKeymap("LAYER_ID", "?", "Toggle Help", LAYER_NAMEToggleHelp, false, 100)  ; Help system
;     ; ... more keymaps

; ==============================
; INTEGRATION CHECKLIST
; ==============================
; □ 1. Copy and rename this file to {layerName}_layer.ahk
; □ 2. Replace all LAYER_ID placeholders with lowercase identifier (e.g., "excel")
;       ⚠️ Do this FIRST to avoid confusion with LAYER_NAME!
; □ 3. Replace all LAYER_NAME placeholders with PascalCase name (e.g., "Excel")
; □ 4. Replace all LAYER_DISPLAY placeholders with display name (e.g., "Excel Layer")
; □ 5. Verify critical lines use LAYER_ID (lowercase):
;       - SwitchToLayer("LAYER_ID", ...) 
;       - ListenForLayerKeymaps("LAYER_ID", ...)
;       - RegisterKeymap("LAYER_ID", ...)
; □ 6. Implement layer-specific actions
; □ 7. Create action functions in src/actions/ if reusable
; □ 8. Register keymaps in config/keymap.ahk using lowercase LAYER_ID
;       - Include help keymap: RegisterKeymap("LAYER_ID", "?", "Toggle Help", LAYER_NAMEToggleHelp, false, 100)
; □ 9. Register layer activation in leader menu if needed:
;       RegisterKeymap("leader", "key", "LAYER_DISPLAY", ActivateLAYER_NAMELayer, false)
; □ 10. Test activation, keymaps, and deactivation
; □ 11. Test help system by pressing "?" while layer is active
