; ==============================
; Explorer Actions Plugin
; ==============================
; Provides vim-style navigation and file management for Windows Explorer.
; Includes rename, copy, tab management, and file creation operations.
;
; INSTALLATION:
; Copy this file to ahk/plugins/ and reload HybridCapsLock (Leader + h + R)
;
; USAGE:
; Activate the explorer layer with Leader → e → x (or your configured key)
; Then use vim-style keybindings for Explorer operations

; ==============================
; LAYER REGISTRATION
; ==============================
RegisterLayer("explorer", "EXPLORER", "#4A90E2", "#ffffff")

; ==============================
; HELPER FUNCTIONS
; ==============================

/**
 * CopyToClipboard - Copy text to clipboard with feedback tooltip
 * @param text - Text to copy to clipboard
 * @param label - Optional label for the tooltip (default: "Copied")
 */
CopyToClipboard(text, label := "Copied") {
    if (text == "") {
        ShowTooltipFeedback("Nothing to copy", "error")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    A_Clipboard := text
    ShowTooltipFeedback(label . ": " . text)
    SetTimer(() => RemoveToolTip(), -2000)
}

; /**
;  * ToggleHiddenFiles - Toggle hidden files visibility in Explorer
;  */
; ToggleHiddenFiles() {
;     Send("^h")
; }

/**
 * CloseExplorerWindow - Close the current Explorer window
 */
CloseExplorerWindow() {
    if WinActive("ahk_class CabinetWClass") {
        WinClose("A")
    }
}

/**
 * NewExplorerWindow - Open a new Explorer window in the current directory
 */
NewExplorerWindow() {
    currentPath := GetActiveExplorerPath()
    if (currentPath == "") {
        currentPath := EnvGet("USERPROFILE")
    }
    
    Run('explorer.exe "' . currentPath . '"')
}

/**
 * NavigatePrevious - Navigate to previous folder (Alt+Left)
 */
NavigatePrevious() {
    if WinActive("ahk_class CabinetWClass") {
        Send("!{Left}")
    }
}

/**
 * NavigateNext - Navigate to next folder (Alt+Right)
 */
NavigateNext() {
    if WinActive("ahk_class CabinetWClass") {
        Send("!{Right}")
    }
}

/**
 * RenameSelectedItem - Send F2 to rename and switch to insert layer
 */
RenameSelectedItem() {
    if WinActive("ahk_class CabinetWClass") {
        Send("{F2}")
        ; Switch to insert layer (provided by vim_actions.ahk)
        ; User can press Escape to exit insert mode
        SwitchToLayer("explorer_insert")
    }
}

/**
 * CopySelectedItemPath - Copy the full path of the selected item
 */
CopySelectedItemPath() {
    itemPath := GetSelectedExplorerItem()
    if (itemPath != "") {
        CopyToClipboard(itemPath, "Item Path")
    } else {
        ShowTooltipFeedback("No item selected", "error")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

/**
 * CopyCurrentDirectory - Copy the current directory path
 */
CopyCurrentDirectory() {
    dirPath := GetActiveExplorerPath()
    if (dirPath != "") {
        CopyToClipboard(dirPath, "Directory")
    } else {
        ShowTooltipFeedback("No Explorer window active", "error")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

/**
 * CopyFileName - Copy only the filename of the selected item
 */
CopyFileName() {
    itemPath := GetSelectedExplorerItem()
    if (itemPath != "") {
        SplitPath(itemPath, &fileName)
        CopyToClipboard(fileName, "Filename")
    } else {
        ShowTooltipFeedback("No item selected", "error")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

/**
 * CreateFileOrFolder - Show GUI to create a file or folder dynamically
 * Detects type based on input: ends with / = folder, has extension = file
 */
CreateFileOrFolder() {
    currentPath := GetActiveExplorerPath()
    if (currentPath == "") {
        ShowTooltipFeedback("No Explorer window active", "error")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    ; Create input box
    ib := InputBox("Enter name (folder/ or file.ext):", "Create File or Folder", "w300 h100")
    if (ib.Result == "Cancel" || ib.Value == "") {
        return
    }
    
    itemName := Trim(ib.Value)
    fullPath := currentPath . "\" . itemName
    
    ; Detect if it's a folder (ends with /) or file (has extension)
    if (SubStr(itemName, -1) == "/" || SubStr(itemName, -1) == "\") {
        ; Create folder
        folderName := SubStr(itemName, 1, -1)  ; Remove trailing slash
        folderPath := currentPath . "\" . folderName
        
        try {
            DirCreate(folderPath)
            ShowTooltipFeedback("Folder created: " . folderName, "success")
            SetTimer(() => RemoveToolTip(), -2000)
        } catch Error as e {
            ShowTooltipFeedback("Error creating folder: " . e.Message, "error")
            SetTimer(() => RemoveToolTip(), -3000)
        }
    } else {
        ; Create file
        try {
            ; Use PowerShell New-Item for file creation
            RunWait('powershell.exe -Command "New-Item -ItemType File -Path \"' . fullPath . '\" -Force"', , "Hide")
            ShowTooltipFeedback("File created: " . itemName, "success")
            SetTimer(() => RemoveToolTip(), -2000)
        } catch Error as e {
            ShowTooltipFeedback("Error creating file: " . e.Message, "error")
            SetTimer(() => RemoveToolTip(), -3000)
        }
    }
}

/**
 * EditInNvim - Open selected file in Nvim
 */
EditInNvim() {
    itemPath := GetSelectedExplorerItem()
    if (itemPath == "") {
        ShowTooltipFeedback("No item selected", "error")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    ; Check if it's a file
    if FileExist(itemPath) && !InStr(FileExist(itemPath), "D") {
        Run('wt.exe nvim "' . itemPath . '"')
    } else {
        ShowTooltipFeedback("Please select a file", "error")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

/**
 * EditInNotepad - Open selected file in Notepad
 */
EditInNotepad() {
    itemPath := GetSelectedExplorerItem()
    if (itemPath == "") {
        ShowTooltipFeedback("No item selected", "error")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    ; Check if it's a file
    if FileExist(itemPath) && !InStr(FileExist(itemPath), "D") {
        Run('notepad.exe "' . itemPath . '"')
    } else {
        ShowTooltipFeedback("Please select a file", "error")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

/**
 * Motions tabs
 */ 
PreviousTab() {
    Send("^+{Tab}")
}

NextTab() {
    Send("^{Tab}")
}

CloseTabAction() {
    Send("^w")
}

NewTabAction() {
    Send("^t")
}

SearchBox() {
    Send("^e")
}

TogglePreviewPane() {
    Send("!p")
}

PermanentlyDelete() {
    Send("+{Delete}")
    SwitchToLayer("delete_confirmation")
}

; ==============================
; MULTISELECT FUNCTIONS (Ctrl+Arrow+Space)
; ==============================

/**
 * MultiSelect Movement Functions
 * These functions send Ctrl+Arrow combinations to maintain multi-select mode
 */
MultiSelectMoveLeft() {
    Send("^{Left}")
}

MultiSelectMoveDown() {
    Send("^{Down}")
}

MultiSelectMoveUp() {
    Send("^{Up}")
}

MultiSelectMoveRight() {
    Send("^{Right}")
}

/**
 * ToggleSelectionWithSpace - Toggle selection on current item while keeping Ctrl pressed
 * This simulates pressing Space while Ctrl is held down
 */
ToggleSelectionWithSpace() {
    Send("^{Space}")
}
; ========================
; Confirmation Dialog Functions
; =======================

YesDeleteConfirmation() {
    ShowTooltipFeedback("Item permanently deleted", "success")
    Send("{Enter}")
    SwitchToLayer("explorer")
}
CancelDeleteConfirmation() {
    ShowTooltipFeedback("Delete cancelled", "info")
    Send("{Esc}")
    SwitchToLayer("explorer")
}

; ==============================
; GO TO FUNCTIONS (Vim-Style Navigation)
; ==============================
; DEPENDENCIES: Requires context_utils.ahk (NavigateExplorer function)
; These functions use NavigateExplorer() for intelligent navigation:
; - If Explorer is active: navigates the current window
; - If Explorer is not active: opens a new window at the target location

; GoToDesktop() {
;     NavigateExplorer(EnvGet("USERPROFILE") . "\Desktop")
; }
;
; GoToHome() {
;     NavigateExplorer(EnvGet("USERPROFILE"))
; }
;
; GoToTemp() {
;     NavigateExplorer(EnvGet("TEMP"))
; }
;
; GoToAppData() {
;     NavigateExplorer(EnvGet("APPDATA"))
; }
;
; GoToLocalAppData() {
;     NavigateExplorer(EnvGet("LOCALAPPDATA"))
; }
;
; GoToProgramFiles() {
;     NavigateExplorer("C:\Program Files")
; }
;
; GoToSystem32() {
;     NavigateExplorer("C:\Windows\System32")
; }
;
; GoToDownloads() {
;     NavigateExplorer(EnvGet("USERPROFILE") . "\Downloads")
; }
;
; GoToDocuments() {
;     NavigateExplorer(EnvGet("USERPROFILE") . "\Documents")
; }
;
; GoToRoot() {
;     NavigateExplorer("C:\")
; }
; ==============================
; LAYER REGISTRATION
; ==============================
RegisterLayer("explorer_visual", "VISUAL MODE", "#ffafcc", "#000000")
RegisterLayer("explorer_insert", "INSERT MODE", "#d0f0c0", "#000000", false)
RegisterLayer("explorer_multiselect", "MULTISELECT", "#ffa500", "#000000")
RegisterLayer("delete_confirmation", "DELETE CONFIRM", "#ff0000", "#ffffff", false)

; ==============================
; KEYMAP REGISTRATION
; ==============================

; --- Global Entry Point ---
RegisterKeymap("leader", "e", "Explorer Mode", () => SwitchToLayer("explorer"), false, 1)

; --- EXPLORER LAYER ---

; Motion Keys
RegisterKeymap("explorer", "h", "Left", VimMoveLeft)
RegisterKeymap("explorer", "j", "Down", VimMoveDown)
RegisterKeymap("explorer", "k", "Up", VimMoveUp)
RegisterKeymap("explorer", "l", "Right", VimMoveRight)

; Motions to Navigate between files alternaive to Arrows, but need view list type
; RegisterKeymap("explorer", "h", "Select Left", () => Send("{backspace}"))
; RegisterKeymap("explorer", "l", "Select Right", () => Send("{Enter}"))

; Go To Category (g + KEY)
RegisterCategoryKeymap("explorer", "g", "Go To", 1) 
RegisterKeymap("explorer", "g", "g", "Top File", VimTopOfFile) 
RegisterKeymap("explorer", "G", "Bottom File", VimBottomOfFile)
; Go To System Folders
RegisterKeymap("explorer", "g", "d", "Desktop", GoToDesktop)
RegisterKeymap("explorer", "g", "h", "Home", GoToHome)
RegisterKeymap("explorer", "g", "t", "Temp", GoToTemp)
RegisterKeymap("explorer", "g", "a", "AppData", GoToAppData)
RegisterKeymap("explorer", "g", "l", "LocalAppData", GoToLocalAppData)
RegisterKeymap("explorer", "g", "p", "Program Files", GoToProgramFiles)
RegisterKeymap("explorer", "g", "s", "System32", GoToSystem32)
RegisterKeymap("explorer", "g", "D", "Downloads", GoToDownloads)
RegisterKeymap("explorer", "g", "c", "Documents", GoToDocuments)
RegisterKeymap("explorer", "g", "r", "Root (C:\)", GoToRoot)
; Motions Tabs 
RegisterKeymap("explorer", "H", "Prev Tab", PreviousTab)
RegisterKeymap("explorer", "L", "Next Tab", NextTab)
; Edit Commands
RegisterKeymap("explorer", "x", "Cut", VimCut)
RegisterKeymap("explorer", "d", "Cut/Delete", VimDelete)
RegisterKeymap("explorer", "D", "Delete Permanently", PermanentlyDelete)
RegisterKeymap("explorer", "y", "Yank line", VimYank)
RegisterKeymap("explorer", "p", "Paste", VimPaste)
RegisterKeymap("explorer", "u", "Undo", VimUndo)
RegisterKeymap("explorer", "R", "Redo", VimRedo)
RegisterKeymap("explorer", "Enter", "Open", () => Send("{Enter}"))
; view commands
RegisterKeymap("explorer", "P", "Toggle preview", TogglePreviewPane)

RegisterKeymap("explorer", "v", "Visual Mode", () => SwitchToLayer("explorer_visual"))
RegisterKeymap("explorer", "Space", "Multiselect Mode", () => SwitchToLayer("explorer_multiselect"))
; Rename action
RegisterKeymap("explorer", "r", "Rename", RenameSelectedItem)

; Search Box
RegisterKeymap("explorer", "/", "Filter", SearchBox)

; Exit to Explorer Layer
RegisterKeymap("explorer", "Escape", "Exit",  ExitCurrentLayer)

; Tab Manager Category
RegisterCategoryKeymap("explorer", "b", "Tab Manager", 4)
RegisterKeymap("explorer", "b", "d", "Close Window", CloseTabAction, false, 1)
RegisterKeymap("explorer", "b", "n", "New Window", NewTabAction, false, 2)
; RegisterKeymap("explorer", "b", "H", "Previous Folder", NavigatePrevious, false, 3)
; RegisterKeymap("explorer", "b", "L", "Next Folder", NavigateNext, false, 4)

; Copy Actions Category
RegisterCategoryKeymap("explorer", "c", "Copy Actions", 3)
RegisterKeymap("explorer", "c", "p", "Copy Path", CopySelectedItemPath, false, 1)
RegisterKeymap("explorer", "c", "d", "Copy Directory", CopyCurrentDirectory, false, 2)
RegisterKeymap("explorer", "c", "f", "Copy Filename", CopyFileName, false, 3)

; File Operations
RegisterKeymap("explorer", ".", "Toggle Hidden", ToggleHiddenFiles)
RegisterKeymap("explorer", "a", "Add File/Folder", CreateFileOrFolder)

; Edit Actions (examples - users can customize)
RegisterCategoryKeymap("explorer", "e", "Edit In", 2)
RegisterKeymap("explorer", "e", "n", "Nvim", EditInNvim, false, 1)
RegisterKeymap("explorer", "e", "t", "Notepad", EditInNotepad, false, 2)

; Exit Explorer Layer
RegisterKeymap("explorer_visual", "h", "Select Left", VimVisualMoveLeft)
RegisterKeymap("explorer_visual", "j", "Select Down", VimVisualMoveDown)
RegisterKeymap("explorer_visual", "k", "Select Up", VimVisualMoveUp)
RegisterKeymap("explorer_visual", "l", "Select Right", VimVisualMoveRight)

RegisterCategoryKeymap("explorer_visual", "g", "Go To", 1) 
RegisterKeymap("explorer_visual", "g", "g", " Select Top File", VimVisualTopOfFile) 
RegisterKeymap("explorer_visual", "G", "Select Bottom", VimVisualBottomOfFile)

RegisterKeymap("explorer_visual", "d", "Cut Selection", VimDelete)
RegisterKeymap("explorer_visual", "x", "Cut Selection", VimCut)
RegisterKeymap("explorer_visual", "y", "Copy Selection", VimYankWithReturn)

RegisterKeymap("explorer_visual", "Escape", "Normal Mode", () => SwitchToLayer("explorer"))
RegisterKeymap("explorer_visual", "v", "Normal Mode", ExitVisualMode)
RegisterKeymap("explorer_insert", "Escape", "Exit Insert Mode",  () => SwitchToLayer("explorer"))

; --- MULTISELECT LAYER ---
RegisterKeymap("explorer_multiselect", "h", "Move Left", MultiSelectMoveLeft)
RegisterKeymap("explorer_multiselect", "j", "Move Down", MultiSelectMoveDown)
RegisterKeymap("explorer_multiselect", "k", "Move Up", MultiSelectMoveUp)
RegisterKeymap("explorer_multiselect", "l", "Move Right", MultiSelectMoveRight)
RegisterKeymap("explorer_multiselect", "Space", "Toggle Selection", ToggleSelectionWithSpace)
RegisterKeymap("explorer_multiselect", "Escape", "Exit Multiselect", () => SwitchToLayer("explorer"))
RegisterKeymap("explorer_multiselect", "x", "Cut", VimCut)
RegisterKeymap("explorer_multiselect", "d", "Cut/Delete", VimDelete)
RegisterKeymap("explorer_multiselect", "D", "Delete Permanently", PermanentlyDelete)
RegisterKeymap("explorer_multiselect", "y", "Yank line", VimYankWithReturn)

; --- DELETE CONFIRMATION LAYER ---
RegisterKeymap("delete_confirmation", "y", "Yes Delete", YesDeleteConfirmation)
RegisterKeymap("delete_confirmation", "n", "No Cancel", CancelDeleteConfirmation)
