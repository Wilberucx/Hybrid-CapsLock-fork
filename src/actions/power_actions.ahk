; ==============================
; Power Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

SuspendSystem() {
    DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
}

HibernateSystem() {
    DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
}

RestartSystem() {
    Run("shutdown.exe /r /t 0")
}

ShutdownSystem() {
    Run("shutdown.exe /s /t 0")
}

LockWorkstation() {
    DllCall("user32\LockWorkStation")
}

SignOutUser() {
    Run("shutdown.exe /l")
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
