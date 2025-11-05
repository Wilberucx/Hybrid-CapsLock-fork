; Scroll tooltip integration (C#)

ShowScrollLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        if (isActive)
            ShowScrollLayerStatusCS(true)
        else
            HideCSharpTooltip()
    } else {
        ShowCenteredToolTip(isActive ? "SCROLL LAYER ON" : "SCROLL LAYER OFF")
        SetTimer(() => RemoveToolTip(), -1200)
    }
}

ShowScrollLayerStatusCS(isActive) {
    ; Ensure app is running and hide any previous tooltip to avoid overlap
    try HideCSharpTooltip()
    Sleep 30
    StartTooltipApp()
    theme := ReadTooltipThemeDefaults()
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "Scroll"
    cmd["layout"] := "list"
    cmd["tooltip_type"] := "bottom_right_list"
    cmd["timeout_ms"] := isActive ? 0 : 1000
    items := []
    it := Map()
    it["key"] := "?"
    it["description"] := "help"
    items.Push(it)
    cmd["items"] := items
    if (theme.style.Count)
        cmd["style"] := theme.style
    if (theme.position.Count)
        cmd["position"] := theme.position
    if (theme.window.Has("topmost"))
        cmd["topmost"] := theme.window["topmost"]
    if (theme.window.Has("click_through"))
        cmd["click_through"] := theme.window["click_through"]
    if (theme.window.Has("opacity"))
        cmd["opacity"] := theme.window["opacity"]
    json := SerializeJson(cmd)
    ScheduleTooltipJsonWrite(json)
}

ShowScrollHelpCS() {
    global tooltipConfig
    items := "k:Scroll up|j:Scroll down|h:Scroll left|l:Scroll right|s:Exit scroll layer"
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    if (to < 8000)
        to := 8000
    ShowBottomRightListTooltip("SCROLL HELP", items, "?: Close", to)
}
