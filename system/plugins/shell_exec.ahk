; ==============================
; Shell Execute - Core Plugin
; ==============================
; CORE INFRASTRUCTURE: Provides shell execution API for other plugins and user configurations.
; This plugin does NOT register any keymaps - it provides reusable functions only.
;
; FEATURES:
; - Execute commands without showing console windows
; - Smart parameter detection (working dir, window state, config files)
; - Compatible with RegisterKeymap pattern (returns closures)
; - Support for multiple file types: .vbs, .bat, .exe, .ahk, and direct commands
; - Output capture and synchronous execution variants
;
; USAGE IN PLUGINS:
; RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
; RegisterKeymap("leader", "t", "cmd", "Terminal", ShellExec("cmd.exe", "Show"), false, 1)
; RegisterKeymap("leader", "g", "s", "Git Status", ShellExec("git status", A_WorkingDir), false, 1)
;
; SIMILAR PATTERN: See SendInfo() in sendinfo_actions.ahk for text insertion using the same closure pattern.
;
; API REFERENCE: See doc/develop/shell_exec_api.md for complete documentation.

; ---- Main intelligent shell execution function ----
/**
 * ShellExec - Smart shell execution with automatic parameter detection
 * 
 * This is the PRIMARY function for RegisterKeymap usage. It returns a closure
 * that executes the command when called, following the same pattern as SendInfo().
 * 
 * PARAMETER DETECTION:
 * - Window states: "Hide", "Show", "Min", "Max", "Minimize", "Maximize"
 * - Working directory: Any path containing \ or / or drive letter (C:)
 * - Config file: Files with extensions .kbd, .json, .cfg, .conf, .ini, .xml, .yml, .yaml, .txt
 * - Additional parameters: Anything else is treated as command parameter
 * 
 * @param command - Command to execute (exe, bat, vbs, ahk, or direct command)
 * @param param2 - Optional: working dir, window state, or config file (auto-detected)
 * @param param3 - Optional: working dir, window state, or config file (auto-detected)
 * @param param4 - Optional: working dir, window state, or config file (auto-detected)
 * @return Function - Closure that executes the command when called
 * 
 * @example
 * ; Simple command
 * RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
 * 
 * @example
 * ; With window state
 * RegisterKeymap("leader", "t", "cmd", "Terminal", ShellExec("cmd.exe", "Show"), false, 1)
 * 
 * @example
 * ; With working directory
 * RegisterKeymap("leader", "g", "s", "Git Status", ShellExec("git status", "C:\\Projects"), false, 1)
 * 
 * @example
 * ; With config file
 * RegisterKeymap("leader", "k", "r", "Reload Kanata", ShellExec("kanata.exe", "kanata.kbd"), false, 1)
 */
ShellExec(command, param2 := "", param3 := "", param4 := "") {
    ; ALWAYS return a function for RegisterKeymap usage
    return () => ShellExecNow(command, param2, param3, param4)
}

; ---- Internal execution function (immediate execution) ----
/**
 * ShellExecNow - Internal function for immediate command execution
 * 
 * DO NOT use this directly in RegisterKeymap - use ShellExec() instead.
 * This function executes immediately and does not return a closure.
 * 
 * @param command - Command to execute
 * @param param2 - Optional parameter (auto-detected)
 * @param param3 - Optional parameter (auto-detected)
 * @param param4 - Optional parameter (auto-detected)
 * @return Boolean - True if execution succeeded, false otherwise
 */
