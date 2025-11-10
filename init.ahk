; ===================================================================
; HybridCapsLock Orchestrator (Modular)
; ===================================================================
#Requires AutoHotkey v2.0
#SingleInstance Force
#Warn All
; --------------------
; Core
; --------------------
#Include src\core\kanata_launcher.ahk
#Include src\core\globals.ahk
#Include src\core\config.ahk
#Include src\core\persistence.ahk
#Include src\core\confirmations.ahk
#Include src\core\keymap_registry.ahk
#Include src\core\mappings.ahk
#Include src\core\auto_loader.ahk

; --------------------
; Actions (funciones reutilizables - sistema declarativo)
; --------------------
; Core actions (reutilizables en múltiples capas)
#Include src\actions\vim_nav.ahk
#Include src\actions\vim_visual.ahk
#Include src\actions\vim_edit.ahk

; Actions específicas por dominio
#Include src\actions\hybrid_actions.ahk
#Include src\actions\system_actions.ahk
#Include src\actions\network_actions.ahk
#Include src\actions\git_actions.ahk
#Include src\actions\monitoring_actions.ahk
#Include src\actions\folder_actions.ahk
#Include src\actions\power_actions.ahk
#Include src\actions\adb_actions.ahk
#Include src\actions\vaultflow_actions.ahk
#Include src\actions\timestamp_actions.ahk
#Include src\actions\shell_exec_actions.ahk


; ===== AUTO-LOADED ACTIONS START =====
#Include src\actions\nvim_layer_helpers.ahk
#Include src\actions\program_actions.ahk
; ===== AUTO-LOADED ACTIONS END =====

#Include config\keymap.ahk

; --------------------
; UI
; --------------------
#Include src\\ui\\tooltip_csharp_integration.ahk
#Include src\\ui\\tooltips_native_wrapper.ahk
#Include src\\ui\\scroll_tooltip_integration.ahk

; --------------------
; Layers & Leader
; --------------------
#Include src\layer\leader_router.ahk
#Include src\layer\timestamps_layer.ahk
#Include src\layer\information_layer.ahk
#Include src\layer\excel_layer.ahk
#Include src\layer\nvim_layer.ahk
#Include src\layer\scroll_layer.ahk

; ===== AUTO-LOADED LAYERS START =====
#Include src\layer\insert_layer.ahk
#Include src\layer\visual_layer.ahk
; ===== AUTO-LOADED LAYERS END =====

; --------------------
; Startup logic
; --------------------
try {
    ; Run auto-loader to detect new files (before anything else)
    AutoLoaderInit()
    
    ; Iniciar Kanata primero (si existe)
    StartKanataIfNeeded()
    
    ; Registrar keymaps (Fase 2 - Sistema Declarativo)
    ; ELIMINADO: ahora se maneja desde InitializeCategoryKeymaps()
    
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
