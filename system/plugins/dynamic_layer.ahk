; ==============================
; Dynamic Layer - Core System Plugin
; ==============================
; Automatically activates layers based on the active application
; Location: system/plugins/dynamic_layer.ahk

; ==============================
; CONFIGURATION
; ==============================

global DYNAMIC_LAYER_ENABLED := true  ; Toggle for the system

; ==============================
; DATA MANAGEMENT
; ==============================

GetLayerBindingsPath() {
    dataPath := "data\layer_bindings.json"
    SplitPath(dataPath, , &dir)
    if !DirExist(dir)
        DirCreate(dir)
    return dataPath
}

GetLayersMetadataPath() {
    return "data\layers.json"
}

LoadLayerBindings() {
    jsonFile := GetLayerBindingsPath()
    if !FileExist(jsonFile)
        return Map()
        
    try {
        content := FileRead(jsonFile)
        if (content == "")
            return Map()
            
        bindings := Map()
        
        ; Remove outer braces
        content := Trim(content, "{} `t`n`r")
        
        ; Parse JSON manually (simple key-value pairs)
        needle := '"((?:[^"\\]|\\.)*)"\s*:\s*"((?:[^"\\]|\\.)*)"'
        pos := 1
        while (pos := RegExMatch(content, needle, &match, pos)) {
            process := match[1]
            layerId := match[2]
            bindings[process] := layerId
            pos += match.Len
        }
        
        return bindings
    } catch as err {
        Log.e("Error loading layer bindings: " . err.Message)
        return Map()
    }
}

SaveLayerBindings(bindings) {
    jsonFile := GetLayerBindingsPath()
    
    content := "{"
    first := true
    
    for process, layerId in bindings {
        if (!first)
            content .= ","
        first := false
        content .= '`n  "' . process . '": "' . layerId . '"'
    }
    content .= "`n}"
    
    try {
        if FileExist(jsonFile)
            FileDelete(jsonFile)
        FileAppend(content, jsonFile)
    } catch as err {
        Log.e("Error saving layer bindings: " . err.Message)
    }
}

LoadAvailableLayers() {
    jsonFile := GetLayersMetadataPath()
    if !FileExist(jsonFile)
        return Map()
        
    try {
        content := FileRead(jsonFile)
        if (content == "")
            return Map()
            
        layers := Map()
        
        ; The JSON structure from RegisterLayer is:
        ; {"layers": [{"id": "...", "name": "..."}, ...], "lastUpdate": "..."}
        ; We need to extract the layers array
        
        ; Find the "layers" array
        if (RegExMatch(content, '"layers"\s*:\s*\[(.*?)\]', &match)) {
            layersContent := match[1]
            
            ; Parse each layer object: {"id": "...", "name": "..."}
            needle := '\{"id"\s*:\s*"([^"]+)"[^}]*"name"\s*:\s*"([^"]+)"\}'
            pos := 1
            while (pos := RegExMatch(layersContent, needle, &layerMatch, pos)) {
                layerId := layerMatch[1]
                layerName := layerMatch[2]
                layers[layerId] := layerName
                pos += layerMatch.Len
            }
        }
        
        return layers
    } catch as err {
        Log.e("Error loading layers metadata: " . err.Message)
        return Map()
    }
}

; ==============================
; CORE LOGIC
; ==============================

GetLayerForProcess(processName) {
    bindings := LoadLayerBindings()
    if bindings.Has(processName)
        return bindings[processName]
    return ""
}

/**
 * ActivateDynamicLayer - Manually activates the layer bound to the current process
 * This function is meant to be called via keymap or HotIf
 * Returns: Boolean (true if layer was activated, false otherwise)
 */
ActivateDynamicLayer() {
    if (!DYNAMIC_LAYER_ENABLED) {
        ShowTooltipFeedback("Dynamic Layer system is disabled", "warning", 1500)
        SetTimer(() => ToolTip(, , , 20), -1500)
        return false
    }
    
    currentProcess := GetActiveProcessName()
    if (currentProcess == "") {
        ShowTooltipFeedback("Unable to detect active process", "error", 1500)
        SetTimer(() => ToolTip(, , , 20), -1500)
        return false
    }
    
    layerId := GetLayerForProcess(currentProcess)
    if (layerId == "") {
        ShowTooltipFeedback("No layer bound to: " . currentProcess, "info", 2000)
        SetTimer(() => ToolTip(, , , 20), -2000)
        return false
    }
    
    try {
        SwitchToLayer(layerId)
        Log.i("Activated layer: " . layerId . " for process: " . currentProcess, "DYNAMIC_LAYER")
        return true
    } catch {
        ShowTooltipFeedback("Failed to activate layer: " . layerId, "error", 2000)
        SetTimer(() => ToolTip(, , , 20), -2000)
        Log.e("Failed to switch to layer " . layerId)
        return false
    }
}

