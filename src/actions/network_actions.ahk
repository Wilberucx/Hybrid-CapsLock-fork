; ==============================
; Network Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

ShowIPConfig() {
    Run("cmd.exe /k ipconfig /all")
    ShowCommandExecuted("Network", "IP Config")
}

PingGoogle() {
    Run("cmd.exe /k ping google.com")
    ShowCommandExecuted("Network", "Ping Test")
}

ShowNetstat() {
    Run("cmd.exe /k netstat -an")
    ShowCommandExecuted("Network", "Netstat")
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterNetworkKeymaps() {
    RegisterKeymap("network", "i", "IP Config", ShowIPConfig, false, 1)
    RegisterKeymap("network", "p", "Ping Google", PingGoogle, false, 2)
    RegisterKeymap("network", "n", "Netstat", ShowNetstat, false, 3)
}
