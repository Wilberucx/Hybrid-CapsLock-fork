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
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → v (VaultFlow) → key
RegisterVaultFlowKeymaps() {
    RegisterKeymap("c", "v", "v", "Run VaultFlow", RunVaultFlow, false, 1)
    RegisterKeymap("c", "v", "s", "Status", VaultFlowStatus, false, 2)
    RegisterKeymap("c", "v", "l", "List", VaultFlowList, false, 3)
    RegisterKeymap("c", "v", "h", "Help", VaultFlowHelp, false, 4)
}
