; ==============================
; Keymap Configuration - Configuration of keymaps and categories and layers activation
; ==============================

; ==============================
; Triggers (F23/F24 from Kanata)
; ==============================
RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")      ; CapsLock+Space → Leader
RegisterTrigger("F23", ActivateDynamicLayer, "DYNAMIC_LAYER_ENABLED")  ; Tap CapsLock → Dynamic Layer


; ===================================================================
; Hybrid Management (leader → h → KEY)
; ===================================================================
RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
; Hybrid actions
RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 2)
RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 3)
RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 4)
RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 5)
; Dynamic Layer actions
RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 6)
RegisterKeymap("leader", "h", "t", "Toggle Dynamic Layer", ToggleDynamicLayer, false, 7)
RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 8)
RegisterKeymap("leader", "d", "Dynamic Layer", ActivateDynamicLayer, false, 1)

; Kanata Management subcategory (leader → h → k → KEY)
RegisterCategoryKeymap("leader", "h", "k", "Kanata", 9)
RegisterKeymap("leader", "h", "k", "t", "Toggle Kanata", (*) => KanataToggle(), false, 1)
RegisterKeymap("leader", "h", "k", "r", "Restart Kanata", KanataRestart(), false, 2)
RegisterKeymap("leader", "h", "k", "s", "Show Kanata Status", (*) => KanataShowStatus(), false, 3)
RegisterKeymap("leader", "h", "k", "k", "Start Kanata", (*) => KanataStart(), false, 4)
RegisterKeymap("leader", "h", "k", "x", "Stop Kanata", (*) => KanataStop(), false, 5)
; ===================================================================


