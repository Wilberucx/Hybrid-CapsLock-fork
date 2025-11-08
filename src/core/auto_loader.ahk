; ===================================================================
; Auto Loader - Dynamic Actions & Layers Discovery
; ===================================================================
; Automatically scans and includes new .ahk files from:
; - src/actions/
; - src/layer/
;
; Features:
; - JSON memory to track included files
; - Auto-include in init.ahk
; - Safety: Excludes files in no_include/ folders
; - Cleanup: Removes includes for deleted files
;
; Usage: Called at startup by init.ahk
; ===================================================================

; ===================================================================
; CONFIGURATION
; ===================================================================

global AUTO_LOADER_ENABLED := true  ; Set to false to disable auto-loading

; Paths
global AUTO_LOADER_MEMORY_FILE := A_ScriptDir . "\data\auto_loader_memory.json"
global AUTO_LOADER_INIT_FILE := A_ScriptDir . "\init.ahk"

; Scan directories
global AUTO_LOADER_ACTIONS_DIR := A_ScriptDir . "\src\actions"
global AUTO_LOADER_LAYERS_DIR := A_ScriptDir . "\src\layer"

; Exclude directories (files here won't be included)
global AUTO_LOADER_ACTIONS_NO_INCLUDE := A_ScriptDir . "\src\actions\no_include"
global AUTO_LOADER_LAYERS_NO_INCLUDE := A_ScriptDir . "\src\layer\no_include"

; Markers in init.ahk for auto-injection
global AUTO_LOADER_ACTIONS_MARKER_START := "; ===== AUTO-LOADED ACTIONS START ====="
global AUTO_LOADER_ACTIONS_MARKER_END := "; ===== AUTO-LOADED ACTIONS END ====="
global AUTO_LOADER_LAYERS_MARKER_START := "; ===== AUTO-LOADED LAYERS START ====="
global AUTO_LOADER_LAYERS_MARKER_END := "; ===== AUTO-LOADED LAYERS END ====="

; ===================================================================
; MAIN FUNCTION - Called at startup
; ===================================================================

AutoLoaderInit() {
    global AUTO_LOADER_ENABLED
    
    if (!AUTO_LOADER_ENABLED) {
        OutputDebug("[AutoLoader] Disabled by config")
        return
    }
    
    OutputDebug("[AutoLoader] Starting scan...")
    
    ; Ensure no_include directories exist
    EnsureNoIncludeDirectories()
    
    ; Load memory (previously included files)
    memory := LoadAutoLoaderMemory()
    
    ; Scan current files
    currentActions := ScanDirectory(AUTO_LOADER_ACTIONS_DIR, AUTO_LOADER_ACTIONS_NO_INCLUDE)
    currentLayers := ScanDirectory(AUTO_LOADER_LAYERS_DIR, AUTO_LOADER_LAYERS_NO_INCLUDE)
    
    ; Detect changes
    changes := DetectChanges(memory, currentActions, currentLayers)
    
    ; Apply changes if any
    if (changes["hasChanges"]) {
        OutputDebug("[AutoLoader] Changes detected, updating init.ahk...")
        ApplyChanges(changes, currentActions, currentLayers)
        
        ; Save new memory
        SaveAutoLoaderMemory(currentActions, currentLayers)
        
        OutputDebug("[AutoLoader] Changes applied successfully")
        
        ; Show notification
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                ShowCSharpStatusNotification("AUTO-LOADER", "Files updated - Reload required")
            }
        }
    } else {
        OutputDebug("[AutoLoader] No changes detected")
    }
}

; ===================================================================
; MEMORY MANAGEMENT (JSON)
; ===================================================================

LoadAutoLoaderMemory() {
    global AUTO_LOADER_MEMORY_FILE
    
    if (!FileExist(AUTO_LOADER_MEMORY_FILE)) {
        OutputDebug("[AutoLoader] No memory file found, creating new")
        return Map("actions", [], "layers", [], "version", "1.0")
    }
    
    try {
        content := FileRead(AUTO_LOADER_MEMORY_FILE)
        memory := Jxon_Load(&content)
        OutputDebug("[AutoLoader] Memory loaded: " . memory["actions"].Length . " actions, " . memory["layers"].Length . " layers")
        return memory
    } catch as err {
        OutputDebug("[AutoLoader] Error loading memory: " . err.Message)
        return Map("actions", [], "layers", [], "version", "1.0")
    }
}

SaveAutoLoaderMemory(actions, layers) {
    global AUTO_LOADER_MEMORY_FILE
    
    ; Ensure data directory exists
    dataDir := A_ScriptDir . "\data"
    if (!DirExist(dataDir)) {
        DirCreate(dataDir)
    }
    
    memory := Map(
        "actions", actions,
        "layers", layers,
        "version", "1.0",
        "lastUpdate", A_Now
    )
    
    try {
        jsonContent := Jxon_Dump(memory, 4)
        FileDelete(AUTO_LOADER_MEMORY_FILE)
        FileAppend(jsonContent, AUTO_LOADER_MEMORY_FILE)
        OutputDebug("[AutoLoader] Memory saved successfully")
    } catch as err {
        OutputDebug("[AutoLoader] Error saving memory: " . err.Message)
    }
}

