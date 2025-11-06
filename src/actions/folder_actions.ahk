; ==============================
; Folder Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE CARPETAS
; ==============================

OpenTempFolder() {
    Run('explorer.exe "' . EnvGet("TEMP") . '"')
}

OpenAppDataFolder() {
    Run('explorer.exe "' . EnvGet("APPDATA") . '"')
}

OpenProgramFilesFolder() {
    Run('explorer.exe "C:\\Program Files"')
}

OpenUserProfileFolder() {
    Run('explorer.exe "' . EnvGet("USERPROFILE") . '"')
}

OpenDesktopFolder() {
    Run('explorer.exe "' . EnvGet("USERPROFILE") . '\\Desktop"')
}

OpenSystem32Folder() {
    Run('explorer.exe "C:\\Windows\\System32"')
}

; ==============================
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterFolderKeymaps() {
    RegisterKeymap("folder", "t", "Temp Folder", Func("OpenTempFolder"), false)
    RegisterKeymap("folder", "a", "AppData Folder", Func("OpenAppDataFolder"), false)
    RegisterKeymap("folder", "p", "Program Files", Func("OpenProgramFilesFolder"), false)
    RegisterKeymap("folder", "u", "User Profile", Func("OpenUserProfileFolder"), false)
    RegisterKeymap("folder", "d", "Desktop", Func("OpenDesktopFolder"), false)
    RegisterKeymap("folder", "s", "System32", Func("OpenSystem32Folder"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
