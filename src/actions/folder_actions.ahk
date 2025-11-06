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
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterFolderKeymaps() {
    RegisterKeymap("folder", "t", "Temp Folder", OpenTempFolder, false, 1)
    RegisterKeymap("folder", "a", "AppData", OpenAppDataFolder, false, 2)
    RegisterKeymap("folder", "p", "Program Files", OpenProgramFilesFolder, false, 3)
    RegisterKeymap("folder", "u", "User Profile", OpenUserProfileFolder, false, 4)
    RegisterKeymap("folder", "d", "Desktop", OpenDesktopFolder, false, 5)
    RegisterKeymap("folder", "s", "System32", OpenSystem32Folder, false, 6)
}
