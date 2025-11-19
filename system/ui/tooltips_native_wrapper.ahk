; ==============================
; UI native wrapper and status helpers
; ==============================
; Provides fallback UI when C# tooltips are disabled or unavailable.
; Exposes unified functions used by layers.

; Normalize navigation labels in native tooltips using INI [TooltipStyle]/navigation_label.
NormalizeNavigationLabels(text) {
    global HybridConfig, ConfigIni
    navLbl := ""
    
    ; Try HybridConfig theme first
    if (IsSet(HybridConfig)) {
        try {
            theme := HybridConfig.getTheme()
            if (theme.navigation.HasOwnProp("back_label") && theme.navigation.HasOwnProp("exit_label")) {
                text := StrReplace(text, "[\: Back]", "[" . theme.navigation.back_label . "]")
                text := StrReplace(text, "[Esc: Exit]", "[" . theme.navigation.exit_label . "]")
                text := StrReplace(text, "[ESC: Exit]", "[" . theme.navigation.exit_label . "]")
                return text
            }
        }
    }
    
    ; Fallback to INI
    try navLbl := IniRead(ConfigIni, "TooltipStyle", "navigation_label", "")
    if (navLbl != "" && navLbl != "ERROR") {
        parts := StrSplit(navLbl, "|")
        if (parts.Length >= 1)
            text := StrReplace(text, "[\\: Back]", "[" . Trim(parts[1]) . "]")
        if (parts.Length >= 2) {
            text := StrReplace(text, "[Esc: Exit]", "[" . Trim(parts[2]) . "]")
            text := StrReplace(text, "[ESC: Exit]", "[" . Trim(parts[2]) . "]")
        }
    } else {
        ; Default normalization to Backspace
        text := StrReplace(text, "[\\: Back]", "[BackSpace:Back]")
    }
    return text
}

; Basic tooltip centered on screen
ShowCenteredToolTip(Text) {
    ToolTipX := A_ScreenWidth // 2
    ToolTipY := A_ScreenHeight - 100
    ToolTip(Text, ToolTipX, ToolTipY)
}

; Remove any active tooltip
RemoveToolTip() {
    ToolTip()
}

; Hide current menu tooltip or C# tooltip (menus use id=2 in native)
HideMenuTooltip() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        HideCSharpTooltip()
    } else {
        ; Hide menu tooltip with id=2
        ToolTip(, , , 2)
    }
}

; Hide all tooltips (both default and menu id)
HideAllTooltips() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        HideCSharpTooltip()
    }
    ToolTip()
    ToolTip(, , , 2)
}

; Temporary status setter (shared with UI status)
SetTempStatus(status, duration) {
    global currentTempStatus, tempStatusExpiry
    currentTempStatus := status
    tempStatusExpiry := A_TickCount + duration
}

; Status helpers using either C# or native fallback
ShowCopyNotification() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCopyNotificationCS()
    } else {
        ShowCenteredToolTip("COPIED")
        SetTimer(() => RemoveToolTip(), -800)
    }
    ; Post-copy motion to emulate NVIM yank feedback: move cursor Up when NVIM layer is active
    try {
        global isNvimLayerActive, ConfigIni
        if (IsSet(isNvimLayerActive) && isNvimLayerActive) {
            Sleep 30
            Send("{Up}")
            ; Optionally return cursor with Down after Up (NVIM-like yank feedback)
            ret := "true"
            try ret := IniRead(ConfigIni, "Nvim", "yank_feedback_return", "true")
            if (StrLower(Trim(ret)) = "true") {
                Sleep 25
                Send("{Down}")
            }
        }
    }
}

ShowLeftClickStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpStatusNotification("MOUSE", isActive ? "LEFT CLICK HELD" : "LEFT CLICK RELEASED")
    } else {
        ShowCenteredToolTip(isActive ? "LEFT CLICK HELD" : "LEFT CLICK RELEASED")
    }
}

ShowRightClickStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpStatusNotification("MOUSE", "RIGHT CLICK")
    } else {
        ShowCenteredToolTip("RIGHT CLICK")
    }
}

ShowCapsLockStatus(isNormal) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpStatusNotification("CAPSLOCK", isNormal ? "NORMAL MODE" : "HYBRID MODE")
    } else {
        ShowCenteredToolTip(isNormal ? "CAPSLOCK NORMAL MODE" : "CAPSLOCK HYBRID MODE")
    }
}

ShowProcessTerminated() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowProcessTerminatedCS()
    } else {
        ShowCenteredToolTip("PROCESS TERMINATED")
    }
}

ShowNvimLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(isActive)
    } else {
        ShowCenteredToolTip(isActive ? "◉ NVIM" : "○ NVIM")
        SetTimer(() => RemoveToolTip(), -900)
    }
}

ShowVisualModeStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowVisualLayerToggleCS(isActive)
        ; If turning OFF Visual and NVIM layer remains active, restore NVIM persistent tooltip
        try {
            global isNvimLayerActive
            if (!isActive && isNvimLayerActive)
                ShowNvimLayerToggleCS(true)
        }
    } else {
        ShowCenteredToolTip(isActive ? "◉ VISUAL" : "○ VISUAL")
        SetTimer(() => RemoveToolTip(), -900)
    }
}

ShowExcelLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowExcelLayerToggleCS(isActive)
    } else {
        ShowCenteredToolTip(isActive ? "◉ EXCEL" : "○ EXCEL")
        SetTimer(() => RemoveToolTip(), -900)
    }
}

ShowVisualLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowVisualLayerToggleCS(isActive)
    } else {
        ShowCenteredToolTip(isActive ? "◉ VISUAL" : "○ VISUAL")
        SetTimer(() => RemoveToolTip(), -900)
    }
}

ShowDeleteMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowDeleteMenuCS()
    } else {
        ShowCenteredToolTip("DELETE: w=word, d=line, a=all")
    }
}

ShowYankMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowYankMenuCS()
    } else {
        ShowCenteredToolTip("YANK: y=line, w=word, a=all, p=paragraph")
    }
}
