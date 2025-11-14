; ==============================
; EXCEL LAYER - Following Template Pattern
; ==============================
; Excel navigation layer using the standard template pattern
; Refactored to be consistent with other layers

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
    
    ; Show status tooltip (persistent indicator)
    try {
        ShowExcelLayerStatus(true)
        SetTempStatus("EXCEL LAYER ON", 1500)
    } catch Error as e {
        OutputDebug("[Excel] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (uses keymap_registry system)
    try {
        ListenForLayerKeymaps("excel", "isExcelLayerActive")
    } catch Error as e {
        OutputDebug("[Excel] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
}

OnExcelLayerDeactivate() {
    global isExcelLayerActive, ExcelHelpActive
    isExcelLayerActive := false
    
    ; Clean up help if active
    if (IsSet(ExcelHelpActive) && ExcelHelpActive) {
        try ExcelCloseHelp()
    }
    
    try ShowExcelLayerStatus(false)
    
    OutputDebug("[Excel] Layer deactivated")
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to this layer's control
; Generic/reusable actions should be in src/actions/

ExcelExit() {
    ; Note: Layer deactivation is handled by ReturnToPreviousLayer()
    try ReturnToPreviousLayer()
}

; ==============================
; HELP SYSTEM (Optional but Recommended)
; ==============================
; Dynamic help system that reads keymaps from KeymapRegistry
; Shows all registered keymaps for this layer with tooltips

global ExcelHelpActive := false

ExcelToggleHelp() {
    global ExcelHelpActive
    if (ExcelHelpActive)
        ExcelCloseHelp()
    else
        ExcelShowHelp()
}

ExcelShowHelp() {
    global tooltipConfig, ExcelHelpActive
    try HideCSharpTooltip()
    Sleep 30
    ExcelHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(ExcelHelpAutoClose, -to)
    
    ; Generate help dynamically from KeymapRegistry
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ; Use C# tooltip with dynamic items
            items := GenerateCategoryItemsForPath("excel")
            if (items = "")
                items := "[No keymaps registered for excel layer]"
            ShowBottomRightListTooltip("EXCEL LAYER HELP", items, "?: Close", to)
        } else {
            ; Fallback: native tooltip with dynamic text
            menuText := BuildMenuForPath("excel", "EXCEL LAYER HELP")
            if (menuText = "")
                menuText := "NO KEYMAPS REGISTERED"
            ShowCenteredToolTip(menuText)
        }
    } catch Error as e {
        OutputDebug("[Excel] ERROR showing help: " . e.Message)
        ShowCenteredToolTip("EXCEL LAYER HELP: See registered keymaps in config/keymap.ahk")
    }
}

ExcelHelpAutoClose() {
    global ExcelHelpActive
    if (ExcelHelpActive)
        ExcelCloseHelp()
}

ExcelCloseHelp() {
    global isExcelLayerActive, ExcelHelpActive
    try SetTimer(ExcelHelpAutoClose, 0)
    try HideCSharpTooltip()
    ExcelHelpActive := false
    if (isExcelLayerActive) {
        try ShowExcelLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}