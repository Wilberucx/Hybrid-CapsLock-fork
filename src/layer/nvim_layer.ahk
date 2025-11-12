; ==============================
; NVIM LAYER - Unified Keymap System
; ==============================
; Vim-like navigation layer using RegisterKeymap() and ListenForLayerKeymaps()
;
; FEATURES:
; - Toggle ON/OFF con F23 (tap CapsLock from Kanata)
; - Basic vim navigation (hjkl, word jumps, document navigation)
; - Edit operations (yank, paste, undo, redo)
; - Integration with visual_layer and insert_layer
; - Help system
;
; DEPENDENCIES:
; - vim_nav.ahk: Navegación básica reutilizable
; - vim_edit.ahk: Operaciones de edición
; - nvim_layer_helpers.ahk: Helper functions
;
; COMPLEX LOGIC REMOVED:
; - ColonLogic (:w, :q, :wq) - Moved to no_include/nvim_layer_LEGACY.ahk
; - GLogic (gg for top) - Moved to no_include/nvim_layer_LEGACY.ahk
; - Conditional key behavior - Simplified
;
; NOTE: This is a CLEAN implementation following the layer template pattern

; ==============================
; CONFIGURATION
; ==============================

global nvimLayerEnabled := true          ; Feature flag
global isNvimLayerActive := false        ; Layer state
global nvimStaticEnabled := true         ; Legacy: static vs dynamic hotkeys

; ==============================
; ACTIVATION FUNCTION (Toggle)
; ==============================
; NOTE: Nvim uses TOGGLE instead of simple activation
; F23 (from Kanata) toggles the layer on/off

ActivateNvimLayer() {
    global isNvimLayerActive
    
    ; Toggle layer
    isNvimLayerActive := !isNvimLayerActive
    
    OutputDebug("[Nvim] ActivateNvimLayer() - Toggling to: " . (isNvimLayerActive ? "ON" : "OFF"))
    
    if (isNvimLayerActive) {
        OnNvimLayerActivate()
    } else {
        OnNvimLayerDeactivate()
    }
}

; ==============================
; ACTIVATION/DEACTIVATION HOOKS
; ==============================

OnNvimLayerActivate() {
    global isNvimLayerActive
    isNvimLayerActive := true
    
    OutputDebug("[Nvim] OnNvimLayerActivate() - Activating layer")
    
    ; Show status
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimLayerToggleCS(true)
        } else {
            ShowNvimLayerStatus(true)
            SetTempStatus("NVIM LAYER ON", 1500)
        }
    } catch Error as e {
        OutputDebug("[Nvim] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (uses keymap_registry system)
    try {
        ListenForLayerKeymaps("nvim", "isNvimLayerActive")
    } catch Error as e {
        OutputDebug("[Nvim] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
    
    ; When listener exits, deactivate layer
    isNvimLayerActive := false
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimLayerToggleCS(false)
        } else {
            ShowNvimLayerStatus(false)
            SetTempStatus("NVIM LAYER OFF", 1500)
        }
    }
    
    try SaveLayerState()
}

OnNvimLayerDeactivate() {
    global isNvimLayerActive
    isNvimLayerActive := false
    
    ; Clean up
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimLayerToggleCS(false)
        } else {
            ShowNvimLayerStatus(false)
        }
    }
    
    try SaveLayerState()
    
    OutputDebug("[Nvim] Layer deactivated")
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to nvim layer control
; Generic vim actions (VimMoveLeft, VimYank, etc.) are in src/actions/

; Exit nvim layer (quick exit with 'f')
NvimExit() {
    global isNvimLayerActive
    isNvimLayerActive := false
    Send("^!+2")  ; Additional behavior (if needed)
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
; HELP SYSTEM (Dynamic from KeymapRegistry)
; ==============================
; Help is generated dynamically from registered keymaps

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
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled)
                ShowNvimLayerToggleCS(true)
            else
                ShowNvimLayerStatus(true)
        }
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
