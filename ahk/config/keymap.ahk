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
RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 4)
RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 5)
RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 6)
; Dynamic Layer actions
RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 7)
RegisterKeymap("leader", "h", "t", "Toggle Dynamic Layer", ToggleDynamicLayer, false, 8)
RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 9)
RegisterKeymap("leader", "d", "Dynamic Layer", ActivateDynamicLayer, false, 1)
; ===================================================================


