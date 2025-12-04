; ==============================
; Hybrid Management Actions
; ==============================
; Reusable functions for Hybrid Management
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
    if (KanataIsRunning()) {
        KanataRestart()
    }
    
    ; Reiniciar AHK
    Run('"' . A_AhkPath . '" "' . A_ScriptFullPath . '"')
    ExitApp()
}

; ---- Restart solo Kanata ----
KanataRestartOnly() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowCSharpStatusNotification("KANATA", "RESTARTING...")
    } else {
        ShowCenteredToolTip("RESTARTING KANATA...")
        SetTimer(() => RemoveToolTip(), -800)
    }
    
    KanataRestart()
    
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
    if (KanataIsRunning()) {
        KanataStop()
    }
    
    ; Salir de AHK
    ExitApp()
}

; ---- Pause Hybrid ----
PauseHybridScript() {
    ToggleHybridPause()
}

; ---- Hybrid Pause Helper Functions ----
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
        SetTimer(() => RemoveToolTip(), -900)
    }
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

