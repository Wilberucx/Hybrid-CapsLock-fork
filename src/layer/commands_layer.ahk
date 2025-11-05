; ==============================
; Commands Layer (main menu only - step 1)
; ==============================
; Builds and shows the Commands main menu. Category handling will be added in step 2.
; Depends on: globals (CommandsIni), ui (tooltips), core/config (GetEffectiveTimeout)

BuildCommandsMainMenuText() {
    global CommandsIni
    text := ""
    order := IniRead(CommandsIni, "Categories", "order", "")
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            name := IniRead(CommandsIni, k . "_category", "title", "")
            if (name = "" || name = "ERROR")
                name := IniRead(CommandsIni, "Categories", k, "")
            if (name != "" && name != "ERROR")
                text .= k . " - " . name . "`n"
        }
    }
    return text
}

ShowCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "COMMAND PALETTE`n`n"
        configText := BuildCommandsMainMenuText()
        if (configText != "") {
            menuText .= configText
        } else {
            hasConfigMenu := false
            Loop 20 {
                lineContent := IniRead(CommandsIni, "MenuDisplay", "main_line" . A_Index, "")
                if (lineContent != "" && lineContent != "ERROR") {
                    menuText .= lineContent . "`n"
                    hasConfigMenu := true
                }
            }
            if (!hasConfigMenu) {
                menuText .= "s - System Commands`n"
                menuText .= "n - Network Commands`n"
                menuText .= "g - Git Commands`n"
                menuText .= "m - Monitoring Commands`n"
                menuText .= "f - Folder Commands`n"
                menuText .= "o - Power Options`n"
                menuText .= "a - ADB Tools`n"
                menuText .= "v - VaultFlow`n"
                menuText .= "h - Hybrid Management`n"
            }
        }
        menuText .= "`n[Backspace: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ---- Dynamic category menu (new schema) ----
ShowDynamicCommandsMenu(catKey) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ; In C# mode, category menus are handled by *_CS functions
        return
    }
    global CommandsIni
    sec := catKey . "_category"
    title := IniRead(CommandsIni, sec, "title", "")
    if (title = "" || title = "ERROR")
        title := IniRead(CommandsIni, "Categories", catKey, "COMMANDS")
    order := IniRead(CommandsIni, sec, "order", "")
    if (order = "" || order = "ERROR") {
        ; Fallback to simple order from Categories if present
        order := IniRead(CommandsIni, "Categories", catKey, "")
    }
    ToolTipX := A_ScreenWidth // 2 - 120
    ToolTipY := A_ScreenHeight // 2 - 100
    menuText := title . "`n`n"
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            itemTitle := IniRead(CommandsIni, sec, k, "")
            if (itemTitle != "" && itemTitle != "ERROR")
                menuText .= k . " - " . itemTitle . "`n"
            else
                menuText .= k . " - [Missing mapping in [" . sec . "]]" . "`n"
        }
    } else if (catKey = "h") {
        ; Fallback default for Hybrid Management if INI is missing
        menuText .= "R - Reload Script`n"
        menuText .= "c - Open Config Folder`n"
        menuText .= "l - View Log File`n"
        menuText .= "v - Version Info`n"
        menuText .= "e - Exit Script`n"
    } else {
        menuText .= "[Missing order in [" . sec . "]]" . "`n"
    }
    menuText .= "`n[Backspace: Back] [Esc: Exit]"
    ToolTip(menuText, ToolTipX, ToolTipY, 2)
}

