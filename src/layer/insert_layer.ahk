; ==============================
; INSERT LAYER - Vim-style Insert Mode
; ==============================
; Generic insert mode layer that can be invoked from any other layer
; 
; FEATURES:
; - Minimal hotkeys (only ESC active)
; - All other keys pass through for normal typing
; - Clean exit back to origin layer
; - Vim-style insert behavior
;
; USAGE:
; - Call from any layer: SwitchToLayer("insert", "origin_layer")  
; - ESC returns to origin layer
; - All other typing works normally
;
; DEPENDENCIES:
; - Auto-loaded by auto_loader.ahk system
; - Self-contained insert mode behavior

; ==============================
; CONFIGURATION
; ==============================

global InsertLayerActive := false    ; Layer state

; ==============================
; LAYER HOTKEYS
; ==============================

#HotIf (InsertLayerActive)

; === EXIT INSERT MODE ===
Esc::ExitInsertLayer()

; === EMERGENCY EXIT ===
f::ExitInsertToBase()

; === HELP SYSTEM ===
+vkBF::ShowInsertHelp()
+SC035::ShowInsertHelp()
?::ShowInsertHelp()

#HotIf

; ==============================
; LAYER FUNCTIONS
; ==============================

; Called when entering insert layer
ActivateInsertLayer() {
    global InsertLayerActive
    
    InsertLayerActive := true
    
    ; Show insert mode status
    ShowInsertModeStatus(true)
    OutputDebug("[InsertLayer] Insert mode activated")
}

; Called when exiting insert layer  
DeactivateInsertLayer() {
    global InsertLayerActive
    
    InsertLayerActive := false
    
    ShowInsertModeStatus(false)
    OutputDebug("[InsertLayer] Insert mode deactivated")
}

; Exit insert and return to previous layer
ExitInsertLayer() {
    DeactivateInsertLayer()
    ReturnToPreviousLayer()
}

; Emergency exit to base state
ExitInsertToBase() {
    global CurrentActiveLayer, PreviousLayer
    DeactivateInsertLayer()
    CurrentActiveLayer := ""
    PreviousLayer := ""
    
    ShowCenteredToolTip("EXITED TO BASE")
    SetTimer(() => RemoveToolTip(), -800)
}

; ==============================
; UI FUNCTIONS
; ==============================

ShowInsertModeStatus(active) {
    if (active) {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("INSERT", "Insert Mode - ESC to exit")
        } else {
            ShowCenteredToolTip("INSERT MODE")
        }
    } else {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("INSERT", "Insert mode OFF")
        } else {
            ShowCenteredToolTip("INSERT OFF")
        }
    }
}

ShowInsertHelp() {
    helpText := "INSERT MODE HELP`n`n"
    helpText .= "BEHAVIOR:`n"
    helpText .= "Type normally - all keys pass through`n"
    helpText .= "Only ESC is intercepted for exit`n`n"
    helpText .= "EXIT:`n"
    helpText .= "Esc - Return to previous layer`n"
    helpText .= "f - Emergency exit to base`n`n"
    helpText .= "This is vim-style insert mode`n"
    helpText .= "where you type freely until ESC"
    
    ShowCenteredToolTip(helpText)
    SetTimer(() => RemoveToolTip(), -6000)
}

; ==============================
; LAYER INTEGRATION HOOKS
; ==============================

; These functions are called by the layer switching system
; from auto_loader.ahk

; Hook called when this layer is activated
OnInsertLayerActivate() {
    ActivateInsertLayer()
}

; Hook called when this layer is deactivated  
OnInsertLayerDeactivate() {
    DeactivateInsertLayer()
}