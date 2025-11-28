; ==============================
; Power Actions Plugin
; ==============================

; ==============================
; GLOBAL STATE & INITIALIZATION
; ==============================

global preventSleepActive := false

; Load saved state on startup
InitializePowerActions()

InitializePowerActions() {
    global preventSleepActive
    try {
        savedState := IniRead("data\power_settings.ini", "Settings", "PreventSleep", "0")
        if (savedState == "1") {
            ; Re-apply prevent sleep
            DllCall("kernel32\SetThreadExecutionState", "UInt", 0x80000003) ; ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
            preventSleepActive := true
        }
    } catch {
        ; Ignore errors on init
    }
}

; ==============================
; HELPER FUNCTIONS
; ==============================

ShowPowerFeedback(message) {
    ; Use native tooltip with dedicated ID for Power Actions
    ToolTip(message, , , 15)
    SetTimer(() => ToolTip(, , , 15), -2000)
}

SavePowerSettings() {
    global preventSleepActive
    try {
        IniWrite(preventSleepActive ? "1" : "0", "data\power_settings.ini", "Settings", "PreventSleep")
    } catch {
        ; Ignore write errors
    }
}

; ==============================
; ACTION FUNCTIONS
; ==============================

SuspendSystem() {
    result := MsgBox("Are you sure you want to suspend the system?", "Confirm Sleep", "YesNo Icon?")
    if (result == "Yes") {
        ShowPowerFeedback("💤 Suspending system...")
        Sleep(500)
        DllCall("PowrProf\SetSuspendState", "int", 0, "int", 0, "int", 0)
    }
}

HibernateSystem() {
    result := MsgBox("Are you sure you want to hibernate the system?", "Confirm Hibernate", "YesNo Icon?")
    if (result == "Yes") {
        ShowPowerFeedback("💾 Hibernating system...")
        Sleep(500)
        DllCall("PowrProf\SetSuspendState", "int", 1, "int", 0, "int", 0)
    }
}

RestartSystem() {
    result := MsgBox("Are you sure you want to restart the system?", "Confirm Restart", "YesNo Icon!")
    if (result == "Yes") {
        ShowPowerFeedback("🔄 Restarting system...")
        Sleep(500)
        Run("shutdown.exe /r /t 0")
    }
}

ShutdownSystem() {
    result := MsgBox("Are you sure you want to shutdown the system?", "Confirm Shutdown", "YesNo Icon!")
    if (result == "Yes") {
        ShowPowerFeedback("⚡ Shutting down system...")
        Sleep(500)
        Run("shutdown.exe /s /t 0")
    }
}

LockWorkstation() {
    ShowPowerFeedback("🔒 Locking workstation...")
    Sleep(300)
    DllCall("user32\LockWorkStation")
}

SignOutUser() {
    result := MsgBox("Are you sure you want to sign out?", "Confirm Sign Out", "YesNo Icon?")
    if (result == "Yes") {
        ShowPowerFeedback("👋 Signing out...")
        Sleep(500)
        Run("shutdown.exe /l")
    }
}

MonitorOff() {
    ShowPowerFeedback("🖥️ Turning off monitor...")
    Sleep(300)
    ; Send monitor to low-power state
    SendMessage(0x112, 0xF170, 2, , "Program Manager")
}

TogglePreventSleep() {
    global preventSleepActive
    
    if (preventSleepActive) {
        ; Disable prevent sleep - return to normal
        DllCall("kernel32\SetThreadExecutionState", "UInt", 0x80000000) ; ES_CONTINUOUS
        preventSleepActive := false
        ShowPowerFeedback("🌙 Prevent Sleep: OFF")
    } else {
        ; Enable prevent sleep - keep system awake
        DllCall("kernel32\SetThreadExecutionState", "UInt", 0x80000003) ; ES_CONTINUOUS | ES_SYSTEM_REQUIRED | ES_DISPLAY_REQUIRED
        preventSleepActive := true
        ShowPowerFeedback("🔆 Prevent Sleep: ON")
    }
    SavePowerSettings()
}

ScheduledShutdown() {
    ib := InputBox("Enter minutes until shutdown (0 to cancel):", "Scheduled Shutdown", "w300 h130")
    if (ib.Result == "Cancel")
        return
        
    minutes := Integer(ib.Value)
    
    if (minutes == 0) {
        ; Cancel any scheduled shutdown
        Run("shutdown.exe /a", , "Hide")
        ShowPowerFeedback("❌ Scheduled shutdown cancelled")
    } else if (minutes > 0) {
        seconds := minutes * 60
        Run("shutdown.exe /s /t " . seconds, , "Hide")
        ShowPowerFeedback("⏰ Shutdown scheduled in " . minutes . " minute(s)")
    }
}

ScheduledRestart() {
    ib := InputBox("Enter minutes until restart (0 to cancel):", "Scheduled Restart", "w300 h130")
    if (ib.Result == "Cancel")
        return
        
    minutes := Integer(ib.Value)
    
    if (minutes == 0) {
        ; Cancel any scheduled restart
        Run("shutdown.exe /a", , "Hide")
        ShowPowerFeedback("❌ Scheduled restart cancelled")
    } else if (minutes > 0) {
        seconds := minutes * 60
        Run("shutdown.exe /r /t " . seconds, , "Hide")
        ShowPowerFeedback("⏰ Restart scheduled in " . minutes . " minute(s)")
    }
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================
; These keymaps are auto-registered when this plugin is loaded.

; Power Options (leader → o → KEY)
RegisterCategoryKeymap("leader", "o", "Power Options", 10)
RegisterKeymap("leader", "o", "l", "Lock Screen", LockWorkstation, false, 1)
RegisterKeymap("leader", "o", "m", "Monitor Off", MonitorOff, false, 2)
RegisterKeymap("leader", "o", "p", "Toggle Prevent Sleep", TogglePreventSleep, false, 3)
RegisterKeymap("leader", "o", "s", "Sleep", SuspendSystem, false, 4)
RegisterKeymap("leader", "o", "h", "Hibernate", HibernateSystem, false, 5)
RegisterKeymap("leader", "o", "o", "Sign Out", SignOutUser, false, 6)
RegisterKeymap("leader", "o", "r", "Restart", RestartSystem, false, 7)
RegisterKeymap("leader", "o", "S", "Shutdown", ShutdownSystem, false, 8)
RegisterKeymap("leader", "o", "t", "Schedule Shutdown", ScheduledShutdown, false, 9)
RegisterKeymap("leader", "o", "T", "Schedule Restart", ScheduledRestart, false, 10)
