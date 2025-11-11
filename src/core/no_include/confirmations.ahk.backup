; ==============================
; Core confirmations (global/layer/category/command)
; ==============================
; Confirmation helpers and rules precedence. Depends on globals+config.

; ---- Simple Y/N confirmation with timeout ----
ConfirmYN(prompt, timeoutLayer := "leader") {
    global tooltipConfig
    ; Show confirmation UI
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowCSharpOptionsMenu(prompt, "y:Yes|n:No", "Esc: Cancel")
    } else {
        ShowCenteredToolTip(prompt . "`n[y: Yes] [n/Esc: No]")
    }
    ; Wait for single key input
    ih := InputHook("L1 T" . GetEffectiveTimeout(timeoutLayer))
    ih.KeyOpt("{Escape}", "+")
    ih.Start()
    ih.Wait()
    result := false
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        result := false
    } else if (ih.EndReason = "Timeout") {
        result := false
    } else {
        key := ih.Input
        if (key = "y" || key = "Y")
            result := true
    }
    ih.Stop()
    ; Hide tooltip if C#
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        HideCSharpTooltip()
    } else {
        SetTimer(() => RemoveToolTip(), -200)
    }
    return result
}

; ---- Layer default confirmations ----
ShouldConfirmAction(layer) {
    global ConfigIni, ProgramsIni, InfoIni, TimestampsIni, CommandsIni
    ; Global override: if true, confirmation is enforced for all layers
    globalFlag := CleanIniBool(IniRead(ConfigIni, "Behavior", "show_confirmation_global", "false"), false)
    if (globalFlag)
        return true
    ; Per-layer flags
    if (layer = "programs") {
        return CleanIniBool(IniRead(ProgramsIni, "Settings", "show_confirmation", "false"), false)
    }
    if (layer = "information") {
        return CleanIniBool(IniRead(InfoIni, "Settings", "show_confirmation", "false"), false)
    }
    if (layer = "timestamps") {
        return CleanIniBool(IniRead(TimestampsIni, "Settings", "show_confirmation", "false"), false)
    }
    if (layer = "power") {
        ; More conservative default for power operations
        return CleanIniBool(IniRead(CommandsIni, "Settings", "show_confirmation", "true"), true)
    }
    return false
}

