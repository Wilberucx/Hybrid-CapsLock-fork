; ==============================
; Timestamp Actions - Funciones reutilizables
; ==============================
; Extracted from timestamps_layer.ahk para seguir arquitectura declarativa
; Cada función inserta un timestamp con formato específico

; ==============================
; FUNCIONES DE DATE FORMATS
; ==============================

InsertDateFormat1() {
    SendText(FormatTime(, "yyyy-MM-dd"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "yyyy-MM-dd"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateFormat2() {
    SendText(FormatTime(, "dd/MM/yyyy"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "dd/MM/yyyy"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateFormat3() {
    SendText(FormatTime(, "MM/dd/yyyy"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "MM/dd/yyyy"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateFormat4() {
    SendText(FormatTime(, "dd-MMM-yyyy"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "dd-MMM-yyyy"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateFormat5() {
    SendText(FormatTime(, "ddd, dd MMM yyyy"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "ddd, dd MMM yyyy"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateFormat6() {
    SendText(FormatTime(, "yyyyMMdd"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "yyyyMMdd"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateDefault() {
    InsertDateFormat6()  ; Default es formato 6
}

; ==============================
; FUNCIONES DE TIME FORMATS
; ==============================

InsertTimeFormat1() {
    SendText(FormatTime(, "HH:mm:ss"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "HH:mm:ss"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertTimeFormat2() {
    SendText(FormatTime(, "HH:mm"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "HH:mm"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertTimeFormat3() {
    SendText(FormatTime(, "hh:mm tt"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "hh:mm tt"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertTimeFormat4() {
    SendText(FormatTime(, "HHmmss"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "HHmmss"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertTimeFormat5() {
    SendText(FormatTime(, "HH.mm.ss"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "HH.mm.ss"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertTimeDefault() {
    InsertTimeFormat4()  ; Default es formato 4
}

; ==============================
; FUNCIONES DE DATETIME FORMATS
; ==============================

InsertDateTimeFormat1() {
    SendText(FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateTimeFormat2() {
    SendText(FormatTime(, "dd/MM/yyyy HH:mm"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "dd/MM/yyyy HH:mm"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateTimeFormat3() {
    SendText(FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateTimeFormat4() {
    SendText(FormatTime(, "yyyyMMddHHmmss"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "yyyyMMddHHmmss"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateTimeFormat5() {
    SendText(FormatTime(, "ddd, dd MMM yyyy HH:mm"))
    ShowCenteredToolTip("TIMESTAMP: " . FormatTime(, "ddd, dd MMM yyyy HH:mm"))
    SetTimer(() => RemoveToolTip(), -2000)
}

InsertDateTimeDefault() {
    InsertDateTimeFormat4()  ; Default es formato 4
}

; ==============================
; REGISTRO DE KEYMAPS (Sistema Declarativo)
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
