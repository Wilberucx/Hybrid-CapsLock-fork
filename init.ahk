; HybridCapsLock - Main Application (init.ahk)
; ===================================================================
; Like Neovim's init.lua, this is the main configuration file.
; Execute HybridCapslock.ahk to start the application.
; 
; Structure (Neovim-inspired):
; - ahk/        - Your custom config (like lua/ in Neovim)
; - system/     - Core system files (auto-updateable)
; - init.ahk    - Main config file (this file, editable)
; 
; The auto-loader searches in this order:
; 1. ahk/ (user files have priority)
; 2. system/ (system defaults)
; ===================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All

; --------------------
; Core System (from system/)
; --------------------
#Include system\core\globals.ahk
#Include system\core\config.ahk
#Include system\core\keymap_registry.ahk
#Include system\core\layer_manager.ahk
#Include system\core\auto_loader.ahk
#Include system\core\leader_router.ahk



; ===== AUTO-LOADED PLUGINS START =====
#Include system\plugins\context_utils.ahk
#Include system\plugins\dynamic_layer.ahk
#Include system\plugins\hybrid_actions.ahk
#Include system\plugins\kanata_manager.ahk
#Include system\plugins\shell_exec.ahk
#Include system\plugins\welcome_screen.ahk
; ===== AUTO-LOADED PLUGINS END =====

; --------------------
; User Config (from ahk/)
; --------------------
#Include ahk\config\colorscheme.ahk
#Include ahk\config\settings.ahk
#Include ahk\config\keymap.ahk

; --------------------
; UI System (from system/)
; --------------------
#Include system\ui\tooltip_csharp_integration.ahk
#Include system\ui\tooltips_native_wrapper.ahk

; ===== AUTO-LOADED LAYERS START =====
; (No auto-loaded files)
; ===== AUTO-LOADED LAYERS END =====

; --------------------
; Startup logic
; --------------------
try {
    if (IsSet(HybridConfig)) {
        LogInfo("Config loaded from: ahk", "INIT")
        
        InitDebugSystem()
        
        SyncDebugMode()
        
        LogInfo("HybridCapsLock v" . HybridConfig.app.version . " iniciado correctamente", "INIT")
    } else {
        LogError("Config not loaded, will use INI fallback", "INIT")
    }
    
    LoadLayerFlags()
    StartTooltipApp()  ; Start C# tooltip application
} catch {
}

try {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ; Schedule welcome screen to avoid startup race conditions
        ; SetTimer(ShowWelcomeScreen, -1000)
    }
} catch {
}
