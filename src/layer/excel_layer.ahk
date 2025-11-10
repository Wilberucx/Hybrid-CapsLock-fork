; ==============================
; EXCEL LAYER - Refactored with Reusable Actions
; ==============================
; Excel/Accounting persistent layer with vim-like navigation
;
; FEATURES:
; - Virtual numpad (123/QWE/ASD/Z)
; - Vim navigation (hjkl)
; - Visual Mode (v) for selection
; - Insert Mode (i/I) for editing
; - Excel-specific selection (vr/vc for row/column)
; - Help system (?)
;
; DEPENDENCIES:
; - vim_nav.ahk: Basic navigation functions
; - vim_edit.ahk: Edit operations (yank/paste/undo/redo)
; - visual_layer.ahk: Visual selection mode
; - insert_layer.ahk: Insert/edit mode
;
; ARCHITECTURE:
; - Uses reusable functions from actions/ where possible
; - Maintains Excel-specific logic (VLogic for row/column)
; - Follows pattern similar to nvim_layer.ahk

; ==============================
; CONFIGURATION
; ==============================

global excelLayerEnabled := true      ; Feature flag
global excelStaticEnabled := true     ; Static vs dynamic hotkeys
global excelLayerActive := false      ; Layer state

; ==============================
; ACTIVATION FUNCTION (for easy invocation)
; ==============================

ActivateExcelLayer(originLayer := "leader") {
    global excelLayerActive
    OutputDebug("[EXCEL] ActivateExcelLayer() called with originLayer: " . originLayer)
    
    ; Activate the layer directly
    excelLayerActive := true
    
    ; Show status
    ShowExcelLayerStatus(true)
    try SetTempStatus("EXCEL LAYER ON", 1500)
    
    OutputDebug("[EXCEL] Excel layer activated")
    return true
}

; ==============================
; DYNAMIC MAPPINGS (Optional)
; ==============================

; Try dynamic mappings if available
try {
    global excelMappings
    excelMappings := LoadExcelMappings(A_ScriptDir . "\\config\\excel_layer.ini")
    if (excelMappings.Count > 0)
        ApplyExcelMappings(excelMappings)
} catch {
}

; ==============================
; LAYER HOTKEYS - NORMAL MODE
; ==============================

#InputLevel 1
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VLogicActive) : false)

; === NUMPAD SECTION ===
; Virtual numeric pad: 123 (top), QWE (middle), ASD (bottom), Z as 0
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

