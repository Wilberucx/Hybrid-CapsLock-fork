; ==============================
; Core persistence (layer state)
; ==============================
; Save/Load of persistent runtime flags to data/layer_state.ini

GetLayerStateFile() {
    return A_ScriptDir . "\\data\\layer_state.ini"
}

EnsureLayerStateDir() {
    dir := A_ScriptDir . "\\data"
    if (!DirExist(dir)) {
        DirCreate(dir)
    }
}

SaveLayerState() {
    global enableLayerPersistence, isNvimLayerActive, excelLayerActive
    if (!enableLayerPersistence)
        return
    EnsureLayerStateDir()
    stateFile := GetLayerStateFile()
    IniWrite(isNvimLayerActive ? "true" : "false", stateFile, "LayerState", "isNvimLayerActive")
    IniWrite(excelLayerActive ? "true" : "false", stateFile, "LayerState", "excelLayerActive")
}

LoadLayerState() {
    global enableLayerPersistence, nvimLayerEnabled, excelLayerEnabled
    global isNvimLayerActive, excelLayerActive
    if (!enableLayerPersistence)
        return
    stateFile := GetLayerStateFile()
    if (!FileExist(stateFile))
        return
    ; Read values with defaults to current in-memory states
    nvimState := IniRead(stateFile, "LayerState", "isNvimLayerActive", isNvimLayerActive ? "true" : "false")
    excelState := IniRead(stateFile, "LayerState", "excelLayerActive", excelLayerActive ? "true" : "false")
    
    ; Apply with gating clamps
    isNvimLayerActive := (nvimLayerEnabled && (StrLower(nvimState) = "true"))
    excelLayerActive := (excelLayerEnabled && (StrLower(excelState) = "true"))
}
