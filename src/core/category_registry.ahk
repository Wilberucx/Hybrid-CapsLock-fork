; ==============================
; Category Registry - Sistema de Categorías Jerárquico
; ==============================
; Sistema declarativo jerárquico estilo which-key de Neovim
; Registra TODAS las categorías y subcategorías del sistema de navegación
; Define la estructura de navegación: leader → categoría → subcategoría → acción
; LLAMAR ESTA FUNCIÓN UNA SOLA VEZ al inicio

InitializeCategoryRegistry() {
    ; ==============================
    ; 1. CATEGORÍAS PRINCIPALES EN LEADER
    ; ==============================
    ; Leader → w (Windows)
    RegisterCategoryKeymap("w", "Windows", 1)
    
    ; Leader → t (Timestamps)
    RegisterCategoryKeymap("t", "Timestamps", 2)
    
    ; Leader → c (Commands)
    RegisterCategoryKeymap("c", "Commands", 3)
    
    ; ==============================
    ; 2. SUBCATEGORÍAS EN COMMANDS Y TIMESTAMPS
    ; ==============================
    ; Leader → c → s (System)
    ; Leader → c → h (Hybrid)
    ; etc.
    
    RegisterCategoryKeymap("c", "s", "System Commands", 1)
    RegisterCategoryKeymap("h", "Hybrid Management", 2)
    RegisterCategoryKeymap("c", "g", "Git Commands", 3)
    RegisterCategoryKeymap("c", "m", "Monitoring Commands", 4)
    RegisterCategoryKeymap("c", "n", "Network Commands", 5)
    RegisterCategoryKeymap("c", "f", "Folder Access", 6)
    RegisterCategoryKeymap("c", "o", "Power Options", 7)
    RegisterCategoryKeymap("c", "a", "ADB Tools", 8)
    RegisterCategoryKeymap("c", "v", "VaultFlow", 9)
    
    ; Leader → t → d/t/h (Date/Time/DateTime)
    RegisterCategoryKeymap("t", "d", "Date Formats", 1)
    RegisterCategoryKeymap("t", "t", "Time Formats", 2)
    RegisterCategoryKeymap("t", "h", "Date+Time Formats", 3)
    
    ; ==============================
    ; 3. REGISTRAR TODOS LOS KEYMAPS
    ; ==============================
    ; Cada función Register*Keymaps() usa sintaxis jerárquica:
    ; RegisterKeymap("leader_key", "category_key", "action_key", "desc", action, confirm, order)
    
    ; Windows Layer
    RegisterWindowsKeymaps()
    
    ; Commands Layer (subcategorías)
    RegisterSystemKeymaps()
    RegisterHybridKeymaps()
    RegisterGitKeymaps()
    RegisterMonitoringKeymaps()
    RegisterNetworkKeymaps()
    RegisterFolderKeymaps()
    RegisterPowerKeymaps()
    RegisterADBKeymaps()
    RegisterVaultFlowKeymaps()
    
    ; Timestamps Layer
    RegisterTimestampKeymaps()
    
    ; ==============================
    ; SISTEMA LISTO
    ; ==============================
    ; Estructura resultante:
    ; Leader
    ;   ├── w (Windows)
    ;   │   ├── 2 - Split 50/50
    ;   │   ├── m - Maximize
    ;   │   └── ...
    ;   └── c (Commands)
    ;       ├── s (System)
    ;       │   ├── s - System Info
    ;       │   └── t - Task Manager
    ;       ├── a (ADB)
    ;       │   ├── d - List Devices
    ;       │   └── s - Shell
    ;       └── ...
}