; Decimal and operations
.::Send("{NumpadDot}")
8::Send("*")            ; Multiplication
9::Send("(){Left}")     ; Parentheses with cursor inside
`;::Send("{NumpadSub}")
/::Send("{NumpadDiv}")

; === NAVIGATION SECTION ===
; Arrow keys (Vim HJKL) - using reusable vim_nav functions
h::VimMoveLeft()
j::VimMoveDown()
k::VimMoveUp()
l::VimMoveRight()

; Tab navigation
[::Send("+{Tab}")       ; Previous field
]::Send("{Tab}")        ; Next field

; === LINE/DOCUMENT NAVIGATION ===
0::VimStartOfLine()     ; Go to column A (Home)
+4::VimEndOfLine()      ; Go to end of row (End) - Shift+4 = $

g::VimTopOfFile()       ; Go to beginning (Ctrl+Home)
+g::VimBottomOfFile()   ; Go to end (Ctrl+End) - Shift+G

; === EDIT OPERATIONS ===
; Using reusable vim_edit functions
y::VimYank()            ; Copy (Ctrl+C)
p::VimPaste()           ; Paste (Ctrl+V)
u::VimUndo()            ; Undo (Ctrl+Z)
r::VimRedo()            ; Redo (Ctrl+Y)

; === VISUAL MODE (reusable visual_layer) ===
v::SwitchToLayer("visual", "excel")

; === INSERT MODE (reusable insert_layer) ===
i::ExcelEnterEditMode(false)    ; Edit current cell (F2)
+i::ExcelEnterEditMode(true)    ; Edit and exit layer (Shift+I)

; === EXCEL-SPECIFIC FUNCTIONS ===
f::Send("^f")           ; Find
m::Send("^g")           ; Go to specific cell (Ctrl+G)
o::Send("{Enter}")      ; Confirm/move down
+o::Send("+{Enter}")    ; Move up (Shift+Enter)

; === EXCEL SELECTION MINI-LAYER (VLogic: vr/vc) ===
; Note: This is Excel-specific and stays here
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed() && !VLogicActive) : false)
*v::VLogicStart()
#HotIf (excelStaticEnabled ? (excelLayerActive && !GetKeyState("CapsLock", "P") && ExcelLayerAppAllowed()) : false)

; === EXIT EXCEL LAYER ===
+n:: {
    global excelLayerActive
    excelLayerActive := false
    ShowExcelLayerStatus(false)
    SetTempStatus("EXCEL LAYER OFF", 2000)
}

; === HELP SYSTEM ===
+vkBF:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())
+SC035:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())
?:: (ExcelHelpActive ? ExcelCloseHelp() : ExcelShowHelp())

#HotIf

; ==============================
; VLOGIC SUB-MODE (vr/vc for row/column selection) (InputLevel 2)
; ==============================

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
        ToolTip("ROW SELECTED")
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

*v::SwitchToLayer("visual", "excel")  ; vv now switches to visual layer

*Esc::VLogicCancel()
#HotIf
#InputLevel 1

; ==============================
; EXCEL-SPECIFIC HELPER FUNCTIONS
; ==============================

ExcelEnterEditMode(exitLayer := false) {
    global excelLayerActive
    Send("{F2}")  ; F2 = Edit cell in Excel
    if (exitLayer) {
        excelLayerActive := false
        ShowExcelLayerStatus(false)
    }
}

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

; ==============================
; VLOGIC FUNCTIONS
; ==============================

global VLogicActive := false

VLogicStart() {
    global VLogicActive
    VLogicActive := true
    to := 3000 ; 3 seconds timeout
    SetTimer(VLogicTimeout, -to)
}

VLogicTimeout() {
    VLogicCancel()
}

VLogicCancel() {
    global VLogicActive
    VLogicActive := false
}

; ==============================
; HELP SYSTEM
; ==============================

global ExcelHelpActive := false

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

; ==============================
; LAYER INTEGRATION HOOKS
; ==============================
; Note: Excel layer reactivation is handled automatically by auto_loader.ahk
; The ReactivateOriginLayer() function in auto_loader handles the "excel" case

; ==============================
; NOTAS DE REFACTORING
; ==============================
; Cambios principales realizados:
; 1. Navegación hjkl → VimMoveLeft/Down/Up/Right() de vim_nav.ahk
; 2. Navegación 0/$/g/G → VimStartOfLine/EndOfLine/TopOfFile/BottomOfFile() de vim_nav.ahk
; 3. Edición y/p/u/r → VimYank/Paste/Undo/Redo() de vim_edit.ahk
; 4. VV Mode ELIMINADO → reemplazado con SwitchToLayer("visual", "excel")
; 5. VLogic vv → ahora también usa visual_layer en lugar de VVModeActive
; 6. Estructura similar a nvim_layer.ahk con layer switching
; 7. Modo Insert agregado con i/I (F2 para editar celda)
;
; Funciones Excel-específicas que permanecen:
; - Numpad virtual (123/QWE/ASD/Z)
; - VLogic para vr (row) y vc (column) - exclusivo de Excel
; - ExcelEnterEditMode() - F2 específico de Excel
; - ExcelAppAllowedGuard() - filtrado de aplicaciones
;
; Funciones eliminadas (ahora en actions/ o visual_layer):
; - ExcelVVDirectionalSend() → reemplazado por visual_layer.ahk
; - Todo el manejo de VVModeActive
; - Duplicación de Send("{Left/Down/Up/Right}") → ahora usa vim_nav.ahk
; - Duplicación de Copy/Paste/Undo/Redo → ahora usa vim_edit.ahk
;
; Ventajas:
; - Código más limpio y mantenible
; - Reutilización de funciones probadas
; - Compatibilidad con visual_layer para selección
; - Estructura consistente con otros layers
; - Menos duplicación de código
