; ==============================
; NVIM Layer Helpers - Funciones Específicas
; ==============================
; Funciones que son específicas de nvim_layer.ahk y NO son reutilizables
; en otras capas. Estas funciones dependen del estado de nvim_layer.
;
; USADO EXCLUSIVAMENTE EN: nvim_layer.ahk
;
; REQUIERE:
; - Global: isNvimLayerActive, VisualMode, _tempEditMode
; - vim_nav.ahk, vim_edit.ahk (para operaciones básicas)

; ==============================
; NAVEGACIÓN DIRECCIONAL CON VISUAL MODE
; ==============================

; Directional send that respects VisualMode and modifiers
; Si VisualMode está activo, añade Shift para extender selección
NvimDirectionalSend(dir) {
    global VisualMode
    mods := ""
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("Shift", "P")
        mods .= "+"
    ; En VisualMode, asegurar que Shift esté presente para extender selección
    if (VisualMode && !InStr(mods, "+"))
        mods .= "+"
    Send(mods . "{" . dir . "}")
}

; Word jump with VisualMode support (w/b)
NvimWordJumpHelper(dir) {
    global VisualMode
    mods := "^"  ; Ctrl for word movement
    if (VisualMode)
        mods .= "+"  ; add Shift to extend selection in Visual
    arrow := (dir = "Right") ? "Right" : "Left"
    Send(mods . "{" . arrow . "}")
}

; Go to document edge with VisualMode support (gg/G)
NvimGoToDocEdge(goTop := true) {
    global VisualMode
    mods := "^"  ; Ctrl for document edge
    if (VisualMode)
        mods .= "+"  ; Shift to extend selection
    Send(mods . "{" . (goTop ? "Home" : "End") . "}")
}

; ==============================
; INSERT MODE MANAGEMENT
; ==============================

; Reactivate NVIM layer after Insert mode (Esc from insert)
ReactivateNvimAfterInsert() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        SetTimer(() => RemoveToolTip(), -1000)
    }
}

; ==============================
; APP FILTERING (WHITELIST/BLACKLIST)
; ==============================

NvimLayerAppAllowed() {
    try {
        ini := A_ScriptDir . "\config\nvim_layer.ini"
        wl := IniRead(ini, "Settings", "whitelist", "")
        bl := IniRead(ini, "Settings", "blacklist", "")
        proc := WinGetProcessName("A")
        if (bl != "" && InStr("," . StrLower(bl) . ",", "," . StrLower(proc) . ","))
            return false
        if (wl = "")
            return true
        return InStr("," . StrLower(wl) . ",", "," . StrLower(proc) . ",")
    } catch {
        return true
    }
}

; ==============================
; COLON COMMAND LOGIC (:wq system)
; ==============================

global ColonLogicActive := false
global ColonStage := ""

; Maybe start colon logic (only if Shift is pressed for ':')
ColonMaybeStart() {
    if GetKeyState("Shift", "P") {
        ColonLogicStart()
        return
    }
    Send(";")
}

; Start colon command mode
ColonLogicStart() {
    global ColonLogicActive, ColonStage
    ColonLogicActive := true
    ColonStage := ""
    ColonLogicShowTip()
}

; Cancel colon command mode
ColonLogicCancel() {
    global ColonLogicActive, ColonStage
    ColonLogicActive := false
    ColonStage := ""
    try HideCSharpTooltip()
    try ShowCenteredToolTipCS("Cmd: cancelled", 800)
    SetTimer(() => RemoveToolTip(), -600)
}

; Show colon command tooltip
ColonLogicShowTip() {
    items := "w:Save|q:Quit|wq:Save + Quit"
    ShowBottomRightListTooltip("CMD", items, "Enter: Execute|Esc: Cancel", 0)
}

; Handle 'w' in colon mode
ColonLogicHandleW() {
    global ColonStage
    if (ColonStage = "") {
        ColonStage := "w"
    } else if (ColonStage = "w") {
        ColonStage := "wq"
    } else if (ColonStage = "q") {
        ColonStage := "q"
    }
    ColonLogicShowTip()
}

; Handle 'q' in colon mode
ColonLogicHandleQ() {
    global ColonStage
    if (ColonStage = "") {
        ColonStage := "q"
    } else if (ColonStage = "w") {
        ColonStage := "wq"
    } else if (ColonStage = "q") {
        ColonStage := "q"
    }
    ColonLogicShowTip()
}

; Execute colon command on Enter
ColonLogicEnter() {
    global ColonStage
    if (ColonStage = "w") {
        Send("^s")
    } else if (ColonStage = "q") {
        Send("!{F4}")
    } else if (ColonStage = "wq") {
        Send("^s")
        Sleep(80)
        Send("!{F4}")
    }
    ColonLogicCancel()
}

; ==============================
; G LOGIC (gg for top of file)
; ==============================

