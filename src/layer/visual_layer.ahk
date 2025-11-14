; ==============================
; LAYER TEMPLATE - Dynamic Layer Creation Pattern
; ==============================
; This is a template for creating new persistent layers
; 
; INSTRUCTIONS:
; 1. Copy this file to a new file: {layerName}_layer.ahk
; 2. Replace Visual with your layer name in PascalCase (e.g., "Scroll", "Nvim", "Excel")
;    - For functions: ActivateVisualLayer → ActivateExcelLayer
;    - For variables: isVisualLayerActive → isExcelLayerActive
; 3. Replace visual with layer identifier in lowercase (e.g., "scroll", "nvim", "excel")
;    - For SwitchToLayer: SwitchToLayer("visual", ...) → SwitchToLayer("excel", ...)
;    - For ListenForLayerKeymaps: ListenForLayerKeymaps("visual", ...) → ListenForLayerKeymaps("excel", ...)
;    - For RegisterKeymap: RegisterKeymap("visual", ...) → RegisterKeymap("excel", ...)
; 4. Replace Visual Layer with friendly name (e.g., "Scroll Layer", "Nvim Layer", "Excel Layer")
; 5. Implement your layer-specific actions
; 6. Register keymaps in config/keymap.ahk
;

; ==============================
; CONFIGURATION
; ==============================

global VisualLayerEnabled := true          ; Feature flag
global isVisualLayerActive := false        ; Layer state (managed by SwitchToLayer)

; ==============================
; ACTIVATION FUNCTION
; ==============================

ActivateVisualLayer(originLayer := "leader") {
    OutputDebug("[Visual] ActivateVisualLayer() called with originLayer: " . originLayer)
    result := SwitchToLayer("visual", originLayer)  ; ⚠️ Use lowercase visual here!
    OutputDebug("[Visual] SwitchToLayer result: " . (result ? "true" : "false"))
    return result
}

; ==============================
; ACTIVATION/DEACTIVATION HOOKS
; ==============================

OnVisualLayerActivate() {
    global isVisualLayerActive
    isVisualLayerActive := true
    
    OutputDebug("[Visual] OnVisualLayerActivate() - Activating layer")
    
    ; Show status tooltip (persistent indicator)
    try {
        ShowVisualLayerStatus(true)
        SetTempStatus("Visual Layer ON", 1500)
    } catch Error as e {
        OutputDebug("[Visual] ERROR showing status: " . e.Message)
    }
    
    ; Start listening for keymaps (uses keymap_registry system)
    try {
        ListenForLayerKeymaps("visual", "isVisualLayerActive")  ; ⚠️ Use lowercase visual here!
    } catch Error as e {
        OutputDebug("[Visual] ERROR in ListenForLayerKeymaps: " . e.Message)
    }
    
    ; Note: Layer deactivation is handled by the SwitchToLayer system
    ; No need to manually deactivate here
}

OnVisualLayerDeactivate() {
    global isVisualLayerActive, VisualHelpActive
    isVisualLayerActive := false
    
    ; Clean up help if active
    if (IsSet(VisualHelpActive) && VisualHelpActive) {
        try VisualCloseHelp()
    }
    
    try ShowVisualLayerStatus(false)
    
    OutputDebug("[Visual] Layer deactivated")
}

; ==============================
; LAYER-SPECIFIC ACTIONS
; ==============================
; Actions specific to this layer's control
; Generic/reusable actions should be in src/actions/

VisualExit() {
    global isVisualLayerActive
    isVisualLayerActive := false
    try ReturnToPreviousLayer()
}

; Add your layer-specific action functions here
; Example:
; VisualDoSomething() {
;     ; Implementation
; }

; ==============================
; HELP SYSTEM (Optional but Recommended)
; ==============================
; Dynamic help system that reads keymaps from KeymapRegistry
; Shows all registered keymaps for this layer with tooltips

global VisualHelpActive := false

VisualToggleHelp() {
    global VisualHelpActive
    if (VisualHelpActive)
        VisualCloseHelp()
    else
        VisualShowHelp()
}

VisualShowHelp() {
    global tooltipConfig, VisualHelpActive
    try HideCSharpTooltip()
    Sleep 30
    VisualHelpActive := true
    to := (IsSet(tooltipConfig) && tooltipConfig.HasProp("optionsTimeout") && tooltipConfig.optionsTimeout > 0) ? tooltipConfig.optionsTimeout : 8000
    try SetTimer(VisualHelpAutoClose, -to)
    
    ; Generate help dynamically from KeymapRegistry
    try {
        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
            ; Use C# tooltip with dynamic items
            items := GenerateCategoryItemsForPath("visual")  ; ⚠️ Use lowercase visual!
            if (items = "")
                items := "[No keymaps registered for visual layer]"
            ShowBottomRightListTooltip("Visual Layer HELP", items, "?: Close", to)
        } else {
            ; Fallback: native tooltip with dynamic text
            menuText := BuildMenuForPath("visual", "Visual Layer HELP")  ; ⚠️ Use lowercase visual!
            if (menuText = "")
                menuText := "NO KEYMAPS REGISTERED"
            ShowCenteredToolTip(menuText)
        }
    } catch Error as e {
        OutputDebug("[Visual] ERROR showing help: " . e.Message)
        ShowCenteredToolTip("Visual Layer HELP: See registered keymaps in config/keymap.ahk")
    }
}

VisualHelpAutoClose() {
    global VisualHelpActive
    if (VisualHelpActive)
        VisualCloseHelp()
}

