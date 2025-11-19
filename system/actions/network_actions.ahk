; ==============================
; Network Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
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
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → n (Network) → key
; RegisterNetworkKeymaps() {
;     RegisterKeymap("c", "n", "i", "IP Config", ShowIPConfig, false, 1)
;     RegisterKeymap("c", "n", "p", "Ping Google", PingGoogle, false, 2)
;     RegisterKeymap("c", "n", "n", "Netstat", ShowNetstat, false, 3)
; }
