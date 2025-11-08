; ==============================
; Nvim Layer (toggle on F23 from Kanata)
; ==============================
; Provides a lightweight Vim-like navigation layer toggled by F23 key.
; - Toggle: F23 sent by Kanata when CapsLock is tapped
; - Context: Active when isNvimLayerActive is true
; - Visual Mode: simple ON/OFF indicator
; Depends on: core/globals (isNvimLayerActive, VisualMode),
;             core/persistence (SaveLayerState), ui/tooltips_native_wrapper (status)

; ---- Toggle via F23 (sent by Kanata on CapsLock tap) ----
*F23:: {
    global nvimLayerEnabled, isNvimLayerActive, VisualMode, debug_mode
    if (!nvimLayerEnabled)
        return
    
    if (debug_mode)
        OutputDebug "[NVIM] F23 received, toggling layer\n"
    
    ; Toggle
    isNvimLayerActive := !isNvimLayerActive
    if (isNvimLayerActive) {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimLayerToggleCS(true)
        } else {
            ShowNvimLayerStatus(true)
            SetTempStatus("NVIM LAYER ON", 1500)
        }
    } else {
        VisualMode := false
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimLayerToggleCS(false)
        } else {
            ShowNvimLayerStatus(false)
            SetTempStatus("NVIM LAYER OFF", 1500)
        }
    }
    try SaveLayerState()
}



