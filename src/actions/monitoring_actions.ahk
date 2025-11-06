; ==============================
; Monitoring Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE MONITOREO
; ==============================

ShowTopProcesses() {
    Run("powershell.exe -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
}

ShowServicesStatus() {
    Run("powershell.exe -Command `"Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
}

ShowDiskSpace() {
    Run("powershell.exe -Command `"Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
}

ShowMemoryUsage() {
    Run("powershell.exe -Command `"Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
}

ShowCPUUsage() {
    Run("powershell.exe -Command `"Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
}

; ==============================
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterMonitoringKeymaps() {
    RegisterKeymap("monitoring", "p", "Top Processes", Func("ShowTopProcesses"), false)
    RegisterKeymap("monitoring", "s", "Services Status", Func("ShowServicesStatus"), false)
    RegisterKeymap("monitoring", "d", "Disk Space", Func("ShowDiskSpace"), false)
    RegisterKeymap("monitoring", "m", "Memory Usage", Func("ShowMemoryUsage"), false)
    RegisterKeymap("monitoring", "c", "CPU Usage", Func("ShowCPUUsage"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