ToggleDynamicLayer() {
    global DYNAMIC_LAYER_ENABLED
    DYNAMIC_LAYER_ENABLED := !DYNAMIC_LAYER_ENABLED
    
    status := DYNAMIC_LAYER_ENABLED ? "ENABLED" : "DISABLED"
    ShowTooltipFeedback("Dynamic Layer system " . status, "info", 2000)
    SetTimer(() => ToolTip(, , , 20), -2000)
    
    Log.i("Dynamic Layer system " . status, "DYNAMIC_LAYER")
}

; ==============================
; GUI FUNCTIONS
; ==============================

ShowBindProcessGui() {
    currentProcess := GetActiveProcessName()
    if (currentProcess == "") {
        MsgBox("Unable to detect active process", "Error", "Icon!")
        return
    }
    
    layers := LoadAvailableLayers()
    if (layers.Count == 0) {
        MsgBox("No layers registered yet. Create a layer first using RegisterLayer.", "Error", "Icon!")
        return
    }
    
    layerNames := []
    layerIds := []
    for id, name in layers {
        layerNames.Push(name . " (" . id . ")")
        layerIds.Push(id)
    }
    
    g := Gui(, "Bind Process to Layer")
    g.SetFont("s10", "Segoe UI")
    
    g.Add("Text",, "Process: " . currentProcess)
    g.Add("Text",, "Select Layer:")
    
    lb := g.Add("ListBox", "w400 h200 vSelectedLayer", layerNames)
    
    ; Pre-select if already bound
    bindings := LoadLayerBindings()
    if bindings.Has(currentProcess) {
        currentLayerId := bindings[currentProcess]
        for index, id in layerIds {
            if (id == currentLayerId) {
                lb.Choose(index)
                break
            }
        }
    }
    
    g.Add("Button", "Default w100", "Bind").OnEvent("Click", (*) => BindProcess(g, currentProcess, lb.Value, layerIds))
    g.Add("Button", "x+10 w100", "Unbind").OnEvent("Click", (*) => UnbindProcess(g, currentProcess))
    
    g.Show()
    
    BindProcess(guiObj, process, selection, layerIds) {
        if (selection == 0) {
            MsgBox("Please select a layer", "Error", "Icon!")
            return
        }
        
        layerId := layerIds[selection]
        bindings := LoadLayerBindings()
        bindings[process] := layerId
        SaveLayerBindings(bindings)
        
        MsgBox("Bound " . process . " to layer: " . layerId, "Success", "Iconi")
        guiObj.Destroy()
    }
    
    UnbindProcess(guiObj, process) {
        bindings := LoadLayerBindings()
        if bindings.Has(process) {
            bindings.Delete(process)
            SaveLayerBindings(bindings)
            MsgBox("Unbound " . process, "Success", "Iconi")
        } else {
            MsgBox(process . " is not bound to any layer", "Info", "Iconi")
        }
        guiObj.Destroy()
    }
}

ShowBindingsListGui() {
    bindings := LoadLayerBindings()
    layers := LoadAvailableLayers()
    
    if (bindings.Count == 0) {
        MsgBox("No process bindings configured yet", "Info", "Iconi")
        return
    }
    
    g := Gui(, "Layer Bindings")
    g.SetFont("s10", "Segoe UI")
    
    g.Add("Text",, "Current Bindings:")
    
    bindingList := []
    for process, layerId in bindings {
        layerName := layers.Has(layerId) ? layers[layerId] : layerId
        bindingList.Push(process . " → " . layerName)
    }
    
    lb := g.Add("ListBox", "w500 h300", bindingList)
    
    g.Add("Button", "w100", "Close").OnEvent("Click", (*) => g.Destroy())
    
    g.Show()
}

; ==============================
; INITIALIZATION
; ==============================

; No auto-initialization needed - system is activated manually via keymap

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================
; Moved to keymap.ahk
;
; RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 7)
; RegisterKeymap("leader", "h", "t", "Toggle Dynamic Layer", ToggleDynamicLayer, false, 8)
; RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 9)
; RegisterKeymap("leader", "d", "Dynamic Layer", ActivateDynamicLayer, false, 1)
