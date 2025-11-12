; ==============================
; LAYER TEMPLATE - Dynamic Layer Creation Pattern
; ==============================
; This is a template for creating new persistent layers
; 
; INSTRUCTIONS:
; 1. Copy this file to a new file: {layerName}_layer.ahk
; 2. Replace LAYER_NAME with your layer name (e.g., "scroll", "nvim", "excel")
; 3. Replace LAYER_DISPLAY with friendly name (e.g., "Scroll Layer", "Nvim Layer")
; 4. Implement your layer-specific actions
; 5. Register keymaps in config/keymap.ahk
;
; EXAMPLE:
;   LAYER_NAME = "scroll"
;   LAYER_DISPLAY = "Scroll Layer"
;   → scrollLayerEnabled
;   → isScrollLayerActive
;   → ActivateScrollLayer()
;   → OnScrollLayerActivate()
;   → OnScrollLayerDeactivate()

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
    result := SwitchToLayer("LAYER_NAME", originLayer)
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
        ListenForLayerKeymaps("LAYER_NAME", "isLAYER_NAMELayerActive")
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
; KEYMAP REGISTRATION
; ==============================
; Register in config/keymap.ahk:
;
; RegisterLAYER_NAMEKeymaps() {
;     ; Basic actions
;     RegisterKeymap("LAYER_NAME", "key", "Description", ActionFunction, false, 1)
;     
;     ; Layer control
;     RegisterKeymap("LAYER_NAME", "Escape", "Exit Layer", LAYER_NAMEExit, false, 10)
;     
;     OutputDebug("[LAYER_NAME] Keymaps registered successfully")
; }
;
; Then call RegisterLAYER_NAMEKeymaps() in InitializeCategoryKeymaps()

; ==============================
; INTEGRATION CHECKLIST
; ==============================
; □ 1. Copy and rename this file to {layerName}_layer.ahk
; □ 2. Replace all LAYER_NAME placeholders with actual layer name
; □ 3. Replace all LAYER_DISPLAY placeholders with display name
; □ 4. Implement layer-specific actions
; □ 5. Create action functions in src/actions/ if reusable
; □ 6. Register keymaps in config/keymap.ahk
; □ 7. Register layer activation in leader menu if needed:
;       RegisterKeymap("leader", "key", "LAYER_DISPLAY", ActivateLAYER_NAMELayer, false)
; □ 8. Test activation, keymaps, and deactivation
