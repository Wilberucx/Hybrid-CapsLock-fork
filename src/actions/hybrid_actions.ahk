; ==============================
; Hybrid Management Actions
; ==============================
; Funciones reutilizables para Hybrid Management
; Estilo: una función = una acción atómica
; Inspirado en kanata_launcher.ahk - funciones limpias y reutilizables

; ---- Reload completo (Kanata + AHK) ----
ReloadHybridScript() {
    ; Notificación
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("HYBRID", "RELOADING...")
    } else {
        ShowCenteredToolTip("RELOADING...")
        SetTimer(() => RemoveToolTip(), -800)
    }
    
    Sleep(400)
    
    ; Detener tooltip app
    try StopTooltipApp()
    
    ; Reiniciar Kanata (si estaba corriendo)
    if (IsKanataRunning()) {
        RestartKanata()
    }
    
    ; Reiniciar AHK
    Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '"')
    ExitApp()
}

; ---- Restart solo Kanata ----
RestartKanataOnly() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("KANATA", "RESTARTING...")
    } else {
        ShowCenteredToolTip("RESTARTING KANATA...")
        SetTimer(() => RemoveToolTip(), -800)
    }
    
    RestartKanata()
    
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        Sleep(600)
        try ShowCSharpStatusNotification("KANATA", "RESTARTED")
        Sleep(1000)
    } else {
        Sleep(800)
        ShowCenteredToolTip("KANATA RESTARTED")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

; ---- Exit completo (Kanata + AHK) ----
ExitHybridScript() {
    ; Notificación
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("HYBRID", "EXITING...")
        Sleep(500)
        try StopTooltipApp()
    } else {
        ShowCenteredToolTip("EXITING SCRIPT...")
        SetTimer(() => RemoveToolTip(), -600)
        Sleep(600)
    }
    
    ; Detener Kanata (si estaba corriendo)
    if (IsKanataRunning()) {
        StopKanata()
    }
    
    ; Salir de AHK
    ExitApp()
}

; ---- Pause Hybrid ----
PauseHybridScript() {
    ToggleHybridPause()
}

; ---- Open Config Folder ----
OpenConfigFolder() {
    Run('explorer.exe "' . A_ScriptDir . '\\config"')
    ShowCommandExecuted("Hybrid", "Config Folder")
}

; ---- View Log File ----
ViewLogFile() {
    logFile := A_ScriptDir . "\\hybrid_log.txt"
    if (FileExist(logFile)) {
        Run('notepad.exe "' . logFile . '"')
        ShowCommandExecuted("Hybrid", "Log File")
    } else {
        ShowCenteredToolTip("No log file found")
        SetTimer(() => RemoveToolTip(), -1500)
    }
}

; ---- Show Version Info ----
ShowVersionInfo() {
    ver := IniRead(A_ScriptDir . "\\config\\configuration.ini", "General", "script_version", "")
    verText := (ver != "" && ver != "ERROR") ? ("HybridCapsLock v" . ver) : "HybridCapsLock"
    ShowCenteredToolTip(verText)
    SetTimer(() => RemoveToolTip(), -1500)
}

; ---- Show System Status ----
ShowSystemStatus() {
    global isNvimLayerActive, excelLayerActive
    
    status := "HYBRID STATUS`n`n"
    status .= "Kanata: " . (IsKanataRunning() ? "Running" : "Stopped") . "`n"
    status .= "Nvim Layer: " . (isNvimLayerActive ? "ON" : "OFF") . "`n"
    status .= "Excel Layer: " . (excelLayerActive ? "ON" : "OFF") . "`n"
    
    ShowCenteredToolTip(status)
    SetTimer(() => RemoveToolTip(), -3000)
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterHybridKeymaps() {
    RegisterKeymap("hybrid", "p", "Pause Hybrid", PauseHybridScript, false, 1)
    RegisterKeymap("hybrid", "s", "Show System Status", ShowSystemStatus, false, 2)
    RegisterKeymap("hybrid", "v", "Show Version Info", ShowVersionInfo, false, 3)
    RegisterKeymap("hybrid", "l", "View Log File", ViewLogFile, false, 4)
    RegisterKeymap("hybrid", "c", "Open Config Folder", OpenConfigFolder, false, 5)
    RegisterKeymap("hybrid", "k", "Restart Kanata Only", RestartKanataOnly, false, 6)
    RegisterKeymap("hybrid", "R", "Reload Script", ReloadHybridScript, true, 7)
    RegisterKeymap("hybrid", "e", "Exit Script", ExitHybridScript, true, 8)
}