; ===================================================================
; DIRECTORY SCANNING
; ===================================================================

EnsureNoIncludeDirectories() {
    global AUTO_LOADER_ACTIONS_NO_INCLUDE, AUTO_LOADER_LAYERS_NO_INCLUDE
    
    if (!DirExist(AUTO_LOADER_ACTIONS_NO_INCLUDE)) {
        DirCreate(AUTO_LOADER_ACTIONS_NO_INCLUDE)
        OutputDebug("[AutoLoader] Created: " . AUTO_LOADER_ACTIONS_NO_INCLUDE)
    }
    
    if (!DirExist(AUTO_LOADER_LAYERS_NO_INCLUDE)) {
        DirCreate(AUTO_LOADER_LAYERS_NO_INCLUDE)
        OutputDebug("[AutoLoader] Created: " . AUTO_LOADER_LAYERS_NO_INCLUDE)
    }
}

ScanDirectory(dirPath, excludePath) {
    files := []
    
    if (!DirExist(dirPath)) {
        OutputDebug("[AutoLoader] Directory not found: " . dirPath)
        return files
    }
    
    Loop Files, dirPath . "\*.ahk", "F" {
        fullPath := A_LoopFileFullPath
        
        ; Skip if in no_include directory
        if (InStr(fullPath, excludePath)) {
            OutputDebug("[AutoLoader] Excluded: " . A_LoopFileName)
            continue
        }
        
        ; Get relative path for #Include
        relativePath := StrReplace(fullPath, A_ScriptDir . "\", "")
        
        files.Push(Map(
            "name", A_LoopFileName,
            "path", relativePath,
            "fullPath", fullPath
        ))
    }
    
    OutputDebug("[AutoLoader] Scanned " . dirPath . ": found " . files.Length . " files")
    return files
}

; ===================================================================
; CHANGE DETECTION
; ===================================================================

DetectChanges(memory, currentActions, currentLayers) {
    changes := Map(
        "hasChanges", false,
        "newActions", [],
        "removedActions", [],
        "newLayers", [],
        "removedLayers", []
    )
    
    ; Convert memory arrays to maps for easier lookup
    memoryActionsMap := Map()
    if (memory.Has("actions")) {
        for item in memory["actions"] {
            memoryActionsMap[item["name"]] := true
        }
    }
    
    memoryLayersMap := Map()
    if (memory.Has("layers")) {
        for item in memory["layers"] {
            memoryLayersMap[item["name"]] := true
        }
    }
    
    ; Detect new actions
    for action in currentActions {
        if (!memoryActionsMap.Has(action["name"])) {
            changes["newActions"].Push(action)
            changes["hasChanges"] := true
        }
    }
    
    ; Detect removed actions
    if (memory.Has("actions")) {
        currentActionsMap := Map()
        for action in currentActions {
            currentActionsMap[action["name"]] := true
        }
        
        for item in memory["actions"] {
            if (!currentActionsMap.Has(item["name"])) {
                changes["removedActions"].Push(item)
                changes["hasChanges"] := true
            }
        }
    }
    
    ; Detect new layers
    for layer in currentLayers {
        if (!memoryLayersMap.Has(layer["name"])) {
            changes["newLayers"].Push(layer)
            changes["hasChanges"] := true
        }
    }
    
    ; Detect removed layers
    if (memory.Has("layers")) {
        currentLayersMap := Map()
        for layer in currentLayers {
            currentLayersMap[layer["name"]] := true
        }
        
        for item in memory["layers"] {
            if (!currentLayersMap.Has(item["name"])) {
                changes["removedLayers"].Push(item)
                changes["hasChanges"] := true
            }
        }
    }
    
    ; Log changes
    if (changes["hasChanges"]) {
        OutputDebug("[AutoLoader] Changes detected:")
        OutputDebug("  New actions: " . changes["newActions"].Length)
        OutputDebug("  Removed actions: " . changes["removedActions"].Length)
        OutputDebug("  New layers: " . changes["newLayers"].Length)
        OutputDebug("  Removed layers: " . changes["removedLayers"].Length)
    }
    
    return changes
}

; ===================================================================
; APPLY CHANGES TO init.ahk
; ===================================================================

ApplyChanges(changes, currentActions, currentLayers) {
    global AUTO_LOADER_INIT_FILE
    
    ; Read current init.ahk
    if (!FileExist(AUTO_LOADER_INIT_FILE)) {
        OutputDebug("[AutoLoader] ERROR: init.ahk not found!")
        return
    }
    
    content := FileRead(AUTO_LOADER_INIT_FILE)
    
    ; Update actions section
    content := UpdateSection(
        content,
        AUTO_LOADER_ACTIONS_MARKER_START,
        AUTO_LOADER_ACTIONS_MARKER_END,
        GenerateIncludes(currentActions)
    )
    
    ; Update layers section
    content := UpdateSection(
        content,
        AUTO_LOADER_LAYERS_MARKER_START,
        AUTO_LOADER_LAYERS_MARKER_END,
        GenerateIncludes(currentLayers)
    )
    
    ; Write back to init.ahk
    try {
        FileDelete(AUTO_LOADER_INIT_FILE)
        FileAppend(content, AUTO_LOADER_INIT_FILE)
        OutputDebug("[AutoLoader] init.ahk updated successfully")
    } catch as err {
        OutputDebug("[AutoLoader] ERROR updating init.ahk: " . err.Message)
    }
}

UpdateSection(content, startMarker, endMarker, newContent) {
    ; Find marker positions
    startPos := InStr(content, startMarker)
    endPos := InStr(content, endMarker)
    
    if (!startPos || !endPos) {
        OutputDebug("[AutoLoader] WARNING: Markers not found in init.ahk")
        OutputDebug("  Looking for: " . startMarker)
        OutputDebug("  and: " . endMarker)
        return content
    }
    
    ; Extract parts
    before := SubStr(content, 1, startPos + StrLen(startMarker) - 1)
    after := SubStr(content, endPos)
    
    ; Reconstruct
    return before . "`n" . newContent . "`n" . after
}

GenerateIncludes(files) {
    if (files.Length = 0) {
        return "; (No auto-loaded files)"
    }
    
    includes := ""
    for fileItem in files {
        ; Convert forward slashes to backslashes for Windows paths
        path := StrReplace(fileItem["path"], "/", "\")
        includes .= "#Include " . path . "`n"
    }
    
    return RTrim(includes, "`n")
}

; ===================================================================
; JSON HELPER (Simple implementation)
; ===================================================================
; Note: For production, consider using a full JSON library like:
; https://github.com/cocobelgica/AutoHotkey-JSON

Jxon_Load(&src, args*) {
    ; Simple JSON parser for our use case
    ; This is a placeholder - you should use a proper JSON library
    ; For now, we'll create a basic implementation
    
    ; Remove whitespace
    src := RegExReplace(src, "[\r\n\t]", "")
    
    ; Parse as map
    result := Map()
    
    ; Extract actions array
    if (RegExMatch(src, '"actions":\s*\[(.*?)\]', &matchActions)) {
        result["actions"] := ParseJsonArray(matchActions[1])
    } else {
        result["actions"] := []
    }
    
    ; Extract layers array
    if (RegExMatch(src, '"layers":\s*\[(.*?)\]', &matchLayers)) {
        result["layers"] := ParseJsonArray(matchLayers[1])
    } else {
        result["layers"] := []
    }
    
    return result
}

ParseJsonArray(jsonArrayContent) {
    items := []
    
    ; Split by objects (find all {...} patterns)
    pos := 1
    while (pos := RegExMatch(jsonArrayContent, "\{(.*?)\}", &match, pos)) {
        objContent := match[1]
        
        ; Parse object
        obj := Map()
        
        ; Extract name
        if (RegExMatch(objContent, '"name":\s*"([^"]+)"', &nameMatch)) {
            obj["name"] := nameMatch[1]
        }
        
        ; Extract path
        if (RegExMatch(objContent, '"path":\s*"([^"]+)"', &pathMatch)) {
            obj["path"] := pathMatch[1]
        }
        
        ; Extract fullPath
        if (RegExMatch(objContent, '"fullPath":\s*"([^"]+)"', &fullPathMatch)) {
            obj["fullPath"] := fullPathMatch[1]
        }
        
        items.Push(obj)
        pos += StrLen(match[0])
    }
    
    return items
}

Jxon_Dump(obj, indent := "") {
    ; Simple JSON serializer
    output := "{"
    
    ; Version
    if (obj.Has("version")) {
        output .= '`n  "version": "' . obj["version"] . '",'
    }
    
    ; Last update
    if (obj.Has("lastUpdate")) {
        output .= '`n  "lastUpdate": "' . obj["lastUpdate"] . '",'
    }
    
    ; Actions array
    output .= '`n  "actions": ['
    if (obj["actions"].Length > 0) {
        for item in obj["actions"] {
            output .= "`n    " . SerializeItem(item) . ","
        }
        output := RTrim(output, ",")
    }
    output .= "`n  ],"
    
    ; Layers array
    output .= '`n  "layers": ['
    if (obj["layers"].Length > 0) {
        for item in obj["layers"] {
            output .= "`n    " . SerializeItem(item) . ","
        }
        output := RTrim(output, ",")
    }
    output .= "`n  ]"
    
    output .= "`n}"
    return output
}

SerializeItem(item) {
    ; Escape backslashes for JSON
    path := StrReplace(item["path"], "\", "\\")
    fullPath := StrReplace(item["fullPath"], "\", "\\")
    
    return '{"name": "' . item["name"] . '", "path": "' . path . '", "fullPath": "' . fullPath . '"}'
}
