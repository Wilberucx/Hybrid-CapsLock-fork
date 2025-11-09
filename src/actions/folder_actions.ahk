; ==============================
; Folder Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
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
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → f (Folder) → key
RegisterFolderKeymaps() {
    RegisterKeymap("c", "f", "t", "Temp Folder", OpenTempFolder, false, 1)
    RegisterKeymap("c", "f", "a", "AppData", OpenAppDataFolder, false, 2)
    RegisterKeymap("c", "f", "p", "Program Files", OpenProgramFilesFolder, false, 3)
    RegisterKeymap("c", "f", "u", "User Profile", OpenUserProfileFolder, false, 4)
    RegisterKeymap("c", "f", "d", "Desktop", OpenDesktopFolder, false, 5)
    RegisterKeymap("c", "f", "s", "System32", OpenSystem32Folder, false, 6)
}
