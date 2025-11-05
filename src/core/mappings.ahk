; ==============================
; Core mappings (dynamic hotkeys per layer)
; ==============================
; Utilities to load INI-based mappings and register hotkeys dynamically.

; ---- Parse action spec ----
ParseActionSpec(spec) {
    spec := Trim(spec)
    if (spec = "")
        return { type: "none" }
    colon := InStr(spec, ":")
    if (!colon) {
        return { type: "send", payload: spec }
    }
    kind := StrLower(Trim(SubStr(spec, 1, colon - 1)))
    payload := Trim(SubStr(spec, colon + 1))
    if (kind = "send")
        return { type: "send", payload: payload }
    if (kind = "func")
        return { type: "func", payload: payload }
    if (kind = "macro") {
        steps := []
        for part in StrSplit(payload, [";", "`n", "`r"]) {
            p := Trim(part)
            if (p != "")
                steps.Push(p)
        }
        return { type: "macro", steps: steps }
    }
    if (kind = "showmenu")
        return { type: "showmenu", payload: payload }
    if (kind = "notify")
        return { type: "notify", payload: payload }
    return { type: kind, payload: payload }
}

; ---- Normalize friendly modifier/key syntax ----
NormalizeSendSpec(s) {
    if (s = "")
        return s
    ; Translate friendly modifiers to AHK symbols (case-insensitive)
    s := RegExReplace(s, "(?i)\bcontrol\+", "^")
    s := RegExReplace(s, "(?i)\bctrl\+", "^")
    s := RegExReplace(s, "(?i)\balt\+", "!")
    s := RegExReplace(s, "(?i)\bshift\+", "+")
    s := RegExReplace(s, "(?i)\bwin(dows)?\+", "#")
    ; Wrap common named keys in braces if not already
    s := RegExReplace(s, "(?i)(?<!\{)right(?!\})", "{Right}")
    s := RegExReplace(s, "(?i)(?<!\{)left(?!\})", "{Left}")
    s := RegExReplace(s, "(?i)(?<!\{)up(?!\})", "{Up}")
    s := RegExReplace(s, "(?i)(?<!\{)down(?!\})", "{Down}")
    s := RegExReplace(s, "(?i)(?<!\{)home(?!\})", "{Home}")
    s := RegExReplace(s, "(?i)(?<!\{)end(?!\})", "{End}")
    s := RegExReplace(s, "(?i)(?<!\{)pgup(?!\})", "{PgUp}")
    s := RegExReplace(s, "(?i)(?<!\{)pgdn(?!\})", "{PgDn}")
    s := RegExReplace(s, "(?i)(?<!\{)(delete|del)(?!\})", "{Delete}")
    s := RegExReplace(s, "(?i)(?<!\{)(insert|ins)(?!\})", "{Insert}")
    s := RegExReplace(s, "(?i)(?<!\{)(backspace|bs)(?!\})", "{Backspace}")
    s := RegExReplace(s, "(?i)(?<!\{)(enter|return)(?!\})", "{Enter}")
    s := RegExReplace(s, "(?i)(?<!\{)(escape|esc)(?!\})", "{Escape}")
    s := RegExReplace(s, "(?i)(?<!\{)tab(?!\})", "{Tab}")
    ; Do NOT wrap literal bracket keys in braces; let modifiers apply to the raw char
    ; If you need layout-robust behavior, prefer scancodes: e.g., send:Ctrl+Alt+Shift+{sc01A} / {sc01B}

    return s
}

; ---- Execute action spec ----
ExecuteAction(layer, action) {
    if (!IsObject(action))
        action := ParseActionSpec(action)
    switch action.type {
        case "send":
            Send(NormalizeSendSpec(action.payload))
        case "func":
            fn := action.payload
            %fn%()
        case "notify":
            if (StrLower(action.payload) = "copy")
                ShowCopyNotification()
        case "macro":
            for step in action.steps {
                sColon := InStr(step, ":")
                if (!sColon) {
                    continue
                }
                sk := StrLower(Trim(SubStr(step, 1, sColon - 1)))
                sv := Trim(SubStr(step, sColon + 1))
                if (sk = "send")
                    Send(NormalizeSendSpec(sv))
                else if (sk = "sleep")
                    Sleep(Integer(sv))
                else if (sk = "tooltip") {
                    ShowCenteredToolTip(sv)
                    SetTimer(() => RemoveToolTip(), -1200)
                } else if (sk = "notify") {
                    if (StrLower(sv) = "copy")
                        ShowCopyNotification()
                } else if (sk = "func") {
                    fn := sv
                    %fn%()
                }
            }
        case "showmenu":
            if (SubStr(layer, 1, 4) = "nvim") {
                if (StrLower(action.payload) = "delete")
                    NvimHandleDeleteMenu()
                else if (StrLower(action.payload) = "yank")
                    NvimHandleYankMenu()
            } else {
                ; Unknown menu for this layer - no-op
            }
        default:
            ; Unknown: no-op
            return
    }
}

