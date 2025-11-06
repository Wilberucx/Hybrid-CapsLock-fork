; ==============================
; Git Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

GitStatus() {
    Run("cmd.exe /k git status")
    ShowCommandExecuted("Git", "Status")
}

GitLog() {
    Run("cmd.exe /k git log --oneline -10")
    ShowCommandExecuted("Git", "Log")
}

GitBranches() {
    Run("cmd.exe /k git branch -a")
    ShowCommandExecuted("Git", "Branches")
}

GitDiff() {
    Run("cmd.exe /k git diff")
    ShowCommandExecuted("Git", "Diff")
}

GitAddAll() {
    Run("cmd.exe /k git add .")
    ShowCommandExecuted("Git", "Add All")
}

GitPull() {
    Run("cmd.exe /k git pull")
    ShowCommandExecuted("Git", "Pull")
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterGitKeymaps() {
    RegisterKeymap("git", "s", "Status", GitStatus, false, 1)
    RegisterKeymap("git", "l", "Log (last 10)", GitLog, false, 2)
    RegisterKeymap("git", "b", "Branches", GitBranches, false, 3)
    RegisterKeymap("git", "d", "Diff", GitDiff, false, 4)
    RegisterKeymap("git", "a", "Add All", GitAddAll, true, 5)
    RegisterKeymap("git", "p", "Pull", GitPull, true, 6)
}