global GLogicActive := false

; Start 'g' mini-layer
GLogicStart() {
    global GLogicActive
    GLogicActive := true
    to := GetEffectiveTimeout("nvim")
    try SetTimer(GLogicTimeout, -to*1000)
}

; Handle second 'g' press (gg = top)
GLogicHandleG() {
    GLogicCancel()
    NvimGoToDocEdge(true)  ; top
}

; Cancel 'g' mini-layer
GLogicCancel() {
    global GLogicActive
    GLogicActive := false
}

; Timeout for 'g' mini-layer
GLogicTimeout() {
    GLogicCancel()
}

; ==============================
; DELETE MENU (context-aware deletion)
; ==============================

NvimHandleDeleteMenu() {
    global VisualMode
    if (VisualMode) {
        Send("{Delete}")
        return
    }
    ShowDeleteMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("nvim"), "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        try HideCSharpTooltip()
        return
    }
    key := ih.Input
    try HideCSharpTooltip()
    switch key {
        case "w": VimDeleteCurrentWord(), ShowCenteredToolTip("WORD DELETED"), SetTimer(() => RemoveToolTip(), -800)
        case "d": VimDeleteCurrentLineDirect(), ShowCenteredToolTip("LINE DELETED"), SetTimer(() => RemoveToolTip(), -800)
        case "a": VimDeleteAll(), ShowCenteredToolTip("ALL DELETED"), SetTimer(() => RemoveToolTip(), -800)
    }
}

; ==============================
; YANK MENU (context-aware copying)
; ==============================

NvimHandleYankMenu() {
    global VisualMode
    if (VisualMode) {
        Send("^c")
        ShowCopyNotification()
        return
    }
    ShowYankMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("nvim"), "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        try HideCSharpTooltip()
        return
    }
    key := ih.Input
    try HideCSharpTooltip()
    switch key {
        case "y": VimCopyCurrentLineDirect(), ShowCenteredToolTip("LINE COPIED"), SetTimer(() => RemoveToolTip(), -800)
        case "w": VimCopyCurrentWord(), ShowCopyNotification()
        case "a": Send("^a^c"), ShowCopyNotification()
        case "p": VimCopyCurrentParagraph(), ShowCenteredToolTip("PARAGRAPH COPIED"), SetTimer(() => RemoveToolTip(), -800)
    }
}

; ==============================
; HELP SYSTEM - VISUAL MODE
; ==============================

global VisualHelpActive := false

VisualShowHelp() {
    global tooltipConfig, VisualHelpActive
    try HideCSharpTooltip()
    Sleep 30
    VisualHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(VisualHelpAutoClose, -to)
    try ShowVisualHelpCS()
}

VisualHelpAutoClose() {
    global VisualHelpActive
    if (VisualHelpActive)
        VisualCloseHelp()
}

VisualCloseHelp() {
    global isNvimLayerActive, VisualMode, tooltipConfig, VisualHelpActive
    try SetTimer(VisualHelpAutoClose, 0)
    try HideCSharpTooltip()
    VisualHelpActive := false
    if (VisualMode) {
        try ShowVisualLayerToggleCS(true)
    } else if (isNvimLayerActive) {
        try ShowNvimLayerToggleCS(true)
    } else {
        try RemoveToolTip()
    }
}

; ==============================
; HELP SYSTEM - NVIM NORMAL MODE
; ==============================

global NvimHelpActive := false

NvimShowHelp() {
    global isNvimLayerActive, tooltipConfig, NvimHelpActive
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try HideCSharpTooltip()
        Sleep 30
    }
    NvimHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 5000
    try SetTimer(NvimHelpAutoClose, -to)
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimHelpCS()
        } else {
            ShowCenteredToolTip("NVIM HELP: hjkl move | gg/G top/bottom | v visual | y copy | p paste | u undo | x cut | i insert (no combo) | I insert+^!+i | f find")
        }
    } catch {
        ShowCenteredToolTip("NVIM HELP: hjkl move | gg/G top/bottom | v visual | y copy | p paste | u undo | x cut | i insert (no combo) | I insert+^!+i | f find")
    }
}

NvimHelpAutoClose() {
    global NvimHelpActive
    if (NvimHelpActive)
        NvimCloseHelp()
}

NvimCloseHelp() {
    if (VisualHelpActive)
        return
    global isNvimLayerActive, tooltipConfig, NvimHelpActive
    try SetTimer(NvimHelpAutoClose, 0)
    try HideCSharpTooltip()
    NvimHelpActive := false
    if (isNvimLayerActive) {
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled)
                ShowNvimLayerToggleCS(true)
            else
                ShowNvimLayerStatus(true)
        } catch {
            ShowNvimLayerStatus(true)
        }
    } else {
        try RemoveToolTip()
    }
}
