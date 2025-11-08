; ==============================
; VISUAL LAYER - Independent Visual Mode
; ==============================
; Generic visual selection layer that can be invoked from any other layer
; 
; FEATURES:
; - Text selection with hjkl navigation
; - Word-level selection (w/b/e)
; - Line operations (0/$)
; - Edit operations (d/y/c/x)
; - Select all (a)
; - Context-aware behavior
;
; USAGE:
; - Call from any layer: SwitchToLayer("visual", "origin_layer")  
; - ESC returns to origin layer or base state
; - All edit operations exit visual and return to origin
;
; DEPENDENCIES:
; - Auto-loaded by auto_loader.ahk system
; - Uses existing global functions from actions (if available)
; - Self-contained where functions don't exist

; ==============================
; CONFIGURATION
; ==============================

global VisualLayerActive := false    ; Layer state
global VisualSelection := false      ; Selection state
global VisualHelpActive := false     ; Help menu state

; ==============================
; LAYER HOTKEYS
; ==============================

#HotIf (VisualLayerActive)

; === BASIC NAVIGATION (with selection) ===
*h::VisualMove("Left")
*j::VisualMove("Down") 
*k::VisualMove("Up")
*l::VisualMove("Right")

; Alt-modified combos (avoid menu conflicts)
*!h::VisualMove("Left")
*!j::VisualMove("Down")
*!k::VisualMove("Up") 
*!l::VisualMove("Right")

; === LINE NAVIGATION ===
0::VisualMove("Home")        ; Start of line
+4::VisualMove("End")        ; End of line (Shift+4 = $)

; === WORD NAVIGATION ===
w::VisualMove("^Right")      ; Next word
b::VisualMove("^Left")       ; Previous word  
e::VisualMoveEndOfWord()     ; End of current word

; === DOCUMENT NAVIGATION ===
g::VisualMove("^Home")       ; Top of document
+g::VisualMove("^End")       ; Bottom of document (Shift+G)

; === EDIT OPERATIONS (exit visual after operation) ===
d:: {
    Send("{Delete}")
    ExitVisualLayer()
}

y:: {
    Send("^c")  ; Copy selection
    ShowCopyNotification()
    ExitVisualLayer()
}

c:: {
    Send("{Delete}")
    SwitchToInsertMode()
}

x:: {
    Send("^x")  ; Cut
    ExitVisualLayer()
}

p:: {
    Send("^v")  ; Paste
    ExitVisualLayer()
}

+p:: {
    Send("^v")  ; Paste (plain)
    ExitVisualLayer()
}

; === SELECT ALL ===
a:: {
    global VisualSelection
    Send("^a")
    VisualSelection := true
    ShowVisualModeStatus(true)
}

; === EXIT VISUAL MODE ===
Esc::ExitVisualLayer()

; === EXIT TO BASE (emergency) ===
f::ExitToBase()

; === HELP SYSTEM ===
+vkBF::ShowVisualHelp()
+SC035::ShowVisualHelp()
?::ShowVisualHelp()

#HotIf

; ==============================
; LAYER FUNCTIONS
; ==============================

; Called when entering visual layer
ActivateVisualLayer() {
    global VisualLayerActive, VisualSelection
    
    VisualLayerActive := true
    VisualSelection := false
    
    ; Start selection at current position
    Send("+{Right}")    ; Start selection
    Send("{Left}")      ; Reset to original position but keep selection active
    VisualSelection := true
    
    ShowVisualModeStatus(true)
    OutputDebug("[VisualLayer] Visual mode activated")
}

; Called when exiting visual layer  
DeactivateVisualLayer() {
    global VisualLayerActive, VisualSelection
    
    VisualLayerActive := false
    VisualSelection := false
    
    ; Clear any selection
    Send("{Right}{Left}")
    
    ShowVisualModeStatus(false)
    OutputDebug("[VisualLayer] Visual mode deactivated")
}

; Exit visual and return to previous layer
ExitVisualLayer() {
    DeactivateVisualLayer()
    ReturnToPreviousLayer()
}

; Exit visual and switch to insert mode (for 'c' command)
SwitchToInsertMode() {
    global
    DeactivateVisualLayer()
    
    ; TODO: Implement generic insert mode or return to origin with insert flag
    ; For now, just return to previous layer
    ReturnToPreviousLayer()
    
    ; Show insert notification
    ShowCenteredToolTip("INSERT MODE")
    SetTimer(() => RemoveToolTip(), -1000)
}

; Emergency exit to base state
ExitToBase() {
    global CurrentActiveLayer, PreviousLayer
    DeactivateVisualLayer()
    CurrentActiveLayer := ""
    PreviousLayer := ""
    
    ShowCenteredToolTip("EXITED TO BASE")
    SetTimer(() => RemoveToolTip(), -800)
}

; ==============================
; VISUAL MOVEMENT FUNCTIONS
; ==============================

VisualMove(direction) {
    global VisualSelection
    
    if (!VisualSelection) {
        ; Start selection
        VisualSelection := true
        Send("+" . GetMovementKey(direction))
    } else {
        ; Continue selection
        Send("+" . GetMovementKey(direction))
    }
}

VisualMoveEndOfWord() {
    global VisualSelection
    
    if (!VisualSelection) {
        VisualSelection := true
        Send("+^{Right}")
        Send("+{Left}")  ; Adjust for end of word
    } else {
        Send("+^{Right}")
        Send("+{Left}")
    }
}

GetMovementKey(direction) {
    switch direction {
        case "Left": return "{Left}"
        case "Right": return "{Right}"
        case "Up": return "{Up}"
        case "Down": return "{Down}"
        case "Home": return "{Home}"
        case "End": return "{End}"
        case "^Left": return "^{Left}"
        case "^Right": return "^{Right}" 
        case "^Home": return "^{Home}"
        case "^End": return "^{End}"
        default: return "{Right}"
    }
}

; ==============================
; UI FUNCTIONS
; ==============================

; ShowVisualModeStatus is defined globally in src/ui/tooltips_native_wrapper.ahk

ShowVisualHelp() {
    helpText := "VISUAL MODE HELP`n`n"
    helpText .= "NAVIGATION:`n"
    helpText .= "h/j/k/l - Move with selection`n"
    helpText .= "w/b/e - Word navigation`n" 
    helpText .= "0/$ - Line start/end`n"
    helpText .= "g/G - Document start/end`n`n"
    helpText .= "OPERATIONS:`n"
    helpText .= "d - Delete selection`n"
    helpText .= "y - Copy selection`n"
    helpText .= "c - Change (delete + insert)`n"
    helpText .= "x - Cut selection`n"
    helpText .= "p/P - Paste`n"
    helpText .= "a - Select all`n`n"
    helpText .= "EXIT:`n"
    helpText .= "Esc - Return to previous layer`n"
    helpText .= "f - Emergency exit to base"
    
    ShowCenteredToolTip(helpText)
    SetTimer(() => RemoveToolTip(), -8000)
}

; ==============================
; LAYER INTEGRATION HOOKS
; ==============================

; These functions are called by the layer switching system
; from auto_loader.ahk

; Hook called when this layer is activated
OnVisualLayerActivate() {
    ActivateVisualLayer()
}

; Hook called when this layer is deactivated  
OnVisualLayerDeactivate() {
    DeactivateVisualLayer()
}

; ==============================
; BASIC UTILITY FUNCTIONS
; ==============================
; Note: ShowCopyNotification, ShowCenteredToolTip, and RemoveToolTip are defined globally
; in src/ui/tooltips_native_wrapper.ahk