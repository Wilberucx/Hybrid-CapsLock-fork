; ==============================
; Modifier Mode (CapsLock & key)
; ==============================
; Migrated core of Modifier Mode: window controls, navigation, scrolling, common shortcuts.
; Depends on: core/globals (MarkCapsLockAsModifier), ui (status/tooltip helpers)

; Try dynamic mappings if available (modifier)
try {
    global modifierMappings
    if (IsSet(debug_mode) && debug_mode)
        OutputDebug "[MOD] Startup loading modifier INI...\n"
    modifierMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\modifier_layer.ini")
    if (modifierMappings.Count > 0)
        ApplyGenericMappings("modifier", modifierMappings, (*) => (modifierLayerEnabled && ModifierLayerAppAllowed()), "CapsLock & ")
} catch {
}

#HotIf (modifierStaticEnabled ? (modifierLayerEnabled) : false)

; ----- Window Functions -----
; Toggle OS CapsLock state with CapsLock+F10 (no script mode changes)
CapsLock & F10:: {
    MarkCapsLockAsModifier()
    ; Read current OS CapsLock state and set explicitly to the opposite
    cur := GetKeyState("CapsLock", "T")
    try {
        SetCapsLockState(cur ? "Off" : "On")
    } catch {
    }
}

CapsLock & 1::WinMinimize("A")
CapsLock & `::Send("#m")  ; Minimize all windows
CapsLock & q::Send("!{F4}")  ; Close window (Alt+F4)

; Maximize/Restore toggle
CapsLock & f:: {
    MarkCapsLockAsModifier()
    winState := WinGetMinMax("A")
    if (winState = 1)
        WinRestore("A")
    else
        WinMaximize("A")
}

; ----- Window Switcher / Custom -----
CapsLock & Tab:: {
    ; Enhanced Alt+Tab: hold CapsLock to keep cycling with Tab
    MarkCapsLockAsModifier()
    Send("{Alt down}{Tab}")
    KeyWait("Tab")
    while GetKeyState("CapsLock", "P") {
        if GetKeyState("Tab", "P") {
            Send("{Tab}")
            KeyWait("Tab")
        }
        Sleep(10)
    }
    Send("{Alt up}")
}
CapsLock & 2:: {
    MarkCapsLockAsModifier()
    Send("^!+2")
}

; ----- Basic Navigation (Vim Style) -----
; hjkl modifier-aware arrows (Ctrl/Alt/Shift/Win). If any modifier is held,
; it is applied to the arrow key. Reserved combos como Ctrl+a/Ctrl+c no se ven
; afectados porque son otras teclas (no hjkl). Caso Ctrl+Shift+c queda pendiente.

CapsLock & h:: {
    MarkCapsLockAsModifier()
    pref := GetActiveModPrefixForArrows()
    Send(pref . "{Left}")
}
CapsLock & j:: {
    MarkCapsLockAsModifier()
    pref := GetActiveModPrefixForArrows()
    Send(pref . "{Down}")
}
CapsLock & k:: {
    MarkCapsLockAsModifier()
    pref := GetActiveModPrefixForArrows()
    Send(pref . "{Up}")
}
CapsLock & l:: {
    MarkCapsLockAsModifier()
    pref := GetActiveModPrefixForArrows()
    Send(pref . "{Right}")
}

; ----- Smooth Scrolling -----
CapsLock & e:: {
    MarkCapsLockAsModifier()
    Send("{WheelDown 3}")
}
CapsLock & d:: {
    MarkCapsLockAsModifier()
    Send("{WheelUp 3}")
}

; ----- Common Shortcuts (Ctrl equivalents) -----
CapsLock & s:: {
    MarkCapsLockAsModifier()
    Send("^s")
} ; Save
CapsLock & c:: {
    MarkCapsLockAsModifier()
    Send("^c")
    ShowCopyNotification()
} ; Copy + notify
CapsLock & v:: {
    MarkCapsLockAsModifier()
    Send("^v")
} ; Paste
CapsLock & x:: {
    MarkCapsLockAsModifier()
    Send("^x")
} ; Cut
CapsLock & z:: {
    MarkCapsLockAsModifier()
    Send("^z")
} ; Undo
CapsLock & a:: {
    MarkCapsLockAsModifier()
    Send("^a")
} ; Select all

; ----- File/Tab Operations -----
CapsLock & o:: {
    MarkCapsLockAsModifier()
    Send("^o")
} ; Open
CapsLock & t:: {
    MarkCapsLockAsModifier()
    Send("^t")
} ; New tab
CapsLock & w:: {
    MarkCapsLockAsModifier()
    Send("^w")
} ; Close tab

; ----- Tabs Navigation -----
CapsLock & m:: {
    MarkCapsLockAsModifier()
    Send("^{PgDn}")
} ; Next tab
CapsLock & u:: {
    MarkCapsLockAsModifier()
    Send("^{PgUp}")
} ; Prev tab

; ----- Mouse-like -----
;CapsLock & sc027:: {
;    MarkCapsLockAsModifier()
;    SendEvent("{LButton down}")
;}
;CapsLock & sc028::  {
;    MarkCapsLockAsModifier()
;    Click "Right"
;}

; ----- Back / URL copy / Screenshot / Ctrl+Enter -----

; ----- Browse navigation (Back/Forward) -----
CapsLock & [:: {
    MarkCapsLockAsModifier()
    Send("^!+{[}")
}
CapsLock & ]:: {
    MarkCapsLockAsModifier()
    Send("^!+{]}")
}

; Missing hotkey from v1
CapsLock & g:: {
    MarkCapsLockAsModifier()
    Send("^!+g")
}

; Missing hotkey from v1
CapsLock & p:: {
    MarkCapsLockAsModifier()
    Send("+!p")
}

CapsLock & Backspace:: {
    MarkCapsLockAsModifier()
    Send("!{Left}")
} ; Back
CapsLock & 5:: {
    MarkCapsLockAsModifier()
    Send("^l^c")
    ShowCopyNotification()
} ; Copy path/URL
CapsLock & 9:: {
    MarkCapsLockAsModifier()
    Send("#+s")
} ; Snip
CapsLock & Enter:: {
    MarkCapsLockAsModifier()
    Send("^{Enter}")
} ; Ctrl+Enter

; ----- Mouse release (click hold cleanup) -----
#HotIf (modifierStaticEnabled ? (modifierLayerEnabled && GetKeyState("CapsLock", "P") && ModifierLayerAppAllowed()) : false)
sc027 up:: {
    SendEvent("{LButton up}")
}
#HotIf (modifierStaticEnabled ? (modifierLayerEnabled) : false)

#HotIf

; ---- Arrow modifiers helper ----
GetActiveModPrefixForArrows() {
    pref := ""
    try {
        if (GetKeyState("LWin", "P") || GetKeyState("RWin", "P"))
            pref .= "#"
        if (GetKeyState("Ctrl", "P"))
            pref .= "^"
        if (GetKeyState("Alt", "P"))
            pref .= "!"
        if (GetKeyState("Shift", "P"))
            pref .= "+"
    } catch {
    }
    return pref
}

; ---- App filter for Modifier layer ----
ModifierLayerAppAllowed() {
    try {
        ini := A_ScriptDir . "\\config\\modifier_layer.ini"
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
