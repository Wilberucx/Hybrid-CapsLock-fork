; ==============================
; Leader Router - Sistema Jerárquico Universal
; ==============================
; Router genérico para navegación jerárquica en Leader Menu.
; Hotkey: F24 (sent by Kanata when CapsLock hold + Space)
;
; ARQUITECTURA:
; - Usa ExecuteKeymapAtPath() del keymap_registry
; - Navegación multinivel con breadcrumb (back funcionando)
; - Compatible con categorías registradas en command_system_init.ahk
;
; Depends on: 
;   - core/keymap_registry (ExecuteKeymapAtPath, GetSortedKeymapsForPath)
;   - core/config (GetEffectiveTimeout)
;   - ui/tooltips

#SuspendExempt
#HotIf (leaderLayerEnabled)
F24:: {
    ; F24 sent by Kanata when CapsLock is held and Space is pressed
    TryActivateLeader()
}
#HotIf

#SuspendExempt False

; ==============================
; NAVEGACIÓN JERÁRQUICA UNIVERSAL
; ==============================

TryActivateLeader() {
    global leaderActive, isNvimLayerActive, hybridPauseActive
    
    ; Resume script if suspended
    if (A_IsSuspended) {
        try SetTimer(HybridAutoResumeTimer, 0)
        Suspend(0)
        hybridPauseActive := false
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("HYBRID", "RESUMED")
        } else {
            ShowCenteredToolTip("RESUMED")
            SetTimer(() => RemoveToolTip(), -900)
        }
    }
    
    leaderActive := true
    
    ; Deactivate NVIM layer to avoid conflicts
    if (isNvimLayerActive) {
        isNvimLayerActive := false
        try ShowNvimLayerToggleCS(false)
        try ShowNvimLayerStatus(false)
    }
    
    ; Start hierarchical navigation at root
    NavigateHierarchical("leader")
    
    leaderActive := false
}

; ==============================
; NAVEGADOR JERÁRQUICO GENÉRICO
; ==============================

NavigateHierarchical(currentPath) {
    Loop {
        ; Mostrar menú del path actual
        ShowMenuForCurrentPath(currentPath)
        
        ; Esperar input del usuario
        timeout := GetTimeoutForPath(currentPath)
        ih := InputHook("L1 T" . timeout, "{Escape}{Backspace}")
        ih.KeyOpt("{Escape}", "S")
        ih.KeyOpt("{Backspace}", "S")
        ih.Start()
        ih.Wait()
        
        ; Manejar Escape (salir completamente)
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            HideAllTooltips()
            ih.Stop()
            return "EXIT"
        }
        
        ; Manejar Backspace (volver atrás)
        if (ih.EndReason = "EndKey" && ih.EndKey = "Backspace") {
            ih.Stop()
            ; Si estamos en root (leader), salir
            if (currentPath = "leader") {
                HideAllTooltips()
                return "EXIT"
            }
            ; Si no, volver al padre
            return "BACK"
        }
        
        ; Manejar timeout
        if (ih.EndReason = "Timeout") {
            ih.Stop()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Obtener tecla presionada
        key := ih.Input
        ih.Stop()
        
        ; Tecla vacía o inválida
        if (key = "" || key = Chr(0)) {
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Backslash como alternativa a Backspace
        if (key = "\\") {
            if (currentPath = "leader") {
                HideAllTooltips()
                return "EXIT"
            }
            return "BACK"
        }
        
        ; ==============================
        ; NAVEGACIÓN JERÁRQUICA UNIVERSAL
        ; ==============================
        ; TODO lo maneja ExecuteKeymapAtPath() del registry
        ; NO hay código hardcoded para categorías específicas
        
        ; Ejecutar keymap en el path actual
        result := ExecuteKeymapAtPath(currentPath, key)
        
        if (Type(result) = "String") {
            ; Es una categoría, navegar más profundo
            res := NavigateHierarchical(result)
            if (res = "EXIT") {
                HideAllTooltips()
                return "EXIT"
            }
            ; Si es "BACK", continuar en este nivel
            continue
        } else if (result = true) {
            ; Acción ejecutada exitosamente
            HideAllTooltips()
            return "EXIT"
        } else if (result = false) {
            ; Keymap no encontrado
            ShowCenteredToolTip("Unknown key: " . key)
            SetTimer(() => RemoveToolTip(), -800)
            continue
        }
    }
}

; ==============================
; MOSTRAR MENÚ DEL PATH ACTUAL
; ==============================

ShowMenuForCurrentPath(path) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowMenuForPathCS(path)
    } else {
        ; Fallback a tooltip nativo
        menuText := BuildMenuForPath(path, GetTitleForPath(path))
        if (menuText = "") {
            menuText := "NO ITEMS IN MENU"
        }
        
        ToolTipX := A_ScreenWidth // 2 - 110
        ToolTipY := A_ScreenHeight // 2 - 100
        ToolTip(menuText, ToolTipX, ToolTipY, 2)
    }
}

