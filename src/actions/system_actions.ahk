; ==============================
; System Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa
; Cada función es independiente y puede ser llamada desde cualquier lugar

; ==============================
; FUNCIONES DE SISTEMA
; ==============================

ShowSystemInfo() {
    Run("cmd.exe /k systeminfo")
}

ShowTaskManager() {
    Run("taskmgr.exe")
}

ShowServicesManager() {
    Run("services.msc")
}

ShowDeviceManager() {
    Run("devmgmt.msc")
}

ShowDiskCleanup() {
    Run("cleanmgr.exe")
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
}

ShowEnvironmentVariables() {
    Run("rundll32.exe sysdm.cpl,EditEnvironmentVariables")
}

ShowEventViewer() {
    try {
        Run(EnvGet("SystemRoot") . "\\system32\\eventvwr.msc")
    } catch {
        try Run("eventvwr.msc")
    }
}

; ==============================
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterSystemKeymaps() {
    RegisterKeymap("system", "s", "System Info", Func("ShowSystemInfo"), false)
    RegisterKeymap("system", "t", "Task Manager", Func("ShowTaskManager"), false)
    RegisterKeymap("system", "v", "Services Manager", Func("ShowServicesManager"), false)
    RegisterKeymap("system", "d", "Device Manager", Func("ShowDeviceManager"), false)
    RegisterKeymap("system", "c", "Disk Cleanup", Func("ShowDiskCleanup"), false)
    RegisterKeymap("system", "h", "Toggle Hidden Files", Func("ToggleHiddenFiles"), false)
    RegisterKeymap("system", "r", "Registry Editor", Func("ShowRegistryEditor"), false)
    RegisterKeymap("system", "E", "Environment Variables", Func("ShowEnvironmentVariables"), false)
    RegisterKeymap("system", "e", "Event Viewer", Func("ShowEventViewer"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
