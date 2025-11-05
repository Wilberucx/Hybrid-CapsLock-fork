; ==============================
; Core configuration and INI helpers
; ==============================
; All helpers to read/normalize INI values and derive effective timeouts.
; Depends on globals declared in src/core/globals.ahk

; ---- Value cleaners ----
CleanIniNumber(value) {
    if (value = "" || value = "ERROR")
        return ""
    if (InStr(value, ";"))
        value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
    value := Trim(value)
    if RegExMatch(value, "^[0-9]+(\.[0-9]+)?$")
        return value
    return ""
}

CleanIniBool(value, default := true) {
    if (value = "" || value = "ERROR")
        return default
    if (InStr(value, ";"))
        value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
    v := StrLower(Trim(value))
    return (v = "true" || v = "1" || v = "yes" || v = "on")
}

; ---- Key list helpers (comma/space separated, case-sensitive compare) ----
ParseKeyList(s) {
    if (s = "" || s = "ERROR")
        return []
    if InStr(s, ";")
        s := Trim(SubStr(s, 1, InStr(s, ";") - 1))
    arr := []
    for part in StrSplit(s, [",", " ", "`t", "`n", "`r"]) {
        token := Trim(part)
        if (token != "")
            arr.Push(token)
    }
    return arr
}

KeyInList(key, listStr) {
    for token in ParseKeyList(listStr) {
        if (token == key) ; case-sensitive on purpose
            return true
    }
    return false
}

; ---- Load layer enable flags from configuration ----
LoadLayerFlags() {

    global capsTapThresholdMs, ConfigIni
    global ConfigIni, nvimLayerEnabled, excelLayerEnabled, modifierLayerEnabled, leaderLayerEnabled, enableLayerPersistence, debug_mode
    nvimLayerEnabled := CleanIniBool(IniRead(ConfigIni, "Layers", "nvim_layer_enabled", "true"))
    excelLayerEnabled := CleanIniBool(IniRead(ConfigIni, "Layers", "excel_layer_enabled", "true"))
    modifierLayerEnabled := CleanIniBool(IniRead(ConfigIni, "Layers", "modifier_layer_enabled", "true"))
    leaderLayerEnabled := CleanIniBool(IniRead(ConfigIni, "Layers", "leader_layer_enabled", "true"))
    enableLayerPersistence := CleanIniBool(IniRead(ConfigIni, "Layers", "enable_layer_persistence", "true"))
    ; Read Nvim tap threshold if present
    thr := CleanIniNumber(IniRead(ConfigIni, "Behavior", "nvim_tap_threshold_ms", ""))
    if (thr != "" && thr != "ERROR")
        capsTapThresholdMs := Integer(thr)

    ; Hybrid pause settings
    global hybridPauseMinutes, enableEmergencyResumeHotkey
    m := CleanIniNumber(IniRead(ConfigIni, "Behavior", "hybrid_pause_minutes", ""))
    hybridPauseMinutes := (m != "" && m != "ERROR") ? Integer(m) : 10
    enableEmergencyResumeHotkey := CleanIniBool(IniRead(ConfigIni, "Behavior", "enable_emergency_resume_hotkey", "true"), true)
}

; ---- Compute effective timeouts with precedence (layer-specific > leader > global > default) ----
GetEffectiveTimeout(layer) {
    global ConfigIni, ProgramsIni, InfoIni, TimestampsIni, CommandsIni
    default := 10
    layerLower := StrLower(layer)
    timeoutStr := ""
    if (InStr(layerLower, "timestamps")) {
        timeoutStr := CleanIniNumber(IniRead(TimestampsIni, "Settings", "timeout_seconds", ""))
    } else if (InStr(layerLower, "commands")) {
        timeoutStr := CleanIniNumber(IniRead(CommandsIni, "Settings", "timeout_seconds", ""))
    } else if (InStr(layerLower, "programs")) {
        timeoutStr := CleanIniNumber(IniRead(ProgramsIni, "Settings", "timeout_seconds", ""))
    } else if (InStr(layerLower, "information")) {
        timeoutStr := CleanIniNumber(IniRead(InfoIni, "Settings", "timeout_seconds", ""))
    } else if (layerLower = "leader" or layerLower = "main" or layerLower = "windows") {
        leaderStr := CleanIniNumber(IniRead(ConfigIni, "Behavior", "leader_timeout_seconds", ""))
        if (leaderStr != "" && leaderStr != "ERROR")
            return Integer(leaderStr)
        globalStr := CleanIniNumber(IniRead(ConfigIni, "Behavior", "global_timeout_seconds", ""))
        if (globalStr != "" && globalStr != "ERROR")
            return Integer(globalStr)
        return default
    }
    if (timeoutStr != "" && timeoutStr != "ERROR")
        return Integer(timeoutStr)
    leaderStr := CleanIniNumber(IniRead(ConfigIni, "Behavior", "leader_timeout_seconds", ""))
    if (leaderStr != "" && leaderStr != "ERROR")
        return Integer(leaderStr)
    globalStr := CleanIniNumber(IniRead(ConfigIni, "Behavior", "global_timeout_seconds", ""))
    if (globalStr != "" && globalStr != "ERROR")
        return Integer(globalStr)
    return default
}

