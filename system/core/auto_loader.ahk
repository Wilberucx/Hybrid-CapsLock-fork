; ===================================================================
; Auto Loader - Dynamic Plugins & Layers Discovery (Neovim-style)
; ===================================================================
; Automatically scans and includes new .ahk files with priority system:
; 1. ahk/plugins/ and ahk/layers/ (USER - highest priority)
; 2. system/plugins/ and system/layers/ (SYSTEM - fallback)
;
; Features:
; - User files override system files (like Neovim's lua/ folder)
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
global AUTO_LOADER_LAYER_REGISTRY_FILE := A_ScriptDir . "\data\layer_registry.ini"
global AUTO_LOADER_INIT_FILE := A_ScriptDir . "\init.ahk"

; Scan directories (User - priority 1)
global AUTO_LOADER_USER_PLUGINS_DIR := A_ScriptDir . "\ahk\plugins"
; global AUTO_LOADER_USER_LAYERS_DIR := A_ScriptDir . "\ahk\layers" ; Deprecated

; Scan directories (System - priority 2)
global AUTO_LOADER_SYSTEM_PLUGINS_DIR := A_ScriptDir . "\system\plugins"
global AUTO_LOADER_SYSTEM_LAYERS_DIR := A_ScriptDir . "\system\layers"

; Exclude directories (files here won't be included)
global AUTO_LOADER_SYSTEM_PLUGINS_NO_INCLUDE := A_ScriptDir . "\system\plugins\no_include"
global AUTO_LOADER_SYSTEM_LAYERS_NO_INCLUDE := A_ScriptDir . "\system\layers\no_include"

; Markers in init.ahk for auto-injection
global AUTO_LOADER_PLUGINS_MARKER_START := "; ===== AUTO-LOADED PLUGINS START ====="
global AUTO_LOADER_PLUGINS_MARKER_END := "; ===== AUTO-LOADED PLUGINS END ====="
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
    
    OutputDebug("[AutoLoader] Starting scan (Neovim-style priority)...")
    
    ; Ensure no_include directories exist
    EnsureNoIncludeDirectories()
    
    ; Load memory (previously included files)
    memory := LoadAutoLoaderMemory()
    
    ; Scan current files from BOTH user and system directories
    ; Priority: User files override system files with same name
    currentPlugins := MergeWithPriority(
        ScanDirectory(AUTO_LOADER_USER_PLUGINS_DIR, ""),
        ScanDirectory(AUTO_LOADER_SYSTEM_PLUGINS_DIR, AUTO_LOADER_SYSTEM_PLUGINS_NO_INCLUDE)
    )
    
    currentLayers := MergeWithPriority(
        [], ; No user layers folder anymore
        ScanDirectory(AUTO_LOADER_SYSTEM_LAYERS_DIR, AUTO_LOADER_SYSTEM_LAYERS_NO_INCLUDE)
    )
    
    ; Get hardcoded includes (needed for filtering)
    hardcoded := GetHardcodedIncludes()
    hardcodedPlugins := hardcoded["plugins"]
    hardcodedLayers := hardcoded["layers"]
    
    ; Detect changes
    changes := DetectChanges(memory, currentPlugins, currentLayers)
    
    ; Apply changes if any
    if (changes["hasChanges"]) {
        OutputDebug("[AutoLoader] Changes detected, updating init.ahk...")
        
        ; Filter out hardcoded files before applying changes
        filteredPlugins := []
        for plugin in currentPlugins {
            if (!hardcodedPlugins.Has(plugin["name"])) {
                filteredPlugins.Push(plugin)
            }
        }
        
        filteredLayers := []
        for layer in currentLayers {
            if (!hardcodedLayers.Has(layer["name"])) {
                filteredLayers.Push(layer)
            }
        }
        
        ApplyChanges(changes, filteredPlugins, filteredLayers)
        
        ; Save new memory (with filtered lists)
        SaveAutoLoaderMemory(filteredPlugins, filteredLayers)
        
        OutputDebug("[AutoLoader] Changes applied successfully")
        
        ; Show notification (if tooltip functions are available)
        try {
            if (IsSet(tooltipConfig) && tooltipConfig.enabled && IsSet(ShowCSharpStatusNotification)) {
                ShowCSharpStatusNotification("AUTO-LOADER", "Files updated - Reload required")
            }
        } catch {
            ; Ignore if tooltip functions not available yet
        }
    } else {
        OutputDebug("[AutoLoader] No changes detected")
    }
    
    ; Always generate/update layer registry (even if no file changes)
    GenerateLayerRegistry(currentLayers)
}

; ===================================================================
; MEMORY MANAGEMENT (JSON)
; ===================================================================

LoadAutoLoaderMemory() {
    global AUTO_LOADER_MEMORY_FILE
    
    if (!FileExist(AUTO_LOADER_MEMORY_FILE)) {
        OutputDebug("[AutoLoader] No memory file found, creating new")
        return Map("plugins", [], "layers", [], "version", "1.0")
    }
    
    try {
        content := FileRead(AUTO_LOADER_MEMORY_FILE)
        memory := Jxon_Load(&content)
        OutputDebug("[AutoLoader] Memory loaded: " . memory["plugins"].Length . " plugins, " . memory["layers"].Length . " layers")
        return memory
    } catch as loadErr {
        OutputDebug("[AutoLoader] Error loading memory: " . loadErr.Message)
        return Map("plugins", [], "layers", [], "version", "1.0")
    }
}

SaveAutoLoaderMemory(plugins, layers) {
    global AUTO_LOADER_MEMORY_FILE
    
    ; Ensure data directory exists
    dataDir := A_ScriptDir . "\data"
    if (!DirExist(dataDir)) {
        DirCreate(dataDir)
    }
    
    memory := Map(
        "plugins", plugins,
        "layers", layers,
        "version", "1.0",
        "lastUpdate", A_Now
    )
    
    try {
        jsonContent := Jxon_Dump(memory, 4)
        FileDelete(AUTO_LOADER_MEMORY_FILE)
        FileAppend(jsonContent, AUTO_LOADER_MEMORY_FILE)
        OutputDebug("[AutoLoader] Memory saved successfully")
    } catch as saveErr {
        OutputDebug("[AutoLoader] Error saving memory: " . saveErr.Message)
    }
}

; ===================================================================
; DIRECTORY SCANNING
; ===================================================================

EnsureNoIncludeDirectories() {
    global AUTO_LOADER_SYSTEM_PLUGINS_NO_INCLUDE, AUTO_LOADER_SYSTEM_LAYERS_NO_INCLUDE
    
    if (!DirExist(AUTO_LOADER_SYSTEM_PLUGINS_NO_INCLUDE)) {
        DirCreate(AUTO_LOADER_SYSTEM_PLUGINS_NO_INCLUDE)
        OutputDebug("[AutoLoader] Created: " . AUTO_LOADER_SYSTEM_PLUGINS_NO_INCLUDE)
    }
    
    if (!DirExist(AUTO_LOADER_SYSTEM_LAYERS_NO_INCLUDE)) {
        DirCreate(AUTO_LOADER_SYSTEM_LAYERS_NO_INCLUDE)
        OutputDebug("[AutoLoader] Created: " . AUTO_LOADER_SYSTEM_LAYERS_NO_INCLUDE)
    }
}

; ===================================================================
; MERGE WITH PRIORITY (Neovim-style)
; ===================================================================

MergeWithPriority(userFiles, systemFiles) {
    ; User files have priority over system files
    ; If a file with the same name exists in both, only the user version is included
    
    merged := []
    userFileNames := Map()
    
    ; First, add all user files and track their names
    for userFile in userFiles {
        merged.Push(userFile)
        userFileNames[userFile["name"]] := true
        OutputDebug("[AutoLoader] Priority: USER file '" . userFile["name"] . "' from " . userFile["path"])
    }
    
    ; Then, add system files only if not overridden by user
    for systemFile in systemFiles {
        if (!userFileNames.Has(systemFile["name"])) {
            merged.Push(systemFile)
            OutputDebug("[AutoLoader] Including SYSTEM file '" . systemFile["name"] . "' from " . systemFile["path"])
        } else {
            OutputDebug("[AutoLoader] Skipping SYSTEM file '" . systemFile["name"] . "' (overridden by user)")
        }
    }
    
    return merged
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
        if (excludePath != "" && InStr(fullPath, excludePath)) {
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
; DETECT HARDCODED INCLUDES
; ===================================================================

GetHardcodedIncludes() {
    global AUTO_LOADER_INIT_FILE, AUTO_LOADER_PLUGINS_MARKER_START, AUTO_LOADER_LAYERS_MARKER_START
    
    hardcodedPlugins := Map()
    hardcodedLayers := Map()
    
    if (!FileExist(AUTO_LOADER_INIT_FILE))
        return Map("plugins", hardcodedPlugins, "layers", hardcodedLayers)
    
    content := FileRead(AUTO_LOADER_INIT_FILE)
    lines := StrSplit(content, "`n")
    
    inPluginsSection := false
    inLayersSection := false
    inAutoLoadedSection := false
    
    for line in lines {
        trimmed := Trim(line)
        
        ; Detect sections
        if (InStr(trimmed, "Plugins (funciones reutilizables")) {
            inPluginsSection := true
            inLayersSection := false
            continue
        }
        if (InStr(trimmed, AUTO_LOADER_PLUGINS_MARKER_START)) {
            inAutoLoadedSection := true
            inPluginsSection := false
            continue
        }
        if (InStr(trimmed, "Layers & Leader")) {
            inLayersSection := true
            inPluginsSection := false
            inAutoLoadedSection := false
            continue
        }
        if (InStr(trimmed, AUTO_LOADER_LAYERS_MARKER_START)) {
            inAutoLoadedSection := true
            inLayersSection := false
            continue
        }
        if (InStr(trimmed, "===== AUTO-LOADED") && InStr(trimmed, "END =====")) {
            inAutoLoadedSection := false
            continue
        }
        
        ; Skip auto-loaded sections
        if (inAutoLoadedSection)
            continue
        
        ; Extract hardcoded includes
        if (InStr(trimmed, "#Include") && !InStr(trimmed, ";")) {
            if (RegExMatch(trimmed, "#Include\s+(.+)", &match)) {
                path := Trim(match[1])
                filename := ""
                
                ; Extract filename from path
                if (InStr(path, "\")) {
                    parts := StrSplit(path, "\")
                    filename := parts[parts.Length]
                } else {
                    filename := path
                }
                
                ; Categorize by section
                if (inPluginsSection && InStr(path, "plugins")) {
                    hardcodedPlugins[filename] := true
                    OutputDebug("[AutoLoader] Hardcoded plugin detected: " . filename)
                } else if (inLayersSection && InStr(path, "layer")) {
                    ; Special case: leader_router is now core, ignore it if found
                    if (!InStr(filename, "leader_router")) {
                        hardcodedLayers[filename] := true
                        OutputDebug("[AutoLoader] Hardcoded layer detected: " . filename)
                    }
                }
            }
        }
    }
    
    return Map("plugins", hardcodedPlugins, "layers", hardcodedLayers)
}

; ===================================================================
; CHANGE DETECTION
; ===================================================================

DetectChanges(memory, currentPlugins, currentLayers) {
    ; Get hardcoded includes to exclude from auto-loading
    hardcoded := GetHardcodedIncludes()
    hardcodedPlugins := hardcoded["plugins"]
    hardcodedLayers := hardcoded["layers"]
    
    changes := Map(
        "hasChanges", false,
        "newPlugins", [],
        "removedPlugins", [],
        "newLayers", [],
        "removedLayers", []
    )
    
    ; Convert memory arrays to maps for easier lookup
    memoryPluginsMap := Map()
    if (memory.Has("plugins")) {
        for item in memory["plugins"] {
            memoryPluginsMap[item["name"]] := true
        }
    }
    
    memoryLayersMap := Map()
    if (memory.Has("layers")) {
        for item in memory["layers"] {
            memoryLayersMap[item["name"]] := true
        }
    }
    
    ; Detect new plugins (exclude hardcoded)
    for plugin in currentPlugins {
        ; Skip if hardcoded manually in init.ahk
        if (hardcodedPlugins.Has(plugin["name"])) {
            OutputDebug("[AutoLoader] Skipping hardcoded plugin: " . plugin["name"])
            continue
        }
        
        if (!memoryPluginsMap.Has(plugin["name"])) {
            changes["newPlugins"].Push(plugin)
            changes["hasChanges"] := true
        }
    }
    
    ; Detect removed plugins
    if (memory.Has("plugins")) {
        currentPluginsMap := Map()
        for plugin in currentPlugins {
            currentPluginsMap[plugin["name"]] := true
        }
        
        for item in memory["plugins"] {
            if (!currentPluginsMap.Has(item["name"])) {
                changes["removedPlugins"].Push(item)
                changes["hasChanges"] := true
            }
        }
    }
    
    ; Detect new layers (exclude hardcoded)
    for layer in currentLayers {
        ; Skip if hardcoded manually in init.ahk
        if (hardcodedLayers.Has(layer["name"])) {
            OutputDebug("[AutoLoader] Skipping hardcoded layer: " . layer["name"])
            continue
        }
        
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
        OutputDebug("  New plugins: " . changes["newPlugins"].Length)
        OutputDebug("  Removed plugins: " . changes["removedPlugins"].Length)
        OutputDebug("  New layers: " . changes["newLayers"].Length)
        OutputDebug("  Removed layers: " . changes["removedLayers"].Length)
    }
    
    return changes
}

; ===================================================================
; APPLY CHANGES TO init.ahk
; ===================================================================

ApplyChanges(changes, currentPlugins, currentLayers) {
    global AUTO_LOADER_INIT_FILE
    
    ; Read current init.ahk
    if (!FileExist(AUTO_LOADER_INIT_FILE)) {
        OutputDebug("[AutoLoader] ERROR: init.ahk not found!")
        return
    }
    
    content := FileRead(AUTO_LOADER_INIT_FILE)
    
    ; Update plugins section
    content := UpdateSection(
        content,
        AUTO_LOADER_PLUGINS_MARKER_START,
        AUTO_LOADER_PLUGINS_MARKER_END,
        GenerateIncludes(currentPlugins)
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
    } catch as updateErr {
        OutputDebug("[AutoLoader] ERROR updating init.ahk: " . updateErr.Message)
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
    
    ; Extract plugins array
    if (RegExMatch(src, '"plugins":\s*\[(.*?)\]', &matchPlugins)) {
        result["plugins"] := ParseJsonArray(matchPlugins[1])
    } else {
        result["plugins"] := []
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
    
    ; Plugins array
    output .= '`n  "plugins": ['
    if (obj["plugins"].Length > 0) {
        for item in obj["plugins"] {
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

; ===================================================================
; LAYER REGISTRY SYSTEM
; ===================================================================

GenerateLayerRegistry(allLayers) {
    global AUTO_LOADER_LAYER_REGISTRY_FILE
    
    OutputDebug("[LayerRegistry] Generating layer registry...")
    
    ; Ensure data directory exists
    dataDir := A_ScriptDir . "\data"
    if (!DirExist(dataDir)) {
        DirCreate(dataDir)
    }
    
    ; Create registry content
    registryContent := "; ===================================================================`n"
    registryContent .= "; Layer Registry - Auto-generated by Auto Loader`n"
    registryContent .= "; Maps short layer names to their .ahk files`n"
    registryContent .= "; Usage: SwitchToLayer(`"visual`", `"nvim`")`n"
    registryContent .= "; ===================================================================`n`n"
    registryContent .= "[Layers]`n"
    
    ; Create a Map to avoid duplicates
    layerMap := Map()
    
    ; Get hardcoded layers to include them in registry
    hardcoded := GetHardcodedIncludes()
    hardcodedLayers := hardcoded["layers"]
    
    ; Process hardcoded layers first (from init.ahk)
    for layerFile in hardcodedLayers {
        if (InStr(layerFile, "_layer.ahk")) {
            layerName := ExtractLayerNameFromFile(layerFile)
            if (layerName != "") {
                relativePath := "system\\layers\\" . layerFile
                layerMap[layerName] := relativePath
                OutputDebug("[LayerRegistry] Added hardcoded layer: " . layerName . " -> " . relativePath)
            }
        }
    }
    
    ; Process auto-discovered layers (only if not already in map from hardcoded)
    for layer in allLayers {
        if (InStr(layer["name"], "_layer.ahk")) {
            layerName := ExtractLayerNameFromFile(layer["name"])
            if (layerName != "" && !layerMap.Has(layerName)) {
                layerMap[layerName] := layer["path"]
                OutputDebug("[LayerRegistry] Added auto-discovered layer: " . layerName . " -> " . layer["path"])
            } else if (layerName != "" && layerMap.Has(layerName)) {
                OutputDebug("[LayerRegistry] Skipped duplicate layer: " . layerName . " (already exists)")
            }
        }
    }
    
    ; Write all unique layers to registry
    for layerName, layerPath in layerMap {
        registryContent .= layerName . "=" . layerPath . "`n"
    }
    
    ; Write registry file
    try {
        FileDelete(AUTO_LOADER_LAYER_REGISTRY_FILE)
        FileAppend(registryContent, AUTO_LOADER_LAYER_REGISTRY_FILE)
        OutputDebug("[LayerRegistry] Registry generated successfully at: " . AUTO_LOADER_LAYER_REGISTRY_FILE)
    } catch as registryErr {
        OutputDebug("[LayerRegistry] ERROR generating registry: " . registryErr.Message)
    }
}

ExtractLayerNameFromFile(filename) {
    ; Convert "nvim_layer.ahk" to "nvim"
    ; Convert "visual_layer.ahk" to "visual"
    if (RegExMatch(filename, "^(.+)_layer\.ahk$", &match)) {
        return match[1]
    }
    return ""
}


