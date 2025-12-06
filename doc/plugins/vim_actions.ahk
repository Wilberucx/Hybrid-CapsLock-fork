; ==============================
; Vim Actions Plugin 
; ==============================
; Combines Navigation, Visual Mode, and Edit Operations.
; Includes Layer Definitions and Keymaps.

; ==============================
; LAYER REGISTRATION
; ==============================
; Vim layers with passthrough mode (false = no suprimir teclas no mapeadas)
; Solo interceptamos teclas específicas, el resto pasa a la aplicación
RegisterLayer("vim", "VIM MODE", "#7F9C5D", "#ffffff")
RegisterLayer("vim_visual", "VISUAL MODE", "#ffafcc", "#000000")
RegisterLayer("vim_insert", "INSERT MODE", "#d0f0c0", "#000000", false)

; ==============================
; MODE SWITCHING FUNCTIONS
; ==============================

ToggleVimMode() {
    SwitchToLayer("vim")
}

EnterVisualMode() {
    SwitchToLayer("vim_visual")
}

ExitVisualMode() {
    SwitchToLayer("vim")
}

ExitVimMode() {
    DeactivateLayer("vim")
}

; ==============================
; 1. NAVIGATION (Normal Mode)
; ==============================

; --- Basic Movement (hjkl) ---
VimMoveLeft() {
    Send("{Left}")
}

VimMoveDown() {
    Send("{Down}")
}

VimMoveUp() {
    Send("{Up}")
}

VimMoveRight() {
    Send("{Right}")
}

; --- Word Movement (w/b/e) ---
VimWordForward() {
    Send("^{Right}")
}

VimWordBackward() {
    Send("^{Left}")
}

VimEndOfWord() {
    Send("^{Right}")
    Send("{Left}")
}

; --- Line Movement (0/$) ---
VimStartOfLine() {
    Send("{Home}")
}

VimEndOfLine() {
    Send("{End}")
}

; --- Document Movement (gg/G) ---
VimTopOfFile() {
    Send("^{Home}")
}

VimBottomOfFile() {
    Send("^{End}")
}

; --- Page Movement (Ctrl+d/u) ---
VimPageDown() {
    Send("{PgDn}")
}

VimPageUp() {
    Send("{PgUp}")
}

VimHalfPageDown() {
    Loop 10
        Send("{Down}")
}

VimHalfPageUp() {
    Loop 10
        Send("{Up}")
}

; --- Screen Movement (H/L) ---
VimScreenTop() {
    Send("{PgUp}")
    Send("{Home}")
}

VimScreenBottom() {
    Send("{PgDn}")
    Send("{End}")
}

; ==============================
; 2. VISUAL MODE (Selection)
; ==============================

; --- Basic Selection (Shift+hjkl) ---
VimVisualMoveLeft() {
    Send("+{Left}")
}

VimVisualMoveDown() {
    Send("+{Down}")
}

VimVisualMoveUp() {
    Send("+{Up}")
}

VimVisualMoveRight() {
    Send("+{Right}")
}

; --- Word Selection (Shift+w/b/e) ---
VimVisualWordForward() {
    Send("+^{Right}")
}

VimVisualWordBackward() {
    Send("+^{Left}")
}

VimVisualEndOfWord() {
    Send("+^{Right}")
    Send("+{Left}")
}

; --- Line Selection (Shift+0/$) ---
VimVisualStartOfLine() {
    Send("+{Home}")
}

VimVisualEndOfLine() {
    Send("+{End}")
}

; --- Document Selection (Shift+gg/G) ---
VimVisualTopOfFile() {
    Send("+^{Home}")
}

VimVisualBottomOfFile() {
    Send("+^{End}")
}

; --- Page Selection ---
VimVisualPageDown() {
    Send("+{PgDn}")
}

VimVisualPageUp() {
    Send("+{PgUp}")
}

; --- Visual Line Mode (V) ---
VimVisualLineDown() {
    Send("+{Down}")
    Send("+{Home}")
}

VimVisualLineUp() {
    Send("+{Up}")
    Send("+{Home}")
}

; --- Selection Objects ---
VimVisualInsideWord() {
    Send("^{Left}")
    Send("+^{Right}")
}

VimVisualAroundWord() {
    Send("^{Left}")
    Send("+^{Right}")
    Send("+{Space}")
}

; ==============================
; 3. EDIT OPERATIONS
; ==============================

; --- Clipboard (y/d/p) ---
VimYank() {
    Send("^c")
    ExitVisualMode() ; Usually yank exits visual mode
}

VimYankLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^c")
    Send("{Down}")
    Send("{Home}")
}

VimYankEndLine() {
    Send("+{End}")
    Send("^c")
    Send("{Left}")
}

VimYankStartLine() {
    Send("+{Home}")
    Send("^c")
    Send("{Right}")
}

VimDelete() {
    Send("{delete}")
}

VimCut() {
    Send("^x")
}

VimVisualDelete() {
    Send("delete")
    ExitVisualMode() ; Usually delete exits visual mode
}

VimVisualCut() {
    Send("^x")
    ExitVisualMode() ; Usually delete exits visual mode
}

VimDeleteLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^x")
}

