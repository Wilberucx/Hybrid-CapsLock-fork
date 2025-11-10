; ==============================
; Windows Actions - Window Management Specific Functions
; ==============================
; Specific actions for Windows window management.
; These functions are SPECIFIC and NOT reusable in other layers.
;
; USED IN: windows_layer.ahk

F13::WinMinimize("A")
; ==============================
; BASIC WINDOW MANAGEMENT
; ==============================

; Maximize Window
MaximizeWindow() {
    Send("#{Up}")
}

; Minimize Window
MinimizeWindow() {
    Send("#{Down}")
}

; Close Window
CloseWindow() {
    Send("!{F4}")
}

; Restore Window
RestoreWindow() {
    Send("#{Down}")
    Sleep(50)
    Send("#{Up}")
}

; ==============================
; WINDOW SPLITS (Windows Snap specific)
; ==============================

; Split 50/50 (Left + Right)
Split5050() {
    Send("#{Left}")
    Sleep(100)  ; Critical timing for Windows Snap to work
    Send("#{Right}")
}

; Split 33/67 (Left + Right + Left)
Split3367() {
    Send("#{Left}")
    Sleep(100)
    Send("#{Right}")
    Sleep(100)
    Send("#{Left}")
}

; Split 67/33 (Right + Left + Right)
Split6733() {
    Send("#{Right}")
    Sleep(100)
    Send("#{Left}")
    Sleep(100)
    Send("#{Right}")
}

; Quarter Split (Top-Left)
QuarterSplitTopLeft() {
    Send("#{Up}")
    Sleep(100)
    Send("#{Left}")
}

; Quarter Split (Top-Right)
QuarterSplitTopRight() {
    Send("#{Up}")
    Sleep(100)
    Send("#{Right}")
}

; Quarter Split (Bottom-Left)
QuarterSplitBottomLeft() {
    Send("#{Down}")
    Sleep(100)
    Send("#{Left}")
}

; Quarter Split (Bottom-Right)
QuarterSplitBottomRight() {
    Send("#{Down}")
    Sleep(100)
    Send("#{Right}")
}

; ==============================
; SNAP POSITIONS (Win+Arrow)
; ==============================

; Snap Left
SnapLeft() {
    Send("#{Left}")
}

; Snap Right
SnapRight() {
    Send("#{Right}")
}

; Snap Top
SnapTop() {
    Send("#{Up}")
}

; Snap Bottom
SnapBottom() {
    Send("#{Down}")
}

; ==============================
; ZOOM TOOLS (PowerToys o similar)
; ==============================

; Draw Mode (PowerToys Screen Ruler)
ActivateDrawMode() {
    Send("^!+9")  ; Ctrl+Alt+Shift+9
}

; Zoom Mode (PowerToys Zoom)
ActivateZoomMode() {
    Send("^!+1")  ; Ctrl+Alt+Shift+1
}

; Zoom with Cursor (PowerToys)
ActivateZoomCursor() {
    Send("^!+4")  ; Ctrl+Alt+Shift+4
}

; ==============================
; PERSISTENT BLIND SWITCH (Alt+Tab persistente)
; ==============================
; NOTA: Esta función es COMPLEJA y específica de Windows Layer
; Mantiene un loop para Alt+Tab/Alt+Shift+Tab sin soltar Alt

StartPersistentBlindSwitch() {
    ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")

    ; Persistent loop para blind switching
    Loop {
        ih := InputHook("L1 T" . GetEffectiveTimeout("windows"))
        ih.Start()
        ih.Wait()

        if (ih.EndReason = "Timeout") {
            ih.Stop()
            ShowCenteredToolTip("BLIND SWITCH TIMEOUT")
            SetTimer(() => RemoveToolTip(), -1000)
            break
        }

        key := ih.Input
        ih.Stop()

        if (key = "j") {
            Send("!{Tab}")  ; Alt+Tab (siguiente ventana)
            ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
        } else if (key = "k") {
            Send("!+{Tab}")  ; Alt+Shift+Tab (ventana anterior)
            ShowCenteredToolTip("BLIND SWITCH MODE`nj: Next | k: Previous | Enter: Exit | Esc: Cancel")
        } else if (key = Chr(13) || key = Chr(10)) {
            ; Enter - confirmar selección
            ShowCenteredToolTip("BLIND SWITCH ENDED")
            SetTimer(() => RemoveToolTip(), -1000)
            break
        } else if (key = Chr(27)) {
            ; Escape - cancelar
            Send("{Esc}")
            ShowCenteredToolTip("BLIND SWITCH CANCELLED")
            SetTimer(() => RemoveToolTip(), -1000)
            break
        }
        ; Cualquier otra tecla continúa el loop
    }
}

