; ==============================
; Excel/Accounting Layer (persistent)
; ==============================
; Hotkeys active only when excelLayerActive is true and CapsLock is not physically pressed.
; Depends on: core/globals (excelLayerActive flag), ui wrapper (ShowExcelLayerStatus, SetTempStatus).

; Try dynamic mappings if available
try {
    global excelMappings
    excelMappings := LoadExcelMappings(A_ScriptDir . "\\config\\excel_layer.ini")
    if (excelMappings.Count > 0)
        ApplyExcelMappings(excelMappings)
} catch {
}

#InputLevel 1
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VVModeActive && !VLogicActive) : false)

; === NUMPAD SECTION ===
; New numeric pad: 123 (top), QWE (middle), ASD (bottom), X as 0
1::Send("{Numpad1}")
2::Send("{Numpad2}")
3::Send("{Numpad3}")

q::Send("{Numpad4}")
w::Send("{Numpad5}")
e::Send("{Numpad6}")

a::Send("{Numpad7}")
s::Send("{Numpad8}")
d::Send("{Numpad9}")
+d::Send("{Delete}")    ; Shift+d: Delete key

; Zero
z::Send("{Numpad0}")

; Decimal and comma
; , (comma) - not mapped, sends comma naturally
.::Send("{NumpadDot}")

