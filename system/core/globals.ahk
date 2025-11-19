; ==============================
; Core global variables
; ==============================
; Define global state early so any included module can use them safely

; ---- Layer runtime states ----
global isNvimLayerActive := false

; Hybrid pause state
global hybridPauseActive := false

global _tempEditMode := false
global VisualMode := false

; Leader state flag
global leaderActive := false

; Other runtime flags
global excelLayerActive := false
; Default: enable static Excel hotkeys unless dynamic mappings disable them
global excelStaticEnabled := true
global rightClickHeld := false
global scrollModeActive := false
global _yankAwait := false
global _deleteAwait := false

; Temporary status tracking (UI)
global currentTempStatus := ""
global tempStatusExpiry := 0

; ---- Static mapping toggles for dynamic override ----
global nvimStaticEnabled := true

; ===============================
; DEBUG SYSTEM - LEGACY COMPATIBILITY
; ===============================
; NOTA: El sistema de debug se ha movido a system/core/Debug_log.ahk
; Estas funciones se mantienen por compatibilidad, pero redirigen al nuevo sistema
; Se recomienda usar las nuevas funciones: LogDebug(), LogInfo(), LogError()
; O mejor aún, usar la nueva API: Log.d(), Log.i(), Log.e()

; Include del nuevo sistema de debug centralizado
#Include %A_ScriptDir%\system\core\Debug_log.ahk

; Debug flag - controls development logging (mantenido para compatibilidad)
global debug_mode := false

; Funciones de compatibilidad - redirigen al nuevo sistema
DebugLog(message, category := "DEBUG") {
    LogDebug(message, category)
}

InfoLog(message, category := "INFO") {
    LogInfo(message, category)
}

ErrorLog(message, category := "ERROR") {
    LogError(message, category)
}

; Sincronizar debug_mode con el nuevo sistema cuando se cargue la configuración
SyncDebugMode() {
    global debug_mode
    ; Sincronizar con el nuevo sistema de logging
    debug_mode := Log.IsEnabled(LogLevel.DEBUG)
}
