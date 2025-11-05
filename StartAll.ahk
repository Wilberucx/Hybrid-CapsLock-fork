; ==============================
; StartAll.ahk - Launcher Maestro
; ==============================
; Inicia Kanata y HybridCapsLock automáticamente
; Uso: Ejecuta este script para lanzar todo el sistema

#Requires AutoHotkey v2.0
#SingleInstance Force

; ---- Configuración ----
global KanataStartDelay := 500  ; ms de espera después de lanzar Kanata
global ShowNotifications := true ; Mostrar mensajes de inicio

; ---- Detectar rutas ----
scriptDir := A_ScriptDir
kanataVBS := scriptDir . "\start_kanata.vbs"
hybridAHK := scriptDir . "\HybridCapsLock.ahk"

; ---- Verificar archivos necesarios ----
if (!FileExist(kanataVBS)) {
    MsgBox("ERROR: No se encontró start_kanata.vbs`n`nRuta esperada:`n" . kanataVBS, "StartAll Error", "Icon!")
    ExitApp
}

if (!FileExist(hybridAHK)) {
    MsgBox("ERROR: No se encontró HybridCapsLock.ahk`n`nRuta esperada:`n" . hybridAHK, "StartAll Error", "Icon!")
    ExitApp
}

; ---- Verificar si Kanata ya está corriendo ----
if (ProcessExist("kanata.exe")) {
    if (ShowNotifications) {
        result := MsgBox("Kanata ya está corriendo.`n`n¿Reiniciarlo?", "StartAll", "YesNo Icon?")
        if (result = "Yes") {
            ProcessClose("kanata.exe")
            Sleep(300)
        } else {
            goto SkipKanata
        }
    }
}

; ---- Lanzar Kanata (oculto vía VBS) ----
try {
    Run(kanataVBS, scriptDir)
    if (ShowNotifications)
        TrayTip("Kanata iniciado", "Esperando " . KanataStartDelay . "ms antes de lanzar AHK...", "Iconi Mute")
    Sleep(KanataStartDelay)
} catch as err {
    MsgBox("ERROR al iniciar Kanata:`n" . err.Message, "StartAll Error", "Icon!")
    ExitApp
}

SkipKanata:

; ---- Verificar si HybridCapsLock ya está corriendo ----
if (ProcessExist("AutoHotkey64.exe") || ProcessExist("AutoHotkey32.exe")) {
    ; Revisar si algún proceso AHK está ejecutando HybridCapsLock.ahk
    detectString := WinGetList("ahk_exe AutoHotkey64.exe")
    Loop detectString.Length {
        try {
            title := WinGetTitle("ahk_id " . detectString[A_Index])
            if (InStr(title, "HybridCapsLock")) {
                if (ShowNotifications) {
                    result := MsgBox("HybridCapsLock ya está corriendo.`n`n¿Reiniciarlo?", "StartAll", "YesNo Icon?")
                    if (result = "Yes") {
                        WinClose("ahk_id " . detectString[A_Index])
                        Sleep(300)
                    } else {
                        goto SkipAHK
                    }
                }
                break
            }
        }
    }
}

; ---- Lanzar HybridCapsLock ----
try {
    Run(hybridAHK, scriptDir)
    if (ShowNotifications)
        TrayTip("Sistema iniciado", "Kanata + HybridCapsLock corriendo", "Iconi Mute")
    Sleep(1500)
    TrayTip() ; Ocultar tooltip
} catch as err {
    MsgBox("ERROR al iniciar HybridCapsLock:`n" . err.Message, "StartAll Error", "Icon!")
    ExitApp
}

SkipAHK:

; ---- Mensaje final ----
if (ShowNotifications) {
    MsgBox("✓ Sistema iniciado correctamente`n`n"
        . "• Kanata: Ejecutándose`n"
        . "• HybridCapsLock: Ejecutándose`n`n"
        . "Prueba:`n"
        . "  - Tap CapsLock → Nvim layer`n"
        . "  - Hold CapsLock + hjkl → Navegación`n"
        . "  - Hold CapsLock + Space → Leader menu",
        "StartAll - Éxito", "Iconi T3")
}

; ---- Salir (este script solo lanza los demás) ----
ExitApp
