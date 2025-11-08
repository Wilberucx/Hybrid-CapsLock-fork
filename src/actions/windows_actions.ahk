; ==============================
; Windows Actions - Funciones Específicas de Window Management
; ==============================
; Acciones específicas para gestión de ventanas en Windows.
; Estas funciones SON ESPECÍFICAS y NO son reutilizables en otras capas.
;
; USADAS EN: windows_layer.ahk

; ==============================
; WINDOW MANAGEMENT BÁSICO
; ==============================

; Maximize Window
MaximizeWindow() {
    Send("#{Up}")
    ShowCommandExecuted("Windows", "Maximized")
}

; Minimize Window
MinimizeWindow() {
    Send("#{Down}")
    ShowCommandExecuted("Windows", "Minimized")
}

; Close Window
CloseWindow() {
    Send("!{F4}")
    ShowCommandExecuted("Windows", "Closed")
}

; Restore Window
RestoreWindow() {
    Send("#{Down}")
    Sleep(50)
    Send("#{Up}")
    ShowCommandExecuted("Windows", "Restored")
}

; ==============================
; WINDOW SPLITS (Específico de Windows Snap)
; ==============================

; Split 50/50 (Left + Right)
Split5050() {
    Send("#{Left}")
    Sleep(100)  ; Timing crítico para que Windows Snap funcione
    Send("#{Right}")
    ShowCommandExecuted("Windows", "Split 50/50")
}

; Split 33/67 (Left + Right + Left)
Split3367() {
    Send("#{Left}")
    Sleep(100)
    Send("#{Right}")
    Sleep(100)
    Send("#{Left}")
    ShowCommandExecuted("Windows", "Split 33/67")
}

; Split 67/33 (Right + Left + Right)
Split6733() {
    Send("#{Right}")
    Sleep(100)
    Send("#{Left}")
    Sleep(100)
    Send("#{Right}")
    ShowCommandExecuted("Windows", "Split 67/33")
}

; Quarter Split (Top-Left)
QuarterSplitTopLeft() {
    Send("#{Up}")
    Sleep(100)
    Send("#{Left}")
    ShowCommandExecuted("Windows", "Quarter Top-Left")
}

; Quarter Split (Top-Right)
QuarterSplitTopRight() {
    Send("#{Up}")
    Sleep(100)
    Send("#{Right}")
    ShowCommandExecuted("Windows", "Quarter Top-Right")
}

; Quarter Split (Bottom-Left)
QuarterSplitBottomLeft() {
    Send("#{Down}")
    Sleep(100)
    Send("#{Left}")
    ShowCommandExecuted("Windows", "Quarter Bottom-Left")
}

; Quarter Split (Bottom-Right)
QuarterSplitBottomRight() {
    Send("#{Down}")
    Sleep(100)
    Send("#{Right}")
    ShowCommandExecuted("Windows", "Quarter Bottom-Right")
}

; ==============================
; SNAP POSITIONS (Win+Arrow)
; ==============================

; Snap Left
SnapLeft() {
    Send("#{Left}")
    ShowCommandExecuted("Windows", "Snap Left")
}

; Snap Right
SnapRight() {
    Send("#{Right}")
    ShowCommandExecuted("Windows", "Snap Right")
}

; Snap Top
SnapTop() {
    Send("#{Up}")
    ShowCommandExecuted("Windows", "Snap Top")
}

; Snap Bottom
SnapBottom() {
    Send("#{Down}")
    ShowCommandExecuted("Windows", "Snap Bottom")
}

; ==============================
; ZOOM TOOLS (PowerToys o similar)
; ==============================

; Draw Mode (PowerToys Screen Ruler)
ActivateDrawMode() {
    Send("^!+9")  ; Ctrl+Alt+Shift+9
    ShowCommandExecuted("Windows", "Draw Mode")
}

; Zoom Mode (PowerToys Zoom)
ActivateZoomMode() {
    Send("^!+1")  ; Ctrl+Alt+Shift+1
    ShowCommandExecuted("Windows", "Zoom Mode")
}

; Zoom with Cursor (PowerToys)
ActivateZoomCursor() {
    Send("^!+4")  ; Ctrl+Alt+Shift+4
    ShowCommandExecuted("Windows", "Zoom Cursor")
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
    ShowCommandExecuted("Windows", "New Desktop")
}

; Close Virtual Desktop
CloseVirtualDesktop() {
    Send("#^{F4}")
    ShowCommandExecuted("Windows", "Close Desktop")
}

; Switch Virtual Desktop Left
SwitchDesktopLeft() {
    Send("#^{Left}")
    ShowCommandExecuted("Windows", "Desktop Left")
}

; Switch Virtual Desktop Right
SwitchDesktopRight() {
    Send("#^{Right}")
    ShowCommandExecuted("Windows", "Desktop Right")
}

; ==============================
; WINDOW ORGANIZATION
; ==============================

; Move Window to Monitor Left
MoveWindowToMonitorLeft() {
    Send("+#{Left}")
    ShowCommandExecuted("Windows", "Move to Monitor Left")
}

; Move Window to Monitor Right
MoveWindowToMonitorRight() {
    Send("+#{Right}")
    ShowCommandExecuted("Windows", "Move to Monitor Right")
}

; Shake Window (minimize all others)
ShakeWindow() {
    ; Win+Home (Aero Shake)
    Send("#{Home}")
    ShowCommandExecuted("Windows", "Shake Window")
}

; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO
; ==============================
; Ruta: Leader → w (Windows) → key

RegisterWindowsKeymaps() {
    ; Splits
    RegisterKeymap("w", "2", "Split 50/50", Split5050, false, 1)
    RegisterKeymap("w", "3", "Split 33/67", Split3367, false, 2)
    RegisterKeymap("w", "4", "Quarter Top-Left", QuarterSplitTopLeft, false, 3)
    
    ; Window Management Básico
    RegisterKeymap("w", "m", "Maximize", MaximizeWindow, false, 10)
    RegisterKeymap("w", "-", "Minimize", MinimizeWindow, false, 11)
    RegisterKeymap("w", "x", "Close", CloseWindow, false, 12)
    
    ; Snap Positions
    RegisterKeymap("w", "h", "Snap Left", SnapLeft, false, 20)
    RegisterKeymap("w", "l", "Snap Right", SnapRight, false, 21)
    RegisterKeymap("w", "k", "Snap Top", SnapTop, false, 22)
    RegisterKeymap("w", "j", "Snap Bottom", SnapBottom, false, 23)
    
    ; Zoom Tools
    RegisterKeymap("w", "d", "Draw Mode", ActivateDrawMode, false, 30)
    RegisterKeymap("w", "z", "Zoom Mode", ActivateZoomMode, false, 31)
    RegisterKeymap("w", "c", "Zoom Cursor", ActivateZoomCursor, false, 32)
    
    ; Blind Switch (j/k ya usados arriba, usar b para Blind)
    RegisterKeymap("w", "b", "Blind Switch", StartPersistentBlindSwitch, false, 40)
    
    ; Virtual Desktops
    RegisterKeymap("w", "n", "New Desktop", NewVirtualDesktop, false, 50)
    RegisterKeymap("w", "q", "Close Desktop", CloseVirtualDesktop, false, 51)
    RegisterKeymap("w", "[", "Desktop Left", SwitchDesktopLeft, false, 52)
    RegisterKeymap("w", "]", "Desktop Right", SwitchDesktopRight, false, 53)
}
