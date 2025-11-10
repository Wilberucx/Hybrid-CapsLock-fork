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

global scrollLayerEnabled := true      ; Feature flag
global scrollLayerActive := false      ; Layer state (managed by SwitchToLayer)

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
    global scrollLayerActive
    scrollLayerActive := true
    
    ; DEBUG: Log para verificar si se ejecuta
    OutputDebug("[SCROLL DEBUG] OnScrollLayerActivate() EJECUTÁNDOSE")
    
    try {
        ShowScrollLayerStatus(true)
        OutputDebug("[SCROLL DEBUG] ShowScrollLayerStatus(true) completado")
    } catch Error as e {
        OutputDebug("[SCROLL DEBUG] ERROR en ShowScrollLayerStatus: " . e.Message)
    }
    
    try SetTempStatus("SCROLL LAYER ON", 1500)
}

OnScrollLayerDeactivate() {
    global scrollLayerActive, ScrollHelpActive
    scrollLayerActive := false
    
    ; Clean up help if active
    if (IsSet(ScrollHelpActive) && ScrollHelpActive) {
        try ScrollCloseHelp()
    }
    
    try ShowScrollLayerStatus(false)
    try SetTempStatus("SCROLL LAYER OFF", 1500)
}

; ==============================
; HOTKEYS
; ==============================

#HotIf (scrollLayerEnabled ? (scrollLayerActive && !GetKeyState("CapsLock", "P")) : false)

; === SCROLL NAVIGATION (hjkl) ===
; Up / Down scroll
k::Send("{WheelUp}")
j::Send("{WheelDown}")

; Left / Right scroll  
h::Send("+{WheelUp}")
l::Send("+{WheelDown}")

; === LAYER EXIT ===
; Exit with 's' key (toggle behavior)
s:: {
    try ReturnToPreviousLayer()
}

; Exit with Escape (consistent with other layers)
*Esc:: {
    try ReturnToPreviousLayer()
}

; === HELP SYSTEM ===
; Help toggle with '?' (multiple keycodes for compatibility)
+vkBF:: (ScrollHelpActive ? ScrollCloseHelp() : ScrollShowHelp())
+SC035:: (ScrollHelpActive ? ScrollCloseHelp() : ScrollShowHelp())
?:: (ScrollHelpActive ? ScrollCloseHelp() : ScrollShowHelp())

#HotIf

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
    global scrollLayerActive, ScrollHelpActive
    try SetTimer(ScrollHelpAutoClose, 0)
    try HideCSharpTooltip()
    ScrollHelpActive := false
    if (scrollLayerActive) {
        try ShowScrollLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}

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

