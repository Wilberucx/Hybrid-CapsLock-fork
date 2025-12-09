; ==============================
; Windows Manager Plugin
; ==============================
; Comprehensive window management system for HybridCapsLock
; Provides window control, navigation, and tab management
;
; INSTALLATION:
; Copy this file to ahk/plugins/ and reload HybridCapsLock (Leader + h + R)
;
; KEYMAPS:
; Leader + w       → Enter Windows Manager
;     ├─ d         → Close active window (with confirmation)
;     ├─ m         → Toggle minimize/restore window
;     ├─ M         → Minimize window to taskbar
;     ├─ l         → List windows (Alt+Tab with hjkl navigation)
;     ├─ H         → Previous window (Alt+Shift+Tab)
;     ├─ L         → Next window (Alt+Tab)
;     └─ b         → Tab Manager
;         ├─ d     → Close tab (Ctrl+W)
;         └─ n     → New tab (Ctrl+T)

; ==============================
; HELPER FUNCTIONS
; ==============================


GetActiveWindowState() {
    ; Returns the minimize/maximize state of the active window
    ; -1 = Minimized, 0 = Normal, 1 = Maximized
    try {
        return WinGetMinMax("A")
    } catch {
        return 0
    }
}

; ==============================
; WINDOW MANAGEMENT ACTIONS
; ==============================

