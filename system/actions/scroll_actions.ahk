; ==============================
; Scroll Actions - Reusable scroll functions
; ==============================
; Generic scroll actions that can be used from any layer
; Compatible with the unified keymap system

; ==============================
; BASIC SCROLL ACTIONS
; ==============================

; ScrollUp() - Scroll up (mouse wheel up)
ScrollUp() {
    Send("{WheelUp}")
}

; ScrollDown() - Scroll down (mouse wheel down)
ScrollDown() {
    Send("{WheelDown}")
}

; ScrollLeft() - Scroll left (Shift + mouse wheel up)
ScrollLeft() {
    Send("+{WheelUp}")
}

; ScrollRight() - Scroll right (Shift + mouse wheel down)
ScrollRight() {
    Send("+{WheelDown}")
}

; ==============================
; FAST SCROLL ACTIONS
; ==============================

; ScrollUpFast() - Scroll up faster (3x)
ScrollUpFast() {
    Loop 3
        Send("{WheelUp}")
}

; ScrollDownFast() - Scroll down faster (3x)
ScrollDownFast() {
    Loop 3
        Send("{WheelDown}")
}

; ==============================
; PAGE SCROLL ACTIONS
; ==============================

; ScrollPageUp() - Page up
ScrollPageUp() {
    Send("{PgUp}")
}

; ScrollPageDown() - Page down
ScrollPageDown() {
    Send("{PgDn}")
}

; ScrollToTop() - Jump to top (Ctrl+Home)
ScrollToTop() {
    Send("^{Home}")
}

; ScrollToBottom() - Jump to bottom (Ctrl+End)
ScrollToBottom() {
    Send("^{End}")
}

; ==============================
; NOTES
; ==============================
; These functions are intentionally simple and reusable.
; They can be called from any layer (scroll, nvim, excel, etc.)
; Example usage in keymap registration:
;   RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
;   RegisterKeymap("nvim", "k", "Scroll Up", ScrollUp, false)
