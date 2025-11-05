; ==============================
; Timestamps Layer (menus + writer)
; ==============================
; Provides timestamp menus (date/time/datetime) and writer based on timestamps.ini
; Depends on: core/config (GetEffectiveTimeout), core/confirmations (ShouldConfirmTimestamp, ConfirmYN)
; ui/tooltips_native_wrapper (fallback) and ui/tooltip_csharp_integration (CS menus)

ShowTimeMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowTimeMenuCS()
    } else {
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 80
        menuText := "TIMESTAMP MANAGER`n`n"
        menuText .= "d - Date Formats`n"
        menuText .= "t - Time Formats`n"
        menuText .= "h - Date+Time Formats`n`n"
        menuText .= "[Backspace: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowDateFormatsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowDateFormatsMenuCS()
    } else {
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "DATE FORMATS`n`n"
        Loop 10 {
            lineContent := IniRead(TimestampsIni, "MenuDisplay", "date_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowTimeFormatsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowTimeFormatsMenuCS()
    } else {
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := "TIME FORMATS`n`n"
        Loop 10 {
            lineContent := IniRead(TimestampsIni, "MenuDisplay", "time_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ShowDateTimeFormatsMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowDateTimeFormatsMenuCS()
    } else {
        global TimestampsIni
        ToolTipX := A_ScreenWidth // 2 - 140
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "DATE+TIME FORMATS`n`n"
        Loop 10 {
            lineContent := IniRead(TimestampsIni, "MenuDisplay", "datetime_line" . A_Index, "")
            if (lineContent != "" && lineContent != "ERROR")
                menuText .= lineContent . "`n"
        }
        menuText .= "`n[\: Back] [Esc: Exit]"
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

HandleTimestampMode(mode) {
    switch mode {
        case "d":
            Loop {
                ShowDateFormatsMenu()
                ih := InputHook("L1 T" . GetEffectiveTimeout("timestamps_date"))
                ih.Start()
                ih.Wait()
                if (ih.EndReason = "Timeout" || ih.Input = Chr(27)) { ; Esc
                    ih.Stop()
                    return
                }
                if (ih.Input = Chr(8)) { ; Backspace
                    ih.Stop()
                    break
                }
                if (ShouldConfirmTimestamp("date", ih.Input)) {
                    if (!ConfirmYN("Insert date?", "timestamps")) {
                        ih.Stop()
                        return
                    }
                }
                WriteTimestampFromKey("date", ih.Input)
                return
            }
        case "t":
            Loop {
                ShowTimeFormatsMenu()
                ih := InputHook("L1 T" . GetEffectiveTimeout("timestamps_time"))
                ih.Start()
                ih.Wait()
                if (ih.EndReason = "Timeout" || ih.Input = Chr(27)) { ; Esc
                    ih.Stop()
                    return
                }
                if (ih.Input = Chr(8)) { ; Backspace
                    ih.Stop()
                    break
                }
                if (ShouldConfirmTimestamp("time", ih.Input)) {
                    if (!ConfirmYN("Insert time?", "timestamps")) {
                        ih.Stop()
                        return
                    }
                }
                WriteTimestampFromKey("time", ih.Input)
                return
            }
        case "h":
            Loop {
                ShowDateTimeFormatsMenu()
                ih := InputHook("L1 T" . GetEffectiveTimeout("timestamps_datetime"))
                ih.Start()
                ih.Wait()
                if (ih.EndReason = "Timeout" || ih.Input = Chr(27)) { ; Esc
                    ih.Stop()
                    return
                }
                if (ih.Input = Chr(8)) { ; Backspace
                    ih.Stop()
                    break
                }
                if (ShouldConfirmTimestamp("datetime", ih.Input)) {
                    if (!ConfirmYN("Insert date/time?", "timestamps")) {
                        ih.Stop()
                        return
                    }
                }
                WriteTimestampFromKey("datetime", ih.Input)
                return
            }
        default:
            ShowCenteredToolTip("Unknown timestamp mode: " . mode)
            SetTimer(() => RemoveToolTip(), -1500)
    }
}

WriteTimestampFromKey(mode, keyPressed) {
    global TimestampsIni, tooltipConfig
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }
    if (mode = "date") {
        if (keyPressed = "d") {
            defaultNum := IniRead(TimestampsIni, "DateFormats", "default", "1")
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "DateFormats"
    } else if (mode = "time") {
        if (keyPressed = "t") {
            defaultNum := IniRead(TimestampsIni, "TimeFormats", "default", "1")
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "TimeFormats"
    } else if (mode = "datetime") {
        if (keyPressed = "h") {
            defaultNum := IniRead(TimestampsIni, "DateTimeFormats", "default", "1")
            formatKey := "format_" . defaultNum
        } else {
            formatKey := "format_" . keyPressed
        }
        sectionName := "DateTimeFormats"
    }
    formatString := IniRead(TimestampsIni, sectionName, formatKey, "")
    if (formatString = "" || formatString = "ERROR") {
        ShowCenteredToolTip("Format '" . keyPressed . "' not found in " . sectionName)
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    timestamp := FormatTime(, formatString)
    SendText(timestamp)
    ShowCenteredToolTip("TIMESTAMP: " . timestamp)
    SetTimer(() => RemoveToolTip(), -2000)
}
