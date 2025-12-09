; ==============================
; LazyGitActions Plugin 
; ==============================
; This plugin need Git and LazyGit installed and git_actions.ahk included.

; ==============================
; HELPER FUNCTIONS ON GIT_ACTIONS.AHK
; ==============================

InitLazyGit() {
    ShowTooltipFeedback("Launching LazyGit...", "Info")
    RunGitCommand("lazygit", "LazyGit")
}


; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================
; These keymaps are auto-registered when this plugin is loaded.
; You can modify them here or move them to ahk/config/keymap.ahk for better organization and centralize your keymaps.

; Git Commands (leader → g → KEY)
RegisterCategoryKeymap("leader", "g", "Git Commands", 3)
RegisterKeymap("leader", "g", "g", "LazyGit", InitLazyGit, false, 1)
