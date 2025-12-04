; ==============================
; Kanata Manager Plugin
; ==============================
; Core plugin for managing Kanata lifecycle
; Uses native AutoHotkey v2 functions with shell.Exec for output capture
;
; API:
;   KanataStart()              - Start Kanata if not running
;   KanataStop()               - Stop Kanata if running
;   KanataRestart()            - Restart Kanata
;   KanataToggle()             - Toggle Kanata on/off
;   KanataIsRunning()          - Check if Kanata is running
;   KanataGetPID()             - Get Kanata process ID
;   KanataGetStatus()          - Get status string ("Running" / "Stopped")
;   KanataShowStatus()         - Display status in tooltip
;   KanataStartWithRetry()     - Start with automatic retry logic

; ==============================
; CONFIGURATION
; ==============================

; Initialize config if not already set
if (!IsSet(HybridConfig) || !HybridConfig.HasOwnProp("kanata")) {
    if (!IsSet(HybridConfig)) {
        global HybridConfig := {}
    }
    
    HybridConfig.kanata := {
        enabled: true,                              ; Enable Kanata management
        exePath: "kanata.exe",                      ; Kanata binary path (can be full path or in PATH)
        configFile: "ahk\config\kanata.kbd",        ; Config file path (relative to script dir)
        startDelay: 500,                            ; Milliseconds to wait after starting
        autoStart: true,                            ; Start Kanata automatically with HybridCapsLock
        fallbackPaths: [                            ; Paths to search for kanata.exe
            A_ScriptDir . "\bin\kanata.exe",
            A_ScriptDir . "\kanata.exe",
            "C:\Program Files\kanata\kanata.exe",
            A_AppData . "\..\Local\kanata\kanata.exe"
        ]
    }
}

; ==============================
; INTERNAL HELPERS
; ==============================

/**
 * Resolve Kanata executable path
 * Searches configured path and fallback locations
 * @returns {String} Full path to kanata.exe or empty string if not found
 */
ResolveKanataPath() {
    global HybridConfig
    
    ; Check configured path first
    kanataPath := HybridConfig.kanata.exePath
    
    ; If it's a full path and exists, use it
    if (FileExist(kanataPath)) {
        return kanataPath
    }
    
    ; Check if it's in PATH (try to run it)
    try {
        ; Test if command exists in PATH
        RunWait('where "' . kanataPath . '"', , "Hide")
        return kanataPath  ; Found in PATH
    }
    
    ; Search fallback paths
    for fallbackPath in HybridConfig.kanata.fallbackPaths {
        if (FileExist(fallbackPath)) {
            return fallbackPath
        }
    }
    
    ; Not found, return configured path anyway (let it fail with error)
    return kanataPath
}

/**
 * Get full path to Kanata config file
 * @returns {String} Full path to config file
 */
