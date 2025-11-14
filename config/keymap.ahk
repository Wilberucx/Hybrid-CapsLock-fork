; ==============================
; Keymap Configuration - Configuration of keymaps and categories and layers activation
; ==============================

; ==============================
; GLOBAL LAYER ACTIVATION HOTKEYS
; ==============================
; External triggers from Kanata

#SuspendExempt
#HotIf (LeaderLayerEnabled)
F24:: ActivateLeaderLayer()    ; CapsLock+Space → Leader
#HotIf

#HotIf (NvimLayerEnabled)
F23:: ActivateNvimLayer()       ; CapsLock Tap → Nvim (toggle)
#HotIf
#SuspendExempt False

InitializeCategoryKeymaps() {
    ; ==============================
    ; 1. CATEGORÍAS PRINCIPALES EN LEADER
    ; ==============================
    RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
    RegisterCategoryKeymap("leader", "t", "Timestamps", 2)
    RegisterCategoryKeymap("leader", "c", "Commands", 3)
    RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)
    RegisterKeymap("leader", "e", "Excel", ActivateExcelLayer, false, 5)
    RegisterCategoryKeymap("leader", "p", "Programs", 7)
    RegisterCategoryKeymap("leader", "o", "Power Options", 8)
    RegisterCategoryKeymap("leader", "i", "Information", 9)
    ; ==============================
    ; 2. SUBCATEGORÍAS 
    ; ==============================
    
    ; Leader → c
    RegisterCategoryKeymap("leader", "c", "s", "System Commands", 1)
    RegisterCategoryKeymap("leader", "c", "g", "Git Commands", 3)
    RegisterCategoryKeymap("leader", "c", "m", "Monitoring Commands", 4)
    RegisterCategoryKeymap("leader", "c", "n", "Network Commands", 5)
    RegisterCategoryKeymap("leader", "c", "f", "Folder Access", 6)
    RegisterCategoryKeymap("leader", "c", "a", "ADB Tools", 7)
    RegisterCategoryKeymap("leader", "c", "v", "VaultFlow", 8)
    
    ; Leader → t 
    RegisterCategoryKeymap("leader", "t", "d", "Date Formats", 1)
    RegisterCategoryKeymap("leader", "t", "t", "Time Formats", 2)
    RegisterCategoryKeymap("leader", "t", "h", "Date+Time Formats", 3)
    
    ; Programas (leader → p → KEY)
    RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
    RegisterKeymap("leader", "p", "i", "Settings", ShellExec("ms-settings:"), false, 1)
    RegisterKeymap("leader", "p", "t", "Terminal", ShellExec("wt.exe", "Show"), false, 1)
    RegisterKeymap("leader", "p", "n", "Notepad", ShellExec("notepad.exe"), false, 1)
    RegisterKeymap("leader", "p", "b", "Vivaldi", ShellExec(EnvGet("USERPROFILE") . "\AppData\Local\Vivaldi\Application\vivaldi.exe"), false, 1)
    RegisterKeymap("leader", "p", "z", "Zen Browser", ShellExec("C:\Program Files\Zen Browser\zen.exe"), false, 1)
    RegisterKeymap("leader", "p", "m", "Thunderbird", ShellExec("Thunderbird.exe"), false, 1)
    RegisterKeymap("leader", "p", "w", "WezTerm", ShellExec("C:\Program Files\WezTerm\wezterm-gui.exe", "Show"), false, 1)
    RegisterKeymap("leader", "p", "l", "WSL", ShellExec("wsl.exe", "Show"), false, 1)
    RegisterKeymap("leader", "p", "r", "Beeper", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Beeper.lnk"), false, 1)
    RegisterKeymap("leader", "p", "q", "Quick Share", ShellExec("QuickShare.exe"), false, 1)
    RegisterKeymap("leader", "p", "p", "Bitwarden", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Bitwarden.lnk"), false, 1)
    RegisterKeymap("leader", "p", "k", "LocalSend", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LocalSend.lnk"), false, 1)
    
    ; Category timestamps (leader → t → KEY)
    RegisterKeymap("leader", "t", "d", "1", "yyyy-MM-dd", InsertDateFormat1, false, 1)
    RegisterKeymap("leader", "t", "d", "2", "dd/MM/yyyy", InsertDateFormat2, false, 2)
    RegisterKeymap("leader", "t", "d", "3", "MM/dd/yyyy", InsertDateFormat3, false, 3)
    RegisterKeymap("leader", "t", "d", "4", "dd-MMM-yyyy", InsertDateFormat4, false, 4)
    RegisterKeymap("leader", "t", "d", "5", "ddd, dd MMM yyyy", InsertDateFormat5, false, 5)
    RegisterKeymap("leader", "t", "d", "6", "yyyyMMdd", InsertDateFormat6, false, 6)
    RegisterKeymap("leader", "t", "d", "d", "Default (yyyyMMdd)", InsertDateDefault, false, 7)
    
    ; Time formats (leader → t → t → KEY)
    RegisterKeymap("leader", "t", "t", "1", "HH:mm:ss", InsertTimeFormat1, false, 1)
    RegisterKeymap("leader", "t", "t", "2", "HH:mm", InsertTimeFormat2, false, 2)
    RegisterKeymap("leader", "t", "t", "3", "hh:mm tt", InsertTimeFormat3, false, 3)
    RegisterKeymap("leader", "t", "t", "4", "HHmmss", InsertTimeFormat4, false, 4)
    RegisterKeymap("leader", "t", "t", "5", "HH.mm.ss", InsertTimeFormat5, false, 5)
    RegisterKeymap("leader", "t", "t", "t", "Default (HHmmss)", InsertTimeDefault, false, 6)
    
    ; DateTime formats (leader → t → h → KEY)
    RegisterKeymap("leader", "t", "h", "1", "yyyy-MM-dd HH:mm:ss", InsertDateTimeFormat1, false, 1)
    RegisterKeymap("leader", "t", "h", "2", "dd/MM/yyyy HH:mm", InsertDateTimeFormat2, false, 2)
    RegisterKeymap("leader", "t", "h", "3", "yyyy-MM-dd HH:mm:ss", InsertDateTimeFormat3, false, 3)
    RegisterKeymap("leader", "t", "h", "4", "yyyyMMddHHmmss", InsertDateTimeFormat4, false, 4)
    RegisterKeymap("leader", "t", "h", "5", "ddd, dd MMM yyyy HH:mm", InsertDateTimeFormat5, false, 5)
    RegisterKeymap("leader", "t", "h", "h", "Default (yyyyMMddHHmmss)", InsertDateTimeDefault, false, 6)
    
    ; Hybrid Management (leader → h → KEY)
    RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
    RegisterKeymap("leader", "h", "s", "Show System Status", ShowSystemStatus, false, 2)
    RegisterKeymap("leader", "h", "v", "Show Version Info", ShowVersionInfo, false, 3)
    RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 4)
    RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 5)
    RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 6)
    RegisterKeymap("leader", "h", "S", "Scan Layers", ScanLayersManual, false, 7)
    RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 8)
    RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 9)
    
    ; System Commands (leader → c → s → KEY)
    RegisterKeymap("leader", "c", "s", "s", "System Info", ShowSystemInfo, false, 1)
    RegisterKeymap("leader", "c", "s", "t", "Task Manager", ShowTaskManager, false, 2)
    RegisterKeymap("leader", "c", "s", "v", "Services Manager", ShowServicesManager, false, 3)
    RegisterKeymap("leader", "c", "s", "e", "Event Viewer", ShowEventViewer, false, 4)
    RegisterKeymap("leader", "c", "s", "d", "Device Manager", ShowDeviceManager, false, 5)
    RegisterKeymap("leader", "c", "s", "c", "Disk Cleanup", ShowDiskCleanup, false, 6)
    RegisterKeymap("leader", "c", "s", "h", "Toggle Hidden Files", ToggleHiddenFiles, false, 7)
    RegisterKeymap("leader", "c", "s", "r", "Registry Editor", ShowRegistryEditor, false, 8)
    RegisterKeymap("leader", "c", "s", "E", "Environment Variables", ShowEnvironmentVariables, false, 9)
    RegisterKeymap("leader", "c", "s", "w", "Windows Version", ShowWindowsVersion, false, 10)
    
    ; Git Commands (leader → c → g → KEY)
    RegisterKeymap("leader", "c", "g", "s", "Status", GitStatus, false, 1)
    RegisterKeymap("leader", "c", "g", "l", "Log (last 10)", GitLog, false, 2)
    RegisterKeymap("leader", "c", "g", "b", "Branches", GitBranches, false, 3)
    RegisterKeymap("leader", "c", "g", "d", "Diff", GitDiff, false, 4)
    RegisterKeymap("leader", "c", "g", "a", "Add All", GitAddAll, true, 5)
    RegisterKeymap("leader", "c", "g", "p", "Pull", GitPull, true, 6)
    
    ; Monitoring Commands (leader → c → m → KEY)
    RegisterKeymap("leader", "c", "m", "p", "Top Processes", ShowTopProcesses, false, 1)
    RegisterKeymap("leader", "c", "m", "s", "Services Status", ShowServicesStatus, false, 2)
    RegisterKeymap("leader", "c", "m", "d", "Disk Space", ShowDiskSpace, false, 3)
    RegisterKeymap("leader", "c", "m", "m", "Memory Usage", ShowMemoryUsage, false, 4)
    RegisterKeymap("leader", "c", "m", "c", "CPU Usage", ShowCPUUsage, false, 5)
    
    ; Network Commands (leader → c → n → KEY)
    RegisterKeymap("leader", "c", "n", "i", "IP Config", ShowIPConfig, false, 1)
    RegisterKeymap("leader", "c", "n", "p", "Ping Google", PingGoogle, false, 2)
    RegisterKeymap("leader", "c", "n", "n", "Netstat", ShowNetstat, false, 3)
    
    ; Folder Access (leader → c → f → KEY)
    RegisterKeymap("leader", "c", "f", "t", "Temp Folder", OpenTempFolder, false, 1)
    RegisterKeymap("leader", "c", "f", "a", "AppData", OpenAppDataFolder, false, 2)
    RegisterKeymap("leader", "c", "f", "p", "Program Files", OpenProgramFilesFolder, false, 3)
    RegisterKeymap("leader", "c", "f", "u", "User Profile", OpenUserProfileFolder, false, 4)
    RegisterKeymap("leader", "c", "f", "d", "Desktop", OpenDesktopFolder, false, 5)
    RegisterKeymap("leader", "c", "f", "s", "System32", OpenSystem32Folder, false, 6)
    
    ; Power Options (leader → c → o → KEY)
    RegisterKeymap("leader", "o", "l", "Lock Screen", LockWorkstation, false, 1)
    RegisterKeymap("leader", "o", "s", "Sleep", SuspendSystem, false, 2)
    RegisterKeymap("leader", "o", "h", "Hibernate", HibernateSystem, false, 3)
    RegisterKeymap("leader", "o", "o", "Sign Out", SignOutUser, true, 4)
    RegisterKeymap("leader", "o", "r", "Restart", RestartSystem, true, 5)
    RegisterKeymap("leader", "o", "S", "Shutdown", ShutdownSystem, true, 6)
    
    ; Adb Tools (leader → c → a → KEY)
    RegisterKeymap("leader", "c", "a", "d", "List Devices", ADBListDevices, false, 1)
    RegisterKeymap("leader", "c", "a", "x", "Disconnect", ADBDisconnect, false, 2)
    RegisterKeymap("leader", "c", "a", "s", "Shell", ADBShell, false, 3)
    RegisterKeymap("leader", "c", "a", "l", "Logcat", ADBLogcat, false, 4)
    RegisterKeymap("leader", "c", "a", "i", "Install APK", ADBInstallAPK, false, 5)
    RegisterKeymap("leader", "c", "a", "u", "Uninstall Package", ADBUninstallPackage, false, 6)
    RegisterKeymap("leader", "c", "a", "c", "Clear App Data", ADBClearAppData, false, 7)
    RegisterKeymap("leader", "c", "a", "r", "Reboot Device", ADBRebootDevice, false, 8)
    
    ; VualtFlow (leader → c → v → KEY)
    RegisterKeymap("leader", "c", "v", "v", "Run VaultFlow", RunVaultFlow, false, 1)
    RegisterKeymap("leader", "c", "v", "s", "Status", VaultFlowStatus, false, 2)
    RegisterKeymap("leader", "c", "v", "l", "List", VaultFlowList, false, 3)
    RegisterKeymap("leader", "c", "v", "h", "Help", VaultFlowHelp, false, 4)
    
    ; Information (leader → i → KEY)
    RegisterKeymap("leader", "i", "e", "Email", SendInfo("tu.email@example.com", "EMAIL INSERTED"), false, 1)
    RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-123-4567", "PHONE INSERTED"), false, 2)
    RegisterKeymap("leader", "i", "n", "Name", SendInfo("Tu Nombre Completo", "NAME INSERTED"), false, 3)
    RegisterKeymap("leader", "i", "a", "Address", SendInfo("123 Main St, City, State 12345", "ADDRESS INSERTED"), false, 4)
    RegisterKeymap("leader", "i", "h", "Hola", SendInfo("Hola, cómo estás?", "TEXT INSERTED"), false, 5)
    RegisterKeymap("leader", "i", "t", "Thanks", SendInfo("Muchas gracias por tu ayuda!", "TEXT INSERTED"), false, 6)
    RegisterKeymap("leader", "i", "g", "Good morning", SendInfo("Good morning! How are you?", "TEXT INSERTED"), false, 7)
    RegisterKeymap("leader", "i", "s", "Signature", SendInfoMultiline(["Saludos cordiales,", "Tu Nombre", "Tu Cargo/Empresa"], "SIGNATURE INSERTED"), false, 8)
    ; ==============================
    ; PERSISTENT LAYERS KEYMAPS
    ; ==============================
    
    ; === SCROLL LAYER ===
    RegisterKeymap("scroll", "k", "Scroll Up", ScrollUp, false, 1)
    RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false, 2)
    RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false, 3)
    RegisterKeymap("scroll", "l", "Scroll Right", ScrollRight, false, 4)
    RegisterKeymap("scroll", "s", "Exit Scroll Layer", ScrollExit, false, 10)
    RegisterKeymap("scroll", "Escape", "Exit Scroll Layer", ScrollExit, false, 11)
    RegisterKeymap("scroll", "?", "Toggle Help", ScrollToggleHelp, false, 20)
    
    ; === NVIM LAYER (Basic keymaps - Complex logic moved to no_include/) ===
    ; Layer switching
    RegisterKeymap("nvim", "v", "Visual Mode", () => SwitchToLayer("visual", "nvim"), false, 1)
    RegisterKeymap("nvim", "i", "Insert Mode", () => SwitchToLayer("insert", "nvim"), false, 2)
    RegisterKeymap("nvim", "I", "Insert at Beginning", NvimInsertAtBeginning, false, 3)
    
    ; Line navigation
    RegisterKeymap("nvim", "0", "Start of Line", VimStartOfLine, false, 10)
    RegisterKeymap("nvim", "$", "End of Line", VimEndOfLine, false, 11)
    
    ; Basic navigation (hjkl)
    RegisterKeymap("nvim", "h", "Move Left", VimMoveLeft, false, 20)
    RegisterKeymap("nvim", "j", "Move Down", VimMoveDown, false, 21)
    RegisterKeymap("nvim", "k", "Move Up", VimMoveUp, false, 22)
    RegisterKeymap("nvim", "l", "Move Right", VimMoveRight, false, 23)
    
    ; Word navigation
    RegisterKeymap("nvim", "w", "Word Forward", VimWordForward, false, 30)
    RegisterKeymap("nvim", "b", "Word Backward", VimWordBackward, false, 31)
    RegisterKeymap("nvim", "e", "End of Word", VimEndOfWord, false, 32)
    
    ; Document navigation
    RegisterCategoryKeymap("nvim", "g", "Go to", 1)
    RegisterKeymap("nvim", "g", "g", "Go to Top", VimTopOfFile, false, 41)
    RegisterKeymap("nvim", "G", "Go to Bottom", VimBottomOfFile, false, 41)
    
    ; Edit operations
    RegisterKeymap("nvim", "d", "Delete", () => Send("{Delete}"), false, 50)
    RegisterKeymap("nvim", "y", "Yank", NvimYankWithNotification, false, 51)
    RegisterKeymap("nvim", "p", "Paste", VimPaste, false, 52)
    RegisterKeymap("nvim", "P", "Paste Plain", VimPastePlain, false, 53)
    RegisterKeymap("nvim", "x", "Cut", () => Send("^x"), false, 54)
    RegisterKeymap("nvim", "u", "Undo", VimUndo, false, 55)
    RegisterKeymap("nvim", "r", "Redo", VimRedo, false, 56)
    
    ; Special
    RegisterKeymap("nvim", "f", "Quick Exit", NvimExit, false, 71)
    RegisterKeymap("nvim", "Escape", "Exit", NvimExit, false, 72)
    RegisterKeymap("nvim", "?", "Toggle Help", NvimToggleHelp, false, 73)

    ; Excel Layer Keymaps
    ; Navigation
    RegisterKeymap("excel", "h", "Move Left", VimMoveLeft, false, 20)
    RegisterKeymap("excel", "j", "Move Down", VimMoveDown, false, 21)
    RegisterKeymap("excel", "k", "Move Up", VimMoveUp, false, 22)
    RegisterKeymap("excel", "l", "Move Right", VimMoveRight, false, 23)
    
    ; Go to commands
    RegisterCategoryKeymap("excel", "g", "Go to", 1)
    RegisterKeymap("excel", "g", "g", "Go to Top", VimTopOfFile, false, 41)
    RegisterKeymap("excel", "G", "Go to Bottom", VimBottomOfFile, false, 42)
    
    ; Edit operations
    RegisterKeymap("excel", "p", "Paste", VimPaste, false, 52)
    RegisterKeymap("excel", "u", "Undo", VimUndo, false, 55)
    RegisterKeymap("excel", "r", "Redo", VimRedo, false, 56)
    ; Switch to visual layer for selection
    RegisterKeymap("excel", "v", "Visual", ()=> SwitchToLayer("visual", "excel"), false, 52)
    
    ; Layer control
    RegisterKeymap("excel", "Escape", "Exit", ExcelExit, false, 72)
    RegisterKeymap("excel", "?", "Toggle Help", ExcelToggleHelp, false, 73)
    RegisterKeymap("excel", "E", "Exit", ExcelExit, false, 72)

    ; === VISUAL LAYER ===
    ; Basic navigation with selection (vim visual mode)
    RegisterKeymap("visual", "h", "Move Left (Select)", VimVisualMoveLeft, false, 20)
    RegisterKeymap("visual", "j", "Move Down (Select)", VimVisualMoveDown, false, 21)
    RegisterKeymap("visual", "k", "Move Up (Select)", VimVisualMoveUp, false, 22)
    RegisterKeymap("visual", "l", "Move Right (Select)", VimVisualMoveRight, false, 23)
    
    ; Word navigation with selection
    RegisterKeymap("visual", "w", "Word Forward (Select)", VimVisualWordForward, false, 30)
    RegisterKeymap("visual", "b", "Word Backward (Select)", VimVisualWordBackward, false, 31)
    RegisterKeymap("visual", "e", "End of Word (Select)", VimVisualEndOfWord, false, 32)
    
    ; Line navigation with selection
    RegisterKeymap("visual", "0", "Start of Line (Select)", VimVisualStartOfLine, false, 10)
    RegisterKeymap("visual", "$", "End of Line (Select)", VimVisualEndOfLine, false, 11)
    
    ; Document navigation with selection
    RegisterCategoryKeymap("visual", "g", "Go to", 1)
    RegisterKeymap("visual", "g", "g", "Go to Top (Select)", VimVisualTopOfFile, false, 41)
    RegisterKeymap("visual", "G", "Go to Bottom (Select)", VimVisualBottomOfFile, false, 42)
    
    ; Page navigation with selection
    RegisterKeymap("visual", "d", "Page Down (Select)", VimVisualPageDown, false, 45)
    RegisterKeymap("visual", "u", "Page Up (Select)", VimVisualPageUp, false, 46)
    
    ; Text object selection
    RegisterCategoryKeymap("visual", "i", "Inside", 2)
    RegisterKeymap("visual", "i", "w", "Inside Word", VimVisualInsideWord, false, 50)
    RegisterCategoryKeymap("visual", "a", "Around", 3)
    RegisterKeymap("visual", "a", "w", "Around Word", VimVisualAroundWord, false, 51)
    
    ; Edit operations on selection
    RegisterKeymap("visual", "y", "Yank Selection", () => Send("^c"), false, 60)
    RegisterKeymap("visual", "x", "Cut Selection", () => Send("^x"), false, 61)
    RegisterKeymap("visual", "p", "Paste", VimPaste, false, 62)
    
    ; Layer control
    RegisterKeymap("visual", "Escape", "Exit", VisualExit , false, 72)
    RegisterKeymap("visual", "?", "Toggle Help", VisualToggleHelp, false, 73)
    
    ; REMOVED (Complex logic moved to no_include/nvim_layer_LEGACY.ahk):
    ; - ColonLogic (:w, :q, :wq)
    ; - GLogic (gg for top)
    ; - Alt-modified (!h, !j, !k, !l)
    ; - Ctrl-modified (^u, ^d)
    ; - Conditional key behavior
    
    ; LoadActionKeymapFallbacks()
}

; LoadActionKeymapFallbacks() {
;     ; Cargar todos los keymaps de actions como fallback
;     ; (Solo se registrarán los que NO existen ya gracias al sistema de prioridad)
;     RegisterHybridKeymaps()
;     RegisterSystemKeymaps()
;     RegisterNetworkKeymaps()
;     RegisterGitKeymaps()
;     RegisterMonitoringKeymaps()
;     RegisterFolderKeymaps()
;     RegisterPowerKeymaps()
;     RegisterADBKeymaps()
;     RegisterVaultFlowKeymaps()
;     RegisterTimestampKeymaps()
;     RegisterWindowsKeymaps()
;     RegisterScrollKeymaps()
; }