; ---- Category submenus (step 2: System + Network) ----
ShowSystemCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowSystemCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "SYSTEM COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "system_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[Backspace: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowNetworkCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowNetworkCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 70
        menuText := "NETWORK COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "network_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[Backspace: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowGitCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowGitCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "GIT COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "git_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[Backspace: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowMonitoringCommandsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowMonitoringCommandsMenuCS()
    } else {
        global CommandsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 90
        menuText := "MONITORING COMMANDS`n`n"
        Loop 10 {
            lineContent := IniRead(CommandsIni, "MenuDisplay", "monitoring_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[Backspace: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ---- Executors ----
ShowCommandExecuted(category, command) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCommandExecutedCS(category, command)
    } else {
        ShowCenteredToolTip(category . " command executed: " . command)
        SetTimer(() => RemoveToolTip(), -2000)
    }
}

ExecuteSystemCommand(cmd) {
    ; Auto-hide tooltip first if configured
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        ; Core system
        case "s": Run("cmd.exe /k systeminfo")
        case "t": Run("taskmgr.exe")
        case "v": Run("services.msc")
        case "d": Run("devmgmt.msc")
        case "c": Run("cleanmgr.exe")
        ; Former Windows commands now native in System
        case "h":
            ToggleHiddenFiles()
            ShowCommandExecuted("System", "Toggle Hidden Files")
            return
        case "r":
            Run("regedit.exe")
            ShowCommandExecuted("System", "Registry Editor")
            return
        case "E":
            Run("rundll32.exe sysdm.cpl,EditEnvironmentVariables")
            ShowCommandExecuted("System", "Environment Variables")
            return
        case "e":
            try {
                Run(EnvGet("SystemRoot") . "\\system32\\eventvwr.msc")
            } catch {
                try Run("eventvwr.msc")
            }
        default:
            ShowCenteredToolTip("Unknown system command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("System", cmd)
}

ExecuteNetworkCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "i": Run("cmd.exe /k ipconfig /all")
        case "p": Run("cmd.exe /k ping google.com")
        case "n": Run("cmd.exe /k netstat -an")
        default:
            ShowCenteredToolTip("Unknown network command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Network", cmd)
}

; ---- Dynamic category dispatcher (new schema) ----
HandleCommandCategory(catKey) {
    k := StrLower(Trim(catKey))
    ; Show dynamic category menu for native tooltips
    if (!(IsSet(tooltipConfig) && tooltipConfig.enabled)) {
        ShowDynamicCommandsMenu(k)
    } else {
        ; In C# mode (handleInput=false), mostramos el submenú correspondiente
        switch k {
            case "s": ShowSystemCommandsMenuCS()
            case "n": ShowNetworkCommandsMenuCS()
            case "g": ShowGitCommandsMenuCS()
            case "m": ShowMonitoringCommandsMenuCS()
            case "f": ShowFolderCommandsMenuCS()
            case "o": ShowPowerOptionsCommandsMenuCS()
            case "a": ShowADBCommandsMenuCS()
            case "v": ShowVaultFlowCommandsMenuCS()
            case "h": ShowHybridManagementMenuCS()
            default:
                ; Si categoría no reconocida, continuar flujo normal
        }
    }
    ih := InputHook("L1 T" . GetEffectiveTimeout("commands"), "{Escape}{Backspace}")
ih.KeyOpt("{Escape}", "S")
ih.KeyOpt("{Backspace}", "S")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey") {
        if (ih.EndKey = "Backspace") {
            ih.Stop()
            if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                ShowLeaderModeMenuCS()
            }
            return "BACK"
        }
        if (ih.EndKey = "Escape") {
            ih.Stop()
            return "EXIT"
        }
        ih.Stop()
        return
    }
    key := ih.Input
    ih.Stop()
    if (key = "\\") {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowLeaderModeMenuCS()
        }
        return "BACK"
    }
    if (key = "" || key = Chr(0))
        return

    categoryInternal := ""
    global CommandsIni
    ; Prefer key-based mapping first for reliability, then fall back to title-based
    categoryInternal := SymToInternal(k)
    if (categoryInternal = "") {
        title := IniRead(CommandsIni, "Categories", k, "")
        if (title != "" && title != "ERROR")
            categoryInternal := NormalizeCategoryToken(title)
    }
    if (categoryInternal = "") {
        HideMenuTooltip()
        ShowCenteredToolTip("Unknown category: '" . k . "'")
        SetTimer(() => RemoveToolTip(), -1200)
        return
    }

    ; First try dynamic action resolution based on new schema
    if (ResolveAndExecuteCustomAction(categoryInternal, key))
        return

    ; Fallback to hardcoded executors for migrated categories
    switch categoryInternal {
        case "system":
            ExecuteSystemCommand(key)
        case "network":
            ExecuteNetworkCommand(key)
        case "git":
            ExecuteGitCommand(key)
        case "monitoring":
            ExecuteMonitoringCommand(key)
        case "folder":
            ExecuteFolderCommand(key)
        case "power":
            ExecutePowerOptionsCommand(key)
        case "adb":
            ExecuteADBCommand(key)
        case "vaultflow":
            ExecuteVaultFlowCommand(key)
        case "hybrid":
            ExecuteHybridManagementCommand(key)
        default:
            HideMenuTooltip()
            ShowCenteredToolTip("Category '" . categoryInternal . "' not implemented yet")
            SetTimer(() => RemoveToolTip(), -1200)
    }
}

