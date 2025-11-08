; ==============================
; NVIM LAYER - Refactored with Reusable Actions
; ==============================
; Vim-like navigation layer toggled by F23 (CapsLock tap from Kanata)
;
; FEATURES:
; - Toggle ON/OFF con F23 (tap CapsLock)
; - Visual Mode (v) para selección
; - Insert Mode (i/I) temporal
; - Colon Commands (:w, :q, :wq)
; - G Logic (gg para top)
; - Help system (?)
;
; DEPENDENCIES:
; - vim_nav.ahk: Navegación básica reutilizable
; - vim_visual.ahk: Navegación con selección
; - vim_edit.ahk: Operaciones de edición
; - nvim_layer_helpers.ahk: Funciones específicas de este layer
;
; ARCHITECTURE:
; - Usa funciones reut ilizables de actions/ donde sea posible
; - Mantiene lógica específica en helpers
; - Sigue patrón similar al template pero con toggle en lugar de activación manual

; ==============================
; CONFIGURATION
; ==============================

global nvimLayerEnabled := true      ; Feature flag
global nvimStaticEnabled := true     ; Static vs dynamic hotkeys
global isNvimLayerActive := false    ; Layer state
global VisualMode := false           ; Visual mode state
global _tempEditMode := false        ; Insert mode state

; ==============================
; TOGGLE ACTIVATION (F23 from Kanata)
; ==============================

*F23:: {
    global nvimLayerEnabled, isNvimLayerActive, VisualMode, debug_mode
    if (!nvimLayerEnabled)
        return
    
    if (debug_mode)
        OutputDebug "[NVIM] F23 received, toggling layer\n"
    
    ; Toggle layer
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

; ==============================
; DYNAMIC MAPPINGS (Optional)
; ==============================

; Normal mode mappings
try {
    global nvimMappings
    nvimMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Normal", "order")
    if (nvimMappings.Count > 0)
        ApplyGenericMappings("nvim_normal", nvimMappings, (*) => (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; Visual mode mappings
try {
    global nvimVisualMappings
    nvimVisualMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Visual", "order")
    if (nvimVisualMappings.Count > 0)
        ApplyGenericMappings("nvim_visual", nvimVisualMappings, (*) => (isNvimLayerActive && VisualMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; Insert mode mappings
try {
    global nvimInsertMappings
    nvimInsertMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Insert", "order")
    if (nvimInsertMappings.Count > 0)
        ApplyGenericMappings("nvim_insert", nvimInsertMappings, (*) => (_tempEditMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
} catch {
}

; ==============================
; LAYER HOTKEYS - NORMAL MODE
; ==============================

#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)

; === VISUAL MODE TOGGLE ===
v:: {
    global VisualMode
    VisualMode := !VisualMode
    ShowVisualModeStatus(VisualMode)
    SetTimer(() => RemoveToolTip(), -1000)
}

; === LINE NAVIGATION ===
0::VimStartOfLine()       ; Home
+4::VimEndOfLine()        ; End (Shift+4 = $)

; === DOCUMENT NAVIGATION ===
; gg handled by GLogic (see below)
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed() && !GLogicActive) : false)
g::GLogicStart()
+g::NvimGoToDocEdge(false)  ; G = bottom (uses helper for VisualMode support)
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)

; === BASIC NAVIGATION (hjkl) ===
; NOTA: Duplicación intencional con Kanata
; Kanata: Hold CapsLock + hjkl = instant navigation (no persistent)
; AHK: Nvim Layer active + hjkl = persistent with Visual Mode logic
*h::NvimDirectionalSend("Left")    ; Uses helper for VisualMode support
*j::NvimDirectionalSend("Down")
*k::NvimDirectionalSend("Up")
*l::NvimDirectionalSend("Right")

; Alt-modified combos (avoid menu steal)
*!h::NvimDirectionalSend("Left")
*!j::NvimDirectionalSend("Down")
*!k::NvimDirectionalSend("Up")
*!l::NvimDirectionalSend("Right")

; === WORD NAVIGATION ===
w:: {
    global ColonLogicActive
    if (ColonLogicActive) {
        ColonLogicHandleW()
        return
    }
    NvimWordJumpHelper("Right")  ; Uses helper for VisualMode support
}
b::NvimWordJumpHelper("Left")
e::VimEndOfWord()

; === EDIT OPERATIONS ===
d:: {
    global VisualMode
    Send("{Delete}")
    if (VisualMode) {
        VisualMode := false
        ShowVisualModeStatus(false)
        SetTimer(() => RemoveToolTip(), -500)
    }
}

y:: {
    global VisualMode
    VimYank()  ; From vim_edit.ahk
    ShowCopyNotification()
    if (VisualMode) {
        VisualMode := false
        ShowVisualModeStatus(false)
        SetTimer(() => RemoveToolTip(), -500)
    }
}

p::VimPaste()        ; From vim_edit.ahk
+p::VimPastePlain()  ; From vim_edit.ahk
x::Send("^x")        ; Cut
u::VimUndo()         ; From vim_edit.ahk
r::VimRedo()         ; From vim_edit.ahk

; === CHANGE (Visual only) ===
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

; === SELECT ALL (Visual only) ===
a:: {
    global VisualMode
    if (VisualMode) {
        Send("^a")
        ShowVisualModeStatus(true)
    }
}

; === SCROLL ===
^u::Send("{WheelUp 6}")
^d::Send("{WheelDown 6}")

; === INSERT MODE ===
i:: {
    global isNvimLayerActive, _tempEditMode, tooltipConfig
    isNvimLayerActive := false
    _tempEditMode := true
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false)
    } else {
        ShowNvimLayerStatus(false)
    }
    SetTempStatus("INSERT MODE (Esc para volver)", 1500)
}

+i:: {
    global isNvimLayerActive, _tempEditMode, tooltipConfig
    isNvimLayerActive := false
    _tempEditMode := true
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false)
    } else {
        ShowNvimLayerStatus(false)
    }
    SetTempStatus("INSERT MODE (Esc para volver)", 1500)
    Send("^!+i")
}

; === ESCAPE (multi-purpose) ===
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

; === QUICK EXIT (f key) ===
f:: {
    global isNvimLayerActive, tooltipConfig
    isNvimLayerActive := false
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false)
    } else {
        ShowNvimLayerStatus(false)
    }
    Send("^!+2")
}

