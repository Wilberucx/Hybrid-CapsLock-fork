; ==============================
; Folder Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

OpenTempFolder() {
    Run('explorer.exe "' . EnvGet("TEMP") . '"')
    ShowCommandExecuted("Folder", "Temp Folder")
}

OpenAppDataFolder() {
    Run('explorer.exe "' . EnvGet("APPDATA") . '"')
    ShowCommandExecuted("Folder", "AppData")
}

OpenProgramFilesFolder() {
    Run('explorer.exe "C:\\Program Files"')
    ShowCommandExecuted("Folder", "Program Files")
}

OpenUserProfileFolder() {
    Run('explorer.exe "' . EnvGet("USERPROFILE") . '"')
    ShowCommandExecuted("Folder", "User Profile")
}

OpenDesktopFolder() {
    Run('explorer.exe "' . EnvGet("USERPROFILE") . '\\Desktop"')
    ShowCommandExecuted("Folder", "Desktop")
}

OpenSystem32Folder() {
    Run('explorer.exe "C:\\Windows\\System32"')
    ShowCommandExecuted("Folder", "System32")
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
