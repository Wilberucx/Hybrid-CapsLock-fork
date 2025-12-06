; ===================================================================
; Notification System - Core Plugin
; ===================================================================
; Unified notification/feedback system for all plugins.
; Provides animated, type-based notifications using TooltipApp.
;
; Author: HybridCapsLock Team
; Version: 1.0.0
; ===================================================================

; ===================================================================
; PUBLIC API
; ===================================================================

/**
 * ShowTooltipFeedback - Display animated feedback notification
 * 
 * @param {String} message - The message to display
 * @param {String} type - Notification type: "info", "success", "warning", "error", "confirm"
 * @param {Integer} timeout - Auto-hide timeout in milliseconds (default: 2000)
 * 
 * @example
 * ShowTooltipFeedback("File saved successfully", "success")
 * ShowTooltipFeedback("Connection failed", "error", 3000)
 * ShowTooltipFeedback("Processing...", "info")
 */
ShowTooltipFeedback(message, type := "info", timeout := 2000) {
    global tooltipConfig
    
    ; Validate type
    validTypes := ["info", "success", "warning", "error", "confirm"]
    if (!HasValue(validTypes, type)) {
        type := "info"  ; Default to info if invalid type
    }
    
    ; Get notification config for this type
    config := GetNotificationConfig(type)
    
    ; Try TooltipApp first (animated, rich UI)
    if (IsTooltipAppAvailable()) {
        ShowAnimatedNotification(message, config, timeout)
    } else {
        ; Fallback to native ToolTip
        ShowNativeNotification(message, config, timeout)
    }
}

; ===================================================================
; INTERNAL FUNCTIONS
; ===================================================================

/**
 * GetNotificationConfig - Get styling config for notification type
 * @private
 */
GetNotificationConfig(type) {
    global HybridConfig
    
    ; Get current theme for colors
    theme := HybridConfig.getTheme()
    
    ; Base configuration with theme colors
    config := Map()
    config["icon"] := ""
    config["bgColor"] := theme.colors.background
    config["textColor"] := theme.colors.text
    config["borderColor"] := theme.colors.border
    
    ; Type-specific overrides (NerdFont icons + matching text color)
    switch type {
        case "info":
            config["icon"] := Chr(0xf05a)        ; NerdFont: 
            config["borderColor"] := "#3498db"  ; Blue
            config["textColor"] := "#3498db"    ; Text matches border
            
        case "success":
            config["icon"] := Chr(0xf00c)        ; NerdFont: 
            config["borderColor"] := "#27ae60"  ; Green
            config["textColor"] := "#27ae60"    ; Text matches border
            
        case "warning":
            config["icon"] := Chr(0xf071)        ; NerdFont: 
            config["borderColor"] := "#f39c12"  ; Orange
            config["textColor"] := "#f39c12"    ; Text matches border
            
        case "error":
            config["icon"] := Chr(0xf00d)        ; NerdFont: 
            config["borderColor"] := "#e74c3c"  ; Red
            config["textColor"] := "#e74c3c"    ; Text matches border
            
        case "confirm":
            config["icon"] := Chr(0xf059)        ; NerdFont: 
            config["borderColor"] := "#9b59b6"  ; Purple
            config["textColor"] := "#9b59b6"    ; Text matches border
    }
    
    return config
}

/**
 * ShowAnimatedNotification - Show notification using TooltipApp
 * @private
 */
