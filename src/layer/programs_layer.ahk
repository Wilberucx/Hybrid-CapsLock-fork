; ==============================
; Programs Layer (menu + launcher)
; ==============================
; Shows programs menu based on programs.ini mapping and launches apps.
; Depends on: core/config (GetEffectiveTimeout), core/confirmations,
; ui/tooltips_native_wrapper (fallback), ui/tooltip_csharp_integration (CS menus)

; ---- Menu display ----
ShowProgramMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowProgramMenuCS()
    } else {
        ; Generate menu dynamically from ProgramMapping order
        menuText := GenerateProgramMenuText()
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 150
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ---- Build native tooltip menu text ----
GenerateProgramMenuText() {
    global ProgramsIni

    menuText := "PROGRAM LAUNCHER`n`n"

    orderStr := IniRead(ProgramsIni, "ProgramMapping", "order", "")
    if (orderStr = "" || orderStr = "ERROR") {
        orderStr := "e v n t o b z m w l r q p k f"  ; fallback order
    }

    keys := StrSplit(orderStr, " ")
    currentLine := ""
    Loop keys.Length {
        key := Trim(keys[A_Index])
        if (key = "")
            continue
        programName := IniRead(ProgramsIni, "ProgramMapping", key, "")
        if (programName = "" || programName = "ERROR")
            continue
        entry := key . " - " . programName
        if (currentLine = "") {
            currentLine := entry
        } else {
            menuText .= Format("{:-15s} {}", currentLine, entry) . "`n"
            currentLine := ""
        }
    }
    if (currentLine != "")
        menuText .= currentLine . "`n"
    menuText .= "`n[Backspace: Back] [Esc: Exit]"
    return menuText
}

; ---- Universal program launcher ----
LaunchApp(appName, exeNameOrUri) {
    global ProgramsIni
    _path := ""

    ; Handle URIs (e.g., ms-settings:)
    if (!InStr(exeNameOrUri, ".exe") && !InStr(exeNameOrUri, ".lnk")) {
        try {
            Run(exeNameOrUri)
        } catch Error as err {
            ShowCenteredToolTip("Failed to launch: " . appName)
            SetTimer(() => RemoveToolTip(), -3000)
        }
        return
    }

    ; 1) User-defined path from programs.ini
    _userPath := IniRead(ProgramsIni, "Programs", appName, "")
    if (_userPath != "" && _userPath != "ERROR") {
        _expandedPath := ExpandEnvironmentStrings(_userPath)
        if (FileExist(_expandedPath)) {
            try {
                Run('"' . _expandedPath . '"')
                return
            } catch Error as err {
                ; continue
            }
        }
    }

    ; 2) Resolve automatically
    _resolvedPath := ResolveExecutable(exeNameOrUri)
    if (_resolvedPath != "") {
        try {
            Run('"' . _resolvedPath . '"')
            return
        } catch Error as err {
            ; continue
        }
    }

    ; 3) Failure -> show message
    ShowCenteredToolTip(appName . " not found.`nAdd the path to programs.ini`n[Programs]")
    SetTimer(() => RemoveToolTip(), -3500)
}

