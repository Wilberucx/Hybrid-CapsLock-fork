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
    RegisterCategoryKeymap("w", "Windows", 4)
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
    
    ; ==============================
    ; 3. REGISTRAR TODOS LOS KEYMAPS
    ; ==============================
    RegisterWindowsKeymaps()
    RegisterSystemKeymaps()
    RegisterHybridKeymaps()
    RegisterGitKeymaps()
    RegisterMonitoringKeymaps()
    RegisterNetworkKeymaps()
    RegisterFolderKeymaps()
    RegisterPowerKeymaps()
    RegisterADBKeymaps()
    RegisterVaultFlowKeymaps()
    RegisterTimestampKeymaps()
    
}

