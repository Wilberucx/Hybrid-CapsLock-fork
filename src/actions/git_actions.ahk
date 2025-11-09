; ==============================
; Git Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

GitStatus() {
    Run("cmd.exe /k git status")
}

GitLog() {
    Run("cmd.exe /k git log --oneline -10")
}

GitBranches() {
    Run("cmd.exe /k git branch -a")
}

GitDiff() {
    Run("cmd.exe /k git diff")
}

GitAddAll() {
    Run("cmd.exe /k git add .")
}

GitPull() {
    Run("cmd.exe /k git pull")
}

; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → g (Git) → key
RegisterGitKeymaps() {
    RegisterKeymap("c", "g", "s", "Status", GitStatus, false, 1)
    RegisterKeymap("c", "g", "l", "Log (last 10)", GitLog, false, 2)
    RegisterKeymap("c", "g", "b", "Branches", GitBranches, false, 3)
    RegisterKeymap("c", "g", "d", "Diff", GitDiff, false, 4)
    RegisterKeymap("c", "g", "a", "Add All", GitAddAll, true, 5)
    RegisterKeymap("c", "g", "p", "Pull", GitPull, true, 6)
}
