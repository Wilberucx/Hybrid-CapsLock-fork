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
global capsLockWasHeld := false
global capsLockUsedAsModifier := false
; Tap detection for CapsLock (to toggle Nvim only on quick tap)
global capsTapThresholdMs := 250  ; configurable via configuration.ini [Behavior].nvim_tap_threshold_ms
global rightClickHeld := false
global scrollModeActive := false
global _yankAwait := false
global _deleteAwait := false
global capsActsNormal := false

; Temporary status tracking (UI)
global currentTempStatus := ""
global tempStatusExpiry := 0

; ---- Layer enable flags (safe defaults) ----
global nvimLayerEnabled := true
global excelLayerEnabled := true
global modifierLayerEnabled := true
; Default: enable static Modifier hotkeys unless dynamic mappings disable them
global modifierStaticEnabled := true
global leaderLayerEnabled := true

; Static mapping toggles for dynamic override
global nvimStaticEnabled := true

; Debug flag (loaded from configuration.ini [General].debug_mode)
global debug_mode := false

; Persistence master flag (can be overwritten by LoadLayerFlags)
global enableLayerPersistence := true

; ---- Helper: mark CapsLock usage as modifier ----
MarkCapsLockAsModifier() {
    global capsLockUsedAsModifier
    capsLockUsedAsModifier := true
}
