; ==============================
; Scroll Actions - Reusable scroll functions
; ==============================
; Generic scroll actions that can be used from any layer
; Compatible with the unified keymap system
; ==============================
; NOTES
; ==============================
; These functions are intentionally simple and reusable.
; They can be called from any layer (scroll, nvim, excel, etc.)
; Example usage in keymap registration:
;   RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false)
;   RegisterKeymap("nvim", "k", "Scroll Up", ScrollUp, false)
;
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

RegisterLayer("scroll", "SCROLL MODE", "#E6C07B", "#000000")

; Scroll Navigation
RegisterKeymap("scroll", "k", "Scroll Up", ScrollUp, false, 1)
RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false, 2)
RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false, 3)
RegisterKeymap("scroll", "l", "Scroll Right", ScrollRight, false, 4)

; Layer Control
RegisterKeymap("scroll", "s", "Exit Scroll Layer", ReturnToPreviousLayer, false, 10)
RegisterKeymap("scroll", "Escape", "Exit Scroll Layer", ReturnToPreviousLayer, false, 11)

; Entry point (Leader + s) - Direct SwitchToLayer call
RegisterKeymap("leader", "s", "Scroll", () => SwitchToLayer("scroll"), false, 4)
