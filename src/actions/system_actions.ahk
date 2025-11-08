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

ShowWindowsVersion() {
    Run("cmd.exe /k ver")
    ShowCommandExecuted("System", "Windows Version")
}
; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → s (System) → key
RegisterSystemKeymaps() {
    RegisterKeymap("c", "s", "s", "System Info", ShowSystemInfo, false, 1)
    RegisterKeymap("c", "s", "t", "Task Manager", ShowTaskManager, false, 2)
    RegisterKeymap("c", "s", "v", "Services Manager", ShowServicesManager, false, 3)
    RegisterKeymap("c", "s", "e", "Event Viewer", ShowEventViewer, false, 4)
    RegisterKeymap("c", "s", "d", "Device Manager", ShowDeviceManager, false, 5)
    RegisterKeymap("c", "s", "c", "Disk Cleanup", ShowDiskCleanup, false, 6)
    RegisterKeymap("c", "s", "h", "Toggle Hidden Files", ToggleHiddenFiles, false, 7)
    RegisterKeymap("c", "s", "r", "Registry Editor", ShowRegistryEditor, false, 8)
    RegisterKeymap("c", "s", "E", "Environment Variables", ShowEnvironmentVariables, false, 9)
    RegisterKeymap("c", "s", "w", "Windows Version", ShowWindowsVersion, false, 10)
}
