; ==============================
; Command System Initialization
; ==============================
; Sistema declarativo centralizado estilo lazy.nvim
; Inicializa TODAS las categorías y keymaps del sistema
; LLAMAR ESTA FUNCIÓN UNA SOLA VEZ al inicio

InitializeCommandSystem() {
    ; ==============================
    ; 1. REGISTRAR TODAS LAS CATEGORÍAS
    ; ==============================
    ; RegisterCategory(symbol, internal, title, order)
    ; symbol: tecla para activar (ej: "s", "h", "g")
    ; internal: nombre interno para keymaps (ej: "system", "hybrid")
    ; title: título mostrado en menú
    ; order: posición en menú principal (menor = primero)
    
    RegisterCategory("s", "system", "System Commands", 1)
    RegisterCategory("h", "hybrid", "Hybrid Management", 2)
    RegisterCategory("g", "git", "Git Commands", 3)
    RegisterCategory("m", "monitoring", "Monitoring Commands", 4)
    RegisterCategory("n", "network", "Network Commands", 5)
    RegisterCategory("f", "folder", "Folder Access", 6)
    RegisterCategory("o", "power", "Power Options", 7)
    RegisterCategory("a", "adb", "ADB Tools", 8)
    RegisterCategory("v", "vaultflow", "VaultFlow", 9)
    
    ; ==============================
    ; 2. REGISTRAR TODOS LOS KEYMAPS
    ; ==============================
    ; Llamar a todas las funciones Register*Keymaps()
    ; definidas en src/actions/*.ahk
    
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
    ; Ahora todas las categorías y comandos están registrados
    ; Los menús se generan automáticamente desde el registry
    ; No se necesita configurar nada más en INI
}

; ==============================
; BENEFICIOS DEL SISTEMA:
; ==============================
; ✓ Todo declarado en código (no INI duplicado)
; ✓ Una función de init centralizada
; ✓ Menús auto-generados
; ✓ Fácil agregar nuevas categorías:
;   1. Crear archivo src/actions/NUEVA_actions.ahk
;   2. Definir funciones + Register[NUEVA]Keymaps()
;   3. Agregar RegisterCategory() aquí
;   4. Agregar Register[NUEVA]Keymaps() aquí
; ✓ Orden explícito y controlado
; ✓ Confirmaciones por comando
; ==============================
