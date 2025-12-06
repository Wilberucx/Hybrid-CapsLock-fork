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

/**
 * NavigateExplorer - Intelligently navigates to a folder path
 * @param path - Folder path to navigate to
 * 
 * Behavior:
 *   - If an Explorer window is active, navigates that window to the new path
 *   - If no Explorer is active, opens a new Explorer window at the path
 * 
 * Example:
 *   NavigateExplorer("C:\Users\Documents")
 */
NavigateExplorer(path) {
    if WinActive("ahk_class CabinetWClass") {
        try {
            hwnd := WinExist("A")
            for window in ComObject("Shell.Application").Windows {
                if (window.hwnd == hwnd) {
                    window.Navigate(path)
                    return
                }
            }
        }
    }
    ; No active Explorer found, open a new one
    Run("explorer.exe " . path)
}

/**
 * GetSelectedExplorerItem - Returns the full path of the currently selected file/folder in Explorer
 * Returns: String (full path) or "" if no item is selected or Explorer is not active
 */
GetSelectedExplorerItem() {
    if WinActive("ahk_class CabinetWClass") {
        try {
            hwnd := WinExist("A")
            for window in ComObject("Shell.Application").Windows {
                if (window.hwnd == hwnd) {
                    selectedItems := window.Document.SelectedItems()
                    if (selectedItems.Count > 0) {
                        return selectedItems.Item(0).Path
                    }
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

; ==============================
; DATA PERSISTENCE
; ==============================

/**
 * LoadHistory - Loads history from an INI file
 * @param key - Key in the "History" section of the INI file
 * @param iniFile - Path to the INI file
 * @returns Array of strings (history items), or empty array if not found
 * 
 * Example:
 *   history := LoadHistory("RecentFolders", "data\my_plugin.ini")
 *   for index, item in history {
 *       MsgBox("Item " . index . ": " . item)
 *   }
 */
LoadHistory(key, iniFile) {
    try {
        historyStr := IniRead(iniFile, "History", key, "")
        if (historyStr == "")
            return []
        return StrSplit(historyStr, "|")
    }
    return []
}

/**
 * SaveHistory - Saves a value to history in an INI file
 * @param key - Key in the "History" section of the INI file
 * @param value - Value to add to the history
 * @param iniFile - Path to the INI file
 * 
 * Behavior:
 *   - Removes the value if it already exists (to move it to the top)
 *   - Inserts the value at position 1
 *   - Keeps a maximum of 10 items
 *   - Saves back to the INI file with format: "item1|item2|item3"
 * 
 * Example:
 *   SaveHistory("RecentFolders", "C:\Users\Documents", "data\my_plugin.ini")
 */
SaveHistory(key, value, iniFile) {
    currentHistory := LoadHistory(key, iniFile)
    
    ; Remove if exists to move to top
    for index, item in currentHistory {
        if (item == value) {
            currentHistory.RemoveAt(index)
            break
        }
    }
    
    ; Add to top
    currentHistory.InsertAt(1, value)
    
    ; Keep max 10 items
    if (currentHistory.Length > 10)
        currentHistory.Pop()
        
    ; Save back
    historyStr := ""
    for item in currentHistory {
        historyStr .= (historyStr == "" ? "" : "|") . item
    }
    IniWrite(historyStr, iniFile, "History", key)
}
