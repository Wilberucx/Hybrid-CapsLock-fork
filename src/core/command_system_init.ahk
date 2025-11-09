; ==============================
; Command System Initialization - JERÁRQUICO
; ==============================
; Sistema declarativo jerárquico estilo which-key de Neovim
; Inicializa TODAS las categorías y keymaps con rutas completas
; LLAMAR ESTA FUNCIÓN UNA SOLA VEZ al inicio

InitializeCommandSystem() {
    ; ==============================
    ; 1. CATEGORÍAS PRINCIPALES EN LEADER
    ; ==============================
    ; Leader → w (Windows)
    RegisterCategoryKeymap("w", "Windows", 1)
    
    ; Leader → c (Commands)
    RegisterCategoryKeymap("c", "Commands", 3)
    
    ; ==============================
    ; 2. SUBCATEGORÍAS EN COMMANDS
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

