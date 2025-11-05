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
    global enableLayerPersistence, isNvimLayerActive, excelLayerActive, capsActsNormal
    if (!enableLayerPersistence)
        return
    EnsureLayerStateDir()
    stateFile := GetLayerStateFile()
    IniWrite(isNvimLayerActive ? "true" : "false", stateFile, "LayerState", "isNvimLayerActive")
    IniWrite(excelLayerActive ? "true" : "false", stateFile, "LayerState", "excelLayerActive")
    IniWrite(capsActsNormal ? "true" : "false", stateFile, "LayerState", "capsActsNormal")
}

LoadLayerState() {
    global enableLayerPersistence, nvimLayerEnabled, excelLayerEnabled
    global isNvimLayerActive, excelLayerActive, capsActsNormal
    if (!enableLayerPersistence)
        return
    stateFile := GetLayerStateFile()
    if (!FileExist(stateFile))
        return
    ; Read values with defaults to current in-memory states
    nvimState := IniRead(stateFile, "LayerState", "isNvimLayerActive", isNvimLayerActive ? "true" : "false")
    excelState := IniRead(stateFile, "LayerState", "excelLayerActive", excelLayerActive ? "true" : "false")
    capsState := IniRead(stateFile, "LayerState", "capsActsNormal", capsActsNormal ? "true" : "false")
    
    ; Apply with gating clamps
    isNvimLayerActive := (nvimLayerEnabled && (StrLower(nvimState) = "true"))
    excelLayerActive := (excelLayerEnabled && (StrLower(excelState) = "true"))
    capsActsNormal := (StrLower(capsState) = "true")
}
