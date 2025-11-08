; ==============================
; Vim Edit Operations - Operaciones de Edición
; ==============================
; Funciones para operaciones de edición de texto estilo Vim.
; Estas funciones NO son navegación, son ACCIONES sobre el texto.
;
; USADAS EN:
; - nvim_layer.ahk (yank/delete/paste/undo)
; - excel_layer.ahk (copy/paste en celdas)
; - Cualquier capa que necesite edición de texto
;
; REQUIERE: Nada (funciones independientes)

; ==============================
; OPERACIONES DE CLIPBOARD (yank/delete/paste)
; ==============================

; Yank (copy) - y en Vim
VimYank() {
    Send("^c")
}

; Yank Line (copy entire line) - yy en Vim
VimYankLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^c")
    Send("{Down}")
    Send("{Home}")
}

; Delete (cut) - d en Vim
VimDelete() {
    Send("^x")
}

; Delete Line (cut entire line) - dd en Vim
VimDeleteLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^x")
}

; Delete to End of Line (cut to end) - D en Vim
VimDeleteToEndOfLine() {
    Send("+{End}")
    Send("^x")
}

; Paste (put) - p en Vim
VimPaste() {
    Send("^v")
}

; Paste Before - P en Vim (aproximación)
VimPasteBefore() {
    Send("{Left}")
    Send("^v")
}

; ==============================
; DESHACER/REHACER (undo/redo)
; ==============================

; Undo - u en Vim
VimUndo() {
    Send("^z")
}

; Redo - Ctrl+r en Vim
VimRedo() {
    Send("^y")  ; Windows: Ctrl+Y, en algunos editores puede ser Ctrl+Shift+Z
}

; Undo Line (deshacer cambios en línea) - U en Vim
; Nota: Difícil de implementar genéricamente, depende del editor

; ==============================
; CAMBIAR (change) - c en Vim
; ==============================

; Change (delete + insert mode)
VimChange() {
    Send("^x")  ; Borra selección, listo para insertar
}

; Change to End of Line - C en Vim
VimChangeToEndOfLine() {
    Send("+{End}")
    Send("^x")
}

; Change Word - cw en Vim
VimChangeWord() {
    Send("+^{Right}")
    Send("^x")
}

; Change Line - cc en Vim
VimChangeLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^x")
}

; ==============================
; REEMPLAZAR (replace)
; ==============================

; Replace character - r en Vim
; Nota: Requiere input adicional, implementar en layer específico

; Replace mode - R en Vim
; Nota: Activar Insert mode (sobreescribir)
VimReplaceMode() {
    Send("{Insert}")  ; Toggle Insert/Overwrite mode
}

; ==============================
; INSERTAR (insert)
; ==============================

; Insert at cursor - i en Vim
; Nota: En Windows no hay "modo", solo posicionar cursor

; Insert at start of line - I en Vim
VimInsertAtLineStart() {
    Send("{Home}")
}

; Append at cursor - a en Vim
VimAppend() {
    Send("{Right}")
}

; Append at end of line - A en Vim
VimAppendAtLineEnd() {
    Send("{End}")
}

; Open line below - o en Vim
VimOpenLineBelow() {
    Send("{End}")
    Send("{Enter}")
}

; Open line above - O en Vim
VimOpenLineAbove() {
    Send("{Home}")
    Send("{Enter}")
    Send("{Up}")
}

; ==============================
; INDENTACIÓN (indent/unindent)
; ==============================

; Indent (shift right) - > en Visual Mode
VimIndent() {
    Send("{Tab}")
}

; Unindent (shift left) - < en Visual Mode
VimUnindent() {
    Send("+{Tab}")
}

; Indent Line - >> en Normal Mode
VimIndentLine() {
    Send("{Home}")
    Send("{Tab}")
}

; Unindent Line - << en Normal Mode
VimUnindentLine() {
    Send("{Home}")
    Send("+{Tab}")
}

; ==============================
; JOIN LINES (unir líneas)
; ==============================

; Join lines - J en Vim
VimJoinLines() {
    Send("{End}")
    Send("{Delete}")
    Send("{Space}")
}

; Join lines without space
VimJoinLinesNoSpace() {
    Send("{End}")
    Send("{Delete}")
}

; ==============================
; CASE CHANGE (cambiar mayúsculas/minúsculas)
; ==============================

; Toggle case - ~ en Vim (aproximación)
VimToggleCase() {
    ; Requiere lógica compleja específica del editor
    ; Placeholder: seleccionar y aplicar formato
}

; Uppercase - gU en Vim
VimUppercase() {
    ; Requiere lógica específica del editor
    ; En algunos editores: Ctrl+Shift+U
}

; Lowercase - gu en Vim
VimLowercase() {
    ; Requiere lógica específica del editor
    ; En algunos editores: Ctrl+U
}

; ==============================
; DUPLICAR/REPETIR
; ==============================

; Repeat last change - . (dot) en Vim
; Nota: Difícil de implementar genéricamente, requiere state tracking

; Duplicate line (no es Vim estándar, pero útil)
VimDuplicateLine() {
    Send("{Home}")
    Send("+{End}")
    Send("^c")
    Send("{End}")
    Send("{Enter}")
    Send("^v")
}

; ==============================
; ARCHIVOS RELACIONADOS:
; ==============================
; - vim_nav.ahk    → Navegación sin selección
; - vim_visual.ahk → Navegación con selección
;
; ==============================
; NOTAS DE USO:
; ==============================
; Estas funciones son operaciones DESPUÉS de seleccionar o posicionar.
; No son movimientos, son ACCIONES sobre el texto.
;
; EJEMPLO en nvim_layer.ahk:
;   #Include src\actions\vim_edit.ahk
;   #Include src\actions\vim_visual.ahk
;   
;   ActivateVisualMode() {
;       Loop {
;           key := GetInput()
;           if (key = "h")
;               VimVisualMoveLeft()  ; vim_visual.ahk
;           else if (key = "y")
;               VimYank(), break      ; vim_edit.ahk
;           else if (key = "d")
;               VimDelete(), break    ; vim_edit.ahk
;       }
;   }
;
; EJEMPLO standalone:
;   #HotIf (isNvimLayerActive)
;   y::VimYank()
;   p::VimPaste()
;   u::VimUndo()
;   #HotIf
