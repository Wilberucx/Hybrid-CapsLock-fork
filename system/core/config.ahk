; ==============================
; Core configuration
; ==============================
; Helpers to load configuration from HybridConfig (config/settings.ahk)
; Depends on globals declared in src/core/globals.ahk

; ---- Load emergency/behavior flags from configuration ----
LoadLayerFlags() {
    global hybridPauseMinutes, enableEmergencyResumeHotkey
    global HybridConfig
    
    hybridPauseMinutes := HybridConfig.behavior.emergency.hybrid_pause_minutes
    enableEmergencyResumeHotkey := HybridConfig.behavior.emergency.enable_emergency_resume_hotkey
}

; ---- Get timeout for InputHook operations ----
GetEffectiveTimeout(layer) {
    global HybridConfig
    ; All layers use the same timeout (leader timeout)
    return HybridConfig.behavior.timeouts.leader
}