; Operations
8::Send("*")  ; Multiplication (asterisk)
9::Send("(){Left}")  ; Parentheses with cursor inside for functions
`;::Send("{NumpadSub}")
/::Send("{NumpadDiv}")

; === NAVIGATION SECTION ===
; Arrow keys (Vim HJKL) - disabled when VVModeActive
h::Send("{Left}")
j::Send("{Down}")
k::Send("{Up}")
l::Send("{Right}")

; Tab navigation
[::Send("+{Tab}")
]::Send("{Tab}")

; === EXCEL FUNCTIONS ===
i::Send("{F2}")         ; Edit cell
+i:: {                  ; Shift+I: Edit cell and exit Excel layer
    global excelLayerActive
    Send("{F2}")
    excelLayerActive := false
    ShowExcelLayerStatus(false)
}
f::Send("^f")           ; Find
u::Send("^z")           ; Undo
r::Send("^y")           ; Redo
g::Send("^{Home}")      ; Go to beginning
; Capital G handled in main context
+g::Send("^{End}")      ; Go to end (Shift+g = G)
m::Send("^g")           ; Go to specific cell
y::Send("^c")           ; Yank (copy) - disabled when VVModeActive
p::Send("^v")           ; Paste - disabled when VVModeActive
o::Send("{Enter}")      ; Enter (confirm/move down)
+o::Send("+{Enter}")    ; Shift+Enter (move up)
; c removed - duplicates y (yank)
; Note: y, p are also defined in VV mode with different behavior

; === EXIT EXCEL LAYER ===
+n:: {
    global excelLayerActive
    excelLayerActive := false
    ShowExcelLayerStatus(false)
    SetTempStatus("EXCEL LAYER OFF", 2000)
}

; === SELECTION FUNCTIONS (MINICAPAS) ===
; v prefix for selection functions (like GLogic in nvim)
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VLogicActive && !VVModeActive) : false)
v::VLogicStart()
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VVModeActive) : false)

; === HELP (toggle with ?) ===
+vkBF:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())
+SC035:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())
?:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())

#HotIf

; === MINICAPA V LOGIC (vr, vc, vv) ===
#InputLevel 2
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && VLogicActive) : false)
*r:: {
    VLogicCancel()
    ; Select entire row with Shift+Space
    OutputDebug("VR: Sending Shift+Space")
    Send("+{Space}")
    OutputDebug("VR: Sent Shift+Space")
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try {
            ShowCSharpStatusNotification("EXCEL", "ROW SELECTED")
            SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
        }
    } else {
        ToolTip("ROW SELECTED - DEBUG")
        SetTimer(() => ToolTip(), -2000)
    }
}

*c:: {
    VLogicCancel()
    Send("^{Space}") ; Ctrl+Space = select entire column
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try {
            ShowCSharpStatusNotification("EXCEL", "COLUMN SELECTED")
            SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
        }
    } else {
        ToolTip("COLUMN SELECTED")
        SetTimer(() => ToolTip(), -1000)
    }
}

*v:: {
    global VVModeActive
    VLogicCancel()
    VVModeActive := true
    ; Show modern C# tooltip for VV mode
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowExcelVVModeToggleCS(true)
    } else {
        ToolTip("VISUAL SELECTION MODE (hjkl to select, Esc/Enter to exit)")
    }
    ; No timeout for VV mode - tooltip stays until action
}

*Esc::VLogicCancel()
#HotIf
#InputLevel 1

; === VV MODE (visual selection with arrows) ===
#InputLevel 2
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && VVModeActive) : false)

h::ExcelVVDirectionalSend("Left")
j::ExcelVVDirectionalSend("Down")
k::ExcelVVDirectionalSend("Up")
l::ExcelVVDirectionalSend("Right")

; Exit VV mode
*Esc:: {
    global VVModeActive
    VVModeActive := false
    ; Restore Excel layer tooltip
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowExcelVVModeToggleCS(false)
    } else {
        ToolTip("VISUAL SELECTION OFF")
        SetTimer(() => ToolTip(), -1000)
    }
}

*Enter:: {
    global VVModeActive
    VVModeActive := false
    ; Restore Excel layer tooltip
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowExcelVVModeToggleCS(false)
    } else {
        ToolTip("VISUAL SELECTION OFF")
        SetTimer(() => ToolTip(), -1000)
    }
}

; Opciones adicionales en VV mode
*y:: {
    global VVModeActive
    Send("^c")  ; Copy selection
    VVModeActive := false
    ; Show copy notification and restore Excel layer
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try {
            ShowCopyNotificationCS()
            SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
        }
    } else {
        ToolTip("COPIED - VV MODE OFF")
        SetTimer(() => ToolTip(), -1000)
    }
}

*d:: {
    global VVModeActive
    Send("{Delete}")  ; Delete selection
    VVModeActive := false
    ; Show delete notification and restore Excel layer
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try {
            ShowCSharpStatusNotification("EXCEL VV", "DELETED")
            SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
        }
    } else {
        ToolTip("DELETED - VV MODE OFF")
        SetTimer(() => ToolTip(), -1000)
    }
}

*p:: {
    global VVModeActive
    Send("^v")  ; Paste over selection
    VVModeActive := false
    ; Show paste notification and restore Excel layer
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try {
            ShowCSharpStatusNotification("EXCEL VV", "PASTED")
            SetTimer(() => ShowExcelLayerToggleCS(true), -1200)
        }
    } else {
        ToolTip("PASTED - VV MODE OFF")
        SetTimer(() => ToolTip(), -1000)
    }
}

; Help in VV mode
+/:: {
    ; Shift+/ = ? (question mark)
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowExcelVVHelpCS()
    } else {
        ToolTip("VV HELP:`nh:Select left | j:Select down | k:Select up | l:Select right`ny:Copy & exit | d:Delete & exit | p:Paste & exit | Esc:Exit")
        SetTimer(() => ToolTip(), -5000)
    }
}

#HotIf
#InputLevel 1

; === Status helper ===
ExcelLayerAppAllowed() {
    return ExcelAppAllowedGuard()
}

ExcelAppAllowedGuard() {
    ; Whitelist/Blacklist by process name from excel_layer.ini
    try {
        ini := A_ScriptDir . "\\config\\excel_layer.ini"
        wl := IniRead(ini, "Settings", "whitelist", "")
        bl := IniRead(ini, "Settings", "blacklist", "")
        proc := WinGetProcessName("A")
        if (bl != "" && InStr("," . StrLower(bl) . ",", "," . StrLower(proc) . ","))
            return false
        if (wl = "" )
            return true
        return InStr("," . StrLower(wl) . ",", "," . StrLower(proc) . ",")
    } catch {
        return true
    }
}

global ExcelHelpActive := false
global VLogicActive := false
global VVModeActive := false

ExcelShowHelp() {
    global tooltipConfig, ExcelHelpActive
    try HideCSharpTooltip()
    Sleep 30
    ExcelHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(ExcelHelpAutoClose, -to)
    try ShowExcelHelpCS()
}

ExcelHelpAutoClose() {
    global ExcelHelpActive
    if (ExcelHelpActive)
        ExcelCloseHelp()
}

ExcelCloseHelp() {
    global excelLayerActive, ExcelHelpActive
    try SetTimer(ExcelHelpAutoClose, 0)
    try HideCSharpTooltip()
    ExcelHelpActive := false
    if (excelLayerActive) {
        try ShowExcelLayerStatus(true)
    } else {
        try RemoveToolTip()
    }
}

ShowExcelLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowExcelLayerToggleCS(isActive)
    } else {
        ToolTip(isActive ? "EXCEL LAYER ON" : "EXCEL LAYER OFF")
        SetTimer(() => ToolTip(), -1200)
    }
}

; === V LOGIC FUNCTIONS ===
VLogicStart() {
    global VLogicActive
    VLogicActive := true
    to := 3000 ; 3 segundos timeout
    SetTimer(VLogicTimeout, -to)
}

VLogicTimeout() {
    VLogicCancel()
}

VLogicCancel() {
    global VLogicActive
    VLogicActive := false
}

; === VV MODE HELPER FUNCTION ===
; Similar to NvimDirectionalSend but for Excel VV mode
; Always adds Shift to extend selection, and respects other modifiers
ExcelVVDirectionalSend(dir) {
    global VVModeActive
    mods := ""
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("Shift", "P")
        mods .= "+"
    ; En VVModeActive, siempre asegurar que Shift esté presente para extender selección
    if (VVModeActive && !InStr(mods, "+"))
        mods .= "+"
    
    ; Use SendInput for more reliable delivery in Excel
    SendInput(mods . "{" . dir . "}")
}
