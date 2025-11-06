; ==============================
; Power Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE ENERGÍA
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
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterPowerKeymaps() {
    RegisterKeymap("power", "s", "Sleep", Func("SuspendSystem"), true)
    RegisterKeymap("power", "h", "Hibernate", Func("HibernateSystem"), true)
    RegisterKeymap("power", "r", "Restart", Func("RestartSystem"), true)
    RegisterKeymap("power", "S", "Shutdown", Func("ShutdownSystem"), true)
    RegisterKeymap("power", "l", "Lock Screen", Func("LockWorkstation"), false)
    RegisterKeymap("power", "o", "Sign Out", Func("SignOutUser"), true)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
