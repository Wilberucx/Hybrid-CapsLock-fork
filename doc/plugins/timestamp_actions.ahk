; ==============================
; Timestamp Actions Plugin
; ==============================
; Insert current date/time in various formats using clipboard for speed

; ==============================
; HELPER FUNCTIONS
; ==============================

ShowTimestampFeedback(message) {
    ; Use native tooltip with dedicated ID 18 for Timestamp Actions
    ToolTip(message, , , 18)
    SetTimer(() => ToolTip(, , , 18), -2000)
}

InsertTimestampText(text, description) {
    ; Save current clipboard content (including non-text data)
    savedClip := ClipboardAll()
    
    ; Set clipboard to new text
    A_Clipboard := text
    
    ; Wait for clipboard to update (timeout 0.5s)
    if !ClipWait(0.5) {
        ; Fallback to SendText if clipboard fails
        SendText(text)
    } else {
        ; Use centralized paste shortcut detection
        shortcut := GetPasteShortcut()
        Send(shortcut)
        
        ; Restore original clipboard after a short delay to ensure paste is complete
        SetTimer(() => A_Clipboard := savedClip, -200)
    }
    
    tooltipMsg := description ? description . ": " . text : "TIMESTAMP: " . text
    ShowTimestampFeedback(tooltipMsg)
}

; ==============================
; CORE TIMESTAMP FUNCTION
; ==============================

/**
 * InsertTimestamp - Generic timestamp inserter
 * @param format - AutoHotkey time format string
 * @param description - Optional description for tooltip
 */
InsertTimestamp(format, description := "") {
    return () => InsertTimestampNow(format, description)
}

InsertTimestampNow(format, description := "") {
    timestamp := FormatTime(, format)
    InsertTimestampText(timestamp, description)
}

; ===================================================================
; DEFAULT KEYMAPS
; ===================================================================

; Category timestamps (leader → t → KEY)
RegisterCategoryKeymap("leader", "t", "Timestamps", 2)

; Date formats (leader → t → d → KEY)
RegisterCategoryKeymap("leader", "t", "d", "Date Formats", 1)
RegisterKeymap("leader", "t", "d", "1", "yyyy-MM-dd", InsertTimestamp("yyyy-MM-dd", "ISO Date"), false, 1)
RegisterKeymap("leader", "t", "d", "2", "dd/MM/yyyy", InsertTimestamp("dd/MM/yyyy", "EU Date"), false, 2)
RegisterKeymap("leader", "t", "d", "3", "MM/dd/yyyy", InsertTimestamp("MM/dd/yyyy", "US Date"), false, 3)
RegisterKeymap("leader", "t", "d", "4", "dd-MMM-yyyy", InsertTimestamp("dd-MMM-yyyy", "Month Name"), false, 4)
RegisterKeymap("leader", "t", "d", "5", "ddd, dd MMM yyyy", InsertTimestamp("ddd, dd MMM yyyy", "Full Date"), false, 5)
RegisterKeymap("leader", "t", "d", "6", "yyyyMMdd", InsertTimestamp("yyyyMMdd", "Compact Date"), false, 6)
RegisterKeymap("leader", "t", "d", "d", "Default (yyyyMMdd)", InsertTimestamp("yyyyMMdd", "Compact Date"), false, 7)

; Time formats (leader → t → t → KEY)
RegisterCategoryKeymap("leader", "t", "t", "Time Formats", 2)
RegisterKeymap("leader", "t", "t", "1", "HH:mm:ss", InsertTimestamp("HH:mm:ss", "24H Time"), false, 1)
RegisterKeymap("leader", "t", "t", "2", "HH:mm", InsertTimestamp("HH:mm", "24H Short"), false, 2)
RegisterKeymap("leader", "t", "t", "3", "hh:mm tt", InsertTimestamp("hh:mm tt", "12H Time"), false, 3)
RegisterKeymap("leader", "t", "t", "4", "HHmmss", InsertTimestamp("HHmmss", "Compact Time"), false, 4)
RegisterKeymap("leader", "t", "t", "5", "HH.mm.ss", InsertTimestamp("HH.mm.ss", "Dotted Time"), false, 5)
RegisterKeymap("leader", "t", "t", "t", "Default (HHmmss)", InsertTimestamp("HHmmss", "Compact Time"), false, 6)

; DateTime formats (leader → t → h → KEY)
RegisterCategoryKeymap("leader", "t", "h", "Date+Time Formats", 3)
RegisterKeymap("leader", "t", "h", "1", "yyyy-MM-dd HH:mm:ss", InsertTimestamp("yyyy-MM-dd HH:mm:ss", "ISO DateTime"), false, 1)
RegisterKeymap("leader", "t", "h", "2", "dd/MM/yyyy HH:mm", InsertTimestamp("dd/MM/yyyy HH:mm", "EU DateTime"), false, 2)
RegisterKeymap("leader", "t", "h", "3", "yyyy-MM-dd HH:mm:ss", InsertTimestamp("yyyy-MM-dd HH:mm:ss", "ISO DateTime"), false, 3)
RegisterKeymap("leader", "t", "h", "4", "yyyyMMddHHmmss", InsertTimestamp("yyyyMMddHHmmss", "Compact DateTime"), false, 4)
RegisterKeymap("leader", "t", "h", "5", "ddd, dd MMM yyyy HH:mm", InsertTimestamp("ddd, dd MMM yyyy HH:mm", "Full DateTime"), false, 5)
RegisterKeymap("leader", "t", "h", "h", "Default (yyyyMMddHHmmss)", InsertTimestamp("yyyyMMddHHmmss", "Compact DateTime"), false, 6)
