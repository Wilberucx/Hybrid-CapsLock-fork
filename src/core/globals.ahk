; ==============================
; Core global variables
; ==============================
; Define global state and INI paths early so any included module can read/use them safely

; ---- INI paths ----
global ConfigIni := A_ScriptDir . "\\config\\configuration.ini"
global ProgramsIni := A_ScriptDir . "\\config\\programs.ini"
global TimestampsIni := A_ScriptDir . "\\config\\timestamps.ini"
global InfoIni := A_ScriptDir . "\\config\\information.ini"
global CommandsIni := A_ScriptDir . "\\config\\commands.ini"

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

; ---- Layer enable flags (safe defaults) ----
global nvimLayerEnabled := true
global excelLayerEnabled := true
global leaderLayerEnabled := true

; Static mapping toggles for dynamic override
global nvimStaticEnabled := true

; ===============================
; DEBUG SYSTEM - LEGACY COMPATIBILITY
; ===============================
; NOTA: El sistema de debug se ha movido a src/core/Debug_log.ahk
; Estas funciones se mantienen por compatibilidad, pero redirigen al nuevo sistema
; Se recomienda usar las nuevas funciones: LogDebug(), LogInfo(), LogError()
; O mejor aún, usar la nueva API: Log.d(), Log.i(), Log.e()

; Include del nuevo sistema de debug centralizado
#Include %A_ScriptDir%\src\core\Debug_log.ahk

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

; Persistence master flag (can be overwritten by LoadLayerFlags)
global enableLayerPersistence := true