VimDeleteToEndOfLine() {
    Send("+{End}")
    Send("^x")
}

VimPaste() {
    Send("^v")
}

VimPasteBefore() {
    Send("{Left}")
    Send("^v")
}

; --- Undo/Redo (u/Ctrl+r) ---
VimUndo() {
    Send("^z")
}

VimRedo() {
    Send("^y")
}

; --- Change (c) ---
VimChange() {
    Send("^x")
    ExitVisualMode()
}

VimChangeToEndOfLine() {
    Send("+{End}")
    Send("^x")
}

VimChangeWord() {
    Send("+^{Right}")
    Send("^x")
}

VimChangeLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^x")
}

; --- Insert/Append (i/a/o) ---
VimInsertAtLineStart() {
    Send("{Home}")
}

VimAppend() {
    Send("{Right}")
}

VimAppendAtLineEnd() {
    Send("{End}")
}

VimOpenLineBelow() {
    Send("{End}")
    Send("{Enter}")
}

VimOpenLineAbove() {
    Send("{Home}")
    Send("{Enter}")
    Send("{Up}")
}

; --- Indent (</>) ---
VimIndent() {
    Send("{Tab}")
}

VimUnindent() {
    Send("+{Tab}")
}

; --- Objects ---
VimDeleteCurrentWord() {
    Send("^{Right}^+{Left}{Delete}")
}

VimDeleteAll() {
    Send("^a{Delete}")
}

; ==============================
; KEYMAP REGISTRATION
; ==============================

; --- Global Entry Point ---
RegisterKeymap("leader", "V", "Vim Mode", ToggleVimMode)

; --- VIM MODE (Normal) ---
RegisterKeymap("vim", "h", "Left", VimMoveLeft)
RegisterKeymap("vim", "j", "Down", VimMoveDown)
RegisterKeymap("vim", "k", "Up", VimMoveUp)
RegisterKeymap("vim", "l", "Right", VimMoveRight)

RegisterKeymap("vim", "w", "Word Fwd", VimWordForward)
RegisterKeymap("vim", "b", "Word Back", VimWordBackward)
RegisterKeymap("vim", "e", "End Word", VimEndOfWord)

RegisterKeymap("vim", "0", "Start Line", VimStartOfLine)
RegisterKeymap("vim", "$", "End Line", VimEndOfLine)

RegisterCategoryKeymap("vim", "g", "Go To", 1) 
RegisterKeymap("vim", "g", "g", "Top File", VimTopOfFile) 
RegisterKeymap("vim", "G", "Bottom File", VimBottomOfFile)

RegisterKeymap("vim", "x", "Cut Char", VimDelete)
RegisterKeymap("vim", "d", "Cut/Delete", VimDelete)
RegisterCategoryKeymap("vim", "y", "Yank menu")
RegisterKeymap("vim", "y", "y", "Yank line", VimYankLine)
RegisterKeymap("vim", "y", "0", "Start of Line", VimYankStartLine)
RegisterKeymap("vim", "y", "$", "End of Line", VimYankEndLine)
RegisterKeymap("vim", "p", "Paste", VimPaste)
RegisterKeymap("vim", "u", "Undo", VimUndo)
RegisterKeymap("vim", "r", "Redo", VimRedo)
RegisterKeymap("vim", "i", "Insert", () => SwitchToLayer("insert"))
RegisterKeymap("vim", "v", "Visual Mode", EnterVisualMode)

; --- VISUAL MODE ---
RegisterKeymap("vim_visual", "h", "Select Left", VimVisualMoveLeft)
RegisterKeymap("vim_visual", "j", "Select Down", VimVisualMoveDown)
RegisterKeymap("vim_visual", "k", "Select Up", VimVisualMoveUp)
RegisterKeymap("vim_visual", "l", "Select Right", VimVisualMoveRight)

RegisterKeymap("vim_visual", "w", "Select Word", VimVisualWordForward)
RegisterKeymap("vim_visual", "b", "Select Back", VimVisualWordBackward)
RegisterKeymap("vim_visual", "e", "Select End", VimVisualEndOfWord)

RegisterKeymap("vim_visual", "0", "Select Start", VimVisualStartOfLine)
RegisterKeymap("vim_visual", "$", "Select End", VimVisualEndOfLine)

RegisterCategoryKeymap("vim_visual", "g", "Go To", 1) 
RegisterKeymap("vim_visual", "g", "g", " Select Top File", VimVisualTopOfFile) 
RegisterKeymap("vim_visual", "G", "Select Bottom", VimVisualBottomOfFile)

RegisterKeymap("vim_visual", "d", "Cut Selection", VimVisualDelete)
RegisterKeymap("vim_visual", "x", "Cut Selection", VimVisualCut)
RegisterKeymap("vim_visual", "c", "Change Selection", VimChange)
RegisterKeymap("vim_visual", "y", "Copy Selection", VimYank)

RegisterKeymap("vim_visual", "Escape", "Normal Mode", ReturnToPreviousLayer)
RegisterKeymap("vim_visual", "v", "Normal Mode", ExitVisualMode)

; Exit insert mode with Esc
RegisterKeymap("vim_insert", "Escape", "Exit Insert Mode",  () => SwitchToLayer("vim"))
