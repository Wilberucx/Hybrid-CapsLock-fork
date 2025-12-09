; ==============================
; System Actions Plugin
; ==============================
; Declarative system commands using ShellExec API


; ==============================
; ACTION FUNCTIONS
; ==============================

ToggleHiddenFiles() {
    try {
        key := "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced"
        currentValue := RegRead(key, "Hidden")
        newValue := (currentValue = 1) ? 2 : 1
        RegWrite(newValue, "REG_DWORD", key, "Hidden")
        
        ; Refresh all Explorer windows
        for window in ComObject("Shell.Application").Windows()
            window.Refresh()
        
        statusText := (newValue = 1) ? "👁️ Hidden Files: SHOWN" : "🙈 Hidden Files: HIDDEN"
        ShowTooltipFeedback("✅ " . statusText)
    } catch Error as e {
        ShowTooltipFeedback("❌ Error: " . e.Message)
    }
}

; ====================================
; DEFAULT KEYMAPS
; ====================================
; Using ShellExec API convenience functions where available

RegisterCategoryKeymap("leader", "s", "System Commands", 10)

; Information & Tools
RegisterKeymap("leader", "s", "s", "System Info", OpenSystemInfo, false, 1)
RegisterKeymap("leader", "s", "t", "Task Manager", OpenTaskManager, false, 2)
RegisterKeymap("leader", "s", "v", "Services", ShellExec("services.msc"), false, 3)
RegisterKeymap("leader", "s", "e", "Event Viewer", OpenEventViewer, false, 4)
RegisterKeymap("leader", "s", "d", "Device Manager", OpenDeviceManager, false, 5)
RegisterKeymap("leader", "s", "r", "Registry Editor", OpenRegistryEditor, false, 6)

; Utilities
RegisterKeymap("leader", "s", "l", "Disk Cleanup", ShellExec("cleanmgr.exe"), false, 7)
RegisterKeymap("leader", "s", "h", "Toggle Hidden Files", ToggleHiddenFiles, false, 8)
RegisterKeymap("leader", "s", "E", "Env Variables", ShellExec("rundll32.exe", "sysdm.cpl,EditEnvironmentVariables", "Show"), false, 9)
RegisterKeymap("leader", "s", "w", "Windows Version", ShellExec("winver.exe", "Show"), false, 10)
