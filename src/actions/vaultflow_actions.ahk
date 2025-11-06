; ==============================
; VaultFlow Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE VAULTFLOW
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
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterVaultFlowKeymaps() {
    RegisterKeymap("vaultflow", "v", "Run VaultFlow", Func("RunVaultFlow"), false)
    RegisterKeymap("vaultflow", "s", "Status", Func("VaultFlowStatus"), false)
    RegisterKeymap("vaultflow", "l", "List", Func("VaultFlowList"), false)
    RegisterKeymap("vaultflow", "h", "Help", Func("VaultFlowHelp"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
