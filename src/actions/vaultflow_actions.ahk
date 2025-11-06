; ==============================
; VaultFlow Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

RunVaultFlow() {
    Run("powershell.exe -Command `"vaultflow`"")
    ShowCommandExecuted("VaultFlow", "Run")
}

VaultFlowStatus() {
    Run("cmd.exe /k vaultflow status")
    ShowCommandExecuted("VaultFlow", "Status")
}

VaultFlowList() {
    Run("cmd.exe /k vaultflow list")
    ShowCommandExecuted("VaultFlow", "List")
}

VaultFlowHelp() {
    Run("cmd.exe /k vaultflow --help")
    ShowCommandExecuted("VaultFlow", "Help")
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterVaultFlowKeymaps() {
    RegisterKeymap("vaultflow", "v", "Run VaultFlow", RunVaultFlow, false, 1)
    RegisterKeymap("vaultflow", "s", "Status", VaultFlowStatus, false, 2)
    RegisterKeymap("vaultflow", "l", "List", VaultFlowList, false, 3)
    RegisterKeymap("vaultflow", "h", "Help", VaultFlowHelp, false, 4)
}
