; ===================================================================
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
#Include system\core\auto_loader.ahk
#Include system\core\kanata_launcher.ahk
#Include system\core\globals.ahk
#Include system\core\config.ahk
#Include system\core\keymap_registry.ahk



; ===== AUTO-LOADED ACTIONS START =====
#Include system\actions\adb_actions.ahk
#Include system\actions\folder_actions.ahk
#Include system\actions\git_actions.ahk
#Include system\actions\hybrid_actions.ahk
#Include system\actions\monitoring_actions.ahk
#Include system\actions\network_actions.ahk
#Include system\actions\power_actions.ahk
#Include system\actions\scroll_actions.ahk
#Include system\actions\sendinfo_actions.ahk
#Include system\actions\shell_exec_actions.ahk
#Include system\actions\system_actions.ahk
#Include system\actions\timestamp_actions.ahk
#Include system\actions\vaultflow_actions.ahk
#Include system\actions\vim_edit.ahk
#Include system\actions\vim_nav.ahk
#Include system\actions\vim_visual.ahk
; ===== AUTO-LOADED ACTIONS END =====

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
#Include system\ui\scroll_tooltip_integration.ahk

; ===== AUTO-LOADED LAYERS START =====
#Include system\layers\excel_layer.ahk
#Include system\layers\insert_layer.ahk
#Include system\layers\leader_router.ahk
#Include system\layers\nvim_layer.ahk
#Include system\layers\scroll_layer.ahk
#Include system\layers\visual_layer.ahk
; ===== AUTO-LOADED LAYERS END =====

; --------------------
; Startup logic
; --------------------
try {
    ; Auto-loader already executed by HybridCapslock.ahk preprocessor
    
    ; Start Kanata first (if it exists)
    StartKanataIfNeeded()
    
    ; Registrar keymaps (Fase 2 - Sistema Declarativo)
    ; ELIMINADO: ahora se maneja desde InitializeCategoryKeymaps()
    
    ; Configuration loaded via #Include directives above
    ; HybridConfig is now global from settings.ahk
    if (IsSet(HybridConfig)) {
        LogInfo("Config loaded from: ahk", "INIT")
        
        ; Inicializar el sistema de debug centralizado
        InitDebugSystem()
        
        ; Sincronizar con el sistema legacy
        SyncDebugMode()
        
        LogInfo("HybridCapsLock v" . HybridConfig.app.version . " iniciado correctamente", "INIT")
    } else {
        LogError("Config not loaded, will use INI fallback", "INIT")
    }
    
    ; Luego cargar configuración de AHK
    LoadLayerFlags()
    StartTooltipApp()  ; Start C# tooltip application
} catch {
}

; --------------------
; Minimal startup to confirm no errors
; --------------------
; NOTA: SetCapsLockState desactivado - Kanata maneja CapsLock ahora
; try {
;     SetCapsLockState("AlwaysOff")
; } catch {
;     ; Ignorar si no se puede ajustar el estado de CapsLock en este entorno
; }

; Initialize Category Keymaps (Sistema de categorías jerárquico)
InitializeCategoryKeymaps()

; Startup welcome (C# only)
try {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ShowWelcomeStatusCS()
    }
} catch {
}