; ==============================
; VIRTUAL DESKTOPS (Win+Ctrl+Arrow)
; ==============================

; New Virtual Desktop
NewVirtualDesktop() {
    Send("#^d")
}

; Close Virtual Desktop
CloseVirtualDesktop() {
    Send("#^{F4}")
}

; Switch Virtual Desktop Left
SwitchDesktopLeft() {
    Send("#^{Left}")
}

; Switch Virtual Desktop Right
SwitchDesktopRight() {
    Send("#^{Right}")
}

; ==============================
; WINDOW ORGANIZATION
; ==============================

; Move Window to Monitor Left
MoveWindowToMonitorLeft() {
    Send("+#{Left}")
}

; Move Window to Monitor Right
MoveWindowToMonitorRight() {
    Send("+#{Right}")
}

; Shake Window (minimize all others)
ShakeWindow() {
    ; Win+Home (Aero Shake)
    Send("#{Home}")
}

; ==============================
; DECLARATIVE HIERARCHICAL REGISTRATION
; ==============================
; Path: Leader → w (Windows) → key

RegisterWindowsKeymaps() {
    ; Modernizado: usando RegisterKeymap inteligente que detecta estructura automáticamente
    ; leader, w, key → DetectaAutomaticamente → RegisterKeymapHierarchical

    ; Splits
    RegisterKeymap("leader", "w", "2", "Split 50/50", Split5050, false, 1)
    RegisterKeymap("leader", "w", "3", "Split 33/67", Split3367, false, 2)
    RegisterKeymap("leader", "w", "4", "Quarter Top-Left", QuarterSplitTopLeft, false, 3)

    ; Window Management Básico
    RegisterKeymap("leader", "w", "m", "Maximize", MaximizeWindow, false, 10)
    RegisterKeymap("leader", "w", "-", "Minimize", MinimizeWindow, false, 11)
    RegisterKeymap("leader", "w", "x", "Close", CloseWindow, false, 12)

    ; Snap Positions
    RegisterKeymap("leader", "w", "h", "Snap Left", SnapLeft, false, 20)
    RegisterKeymap("leader", "w", "l", "Snap Right", SnapRight, false, 21)
    RegisterKeymap("leader", "w", "k", "Snap Top", SnapTop, false, 22)
    RegisterKeymap("leader", "w", "j", "Snap Bottom", SnapBottom, false, 23)

    ; Zoom Tools
    RegisterKeymap("leader", "w", "d", "Draw Mode", ActivateDrawMode, false, 30)
    RegisterKeymap("leader", "w", "z", "Zoom Mode", ActivateZoomMode, false, 31)
    RegisterKeymap("leader", "w", "c", "Zoom Cursor", ActivateZoomCursor, false, 32)

    ; Blind Switch
    RegisterKeymap("leader", "w", "b", "Blind Switch", StartPersistentBlindSwitch, false, 40)

    ; Virtual Desktops
    RegisterKeymap("leader", "w", "n", "New Desktop", NewVirtualDesktop, false, 50)
    RegisterKeymap("leader", "w", "q", "Close Desktop", CloseVirtualDesktop, false, 51)
    RegisterKeymap("leader", "w", "[", "Desktop Left", SwitchDesktopLeft, false, 52)
    RegisterKeymap("leader", "w", "]", "Desktop Right", SwitchDesktopRight, false, 53)

    ; Move Between Monitors
    RegisterKeymap("leader", "w", "M", "Move Monitor Left", MoveWindowToMonitorLeft, false, 60)
    RegisterKeymap("leader", "w", "L", "Move Monitor Right", MoveWindowToMonitorRight, false, 61)
    RegisterKeymap("leader", "w", "s", "Shake Window", ShakeWindow, false, 62)
}
