; ==============================
; Information Layer (menu + insert/preview)
; ==============================
; Provides info menu and insertion from information.ini mapping.
; Depends on: core/config (GetEffectiveTimeout), core/confirmations (ShouldConfirmInformation, ConfirmYN)
; ui/tooltips_native_wrapper (fallback) and ui/tooltip_csharp_integration (CS menus)

ShowInformationMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowInformationMenuCS()
    } else {
        menuText := GenerateInformationMenuText()
        ToolTipX := A_ScreenWidth // 2 - 120
        ToolTipY := A_ScreenHeight // 2 - 100
        menuText := NormalizeNavigationLabels(menuText)
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

GenerateInformationMenuText() {
    global InfoIni
    menuText := "INFORMATION MANAGER`n`n"
    orderStr := IniRead(InfoIni, "InfoMapping", "order", "")
    if (orderStr = "" || orderStr = "ERROR")
        orderStr := "e n p a c w g l r"
    keys := StrSplit(orderStr, " ")
    currentLine := ""
    Loop keys.Length {
        key := Trim(keys[A_Index])
        if (key = "")
            continue
        infoName := IniRead(InfoIni, "InfoMapping", key, "")
        if (infoName = "" || infoName = "ERROR")
            continue
        entry := key . " - " . infoName
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

InsertInformationFromKey(keyPressed) {
    global InfoIni
    infoName := IniRead(InfoIni, "InfoMapping", keyPressed, "")
    if (infoName = "" || infoName = "ERROR") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.`nAdd to information.ini`n[InfoMapping]")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    infoContent := IniRead(InfoIni, "PersonalInfo", infoName, "")
    if (infoContent = "" || infoContent = "ERROR") {
        ShowCenteredToolTip(infoName . " not found in [PersonalInfo].`nAdd content to information.ini")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    autoPaste := CleanIniBool(IniRead(InfoIni, "Settings", "auto_paste", "true"), true)
    if (!autoPaste) {
        ShowInformationDetails(keyPressed)
        return
    }
    if (ShouldConfirmInformation(keyPressed)) {
        if (!ConfirmYN("Insert " . infoName . "?", "information"))
            return
    }
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide)
        HideCSharpTooltip()
    SendText(infoContent)
    ShowCenteredToolTip(infoName . " INSERTED")
    SetTimer(() => RemoveToolTip(), -1500)
}

ShowInformationDetails(keyPressed) {
    global InfoIni
    infoName := IniRead(InfoIni, "InfoMapping", keyPressed, "")
    if (infoName = "" || infoName = "ERROR") {
        ShowCenteredToolTip("Key '" . keyPressed . "' not mapped.`nAdd to information.ini`n[InfoMapping]")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    infoContent := IniRead(InfoIni, "PersonalInfo", infoName, "")
    if (infoContent = "" || infoContent = "ERROR") {
        ShowCenteredToolTip(infoName . " not found in [PersonalInfo].`nAdd content to information.ini")
        SetTimer(() => RemoveToolTip(), -3500)
        return
    }
    detailsText := "INFORMATION: " . infoName . "`nCONTENT: " . infoContent . "`n`nPress ENTER to insert`nPress ESC to cancel"
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpTooltip(detailsText, "Information Details", "info")
    } else {
        ShowCenteredToolTip(detailsText)
    }
    userInput := InputHook("L1 T" . GetEffectiveTimeout("information"))
    userInput.KeyOpt("{Enter}", "ES")
    userInput.KeyOpt("{Escape}", "ES")
    userInput.Start()
    userInput.Wait()
    if (userInput.EndReason = "KeyDown" && userInput.EndKey = "Enter") {
        if (ShouldConfirmInformation(keyPressed)) {
            if (!ConfirmYN("Insert " . infoName . "?", "information")) {
                userInput.Stop()
                return
            }
        }
        if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide) {
            HideCSharpTooltip()
        }
        SendText(infoContent)
        ShowCenteredToolTip(infoName . " INSERTED")
        SetTimer(() => RemoveToolTip(), -1500)
    }
    userInput.Stop()
    if (IsSet(tooltipConfig) && tooltipConfig.enabled)
        HideCSharpTooltip()
}
