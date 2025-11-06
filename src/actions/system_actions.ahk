; ==============================
; System Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

ShowSystemInfo() {
    Run("cmd.exe /k systeminfo")
    ShowCommandExecuted("System", "System Info")
}

ShowTaskManager() {
    Run("taskmgr.exe")
    ShowCommandExecuted("System", "Task Manager")
}

ShowServicesManager() {
    Run("services.msc")
    ShowCommandExecuted("System", "Services Manager")
}

ShowDeviceManager() {
    Run("devmgmt.msc")
    ShowCommandExecuted("System", "Device Manager")
}

ShowDiskCleanup() {
    Run("cleanmgr.exe")
    ShowCommandExecuted("System", "Disk Cleanup")
}

ToggleHiddenFiles() {
    try {
        currentValue := RegRead("HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", "Hidden")
        newValue := (currentValue = 1) ? 2 : 1
        RegWrite(newValue, "REG_DWORD", "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", "Hidden")
        Send("{F5}")
        statusText := (newValue = 1) ? "HIDDEN FILES SHOWN" : "HIDDEN FILES HIDDEN"
        ShowCenteredToolTip(statusText)
        SetTimer(() => RemoveToolTip(), -2000)
    } catch Error as err {
        ShowCenteredToolTip("Error toggling hidden files")
        SetTimer(() => RemoveToolTip(), -2000)
    }
}

ShowRegistryEditor() {
    Run("regedit.exe")
    ShowCommandExecuted("System", "Registry Editor")
}

ShowEnvironmentVariables() {
    Run("rundll32.exe sysdm.cpl,EditEnvironmentVariables")
    ShowCommandExecuted("System", "Environment Variables")
}

ShowEventViewer() {
    try {
        Run(EnvGet("SystemRoot") . "\\system32\\eventvwr.msc")
    } catch {
        try Run("eventvwr.msc")
    }
    ShowCommandExecuted("System", "Event Viewer")
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterSystemKeymaps() {
    RegisterKeymap("system", "s", "System Info", ShowSystemInfo, false, 1)
    RegisterKeymap("system", "t", "Task Manager", ShowTaskManager, false, 2)
    RegisterKeymap("system", "v", "Services Manager", ShowServicesManager, false, 3)
    RegisterKeymap("system", "e", "Event Viewer", ShowEventViewer, false, 4)
    RegisterKeymap("system", "d", "Device Manager", ShowDeviceManager, false, 5)
    RegisterKeymap("system", "c", "Disk Cleanup", ShowDiskCleanup, false, 6)
    RegisterKeymap("system", "h", "Toggle Hidden Files", ToggleHiddenFiles, false, 7)
    RegisterKeymap("system", "r", "Registry Editor", ShowRegistryEditor, false, 8)
    RegisterKeymap("system", "E", "Environment Variables", ShowEnvironmentVariables, false, 9)
}