; ---- Generic layer mappings ----
_layerRegisteredHotkeys := {}

LoadSimpleMappings(iniPath, mapSection := "Map", orderKey := "order") {
    if (!FileExist(iniPath))
        return {}
    enable := StrLower(Trim(IniRead(iniPath, "Settings", "enable", "true")))
    if (enable = "false")
        return {}
    order := IniRead(iniPath, mapSection, orderKey, "")
    mappings := {}
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            spec := IniRead(iniPath, mapSection, k, "")
            if (spec != "" && spec != "ERROR")
                mappings[k] := ParseActionSpec(spec)
        }
    }
    return mappings
}

ApplyGenericMappings(layerName, mappings, contextFn, keyPrefix := "") {
    global debug_mode
    global _layerRegisteredHotkeys
    UnregisterGenericMappings(layerName)
    if (!IsSet(mappings) || mappings.Count = 0)
        return
    ; disable static per-layer if applicable
    if (layerName = "modifier") {
        global modifierStaticEnabled
        modifierStaticEnabled := false
    } else if (layerName = "excel") {
        global excelStaticEnabled
        excelStaticEnabled := false
    } else if (SubStr(layerName, 1, 4) = "nvim") {
        global nvimStaticEnabled
        try nvimStaticEnabled := false
    }
    HotIf(contextFn)
    for key, action in mappings.OwnProps() {
        hk := (keyPrefix = "") ? key : (keyPrefix . key)
        Hotkey(hk, (*) => (layerName = "modifier" ? (MarkCapsLockAsModifier(), ExecuteAction(layerName, action)) : ExecuteAction(layerName, action)), "On")
        if (!_layerRegisteredHotkeys.Has(layerName))
            _layerRegisteredHotkeys[layerName] := []
        _layerRegisteredHotkeys[layerName].Push(hk)
    }
    HotIf()
}

UnregisterGenericMappings(layerName) {
    global debug_mode
    global _layerRegisteredHotkeys
    if (_layerRegisteredHotkeys.Has(layerName)) {
        if (IsSet(debug_mode) && debug_mode)
            OutputDebug "[MAP] Unregister layer=" layerName ", count=" _layerRegisteredHotkeys[layerName].Length "\n"
        for _, hk in _layerRegisteredHotkeys[layerName] {
            try Hotkey(hk, , "Off")
        }
        _layerRegisteredHotkeys.Delete(layerName)
    }
    ; re-enable static per-layer if applicable
    if (layerName = "modifier") {
        global modifierStaticEnabled
        modifierStaticEnabled := true
    } else if (layerName = "excel") {
        global excelStaticEnabled
        excelStaticEnabled := true
    } else if (SubStr(layerName, 1, 4) = "nvim") {
        global nvimStaticEnabled
        try nvimStaticEnabled := true
    }
}

ReloadModifierMappings() {
    ; NOTA: Modifier mode desactivado - Delegado a Kanata
    ; Esta función se mantiene vacía para compatibilidad con código existente
    ; que pueda llamarla, pero no hace nada ya que Kanata maneja todas las
    ; combinaciones CapsLock+tecla ahora.
    return
    
    ; ---- CÓDIGO ORIGINAL DESACTIVADO ----
    ; global debug_mode
    ; try {
    ;     iniPath := A_ScriptDir . "\\config\\modifier_layer.ini"
    ;     maps := LoadSimpleMappings(iniPath)
    ;     if (IsSet(debug_mode) && debug_mode)
    ;         OutputDebug "[MOD] ReloadModifierMappings loaded=" (IsObject(maps) ? maps.Count : -1) "\n"
    ;     if (maps.Count > 0) {
    ;         if (IsSet(debug_mode) && debug_mode)
    ;             OutputDebug "[MOD] Applying modifier mappings: " maps.Count "\n"
    ;         ApplyGenericMappings("modifier", maps, (*) => (modifierLayerEnabled && ModifierLayerAppAllowed()), "CapsLock & ")
    ;     }
    ;     else {
    ;         if (IsSet(debug_mode) && debug_mode)
    ;             OutputDebug "[MOD] No modifier mappings found; unregistering\n"
    ;         UnregisterGenericMappings("modifier")
    ;     }
    ; } catch {
    ;     UnregisterGenericMappings("modifier")
    ; }
}

