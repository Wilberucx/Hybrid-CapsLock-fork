; ==============================
; Timestamp Actions - Reusable Functions
; ==============================
; Extracted from timestamps_layer.ahk to follow declarative architecture
; Each function inserts a timestamp with specific format

; ==============================
; CORE TIMESTAMP FUNCTION (DRY Principle)
; ==============================

/**
 * InsertTimestamp - Generic timestamp inserter
 * @param format - AutoHotkey time format string
 * @param description - Optional description for tooltip
 */
InsertTimestamp(format, description := "") {
    timestamp := FormatTime(, format)
    SendText(timestamp)
    tooltipMsg := description ? description . ": " . timestamp : "TIMESTAMP: " . timestamp
    ShowCenteredToolTip(tooltipMsg)
    SetTimer(() => RemoveToolTip(), -2000)
}

; ==============================
; DATE FORMATS
; ==============================

InsertDateFormat1() {
    InsertTimestamp("yyyy-MM-dd", "ISO Date")
}

InsertDateFormat2() {
    InsertTimestamp("dd/MM/yyyy", "EU Date")
}

InsertDateFormat3() {
    InsertTimestamp("MM/dd/yyyy", "US Date")
}

InsertDateFormat4() {
    InsertTimestamp("dd-MMM-yyyy", "Month Name")
}

InsertDateFormat5() {
    InsertTimestamp("ddd, dd MMM yyyy", "Full Date")
}

InsertDateFormat6() {
    InsertTimestamp("yyyyMMdd", "Compact Date")
}

InsertDateDefault() {
    InsertDateFormat6()  ; Default is format 6
}

; ==============================
; TIME FORMATS
; ==============================

InsertTimeFormat1() {
    InsertTimestamp("HH:mm:ss", "24H Time")
}

InsertTimeFormat2() {
    InsertTimestamp("HH:mm", "24H Short")
}

InsertTimeFormat3() {
    InsertTimestamp("hh:mm tt", "12H Time")
}

InsertTimeFormat4() {
    InsertTimestamp("HHmmss", "Compact Time")
}

InsertTimeFormat5() {
    InsertTimestamp("HH.mm.ss", "Dotted Time")
}

InsertTimeDefault() {
    InsertTimeFormat4()  ; Default is format 4
}

; ==============================
; DATETIME FORMATS
; ==============================

InsertDateTimeFormat1() {
    InsertTimestamp("yyyy-MM-dd HH:mm:ss", "ISO DateTime")
}

InsertDateTimeFormat2() {
    InsertTimestamp("dd/MM/yyyy HH:mm", "EU DateTime")
}

InsertDateTimeFormat3() {
    InsertTimestamp("yyyy-MM-dd HH:mm:ss", "ISO DateTime")  ; Same as Format1
}

InsertDateTimeFormat4() {
    InsertTimestamp("yyyyMMddHHmmss", "Compact DateTime")
}

InsertDateTimeFormat5() {
    InsertTimestamp("ddd, dd MMM yyyy HH:mm", "Full DateTime")
}

InsertDateTimeDefault() {
    InsertDateTimeFormat4()  ; Default is format 4
}

; ==============================
; KEYMAP REGISTRATION (Declarative System)
; ==============================

    ; Date formats (leader → t → d → KEY)
    ; RegisterKeymap("t", "d", "a", "yyyy-MM-dd", InsertDateFormat1, false, 1)
    ; RegisterKeymap("t", "d", "b", "dd/MM/yyyy", InsertDateFormat2, false, 2)
    ; RegisterKeymap("t", "d", "c", "MM/dd/yyyy", InsertDateFormat3, false, 3)
    ; RegisterKeymap("t", "d", "e", "dd-MMM-yyyy", InsertDateFormat4, false, 4)
    ; RegisterKeymap("t", "d", "f", "ddd, dd MMM yyyy", InsertDateFormat5, false, 5)
    ; RegisterKeymap("t", "d", "g", "yyyyMMdd", InsertDateFormat6, false, 6)
    ; RegisterKeymap("t", "d", "d", "Default (yyyyMMdd)", InsertDateDefault, false, 7)
    ; 
    ; Time formats (leader → t → t → KEY)
    ; RegisterKeymap("t", "t", "a", "HH:mm:ss", InsertTimeFormat1, false, 1)
    ; RegisterKeymap("t", "t", "b", "HH:mm", InsertTimeFormat2, false, 2)
    ; RegisterKeymap("t", "t", "c", "hh:mm tt", InsertTimeFormat3, false, 3)
    ; RegisterKeymap("t", "t", "e", "HHmmss", InsertTimeFormat4, false, 4)
    ; RegisterKeymap("t", "t", "f", "HH.mm.ss", InsertTimeFormat5, false, 5)
    ; RegisterKeymap("t", "t", "t", "Default (HHmmss)", InsertTimeDefault, false, 6)
    ;
    ; DateTime formats (leader → t → h → KEY)
    ; RegisterKeymap("t", "h", "a", "yyyy-MM-dd HH:mm:ss", InsertDateTimeFormat1, false, 1)
    ; RegisterKeymap("t", "h", "b", "dd/MM/yyyy HH:mm", InsertDateTimeFormat2, false, 2)
    ; RegisterKeymap("t", "h", "c", "yyyy-MM-dd HH:mm:ss", InsertDateTimeFormat3, false, 3)
    ; RegisterKeymap("t", "h", "e", "yyyyMMddHHmmss", InsertDateTimeFormat4, false, 4)
    ; RegisterKeymap("t", "h", "f", "ddd, dd MMM yyyy HH:mm", InsertDateTimeFormat5, false, 5)
    ; RegisterKeymap("t", "h", "h", "Default (yyyyMMddHHmmss)", InsertDateTimeDefault, false, 6)

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
