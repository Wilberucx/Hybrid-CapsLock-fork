; ===================================================================
; HybridCapsLock - Main Entry Point
; ===================================================================
; This is the MAIN FILE to execute HybridCapsLock.
; 
; What this file does:
; 1. Runs the auto-loader preprocessor to scan src/actions and src/layers
; 2. Updates init.ahk with the latest #Include statements
; 3. Launches the main application (init.ahk)
; 
; Usage:
; - Execute this file to start HybridCapsLock
; - The auto-loader will automatically detect new .ahk files
; - Files in no_include/ folders are ignored
; - Hardcoded #Includes in init.ahk are preserved
; ===================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All

; ===================================================================
; MAIN EXECUTION
; ===================================================================

try {
    OutputDebug("[HybridCapsLock] Starting auto-loader preprocessor...")
    
    ; Load auto-loader functions
    #Include src\core\auto_loader.ahk
    
    ; Run auto-loader to update init.ahk BEFORE execution
    AutoLoaderPreprocessor()
    
    OutputDebug("[HybridCapsLock] Auto-loader complete, launching main application...")
    
    ; Execute the main application
    Run(A_ScriptDir . "\init.ahk")
    
    ; Exit this launcher - the main application is now running
    ExitApp()
    
} catch as err {
    OutputDebug("[HybridCapsLock] ERROR: " . err.Message)
    MsgBox("HybridCapsLock startup failed:`n" . err.Message, "HybridCapsLock Error", "OK Icon!")
    ExitApp(1)
}

; ===================================================================
; AUTO-LOADER PREPROCESSOR
; ===================================================================

AutoLoaderPreprocessor() {
    global AUTO_LOADER_ENABLED
    
    if (!AUTO_LOADER_ENABLED) {
        OutputDebug("[AutoLoaderPreprocessor] Disabled by config")
        return
    }
    
    OutputDebug("[AutoLoaderPreprocessor] Starting scan...")
    
    ; Ensure no_include directories exist
    EnsureNoIncludeDirectories()
    
    ; Load memory (previously included files)
    memory := LoadAutoLoaderMemory()
    
    ; Scan current files
    currentActions := ScanDirectory(AUTO_LOADER_ACTIONS_DIR, AUTO_LOADER_ACTIONS_NO_INCLUDE)
    currentLayers := ScanDirectory(AUTO_LOADER_LAYERS_DIR, AUTO_LOADER_LAYERS_NO_INCLUDE)
    
    ; Get hardcoded includes (needed for filtering)
    hardcoded := GetHardcodedIncludes()
    hardcodedActions := hardcoded["actions"]
    hardcodedLayers := hardcoded["layers"]
    
    ; Detect changes
    changes := DetectChanges(memory, currentActions, currentLayers)
    
    ; Apply changes if any
    if (changes["hasChanges"]) {
        OutputDebug("[AutoLoaderPreprocessor] Changes detected, updating init.ahk...")
        
        ; Filter out hardcoded files before applying changes
        filteredActions := []
        for action in currentActions {
            if (!hardcodedActions.Has(action["name"])) {
                filteredActions.Push(action)
            }
        }
        
        filteredLayers := []
        for layer in currentLayers {
            if (!hardcodedLayers.Has(layer["name"])) {
                filteredLayers.Push(layer)
            }
        }
        
        ApplyChanges(changes, filteredActions, filteredLayers)
        
        ; Save new memory (with filtered lists)
        SaveAutoLoaderMemory(filteredActions, filteredLayers)
        
        OutputDebug("[AutoLoaderPreprocessor] Changes applied successfully")
        
    } else {
        OutputDebug("[AutoLoaderPreprocessor] No changes detected")
    }
    
    ; Always generate/update layer registry (even if no file changes)
    GenerateLayerRegistry(currentLayers)
    
    OutputDebug("[AutoLoaderPreprocessor] Preprocessing complete")
}