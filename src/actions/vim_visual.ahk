; ==============================
; Vim Visual Mode - Navegación con Selección
; ==============================
; Funciones para navegación con selección (Visual Mode de Vim).
; Estas funciones añaden Shift a los comandos de navegación.
;
; USADAS EN:
; - nvim_layer.ahk (modo visual v/V)
; - excel_layer.ahk (selección de celdas)
; - Cualquier capa que necesite seleccionar mientras navega
;
; REQUIERE: vim_nav.ahk (opcional, para complementar)

; ==============================
; NAVEGACIÓN BÁSICA CON SELECCIÓN (Shift+hjkl)
; ==============================

; Move Left with selection (Shift+Left)
VimVisualMoveLeft() {
    Send("+{Left}")
}

; Move Down with selection (Shift+Down)
VimVisualMoveDown() {
    Send("+{Down}")
}

; Move Up with selection (Shift+Up)
VimVisualMoveUp() {
    Send("+{Up}")
}

; Move Right with selection (Shift+Right)
VimVisualMoveRight() {
    Send("+{Right}")
}

; ==============================
; PALABRAS CON SELECCIÓN (Shift+w/b/e)
; ==============================

; Word Forward with selection (Shift+Ctrl+Right)
VimVisualWordForward() {
    Send("+^{Right}")
}

; Word Backward with selection (Shift+Ctrl+Left)
VimVisualWordBackward() {
    Send("+^{Left}")
}

; End of Word with selection
VimVisualEndOfWord() {
    Send("+^{Right}")
    Send("+{Left}")
}

; ==============================
; LÍNEA CON SELECCIÓN (Shift+^/$)
; ==============================

; Start of Line with selection (Shift+Home)
VimVisualStartOfLine() {
    Send("+{Home}")
}

; End of Line with selection (Shift+End)
VimVisualEndOfLine() {
    Send("+{End}")
}

; ==============================
; DOCUMENTO CON SELECCIÓN (Shift+gg/G)
; ==============================

; Top of File with selection (Shift+Ctrl+Home)
VimVisualTopOfFile() {
    Send("+^{Home}")
}

; Bottom of File with selection (Shift+Ctrl+End)
VimVisualBottomOfFile() {
    Send("+^{End}")
}

; ==============================
; PÁGINA CON SELECCIÓN (Shift+Ctrl+d/u)
; ==============================

; Page Down with selection
VimVisualPageDown() {
    Send("+{PgDn}")
}

; Page Up with selection
VimVisualPageUp() {
    Send("+{PgUp}")
}

; ==============================
; SELECCIÓN DE LÍNEA COMPLETA (Visual Line Mode)
; ==============================

; Select entire line down (V + j)
VimVisualLineDown() {
    Send("+{Down}")
    Send("+{Home}")
}

; Select entire line up (V + k)
VimVisualLineUp() {
    Send("+{Up}")
    Send("+{Home}")
}

; Select to end of line (v + $)
VimVisualToEndOfLine() {
    Send("+{End}")
}

; Select to start of line (v + ^)
VimVisualToStartOfLine() {
    Send("+{Home}")
}

; ==============================
; SELECCIÓN INTELIGENTE (Expand/Shrink)
; ==============================

; Select inside word (viw - aproximación)
VimVisualInsideWord() {
    Send("^{Left}")
    Send("+^{Right}")
}

; Select around word (vaw - aproximación)
VimVisualAroundWord() {
    Send("^{Left}")
    Send("+^{Right}")
    Send("+{Space}")  ; Include trailing space
}

; Select inside parentheses/brackets (vi( / vi[ - requiere lógica compleja)
; Nota: Difícil de implementar genéricamente, mejor en layer específico

; ==============================
; ARCHIVOS RELACIONADOS:
; ==============================
; - vim_nav.ahk   → Navegación SIN selección (hjkl básico)
; - vim_edit.ahk  → Operaciones después de selección (yank/delete)
;
; ==============================
; NOTAS DE USO:
; ==============================
; Estas funciones añaden Shift a los movimientos básicos.
; Se usan típicamente en modo Visual de Vim (v/V).
;
; EJEMPLO en nvim_layer.ahk:
;   #Include src\actions\vim_visual.ahk
;   
;   ActivateVisualMode() {
;       global nvimVisualMode := true
;       Loop {
;           key := GetInput()
;           if (key = "h")
;               VimVisualMoveLeft()
;           else if (key = "j")
;               VimVisualMoveDown()
;           else if (key = "Escape")
;               break
;       }
;   }
;
; EJEMPLO en excel_layer.ahk:
;   #Include src\actions\vim_visual.ahk
;   
;   ; Selección de rango de celdas
;   #HotIf (excelLayerActive && excelVisualMode)
;   h::VimVisualMoveLeft()
;   j::VimVisualMoveDown()
;   #HotIf