GetKanataConfigPath() {
    global HybridConfig
    configPath := HybridConfig.kanata.configFile
    
    ; If relative path, make it absolute
    if (!InStr(configPath, ":\") && !InStr(configPath, "\\")) {
        return A_ScriptDir . "\" . configPath
    }
    
    return configPath
}

/**
 * Log error message (integrates with HybridCapsLock logging system)
 * @param {String} message - Error message
 */
LogKanataError(message) {
    ; Try to use HybridCapsLock logging system
    try {
        LogError(message, "KANATA")
    } catch {
        ; Fallback: silent if logging system not available
        ; This is acceptable for Kanata (optional component)
    }
}

/**
 * Log info message
 * @param {String} message - Info message
 */
LogKanataInfo(message) {
    try {
        LogInfo(message, "KANATA")
    } catch {
        ; Fallback: silent if logging system not available
    }
}

/**
 * Execute command and capture output (STDOUT + STDERR) using shell.Exec
 * MUCH SIMPLER AND MORE RELIABLE than PowerShell workarounds
 * 
 * @param {String} cmd - Command to execute
 * @param {Integer} timeout - Timeout in milliseconds (default: 5000)
 * @returns {Object} {exitCode: Integer, stdout: String, stderr: String, timedOut: Boolean}
 */
RunWithOutput(cmd, timeout := 5000) {
    result := {
        exitCode: -1,
        stdout: "",
        stderr: "",
        timedOut: false
    }
    
    try {
        ; Create WScript.Shell COM object
        shell := ComObject("WScript.Shell")
        
        ; Execute command and get execution object
        ; This runs the command and gives us access to its streams
        exec := shell.Exec(cmd)
        
        ; Wait for process to complete (with timeout)
        startTime := A_TickCount
        while (!exec.Status) {  ; Status = 0 (running), 1 (finished)
            if (A_TickCount - startTime > timeout) {
                result.timedOut := true
                break
            }
            Sleep(50)  ; Check every 50ms
        }
        
        ; Capture STDOUT (normal output)
        if (!exec.StdOut.AtEndOfStream) {
            result.stdout := exec.StdOut.ReadAll()
        }
        
        ; Capture STDERR (error output)
        if (!exec.StdErr.AtEndOfStream) {
            result.stderr := exec.StdErr.ReadAll()
        }
        
        ; Get exit code (only valid if process finished)
        if (!result.timedOut) {
            result.exitCode := exec.ExitCode
        }
        
    } catch as err {
        ; If shell.Exec fails, populate error in stderr
        result.stderr := "shell.Exec failed: " . err.Message
        result.exitCode := -1
    }
    
    return result
}

/**
 * Parse Kanata error output and extract meaningful information
 * NOW HANDLES BOTH STDOUT AND STDERR
 * @param {String} stdout - Standard output from Kanata
 * @param {String} stderr - Standard error from Kanata
 * @returns {Object} {type: String, message: String, line: Integer, file: String, context: String}
 */
ParseKanataError(stdout, stderr) {
    ; Combine both outputs for parsing (Kanata may use either)
    output := stderr . "`n" . stdout
    
    errorInfo := {
        type: "UNKNOWN",
        message: "",
        line: 0,
        file: "",
        context: "",
        rawOutput: output
    }
    
    if (output = "" || Trim(output) = "") {
        errorInfo.type := "NO_OUTPUT"
        errorInfo.message := "Kanata produced no output (may have crashed immediately)"
        return errorInfo
    }
    
    ; ========================================
    ; KANATA-SPECIFIC ERROR PATTERNS (v1.7+)
    ; ========================================
    
    ; Pattern 1: Modern Kanata error format with fancy box display
    ; Example: "╭─[kanata.kbd:12:1]" or "──[C:\path\kanata.kbd:72:1]" (encoding may be broken)
    ; Regex handles Windows paths with drive letters (C:\...) and line:col format
    ; Match: [ANYTHING.kbd:NUMBER:NUMBER]
    if (RegExMatch(output, "i)\[(.+\.kbd):(\d+):(\d+)\]", &fileMatch)) {
        errorInfo.type := "SYNTAX_ERROR"
        errorInfo.file := fileMatch[1]
        errorInfo.line := Integer(fileMatch[2])
        
        ; Extract the help message (contains the actual error)
        if (RegExMatch(output, "i)help:\s*(.+?)(?:\n\n|For more info)", &helpMatch)) {
            errorInfo.message := Trim(helpMatch[1])
        }
        
        ; If no help message, try to get "Error here" line
        if (errorInfo.message = "" && RegExMatch(output, "Error here", &errMatch)) {
            errorInfo.message := "Syntax error detected (see line number above)"
        }
        
        ; Extract context lines (the code snippet) - more tolerant pattern
        if (RegExMatch(output, "s)(\d+)\s*[│â]\s*(.+?)(?:\n|$)", &contextMatch)) {
            errorInfo.context := "Line " . contextMatch[1] . ": " . Trim(contextMatch[2])
        }
    }
    
    ; Pattern 2: Legacy "failed to parse file" (Kanata older versions)
    ; Example: "Error in configuration" followed by "failed to parse file"
    else if (RegExMatch(output, "i)Error in configuration", &match)) {
        errorInfo.type := "SYNTAX_ERROR"
        
        ; Try to find line number in format [file:line:col]
        if (RegExMatch(output, "\[([^:]+):(\d+):(\d+)\]", &coordMatch)) {
            errorInfo.file := coordMatch[1]
            errorInfo.line := Integer(coordMatch[2])
        }
        
        ; Get the help message if available
        if (RegExMatch(output, "i)help:\s*(.+?)(?:\n\n|For more)", &helpMatch)) {
            errorInfo.message := Trim(helpMatch[1])
        } else if (RegExMatch(output, "i)failed to parse file", &match)) {
            errorInfo.message := "Failed to parse configuration file"
        }
    }
    
    ; Pattern 3: Parse error with line number (generic format)
    ; Example: "Error: Parse error at line 42 in file kanata.kbd: unexpected token"
    else if (RegExMatch(output, "i)(?:parse\s+)?error.*line\s+(\d+)", &lineMatch)) {
        errorInfo.type := "SYNTAX_ERROR"
        errorInfo.line := Integer(lineMatch[1])
        
        ; Try to extract the actual error message
        if (RegExMatch(output, "i)error[:\s]+(.+?)(?:\n|$)", &msgMatch)) {
            errorInfo.message := Trim(msgMatch[1])
        }
    }
    
    ; Pattern 4: Port already in use
    ; Example: "Error: Address already in use (os error 48)"
    else if (RegExMatch(output, "i)address\s+already\s+in\s+use", &match)) {
        errorInfo.type := "PORT_IN_USE"
        errorInfo.message := "Kanata port already in use (another instance running or port blocked)"
        
        ; Try to extract port number
        if (RegExMatch(output, "i)port\s+(\d+)", &portMatch)) {
            errorInfo.context := "Port: " . portMatch[1]
        }
    }
    
    ; Pattern 5: File not found / Permission denied
    else if (RegExMatch(output, "i)(?:no\s+such\s+file|permission\s+denied|access\s+denied)", &match)) {
        errorInfo.type := "FILE_ERROR"
        errorInfo.message := "File access error (config not found or permission denied)"
    }
    
    ; Pattern 6: Invalid configuration key
    ; Example: "Error: unknown key name 'invalidkey'"
    else if (RegExMatch(output, "i)unknown\s+key\s+name\s+['\`"]([^'\`"]+)", &keyMatch)) {
        errorInfo.type := "INVALID_KEY"
        errorInfo.message := "Invalid key name: '" . keyMatch[1] . "'"
    }
    
    ; Pattern 7: Generic panic/error
    else if (RegExMatch(output, "i)(?:panic|fatal)\s*:\s*(.+?)(?:\n|$)", &panicMatch)) {
        errorInfo.type := "RUNTIME_ERROR"
        errorInfo.message := Trim(panicMatch[1])
    }
    
    ; Pattern 8: Process not found (kanata.exe doesn't exist)
    else if (RegExMatch(output, "i)is not recognized as|not found", &match)) {
        errorInfo.type := "NOT_FOUND"
        errorInfo.message := "kanata.exe not found in PATH or specified location"
    }
    
    ; Pattern 9: Generic ERROR tag from Kanata logging
    else if (RegExMatch(output, "i)\[ERROR\]\s*(.+?)(?:\n|$)", &errorTagMatch)) {
        errorInfo.type := "RUNTIME_ERROR"
        errorInfo.message := Trim(errorTagMatch[1])
    }
    
    ; Fallback: If we still don't have a message, use first meaningful line
    if (errorInfo.message = "" && output != "") {
        ; Get first non-empty line that looks like an error
        lines := StrSplit(output, "`n", "`r")
        for line in lines {
            trimmed := Trim(line)
            ; Skip ANSI color codes and timestamp lines
            if (trimmed != "" && StrLen(trimmed) > 5 && !RegExMatch(trimmed, "^\d+:\d+:\d+")) {
                if (InStr(trimmed, "error") || InStr(trimmed, "Error") || InStr(trimmed, "failed")) {
                    errorInfo.message := trimmed
                    break
                }
            }
        }
    }
    
    ; Final cleanup: Remove ANSI color codes and box-drawing characters
    if (errorInfo.message != "") {
        ; Remove ANSI escape sequences (e.g., [0m, [31m, etc.)
        errorInfo.message := RegExReplace(errorInfo.message, "\x1b\[[0-9;]*m", "")
        
        ; Remove box-drawing characters that MsgBox can't render properly
        errorInfo.message := StrReplace(errorInfo.message, "╭", "+")
        errorInfo.message := StrReplace(errorInfo.message, "╰", "+")
        errorInfo.message := StrReplace(errorInfo.message, "│", "|")
        errorInfo.message := StrReplace(errorInfo.message, "├", "+")
        errorInfo.message := StrReplace(errorInfo.message, "┬", "+")
        errorInfo.message := StrReplace(errorInfo.message, "─", "-")
        
        errorInfo.message := Trim(errorInfo.message)
    }
    
    ; Also clean context if present
    if (errorInfo.context != "") {
        errorInfo.context := RegExReplace(errorInfo.context, "\x1b\[[0-9;]*m", "")
        errorInfo.context := StrReplace(errorInfo.context, "╭", "+")
        errorInfo.context := StrReplace(errorInfo.context, "╰", "+")
        errorInfo.context := StrReplace(errorInfo.context, "│", "|")
        errorInfo.context := StrReplace(errorInfo.context, "├", "+")
        errorInfo.context := StrReplace(errorInfo.context, "┬", "+")
        errorInfo.context := StrReplace(errorInfo.context, "─", "-")
        errorInfo.context := Trim(errorInfo.context)
    }
    
    return errorInfo
}

/**
 * Show detailed error dialog to user
 * @param {Object} errorInfo - Parsed error object from ParseKanataError()
 * @param {String} configPath - Path to config file
 */
ShowKanataErrorDialog(errorInfo, configPath) {
    ; Build user-friendly error message
    title := "Kanata Error"
    icon := 16  ; Error icon
    
    message := "❌ Kanata failed to start`n`n"
    
    ; Error type specific messages
    switch errorInfo.type {
        case "SYNTAX_ERROR":
            title := "Kanata - Syntax Error"
            icon := 48  ; Warning icon
            message .= "🔴 SYNTAX ERROR in your kanata.kbd file`n`n"
            if (errorInfo.line > 0) {
                message .= "📍 Line: " . errorInfo.line . "`n"
            }
            if (errorInfo.message != "") {
                message .= "💬 " . errorInfo.message . "`n"
            }
            if (errorInfo.context != "" && StrLen(errorInfo.context) < 200) {
                message .= "`nContext:`n" . errorInfo.context . "`n"
            }
            message .= "`n📁 Config: " . configPath . "`n`n"
            message .= "🔧 FIX: Open your kanata.kbd file and fix the syntax error.`n"
            message .= '💡 TIP: Run "kanata --cfg ' . Chr(34) . configPath . Chr(34) . '" in a terminal to see full details.'
            
        case "PORT_IN_USE":
            title := "Kanata - Port Conflict"
            message .= "🔴 NETWORK PORT ALREADY IN USE`n`n"
            message .= "💬 " . errorInfo.message . "`n"
            if (errorInfo.context != "") {
                message .= "📍 " . errorInfo.context . "`n"
            }
            message .= "`n🔧 FIX: Another Kanata instance is running OR another program is using the port.`n"
            message .= "• Check Task Manager for kanata.exe processes`n"
            message .= "• Change the port in your kanata.kbd config (defcfg section)"
            
        case "INVALID_KEY":
            title := "Kanata - Invalid Key"
            icon := 48
            message .= "🔴 INVALID KEY DEFINITION`n`n"
            message .= "💬 " . errorInfo.message . "`n`n"
            message .= "📁 Config: " . configPath . "`n`n"
            message .= "🔧 FIX: Check your key names in the kanata.kbd file.`n"
            message .= "💡 TIP: Valid key names are listed in Kanata documentation."
            
        case "NOT_FOUND":
            title := "Kanata - Not Found"
            message .= "🔴 KANATA.EXE NOT FOUND`n`n"
            message .= "💬 kanata.exe is not installed or not in PATH`n`n"
            message .= "🔧 FIX:`n"
            message .= "• Install Kanata from: https://github.com/jtroo/kanata`n"
            message .= "• Add kanata.exe to your PATH`n"
            message .= "• Or configure full path in settings.ahk"
            
        case "FILE_ERROR":
            title := "Kanata - File Error"
            message .= "🔴 CONFIG FILE ACCESS ERROR`n`n"
            message .= "💬 " . errorInfo.message . "`n`n"
            message .= "📁 Config: " . configPath . "`n`n"
            message .= "🔧 FIX: Check that the config file exists and you have read permissions."
            
        case "NO_OUTPUT":
            title := "Kanata - Crashed Immediately"
            message .= "🔴 KANATA CRASHED IMMEDIATELY`n`n"
            message .= "💬 Kanata process died without producing error output`n`n"
            message .= "🔧 POSSIBLE CAUSES:`n"
            message .= "• Missing DLL dependencies`n"
            message .= "• Antivirus blocking execution`n"
            message .= "• Corrupted binary`n`n"
            message .= "💡 TIP: Run kanata.exe manually in a terminal to see error messages."
            
        default:
            title := "Kanata - Runtime Error"
            message .= "🔴 RUNTIME ERROR`n`n"
            if (errorInfo.message != "") {
                message .= "💬 " . errorInfo.message . "`n`n"
            }
            message .= "📁 Config: " . configPath . "`n`n"
            message .= '💡 TIP: Run "kanata --cfg ' . Chr(34) . configPath . Chr(34) . '" in terminal for details.'
    }
    
    ; Add raw output section for debugging (only if error type is UNKNOWN or parsing failed)
    if (errorInfo.type = "UNKNOWN" || (errorInfo.message = "" && errorInfo.rawOutput != "")) {
        ; Clean ANSI codes from raw output before displaying
        cleanOutput := RegExReplace(errorInfo.rawOutput, "\x1b\[[0-9;]*m", "")
        
        ; Clean box-drawing characters
        cleanOutput := StrReplace(cleanOutput, "╭", "+")
        cleanOutput := StrReplace(cleanOutput, "╰", "+")
        cleanOutput := StrReplace(cleanOutput, "│", "|")
        cleanOutput := StrReplace(cleanOutput, "├", "+")
        cleanOutput := StrReplace(cleanOutput, "┬", "+")
        cleanOutput := StrReplace(cleanOutput, "─", "-")
        
        outputPreview := SubStr(cleanOutput, 1, 300)
        if (StrLen(cleanOutput) > 300) {
            outputPreview .= "..."
        }
        message .= "`n`n--- Raw Output (first 300 chars) ---`n" . outputPreview
    }
    
    ; Show dialog
    MsgBox(message, title, icon)
    
    ; Log full error for debugging
    LogKanataError("Kanata error detected - Type: " . errorInfo.type . " | Message: " . errorInfo.message)
    if (errorInfo.rawOutput != "") {
        LogKanataError("Raw output: " . errorInfo.rawOutput)
    }
}

; ==============================
; CORE API
; ==============================

/**
 * Start Kanata if not already running
 * NOW WITH PROPER ERROR CAPTURE using shell.Exec
 * @returns {Boolean} true if started successfully or already running, false on error
 */
KanataStart() {
    global HybridConfig
    
    ; Check if already running
    if (KanataIsRunning()) {
        LogKanataInfo("Kanata already running")
        return true
    }
    
    ; Check if Kanata management is enabled
    if (!HybridConfig.kanata.enabled) {
        LogKanataInfo("Kanata management disabled in config")
        return false
    }
    
    ; Resolve paths
    kanataPath := ResolveKanataPath()
    configPath := GetKanataConfigPath()
    
    ; Verify config file exists
    if (!FileExist(configPath)) {
        errorMsg := "Kanata config file not found:`n`n" . configPath . "`n`nPlease check your settings.ahk configuration."
        MsgBox(errorMsg, "Kanata Error: Config Not Found", 16)
        LogKanataError("Config file not found: " . configPath)
        return false
    }
    
    LogKanataInfo("Starting Kanata - Path: " . kanataPath . " | Config: " . configPath)
    
    ; Build command (--check flag validates config without running)
    cmdValidate := '"' . kanataPath . '" --cfg "' . configPath . '" --check'
    cmdRun := '"' . kanataPath . '" --cfg "' . configPath . '"'
    
    ; STEP 1: Validation run using shell.Exec
    LogKanataInfo("Step 1: Validating config with --check flag...")
    testResult := RunWithOutput(cmdValidate, 3000)  ; 3 second timeout
    
    ; Check validation results
    hasErrors := false
    errorInfo := ""
    
    ; If exit code is non-zero OR stderr/stdout contains errors, parse them
    if (testResult.exitCode != 0 || testResult.stderr != "" || InStr(testResult.stdout, "error") || InStr(testResult.stdout, "Error")) {
        ; Parse combined output
        parsedError := ParseKanataError(testResult.stdout, testResult.stderr)
        
        ; Only treat as error if we found actual error patterns
        if (parsedError.type != "UNKNOWN" || testResult.exitCode != 0) {
            hasErrors := true
            errorInfo := parsedError
            LogKanataError("Validation failed - Exit code: " . testResult.exitCode . " | Type: " . parsedError.type)
        }
    }
    
    ; If validation found errors, show detailed error and abort
    if (hasErrors && errorInfo != "") {
        ; DEBUG: Log raw output to see what we're getting
        LogKanataError("RAW STDOUT: " . testResult.stdout)
        LogKanataError("RAW STDERR: " . testResult.stderr)
        LogKanataError("PARSED - Type: " . errorInfo.type . " | Line: " . errorInfo.line . " | Msg: " . errorInfo.message)
        
        ShowKanataErrorDialog(errorInfo, configPath)
        return false
    }
    
    ; STEP 2: Start Kanata in background (validation passed)
    LogKanataInfo("Step 2: Config validated, starting Kanata in background...")
    
    try {
        ; Start Kanata hidden (no window)
        Run(cmdRun, , "Hide")
        
        ; Wait for process to initialize
        Sleep(500)
        
        ; Verify process started
        if (!ProcessExist("kanata.exe")) {
            LogKanataError("Kanata process not found after start attempt")
            
            notFoundError := {
                type: "NOT_FOUND",
                message: "kanata.exe not found in PATH or specified location",
                line: 0,
                file: "",
                context: "Path checked: " . kanataPath,
                rawOutput: ""
            }
            ShowKanataErrorDialog(notFoundError, configPath)
            return false
        }
        
        ; Wait a bit more and check if it crashed immediately
        Sleep(1000)
        
        if (!ProcessExist("kanata.exe")) {
            LogKanataError("Kanata process crashed immediately after start")
            
            crashError := {
                type: "NO_OUTPUT",
                message: "Kanata started but crashed immediately (passed validation but failed in background mode)",
                line: 0,
                file: "",
                context: "",
                rawOutput: "Process started but died within 1 second"
            }
            ShowKanataErrorDialog(crashError, configPath)
            return false
        }
        
        ; Success!
        pid := ProcessExist("kanata.exe")
        LogKanataInfo("Kanata started successfully - PID: " . pid)
        return true
        
    } catch as err {
        LogKanataError("Exception while starting Kanata: " . err.Message)
        
        exceptionError := {
            type: "RUNTIME_ERROR",
            message: "Exception while starting Kanata: " . err.Message,
            line: 0,
            file: "",
            context: "Command: " . cmdRun,
            rawOutput: ""
        }
        ShowKanataErrorDialog(exceptionError, configPath)
        return false
    }
}

/**
 * Stop Kanata if running
 * @returns {Boolean} true if stopped successfully or not running, false on error
 */
KanataStop() {
    if (!KanataIsRunning()) {
        return true
    }
    
    try {
        ProcessClose("kanata.exe")
        Sleep(200)
        
        if (!KanataIsRunning()) {
            LogKanataInfo("Kanata stopped successfully")
            return true
        } else {
            LogKanataError("Kanata process did not stop")
            return false
        }
    } catch as err {
        LogKanataError("Failed to stop Kanata: " . err.Message)
        return false
    }
}

/**
 * Restart Kanata (stop + start)
 * @returns {Boolean} true if restarted successfully, false on error
 */
KanataRestart() {
    KanataStop()
    Sleep(300)
    return KanataStart()
}

/**
 * Toggle Kanata on/off
 * @returns {Boolean} true if Kanata is running after toggle, false if stopped
 */
KanataToggle() {
    if (KanataIsRunning()) {
        KanataStop()
        return false
    } else {
        KanataStart()
        return true
    }
}

/**
 * Check if Kanata is running
 * @returns {Boolean} true if running, false if not
 */
KanataIsRunning() {
    return ProcessExist("kanata.exe") ? true : false
}

/**
 * Get Kanata process ID
 * @returns {Integer} PID if running, 0 if not
 */
KanataGetPID() {
    return ProcessExist("kanata.exe")
}

; ==============================
; EXTENDED API
; ==============================

/**
 * Start Kanata with retry logic
 * @param {Integer} maxRetries - Maximum number of retry attempts (default: 3)
 * @param {Integer} retryDelay - Delay between retries in milliseconds (default: 1000)
 * @returns {Boolean} true if started successfully, false if all retries failed
 */
KanataStartWithRetry(maxRetries := 3, retryDelay := 1000) {
    LogKanataInfo("Starting Kanata with retry logic (max retries: " . maxRetries . ")")
    
    Loop maxRetries {
        LogKanataInfo("Attempt " . A_Index . "/" . maxRetries)
        
        if (KanataStart()) {
            LogKanataInfo("Kanata started successfully on attempt " . A_Index)
            return true
        }
        
        if (A_Index < maxRetries) {
            LogKanataInfo("Attempt " . A_Index . " failed, waiting " . retryDelay . "ms before retry...")
            Sleep(retryDelay)
        }
    }
    
    LogKanataError("Failed to start Kanata after " . maxRetries . " attempts")
    return false
}

/**
 * Get Kanata status as human-readable string
 * @returns {String} "Running" or "Stopped"
 */
KanataGetStatus() {
    return KanataIsRunning() ? "Running" : "Stopped"
}

/**
 * Display Kanata status in tooltip
 * @param {Integer} duration - Duration in milliseconds (default: 1500)
 */
KanataShowStatus(duration := 1500) {
    status := KanataGetStatus()
    pid := KanataGetPID()
    
    message := "Kanata: " . status
    if (pid) {
        message .= " (PID: " . pid . ")"
    }
    
    ToolTip(message)
    SetTimer(() => ToolTip(), -duration)
}

; ==============================
; AUTO-START
; ==============================

; Auto-start Kanata if configured
if (IsSet(HybridConfig) && HybridConfig.kanata.autoStart) {
    KanataStart()
}