ReloadExcelMappings() {
    try {
        iniPath := A_ScriptDir . "\\config\\excel_layer.ini"
        maps := LoadExcelMappings(iniPath)
        if (maps.Count > 0)
            ApplyExcelMappings(maps)
        else
            UnregisterExcelMappings()
    } catch {
        UnregisterExcelMappings()
    }
}

ReloadNvimMappings() {
    ; Unregister previous nvim mappings (all subcontexts)
    UnregisterGenericMappings("nvim_normal")
    UnregisterGenericMappings("nvim_visual")
    UnregisterGenericMappings("nvim_insert")
    try {
        iniPath := A_ScriptDir . "\\config\\nvim_layer.ini"
        normal := LoadSimpleMappings(iniPath, "Normal", "order")
        visual := LoadSimpleMappings(iniPath, "Visual", "order")
        insert := LoadSimpleMappings(iniPath, "Insert", "order")
        if (normal.Count > 0)
            ApplyGenericMappings("nvim_normal", normal, (*) => (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
        if (visual.Count > 0)
            ApplyGenericMappings("nvim_visual", visual, (*) => (isNvimLayerActive && VisualMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
        if (insert.Count > 0)
            ApplyGenericMappings("nvim_insert", insert, (*) => (_tempEditMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
        if (normal.Count = 0 && visual.Count = 0 && insert.Count = 0) {
            ; fall back to static
            global nvimStaticEnabled
            nvimStaticEnabled := true
        }
    } catch {
        UnregisterGenericMappings("nvim")
    }
}

; ---- Excel mappings ----
_excelRegisteredHotkeys := []

LoadExcelMappings(iniPath) {
    if (!FileExist(iniPath))
        return {}
    enable := StrLower(Trim(IniRead(iniPath, "Settings", "enable", "true")))
    if (enable = "false")
        return {}
    order := IniRead(iniPath, "Map", "order", "")
    mappings := {}
    if (order != "" && order != "ERROR") {
        keys := StrSplit(order, [",", " ", "`t"])
        for _, k in keys {
            k := Trim(k)
            if (k = "")
                continue
            spec := IniRead(iniPath, "Map", k, "")
            if (spec != "" && spec != "ERROR")
                mappings[k] := ParseActionSpec(spec)
        }
    } else {
        ; fallback: try to read all known keys
        for k in ["7","8","9","u","i","o","j","k","l","m",",",".","p",";","/","w","a","s","d","[","]","Enter","Space","f","r"] {
            spec := IniRead(iniPath, "Map", k, "")
            if (spec != "" && spec != "ERROR")
                mappings[k] := ParseActionSpec(spec)
        }
    }
    return mappings
}

; register dynamic Excel hotkeys with context
ApplyExcelMappings(mappings) {
    global _excelRegisteredHotkeys
    ; unregister previous
    UnregisterExcelMappings()
    if (mappings.Count = 0)
        return
    ; disable static
    global excelStaticEnabled
    excelStaticEnabled := false
    ; Use InputLevel 1 to match static Excel hotkeys and allow minicapa V Logic (InputLevel 2) to override
    #InputLevel 1
    ; context: excelLayerActive and CapsLock not physically pressed
    HotIf((*) => (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelAppAllowedGuard()))
    for key, action in mappings.OwnProps() {
        hk := key
        Hotkey(hk, (*) => ExecuteAction("excel", action), "On")  ; Excel actions also go through NormalizeSendSpec via ExecuteAction
        _excelRegisteredHotkeys.Push(hk)
    }
    HotIf()
    #InputLevel 0
}

UnregisterExcelMappings() {
    global _excelRegisteredHotkeys, excelStaticEnabled
    for _, hk in _excelRegisteredHotkeys {
        try Hotkey(hk, , "Off")
    }
    _excelRegisteredHotkeys := []
    ; re-enable static
    excelStaticEnabled := true
}
