; ==============================
; Leader Router - Universal Hierarchical System
; ==============================
; Generic router for hierarchical navigation in Leader Menu.
; Hotkey: F24 (sent by Kanata when CapsLock hold + Space)
;
; ARCHITECTURE:
; - Uses ExecuteKeymapAtPath() from keymap_registry
; - Multi-level navigation with breadcrumb (back working)
; - Compatible with categories registered in command_system_init.ahk
;
; IMPORTANT: F24 hotkey CANNOT be moved to RegisterKeymap()
; - F24 is a GLOBAL TRIGGER from Kanata (external)
; - RegisterKeymap() is for keys INSIDE layers (internal)
; - F24 is the entry point that ACTIVATES leader
; - Keymaps are for actions WITHIN activated layers
;
; Dependencies: 
;   - core/keymap_registry (ExecuteKeymapAtPath, GetSortedKeymapsForPath)
;   - core/config (GetEffectiveTimeout)
;   - ui/tooltips

; ==============================
; CONFIGURATION
; ==============================

global leaderLayerEnabled := true  ; Feature flag for leader layer

; ==============================
; GLOBAL TRIGGER HOTKEY
; ==============================
; F24 is sent by Kanata when CapsLock is held and Space is pressed
; This MUST remain a direct hotkey (cannot use RegisterKeymap)
; because it's the external trigger that activates the leader system


; ==============================
; ACTIVATION FUNCTION
; ==============================
; ActivateLeaderLayer() - Main entry point for leader system
; Can be called from:
;   - F24 hotkey (Kanata trigger)
;   - Other scripts/layers if needed
; Similar to ActivateScrollLayer(), ActivateExcelLayer(), etc.

ActivateLeaderLayer() {
    global leaderActive, isNvimLayerActive, hybridPauseActive
    
    OutputDebug("[Leader] ActivateLeaderLayer() - Activating leader")
    
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
    OutputDebug("[Leader] ActivateLeaderLayer() - Deactivated")
}

; Legacy alias for backward compatibility
TryActivateLeader() => ActivateLeaderLayer()

; ==============================
; GENERIC HIERARCHICAL NAVIGATOR
; ==============================

NavigateHierarchical(currentPath) {
    Loop {
        ; Show menu for current path
        ShowMenuForCurrentPath(currentPath)
        
        ; Wait for user input
        timeout := GetTimeoutForPath(currentPath)
        ih := InputHook("L1 T" . timeout, "{Escape}{Backspace}")
        ih.KeyOpt("{Escape}", "S")
        ih.KeyOpt("{Backspace}", "S")
        ih.Start()
        ih.Wait()
        
        ; Handle Escape (exit completely)
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            HideAllTooltips()
            ih.Stop()
            return "EXIT"
        }
        
        ; Handle Backspace (go back)
        if (ih.EndReason = "EndKey" && ih.EndKey = "Backspace") {
            ih.Stop()
            ; If we're at root (leader), exit
            if (currentPath = "leader") {
                HideAllTooltips()
                return "EXIT"
            }
            ; Otherwise, return to parent
            return "BACK"
        }
        
        ; Handle timeout
        if (ih.EndReason = "Timeout") {
            ih.Stop()
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Get pressed key
        key := ih.Input
        ih.Stop()
        
        ; Empty or invalid key
        if (key = "" || key = Chr(0)) {
            HideAllTooltips()
            return "EXIT"
        }
        
        ; Backslash as alternative to Backspace
        if (key = "\\") {
            if (currentPath = "leader") {
                HideAllTooltips()
                return "EXIT"
            }
            return "BACK"
        }
        
        ; ==============================
        ; UNIVERSAL HIERARCHICAL NAVIGATION
        ; ==============================
        ; Everything is handled by ExecuteKeymapAtPath() from registry
        ; NO hardcoded logic for specific categories
        ; Execute keymap at current path
        result := ExecuteKeymapAtPath(currentPath, key)
        
        if (Type(result) = "String") {
            ; It's a category, navigate deeper
            res := NavigateHierarchical(result)
            if (res = "EXIT") {
                HideAllTooltips()
                return "EXIT"
            }
            ; If "BACK", continue at this level
            continue
        } else if (result = true) {
            ; Action executed successfully
            HideAllTooltips()
            return "EXIT"
        } else if (result = false) {
            ; Keymap not found
            ShowCenteredToolTip("Unknown key: " . key)
            SetTimer(() => RemoveToolTip(), -800)
            continue
        }
    }
}

; ==============================
; SHOW MENU FOR CURRENT PATH
; ==============================

ShowMenuForCurrentPath(path) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowMenuForPathCS(path)
    } else {
        ; Fallback to native tooltip
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
; GET TITLE FOR PATH (generic)
; ==============================

GetTitleForPath(path) {
    global KeymapRegistry
    
    ; Special case for root
    if (path = "leader")
        return "LEADER MENU"
    
    ; Search for title in registry
    ; path = "leader.w" -> search in KeymapRegistry["leader"]["w"]["desc"]
    parts := StrSplit(path, ".")
    if (parts.Length < 2)
        return "MENU"
    
    parentPath := parts[1]
    Loop parts.Length - 2 {
        parentPath .= "." . parts[A_Index + 1]
    }
    key := parts[parts.Length]
    
    ; Try to get desc from registry
    if (KeymapRegistry.Has(parentPath)) {
        if (KeymapRegistry[parentPath].Has(key)) {
            return KeymapRegistry[parentPath][key]["desc"]
        }
    }
    
    ; Fallback: last part of path in uppercase
    return StrUpper(key)
}

; ==============================
; GET TIMEOUT FOR PATH (generic)
; ==============================

GetTimeoutForPath(path) {
    ; Use generic leader timeout
    ; All mini-layers use the same timeout
    return GetEffectiveTimeout("leader")
}

; ==============================
; NOTES:
; ==============================
; This router is COMPLETELY GENERIC
; You do NOT need to edit this file to add new categories
; 
; To add a new category/command:
; 1. Create src/actions/NEW_actions.ahk with functions
; 2. Define Register[NEW]Keymaps() with RegisterKeymap() or RegisterKeymapFlat()
; 3. Register the category in command_system_init.ahk:
;    RegisterCategoryKeymap("key", "Title", order)
; 4. Call Register[NEW]Keymaps() in command_system_init.ahk
; 5. Done! The router detects it automatically
;
; which-key style from Neovim: Everything declarative, nothing hardcoded

; ==============================
; C# MENU (if enabled)
; ==============================

ShowMenuForPathCS(path) {
    ; Generate items for path
    items := GenerateCategoryItemsForPath(path)
    
    if (items = "") {
        items := "[No items registered]"
    }
    
    title := GetTitleForPath(path)
    footer := "\\: Back|ESC: Exit"
    
    ; Show C# tooltip
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