ShellExecNow(command, param2 := "", param3 := "", param4 := "") {
    ; Validate command parameter
    if (command == "") {
        Log.e("ShellExec called with empty command", "SHELL_EXEC")
        ShowCenteredToolTip("Error: Command cannot be empty")
        SetTimer(() => RemoveToolTip(), -2000)
        return false
    }
    
    ; Initialize variables
    workingDir := ""
    showWindow := "Hide"
    configFile := ""
    finalCommand := command
    argsAdded := false
    
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
            ; Only treat as config file (quoted) if it has no spaces/slashes AND actually exists
            if (configFile == "" && !InStr(param, " ") && !InStr(param, "/") && FileExist(param)) {
                configFile := param
            } else {
                ; It's a raw argument (has spaces, flags, or doesn't exist as a file)
                finalCommand .= " " . param
                argsAdded := true
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
    } else if (!argsAdded && !InStr(finalCommand, '"') && InStr(finalCommand, " ") && !InStr(finalCommand, " /")) {
        ; Quote the entire command ONLY if it looks like a path with spaces and NO arguments were added
        finalCommand := '"' . finalCommand . '"'
    }
    
    ; Log execution attempt
    try {
        Log.d("Executing: " . finalCommand . (workingDir ? " in " . workingDir : ""), "SHELL_EXEC")
        
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
        
        Log.d("Command executed successfully", "SHELL_EXEC")
        return true
        
    } catch Error as e {
        ; Log and show error with context
        errorMsg := "Failed to execute: " . finalCommand
        if (workingDir) {
            errorMsg .= "`nWorking Dir: " . workingDir
        }
        errorMsg .= "`nError: " . e.message
        
        ; Suggest common fixes
        if (InStr(e.message, "cannot find") || InStr(e.message, "not found")) {
            errorMsg .= "`n`nTip: Check if the file path is correct"
        } else if (InStr(e.message, "denied")) {
            errorMsg .= "`n`nTip: Try running as administrator"
        }
        
        Log.e("Failed to execute: " . finalCommand . " | Error: " . e.message, "SHELL_EXEC")
        ShowCenteredToolTip(errorMsg)
        SetTimer(() => RemoveToolTip(), -4000)
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
/**
 * ShellExecCapture - Execute command and capture its output
 * 
 * @param command - Command to execute
 * @param workingDir - Optional working directory
 * @return String - Command output, or empty string on error
 */
ShellExecCapture(command, workingDir := "") {
    if (command == "") {
        Log.e("ShellExecCapture called with empty command", "SHELL_EXEC")
        return ""
    }
    
    try {
        ; Use RunWait with output capture
        tempFile := A_Temp . "\shell_exec_output.txt"
        RunWait('cmd.exe /c "' . command . '" > "' . tempFile . '" 2>&1', workingDir, "Hide")
        
        if (FileExist(tempFile)) {
            output := FileRead(tempFile)
            FileDelete(tempFile)
            return output
        }
    } catch Error as e {
        ShowCenteredToolTip("Failed to capture output: " . e.message)
        SetTimer(() => RemoveToolTip(), -3000)
    }
    return ""
}

; ---- Execute and wait for completion ----
/**
 * ShellExecWait - Execute command and wait for completion
 * 
 * @param command - Command to execute
 * @param workingDir - Optional working directory
 * @param timeout - Optional timeout in milliseconds (0 = no timeout)
 * @return Integer - Exit code of the process, or -1 on error/timeout
 */
ShellExecWait(command, workingDir := "", timeout := 0) {
    if (command == "") {
        Log.e("ShellExecWait called with empty command", "SHELL_EXEC")
        return -1
    }
    
    try {
        if (timeout > 0) {
            return RunWait(command, workingDir, "Hide", timeout)
        } else {
            return RunWait(command, workingDir, "Hide")
        }
    } catch Error as e {
        ShowCenteredToolTip("Command execution failed or timed out")
        SetTimer(() => RemoveToolTip(), -2000)
        return -1
    }
}

; ---- Common system commands as convenience functions ----
/**
 * OpenExplorer - Open Windows Explorer in specified path
 * 
 * Returns a closure for RegisterKeymap compatibility.
 * 
 * @param path - Optional path to open (empty = default location)
 * @return Function - Closure that opens Explorer when called
 */
OpenExplorer(path := "") {
    if (path = "") {
        return () => ShellExecNow("explorer.exe", "", "Hide")
    } else {
        return () => ShellExecNow('explorer.exe "' . path . '"', "", "Hide")
    }
}

/**
 * OpenCmd - Open Command Prompt in specified path
 * 
 * @param path - Optional path to open (empty = default location)
 * @return Function - Closure that opens CMD when called
 */
OpenCmd(path := "") {
    if (path = "") {
        return () => ShellExecNow("cmd.exe", "", "Show")
    } else {
        return () => ShellExecNow('cmd.exe /k cd /d "' . path . '"', "", "Show")
    }
}

/**
 * OpenPowerShell - Open PowerShell in specified path
 * 
 * @param path - Optional path to open (empty = default location)
 * @return Function - Closure that opens PowerShell when called
 */
OpenPowerShell(path := "") {
    if (path = "") {
        return () => ShellExecNow("powershell.exe", "", "Show")
    } else {
        return () => ShellExecNow('powershell.exe -NoExit -Command "Set-Location \\"' . path . '\\""', "", "Show")
    }
}

; ---- Execute system utilities ----
OpenTaskManager() => ShellExecNow("taskmgr.exe", "", "Show")
OpenControlPanel() => ShellExecNow("control.exe", "", "Hide")
OpenDeviceManager() => ShellExecNow("devmgmt.msc", "", "Hide")
OpenEventViewer() => ShellExecNow("eventvwr.msc", "", "Hide")
OpenSystemInfo() => ShellExecNow("msinfo32.exe", "", "Hide")
OpenRegistryEditor() => ShellExecNow("regedit.exe", "", "Show")

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
ShellExec_SystemInfo() => ShellExecNow("msinfo32.exe", "", "Hide")
ShellExec_RegEdit() => ShellExecNow("regedit.exe", "", "Hide")
ShellExec_CMD() => ShellExecNow("cmd.exe", "", "Show")
ShellExec_PowerShell() => ShellExecNow("powershell.exe", "", "Show")
CheckPing(target := "8.8.8.8") => ShellExecCapture("ping -n 4 " . target)
GetSystemInfo() => ShellExecCapture("systeminfo")
ListProcesses() => ShellExecCapture("tasklist")
