; ==============================
; Git Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE GIT
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
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterGitKeymaps() {
    RegisterKeymap("git", "s", "Git Status", Func("GitStatus"), false)
    RegisterKeymap("git", "l", "Git Log", Func("GitLog"), false)
    RegisterKeymap("git", "b", "Git Branches", Func("GitBranches"), false)
    RegisterKeymap("git", "d", "Git Diff", Func("GitDiff"), false)
    RegisterKeymap("git", "a", "Git Add All", Func("GitAddAll"), false)
    RegisterKeymap("git", "p", "Git Pull", Func("GitPull"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
