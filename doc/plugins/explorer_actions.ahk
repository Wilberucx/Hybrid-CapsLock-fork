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
        ShowCenteredToolTip("Nothing to copy")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    A_Clipboard := text
    ShowCenteredToolTip(label . ": " . text)
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
        ; User can press Esc to exit insert mode
        SwitchToLayer("insert")
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
        ShowCenteredToolTip("No item selected")
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
        ShowCenteredToolTip("No Explorer window active")
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
        ShowCenteredToolTip("No item selected")
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
        ShowCenteredToolTip("No Explorer window active")
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
            ShowCenteredToolTip("Folder created: " . folderName)
            SetTimer(() => RemoveToolTip(), -2000)
        } catch Error as e {
            ShowCenteredToolTip("Error creating folder: " . e.Message)
            SetTimer(() => RemoveToolTip(), -3000)
        }
    } else {
        ; Create file
        try {
            ; Use PowerShell New-Item for file creation
            RunWait('powershell.exe -Command "New-Item -ItemType File -Path \"' . fullPath . '\" -Force"', , "Hide")
            ShowCenteredToolTip("File created: " . itemName)
            SetTimer(() => RemoveToolTip(), -2000)
        } catch Error as e {
            ShowCenteredToolTip("Error creating file: " . e.Message)
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
        ShowCenteredToolTip("No item selected")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    ; Check if it's a file
    if FileExist(itemPath) && !InStr(FileExist(itemPath), "D") {
        Run('wt.exe nvim "' . itemPath . '"')
    } else {
        ShowCenteredToolTip("Please select a file")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

/**
 * EditInNotepad - Open selected file in Notepad
 */
EditInNotepad() {
    itemPath := GetSelectedExplorerItem()
    if (itemPath == "") {
        ShowCenteredToolTip("No item selected")
        SetTimer(() => RemoveToolTip(), -1500)
        return
    }
    
    ; Check if it's a file
    if FileExist(itemPath) && !InStr(FileExist(itemPath), "D") {
        Run('notepad.exe "' . itemPath . '"')
    } else {
        ShowCenteredToolTip("Please select a file")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

; ==============================
; KEYMAP REGISTRATION
; ==============================

; --- Global Entry Point ---
RegisterKeymap("leader", "e", "Explorer Mode", () => SwitchToLayer("explorer"), false, 1)

; --- EXPLORER LAYER ---

RegisterKeymap("explorer", "h", "Left", VimMoveLeft)
RegisterKeymap("explorer", "j", "Down", VimMoveDown)
RegisterKeymap("explorer", "k", "Up", VimMoveUp)
RegisterKeymap("explorer", "l", "Right", VimMoveRight)

RegisterKeymap("explorer", "w", "Word Fwd", VimWordForward)
RegisterKeymap("explorer", "b", "Word Back", VimWordBackward)
RegisterKeymap("explorer", "e", "End Word", VimEndOfWord)

RegisterKeymap("explorer", "0", "Start Line", VimStartOfLine)
RegisterKeymap("explorer", "$", "End Line", VimEndOfLine)

RegisterCategoryKeymap("explorer", "g", "Go To", 1) 
RegisterKeymap("explorer", "g", "g", "Top File", VimTopOfFile) 
RegisterKeymap("explorer", "G", "Bottom File", VimBottomOfFile)

RegisterKeymap("explorer", "x", "Cut Char", VimDelete)
RegisterKeymap("explorer", "d", "Cut/Delete", VimDelete)
RegisterCategoryKeymap("explorer", "y", "Yank menu")
RegisterKeymap("explorer", "y", "y", "Yank line", VimYankLine)
RegisterKeymap("explorer", "y", "0", "Start of Line", VimYankStartLine)
RegisterKeymap("explorer", "y", "$", "End of Line", VimYankEndLine)
RegisterKeymap("explorer", "p", "Paste", VimPaste)
RegisterKeymap("explorer", "u", "Undo", VimUndo)
RegisterKeymap("explorer", "r", "Redo", VimRedo)

RegisterKeymap("explorer", "v", "Visual Mode", EnterVisualMode)
; Rename action
RegisterKeymap("explorer", "r", "Rename (F2)", RenameSelectedItem)

; Tab Manager Category
RegisterCategoryKeymap("explorer", "b", "Tab Manager", 4)
RegisterKeymap("explorer", "b", "d", "Close Window", CloseExplorerWindow, false, 1)
RegisterKeymap("explorer", "b", "n", "New Window", NewExplorerWindow, false, 2)
RegisterKeymap("explorer", "b", "H", "Previous Folder", NavigatePrevious, false, 3)
RegisterKeymap("explorer", "b", "L", "Next Folder", NavigateNext, false, 4)

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
RegisterKeymap("explorer", "Esc", "Exit Explorer", () => DeactivateLayer("explorer"))
