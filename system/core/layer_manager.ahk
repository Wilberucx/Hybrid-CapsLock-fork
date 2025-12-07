; ===================================================================
; LAYER MANAGER - Runtime Layer Switching & Activation
; ===================================================================
; Handles switching between layers, activating/deactivating them,
; and managing the global layer state.
;
; Separated from auto_loader.ahk to avoid circular dependencies
; during bootstrap.
; ===================================================================

; Global state for layer switching
global CurrentActiveLayer := ""
global PreviousLayer := ""
global LayerRegistry := Map()

LoadLayerRegistry() {
    global AUTO_LOADER_LAYER_REGISTRY_FILE, LayerRegistry
    
    LayerRegistry := Map()
    
    if (!FileExist(AUTO_LOADER_LAYER_REGISTRY_FILE)) {
        Log.e("Registry file not found: " . AUTO_LOADER_LAYER_REGISTRY_FILE, "LAYER")
        return false
    }
    
    try {
        content := FileRead(AUTO_LOADER_LAYER_REGISTRY_FILE)
        lines := StrSplit(content, "`n")
        
        inLayersSection := false
        for line in lines {
            trimmed := Trim(line)
            
            ; Skip comments and empty lines
            if (trimmed == "" || InStr(trimmed, ";") == 1) {
                continue
            }
            
            ; Check for [Layers] section
            if (trimmed == "[Layers]") {
                inLayersSection := true
                continue
            }
            
            ; Parse layer entries
            if (inLayersSection && InStr(trimmed, "=")) {
                parts := StrSplit(trimmed, "=", " `t")
                if (parts.Length >= 2) {
                    layerName := Trim(parts[1])
                    layerPath := Trim(parts[2])
                    LayerRegistry[layerName] := layerPath
                    Log.d("Registered layer: " . layerName . " -> " . layerPath, "LAYER")
                }
            }
        }
        
        Log.d("Registry loaded: " . LayerRegistry.Count . " layers", "LAYER")
        return true
    } catch as regLoadErr {
        Log.e("Error loading registry: " . regLoadErr.Message, "LAYER")
        return false
    }
}

