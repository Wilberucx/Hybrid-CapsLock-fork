; ==============================
; SCROLL LAYER - Refactored with SwitchToLayer Support
; ==============================
; Vim-like scroll navigation layer compatible with the layer switching system
;
; FEATURES:
; - Scroll navigation (hjkl) 
; - Invokable from any layer via SwitchToLayer("scroll", "origin_layer")
; - Direct activation function: ActivateScrollLayer()
; - Help system (?)
; - Exit with 's' or ESC
;
; USAGE:
; - From any layer: SwitchToLayer("scroll", "origin_layer")
; - Direct activation: ActivateScrollLayer() 
; - ESC returns to previous layer or base state
;
; DEPENDENCIES:
; - Auto-loaded by auto_loader.ahk system
; - Uses SwitchToLayer infrastructure

; ==============================
; CONFIGURATION
; ==============================

global scrollLayerEnabled := true        ; Feature flag
global isScrollLayerActive := false      ; Layer state (managed by SwitchToLayer)
                                          ; Renamed to isScrollLayerActive for consistency

; ==============================
; ACTIVATION FUNCTION (for easy invocation)
; ==============================

ActivateScrollLayer(originLayer := "leader") {
    ; DEBUG: Log para verificar si se ejecuta
    OutputDebug("[SCROLL DEBUG] ActivateScrollLayer() llamado con originLayer: " . originLayer)
    
    ; Use SwitchToLayer for consistent behavior
    result := SwitchToLayer("scroll", originLayer)
    
    OutputDebug("[SCROLL DEBUG] SwitchToLayer result: " . (result ? "true" : "false"))
    return result
}

; ==============================
; ACTIVATION/DEACTIVATION HOOKS (called by auto_loader.ahk)
; ==============================

OnScrollLayerActivate() {
    global isScrollLayerActive
    isScrollLayerActive := true
    
    OutputDebug("[ScrollLayer] OnScrollLayerActivate() - Activating layer")
    
    ; Show status
    try {
        ShowScrollLayerStatus(true)
        SetTempStatus("SCROLL LAYER ON", 1500)
    } catch Error as e {
        OutputDebug("[ScrollLayer] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (reuses keymap_registry system)
    ; This replaces the #HotIf blocks - keymaps are now registered and executed dynamically
    try {
        ListenForLayerKeymaps("scroll", "isScrollLayerActive")
    } catch Error as e {
        OutputDebug("[ScrollLayer] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
    
    ; When listener exits, deactivate layer
    isScrollLayerActive := false
    try {
        ShowScrollLayerStatus(false)
        SetTempStatus("SCROLL LAYER OFF", 1500)
    }
}

OnScrollLayerDeactivate() {
    global isScrollLayerActive, ScrollHelpActive
    isScrollLayerActive := false
    
    ; Clean up help if active
    if (IsSet(ScrollHelpActive) && ScrollHelpActive) {
        try ScrollCloseHelp()
    }
    
    try ShowScrollLayerStatus(false)
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to scroll layer control
; Generic scroll actions (ScrollUp, ScrollDown, etc.) are in src/actions/scroll_actions.ahk

ScrollExit() {
    global isScrollLayerActive
    isScrollLayerActive := false
    try ReturnToPreviousLayer()
}

ScrollToggleHelp() {
    global ScrollHelpActive
    if (ScrollHelpActive)
        ScrollCloseHelp()
    else
        ScrollShowHelp()
}

; ==============================
; HELP SYSTEM IMPLEMENTATION
; ==============================

; Help routines
global ScrollHelpActive := false

ScrollShowHelp() {
    global tooltipConfig, ScrollHelpActive
    try HideCSharpTooltip()
    Sleep 30
    ScrollHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(ScrollHelpAutoClose, -to)
    try ShowScrollHelpCS()
}

ScrollHelpAutoClose() {
    global ScrollHelpActive
    if (ScrollHelpActive)
        ScrollCloseHelp()
}

ScrollCloseHelp() {
    global isScrollLayerActive, ScrollHelpActive
    try SetTimer(ScrollHelpAutoClose, 0)
    try HideCSharpTooltip()
    ScrollHelpActive := false
    if (isScrollLayerActive) {
        try ShowScrollLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}

; ==============================
; KEYMAP REGISTRATION (RegisterKeymap system)
; ==============================
; Register all scroll layer keymaps - SINGLE SOURCE OF TRUTH
; These are executed by ListenForLayerKeymaps() which uses ExecuteKeymapAtPath()

; RegisterScrollKeymaps() {
;     ; Scroll navigation
;     RegisterKeymap("scroll", "k", "Scroll Up", ScrollUp, false, 1)
;     RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false, 2)
;     RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false, 3)
;     RegisterKeymap("scroll", "l", "Scroll Right", ScrollRight, false, 4)
;
;     ; Layer control
;     RegisterKeymap("scroll", "s", "Exit Scroll Layer", ScrollExit, false, 10)
;     RegisterKeymap("scroll", "Escape", "Exit Scroll Layer", ScrollExit, false, 11)
;
;     ; Help system
;     RegisterKeymap("scroll", "?", "Toggle Help", ScrollToggleHelp, false, 20)
;
;     OutputDebug("[ScrollLayer] Keymaps registered successfully")
; }

; ==============================
; TEMPORARY DEBUG HOTKEY (REMOVE AFTER TESTING)
; ==============================

; Test hotkey: Ctrl+Shift+S para probar ActivateScrollLayer directamente
^+s:: {
    OutputDebug("[SCROLL DEBUG] Manual test hotkey pressed - calling ActivateScrollLayer()")
    ActivateScrollLayer("manual_test")
}

; ==============================
; REFACTORING NOTES
; ==============================
; Cambios principales del refactor:
; 1. COMPATIBLE CON SwitchToLayer(): Ahora se puede invocar desde cualquier layer
; 2. FUNCIÓN DE ACTIVACIÓN: ActivateScrollLayer(originLayer) para invocación fácil
; 3. HOOKS DE ACTIVACIÓN: OnScrollLayerActivate/OnScrollLayerDeactivate para auto_loader.ahk
; 4. SALIDA CONSISTENTE: ESC y 's' usan ReturnToPreviousLayer() como otros layers
; 5. ESTRUCTURA MODULAR: Comentarios organizadores como nvim_layer.ahk
; 6. GESTIÓN DE ESTADO: scrollLayerActive manejado por el sistema SwitchToLayer
;
; USAGE EXAMPLES:
; - From any layer: SwitchToLayer("scroll", "nvim")
; - From leader: ActivateScrollLayer("leader") 
; - From anywhere: ActivateScrollLayer()  // defaults to "leader"
;
; INTEGRATION:
; - El layer se auto-registra en LayerRegistry como "scroll"
; - Compatible con todo el ecosystem de layer switching
; - Mantiene toda la funcionalidad original (hjkl, help, tooltips)

