
; ==============================
; CONFIGURATION
; ==============================

global ExcelLayerEnabled := true          ; Feature flag
global isExcelLayerActive := false        ; Layer state (managed by SwitchToLayer)

; ==============================
; ACTIVATION FUNCTION
; ==============================

ActivateExcelLayer(originLayer := "leader") {
    OutputDebug("[Excel] ActivateExcelLayer() called with originLayer: " . originLayer)
    result := SwitchToLayer("excel", originLayer)
    OutputDebug("[Excel] SwitchToLayer result: " . (result ? "true" : "false"))
    return result
}

; ==============================
; ACTIVATION/DEACTIVATION HOOKS
; ==============================

OnExcelLayerActivate() {
    global isExcelLayerActive
    isExcelLayerActive := true
    
    OutputDebug("[Excel] OnExcelLayerActivate() - Activating layer")
    
    ; Show status (optional - implement ShowExcelLayerStatus if needed)
    try {
        ; ShowExcelLayerStatus(true)
        SetTempStatus("EXCEL ON", 1500)
    } catch Error as e {
        OutputDebug("[Excel] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (uses keymap_registry system)
    try {
        ListenForLayerKeymaps("excel", "isExcelLayerActive")
    } catch Error as e {
        OutputDebug("[Excel] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
    
    ; When listener exits, deactivate layer
    isExcelLayerActive := false
    try {
        ; ShowExcelLayerStatus(false)
        SetTempStatus("EXCEL OFF", 1500)
    }
}

OnExcelLayerDeactivate() {
    global isExcelLayerActive
    isExcelLayerActive := false
    
    ; Clean up any layer-specific state here
    OutputDebug("[Excel] Layer deactivated")
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to this layer's control
; Generic/reusable actions should be in src/actions/

ExcelExit() {
    global isExcelLayerActive
    isExcelLayerActive := false
    try ReturnToPreviousLayer()
}

; Add your layer-specific action functions here
; Example:
; ExcelDoSomething() {
;     ; Implementation
; }

; ==============================
; KEYMAP REGISTRATION
; ==============================
; Register in config/keymap.ahk:
;
; RegisterExcelKeymaps() {
;     ; Basic actions
;     RegisterKeymap("excel", "h", "Move Left", VimMoveLeft, false, 20)
;     RegisterKeymap("excel", "j", "Move Down", VimMoveDown, false, 21)
;     RegisterKeymap("excel", "k", "Move Up", VimMoveUp, false, 22)
;     RegisterKeymap("excel", "l", "Move Right", VimMoveRight, false, 23)
;     RegisterCategoryKeymap("excel", "g", "Go to", 1)
;     RegisterKeymap("excel", "g", "g", "Go to Top", VimTopOfFile, false, 41)
;     RegisterKeymap("excel", "G", "Go to Bottom", VimBottomOfFile, false, 41)
;     RegisterKeymap("excel", "p", "Paste", VimPaste, false, 52)
;     RegisterKeymap("excel", "u", "Undo", VimUndo, false, 55)
;     RegisterKeymap("excel", "r", "Redo", VimRedo, false, 56)
;     RegisterKeymap("excel", "Escape", "Exit", ExcelExit, false, 72)
;
;     OutputDebug("[Excel] Keymaps registered successfully")
; }
;
; Then call RegisterExcelKeymaps() in InitializeCategoryKeymaps()

; ==============================
; INTEGRATION CHECKLIST
; ==============================
; □ 1. Copy and rename this file to {layerName}_layer.ahk
; □ 2. Replace all Excel placeholders with actual layer name
; □ 3. Replace all EXCEL placeholders with display name
; □ 4. Implement layer-specific actions
; □ 5. Create action functions in src/actions/ if reusable
; □ 6. Register keymaps in config/keymap.ahk
; □ 7. Register layer activation in leader menu if needed:
;       RegisterKeymap("leader", "key", "EXCEL", ActivateExcelLayer, false)
; □ 8. Test activation, keymaps, and deactivation
