; ==============================
; Network Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE RED
; ==============================

ShowIPConfig() {
    Run("cmd.exe /k ipconfig /all")
}

PingGoogle() {
    Run("cmd.exe /k ping google.com")
}

ShowNetstat() {
    Run("cmd.exe /k netstat -an")
}

; ==============================
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterNetworkKeymaps() {
    RegisterKeymap("network", "i", "IP Config", Func("ShowIPConfig"), false)
    RegisterKeymap("network", "p", "Ping Google", Func("PingGoogle"), false)
    RegisterKeymap("network", "n", "Netstat", Func("ShowNetstat"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