CloseActiveWindow() {
    ; Closes the active window using WinClose (sends WM_CLOSE message)
    ; More reliable than Alt+F4, especially for Windows Explorer and system apps
    ; Timeout of 3 seconds for apps that may show confirmation dialogs
    try {
        windowTitle := WinGetTitle("A")
        if (windowTitle = "") {
            ShowTooltipFeedback("❌ No active window", "error")
            return
        }
        
        ; WinClose sends WM_CLOSE directly to the window
        ; More reliable than Alt+F4 which can be intercepted
        WinClose("A", , 3)
        ShowTooltipFeedback("🗙 Closing: " . windowTitle, "info")
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

ToggleMinimizeWindow() {
    ; Toggles between minimized and restored state
    ; If minimized, restores. If normal/maximized, minimizes.
    try {
        windowTitle := WinGetTitle("A")
        if (windowTitle = "") {
            ShowTooltipFeedback("❌ No active window", "error")
            return
        }
        
        state := GetActiveWindowState()
        
        if (state = -1) {
            ; Window is minimized, restore it
            WinRestore("A")
        } else {
            ; Window is normal or maximized, minimize it
            WinMinimize("A")
            ShowTooltipFeedback("📥 Minimized: " . windowTitle, "info")
        }
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

MinimizeToTaskbar() {
    ; Forces minimize to taskbar regardless of current state
    try {
        windowTitle := WinGetTitle("A")
        if (windowTitle = "") {
            ShowTooltipFeedback("❌ No active window", "error")
            return
        }
        
        WinMinimize("A")
        ShowTooltipFeedback("📥 Minimized to taskbar: " . windowTitle, "info")
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

; ==============================
; WINDOW NAVIGATION ACTIONS
; ==============================

NavigateToPreviousWindow() {
    ; Navigates to previous window using Alt+Shift+Tab
    try {
        Send("!+{Tab}")
        ShowTooltipFeedback("⬅️ Previous window", "info")
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

NavigateToNextWindow() {
    ; Navigates to next window using Alt+Tab
    try {
        Send("!{Tab}")
        ShowTooltipFeedback("➡️ Next window", "info")
    } catch as e {
    }
}

ListWindowsWithNavigation() {
    ; Opens Task View (Win+Tab) using RIGHT Windows key and activates navigation layer
    ; Task View stays open without holding keys (cleaner than Alt+Tab)
    ; Allows hjkl navigation until Enter is pressed
    try {
        ; Send RWin+Tab to open Task View
        ; Using RWin (Right Windows key) to avoid conflicts with LWin shortcuts
        Send("{RWin down}{Tab}{RWin up}")
        
        ; Small delay to let Task View open
        Sleep(100)
        
        ; Switch to navigation layer
        SwitchToLayer("windows_list")
        info := "TASK VIEW OPENED `n" 
        info := "=================`n"
        info := "Navigate with HJKL or arrow keys.`n"
        info := "ENTER to select, ESC to cancel."

        ShowTooltipFeedback(info, "info")
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

; ==============================
; WINDOW LIST LAYER ACTIVATION
; ==============================

OnWindowsListLayerActivate() {
    ; This function is called when windows_list layer is activated
    ; Start listening for navigation keys
    global isWindowsListLayerActive := true
    ListenForLayerKeymaps("windows_list", "isWindowsListLayerActive")
}

OnWindowsListLayerDeactivate() {
    ; Cleanup when exiting windows_list layer
    global isWindowsListLayerActive := false
    ; No key cleanup needed (Task View doesn't hold keys)
}

; ==============================
; WINDOW LIST NAVIGATION ACTIONS
; ==============================

WindowListNavigateLeft() {
    ; Navigate left in Alt+Tab switcher
    Send("+{Tab}")
}

WindowListNavigateRight() {
    ; Navigate right in Alt+Tab switcher
    Send("{Tab}")
}

WindowListNavigateUp() {
    ; Navigate up in Alt+Tab switcher (if grid view)
    Send("{Up}")
}

WindowListNavigateDown() {
    ; Navigate down in Alt+Tab switcher (if grid view)
    Send("{Down}")
}

WindowListConfirm() {
    ; Confirm selection in Task View
    ; Just press Enter - no need to release keys
    Send("{Enter}")
    ReturnToPreviousLayer()
    ShowTooltipFeedback("✅ Window selected", "info")
}

WindowListCancel() {
    ; Close Task View without selecting
    Send("{Escape}")   
    ReturnToPreviousLayer()
    ShowTooltipFeedback("❌ Cancelled", "info")
}

; ==============================
; TAB MANAGEMENT ACTIONS
; ==============================

CloseCurrentTab() {
    ; Closes the current tab using Ctrl+W
    ; Works in browsers, editors, and most tab-enabled applications
    try {
        Send("^w")
        ShowTooltipFeedback("🗙 Tab closed (Ctrl+W)", "info")
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

OpenNewTab() {
    ; Opens a new tab using Ctrl+T
    ; Works in browsers, editors, and most tab-enabled applications
    try {
        Send("^t")
    } catch as e {
        ShowTooltipFeedback("❌ Error: " . e.Message, "error")
    }
}

; ==============================
; LAYER REGISTRATIONS
; ==============================

; Temporary Navigation Layer (for window list)
RegisterLayer("windows_list", "WINDOW LIST", "#C678DD", "#ffffff", true)

; ==============================
; KEYMAP REGISTRATIONS
; ==============================

; --- LEADER LAYER ---
; Windows Manager Category (hierarchical menu under leader)
RegisterCategoryKeymap("leader", "w", "Windows Manager", 5)

; Window Management
RegisterKeymap("leader", "w", "d", "Close Window", CloseActiveWindow, false, 1)
RegisterKeymap("leader", "w", "m", "Toggle Min/Restore", ToggleMinimizeWindow, false, 2)
RegisterKeymap("leader", "w", "M", "Minimize to Taskbar", MinimizeToTaskbar, false, 3)

; Window Navigation
RegisterKeymap("leader", "w", "l", "List Windows (hjkl nav)", ListWindowsWithNavigation, false, 4)
RegisterKeymap("leader", "w", "H", "Previous Window", NavigateToPreviousWindow, false, 5)
RegisterKeymap("leader", "w", "L", "Next Window", NavigateToNextWindow, false, 6)

; Tab Manager Sub-Category
RegisterCategoryKeymap("leader", "w", "b", "Tab Manager", 7)
RegisterKeymap("leader", "w", "b", "d", "Close Tab (Ctrl+W)", CloseCurrentTab, false, 1)
RegisterKeymap("leader", "w", "b", "n", "New Tab (Ctrl+T)", OpenNewTab, false, 2)

; --- WINDOWS LIST LAYER ---
; Navigation controls for Alt+Tab switcher

; Vim-style navigation
RegisterKeymap("windows_list", "h", "Navigate Left", () => Send("{Left}"), false, 1)
RegisterKeymap("windows_list", "j", "Navigate Down", () => Send("{Down}"), false, 2)
RegisterKeymap("windows_list", "k", "Navigate Up", () => Send("{Up}"), false, 3)
RegisterKeymap("windows_list", "l", "Navigate Right", () => Send("{Right}"), false, 4)

; Arrow keys (alternative)
RegisterKeymap("windows_list", "Left", "Navigate Left", WindowListNavigateLeft, false, 5)
RegisterKeymap("windows_list", "Down", "Navigate Down", WindowListNavigateDown, false, 6)
RegisterKeymap("windows_list", "Up", "Navigate Up", WindowListNavigateUp, false, 7)
RegisterKeymap("windows_list", "Right", "Navigate Right", WindowListNavigateRight, false, 8)

; Confirmation and cancel
RegisterKeymap("windows_list", "Enter", "Select Window", WindowListConfirm, false, 9)
RegisterKeymap("windows_list", "o", "Select Window", WindowListConfirm, false, 9)
