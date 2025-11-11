; ==============================
; Shell Execute Actions
; ==============================
; Provides shell execution capabilities without showing console windows.
; Compatible with RegisterKeymap for direct terminal command execution.
; Supports: .vbs, .bat, .exe, .ahk, and direct commands

; ---- Main intelligent shell execution function ----
; SMART USAGE FOR REGISTERKEYMAP:
; ShellExec(command)                                    → Returns function for delayed execution
; ShellExec(command, "Show")                           → Returns function with Show parameter
; ShellExec(command, workingDir)                       → Returns function with working directory
; ShellExec(command, configFile, "Hide")               → Returns function with config file
; 
; FOR IMMEDIATE EXECUTION, call ShellExecNow() directly
ShellExec(command, param2 := "", param3 := "", param4 := "") {
    ; ALWAYS return a function for RegisterKeymap usage
    return () => ShellExecNow(command, param2, param3, param4)
}

; ---- Internal execution function (immediate execution) ----
ShellExecNow(command, param2 := "", param3 := "", param4 := "") {
    ; Initialize variables
    workingDir := ""
    showWindow := "Hide"
    configFile := ""
    finalCommand := command
    
    ; SMART PARAMETER DETECTION
    ; Analyze param2, param3, param4 to determine what they are
    params := [param2, param3, param4]
    
    for index, param in params {
        if (param == "")
            continue
            
        ; Check if it's a window state
        if (param ~= "^(Hide|Show|Min|Max|Minimize|Maximize)$") {
            showWindow := (param == "Min" || param == "Minimize") ? "Min" : 
                         (param == "Max" || param == "Maximize") ? "Max" : 
                         (param == "Show") ? "Show" : "Hide"
        }
        ; Check if it's a file (config file, script, etc.)
        else if (InStr(param, ".") && (InStr(param, ".kbd") || InStr(param, ".json") || InStr(param, ".cfg") || 
                InStr(param, ".conf") || InStr(param, ".ini") || InStr(param, ".xml") || InStr(param, ".yml") || 
                InStr(param, ".yaml") || InStr(param, ".txt"))) {
            configFile := param
        }
        ; Check if it's a directory (contains \ or / or drive letter)
        else if (InStr(param, "\") || InStr(param, "/") || (StrLen(param) >= 2 && SubStr(param, 2, 1) == ":")) {
            workingDir := param
        }
        ; If none of the above, treat as additional parameter
        else if (param != "") {
            ; Could be a parameter for the command
            if (configFile == "" && !InStr(param, " ")) {
                configFile := param
            }
        }
    }
    
    ; BUILD FINAL COMMAND
    ; If config file detected, add it as parameter
    if (configFile != "") {
        if (InStr(finalCommand, ".exe")) {
            ; Add config file as parameter for executable
            finalCommand := '"' . finalCommand . '" "' . configFile . '"'
        } else {
            ; For non-exe commands, append the config file
            finalCommand := finalCommand . ' "' . configFile . '"'
        }
    } else if (!InStr(finalCommand, '"') && InStr(finalCommand, " ")) {
        ; Quote the entire command if it has spaces and isn't already quoted
        finalCommand := '"' . finalCommand . '"'
    }
    
    try {
        ; SMART EXECUTION BASED ON FILE TYPE
        if (InStr(command, ".vbs")) {
            ; VBScript files - use wscript for silent execution
            if (configFile != "") {
                Run('wscript.exe "' . command . '" "' . configFile . '"', workingDir, showWindow)
            } else {
                Run('wscript.exe "' . command . '"', workingDir, showWindow)
            }
        }
        else if (InStr(command, ".bat") || InStr(command, ".cmd")) {
            ; Batch files - use cmd /c for execution
            Run('cmd.exe /c ' . finalCommand, workingDir, showWindow)
        }
        else if (InStr(command, ".ahk")) {
            ; AutoHotkey scripts
            if (configFile != "") {
                Run('AutoHotkey.exe "' . command . '" "' . configFile . '"', workingDir, showWindow)
            } else {
                Run('AutoHotkey.exe "' . command . '"', workingDir, showWindow)
            }
        }
        else if (InStr(command, ".exe") || !InStr(command, ".")) {
            ; Executable files or direct commands
            Run(finalCommand, workingDir, showWindow)
        }
        else {
            ; Generic command execution
            Run('cmd.exe /c ' . finalCommand, workingDir, showWindow)
        }
        
        return true
        
    } catch Error as err {
        ; Show error tooltip if execution fails
        ShowCenteredToolTip("Failed to execute: " . finalCommand . "`nError: " . err.message)
        SetTimer(() => RemoveToolTip(), -3000)
        return false
    }
}

; ---- Variants for different window states ----
ShellExecVisible(command, workingDir := "") {
    return ShellExec(command, workingDir, "Show")
}

ShellExecMinimized(command, workingDir := "") {
    return ShellExec(command, workingDir, "Min")
}

ShellExecMaximized(command, workingDir := "") {
    return ShellExec(command, workingDir, "Max")
}

; ---- Specialized execution functions ----
ExecuteVBS(vbsPath, workingDir := "") {
    return ShellExec(vbsPath, workingDir, "Hide")
}

ExecuteBatch(batPath, workingDir := "") {
    return ShellExec(batPath, workingDir, "Hide")
}

ExecuteAHK(ahkPath, workingDir := "") {
    return ShellExec(ahkPath, workingDir, "Hide")
}

; ---- Execute with return value capture ----
ShellExecCapture(command, workingDir := "") {
    try {
        ; Use RunWait with output capture
        tempFile := A_Temp . "\shell_exec_output.txt"
        RunWait('cmd.exe /c "' . command . '" > "' . tempFile . '" 2>&1', workingDir, "Hide")
        
        if (FileExist(tempFile)) {
            output := FileRead(tempFile)
            FileDelete(tempFile)
            return output
        }
    } catch Error as err {
        ShowCenteredToolTip("Failed to capture output: " . err.message)
        SetTimer(() => RemoveToolTip(), -3000)
    }
    return ""
}

; ---- Execute and wait for completion ----
ShellExecWait(command, workingDir := "", timeout := 0) {
    try {
        if (timeout > 0) {
            return RunWait(command, workingDir, "Hide", timeout)
        } else {
            return RunWait(command, workingDir, "Hide")
        }
    } catch Error as err {
        ShowCenteredToolTip("Command execution failed or timed out")
        SetTimer(() => RemoveToolTip(), -2000)
        return -1
    }
}

; ---- Common system commands as convenience functions ----
OpenExplorer(path := "") {
    if (path = "") {
        return ShellExecNow("explorer.exe", "", "Hide")
    } else {
        return ShellExecNow('explorer.exe "' . path . '"', "", "Hide")
    }
}

OpenCmd(path := "") {
    if (path = "") {
        return ShellExecVisible("cmd.exe")
    } else {
        return ShellExecVisible('cmd.exe /k cd /d "' . path . '"')
    }
}

OpenPowerShell(path := "") {
    if (path = "") {
        return ShellExecVisible("powershell.exe")
    } else {
        return ShellExecVisible('powershell.exe -NoExit -Command "Set-Location \"' . path . '\""')
    }
}

; ---- Execute system utilities ----
OpenTaskManager() => ShellExecNow("taskmgr.exe", "", "Hide")
OpenControlPanel() => ShellExecNow("control.exe", "", "Hide")
OpenDeviceManager() => ShellExecNow("devmgmt.msc", "", "Hide")
OpenEventViewer() => ShellExecNow("eventvwr.msc", "", "Hide")
OpenSystemInfo() => ShellExecNow("msinfo32.exe", "", "Hide")
OpenRegistryEditor() => ShellExecNow("regedit.exe", "", "Hide")

; ---- Network and system commands ----
FlushDNS() => ShellExecNow("ipconfig /flushdns", "", "Hide")
RenewIP() => ShellExecNow("ipconfig /renew", "", "Hide")

; ---- Pre-defined shell exec functions for RegisterKeymap ----
; These can be used directly: RegisterKeymap("leader", "p", "e", "Explorer", ShellExec_Explorer, false, 1)
ShellExec_Explorer() => ShellExecNow("explorer.exe", "", "Hide")
ShellExec_Notepad() => ShellExecNow("notepad.exe", "", "Hide")
ShellExec_Calc() => ShellExecNow("calc.exe", "", "Hide")
ShellExec_Paint() => ShellExecNow("mspaint.exe", "", "Hide")
ShellExec_Snip() => ShellExecNow("SnippingTool.exe", "", "Hide")
ShellExec_TaskMgr() => ShellExecNow("taskmgr.exe", "", "Hide")
ShellExec_ControlPanel() => ShellExecNow("control.exe", "", "Hide")
ShellExec_DeviceMgr() => ShellExecNow("devmgmt.msc", "", "Hide")
ShellExec_EventViewer() => ShellExecNow("eventvwr.msc", "", "Hide")
ShellExec_SystemInfo() => ShellExecNow("msinfo32.exe", "", "Hide")
ShellExec_RegEdit() => ShellExecNow("regedit.exe", "", "Hide")
ShellExec_CMD() => ShellExecNow("cmd.exe", "", "Show")
ShellExec_PowerShell() => ShellExecNow("powershell.exe", "", "Show")
CheckPing(target := "8.8.8.8") => ShellExecCapture("ping -n 4 " . target)
GetSystemInfo() => ShellExecCapture("systeminfo")
ListProcesses() => ShellExecCapture("tasklist")

