; ===================================================================
; HybridCapsLock - Main Application
; ===================================================================
; NOTE: This file is auto-updated by HybridCapslock.ahk
; Execute HybridCapslock.ahk instead of this file directly!
; 
; The auto-loader sections are managed automatically:
; - Files in src/actions/ and src/layer/ are auto-included
; - Files in no_include/ folders are ignored
; - Manual #Includes outside AUTO-LOADED sections are preserved
; ===================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All
; --------------------
; Core
; --------------------
#Include src\core\auto_loader.ahk
#Include src\core\kanata_launcher.ahk
#Include src\core\globals.ahk
#Include src\core\config_loader.ahk
#Include src\core\config.ahk
#Include src\core\persistence.ahk
; #Include src\core\confirmations.ahk  ; REMOVED: Replaced with simple keymap boolean system
#Include src\core\keymap_registry.ahk
#Include src\core\mappings.ahk



; ===== AUTO-LOADED ACTIONS START =====
#Include src\actions\adb_actions.ahk
#Include src\actions\folder_actions.ahk
#Include src\actions\git_actions.ahk
#Include src\actions\hybrid_actions.ahk
#Include src\actions\monitoring_actions.ahk
#Include src\actions\network_actions.ahk
#Include src\actions\nvim_layer_helpers.ahk
#Include src\actions\power_actions.ahk
#Include src\actions\sendinfo_actions.ahk
#Include src\actions\shell_exec_actions.ahk
#Include src\actions\system_actions.ahk
#Include src\actions\timestamp_actions.ahk
#Include src\actions\vaultflow_actions.ahk
#Include src\actions\vim_edit.ahk
#Include src\actions\vim_nav.ahk
#Include src\actions\vim_visual.ahk
; ===== AUTO-LOADED ACTIONS END =====

#Include config\colorscheme.ahk
#Include config\settings.ahk
#Include config\keymap.ahk

; --------------------
; UI
; --------------------
#Include src\\ui\\tooltip_csharp_integration.ahk
#Include src\\ui\\tooltips_native_wrapper.ahk
#Include src\\ui\\scroll_tooltip_integration.ahk

; ===== AUTO-LOADED LAYERS START =====
#Include src\layer\excel_layer.ahk
#Include src\layer\insert_layer.ahk
#Include src\layer\leader_router.ahk
#Include src\layer\nvim_layer.ahk
#Include src\layer\scroll_layer.ahk
#Include src\layer\visual_layer.ahk
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
        OutputDebug("[INIT] Config loaded from: ahk`n")
        
        ; Initialize debug_mode from HybridConfig
        global debug_mode
        debug_mode := HybridConfig.app.debug_mode
        if (debug_mode) {
            InfoLog("Debug mode ENABLED - verbose logging active", "INIT")
        }
    } else {
        OutputDebug("[INIT] Config not loaded, will use INI fallback`n")
    }
    
    ; Luego cargar configuración de AHK
    LoadLayerFlags()
    LoadLayerState()
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
