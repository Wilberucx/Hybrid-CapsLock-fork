; ==============================
; Leader Router - Sistema Jerárquico Universal
; ==============================
; Router genérico para navegación jerárquica en Leader Menu.
; Hotkey: F24 (sent by Kanata when CapsLock hold + Space)
;
; ARQUITECTURA:
; - Usa ExecuteKeymapAtPath() del keymap_registry
; - Navegación multinivel con breadcrumb (back funcionando)
; - Compatible con categorías registradas en command_system_init.ahk
;
; Depends on: 
;   - core/keymap_registry (ExecuteKeymapAtPath, GetSortedKeymapsForPath)
;   - core/config (GetEffectiveTimeout)
;   - ui/tooltips

#SuspendExempt
#HotIf (leaderLayerEnabled)
F24:: {
    ; F24 sent by Kanata when CapsLock is held and Space is pressed
    TryActivateLeader()
}
#HotIf

#SuspendExempt False

; ==============================
; NAVEGACIÓN JERÁRQUICA UNIVERSAL
; ==============================

TryActivateLeader() {
    global leaderActive, isNvimLayerActive, hybridPauseActive
    
    ; Resume script if suspended
    if (A_IsSuspended) {
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
    
    leaderActive := true
    
    ; Deactivate NVIM layer to avoid conflicts
    if (isNvimLayerActive) {
        isNvimLayerActive := false
        try ShowNvimLayerToggleCS(false)
        try ShowNvimLayerStatus(false)
    }
    
    ; Start hierarchical navigation at root
    NavigateHierarchical("leader")
    
    leaderActive := false
}

; ==============================
; NAVEGADOR JERÁRQUICO GENÉRICO
; ==============================

NavigateHierarchical(currentPath) {
    Loop {
        ; Mostrar menú del path actual
        ShowMenuForCurrentPath(currentPath)
        
        ; Esperar input del usuario
        timeout := GetTimeoutForPath(currentPath)
        ih := InputHook("L1 T" . timeout, "{Escape}{Backspace}")
        ih.KeyOpt("{Escape}", "S")
        ih.KeyOpt("{Backspace}", "S")
        ih.Start()
        ih.Wait()
        
        ; Manejar Escape (salir completamente)
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            HideAllTooltips()
            ih.Stop()
            return "EXIT"
        }
        
        ; Manejar Backspace (volver atrás)
        if (ih.EndReason = "EndKey" && ih.EndKey = "Backspace") {
            ih.Stop()
            ; Si estamos en root (leader), salir
            if (currentPath = "leader") {
                HideAllTooltips()
                return "EXIT"
            }
            ; Si no, volver al padre
            return "BACK"
        }
        
        ; Manejar timeout
        if (ih.EndReason = "Timeout") {
            ih.Stop()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Obtener tecla presionada
        key := ih.Input
        ih.Stop()
        
        ; Tecla vacía o inválida
        if (key = "" || key = Chr(0)) {
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Backslash como alternativa a Backspace
        if (key = "\\") {
            if (currentPath = "leader") {
                HideAllTooltips()
                return "EXIT"
            }
            return "BACK"
        }
        
        ; ==============================
        ; ACCIONES ESPECIALES (temporales - migrar después)
        ; ==============================
        
        ; Toggle Scroll Layer (s en root)
        if (currentPath = "leader" && (key = "s" || key = "S")) {
            HandleScrollLayerToggle()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Toggle Excel Layer (n en root)
        if (currentPath = "leader" && (key = "n" || key = "N")) {
            HandleExcelLayerToggle()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Timestamps (t en root) - TODO: migrar a sistema declarativo
        if (currentPath = "leader" && (key = "t" || key = "T")) {
            HandleTimestampsLayer()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Information (i en root) - TODO: migrar a sistema declarativo
        if (currentPath = "leader" && (key = "i" || key = "I")) {
            HandleInformationLayer()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Programs (p en root) - TODO: migrar a sistema declarativo
        if (currentPath = "leader" && (key = "p" || key = "P")) {
            HandleProgramsLayer()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; ==============================
        ; NAVEGACIÓN JERÁRQUICA (sistema nuevo)
        ; ==============================
        
        ; Ejecutar keymap en el path actual
        result := ExecuteKeymapAtPath(currentPath, key)
        
        if (Type(result) = "String") {
            ; Es una categoría, navegar más profundo
            res := NavigateHierarchical(result)
            if (res = "EXIT") {
                HideAllTooltips()
                return "EXIT"
            }
            ; Si es "BACK", continuar en este nivel
            continue
        } else if (result = true) {
            ; Acción ejecutada exitosamente
            HideAllTooltips()
            return "EXIT"
        } else if (result = false) {
            ; Keymap no encontrado
            ShowCenteredToolTip("Unknown key: " . key)
            SetTimer(() => RemoveToolTip(), -800)
            continue
        }
    }
}

; ==============================
; MOSTRAR MENÚ DEL PATH ACTUAL
; ==============================

ShowMenuForCurrentPath(path) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowMenuForPathCS(path)
    } else {
        ; Fallback a tooltip nativo
        menuText := BuildMenuForPath(path, GetTitleForPath(path))
        if (menuText = "") {
            menuText := "NO ITEMS IN MENU"
        }
        
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 100
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ==============================
; OBTENER TÍTULO PARA PATH
; ==============================

GetTitleForPath(path) {
    if (path = "leader")
        return "LEADER MENU"
    else if (path = "leader.w")
        return "WINDOWS"
    else if (path = "leader.c")
        return "COMMANDS"
    else if (path = "leader.c.s")
        return "SYSTEM COMMANDS"
    else if (path = "leader.c.a")
        return "ADB TOOLS"
    else
        return StrUpper(SubStr(path, InStr(path, ".", , -1) + 1))
}

; ==============================
; OBTENER TIMEOUT PARA PATH
; ==============================

GetTimeoutForPath(path) {
    ; Mapear path a categoría de timeout
    if (path = "leader")
        return GetEffectiveTimeout("leader")
    else if (InStr(path, "leader.w"))
        return GetEffectiveTimeout("windows")
    else if (InStr(path, "leader.c"))
        return GetEffectiveTimeout("commands")
    else if (InStr(path, "leader.p"))
        return GetEffectiveTimeout("programs")
    else
        return GetEffectiveTimeout("leader")
}

; ==============================
; ACCIONES ESPECIALES (temporales)
; ==============================

HandleScrollLayerToggle() {
    global scrollLayerEnabled, scrollLayerActive
    if (!IsSet(scrollLayerEnabled))
        scrollLayerEnabled := true
    if (!IsSet(scrollLayerActive))
        scrollLayerActive := false
    
    scrollLayerActive := !scrollLayerActive
    try HideAllTooltips()
    try HideCSharpTooltip()
    Sleep 30
    ShowScrollLayerStatus(scrollLayerActive)
    SetTempStatus(scrollLayerActive ? "SCROLL LAYER ON" : "SCROLL LAYER OFF", 1500)
}

HandleExcelLayerToggle() {
    global excelLayerEnabled, excelLayerActive
    if (!excelLayerEnabled) {
        ShowCenteredToolTip("EXCEL LAYER DISABLED")
        SetTimer(() => RemoveToolTip(), -1000)
        return
    }
    
    excelLayerActive := !excelLayerActive
    try HideAllTooltips()
    try HideCSharpTooltip()
    Sleep 30
    ShowExcelLayerStatus(excelLayerActive)
    SetTempStatus(excelLayerActive ? "EXCEL LAYER ON" : "EXCEL LAYER OFF", 1500)
}

HandleTimestampsLayer() {
    ; Timestamps menu with proper Back/Esc handling
    ShowTimeMenu()
    ihTs := InputHook("L1 T" . GetEffectiveTimeout("timestamps"), "{Escape}{Backspace}")
    ihTs.KeyOpt("{Escape}", "S")
    ihTs.KeyOpt("{Backspace}", "S")
    ihTs.Start()
    ihTs.Wait()
    
    if (ihTs.EndReason = "EndKey" && ihTs.EndKey = "Escape") {
        ihTs.Stop()
        return
    }
    if (ihTs.EndReason = "EndKey" && ihTs.EndKey = "Backspace") {
        ihTs.Stop()
        ; TODO: volver a leader menu (necesita refactor)
        return
    }
    
    tsKey := ihTs.Input
    ihTs.Stop()
    
    if (tsKey = "\\" || tsKey = "" || tsKey = Chr(0))
        return
    
    HandleTimestampMode(tsKey)
}

HandleInformationLayer() {
    ; Information menu with proper Back/Esc handling
    ShowInformationMenu()
    ihInfo := InputHook("L1 T" . GetEffectiveTimeout("information"), "{Escape}{Backspace}")
    ihInfo.KeyOpt("{Escape}", "S")
    ihInfo.KeyOpt("{Backspace}", "S")
    ihInfo.Start()
    ihInfo.Wait()
    
    if (ihInfo.EndReason = "EndKey" && ihInfo.EndKey = "Escape") {
        ihInfo.Stop()
        return
    }
    if (ihInfo.EndReason = "EndKey" && ihInfo.EndKey = "Backspace") {
        ihInfo.Stop()
        ; TODO: volver a leader menu (necesita refactor)
        return
    }
    
    infoKey := ihInfo.Input
    ihInfo.Stop()
    
    if (infoKey = "\\" || infoKey = "" || infoKey = Chr(0))
        return
    
    InsertInformationFromKey(infoKey)
}

HandleProgramsLayer() {
    global ProgramsIni
    ShowProgramMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("programs"), "{Escape}{Backspace}")
    ih.KeyOpt("{Escape}", "S")
    ih.KeyOpt("{Backspace}", "S")
    ih.Start()
    ih.Wait()
    
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        ih.Stop()
        return
    }
    if (ih.EndReason = "EndKey" && ih.EndKey = "Backspace") {
        ih.Stop()
        ; TODO: volver a leader menu (necesita refactor)
        return
    }
    
    key := ih.Input
    ih.Stop()
    
    if (key = "\\" || key = "" || key = Chr(0))
        return
    
    autoLaunch := CleanIniBool(IniRead(ProgramsIni, "Settings", "auto_launch", "true"), true)
    if (!autoLaunch) {
        ShowProgramDetails(key)
    } else {
        LaunchProgramFromKey(key)
    }
}

; ==============================
; MENÚ C# (si está habilitado)
; ==============================

ShowMenuForPathCS(path) {
    ; Generar items del path
    items := GenerateCategoryItemsForPath(path)
    
    if (items = "") {
        items := "[No items registered]"
    }
    
    title := GetTitleForPath(path)
    footer := "\\: Back|ESC: Exit"
    
    ; Mostrar tooltip C#
    ShowCSharpOptionsMenu(title, items, footer)
}

; ==============================
; EMERGENCY RESUME HOTKEY
; ==============================

#SuspendExempt
#HotIf (enableEmergencyResumeHotkey)
^!#r:: {
    global hybridPauseActive
    if (A_IsSuspended) {
        try SetTimer(HybridAutoResumeTimer, 0)
        Suspend(0)
        hybridPauseActive := false
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("HYBRID", "RESUMED (emergency)")
        } else {
            ShowCenteredToolTip("RESUMED (emergency)")
            SetTimer(() => RemoveToolTip(), -900)
        }
    }
}
#HotIf
#SuspendExempt False

; ==============================
; NOTAS DE MIGRACIÓN:
; ==============================
; TODO: Migrar a sistema declarativo:
; - Programs Layer → programs_actions.ahk + RegisterProgramsKeymaps()
; - Timestamps Layer → timestamps_actions.ahk + RegisterTimestampsKeymaps()
; - Information Layer → information_actions.ahk + RegisterInformationKeymaps()
; - Scroll/Excel toggles → Considerar si deben ser keymaps o manejarse aparte
;
; DESPUÉS de migrar, eliminar Handle*Layer() y usar solo NavigateHierarchical()
