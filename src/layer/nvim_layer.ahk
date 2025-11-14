; ==============================
; NVIM LAYER - Following Template Pattern  
; ==============================
; Vim-like navigation layer using the standard template pattern
; Refactored to be consistent with other layers

; ==============================
; CONFIGURATION
; ==============================

global NvimLayerEnabled := true          ; Feature flag
global isNvimLayerActive := false        ; Layer state (managed by SwitchToLayer)

; ==============================
; ACTIVATION FUNCTION
; ==============================

ActivateNvimLayer(originLayer := "leader") {
    OutputDebug("[Nvim] ActivateNvimLayer() called with originLayer: " . originLayer)
    result := SwitchToLayer("nvim", originLayer)
    OutputDebug("[Nvim] SwitchToLayer result: " . (result ? "true" : "false"))
    return result
}

; ==============================
; ACTIVATION/DEACTIVATION HOOKS
; ==============================

OnNvimLayerActivate() {
    global isNvimLayerActive
    isNvimLayerActive := true
    
    OutputDebug("[Nvim] OnNvimLayerActivate() - Activating layer")
    
    ; Show status tooltip (persistent indicator)
    try {
        ShowNvimLayerStatus(true)
        SetTempStatus("NVIM LAYER ON", 1500)
    } catch Error as e {
        OutputDebug("[Nvim] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (uses keymap_registry system)
    try {
        ListenForLayerKeymaps("nvim", "isNvimLayerActive")
    } catch Error as e {
        OutputDebug("[Nvim] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
}

OnNvimLayerDeactivate() {
    global isNvimLayerActive, NvimHelpActive
    isNvimLayerActive := false
    
    ; Clean up help if active
    if (IsSet(NvimHelpActive) && NvimHelpActive) {
        try NvimCloseHelp()
    }
    
    try ShowNvimLayerStatus(false)
    
    OutputDebug("[Nvim] Layer deactivated")
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to this layer's control
; Generic/reusable actions should be in src/actions/

NvimExit() {
    ; Note: Layer deactivation is handled by ReturnToPreviousLayer()
    try ReturnToPreviousLayer()
}

; NVIM-SPECIFIC: Legacy behavior for compatibility
NvimLegacyExit() {
    ; Note: Layer deactivation is handled by the layer system
    Send("^!+2")  ; Additional behavior (if needed)
    try ReturnToPreviousLayer()
}

; Yank with notification
NvimYankWithNotification() {
    VimYank()
    ShowCopyNotification()
}

; Insert at beginning of line (I command)
NvimInsertAtBeginning() {
    SwitchToLayer("insert", "nvim")
    Send("^!+i")
}

; ==============================
; HELP SYSTEM (Optional but Recommended)
; ==============================
; Dynamic help system that reads keymaps from KeymapRegistry
; Shows all registered keymaps for this layer with tooltips

global NvimHelpActive := false

NvimToggleHelp() {
    global NvimHelpActive
    if (NvimHelpActive)
        NvimCloseHelp()
    else
        NvimShowHelp()
}

NvimShowHelp() {
    global tooltipConfig, NvimHelpActive
    try HideCSharpTooltip()
    Sleep 30
    NvimHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(NvimHelpAutoClose, -to)
    
    ; Generate help dynamically from KeymapRegistry
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ; Use C# tooltip with dynamic items
            items := GenerateCategoryItemsForPath("nvim")
            if (items = "")
                items := "[No keymaps registered for nvim layer]"
            ShowCSharpOptionsMenu("NVIM LAYER HELP", items, "?: Close Help")
        } else {
            ; Fallback: native tooltip with dynamic text
            menuText := BuildMenuForPath("nvim", "NVIM LAYER HELP")
            if (menuText = "")
                menuText := "NO KEYMAPS REGISTERED"
            ShowCenteredToolTip(menuText)
        }
    } catch Error as e {
        OutputDebug("[Nvim] ERROR showing help: " . e.Message)
        ShowCenteredToolTip("NVIM HELP: See registered keymaps in config/keymap.ahk")
    }
}

NvimHelpAutoClose() {
    global NvimHelpActive
    if (NvimHelpActive)
        NvimCloseHelp()
}

NvimCloseHelp() {
    global isNvimLayerActive, NvimHelpActive
    try SetTimer(NvimHelpAutoClose, 0)
    try HideCSharpTooltip()
    NvimHelpActive := false
    if (isNvimLayerActive) {
        try ShowNvimLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}


; ==============================
; KEYMAP REGISTRATION
; ==============================
; Keymaps are registered in config/keymap.ahk
; See InitializeCategoryKeymaps() → RegisterNvimKeymaps()
;
; This keeps all keymaps centralized in one place