; === HELP SYSTEM ===
+vkBF:: (VisualMode ? (VisualHelpActive ? VisualCloseHelp() : VisualShowHelp()) : (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp()))
+SC035:: (VisualMode ? (VisualHelpActive ? VisualCloseHelp() : VisualShowHelp()) : (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp()))
?:: (VisualMode ? (VisualHelpActive ? VisualCloseHelp() : VisualShowHelp()) : (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp()))

; === COLON COMMANDS (:w/:q/:wq) ===
*SC027::ColonMaybeStart()
*vkBA::ColonMaybeStart()

^!+i::Send("^!+i")

#HotIf

; ==============================
; COLON LOGIC SUB-MODE (InputLevel 2)
; ==============================

#InputLevel 2
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && ColonLogicActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
*w::ColonLogicHandleW()
*q::ColonLogicHandleQ()
*Enter::ColonLogicEnter()
*Esc::ColonLogicCancel()
#HotIf

; ==============================
; G LOGIC SUB-MODE (gg for top) (InputLevel 2)
; ==============================

#HotIf (nvimStaticEnabled ? (isNvimLayerActive && GLogicActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)
*g::GLogicHandleG()
*Esc::GLogicCancel()
#HotIf
#InputLevel 1

; ==============================
; NOTAS DE REFACTORING
; ==============================
; Cambios principales:
; 1. Funciones de vim_nav.ahk: VimStartOfLine, VimEndOfLine, VimEndOfWord
; 2. Funciones de vim_edit.ahk: VimYank, VimPaste, VimPastePlain, VimUndo, VimRedo
; 3. Funciones de nvim_layer_helpers.ahk: Todo lo específico de nvim
; 4. Eliminadas funciones duplicadas: DeleteCurrentWord, CopyCurrentLine, etc.
; 5. Estructura más limpia y modular
;
; Funciones que permanecen inline (son simples wrappers):
; - ShowNvimLayerStatus, ShowVisualModeStatus
;
; Funciones movidas a helpers (lógica compleja específica):
; - NvimDirectionalSend, NvimWordJumpHelper, NvimGoToDocEdge
; - ReactivateNvimAfterInsert, NvimLayerAppAllowed
; - Todo el sistema ColonLogic, GLogic, Help