ResolveExecutable(exeName) {
    ; Try registry App Paths
    try {
        appPath := RegRead("HKEY_LOCAL_MACHINE\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\" . exeName, "")
        if (appPath != "" && FileExist(appPath))
            return appPath
    } catch {
        ; ignore
    }
    try {
        appPath := RegRead("HKEY_CURRENT_USER\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\App Paths\\" . exeName, "")
        if (appPath != "" && FileExist(appPath))
            return appPath
    } catch {
        ; ignore
    }
    ; Try PATH
    try {
        envPath := EnvGet("PATH")
        Loop Parse, envPath, ";" {
            testPath := A_LoopField . "\\" . exeName
            if (FileExist(testPath))
                return testPath
        }
    } catch {
        ; ignore
    }
    return ""
}

ExpandEnvironmentStrings(inputPath) {
    expandedPath := inputPath
    try {
        expandedPath := StrReplace(expandedPath, "%USERPROFILE%", EnvGet("USERPROFILE"))
    }
    try {
        expandedPath := StrReplace(expandedPath, "%PROGRAMFILES%", EnvGet("PROGRAMFILES"))
    }
    try {
        expandedPath := StrReplace(expandedPath, "%PROGRAMFILES(X86)%", EnvGet("PROGRAMFILES(X86)"))
    }
    try {
        expandedPath := StrReplace(expandedPath, "%LOCALAPPDATA%", EnvGet("LOCALAPPDATA"))
    }
    return expandedPath
}

; ---- Specific program helpers ----
LaunchExplorer()    => LaunchApp("Explorer", "explorer.exe")
LaunchSettings()    => LaunchApp("Settings", "ms-settings:")
LaunchTerminal()    => LaunchApp("Terminal", "wt.exe")
LaunchVisualStudio()=> LaunchApp("VisualStudio", "code.exe")
LaunchVivaldi()     => LaunchApp("Vivaldi", "vivaldi.exe")
LaunchZen()         => LaunchApp("Zen", "zen.exe")
LaunchThunderbird() => LaunchApp("Thunderbird", "thunderbird.exe")
LaunchWezTerm()     => LaunchApp("WezTerm", "wezterm-gui.exe")
LaunchWSL()         => LaunchApp("WSL", "wsl.exe")
LaunchBeeper()      => LaunchApp("Beeper", "Beeper.exe")
LaunchBitwarden()   => LaunchApp("Bitwarden", "bitwarden.exe")
LaunchNotepad()     => LaunchApp("Notepad", "notepad.exe")

; ---- Special case: QuickShare ----
LaunchQuickShare() {
    _quickShareLnk := "C:\\ProgramData\\Microsoft\\Windows\\Start Menu\\Quick Share.lnk"
    if (FileExist(_quickShareLnk)) {
        try {
            Run('"' . _quickShareLnk . '"')
            Sleep(1500)
            WinActivate("Quick Share")
            if (!WinActive("Quick Share"))
                WinActivate("ahk_exe NearbyShare.exe")
            return
        } catch Error as err {
        }
    }
    try {
        Run("explorer.exe shell:appsFolder\\NearbyShare_21hpf16v5xp10!NearbyShare")
        Sleep(1500)
        WinActivate("Quick Share")
        if (!WinActive("Quick Share"))
            WinActivate("ahk_exe NearbyShare.exe")
        return
    } catch Error as err {
        ShowCenteredToolTip("Quick Share not found.`nPlease verify it is installed.")
        SetTimer(() => RemoveToolTip(), -3000)
    }
}

; ---- Details flow when auto_launch=false ----
ShowProgramDetails(keyPressed) {
    global ProgramsIni
    ; Read program name
    programName := IniRead(ProgramsIni, "ProgramMapping", keyPressed, "")
    if (programName = "" || programName = "ERROR") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.`nAdd to programs.ini`n[ProgramMapping]")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    executablePath := IniRead(ProgramsIni, "Programs", programName, "")
    if (executablePath = "" || executablePath = "ERROR") {
        ShowCenteredToolTip(programName . " not found in [Programs].`nAdd path to programs.ini")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    detailsText := "PROGRAM: " . programName . "`nPATH: " . executablePath . "`n`nPress ENTER to launch`nPress ESC to cancel"
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpTooltip(detailsText, "Program Details", "info")
    } else {
        ShowCenteredToolTip(detailsText)
    }
    userInput := InputHook("L1 T" . GetEffectiveTimeout("programs"))
    userInput.KeyOpt("{Enter}", "ES")
    userInput.KeyOpt("{Escape}", "ES")
    userInput.Start()
    userInput.Wait()
    if (userInput.EndReason = "KeyDown" && userInput.EndKey = "Enter") {
        if (ShouldConfirmPrograms(keyPressed)) {
            if (!ConfirmYN("Launch " . programName . "?", "programs")) {
                userInput.Stop()
                return
            }
        }
        if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide) {
            HideCSharpTooltip()
        }
        if (programName = "QuickShare") {
            LaunchQuickShare()
        } else {
            LaunchApp(programName, executablePath)
        }
    }
    userInput.Stop()
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        HideCSharpTooltip()
    } else {
        ToolTip()
    }
}

; ---- Launch program by key mapping ----
LaunchProgramFromKey(keyPressed) {
    global ProgramsIni
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    programName := IniRead(ProgramsIni, "ProgramMapping", keyPressed, "")
    if (programName = "" || programName = "ERROR") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.`nAdd to programs.ini`n[ProgramMapping]")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    executablePath := IniRead(ProgramsIni, "Programs", programName, "")
    if (executablePath = "" || executablePath = "ERROR") {
        ShowCenteredToolTip(programName . " not found in [Programs].`nAdd path to programs.ini")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    if (ShouldConfirmPrograms(keyPressed)) {
        if (!ConfirmYN("Launch " . programName . "?", "programs"))
            return
    }
    if (programName = "QuickShare") {
        LaunchQuickShare()
        return
    }
    LaunchApp(programName, executablePath)
}
