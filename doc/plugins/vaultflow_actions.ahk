; ==============================
; VaultFlow Actions Plugin
; ==============================
; Integration with VaultFlow CLI for Obsidian Git management
; Requires 'vaultflow' to be in system PATH

; ==============================
; ACTION FUNCTIONS
; ==============================

VaultFlowStatus() {
    path := GetActiveExplorerPath()
    ; Open terminal with vaultflow menu
    ; If path is empty, it opens in script dir, which is fine for the main menu 
    ; as it lists managed vaults.
    if (path != "") {
        ShellExecNow("cmd.exe /k vaultflow status", path, "Show")
    } else {
        ShellExecNow("cmd.exe /k vaultflow status", "", "Show")
    }
}

VaultFlowCommit() {
    path := GetActiveExplorerPath()
    if (path == "") {
        ShowTooltipFeedback("⚠️ Open a Vault folder in Explorer first", "info")
        return
    }
    
    ib := InputBox("Enter commit message:", "VaultFlow Custom Commit", "w400 h130")
    if (ib.Result == "Cancel" || ib.Value == "") {
        return
    }
    
    message := ib.Value
    ShowTooltipFeedback("⏳ Committing...", "info")
    
    ; Manual git commit as requested: git add . && git commit -m "msg"
    ; We use cmd /c to chain commands
    command := 'cmd /c git add . && git commit -m "' . message . '"'
    
    ; We use RunWait directly here for the chained command simplicity, 
    ; or we could use ShellExecNow if we wrap it in a .bat or similar, 
    ; but direct RunWait is fine for this specific composite action.
    try {
        RunWait(command, path, "Hide")
        ShowTooltipFeedback("✅ Custom commit created: " . message, "success")
    } catch {
        ShowTooltipFeedback("❌ Commit failed", "error")
    }
}

VaultFlowLog() {

    path := GetActiveExplorerPath()
    ; Open terminal with vaultflow menu
    ; If path is empty, it opens in script dir, which is fine for the main menu 
    ; as it lists managed vaults.
    if (path != "") {
        ShellExecNow("cmd.exe /k vaultflow log", path, "Show")
    } else {
        ShellExecNow("cmd.exe /k vaultflow log", "", "Show")
    }
}


RunVaultFlow() {
    path := GetActiveExplorerPath()
    ; Open terminal with vaultflow menu
    ; If path is empty, it opens in script dir, which is fine for the main menu 
    ; as it lists managed vaults.
    if (path != "") {
        ShellExecNow("cmd.exe /k vaultflow", path, "Show")
    } else {
        ShellExecNow("cmd.exe /k vaultflow", "", "Show")
    }
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================

; VaultFlow (leader → v → KEY)
RegisterCategoryKeymap("leader", "v", "VaultFlow", 8)

RegisterKeymap("leader", "v", "v", "VaultFlow", RunVaultFlow, false, 1)
RegisterKeymap("leader", "v", "c", "Commit", VaultFlowCommit, false, 2)
RegisterKeymap("leader", "v", "l", "Log", VaultFlowLog, false, 3)
RegisterKeymap("leader", "v", "s", "Status", VaultFlowStatus, false, 4)
