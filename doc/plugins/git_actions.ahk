; ==============================
; Git Actions Plugin 
; ==============================
; Now with Dynamic Path Detection and Git Init Prompt

; ==============================
; HELPER FUNCTIONS
; ==============================

GetGitWorkingDir() {
    ; 1. Try to get path from active Explorer window
    explorerPath := GetActiveExplorerPath()
    if (explorerPath != "")
        return explorerPath
    
    ; 2. Fallback to script directory
    return A_WorkingDir
}

IsGitRepo(wd) {
    try {
        ; Check if .git directory exists (fast check)
        if FileExist(wd . "\.git")
            return true
            
        ; Check if inside a work tree (slower but more robust for subdirs)
        ; We use RunWait with cmd /c to suppress the window and capture exit code
        exitCode := RunWait("cmd /c cd /d " . wd . " && git rev-parse --is-inside-work-tree > nul 2>&1",, "Hide")
        return exitCode == 0
    }
    return false
}

RunGitCommand(cmd, title := "Git Command") {
    wd := GetGitWorkingDir()
    
    ; Check if it's a git repo
    if !IsGitRepo(wd) {
        ; Ask user if they want to initialize
        result := MsgBox("Current directory is NOT a git repository:`n" . wd . "`n`nDo you want to initialize Git here?", "Git Error", "YesNo Icon!")
        
        if (result == "Yes") {
            Run("cmd.exe /k cd /d " . wd . " && git init && echo. && echo Git Initialized! && echo. && " . cmd)
            return
        } else {
            return ; User cancelled
        }
    }
    
    ; Visual feedback
    try {
        ShowCenteredToolTip("Running " . title . "`n📂 " . wd)
        SetTimer(() => RemoveToolTip(), -1500)
    }
    
    ; Run command in the detected directory
    Run("cmd.exe /k cd /d " . wd . " && " . cmd)
}

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

GitStatus() {
    RunGitCommand("git status", "Git Status")
}

GitLog() {
    RunGitCommand("git log --oneline -10 --graph --all", "Git Log")
}

GitBranches() {
    RunGitCommand("git branch -a", "Git Branches")
}

GitDiff() {
    RunGitCommand("git diff", "Git Diff")
}

GitAddAll() {
    RunGitCommand("git add . && git status", "Git Add All")
}

GitPull() {
    RunGitCommand("git pull", "Git Pull")
}

GitPush() {
    RunGitCommand("git push", "Git Push")
}

GitSync() {
    RunGitCommand("git pull && git add . && git commit -m 'Sync' && git push", "Git Sync (Pull+Push)")
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================
; These keymaps are auto-registered when this plugin is loaded.
; You can modify them here or move them to ahk/config/keymap.ahk for better organization and centralize your keymaps.

; Git Commands (leader → g → KEY)
RegisterCategoryKeymap("leader", "g", "Git Commands", 3)
RegisterKeymap("leader", "g", "s", "Status", GitStatus, false, 1)
RegisterKeymap("leader", "g", "l", "Log (Graph)", GitLog, false, 2)
RegisterKeymap("leader", "g", "b", "Branches", GitBranches, false, 3)
RegisterKeymap("leader", "g", "d", "Diff", GitDiff, false, 4)
RegisterKeymap("leader", "g", "a", "Add All", GitAddAll, true, 5)
RegisterKeymap("leader", "g", "p", "Pull", GitPull, true, 6)
RegisterKeymap("leader", "g", "P", "Push", GitPush, true, 7)
RegisterKeymap("leader", "g", "S", "Sync (Pull+Push)", GitSync, true, 8)