; ---- Programs layer confirmations ----
ShouldConfirmPrograms(key) {
    global ConfigIni, ProgramsIni
    if (CleanIniBool(IniRead(ConfigIni, "Behavior", "show_confirmation_global", "false"), false))
        return true
    confKeys := IniRead(ProgramsIni, "ProgramMapping", "confirm_keys", "")
    noConfKeys := IniRead(ProgramsIni, "ProgramMapping", "no_confirm_keys", "")
    if (confKeys != "" && KeyInList(key, confKeys))
        return true
    if (noConfKeys != "" && KeyInList(key, noConfKeys))
        return false
    sec := "ProgramMapping"
    aliasAscii := "key_ascii_" . Ord(key)
    val := IniRead(ProgramsIni, sec, aliasAscii, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    aliasKey := "key_" . key
    val := IniRead(ProgramsIni, sec, aliasKey, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    val := IniRead(ProgramsIni, sec, key, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    layerVal := IniRead(ProgramsIni, "Settings", "show_confirmation", "")
    if (layerVal != "" && layerVal != "ERROR")
        return CleanIniBool(layerVal, false)
    return false
}

; ---- Information layer confirmations ----
ShouldConfirmInformation(key) {
    global ConfigIni, InfoIni
    if (CleanIniBool(IniRead(ConfigIni, "Behavior", "show_confirmation_global", "false"), false))
        return true
    confKeys := IniRead(InfoIni, "InfoMapping", "confirm_keys", "")
    noConfKeys := IniRead(InfoIni, "InfoMapping", "no_confirm_keys", "")
    if (confKeys != "" && KeyInList(key, confKeys))
        return true
    if (noConfKeys != "" && KeyInList(key, noConfKeys))
        return false
    sec := "InfoMapping"
    aliasAscii := "key_ascii_" . Ord(key)
    val := IniRead(InfoIni, sec, aliasAscii, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    aliasKey := "key_" . key
    val := IniRead(InfoIni, sec, aliasKey, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    val := IniRead(InfoIni, sec, key, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    layerVal := IniRead(InfoIni, "Settings", "show_confirmation", "")
    if (layerVal != "" && layerVal != "ERROR")
        return CleanIniBool(layerVal, false)
    return false
}

; ---- Timestamps layer confirmations ----
ShouldConfirmTimestamp(mode, key) {
    global ConfigIni, TimestampsIni
    if (CleanIniBool(IniRead(ConfigIni, "Behavior", "show_confirmation_global", "false"), false))
        return true
    friendly := ""
    switch mode {
        case "date": friendly := "Date"
        case "time": friendly := "Time"
        case "datetime": friendly := "DateTime"
        default: friendly := mode
    }
    catKey := friendly . "_show_confirmation"
    catVal := IniRead(TimestampsIni, "CategorySettings", catKey, "")
    if (catVal != "" && catVal != "ERROR") {
        if (CleanIniBool(catVal, false))
            return true
    }
    sec := "Confirmations." . friendly
    confKeys := IniRead(TimestampsIni, sec, "confirm_keys", "")
    noConfKeys := IniRead(TimestampsIni, sec, "no_confirm_keys", "")
    if (confKeys != "" && KeyInList(key, confKeys))
        return true
    if (noConfKeys != "" && KeyInList(key, noConfKeys))
        return false
    layerVal := IniRead(TimestampsIni, "Settings", "show_confirmation", "")
    if (layerVal != "" && layerVal != "ERROR")
        return CleanIniBool(layerVal, false)
    return false
}

; ---- Commands layer confirmations (category + command) ----
GetFriendlyCategoryName(cat) {
    switch cat {
        case "system": return "System"
        case "network": return "Network"
        case "git": return "Git"
        case "monitoring": return "Monitoring"
        case "folder": return "Folder"
        case "windows": return "Windows"
        case "power": return "PowerOptions"
        case "adb": return "ADBTools"
        case "hybrid": return "HybridManagement"
        case "vaultflow": return "VaultFlow"
        default: return cat
    }
}

NormalizeCategoryToken(name) {
    n := StrLower(Trim(name))
    n := RegExReplace(n, "[\s_]+", "")
    switch n {
        case "system": return "system"
        case "network": return "network"
        case "git": return "git"
        case "monitoring": return "monitoring"
        case "folder": return "folder"
        case "windows": return "windows"
        case "power", "poweroptions": return "power"
        case "adb", "adbtools": return "adb"
        case "hybrid", "hybridmanagement": return "hybrid"
        case "vaultflow": return "vaultflow"
        default: return ""
    }
}

GetInternalCategoryFromIniKey(key) {
    global CommandsIni
    key := StrLower(key)
    iniVal := IniRead(CommandsIni, "Categories", key, "")
    if (iniVal != "" && iniVal != "ERROR") {
        return NormalizeCategoryToken(iniVal)
    }
    return ""
}

GetCategoryKeySymbol(categoryInternal) {
    switch categoryInternal {
        case "system": return "s"
        case "network": return "n"
        case "git": return "g"
        case "monitoring": return "m"
        case "folder": return "f"
        case "windows": return "w"
        case "power": return "o"
        case "adb": return "a"
        case "hybrid": return "h"
        case "vaultflow": return "v"
        default:
            ; Dynamic fallback: resolve symbol from [Categories] by matching normalized title
            global CommandsIni
            order := IniRead(CommandsIni, "Categories", "order", "")
            if (order != "" && order != "ERROR") {
                normWanted := NormalizeCategoryToken(categoryInternal)
                keys := StrSplit(order, [",", " ", "`t"]) 
                for _, k in keys {
                    k := Trim(k)
                    if (k = "")
                        continue
                    title := IniRead(CommandsIni, "Categories", k, "")
                    if (title = "" || title = "ERROR")
                        continue
                    if (NormalizeCategoryToken(title) = normWanted)
                        return k
                }
            }
            return ""
    }
}

ShouldConfirmCommand(categoryInternal, key) {
    global ConfigIni, CommandsIni
    if (CleanIniBool(IniRead(ConfigIni, "Behavior", "show_confirmation_global", "false"), false))
        return true
    friendly := GetFriendlyCategoryName(categoryInternal)
    catSym := GetCategoryKeySymbol(categoryInternal)
    if (catSym != "") {
        secCat := catSym . "_category"
        newCatFlag := IniRead(CommandsIni, secCat, catSym . "_show_confirmation", "")
        if (newCatFlag != "" && newCatFlag != "ERROR") {
            if (CleanIniBool(newCatFlag, false))
                return true
        }
    }
    catKey := friendly . "_show_confirmation"
    catVal := IniRead(CommandsIni, "CategorySettings", catKey, "")
    if (catVal != "" && catVal != "ERROR") {
        if (CleanIniBool(catVal, false))
            return true
    } else {
        catKey2 := categoryInternal . "_show_confirmation"
        catVal2 := IniRead(CommandsIni, "CategorySettings", catKey2, "")
        if (catVal2 != "" && catVal2 != "ERROR") {
            if (CleanIniBool(catVal2, false))
                return true
        }
    }
    if (catSym != "") {
        secCat := catSym . "_category"
        confKeys := IniRead(CommandsIni, secCat, "confirm_keys", "")
        noConfKeys := IniRead(CommandsIni, secCat, "no_confirm_keys", "")
        if (confKeys != "" && KeyInList(key, confKeys))
            return true
        if (noConfKeys != "" && KeyInList(key, noConfKeys))
            return false
    }
    if (catSym != ""
        ) {
        secKey := "Confirmations." . catSym
        confKeys := IniRead(CommandsIni, secKey, "confirm_keys", "")
        noConfKeys := IniRead(CommandsIni, secKey, "no_confirm_keys", "")
        if (confKeys != "" && KeyInList(key, confKeys))
            return true
        if (noConfKeys != "" && KeyInList(key, noConfKeys))
            return false
    }
    catSym := GetCategoryKeySymbol(categoryInternal)
    if (catSym != "") {
        secKey := "Confirmations." . catSym
        confKeys := IniRead(CommandsIni, secKey, "confirm_keys", "")
        noConfKeys := IniRead(CommandsIni, secKey, "no_confirm_keys", "")
        if (confKeys != "" && KeyInList(key, confKeys))
            return true
        if (noConfKeys != "" && KeyInList(key, noConfKeys))
            return false
    }
    sec := "Confirmations." . friendly
    confKeys := IniRead(CommandsIni, sec, "confirm_keys", "")
    noConfKeys := IniRead(CommandsIni, sec, "no_confirm_keys", "")
    if (confKeys != "" && KeyInList(key, confKeys))
        return true
    if (noConfKeys != "" && KeyInList(key, noConfKeys))
        return false
    sec2 := "Confirmations." . categoryInternal
    if (confKeys = "")
        confKeys := IniRead(CommandsIni, sec2, "confirm_keys", "")
    if (noConfKeys = "")
        noConfKeys := IniRead(CommandsIni, sec2, "no_confirm_keys", "")
    if (confKeys != "" && KeyInList(key, confKeys))
        return true
    if (noConfKeys != "" && KeyInList(key, noConfKeys))
        return false
    sec := "Confirmations." . friendly
    aliasAscii := "key_ascii_" . Ord(key)
    val := IniRead(CommandsIni, sec, aliasAscii, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    aliasKey := "key_" . key
    val := IniRead(CommandsIni, sec, aliasKey, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    val := IniRead(CommandsIni, sec, key, "")
    if (val != "" && val != "ERROR")
        return CleanIniBool(val, false)
    sec2 := "Confirmations." . categoryInternal
    val2 := IniRead(CommandsIni, sec2, aliasAscii, "")
    if (val2 != "" && val2 != "ERROR")
        return CleanIniBool(val2, false)
    val2 := IniRead(CommandsIni, sec2, aliasKey, "")
    if (val2 != "" && val2 != "ERROR")
        return CleanIniBool(val2, false)
    val2 := IniRead(CommandsIni, sec2, key, "")
    if (val2 != "" && val2 != "ERROR")
        return CleanIniBool(val2, false)
    layerVal := IniRead(CommandsIni, "Settings", "show_confirmation", "")
    if (layerVal != "" && layerVal != "ERROR")
        return CleanIniBool(layerVal, false)
    return (categoryInternal = "power")
}