VisualCloseHelp() {
    global isVisualLayerActive, VisualHelpActive
    try SetTimer(VisualHelpAutoClose, 0)
    try HideCSharpTooltip()
    VisualHelpActive := false
    if (isVisualLayerActive) {
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                ; If you have a custom status tooltip, call it here
                ; ShowVisualLayerToggleCS(true)
            } else {
                ShowCenteredToolTip("◉ Visual Layer")
                SetTimer(() => RemoveToolTip(), -900)
            }
        }
    } else {
        try RemoveToolTip()
    }
}

; ==============================
; KEYMAP REGISTRATION
; ==============================
; Register in config/keymap.ahk inside InitializeCategoryKeymaps():
;
; RegisterVisualKeymaps() {
;     ; Basic actions
;     RegisterKeymap("visual", "key", "Description", ActionFunction, false, 1)  ; ⚠️ Use lowercase visual!
;     
;     ; Layer control
;     RegisterKeymap("visual", "Escape", "Exit Layer", VisualExit, false, 10)
;     
;     ; Help system (if implemented)
;     RegisterKeymap("visual", "?", "Toggle Help", VisualToggleHelp, false, 100)
;     
;     OutputDebug("[Visual] Keymaps registered successfully")
; }
;
; Then call RegisterVisualKeymaps() in InitializeCategoryKeymaps()
;
; OR register directly in InitializeCategoryKeymaps() (simpler approach):
;     RegisterKeymap("visual", "h", "Move Left", VimMoveLeft, false, 20)  ; ⚠️ lowercase visual!
;     RegisterKeymap("visual", "j", "Move Down", VimMoveDown, false, 21)
;     RegisterKeymap("visual", "Escape", "Exit Layer", VisualExit, false, 30)
;     RegisterKeymap("visual", "?", "Toggle Help", VisualToggleHelp, false, 100)  ; Help system
;     ; ... more keymaps

; ==============================
; STATUS TOOLTIP FUNCTIONS (To implement in UI files)
; ==============================
; These functions need to be implemented in the UI wrapper files:
;
; 1. In src/ui/tooltips_native_wrapper.ahk (native fallback):
;    ShowVisualLayerStatus(isActive) {
;        if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
;            try ShowVisualLayerToggleCS(isActive)
;        } else {
;            ShowCenteredToolTip(isActive ? "◉ Visual Layer" : "○ Visual Layer")
;            SetTimer(() => RemoveToolTip(), -900)
;        }
;    }
;
; 2. In src/ui/tooltip_csharp_integration.ahk (C# tooltip):
;    ShowVisualLayerToggleCS(isActive) {
;        try HideCSharpTooltip()
;        Sleep 30
;        StartTooltipApp()
;        if (!isActive) {
;            try HideCSharpTooltip()
;            return
;        }
;        theme := ReadTooltipThemeDefaults()
;        cmd := Map()
;        cmd["show"] := true
;        cmd["title"] := "Visual Layer"
;        cmd["layout"] := "list"
;        cmd["tooltip_type"] := "bottom_right_list"
;        cmd["timeout_ms"] := 0  ; persistent while layer is active
;        items := []
;        it := Map()
;        it["key"] := "?"
;        it["description"] := "help"
;        items.Push(it)
;        cmd["items"] := items
;        if (theme.style.Count)
;            cmd["style"] := theme.style
;        if (theme.position.Count)
;            cmd["position"] := theme.position
;        if (theme.window.Has("topmost"))
;            cmd["topmost"] := theme.window["topmost"]
;        if (theme.window.Has("click_through"))
;            cmd["click_through"] := theme.window["click_through"]
;        if (theme.window.Has("opacity"))
;            cmd["opacity"] := theme.window["opacity"]
;        json := SerializeJson(cmd)
;        ScheduleTooltipJsonWrite(json)
;    }
;
; See examples in:
; - ShowScrollLayerStatus() in src/ui/scroll_tooltip_integration.ahk
; - ShowNvimLayerToggleCS() in src/ui/tooltip_csharp_integration.ahk
; - ShowExcelLayerStatus() in src/ui/tooltips_native_wrapper.ahk

; ==============================
; INTEGRATION CHECKLIST
; ==============================
; □ 1. Copy and rename this file to {layerName}_layer.ahk
; □ 2. Replace all visual placeholders with lowercase identifier (e.g., "excel")
;       ⚠️ Do this FIRST to avoid confusion with Visual!
; □ 3. Replace all Visual placeholders with PascalCase name (e.g., "Excel")
; □ 4. Replace all Visual Layer placeholders with display name (e.g., "Excel Layer")
; □ 5. Verify critical lines use visual (lowercase):
;       - SwitchToLayer("visual", ...) 
;       - ListenForLayerKeymaps("visual", ...)
;       - RegisterKeymap("visual", ...)
; □ 6. Implement layer-specific actions
; □ 7. Create action functions in src/actions/ if reusable
; □ 8. Register keymaps in config/keymap.ahk using lowercase visual
;       - Include help keymap: RegisterKeymap("visual", "?", "Toggle Help", VisualToggleHelp, false, 100)
; □ 9. Implement status tooltip functions in UI files:
;       - Add ShowVisualLayerStatus() in src/ui/tooltips_native_wrapper.ahk
;       - Add ShowVisualLayerToggleCS() in src/ui/tooltip_csharp_integration.ahk
;       - See "STATUS TOOLTIP FUNCTIONS" section above for code templates
; □ 10. Register layer activation in leader menu if needed:
;       RegisterKeymap("leader", "key", "Visual Layer", ActivateVisualLayer, false)
; □ 11. Test activation, keymaps, and deactivation
; □ 12. Test help system by pressing "?" while layer is active
; □ 13. Test status tooltip appears when layer activates (persistent indicator)
