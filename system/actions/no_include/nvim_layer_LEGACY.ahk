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
; global _tempEditMode removed - now uses insert_layer.ahk

; ==============================
; TOGGLE ACTIVATION (F23 from Kanata)
; ==============================

*F23:: {
    global nvimLayerEnabled, isNvimLayerActive, debug_mode
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

; Visual mode mappings - DISABLED: Now handled by visual_layer.ahk
; try {
;     global nvimVisualMappings
;     nvimVisualMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\nvim_layer.ini", "Visual", "order")
;     if (nvimVisualMappings.Count > 0)
;         ApplyGenericMappings("nvim_visual", nvimVisualMappings, (*) => (isNvimLayerActive && VisualMode && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()))
; } catch {
; }

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
v::SwitchToLayer("visual", "nvim")

; === LINE NAVIGATION ===
0::VimStartOfLine()       ; Home
+4::VimEndOfLine()        ; End (Shift+4 = $)

; === DOCUMENT NAVIGATION ===
; gg handled by GLogic (see below)
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed() && !GLogicActive) : false)
g::GLogicStart()
+g::NvimGoToDocEdge(false)  ; G = bottom
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock", "P") && NvimLayerAppAllowed()) : false)

; === BASIC NAVIGATION (hjkl) ===
; NOTE: Intentional duplication with Kanata
; Kanata: Hold CapsLock + hjkl = instant navigation (no persistent)
; AHK: Nvim Layer active + hjkl = persistent with Visual Mode logic
*h::NvimDirectionalSend("Left")
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
    NvimWordJumpHelper("Right")
}
b::NvimWordJumpHelper("Left")
e::VimEndOfWord()

; === EDIT OPERATIONS ===
d::Send("{Delete}")

y:: {
    VimYank()  ; From vim_edit.ahk
    ShowCopyNotification()
}

p::VimPaste()        ; From vim_edit.ahk
+p::VimPastePlain()  ; From vim_edit.ahk
x::Send("^x")        ; Cut
u::VimUndo()         ; From vim_edit.ahk
r::VimRedo()         ; From vim_edit.ahk

; === CHANGE - REMOVED: Now handled by visual_layer.ahk ===
; === SELECT ALL - REMOVED: Now handled by visual_layer.ahk ===

; === SCROLL ===
^u::Send("{WheelUp 6}")
^d::Send("{WheelDown 6}")

; === INSERT MODE ===
i::SwitchToLayer("insert", "nvim")

+i:: {
    SwitchToLayer("insert", "nvim")
    Send("^!+i")  ; Insert at beginning of line behavior
}

; === ESCAPE (multi-purpose) ===
Esc:: {
    global ColonLogicActive
    if (ColonLogicActive) {
        ColonLogicCancel()
        return
    }
    Send("{Escape}")
}

; === QUICK EXIT (f key) ===
f:: {
    global tooltipConfig
    ; Note: Layer deactivation should be handled by the layer system
    ; However, this is legacy code with different behavior
    global isNvimLayerActive
    isNvimLayerActive := false
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        try ShowNvimLayerToggleCS(false)
    } else {
        ShowNvimLayerStatus(false)
    }
    Send("^!+2")
}

; === HELP SYSTEM ===
+vkBF:: (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp())
+SC035:: (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp())
?:: (NvimHelpActive ? NvimCloseHelp() : NvimShowHelp())

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
; 5. VISUAL MODE EXTRAÍDO: Ahora en src/layer/visual_layer.ahk independiente
; 6. Layer switching: v::SwitchToLayer("visual", "nvim") - composabilidad real
; 7. Estructura más limpia y modular
;
; Funciones que permanecen inline (son simples wrappers):
; - ShowNvimLayerStatus
;
; Funciones movidas a helpers (lógica compleja específica):
; - NvimDirectionalSend, NvimWordJumpHelper, NvimGoToDocEdge
; - ReactivateNvimAfterInsert, NvimLayerAppAllowed
; - Todo el sistema ColonLogic, GLogic, Help
;
; ELIMINADO COMPLETAMENTE DE ESTE LAYER:
; - VisualMode global variable
; - Visual mode hotkeys (d/y/c/a con visual logic)
; - ShowVisualModeStatus calls
; - Visual help system
; - ESC visual mode handling
; - Todo el manejo de selección visual
