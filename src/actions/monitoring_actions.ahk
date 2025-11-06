; ==============================
; Monitoring Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

ShowTopProcesses() {
    Run("powershell.exe -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 20 | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
    ShowCommandExecuted("Monitoring", "Top Processes")
}

ShowServicesStatus() {
    Run("powershell.exe -Command `"Get-Service | Sort-Object Status,Name | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
    ShowCommandExecuted("Monitoring", "Services Status")
}

ShowDiskSpace() {
    Run("powershell.exe -Command `"Get-WmiObject -Class Win32_LogicalDisk | Select-Object DeviceID,Size,FreeSpace | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
    ShowCommandExecuted("Monitoring", "Disk Space")
}

ShowMemoryUsage() {
    Run("powershell.exe -Command `"Get-WmiObject -Class Win32_OperatingSystem | Select-Object TotalVisibleMemorySize,FreePhysicalMemory | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
    ShowCommandExecuted("Monitoring", "Memory Usage")
}

ShowCPUUsage() {
    Run("powershell.exe -Command `"Get-WmiObject -Class Win32_Processor | Select-Object Name,LoadPercentage | Format-Table -AutoSize; Read-Host 'Press Enter to exit'`"")
    ShowCommandExecuted("Monitoring", "CPU Usage")
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
RegisterMonitoringKeymaps() {
    RegisterKeymap("monitoring", "p", "Top Processes", ShowTopProcesses, false, 1)
    RegisterKeymap("monitoring", "s", "Services Status", ShowServicesStatus, false, 2)
    RegisterKeymap("monitoring", "d", "Disk Space", ShowDiskSpace, false, 3)
    RegisterKeymap("monitoring", "m", "Memory Usage", ShowMemoryUsage, false, 4)
    RegisterKeymap("monitoring", "c", "CPU Usage", ShowCPUUsage, false, 5)
}
