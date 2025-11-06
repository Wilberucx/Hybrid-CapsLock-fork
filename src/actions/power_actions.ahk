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
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterPowerKeymaps() {
    RegisterKeymap("power", "l", "Lock Screen", LockWorkstation, false, 1)
    RegisterKeymap("power", "s", "Sleep", SuspendSystem, false, 2)
    RegisterKeymap("power", "h", "Hibernate", HibernateSystem, false, 3)
    RegisterKeymap("power", "o", "Sign Out", SignOutUser, true, 4)
    RegisterKeymap("power", "r", "Restart", RestartSystem, true, 5)
    RegisterKeymap("power", "S", "Shutdown", ShutdownSystem, true, 6)
}
