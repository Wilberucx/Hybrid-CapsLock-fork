; ==============================
; Monitoring Actions Plugin
; ==============================
; Native AHK implementation for high performance (No PowerShell)

; ==============================
; GLOBAL VARIABLES
; ==============================
global MonitorTimerActive := false

; ==============================
; NATIVE TOOLTIP HELPERS (Bypass C# system)
; ==============================
ShowMonitorTooltip(Text) {
    ; Force native tooltip with ID 20 to avoid conflicts
    ToolTipX := A_ScreenWidth // 2
    ToolTipY := A_ScreenHeight - 100
    ToolTip(Text, ToolTipX, ToolTipY, 20)
}

HideMonitorTooltip() {
    ToolTip(,,,20)
}

; ==============================
; HELPER FUNCTIONS (WMI & Native)
; ==============================

GetCPUUsage() {
    try {
        svc := ComObjGet("winmgmts:")
        proc := svc.ExecQuery("Select LoadPercentage from Win32_Processor")
        for p in proc
            return p.LoadPercentage
    }
    return "N/A"
}

GetRAMUsage() {
    try {
        ; GlobalMemoryStatusEx
        stat := Buffer(64, 0)
        NumPut("UInt", 64, stat)
        if DllCall("Kernel32.dll\GlobalMemoryStatusEx", "Ptr", stat) {
            load := NumGet(stat, 4, "UInt") ; Memory load %
            totalPhys := NumGet(stat, 8, "UInt64")
            availPhys := NumGet(stat, 16, "UInt64")
            
            usedGB := Format("{:.1f}", (totalPhys - availPhys) / 1024 / 1024 / 1024)
            totalGB := Format("{:.1f}", totalPhys / 1024 / 1024 / 1024)
            
            return {Load: load, Used: usedGB, Total: totalGB}
        }
    }
    return {Load: 0, Used: 0, Total: 0}
}

GetDiskUsage(drive := "C:") {
    try {
        free := DriveGetSpaceFree(drive)
        total := DriveGetCapacity(drive)
        used := total - free
        
        freeGB := Format("{:.1f}", free / 1024)
        totalGB := Format("{:.1f}", total / 1024)
        percent := Format("{:.0f}", (used / total) * 100)
        
        return {Free: freeGB, Total: totalGB, Percent: percent}
    }
    return {Free: 0, Total: 0, Percent: 0}
}

; ==============================
; ACTIONS
; ==============================

ShowSystemStats() {
    ShowTooltipFeedback("Obtaining system stats...", "info", 1000)
    cpu := GetCPUUsage()
    ram := GetRAMUsage()
    disk := GetDiskUsage("C:")
    
    info := "📊 SYSTEM MONITOR`n"
    info .= "------------------`n"
    info .= "CPU : " . cpu . "%`n"
    info .= "RAM : " . ram.Load . "% (" . ram.Used . "/" . ram.Total . " GB)`n"
    info .= "DISK: " . disk.Percent . "% Used (" . disk.Free . " GB Free)"
    
    ShowTooltipFeedback(info, "info", 3000)
    SetTimer(() => HideMonitorTooltip(), -3000)
}

ToggleRealTimeMonitor() {
    global MonitorTimerActive
    
    if (MonitorTimerActive) {
        SetTimer(UpdateMonitorTooltip, 0) ; Off
        HideMonitorTooltip()
        MonitorTimerActive := false
        ShowTooltipFeedback("Monitor stopped", "info", 2000)
        SetTimer(() => HideMonitorTooltip(), -1000)
    } else {
        ShowTooltipFeedback("Starting monitor", "info", 2000)
        MonitorTimerActive := true
        SetTimer(UpdateMonitorTooltip, -300) ; First update after 300ms
        SetTimer(UpdateMonitorTooltip, 1000) ; Then every 1s
    }
}

UpdateMonitorTooltip() {
    if (!MonitorTimerActive)
        return
        
    cpu := GetCPUUsage()
    ram := GetRAMUsage()
    
    info := "🔴 LIVE MONITOR`n"
    info .= "CPU: " . cpu . "% | RAM: " . ram.Load . "%"
    
    ShowTooltipFeedback( info, "info") ; Keep native tooltip visible
}

ShowTopProcesses() {
    ShowTooltipFeedback("Analyzing processes...", "info")
    
    ; Use powershell hidden to get sorted CPU usage
    ; We write to a temp file to avoid window flickering from StdOut read
    tempFile := A_Temp . "\top_proc.txt"
    psCmd := "powershell -NoProfile -WindowStyle Hidden -Command `"Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 Name, @{Name='CPU';Expression={[math]::Round($_.CPU, 1)}}, @{Name='RAM';Expression={[math]::Round($_.WorkingSet/1MB, 1)}} | Format-Table -HideTableHeaders -AutoSize | Out-File -Encoding UTF8 '" . tempFile . "'`""
    
    try {
        RunWait(psCmd,, "Hide")
        
        if FileExist(tempFile) {
            result := FileRead(tempFile)
            FileDelete(tempFile)
            
            info := "🚀 TOP PROCESSES (CPU)`n"
            info .= "----------------------`n"
            info .= result
            
            ShowTooltipFeedback(info, "info")
            SetTimer(() => HideMonitorTooltip(), -4000)
        } else {
             ShowTooltipFeedback("Error fetching processes", "error", 3000)
        }
    } catch {
        ShowTooltipFeedback("Error executing PowerShell", "error", 5000)
    }
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================
; These keymaps are auto-registered when this plugin is loaded.
; You can modify them here or move them to ahk/config/keymap.ahk for better organization and centralize your keymaps.

; Monitoring Commands (leader → c → m → KEY)
RegisterCategoryKeymap("leader", "m", "Monitoring Commands", 4)
RegisterKeymap("leader", "m", "s", "System Stats", ShowSystemStats, false, 1)
RegisterKeymap("leader", "m", "m", "Live Monitor (Toggle)", ToggleRealTimeMonitor, false, 2)
RegisterKeymap("leader", "m", "p", "Top Processes", ShowTopProcesses, false, 3)
