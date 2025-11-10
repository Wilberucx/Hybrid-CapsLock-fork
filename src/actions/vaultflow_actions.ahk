; ==============================
; VaultFlow Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

RunVaultFlow() {
    Run("powershell.exe -Command `"vaultflow`"")
}

VaultFlowStatus() {
    Run("cmd.exe /k vaultflow status")
}

VaultFlowList() {
    Run("cmd.exe /k vaultflow list")
}

VaultFlowHelp() {
    Run("cmd.exe /k vaultflow --help")
}

; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → v (VaultFlow) → key
; RegisterVaultFlowKeymaps() {
;     RegisterKeymap("c", "v", "v", "Run VaultFlow", RunVaultFlow, false, 1)
;     RegisterKeymap("c", "v", "s", "Status", VaultFlowStatus, false, 2)
;     RegisterKeymap("c", "v", "l", "List", VaultFlowList, false, 3)
;     RegisterKeymap("c", "v", "h", "Help", VaultFlowHelp, false, 4)
; }
