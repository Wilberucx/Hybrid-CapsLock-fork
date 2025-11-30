; ==============================
; Keymap Configuration - Configuration of keymaps and categories and layers activation
; ==============================

#SuspendExempt
#HotIf (LeaderLayerEnabled)
F24:: ActivateLeaderLayer()    ; CapsLock+Space → Leader about kanata.kbd
#HotIf

#HotIf (DYNAMIC_LAYER_ENABLED)
F23:: ActivateDynamicLayer()    ; Tap CapsLock → Dynamic Layer about kanata.kbd
#HotIf
#SuspendExempt False


; ===================================================================
; Hybrid Management (leader → h → KEY)
; ===================================================================
; RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
; ; Hybrid actions
; RegisterKeymap("leader", "h", "m", "Hybrid Manager", ShowHybridManager, false, 0)
; RegisterKeymap("leader", "h", "p", "Pause Hybrid", PauseHybridScript, false, 1)
; RegisterKeymap("leader", "h", "l", "View Log File", ViewLogFile, false, 2)
; RegisterKeymap("leader", "h", "c", "Open Config Folder", OpenConfigFolder, false, 3)
; RegisterKeymap("leader", "h", "k", "Restart Kanata Only", RestartKanataOnly, false, 4)
; RegisterKeymap("leader", "h", "R", "Reload Script", ReloadHybridScript, true, 5)
; RegisterKeymap("leader", "h", "e", "Exit Script", ExitHybridScript, true, 6)
; ; Dynamic Layer actions
; RegisterKeymap("leader", "h", "r", "Register Process", ShowBindProcessGui, false, 7)
; RegisterKeymap("leader", "h", "t", "Toggle Dynamic Layer", ToggleDynamicLayer, false, 8)
; RegisterKeymap("leader", "h", "b", "List Bindings", ShowBindingsListGui, false, 9)
RegisterKeymap("leader", "d", "Dynamic Layer", ActivateDynamicLayer, false, 1)
; ; ===================================================================


