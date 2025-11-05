; ==============================
; Windows Layer (menu + actions)
; ==============================
; Provides window management menu (ShowWindowMenu), action executor (ExecuteWindowAction)
; and the persistent blind switch mode (StartPersistentBlindSwitch).
; Depends on: tooltip_csharp_integration (CS menus), ui/tooltips_native_wrapper (fallback),
; core/config (GetEffectiveTimeout).

ShowWindowMenu() {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowWindowMenuCS()
    } else {
        ; Fallback to native tooltips
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 120
        menuText := "WINDOW MANAGER`n`n"
        menuText .= "SPLITS:`n"
        menuText .= "2 - Split 50/50    3 - Split 33/67`n"
        menuText .= "4 - Quarter Split`n`n"
        menuText .= "ACTIONS:`n"
        menuText .= "x - Close          m - Maximize`n"
        menuText .= "- - Minimize`n`n"
        menuText .= "ZOOM TOOLS:`n"
        menuText .= "d - Draw           z - Zoom`n"
        menuText .= "c - Zoom with cursor`n`n"
        menuText .= "WINDOW SWITCHING:`n"
        menuText .= "j/k - Persistent Window Switch`n`n"
        menuText .= "[Backspace: Back] [Esc: Exit]"
        menuText := NormalizeNavigationLabels(menuText)
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

ExecuteWindowAction(action) {
    ; Hide tooltip immediately if auto_hide_on_action is enabled (when using C#)
    if (IsSet(tooltipConfig) && tooltipConfig.enabled && tooltipConfig.autoHide) {
        HideCSharpTooltip()
    }

    switch action {
        case "2":
            ; Split 50/50
            Send("#{Left}")
            Sleep(100)
            Send("#{Right}")
            ShowCenteredToolTip("SPLIT 50/50")
            SetTimer(() => RemoveToolTip(), -1500)
        case "3":
            ; Split 33/67
            Send("#{Left}")
            Sleep(100)
            Send("#{Right}")
            Sleep(100)
            Send("#{Left}")
            ShowCenteredToolTip("SPLIT 33/67")
            SetTimer(() => RemoveToolTip(), -1500)
        case "4":
            ; Quarter split
            Send("#{Up}")
            Sleep(100)
            Send("#{Left}")
            ShowCenteredToolTip("QUARTER SPLIT")
            SetTimer(() => RemoveToolTip(), -1500)
        case "x":
            ; Close window
            Send("!{F4}")
            ShowCenteredToolTip("WINDOW CLOSED")
            SetTimer(() => RemoveToolTip(), -1500)
        case "m":
            ; Maximize
            Send("#{Up}")
            ShowCenteredToolTip("MAXIMIZED")
            SetTimer(() => RemoveToolTip(), -1500)
        case "-":
            ; Minimize
            Send("#{Down}")
            ShowCenteredToolTip("MINIMIZED")
            SetTimer(() => RemoveToolTip(), -1500)
        case "d":
            ; Draw (from v1: Ctrl+Alt+Shift+9)
            Send("^!+9")
            ShowCenteredToolTip("DRAW MODE")
            SetTimer(() => RemoveToolTip(), -1500)
        case "z":
            ; Zoom (from v1: Ctrl+Alt+Shift+1)
            Send("^!+1")
            ShowCenteredToolTip("ZOOM MODE")
            SetTimer(() => RemoveToolTip(), -1500)
        case "c":
            ; Zoom with cursor (from v1: Ctrl+Alt+Shift+4)
            Send("^!+4")
            ShowCenteredToolTip("ZOOM CURSOR")
            SetTimer(() => RemoveToolTip(), -1500)
        case "j":
            ; Persistent blind switch - start mode
            StartPersistentBlindSwitch()
        case "k":
            ; This will be handled in persistent mode
            StartPersistentBlindSwitch()
        default:
            ShowCenteredToolTip("Unknown action: " . action)
            SetTimer(() => RemoveToolTip(), -1500)
    }
}

StartPersistentBlindSwitch() {
    ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")

    ; Persistent loop for blind switching
    Loop {
        ih := InputHook("L1 T" . GetEffectiveTimeout("windows"))
        ih.Start()
        ih.Wait()

        if (ih.EndReason = "Timeout") {
            ih.Stop()
            ShowCenteredToolTip("BLIND SWITCH TIMEOUT")
            SetTimer(() => RemoveToolTip(), -1000)
            break
        }

        key := ih.Input
        ih.Stop()

        if (key = "j") {
            Send("!{Tab}")
            ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
        } else if (key = "k") {
            Send("!+{Tab}")
            ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
        } else if (key = Chr(13) || key = Chr(10)) {
            ShowCenteredToolTip("BLIND SWITCH ENDED")
            SetTimer(() => RemoveToolTip(), -1000)
            break
        } else if (key = Chr(27)) {
            ShowCenteredToolTip("BLIND SWITCH CANCELLED")
            SetTimer(() => RemoveToolTip(), -1000)
            break
        }
        ; Any other key -> continue loop
    }
}
