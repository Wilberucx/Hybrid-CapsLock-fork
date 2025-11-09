; ==============================
; Monitoring Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando

; ==============================
; FUNCIONES DE ACCIÓN
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
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → c (Commands) → m (Monitoring) → key
RegisterMonitoringKeymaps() {
    RegisterKeymap("c", "m", "p", "Top Processes", ShowTopProcesses, false, 1)
    RegisterKeymap("c", "m", "s", "Services Status", ShowServicesStatus, false, 2)
    RegisterKeymap("c", "m", "d", "Disk Space", ShowDiskSpace, false, 3)
    RegisterKeymap("c", "m", "m", "Memory Usage", ShowMemoryUsage, false, 4)
    RegisterKeymap("c", "m", "c", "CPU Usage", ShowCPUUsage, false, 5)
}
