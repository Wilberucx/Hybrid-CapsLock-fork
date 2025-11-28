; ==============================
; Context Utils - Core System Plugin
; ==============================
; Centralized functions for detecting system context (active paths, window types)
; Location: system/plugins/context_utils.ahk

; ==============================
; PATH RETRIEVAL
; ==============================

/**
 * GetActiveExplorerPath - Returns the path of the active Windows Explorer window
 * Returns: String (path) or "" if no Explorer window is active
 */
GetActiveExplorerPath() {
    if WinActive("ahk_class CabinetWClass") {
        try {
            hwnd := WinExist("A")
            for window in ComObject("Shell.Application").Windows {
                if (window.hwnd == hwnd) {
                    return window.Document.Folder.Self.Path
                }
            }
        }
    }
    return ""
}

; ==============================
; WINDOW TYPE DETECTION
; ==============================

/**
 * IsTerminalWindow - Checks if the active window is a known terminal emulator
 * Supports: Windows Terminal, Mintty (Git Bash), Alacritty, WezTerm, CMD, PowerShell
 * Returns: Boolean
 */
IsTerminalWindow() {
    activeClass := WinGetClass("A")
    activeProcess := WinGetProcessName("A")
    
    return (activeClass == "CASCADIA_HOSTING_WINDOW_CLASS") || ; Windows Terminal
           (activeClass == "mintty") ||                        ; Git Bash / Mintty
           (activeClass == "ConsoleWindowClass") ||            ; Legacy CMD / PowerShell
           (InStr(activeProcess, "alacritty")) ||              ; Alacritty
           (InStr(activeProcess, "wezterm"))                   ; WezTerm
}

/**
 * GetPasteShortcut - Returns the appropriate paste shortcut for the active window
 * Returns: String ("^v" or "^+v")
 */
GetPasteShortcut() {
    if (IsTerminalWindow()) {
        return "^+v" ; Ctrl+Shift+V for terminals
    }
    return "^v"      ; Ctrl+V for everything else
}

; ==============================
; PROCESS DETECTION
; ==============================

/**
 * GetActiveProcessName - Returns the process name of the active window
 * Returns: String (e.g., "notepad.exe", "Code.exe") or "" if unable to detect
 */
GetActiveProcessName() {
    try {
        return WinGetProcessName("A")
    }
    return ""
}
