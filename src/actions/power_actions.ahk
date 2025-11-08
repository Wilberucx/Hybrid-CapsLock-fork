; ==============================
; Power Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

SuspendSystem() {
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
    ShowCommandExecuted("Power", "Sleep")
}

HibernateSystem() {
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
    ShowCommandExecuted("Power", "Hibernate")
}

RestartSystem() {
    Run("shutdown.exe /r /t 0")
    ShowCommandExecuted("Power", "Restart")
}

ShutdownSystem() {
    Run("shutdown.exe /s /t 0")
    ShowCommandExecuted("Power", "Shutdown")
}

LockWorkstation() {
    DllCall("user32\LockWorkStation")
    ShowCommandExecuted("Power", "Lock Screen")
}

SignOutUser() {
    Run("shutdown.exe /l")
    ShowCommandExecuted("Power", "Sign Out")
}

; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → o (Power) → key
RegisterPowerKeymaps() {
    RegisterKeymap("c", "o", "l", "Lock Screen", LockWorkstation, false, 1)
    RegisterKeymap("c", "o", "s", "Sleep", SuspendSystem, false, 2)
    RegisterKeymap("c", "o", "h", "Hibernate", HibernateSystem, false, 3)
    RegisterKeymap("c", "o", "o", "Sign Out", SignOutUser, true, 4)
    RegisterKeymap("c", "o", "r", "Restart", RestartSystem, true, 5)
    RegisterKeymap("c", "o", "S", "Shutdown", ShutdownSystem, true, 6)
}
