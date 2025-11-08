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
; - vim_visual.ahk: Proper visual selection functions 
; - Auto-loaded by auto_loader.ahk system
; - Uses vim-style selection behavior


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
*h::VimVisualMoveLeft()
*j::VimVisualMoveDown() 
*k::VimVisualMoveUp()
*l::VimVisualMoveRight()

; Alt-modified combos (avoid menu conflicts)
*!h::VimVisualMoveLeft()
*!j::VimVisualMoveDown()
*!k::VimVisualMoveUp() 
*!l::VimVisualMoveRight()

; === LINE NAVIGATION ===
0::VimVisualStartOfLine()    ; Start of line
+4::VimVisualEndOfLine()     ; End of line (Shift+4 = $)

; === WORD NAVIGATION ===
w::VimVisualWordForward()    ; Next word
b::VimVisualWordBackward()   ; Previous word  
e::VimVisualEndOfWord()      ; End of current word

; === DOCUMENT NAVIGATION ===
g::VimVisualTopOfFile()      ; Top of document
+g::VimVisualBottomOfFile()  ; Bottom of document (Shift+G)

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
a::Send("^a")

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
    VisualSelection := true
    
    ; Visual mode starts immediately - user navigation will extend selection
    ; No initial selection needed - first movement will start it
    
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
; VISUAL SELECTION HELPERS
; ==============================
; All movement functions are now handled by vim_visual.ahk
; This layer only manages the layer state and integration

; ==============================
; UI FUNCTIONS
; ==============================

; ShowVisualModeStatus is defined globally in src/ui/tooltips_native_wrapper.ahk

ShowVisualHelp() {
    helpText := "VISUAL MODE HELP`n`n"
    helpText .= "SELECTION NAVIGATION (vim-style):`n"
    helpText .= "h/j/k/l - Move with selection`n"
    helpText .= "w/b/e - Word-based selection`n" 
    helpText .= "0/$ - Line start/end selection`n"
    helpText .= "g/G - Document start/end selection`n`n"
    helpText .= "OPERATIONS:`n"
    helpText .= "d - Delete selection & exit`n"
    helpText .= "y - Copy selection & exit`n"
    helpText .= "c - Change (delete + insert)`n"
    helpText .= "x - Cut selection & exit`n"
    helpText .= "p/P - Paste & exit`n"
    helpText .= "a - Select all`n`n"
    helpText .= "EXIT:`n"
    helpText .= "Esc - Return to previous layer`n"
    helpText .= "f - Emergency exit to base`n`n"
    helpText .= "Uses vim_visual.ahk for proper selection behavior"
    
    ShowCenteredToolTip(helpText)
    SetTimer(() => RemoveToolTip(), -10000)
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
