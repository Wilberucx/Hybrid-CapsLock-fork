; ==============================
; Kanata Launcher Module
; ==============================
; Inicia, detiene y reinicia Kanata
; Scripts VBS ubicados en: system/core/kanata/

; ---- Configuración ----
global KanataStartDelay := 500  ; ms de espera después de lanzar Kanata

; ---- Rutas de scripts VBS ----
GetKanataScriptPath(scriptName) {
    return A_ScriptDir . "\system\core\kanata\" . scriptName
}

; ---- Función: Iniciar Kanata si no está corriendo ----
StartKanataIfNeeded() {
    global KanataStartDelay
    
    startVBS := GetKanataScriptPath("start_kanata.vbs")
    
    ; Verificar que el archivo VBS existe
    if (!FileExist(startVBS)) {
        ; Silencioso: si no existe, continuar sin Kanata
        return false
    }
    
    ; Verificar si Kanata ya está corriendo
    if (ProcessExist("kanata.exe")) {
        ; Ya está corriendo, no hacer nada
        return true
    }
    
    ; Lanzar Kanata (oculto vía VBS)
    try {
        Run(startVBS)
        Sleep(KanataStartDelay)
        return true
    } catch as e {
        ; Error silencioso, continuar sin Kanata
        return false
    }
}

; ---- Función: Detener Kanata ----
StopKanata() {
    stopVBS := GetKanataScriptPath("stop_kanata.vbs")
    
    if (!FileExist(stopVBS)) {
        return false
    }
    
    try {
        Run(stopVBS)
        Sleep(300)
        return true
    } catch {
        return false
    }
}

; ---- Función: Reiniciar Kanata ----
RestartKanata() {
    global KanataStartDelay
    
    restartVBS := GetKanataScriptPath("restart_kanata.vbs")
    
    if (!FileExist(restartVBS)) {
        ; Fallback: stop + start manual
        StopKanata()
        Sleep(500)
        return StartKanataIfNeeded()
    }
    
    try {
        Run(restartVBS)
        Sleep(KanataStartDelay)
        return true
    } catch {
        return false
    }
}

; ---- Función: Verificar si Kanata está corriendo ----
IsKanataRunning() {
    return ProcessExist("kanata.exe") ? true : false
}

; ==============================
; NOTA: Este módulo SOLO maneja Kanata
; Las funciones de Reload/Exit de HybridCapsLock están en commands_layer.ahk
; ==============================
