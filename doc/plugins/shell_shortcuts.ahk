; ==============================
; Shell Shortcuts - Optional Plugin
; ==============================
; Provides quick access shortcuts to commonly used programs and applications.
; This plugin demonstrates how to use the ShellExec core API.
;
; INSTALLATION:
; Copy this file to ahk/plugins/ and reload HybridCapsLock (Leader + h + R)
;
; CUSTOMIZATION:
; Edit the keymaps below to add your own program shortcuts.
; You can find program paths in:
; - C:\Program Files\
; - C:\Program Files (x86)\
; - %USERPROFILE%\AppData\Local\
; - %USERPROFILE%\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\

; ===================================================================
; PROGRAM SHORTCUTS
; ===================================================================
; Quick access to commonly used programs (leader → p → KEY)

RegisterCategoryKeymap("leader", "p", "Programs", 7)

; System Programs
RegisterKeymap("leader", "p", "e", "Explorer", ShellExec("explorer.exe"), false, 1)
RegisterKeymap("leader", "p", "i", "Settings", ShellExec("ms-settings:"), false, 2)
RegisterKeymap("leader", "p", "n", "Notepad", ShellExec("notepad.exe"), false, 3)

; Terminals
RegisterKeymap("leader", "p", "t", "Terminal", ShellExec("wt.exe", "Show"), false, 4)
RegisterKeymap("leader", "p", "w", "WezTerm", ShellExec("C:\Program Files\WezTerm\wezterm-gui.exe", "Show"), false, 5)
RegisterKeymap("leader", "p", "l", "WSL", ShellExec("wsl.exe", "Show"), false, 6)

; Browsers
RegisterKeymap("leader", "p", "b", "Vivaldi", ShellExec(EnvGet("USERPROFILE") . "\AppData\Local\Vivaldi\Application\vivaldi.exe"), false, 7)
RegisterKeymap("leader", "p", "z", "Zen Browser", ShellExec("C:\Program Files\Zen Browser\zen.exe"), false, 8)

; Communication
RegisterKeymap("leader", "p", "m", "Thunderbird", ShellExec("Thunderbird.exe"), false, 9)
RegisterKeymap("leader", "p", "r", "Beeper", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Beeper.lnk"), false, 10)

; Utilities
RegisterKeymap("leader", "p", "q", "Quick Share", ShellExec("QuickShare.exe"), false, 11)
RegisterKeymap("leader", "p", "p", "Bitwarden", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\Bitwarden.lnk"), false, 12)
RegisterKeymap("leader", "p", "k", "LocalSend", ShellExec(EnvGet("USERPROFILE") . "\AppData\Roaming\Microsoft\Windows\Start Menu\Programs\LocalSend.lnk"), false, 13)

; ===================================================================
; CUSTOMIZATION EXAMPLES
; ===================================================================
; Uncomment and modify these examples to add your own shortcuts:

; Custom Applications
; RegisterKeymap("leader", "p", "v", "VS Code", ShellExec("code.exe"), false, 14)
; RegisterKeymap("leader", "p", "s", "Spotify", ShellExec(EnvGet("APPDATA") . "\Spotify\Spotify.exe"), false, 15)
; RegisterKeymap("leader", "p", "d", "Discord", ShellExec(EnvGet("LOCALAPPDATA") . "\Discord\Update.exe --processStart Discord.exe"), false, 16)

; Open Specific Folders
; RegisterKeymap("leader", "f", "d", "Downloads", ShellExec("explorer.exe", EnvGet("USERPROFILE") . "\Downloads"), false, 1)
; RegisterKeymap("leader", "f", "p", "Projects", ShellExec("explorer.exe", "C:\Projects"), false, 2)

; Open Websites
; RegisterKeymap("leader", "w", "g", "Gmail", ShellExec("https://mail.google.com"), false, 1)
; RegisterKeymap("leader", "w", "y", "YouTube", ShellExec("https://youtube.com"), false, 2)

; Run Scripts
; RegisterKeymap("leader", "s", "b", "Backup", ShellExec(A_ScriptDir . "\scripts\backup.bat", "Show"), false, 1)
; RegisterKeymap("leader", "s", "c", "Cleanup", ShellExec(A_ScriptDir . "\scripts\cleanup.vbs"), false, 2)
