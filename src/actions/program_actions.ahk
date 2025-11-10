; ==============================
; Program Actions - RegisterKeymap Configuration
; ==============================
; Converted from config/programs.ini to RegisterKeymap syntax
; Using intelligent ShellExec function for all program launches
; 
; MAPPING: leader → p → LETTER
; Based on programs.ini [ProgramMapping] order: e i t v n o b z m w l r q p k f

; ---- Programs Layer Registration ----
; Each program mapped exactly as in programs.ini

; Explorer (e) - Windows File Explorer
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)

; Settings (i) - Windows Settings
RegisterKeymap("leader", "p", "i", "Settings", ShellExec("ms-settings:"), false, 1)

; Terminal (t) - Windows Terminal
RegisterKeymap("leader", "p", "t", "Terminal", ShellExec("wt.exe", "Show"), false, 1)

; Visual Studio Code (v) - Code Editor (requires confirmation as per programs.ini)
RegisterKeymap("leader", "p", "v", "VS Code", ShellExec("C:\Program Files\Microsoft VS Code\Code.exe"), true, 1)

; Notepad (n) - Text Editor
RegisterKeymap("leader", "p", "n", "Notepad", ShellExec("notepad.exe"), false, 1)

; Vivaldi (b) - Web Browser
RegisterKeymap("leader", "p", "b", "Vivaldi", ShellExec(EnvGet("USERPROFILE") . "\AppData\Local\Vivaldi\Application\vivaldi.exe"), false, 1)

; Zen Browser (z) - Alternative Browser
RegisterKeymap("leader", "p", "z", "Zen Browser", ShellExec("C:\Program Files\Zen Browser\zen.exe"), false, 1)

; Thunderbird (m) - Email Client
RegisterKeymap("leader", "p", "m", "Thunderbird", ShellExec("Thunderbird.exe"), false, 1)

; WezTerm (w) - Terminal Emulator
RegisterKeymap("leader", "p", "w", "WezTerm", ShellExec("C:\Program Files\WezTerm\wezterm-gui.exe", "Show"), false, 1)

; WSL (l) - Windows Subsystem for Linux
RegisterKeymap("leader", "p", "l", "WSL", ShellExec("wsl.exe", "Show"), false, 1)

; Beeper (r) - Communication App
RegisterKeymap("leader", "p", "r", "Beeper", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Beeper.lnk"), false, 1)

; QuickShare (q) - Windows Quick Share
RegisterKeymap("leader", "p", "q", "Quick Share", ShellExec("QuickShare.exe"), false, 1)

; Bitwarden (p) - Password Manager
RegisterKeymap("leader", "p", "p", "Bitwarden", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Bitwarden.lnk"), false, 1)

; LocalSend (k) - File Transfer
RegisterKeymap("leader", "p", "k", "LocalSend", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LocalSend.lnk"), false, 1)

; ==============================
; VENTAJAS DE ESTA IMPLEMENTACIÓN
; ==============================
; ✓ Configuración declarativa clara y legible
; ✓ Una línea por programa, fácil de mantener
; ✓ Usa la función ShellExec inteligente
; ✓ Soporte automático para .exe, .lnk, URIs
; ✓ Variables de entorno expandidas dinámicamente  
; ✓ Configuración de confirmación integrada
; ✓ Ventanas visibles para terminales, ocultas para apps
; ✓ Compatible 100% con el sistema RegisterKeymap existente
; ✓ Ya no depende de programs.ini para el mapeo
;
; PARA AÑADIR UN NUEVO PROGRAMA:
; 1. Añade una línea RegisterKeymap siguiendo el patrón
; 2. Elige una letra disponible  
; 3. Usa ShellExec con el path correcto
; 4. Especifica confirmación (true/false)
;
; EJEMPLOS DE SINTAXIS:
; RegisterKeymap("leader", "p", "x", "Mi App", ShellExec("C:\Path\To\App.exe"), false, 1)
; RegisterKeymap("leader", "p", "y", "Terminal", ShellExec("cmd.exe", "Show"), false, 1)
; RegisterKeymap("leader", "p", "z", "Con Config", ShellExec("app.exe", "config.json"), false, 1)
;
; INTELIGENCIA CONTEXT-AWARE:
; ShellExec() detecta automáticamente el contexto:
; → En RegisterKeymap: Retorna función para ejecución diferida
; → Llamada directa: Ejecuta inmediatamente
; ¡UNA SOLA FUNCIÓN PARA AMBOS USOS!
; ==============================