; Try dynamic mappings if available (Normal mode)
try {
    global nvimMappings
    nvimMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Normal", "order")
    if (nvimMappings.Count > 0)
        ApplyGenericMappings("nvim_normal", nvimMappings, (*) => (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; Try dynamic mappings for Visual mode
try {
    global nvimVisualMappings
    nvimVisualMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Visual", "order")
    if (nvimVisualMappings.Count > 0)
        ApplyGenericMappings("nvim_visual", nvimVisualMappings, (*) => (isNvimLayerActive && VisualMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; Try dynamic mappings for Insert mode
try {
    global nvimInsertMappings
    nvimInsertMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Insert", "order")
    if (nvimInsertMappings.Count > 0)
        ApplyGenericMappings("nvim_insert", nvimInsertMappings, (*) => (_tempEditMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

global ColonLogicActive := false
global ColonStage := ""

; Estado para mini-capa de 'g'
global GLogicActive := false


; ---- Context hotkeys ----
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)

; Visual Mode toggle
v:: {
    global VisualMode
    VisualMode := !VisualMode
    ShowVisualModeStatus(VisualMode)
    SetTimer(() => RemoveToolTip(), -1000)
}

; Line navigation (0: start, $: end)
0::Send("{Home}")
+4::Send("{End}")

; Ir a inicio/fin de documento (gg / G)
; gg -> Top (Ctrl+Home), G (Shift+g) -> Bottom (Ctrl+End)
; En VisualMode, añadir Shift para extender selección

#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock","P") && NvimLayerAppAllowed() && !GLogicActive) : false)
g::GLogicStart()
+g::NvimGoToDocEdge(false)
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock","P") && NvimLayerAppAllowed()) : false)

; Basic navigation (hjkl) - DUPLICACIÓN INTENCIONAL con Kanata
; Kanata maneja: Hold CapsLock + hjkl = navegación instantánea (no persistente)
; AHK maneja: Nvim Layer activa (tap CapsLock) + hjkl = navegación persistente con lógica avanzada
; 
; Los wildcards (*h, *j, *k, *l) permiten combinar con modificadores:
; - Shift+j → Shift+Down (seleccionar hacia abajo en Visual Mode)
; - Ctrl+l → Ctrl+Right (navegar por palabras)
; - Alt+h → Alt+Left (retroceder en navegador)
; Kanata hace esto a nivel hardware, pero cuando Nvim Layer está activo, AHK toma control
; para integrar con Visual Mode y otras funcionalidades context-aware
*h::NvimDirectionalSend("Left")
*j::NvimDirectionalSend("Down")
*k::NvimDirectionalSend("Up")
*l::NvimDirectionalSend("Right")
; Ensure Alt-modified combos also fire (avoid menu-steal)
*!h::NvimDirectionalSend("Left")
*!j::NvimDirectionalSend("Down")
*!k::NvimDirectionalSend("Up")
*!l::NvimDirectionalSend("Right")

; Delete simple (d) — borra la selección si está en Visual y sale de Visual; en Normal envía Delete
d:: {
    global VisualMode
    Send("{Delete}")
    if (VisualMode) {
        VisualMode := false
        ShowVisualModeStatus(false)
        SetTimer(() => RemoveToolTip(), -500)
    }
}

; Yank simple (y) — copia con Ctrl+C; si estaba en Visual, sale de Visual
; Nota: al hacer acciones Visual, mostramos un tooltip nativo del modo Visual
;y:: {
y:: { 
    global VisualMode
    Send("^c")
    ShowCopyNotification()
    if (VisualMode) {
        VisualMode := false
        ShowVisualModeStatus(false)
        SetTimer(() => RemoveToolTip(), -500)
    }
}

; Paste
p::Send("^v")
+p::PastePlain()

; Cut (x)
x::Send("^x")

; Undo (u) / Redo (r arriba)
u::Send("^z")

; Scroll Ctrl+U / Ctrl+D
^u::Send("{WheelUp 6}")
^d::Send("{WheelDown 6}")

; Exit Insert mode (if mapped dynamically)
Esc:: {
    global _tempEditMode, VisualMode, ColonLogicActive
    if (ColonLogicActive) {
        ColonLogicCancel()
        return
    }
    if (_tempEditMode) {
        ReactivateNvimAfterInsert()
        return
    }
    if (VisualMode) {
        VisualMode := false
        ShowVisualModeStatus(false)
        SetTimer(() => RemoveToolTip(), -500)
        return
    }
    Send("{Escape}")
}

; End of word (e)
e::Send("^{Right}{Left}")

; Smooth scrolling
; Removed Shift+e and Shift+y smooth scroll bindings per user request
; +e::Send("{WheelDown 3}")
; +y::Send("{WheelUp 3}")

; Insert mode (temporary disable layer) - manual return with Esc
; i: solo desactiva NVIM layer (no envía combinación)
; Shift+i: desactiva NVIM layer y envía Ctrl+Alt+Shift+I (hereda el comportamiento anterior)
i:: {
    global isNvimLayerActive, _tempEditMode, tooltipConfig
    isNvimLayerActive := false
    _tempEditMode := true
    ; Ocultar/eliminar tooltip persistente según el backend activo
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false) ; oculta el tooltip C# si estaba mostrado
    } else {
        ShowNvimLayerStatus(false) ; tooltip nativo breve
    }
    SetTempStatus("INSERT MODE (Esc para volver)", 1500)
    ; Sin envío de combinación aquí
    ; Retorno manual con Esc
}

+i:: {
    global isNvimLayerActive, _tempEditMode, tooltipConfig
    isNvimLayerActive := false
    _tempEditMode := true
    ; Ocultar/eliminar tooltip persistente según el backend activo
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false)
    } else {
        ShowNvimLayerStatus(false)
    }
    SetTempStatus("INSERT MODE (Esc para volver)", 1500)
    Send("^!+i")
    ; Retorno manual con Esc
}

; Redo (r)
r::Send("^y")

; Help: NVIM or VISUAL (toggle with '?')
+vkBF:: (VisualMode ? (VisualHelpActive ? VisualCloseHelp() : VisualShowHelp()) : (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp()))
+SC035:: (VisualMode ? (VisualHelpActive ? VisualCloseHelp() : VisualShowHelp()) : (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp()))
?:: (VisualMode ? (VisualHelpActive ? VisualCloseHelp() : VisualShowHelp()) : (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp()))

; (moved function definition to global scope below)

global NvimHelpActive := false
global VisualHelpActive := false

VisualShowHelp() {
    global tooltipConfig, VisualHelpActive
    ; Hide persistent Visual status to avoid overlap
    try HideCSharpTooltip()
    Sleep 30
    VisualHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(VisualHelpAutoClose, -to)
    try ShowVisualHelpCS()
}

VisualHelpAutoClose() {
    global VisualHelpActive
    if (VisualHelpActive)
        VisualCloseHelp()
}

VisualCloseHelp() {
    global isNvimLayerActive, VisualMode, tooltipConfig, VisualHelpActive
    try SetTimer(VisualHelpAutoClose, 0)
    try HideCSharpTooltip()
    VisualHelpActive := false
    if (VisualMode) {
        ; Restore persistent Visual status
        try ShowVisualLayerToggleCS(true)
    } else if (isNvimLayerActive) {
        ; Fall back to NVIM persistent if visual off but layer active
        try ShowNvimLayerToggleCS(true)
    } else {
        try RemoveToolTip()
    }
}


NvimShowHelp() {
    global isNvimLayerActive, tooltipConfig, NvimHelpActive
    ; If C# is enabled, hide current persistent NVIM ON tooltip first to avoid overlap
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try HideCSharpTooltip()
        Sleep 30
    }
    NvimHelpActive := true
    ; Auto-close timer using configured optionsTimeout (fallback 5000)
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 5000
    try SetTimer(NvimHelpAutoClose, -to)
    ; Show help (C# or native)
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ShowNvimHelpCS()
        } else {
            ShowCenteredToolTip("NVIM HELP: hjkl move | gg/G top/bottom | v visual | y copy | p paste | u undo | x cut | i insert (no combo) | I insert+^!+i | f find")
        }
    } catch {
        ShowCenteredToolTip("NVIM HELP: hjkl move | gg/G top/bottom | v visual | y copy | p paste | u undo | x cut | i insert (no combo) | I insert+^!+i | f find")
    }
}

NvimHelpAutoClose() {
    global NvimHelpActive
    if (NvimHelpActive)
        NvimCloseHelp()
}

NvimCloseHelp() {
    ; if Visual opened its help, ignore closing here
    if (VisualHelpActive)
        return
    global isNvimLayerActive, tooltipConfig, NvimHelpActive
    ; Cancel any pending auto-close timer
    try SetTimer(NvimHelpAutoClose, 0)
    ; Hide help tooltip (C#) if present
    try HideCSharpTooltip()
    NvimHelpActive := false
    if (isNvimLayerActive) {
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled)
                ShowNvimLayerToggleCS(true)
            else
                ShowNvimLayerStatus(true)
        } catch {
            ShowNvimLayerStatus(true)
        }
    } else {
        ; Ensure native tooltip is removed if we used it
        try RemoveToolTip()
    }
}

; Quick exit
; Send Ctrl+Alt+Shift+2 with f and then deactivate NVIM layer
f:: {
    global isNvimLayerActive, tooltipConfig
    isNvimLayerActive := false
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false)
    } else {
        ShowNvimLayerStatus(false)
    }
    ; Enviar la combinación después de desactivar la capa
    Send("^!+2")
}