ExecutePowerOptionsCommand(cmd) {
    ; Ask confirmation for power actions by default (configurable via INI)
    if (ShouldConfirmCommand("power", cmd)) {
        if (!ConfirmYN("Execute power action?", "commands"))
            return
    }
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "s": ; Sleep
            DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
            ShowCommandExecuted("Power", "Sleep")
        case "h": ; Hibernate
            DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
            ShowCommandExecuted("Power", "Hibernate")
        case "r": ; Restart
            Run("shutdown.exe /r /t 0")
            ShowCommandExecuted("Power", "Restart")
        case "S": ; Shutdown (Shift+s)
            Run("shutdown.exe /s /t 0")
            ShowCommandExecuted("Power", "Shutdown")
        case "l": ; Lock Screen
            DllCall("user32\LockWorkStation")
            ShowCommandExecuted("Power", "Lock Screen")
        case "o": ; Sign Out
            Run("shutdown.exe /l")
            ShowCommandExecuted("Power", "Sign Out")
        default:
            ShowCenteredToolTip("Unknown power command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
}

ExecuteADBCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "d": Run("cmd.exe /k adb devices"), ShowCommandExecuted("ADB", "List Devices")
        case "i": Run("cmd.exe /k echo Select APK file to install && pause && adb install"), ShowCommandExecuted("ADB", "Install APK")
        case "u": Run("cmd.exe /k echo Enter package name to uninstall && pause && adb uninstall"), ShowCommandExecuted("ADB", "Uninstall Package")
        case "l": Run("cmd.exe /k adb logcat"), ShowCommandExecuted("ADB", "Logcat")
        case "s": Run("cmd.exe /k adb shell"), ShowCommandExecuted("ADB", "Shell")
        case "r": Run("cmd.exe /k adb reboot"), ShowCommandExecuted("ADB", "Reboot Device")
        case "c": Run("cmd.exe /k echo Enter package name to clear data && pause && adb shell pm clear"), ShowCommandExecuted("ADB", "Clear App Data")
        default:
            ShowCenteredToolTip("Unknown ADB command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
}

ExecuteVaultFlowCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "v": Run("powershell.exe -Command `"vaultflow`""), ShowCommandExecuted("VaultFlow", "Run VaultFlow")
        case "s": Run("cmd.exe /k vaultflow status"), ShowCommandExecuted("VaultFlow", "Status")
        case "l": Run("cmd.exe /k vaultflow list"), ShowCommandExecuted("VaultFlow", "List")
        case "h": Run("cmd.exe /k vaultflow --help"), ShowCommandExecuted("VaultFlow", "Help")
        default:
            ShowCenteredToolTip("Unknown VaultFlow command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
}

ExecuteHybridManagementCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "R": ; Reload Script
            if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                try ShowCSharpStatusNotification("HYBRID", "RELOADING...")
                Sleep(600)
            } else {
                ShowCenteredToolTip("RELOADING SCRIPT...")
                SetTimer(() => RemoveToolTip(), -600)
                Sleep(600)
            }
            try StopTooltipApp()
            Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '"')
            ExitApp()
        case "e": ; Exit Script
            if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                try ShowCSharpStatusNotification("HYBRID", "EXITING...")
                Sleep(500)
                try StopTooltipApp()
            } else {
                ShowCenteredToolTip("EXITING SCRIPT...")
                SetTimer(() => RemoveToolTip(), -600)
                Sleep(600)
            }
            ExitApp()
        case "c": ; Open Config Folder
            Run('explorer.exe "' . A_ScriptDir . '\\config"')
            ShowCommandExecuted("Hybrid", "Config Folder")
        case "l": ; View Log File
            logFile := A_ScriptDir . "\\hybrid_log.txt"
            if (FileExist(logFile)) {
                Run('notepad.exe "' . logFile . '"')
                ShowCommandExecuted("Hybrid", "Log File")
            } else {
                ShowCenteredToolTip("No log file found")
                SetTimer(() => RemoveToolTip(), -1500)
                return
            }
        case "v": ; Show Version Info
            ShowCenteredToolTip("HybridCapsLock")
            SetTimer(() => RemoveToolTip(), -1500)
        case "p": ; Hybrid Pause (auto timer + resume on Leader)
            ToggleHybridPause()
            return
       default:
            ShowCenteredToolTip("Unknown hybrid command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
}

ExecuteFolderCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "t": Run('explorer.exe "' . EnvGet("TEMP") . '"')
        case "a": Run('explorer.exe "' . EnvGet("APPDATA") . '"')
        case "p": Run('explorer.exe "C:\\Program Files"')
        case "u": Run('explorer.exe "' . EnvGet("USERPROFILE") . '"')
        case "d": Run('explorer.exe "' . EnvGet("USERPROFILE") . '\\Desktop"')
        case "s": Run('explorer.exe "C:\\Windows\\System32"')
        default:
            ShowCenteredToolTip("Unknown folder command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Folder", cmd)
}


; ---- Hybrid Pause helpers ----
ToggleHybridPause() {
    global hybridPauseActive, hybridPauseMinutes
    if (!hybridPauseActive && !A_IsSuspended) {
        ; Start hybrid pause
        Suspend(1)
        hybridPauseActive := true
        mins := (IsSet(hybridPauseMinutes) && hybridPauseMinutes > 0) ? hybridPauseMinutes : 10
        try SetTimer(HybridAutoResumeTimer, -(mins * 60000))
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("HYBRID", "SUSPENDED " . mins . "m — press Leader to resume")
        } else {
            ShowCenteredToolTip("SUSPENDED " . mins . "m — press Leader to resume")
            SetTimer(() => RemoveToolTip(), -1500)
        }
    } else {
        ; Already suspended -> resume now
        try SetTimer(HybridAutoResumeTimer, 0)
        Suspend(0)
        hybridPauseActive := false
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("HYBRID", "RESUMED")
        } else {
            ShowCenteredToolTip("RESUMED")
            SetTimer(() => RemoveToolTip(), -900)
        }
    }
}

HybridAutoResumeTimer() {
    global hybridPauseActive
    Suspend(0)
    hybridPauseActive := false
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("HYBRID", "RESUMED (auto)")
    } else {
        ShowCenteredToolTip("RESUMED (auto)")
        SetTimer(() => RemoveToolTip(), -1000)
    }
}

ToggleHiddenFiles() {
    try {
        currentValue := RegRead("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", "Hidden")
        newValue := (currentValue = 1) ? 2 : 1
        RegWrite(newValue, "REG_DWORD", "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", "Hidden")
        Send("{F5}")
        statusText := (newValue = 1) ? "HIDDEN FILES SHOWN" : "HIDDEN FILES HIDDEN"
        ShowCenteredToolTip(statusText)
        SetTimer(() => RemoveToolTip(), -2000)
    } catch Error as err {
        ShowCenteredToolTip("Error toggling hidden files")
        SetTimer(() => RemoveToolTip(), -2000)
    }
}

ExecuteGitCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "s": Run("cmd.exe /k git status")
        case "l": Run("cmd.exe /k git log --oneline -10")
        case "b": Run("cmd.exe /k git branch -a")
        case "d": Run("cmd.exe /k git diff")
        case "a": Run("cmd.exe /k git add .")
        case "p": Run("cmd.exe /k git pull")
        default:
            ShowCenteredToolTip("Unknown git command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Git", cmd)
}

ExecuteMonitoringCommand(cmd) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    switch cmd {
        case "p":
            Run("powershell.exe -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "s":
            Run("powershell.exe -Command `"Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "d":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "m":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        case "c":
            Run("powershell.exe -Command `"Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
        default:
            ShowCenteredToolTip("Unknown monitoring command: " . cmd)
            SetTimer(() => RemoveToolTip(), -1500)
            return
    }
    ShowCommandExecuted("Monitoring", cmd)
}

; ---- Helpers for dynamic commands (new schema) ----
SymToInternal(catSym) {
    switch catSym {
        case "s": return "system"
        case "n": return "network"
        case "g": return "git"
        case "m": return "monitoring"
        case "f": return "folder"
        case "w": return "windows"
        case "o": return "power"
        case "a": return "adb"
        case "h": return "hybrid"
        case "v": return "vaultflow"
        default:
            ; Dynamic fallback: look up title for this symbol in [Categories] and normalize it
            global CommandsIni
            title := IniRead(CommandsIni, "Categories", catSym, "")
            if (title != "" && title != "ERROR") {
                return NormalizeCategoryToken(title)
            }
            return ""
    }
}

ResolveAndExecuteCustomAction(categoryInternal, key) {
    global CommandsIni
    catSym := GetCategoryKeySymbol(categoryInternal)
    if (catSym = "")
        return false
    sec := catSym . "_category"
    action := IniRead(CommandsIni, sec, key . "_action", "")
    if (action = "" || action = "ERROR")
        return false

    ; Friendly label for confirmation/select feedback
    label := IniRead(CommandsIni, sec, key, key)

    ; Confirm according to rules
    if (ShouldConfirmCommand(categoryInternal, key)) {
        if (!ConfirmYN("Execute " . label . "?", "commands"))
            return true ; handled (cancelled)
    }

    ; Support indirection via @Name in [CustomCommands]
    name := ""
    cmdSpec := action
    if (SubStr(action, 1, 1) = "@") {
        name := SubStr(action, 2)
        cmdSpec := IniRead(CommandsIni, "CustomCommands", name, "")
        if (cmdSpec = "" || cmdSpec = "ERROR") {
            ShowCenteredToolTip("Custom command '@" . name . "' not found")
            SetTimer(() => RemoveToolTip(), -2000)
            return true
        }
    }

    colonPos := InStr(cmdSpec, ":")
    if (!colonPos) {
        ShowCenteredToolTip("Invalid command spec: " . cmdSpec)
        SetTimer(() => RemoveToolTip(), -2000)
        return true
    }

    cmdType := StrLower(Trim(SubStr(cmdSpec, 1, colonPos - 1)))
    payload := Trim(SubStr(cmdSpec, colonPos + 1))

    flags := (name != "") ? LoadCommandFlags(name) : {}
    payload := ExpandPlaceholders(payload)
    for k2, v2 in flags {
        flags[k2] := ExpandPlaceholders(v2)
    }

    ExecuteCustomCommand(cmdType, payload, flags)
    return true
}

LoadCommandFlags(name) {
    global CommandsIni
    flags := {}
    if (name = "")
        return flags
    sec := "CommandFlag." . name
    keys := ["terminal","keep_open","admin","working_dir","env","timeout","wt_shell"]
    for _, k in keys {
        v := IniRead(CommandsIni, sec, k, "")
        if (v != "" && v != "ERROR")
            flags[k] := Trim(v)
    }
    return flags
}

ExpandPlaceholders(text) {
    if (text = "")
        return text
    ; Predefined placeholders
    text := StrReplace(text, "{ScriptDir}", A_ScriptDir)
    text := StrReplace(text, "{UserProfile}", EnvGet("USERPROFILE"))
    text := StrReplace(text, "{Home}", EnvGet("USERPROFILE"))
    text := StrReplace(text, "{Clipboard}", A_Clipboard)
    ; CustomVars from commands.ini
    global CommandsIni
    while RegExMatch(text, "\{([A-Za-z0-9_]+)\}", &m) {
        varName := m[1]
        varVal := IniRead(CommandsIni, "CustomVars", varName, "")
        if (varVal = "" || varVal = "ERROR")
            break
        text := StrReplace(text, "{" . varName . "}", varVal)
    }
    ; Expand %ENV% variables
    while RegExMatch(text, "%([A-Za-z0-9_]+)%", &e) {
        ev := e[1]
        evv := EnvGet(ev)
        text := StrReplace(text, "%" . ev . "%", (evv != "") ? evv : "")
    }
    return text
}

ParseEnvList(envStr) {
    envMap := []
    if (envStr = "")
        return envMap
    for pair in StrSplit(envStr, [";", "`n", "`r"]) {
        pair := Trim(pair)
        if (pair = "")
            continue
        eq := InStr(pair, "=")
        if (!eq)
            continue
        k := Trim(SubStr(pair, 1, eq - 1))
        v := Trim(SubStr(pair, eq + 1))
        envMap.Push([k, v])
    }
    return envMap
}

ExecuteCustomCommand(cmdType, payload, flags) {
    ; Auto-hide C# tooltip on execute if configured
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    opts := ""
    if (flags.HasOwnProp("working_dir"))
        opts := flags["working_dir"]
    runOpts := (flags.HasOwnProp("terminal") && StrLower(flags["terminal"]) = "hidden") ? "Hide" : ""
    admin := (flags.HasOwnProp("admin") && (StrLower(flags["admin"]) = "true"))

    try {
        switch cmdType {
            case "url":
                Run(payload)
            case "cmd":
                envPrefix := ""
                for _, kv in ParseEnvList(flags.HasOwnProp("env") ? flags["env"] : "") {
                    envPrefix .= "set " . kv[1] . "=" . kv[2] . "&& "
                }
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "false") = "true")
                args := (keepOpen ? "/k " : "/c ") . Chr(34) . envPrefix . payload . Chr(34)
                exe := "cmd.exe " . args
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "ps":
                envScript := ""
                for _, kv in ParseEnvList(flags.HasOwnProp("env") ? flags["env"] : "") {
                    envScript := envScript . "$env:" . kv[1] . "='" . kv[2] . "';"
                }
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "false") = "true")
                psCmd := envScript . payload
                args := (keepOpen ? "-NoExit " : "") . "-NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . psCmd . Chr(34)
                exe := "powershell.exe " . args
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "pwsh":
                envScript := ""
                for _, kv in ParseEnvList(flags.HasOwnProp("env") ? flags["env"] : "") {
                    envScript := envScript . "$env:" . kv[1] . "='" . kv[2] . "';"
                }
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "true") = "true")
                psCmd := envScript . payload
                args := (keepOpen ? "-NoExit " : "") . "-NoProfile -Command " . Chr(34) . psCmd . Chr(34)
                exe := "pwsh.exe " . args
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "wsl":
                exe := "wsl.exe " . payload
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            case "wt":
                wtShell := StrLower(flags.HasOwnProp("wt_shell") ? flags["wt_shell"] : "cmd")
                keepOpen := (StrLower(flags.HasOwnProp("keep_open") ? flags["keep_open"] : "true") = "true")
                if (wtShell = "cmd") {
                    inner := (keepOpen ? "/k " : "/c ") . Chr(34) . payload . Chr(34)
                    exe := "wt new-tab cmd " . inner
                } else if (wtShell = "ps") {
                    inner := (keepOpen ? "-NoExit " : "") . "-NoProfile -ExecutionPolicy Bypass -Command " . Chr(34) . payload . Chr(34)
                    exe := "wt new-tab powershell " . inner
                } else {
                    inner := (keepOpen ? "-NoExit " : "") . "-NoProfile -Command " . Chr(34) . payload . Chr(34)
                    exe := "wt new-tab pwsh " . inner
                }
                if (admin)
                    exe := "*RunAs " . exe
                Run(exe, opts, runOpts)
            default:
                ShowCenteredToolTip("Unknown cmd type: " . cmdType)
        }
    } catch as err {
        ShowCenteredToolTip("Command failed: " . err.Message)
        SetTimer(() => RemoveToolTip(), -2000)
    }
}
