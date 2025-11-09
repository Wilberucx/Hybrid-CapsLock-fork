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
}

; ---- View Log File ----
ViewLogFile() {
    logFile := A_ScriptDir . "\\hybrid_log.txt"
    if (FileExist(logFile)) {
        Run('notepad.exe "' . logFile . '"')
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
    global isNvimLayerActive, excelLayerActive, LayerRegistry
    
    status := "HYBRID STATUS`n`n"
    status .= "Kanata: " . (IsKanataRunning() ? "Running" : "Stopped") . "`n"
    status .= "Nvim Layer: " . (isNvimLayerActive ? "ON" : "OFF") . "`n"
    status .= "Excel Layer: " . (excelLayerActive ? "ON" : "OFF") . "`n"
    status .= "Layers Registered: " . LayerRegistry.Count . "`n"
    
    ShowCenteredToolTip(status)
    SetTimer(() => RemoveToolTip(), -3000)
}

; ---- Scan Layers (Manual) ----
ScanLayersManual() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("AUTO-LOADER", "Scanning layers...")
    } else {
        ShowCenteredToolTip("SCANNING LAYERS...")
        SetTimer(() => RemoveToolTip(), -800)
    }
    
    ; Run auto-loader to regenerate registry
    try {
        AutoLoaderInit()
        
        Sleep(500)
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("AUTO-LOADER", "Scan complete - Registry updated")
        } else {
            ShowCenteredToolTip("LAYERS SCANNED`nRegistry updated")
            SetTimer(() => RemoveToolTip(), -1500)
        }
    } catch as err {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("AUTO-LOADER", "Error: " . err.Message)
        } else {
            ShowCenteredToolTip("SCAN ERROR`n" . err.Message)
            SetTimer(() => RemoveToolTip(), -2000)
        }
    }
}

; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → h (Hybrid) → key
RegisterHybridKeymaps() {
    RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
    RegisterKeymap("leader", "h", "s", "Show System Status", ShowSystemStatus, false, 2)
    RegisterKeymap("leader", "h", "v", "Show Version Info", ShowVersionInfo, false, 3)
    RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 4)
    RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 5)
    RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 6)
    RegisterKeymap("leader", "h", "S", "Scan Layers", ScanLayersManual, false, 7)
    RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 8)
    RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 9)
}