^!+i::Send("^!+i")

#HotIf

; Ctrl/Alt/Shift + hjkl sent to arrows with modifiers, honoring VisualMode
; - Shift => selección (mantiene Shift)
; - Ctrl  => navega por palabras/elementos (Ctrl+Arrow)
; - Alt   => deja Alt+Arrow (útil en IDEs/editores con comportamiento propio)
; Combinaciones (ej. Ctrl+Shift+h) se respetan
NvimDirectionalSend(dir) {
    global VisualMode
   mods := ""
   if GetKeyState("Ctrl", "P")
       mods .= "^"
   if GetKeyState("Alt", "P")
       mods .= "!"
   if GetKeyState("Shift", "P")
       mods .= "+"
   ; En VisualMode, asegurar que Shift esté presente para extender selección
   if (VisualMode && !InStr(mods, "+"))
       mods .= "+"
   Send(mods . "{" . dir . "}")
}

; ---- App filter for Nvim layer ----

#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)

NvimLayerAppAllowed() {
   try {
       ini := A_ScriptDir . "\\config\\nvim_layer.ini"
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

#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
; Word jumps like NVIM (w/b)
w:: {
    global ColonLogicActive
    if (ColonLogicActive) {
        ColonLogicHandleW()
        return
    }
    NvimWordJumpHelper("Right")
}
b::NvimWordJumpHelper("Left")

; Save

; Change (visual only): delete selection and enter insert (disable NVIM layer)
c:: {
    global VisualMode, isNvimLayerActive, _tempEditMode
    if (VisualMode) {
        Send("{Delete}")
        VisualMode := false
        ShowVisualModeStatus(false)
        isNvimLayerActive := false
        _tempEditMode := true
        ShowNvimLayerStatus(false)
        SetTempStatus("INSERT MODE (Esc para volver)", 1500)
    }
}

; Select All (visual only)
a:: {
    global VisualMode
    if (VisualMode) {
        Send("^a")
        ShowVisualModeStatus(true)
    }
}

; ---- Colon command logic-only mode (triggered by Shift+; or :) ----
; Entry: Shift+; (:) opens a temporary logical mode that waits for w or q, then Enter.
; Stages:
;   ""  -> awaiting w or q
;   "w" -> awaiting q or Enter
;   "q" -> awaiting Enter
;   "wq"-> awaiting Enter
; Tooltip: fixed text to emulate :w/:q/:wq waiting (does not change with stage).

#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
*SC027::ColonMaybeStart()   ; Semicolon/OEM_1 scancode, decide by Shift state
*vkBA::ColonMaybeStart()    ; OEM_1 by virtual key, decide by Shift state
#HotIf

#InputLevel 2
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && ColonLogicActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
*w::ColonLogicHandleW()
*q::ColonLogicHandleQ()
*Enter::ColonLogicEnter()
*Esc::ColonLogicCancel()
#HotIf

; --- Mini capa para 'g' (gg) ---
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && GLogicActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
*g::GLogicHandleG()
*Esc::GLogicCancel()
#HotIf
#InputLevel 1
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
#HotIf

ColonMaybeStart() {
    ; Only start colon logic when Shift is physically held (i.e., we intend ':')
    if GetKeyState("Shift", "P") {
        ColonLogicStart()
        ; Block the ':' character from being sent
        return
    }
    ; Otherwise it's a bare semicolon ';' — pass it through
    Send(";")
}

ColonLogicStart() {
    global ColonLogicActive, ColonStage
    ColonLogicActive := true
    ColonStage := ""
    ColonLogicShowTip()
}

ColonLogicCancel() {
    global ColonLogicActive, ColonStage
    ColonLogicActive := false
    ColonStage := ""
    try HideCSharpTooltip()
    try ShowCenteredToolTipCS("Cmd: cancelled", 800)
    SetTimer(() => RemoveToolTip(), -600)
}

ColonLogicShowTip() {
    ; Mostrar tooltip tipo lista en esquina inferior derecha usando C#
    ; Persistente (timeout 0) hasta Enter o Esc
    items := "w:Save|q:Quit|wq:Save + Quit"
    ShowBottomRightListTooltip("CMD", items, "Enter: Execute|Esc: Cancel", 0)
}

ColonLogicHandleW() {
    global ColonStage
    if (ColonStage = "") {
        ColonStage := "w"
    } else if (ColonStage = "w") {
        ColonStage := "wq"
    } else if (ColonStage = "q") {
        ColonStage := "q" ; stays waiting only Enter
    }
    ColonLogicShowTip()
}

ColonLogicHandleQ() {
    global ColonStage
    if (ColonStage = "") {
        ColonStage := "q"
    } else if (ColonStage = "w") {
        ColonStage := "wq"
    } else if (ColonStage = "q") {
        ColonStage := "q"
    }
    ColonLogicShowTip()
}

ColonLogicEnter() {
    global ColonStage
    if (ColonStage = "w") {
        Send("^s")
    } else if (ColonStage = "q") {
        Send("!{F4}")
    } else if (ColonStage = "wq") {
        Send("^s")
        Sleep(80)
        Send("!{F4}")
    }
    ColonLogicCancel()
}

; Jump by word like NVIM (used by w/b)
NvimWordJumpHelper(dir) {
   global VisualMode
   mods := "^" ; Ctrl for word movement
   if (VisualMode)
       mods .= "+" ; add Shift to extend selection in Visual
   arrow := (dir = "Right") ? "Right" : "Left"
   Send(mods . "{" . arrow . "}")
}

; Go to document edge (top/bottom) with gg/G
NvimGoToDocEdge(goTop := true) {
    global VisualMode
    mods := "^" ; Ctrl for document edge
    if (VisualMode)
        mods .= "+" ; Shift to extend selection
    Send(mods . "{" . (goTop ? "Home" : "End") . "}")
}


DeleteCurrentWord() {
    Send("^{Right}^+{Left}{Delete}")
    ShowCenteredToolTip("WORD DELETED")
    SetTimer(() => RemoveToolTip(), -800)
}
DeleteCurrentLine() {
    Send("{Home}+{End}{Delete}")
    ShowCenteredToolTip("LINE DELETED")
    SetTimer(() => RemoveToolTip(), -800)
}
DeleteAll() {
    Send("^a{Delete}")
    ShowCenteredToolTip("ALL DELETED")
    SetTimer(() => RemoveToolTip(), -800)
}
CopyCurrentLine() {
    Send("{Home}+{End}^c")
    ShowCenteredToolTip("LINE COPIED")
    SetTimer(() => RemoveToolTip(), -800)
}
CopyCurrentWord() {
    Send("^{Right}^+{Left}^c")
    ShowCopyNotification()
}
CopyCurrentParagraph() {
    Send("^{Up}^+{Down}^c")
    ShowCenteredToolTip("PARAGRAPH COPIED")
    SetTimer(() => RemoveToolTip(), -800)
}
PastePlain() {
    Send("^+v")
}
ReactivateNvimAfterInsert() {
    global isNvimLayerActive, _tempEditMode
    if (_tempEditMode) {
        isNvimLayerActive := true
        _tempEditMode := false
        ShowNvimLayerStatus(true)
        SetTimer(() => RemoveToolTip(), -1000)
    }
}

NvimHandleDeleteMenu() {
    global VisualMode
    if (VisualMode) {
        Send("{Delete}")
        return
    }
    ShowDeleteMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("nvim"), "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        try HideCSharpTooltip()
        return
    }
    key := ih.Input
    try HideCSharpTooltip()
    switch key {
        case "w": DeleteCurrentWord()
        case "d": DeleteCurrentLine()
        case "a": DeleteAll()
    }
}

NvimHandleYankMenu() {
    global VisualMode
    if (VisualMode) {
        Send("^c")
        ShowCopyNotification()
        return
    }
    ShowYankMenu()
    ih := InputHook("L1 T" . GetEffectiveTimeout("nvim"), "{Escape}")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
        try HideCSharpTooltip()
        return
    }
    key := ih.Input
    try HideCSharpTooltip()
    switch key {
        case "y": CopyCurrentLine()
        case "w": CopyCurrentWord()
        case "a": Send("^a^c"), ShowCopyNotification()
        case "p": CopyCurrentParagraph()
    }
}

; --- Lógica mini-capa 'g' (gg) ---
GLogicStart() {
    global GLogicActive
    GLogicActive := true
    to := GetEffectiveTimeout("nvim")
    ; GetEffectiveTimeout returns seconds; SetTimer expects ms when negative
    try SetTimer(GLogicTimeout, -to*1000)
}

GLogicHandleG() {
    GLogicCancel()
    NvimGoToDocEdge(true) ; top
}

GLogicCancel() {
    global GLogicActive
    GLogicActive := false
}

GLogicTimeout() {
    GLogicCancel()
}