; ==============================
; OBTENER TÍTULO PARA PATH (genérico)
; ==============================

GetTitleForPath(path) {
    global KeymapRegistry
    
    ; Root especial
    if (path = "leader")
        return "LEADER MENU"
    
    ; Buscar título en el registry
    ; path = "leader.w" -> buscar en KeymapRegistry["leader"]["w"]["desc"]
    parts := StrSplit(path, ".")
    if (parts.Length < 2)
        return "MENU"
    
    parentPath := parts[1]
    Loop parts.Length - 2 {
        parentPath .= "." . parts[A_Index + 1]
    }
    key := parts[parts.Length]
    
    ; Intentar obtener desc del registry
    if (KeymapRegistry.Has(parentPath)) {
        if (KeymapRegistry[parentPath].Has(key)) {
            return KeymapRegistry[parentPath][key]["desc"]
        }
    }
    
    ; Fallback: última parte del path en mayúsculas
    return StrUpper(key)
}

; ==============================
; OBTENER TIMEOUT PARA PATH (genérico)
; ==============================

GetTimeoutForPath(path) {
    ; Usar timeout genérico de leader
    ; Todos los mini-layers usan el mismo timeout
    return GetEffectiveTimeout("leader")
}

; ==============================
; NOTAS:
; ==============================
; Este router es COMPLETAMENTE GENÉRICO
; NO necesitas editar este archivo para agregar nuevas categorías
; 
; Para agregar una nueva categoría/comando:
; 1. Crea src/actions/NUEVA_actions.ahk con las funciones
; 2. Define Register[NUEVA]Keymaps() con RegisterKeymap() o RegisterKeymapFlat()
; 3. Registra la categoría en command_system_init.ahk:
;    RegisterCategoryKeymap("tecla", "Título", orden)
; 4. Llama Register[NUEVA]Keymaps() en command_system_init.ahk
; 5. ¡Listo! El router lo detecta automáticamente
;
; Estilo which-key de Neovim: Todo declarativo, nada hardcoded

; ==============================
; MENÚ C# (si está habilitado)
; ==============================

ShowMenuForPathCS(path) {
    ; Generar items del path
    items := GenerateCategoryItemsForPath(path)
    
    if (items = "") {
        items := "[No items registered]"
    }
    
    title := GetTitleForPath(path)
    footer := "\\: Back|ESC: Exit"
    
    ; Mostrar tooltip C#
    ShowCSharpOptionsMenu(title, items, footer)
}

; ==============================
; EMERGENCY RESUME HOTKEY
; ==============================

#SuspendExempt
#HotIf (enableEmergencyResumeHotkey)
^!#r:: {
    global hybridPauseActive
    if (A_IsSuspended) {
        try SetTimer(HybridAutoResumeTimer, 0)
        Suspend(0)
        hybridPauseActive := false
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            try ShowCSharpStatusNotification("HYBRID", "RESUMED (emergency)")
        } else {
            ShowCenteredToolTip("RESUMED (emergency)")
            SetTimer(() => RemoveToolTip(), -900)
        }
    }
}
#HotIf
#SuspendExempt False
