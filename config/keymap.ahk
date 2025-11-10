; ==============================
; Keymap Configuration - Configuración de Categorías y Navegación
; ==============================
; Sistema declarativo jerárquico estilo which-key de Neovim
; Define la estructura completa de navegación del sistema
; 
; PROPÓSITO: Archivo de configuración centralizado para categorías y subcategorías
; Ubicación: config/ (fácil de editar sin tocar código core)
; 
; ESTRUCTURA: leader → categoría → subcategoría → acción
; 
; EVOLUCIÓN FUTURA: Este archivo puede tener prioridad sobre los keymaps
; definidos en src/actions/*.ahk, manteniendo esos como fallback.
; 
; LLAMAR InitializeCategoryKeymaps() UNA SOLA VEZ al inicio

InitializeCategoryKeymaps() {
    ; ==============================
    ; 1. CATEGORÍAS PRINCIPALES EN LEADER
    ; ==============================
    RegisterCategoryKeymap("h", "Hybrid Management", 1)
    RegisterCategoryKeymap("t", "Timestamps", 2)
    RegisterCategoryKeymap("c", "Commands", 3)
    RegisterCategoryKeymap("p", "Programs", 5)
    ; ==============================
    ; 2. SUBCATEGORÍAS EN COMMANDS Y TIMESTAMPS
    ; ==============================
    ; Leader → c
    RegisterCategoryKeymap("c", "s", "System Commands", 1)
    RegisterCategoryKeymap("c", "g", "Git Commands", 3)
    RegisterCategoryKeymap("c", "m", "Monitoring Commands", 4)
    RegisterCategoryKeymap("c", "n", "Network Commands", 5)
    RegisterCategoryKeymap("c", "f", "Folder Access", 6)
    RegisterCategoryKeymap("c", "o", "Power Options", 7)
    RegisterCategoryKeymap("c", "a", "ADB Tools", 8)
    RegisterCategoryKeymap("c", "v", "VaultFlow", 9)
    ; Leader → t 
    RegisterCategoryKeymap("t", "d", "Date Formats", 1)
    RegisterCategoryKeymap("t", "t", "Time Formats", 2)
    RegisterCategoryKeymap("t", "h", "Date+Time Formats", 3)
    ; Programas (leader → p → KEY)
    RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
    RegisterKeymap("leader", "p", "i", "Settings", ShellExec("ms-settings:"), false, 1)
    RegisterKeymap("leader", "p", "t", "Terminal", ShellExec("wt.exe", "Show"), false, 1)
    RegisterKeymap("leader", "p", "n", "Notepad", ShellExec("notepad.exe"), false, 1)
    RegisterKeymap("leader", "p", "b", "Vivaldi", ShellExec(EnvGet("USERPROFILE") . "\AppData\Local\Vivaldi\Application\vivaldi.exe"), false, 1)
    RegisterKeymap("leader", "p", "z", "Zen Browser", ShellExec("C:\Program Files\Zen Browser\zen.exe"), false, 1)
    RegisterKeymap("leader", "p", "m", "Thunderbird", ShellExec("Thunderbird.exe"), false, 1)
    RegisterKeymap("leader", "p", "w", "WezTerm", ShellExec("C:\Program Files\WezTerm\wezterm-gui.exe", "Show"), false, 1)
    RegisterKeymap("leader", "p", "l", "WSL", ShellExec("wsl.exe", "Show"), false, 1)
    RegisterKeymap("leader", "p", "r", "Beeper", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Beeper.lnk"), false, 1)
    RegisterKeymap("leader", "p", "q", "Quick Share", ShellExec("QuickShare.exe"), false, 1)
    RegisterKeymap("leader", "p", "p", "Bitwarden", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Bitwarden.lnk"), false, 1)
    RegisterKeymap("leader", "p", "k", "LocalSend", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LocalSend.lnk"), false, 1)
    ; Category timestamps (leader → t → KEY)
    RegisterKeymap("leader", "t", "d", "1", "yyyy-MM-dd", InsertDateFormat1, false, 1)
    RegisterKeymap("leader", "t", "d", "2", "dd/MM/yyyy", InsertDateFormat2, false, 2)
    RegisterKeymap("leader", "t", "d", "3", "MM/dd/yyyy", InsertDateFormat3, false, 3)
    RegisterKeymap("leader", "t", "d", "4", "dd-MMM-yyyy", InsertDateFormat4, false, 4)
    RegisterKeymap("leader", "t", "d", "5", "ddd, dd MMM yyyy", InsertDateFormat5, false, 5)
    RegisterKeymap("leader", "t", "d", "6", "yyyyMMdd", InsertDateFormat6, false, 6)
    RegisterKeymap("leader", "t", "d", "d", "Default (yyyyMMdd)", InsertDateDefault, false, 7)
    ; Time formats (leader → t → t → KEY)
    RegisterKeymap("leader", "t", "t", "1", "HH:mm:ss", InsertTimeFormat1, false, 1)
    RegisterKeymap("leader", "t", "t", "2", "HH:mm", InsertTimeFormat2, false, 2)
    RegisterKeymap("leader", "t", "t", "3", "hh:mm tt", InsertTimeFormat3, false, 3)
    RegisterKeymap("leader", "t", "t", "4", "HHmmss", InsertTimeFormat4, false, 4)
    RegisterKeymap("leader", "t", "t", "5", "HH.mm.ss", InsertTimeFormat5, false, 5)
    RegisterKeymap("leader", "t", "t", "t", "Default (HHmmss)", InsertTimeDefault, false, 6)
    
    ; DateTime formats (leader → t → h → KEY)
    RegisterKeymap("leader", "t", "h", "1", "yyyy-MM-dd HH:mm:ss", InsertDateTimeFormat1, false, 1)
    RegisterKeymap("leader", "t", "h", "2", "dd/MM/yyyy HH:mm", InsertDateTimeFormat2, false, 2)
    RegisterKeymap("leader", "t", "h", "3", "yyyy-MM-dd HH:mm:ss", InsertDateTimeFormat3, false, 3)
    RegisterKeymap("leader", "t", "h", "4", "yyyyMMddHHmmss", InsertDateTimeFormat4, false, 4)
    RegisterKeymap("leader", "t", "h", "5", "ddd, dd MMM yyyy HH:mm", InsertDateTimeFormat5, false, 5)
    RegisterKeymap("leader", "t", "h", "h", "Default (yyyyMMddHHmmss)", InsertDateTimeDefault, false, 6)
    ; Hybrid Management (leader → h → KEY)
    RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
    RegisterKeymap("leader", "h", "s", "Show System Status", ShowSystemStatus, false, 2)
    RegisterKeymap("leader", "h", "v", "Show Version Info", ShowVersionInfo, false, 3)
    RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 4)
    RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 5)
    RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 6)
    RegisterKeymap("leader", "h", "S", "Scan Layers", ScanLayersManual, false, 7)
    RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 8)
    RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 9)
    ; ==============================
    ; 3. CONFIGURACIÓN PERSONALIZADA (OVERRIDE)
    ; ==============================
    ; Aquí puedes override cualquier keymap desde actions
    ; Estos keymaps tienen PRIORIDAD sobre los definidos en src/actions/
    
    ; Programs overrides (ejemplos):
    ; RegisterKeymap("leader", "p", "e", "Explorer Downloads", ShellExec("explorer.exe", "C:\Users\Downloads"), false, 1)
    ; RegisterKeymap("leader", "p", "v", "VS Code Project", ShellExec("code.exe", "C:\MyProject"), false, 1)
    
    ; Windows overrides (ejemplos):
    ; RegisterKeymap("leader", "w", "m", "Minimize Custom", () => MinimizeWindow(), false, 1)
    
    ; System overrides (ejemplos):
    ; RegisterKeymap("leader", "c", "s", "r", "Restart Custom", () => RestartSystem(), true, 1)
    
    ; ==============================
    ; 4. CARGAR FALLBACKS DESDE ACTIONS
    ; ==============================
    ; Solo se registran keymaps que NO fueron definidos arriba
    ; LoadActionKeymapFallbacks()
}

; LoadActionKeymapFallbacks() {
;     ; Cargar todos los keymaps de actions como fallback
;     ; (Solo se registrarán los que NO existen ya gracias al sistema de prioridad)
;     RegisterHybridKeymaps()
;     RegisterSystemKeymaps()
;     RegisterNetworkKeymaps()
;     RegisterGitKeymaps()
;     RegisterMonitoringKeymaps()
;     RegisterFolderKeymaps()
;     RegisterPowerKeymaps()
;     RegisterADBKeymaps()
;     RegisterVaultFlowKeymaps()
;     RegisterTimestampKeymaps()
;     RegisterWindowsKeymaps()
;
;     ; NOTA: program_actions.ahk usa declaración directa (no función wrapper)
;     ; Sus RegisterKeymap se ejecutan automáticamente al cargar el archivo
; }