SwitchToLayer(targetLayer, originLayer := "") {
    global CurrentActiveLayer, PreviousLayer, LayerRegistry
    
    Log.t(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>", "LAYER")
    Log.d("SWITCH TO LAYER CALLED", "LAYER")
    Log.d("From: " . originLayer . " ? To: " . targetLayer, "LAYER")
    Log.d("CurrentActiveLayer before: " . CurrentActiveLayer, "LAYER")
    Log.d("PreviousLayer before: " . PreviousLayer, "LAYER")
    
    ; Load registry if not loaded
    if (LayerRegistry.Count == 0) {
        if (!LoadLayerRegistry()) {
            Log.e("Could not load layer registry", "LAYER")
            return false
        }
    }
    
    ; Validate target layer exists
    if (!LayerRegistry.Has(targetLayer)) {
        Log.e("Layer not found: " . targetLayer, "LAYER")
        return false
    }
    
    ; CRITICAL: Deactivate origin layer explicitly to avoid #HotIf conflicts
    if (originLayer != "" && originLayer != "leader") {
        ; Use full deactivation to ensure proper cleanup
        DeactivateLayer(originLayer)
    }
    
    ; Deactivate current layer (if switching from intermediate state)
    if (CurrentActiveLayer != "" && CurrentActiveLayer != originLayer) {
        DeactivateLayer(CurrentActiveLayer)
    }
    
    ; Set state - preserve current layer if origin not specified
    if (originLayer == "") {
        PreviousLayer := CurrentActiveLayer  ; Auto-preserve current layer for proper return navigation
    } else {
        PreviousLayer := originLayer
    }
    CurrentActiveLayer := targetLayer
    
    ; Force close any existing tooltips (like Leader Menu) before activating new layer
    try {
        HideAllTooltips()
    }
    
    ; Activate new layer
    ActivateLayer(targetLayer)
    
    Log.d("Switched to layer: " . targetLayer . " (from: " . PreviousLayer . ")", "LAYER")
    return true
}

ReturnToPreviousLayer() {
    global CurrentActiveLayer, PreviousLayer
    
    Log.t("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<", "LAYER")
    Log.d("RETURN TO PREVIOUS LAYER CALLED", "LAYER")
    Log.d("CurrentActiveLayer: " . CurrentActiveLayer, "LAYER")
    Log.d("PreviousLayer: " . PreviousLayer, "LAYER")
    Log.t("<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<", "LAYER")
    
    if (PreviousLayer == "" || PreviousLayer == "leader") {
        ; Return to base state - completely exit current layer
        if (CurrentActiveLayer != "") {
            DeactivateLayer(CurrentActiveLayer)
        }
        CurrentActiveLayer := ""
        PreviousLayer := ""
        Log.d("Returned to base state", "LAYER")
    } else {
        ; Return to previous layer - use intelligent restoration
        if (CurrentActiveLayer != "") {
            DeactivateLayer(CurrentActiveLayer)
        }
        
        ; CRITICAL FIX: Update CurrentActiveLayer BEFORE restoring context
        ; This ensures the listener sees the correct CurrentActiveLayer immediately
        tempPrevious := PreviousLayer
        CurrentActiveLayer := tempPrevious
        PreviousLayer := ""
        Log.d("Updated CurrentActiveLayer to: " . CurrentActiveLayer, "LAYER")
        
        ; Smart reactivation: preserve original context
        RestoreOriginLayerContext(tempPrevious)
        Log.d("Returned to previous layer: " . CurrentActiveLayer, "LAYER")
    }
}

; ===================================================================
; ExitCurrentLayer()
; ===================================================================
; **PUBLIC API** - Explicitly exit the current layer and return to base state.
;
; Use this function when you want to FORCE EXIT from any layer,
; ignoring navigation history and returning directly to base state.
;
; Differences from ReturnToPreviousLayer():
;   - ReturnToPreviousLayer(): Smart navigation (returns to previous layer if exists)
;   - ExitCurrentLayer():      Force exit (always returns to base state)
;
; Use Cases:
;   ✅ Emergency exit / panic button (e.g., double-tap Escape)
;   ✅ Explicit "close layer" commands (e.g., "q" to quit)
;   ✅ Reset to base state in error conditions
;   ✅ User-triggered "exit all layers" hotkey
;
; Example Usage:
;   ; In a plugin keymap:
;   RegisterKeymap("my_layer", "q", "Force Exit", ExitCurrentLayer)
;   
;   ; Or in custom logic:
;   if (error_condition) {
;       ExitCurrentLayer()
;   }
;
; State Changes:
;   Before: CurrentActiveLayer = "some_layer", PreviousLayer = "other_layer"
;   After:  CurrentActiveLayer = "", PreviousLayer = ""
; ===================================================================
ExitCurrentLayer() {
    global CurrentActiveLayer, PreviousLayer
    
    Log.t("========================================", "LAYER")
    Log.d("EXIT CURRENT LAYER CALLED (FORCE EXIT)", "LAYER")
    Log.d("CurrentActiveLayer: " . CurrentActiveLayer, "LAYER")
    Log.t("========================================", "LAYER")
    
    ; Store layer name for logging before clearing
    exitedLayer := CurrentActiveLayer
    
    ; Deactivate current layer if active
    if (CurrentActiveLayer != "") {
        DeactivateLayer(CurrentActiveLayer)
        Log.d("Force exited layer: " . exitedLayer, "LAYER")
    } else {
        Log.d("No active layer to exit (already in base state)", "LAYER")
    }
    
    ; Clear all layer state - return to base
    CurrentActiveLayer := ""
    PreviousLayer := ""
    
    Log.d("Returned to base state (force exit)", "LAYER")
}

ActivateLayer(layerName) {
    Log.t("+++++ ACTIVATING LAYER: " . layerName . " +++++", "LAYER")
    
    ; 1. Try specific activation hook (Legacy/Advanced mode)
    hookFunction := "On" . StrTitle(layerName) . "LayerActivate"
    if (IsSet(%hookFunction%)) {
        try {
            %hookFunction%()
            Log.d("Called activation hook: " . hookFunction, "LAYER")
            
            ; Ensure state variable is set (hook might do it, but safety first)
            layerStateVar := "is" . StrTitle(layerName) . "LayerActive"
            try {
                %layerStateVar% := true
            }
            return
        } catch as hookErr {
            Log.w("Activation hook failed: " . hookErr.Message, "LAYER")
        }
    }
    
    ; 2. Try Generic Activation (File-less mode)
    ; If no hook exists but layer is registered or requested
    if (LayerRegistry.Has(layerName) || true) { ; Always allow generic activation for dynamic layers
        ActivateGenericLayer(layerName)
        return
    }
    
    Log.e("Could not activate layer: " . layerName . " (No hook found)", "LAYER")
}

ActivateGenericLayer(layerName) {
    Log.d("Activating GENERIC layer: " . layerName, "LAYER")
    
    ; 1. Show Status
    try {
        if (IsSet(ShowGenericLayerStatusCS)) {
            ShowGenericLayerStatusCS(layerName, true)
        }
    } catch as e {
        Log.w("Could not show status: " . e.Message, "LAYER")
    }
    
    ; 2. Start Listener
    ; We pass "CurrentActiveLayer" as the state variable name
    ; The listener will check if CurrentActiveLayer == layerName
    try {
        ListenForLayerKeymaps(layerName, "CurrentActiveLayer")
    } catch as e {
        Log.e("Error in generic listener: " . e.Message, "LAYER")
    }
}

; ===================================================================
; DeactivateLayer(layerName)
; ===================================================================
; **INTERNAL HELPER FUNCTION** - Do NOT call directly from plugins!
;
; This is a LOW-LEVEL function used internally by:
;   - SwitchToLayer() - to cleanup when switching between layers
;   - ReturnToPreviousLayer() - to cleanup before restoring state
;
; What it does:
;   ✅ Calls OnXxxLayerDeactivate() hooks
;   ✅ Hides layer status tooltips
;   ✅ Sets isXxxLayerActive := false
;   ✅ Stops CurrentLayerInputHook
;   ❌ Does NOT update CurrentActiveLayer/PreviousLayer globals
;   ❌ Does NOT handle layer stack/restoration
;
; **PLUGINS SHOULD USE**: ReturnToPreviousLayer()
; That function handles complete state management and calls this internally.
; ===================================================================
DeactivateLayer(layerName) {
    Log.t("----- DEACTIVATING LAYER: " . layerName . " -----", "LAYER")
    
    ; Call layer-specific deactivation hook if it exists
    hookFunction := "On" . StrTitle(layerName) . "LayerDeactivate"
    try {
        if (IsSet(%hookFunction%)) {
            %hookFunction%()
            Log.d("Called deactivation hook: " . hookFunction, "LAYER")
        }
    } catch as deactivationErr {
        Log.w("Deactivation hook not found or failed: " . hookFunction . " - " . deactivationErr.Message, "LAYER")
    }
    
    ; Always try to hide generic status (safe to call even if not shown)
    try {
        if (IsSet(ShowGenericLayerStatusCS)) {
            ShowGenericLayerStatusCS(layerName, false)
        }
    } catch {
        ; Ignore errors if status function not available
    }
    
    ; Unset layer state variable
    layerStateVar := "is" . StrTitle(layerName) . "LayerActive"
    try {
        %layerStateVar% := false
        Log.d("Set state variable: " . layerStateVar . " = false", "LAYER")
        
        ; CRITICAL OPTIMIZATION: Stop the InputHook immediately
        ; This removes the need for the 100ms polling loop in the listener
        if (IsSet(CurrentLayerInputHook) && IsObject(CurrentLayerInputHook)) {
            try {
                CurrentLayerInputHook.Stop()
                Log.d("Stopped CurrentLayerInputHook immediately", "LAYER")
            } catch as hookErr {
                Log.w("Error stopping InputHook: " . hookErr.Message, "LAYER")
            }
        }
    } catch {
        Log.d("Could not unset state variable: " . layerStateVar, "LAYER")
    }
}


RestoreOriginLayerContext(layerName) {
    Log.d("Restoring origin layer context: " . layerName, "LAYER")
    
    ; Longer delay to ensure previous layer is completely deactivated and listeners stopped
    Sleep(150)
    
    ; CRITICAL FIX: Clear any pending input hooks before reactivation
    ; This prevents ESC key issues when returning to origin layer
    try {
        ; Create and immediately stop a dummy InputHook to clear any pending state
        clearHook := InputHook("L1")
        clearHook.Stop()
        Log.d("Cleared pending InputHook state", "LAYER")
    } catch as clearErr {
        Log.w("Error clearing InputHook: " . clearErr.Message, "LAYER")
    }
    
    ; Small delay after clearing to ensure clean state
    Sleep(75)
    
    ; Use ActivateLayer directly - this is cleaner and ensures proper activation sequence
    ; ActivateLayer will:
    ; 1. Call the activation hook (which sets state var and starts listener)
    ; 2. Set the state variable (redundant but safe)
    ActivateLayer(layerName)
    
    Log.d("Origin layer context fully restored: " . layerName, "LAYER")
}
