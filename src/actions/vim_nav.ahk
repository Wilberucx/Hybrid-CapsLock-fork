; ==============================
; Vim Navigation Actions - Reusable Functions
; ==============================
; Vim-style navigation that can be used in multiple layers:
; - nvim_layer.ahk (text navigation)
; - excel_layer.ahk (cell navigation)
; - Any future layer that needs hjkl navigation
;
; These functions are GENERIC and do NOT depend on specific context.
; Each layer decides WHEN to call them (context-aware in the layer).

; ==============================
; BASIC NAVIGATION (hjkl)
; ==============================

; Move Left (h)
VimMoveLeft() {
    Send("{Left}")
}

; Move Down (j)
VimMoveDown() {
    Send("{Down}")
}

; Move Up (k)
VimMoveUp() {
    Send("{Up}")
}

; Move Right (l)
VimMoveRight() {
    Send("{Right}")
}

; ==============================
; WORD NAVIGATION (w/b/e)
; ==============================

; Word Forward (w)
VimWordForward() {
    Send("^{Right}")  ; Ctrl+Right
}

; Word Backward (b)
VimWordBackward() {
    Send("^{Left}")   ; Ctrl+Left
}

; End of Word (e)
VimEndOfWord() {
    Send("^{Right}")
    Send("{Left}")
}

; ==============================
; LINE NAVIGATION (0/$)
; ==============================

; Start of Line (0 o ^)
VimStartOfLine() {
    Send("{Home}")
}

; End of Line ($)
VimEndOfLine() {
    Send("{End}")
}

; ==============================
; DOCUMENT NAVIGATION (gg/G)
; ==============================

; Top of File (gg)
VimTopOfFile() {
    Send("^{Home}")
}

; Bottom of File (G)
VimBottomOfFile() {
    Send("^{End}")
}

; ==============================
; PAGE NAVIGATION (Ctrl+d/Ctrl+u)
; ==============================

; Page Down (Ctrl+d)
VimPageDown() {
    Send("{PgDn}")
}

; Page Up (Ctrl+u)
VimPageUp() {
    Send("{PgUp}")
}

; Half Page Down (Ctrl+d - scrolling)
VimHalfPageDown() {
    Loop 10 {
        Send("{Down}")
    }
}

; Half Page Up (Ctrl+u - scrolling)
VimHalfPageUp() {
    Loop 10 {
        Send("{Up}")
    }
}

; ==============================
; SCREEN NAVIGATION (H/M/L)
; ==============================

; High (H) - Top of visible screen
VimScreenTop() {
    ; Approximation: PgUp then Home
    Send("{PgUp}")
    Send("{Home}")
}

; Middle (M) - Middle of visible screen
VimScreenMiddle() {
    ; Difícil de implementar sin conocer tamaño de ventana
    ; Placeholder: mantener posición
}

; Low (L) - Bottom of visible screen
VimScreenBottom() {
    ; Aproximación: PgDn luego End
    Send("{PgDn}")
    Send("{End}")
}

; ==============================
; SEARCH AND NAVIGATION (f/t/;/,)
; ==============================

; Find character forward (f{char})
; Nota: Requiere input adicional, implementar en layer específico

; Till character forward (t{char})
; Nota: Requiere input adicional, implementar en layer específico

; Repeat last search (;)
VimRepeatSearch() {
    Send("{F3}")  ; Find Next en muchas apps
}

; Reverse repeat last search (,)
VimReverseSearch() {
    Send("+{F3}")  ; Find Previous
}



; ==============================
; ARCHIVOS RELACIONADOS:
; ==============================
; - vim_visual.ahk  → Navegación con selección (Shift+hjkl)
; - vim_edit.ahk    → Operaciones de edición (yank/delete/paste/undo)
;
; ==============================
; NOTAS DE USO:
; ==============================
; Estas funciones son BUILDING BLOCKS para navegación SIN selección.
; Cada layer decide:
; 1. CUÁNDO llamarlas (context: #HotIf)
; 2. CÓMO mapearlas (RegisterKeymap o hotkeys directos)
; 3. SI necesita wrappers específicos (ej: ExcelMoveLeft que llama VimMoveLeft + lógica extra)
;
; EJEMPLO en nvim_layer.ahk:
;   #Include src\actions\vim_nav.ahk
;   #HotIf (isNvimLayerActive)
;   h::VimMoveLeft()
;   j::VimMoveDown()
;   #HotIf
;
; EJEMPLO en excel_layer.ahk:
;   #Include src\actions\vim_nav.ahk
;   #HotIf (excelLayerActive)
;   h::VimMoveLeft()  // REUTILIZA la misma función
;   j::VimMoveDown()
;   #HotIf
