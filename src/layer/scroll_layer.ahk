; ===================================================================
; Scroll Layer (basic)
; - Activated via Leader -> s
; - While active: k scrolls up, j scrolls down
; - Shows persistent tooltip (C#) with "Scroll ? help"
; ===================================================================

; Ensure globals have default values
if (!IsSet(scrollLayerEnabled))
    global scrollLayerEnabled := true
if (!IsSet(scrollLayerActive))
    global scrollLayerActive := false

#HotIf (scrollLayerEnabled ? (scrollLayerActive && !GetKeyState("CapsLock", "P")) : false)

; Up / Down scroll
k::Send("{WheelUp}")
j::Send("{WheelDown}")

; Left / Right scroll
h::Send("+{WheelUp}")
l::Send("+{WheelDown}")

; Exit Scroll layer with Shift+n (consistent with Excel exit)
s:: {
    global scrollLayerActive
    scrollLayerActive := false
    ShowScrollLayerStatus(false)
    SetTempStatus("SCROLL LAYER OFF", 1500)
}

; Help toggle with '?'
+vkBF:: (ScrollHelpActive ? ScrollCloseHelp() : ScrollShowHelp())
+SC035:: (ScrollHelpActive ? ScrollCloseHelp() : ScrollShowHelp())
?:: (ScrollHelpActive ? ScrollCloseHelp() : ScrollShowHelp())

#HotIf

; Help routines
global ScrollHelpActive := false

ScrollShowHelp() {
    global tooltipConfig, ScrollHelpActive
    try HideCSharpTooltip()
    Sleep 30
    ScrollHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(ScrollHelpAutoClose, -to)
    try ShowScrollHelpCS()
}

ScrollHelpAutoClose() {
    global ScrollHelpActive
    if (ScrollHelpActive)
        ScrollCloseHelp()
}

ScrollCloseHelp() {
    global scrollLayerActive, ScrollHelpActive
    try SetTimer(ScrollHelpAutoClose, 0)
    try HideCSharpTooltip()
    ScrollHelpActive := false
    if (scrollLayerActive) {
        try ShowScrollLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}

