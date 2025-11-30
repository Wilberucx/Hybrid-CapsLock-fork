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

; ==============================
; Hybrid Manager UI
; ==============================

/**
 * ShowHybridManager - Display the centralized Hybrid Manager UI
 * 
 * Shows a centered, tabbed interface for managing HybridCapsLock.
 * Uses TooltipApp v2.1 features for layout and styling.
 * 
 * @param tabName - The active tab to display (Default: "General")
 */
ShowHybridManager(tabName := "General") {
    ; Define tabs
    tabs := ["General", "Plugins", "System"]
    
    ; Build title with active tab highlighted
    title := "HYBRID MANAGER"
    subTitle := ""
    for t in tabs {
        if (t = tabName) {
            subTitle .= " [" . t . "] "
        } else {
            subTitle .= " " . t . " "
        }
    }
    
    ; Build items based on active tab
    items := []
    
    if (tabName = "General") {
        items.Push("r:Reload Script")
        items.Push("k:Restart Kanata")
        items.Push("p:Pause/Resume")
        items.Push("c:Open Config")
        items.Push("l:View Logs")
        items.Push("e:Exit Hybrid")
    } else if (tabName = "Plugins") {
        items.Push("w:Welcome Screen")
        items.Push("s:Shell Exec Help")
        items.Push("d:Docs Folder")
    } else if (tabName = "System") {
        items.Push("i:System Info")
        items.Push("t:Task Manager")
        items.Push("v:Volume Mixer")
    }
    
    ; Navigation hints
    navigation := ["TAB: Switch Tab", "ESC: Close"]
    
    ; Configuration options
    opts := Map()
    
    ; 1. Layout & Position
    opts["layout"] := Map()
    opts["layout"]["mode"] := "list"
    opts["layout"]["columns"] := 2  ; Two columns for better use of space
    
    opts["position"] := Map()
    opts["position"]["anchor"] := "center"
    
    ; 2. Styling (Manager Theme)
    opts["style"] := Map()
    opts["style"]["background"] := "#1e1e2e"      ; Darker background
    opts["style"]["text"] := "#cdd6f4"            ; White text
    opts["style"]["accent_options"] := "#f5c2e7"  ; Pink accent for keys
    opts["style"]["border"] := "#cba6f7"          ; Purple border
    opts["style"]["border_thickness"] := 2
    opts["style"]["title_font_size"] := 14
    opts["style"]["item_font_size"] := 12
    
    ; 3. Window Properties
    opts["window"] := Map()
    opts["window"]["topmost"] := true
    opts["window"]["opacity"] := 0.98
    
    ; 4. Animation
    opts["animation"] := Map()
    opts["animation"]["type"] := "fade"
    opts["animation"]["duration_ms"] := 150
    
    ; 5. ID for stability
    opts["id"] := "hybrid_manager"
    
    ; Show the tooltip
    ShowCSharpTooltipAdvanced(title . "`n" . subTitle, items, navigation, opts)
    
    ; Register temporary keymaps for interaction
    ; Note: This relies on the standard Leader key handling input
    ; We might need a specific input handler for the manager if we want "Tab" to work
    ; For now, we rely on the user pressing the key corresponding to the item
}

; Helper to switch tabs (can be bound to a key if we have an input handler)
SwitchManagerTab(currentTab) {
    nextTab := "General"
    if (currentTab = "General")
        nextTab := "Plugins"
    else if (currentTab = "Plugins")
        nextTab := "System"
    
    ShowHybridManager(nextTab)
}

