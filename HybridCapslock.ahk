; ===================================================================
; HybridCapsLock - Main Entry Point
; ===================================================================
; This is the MAIN FILE to execute HybridCapsLock.
; 
; What this file does:
; 1. Verifies that all dependencies are installed (AutoHotkey, Kanata, config files)
; 2. Shows helpful error messages if dependencies are missing
; 3. Launches the main application (init.ahk) if everything is OK
; 
; Usage:
; - Execute this file to start HybridCapsLock
; - If dependencies are missing, helpful dialogs will guide you
; - The actual application logic is in init.ahk
; - This file exits after launching init.ahk
; ===================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All

; ===================================================================
; MAIN EXECUTION
; ===================================================================

try {
    OutputDebug("[HybridCapsLock] Starting dependency check...")
    
    ; Load dependency checker (from system/core)
    #Include system\core\dependency_checker.ahk
    
    ; Check all dependencies before proceeding
    if (!CheckDependencies()) {
        OutputDebug("[HybridCapsLock] Dependency check failed, exiting...")
        ExitApp(1)
    }
    
    OutputDebug("[HybridCapsLock] Dependencies OK, launching main application...")
    
    ; Run Auto-Loader to update init.ahk with new layers/actions
    OutputDebug("[HybridCapsLock] Running Auto-Loader...")
    #Include system\core\auto_loader.ahk
    AutoLoaderInit()
    
    ; Launch the main application (init.ahk)
    if (FileExist("init.ahk")) {
        OutputDebug("[HybridCapsLock] Launching init.ahk...")
        Run('"' . A_AhkPath . '" "' . A_ScriptDir . '\init.ahk"')
        OutputDebug("[HybridCapsLock] Main application launched successfully")
    } else {
        MsgBox("Error: init.ahk not found!`n`nPath: " . A_ScriptDir . "\init.ahk", "HybridCapsLock - File Missing", "Icon!")
        OutputDebug("[HybridCapsLock] ERROR: init.ahk not found")
        ExitApp(1)
    }
    
    ; HybridCapslock.ahk exits after launching init.ahk
    OutputDebug("[HybridCapsLock] Startup verification complete, exiting...")
    ExitApp(0)
    
} catch as err {
    OutputDebug("[HybridCapsLock] ERROR: " . err.Message)
    MsgBox("HybridCapsLock startup failed:`n" . err.Message, "HybridCapsLock Error", "OK Icon!")
    ExitApp(1)
}

