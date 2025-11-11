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
; DEBUG SYSTEM
; ===============================
; Debug flag - controls development logging
; Updated from HybridConfig.app.debug_mode after config loads
global debug_mode := false

; Debug logging function - only logs if debug_mode is enabled
DebugLog(message, category := "DEBUG") {
    global debug_mode
    if (debug_mode) {
        OutputDebug("[" . category . "] " . message . "`n")
    }
}

; Always log (regardless of debug_mode) - for critical messages
InfoLog(message, category := "INFO") {
    OutputDebug("[" . category . "] " . message . "`n")
}

; Error logging (always shown)
ErrorLog(message, category := "ERROR") {
    OutputDebug("[" . category . "] " . message . "`n")
}

; Persistence master flag (can be overwritten by LoadLayerFlags)
global enableLayerPersistence := true