ShowAnimatedNotification(message, config, timeout) {
    ; Get notification type label (e.g., "INFO", "ERROR", "SUCCESS")
    typeLabel := GetNotificationTypeLabel(config)
    
    ; Build title with icon and type label
    title := config["icon"] . " " . typeLabel
    
    ; Word-wrap the message manually to prevent off-screen rendering
    wrappedMessage := WrapText(message, 45)  ; ~45 chars per line for 400px width
    
    ; Build command directly (bypass menu system)
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := title  ; Icon + type label in title
    cmd["content"] := wrappedMessage  ; Wrapped message in content
    cmd["timeout_ms"] := timeout
    cmd["id"] := "notification_feedback"
    cmd["tooltip_type"] := "text_block"  ; Use text_block for multi-line support
    
    ; Position: top_left (temporary workaround for anchor bug)
    ; TODO: Change to top_right when TooltipApp supports right-side anchoring
    cmd["position"] := Map()
    cmd["position"]["anchor"] := "top_left"
    cmd["position"]["offset_x"] := 20
    cmd["position"]["offset_y"] := 20
    
    ; Style: notification design with explicit max_width
    cmd["style"] := Map()
    cmd["style"]["background"] := config["bgColor"]
    cmd["style"]["text"] := config["textColor"]  ; Matches border color
    cmd["style"]["border"] := config["borderColor"]
    cmd["style"]["border_thickness"] := 2
    cmd["style"]["padding"] := [12, 16, 12, 16]  ; Vertical padding for readability
    cmd["style"]["corner_radius"] := 6
    cmd["style"]["font_family"] := "JetBrainsMono Nerd Font"  ; NerdFont for icon rendering
    cmd["style"]["title_font_size"] := 13  ; Title (icon + label) size
    cmd["style"]["item_font_size"] := 11  ; Content text size
    cmd["style"]["max_width"] := 400  ; Hard limit to prevent off-screen rendering
    
    ; Animation: slide_left
    cmd["animation"] := Map()
    cmd["animation"]["type"] := "slide_left"
    cmd["animation"]["duration_ms"] := 300
    cmd["animation"]["easing"] := "ease_out"
    
    ; Window: topmost, click-through (non-interactive)
    cmd["window"] := Map()
    cmd["window"]["topmost"] := true
    cmd["window"]["click_through"] := true
    
    ; NO navigation, NO items → Pure notification (no BACK/ESC buttons)
    
    ; Send directly to TooltipApp
    try {
        StartTooltipApp()
        json := SerializeJson(cmd)
        
        Tooltip_SendRaw(json)
    } catch Error as e {
        ; If TooltipApp fails, fallback to native
        Log.w("TooltipApp failed, using native fallback: " . e.Message, "NOTIFICATION")
        ShowNativeNotification(message, config, timeout)
    }
}

/**
 * ShowNativeNotification - Fallback to native AutoHotkey ToolTip
 * @private
 */
ShowNativeNotification(message, config, timeout) {
    ; Use dedicated ID 19 for notifications
    fullMessage := config["icon"] . " " . message
    ToolTip(fullMessage, , , 19)
    SetTimer(() => ToolTip(, , , 19), -timeout)
}

/**
 * IsTooltipAppAvailable - Check if TooltipApp C# is running
 * @private
 */
IsTooltipAppAvailable() {
    ; Check if TooltipApp.exe process exists
    try {
        if (ProcessExist("TooltipApp.exe")) {
            return true
        }
    } catch {
        return false
    }
    return false
}

/**
 * GetNotificationTypeLabel - Get uppercase label for notification type
 * @private
 */
GetNotificationTypeLabel(config) {
    ; Extract type from border color mapping
    switch config["borderColor"] {
        case "#3498db":  ; Blue = Info
            return "INFO"
        case "#27ae60":  ; Green = Success
            return "SUCCESS"
        case "#f39c12":  ; Orange = Warning
            return "WARNING"
        case "#e74c3c":  ; Red = Error
            return "ERROR"
        case "#9b59b6":  ; Purple = Confirm
            return "CONFIRM"
        default:
            return "NOTIFICATION"
    }
}

/**
 * WrapText - Manually wrap text to specified character width
 * @private
 */
WrapText(text, maxCharsPerLine) {
    if (StrLen(text) <= maxCharsPerLine) {
        return text  ; No wrapping needed
    }
    
    words := StrSplit(text, " ")
    lines := []
    currentLine := ""
    
    for _, word in words {
        testLine := (currentLine = "") ? word : (currentLine . " " . word)
        
        if (StrLen(testLine) <= maxCharsPerLine) {
            currentLine := testLine
        } else {
            ; Current line is full, save it and start new line
            if (currentLine != "") {
                lines.Push(currentLine)
            }
            currentLine := word
        }
    }
    
    ; Add last line
    if (currentLine != "") {
        lines.Push(currentLine)
    }
    
    ; Join with newlines
    result := ""
    for i, line in lines {
        result .= line
        if (i < lines.Length) {
            result .= "`n"
        }
    }
    
    return result
}

/**
 * HasValue - Check if array contains value
 * @private
 */
HasValue(arr, val) {
    for _, v in arr {
        if (v == val) {
            return true
        }
    }
    return false
}

; ===================================================================
; INITIALIZATION
; ===================================================================

Log.i("Notification system loaded", "NOTIFICATION")
