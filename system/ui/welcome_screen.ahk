; ===================================================================
; WELCOME SCREEN
; ===================================================================
; Displays a centered ASCII art welcome screen on startup.
; ===================================================================

global WelcomeAsciiArt := "
(
░██     ░██            ░██                 ░██       ░██                                               
░██     ░██            ░██                           ░██                                               
░██     ░██ ░██    ░██ ░████████  ░██░████ ░██ ░████████                                               
░██████████ ░██    ░██ ░██    ░██ ░███     ░██░██    ░██                                               
░██     ░██ ░██    ░██ ░██    ░██ ░██      ░██░██    ░██                                               
░██     ░██ ░██   ░███ ░███   ░██ ░██      ░██░██   ░███                                               
░██     ░██  ░█████░██ ░██░█████  ░██      ░██ ░█████░██                                               
                   ░██                                                                                 
             ░███████                                                                                  
                                                                                                       
                 ░██████                                   ░██                               ░██       
                ░██   ░██                                  ░██                               ░██       
               ░██         ░██████   ░████████   ░███████  ░██          ░███████   ░███████  ░██    ░██
               ░██              ░██  ░██    ░██ ░██        ░██         ░██    ░██ ░██    ░██ ░██   ░██ 
               ░██         ░███████  ░██    ░██  ░███████  ░██         ░██    ░██ ░██        ░███████  
                ░██   ░██ ░██   ░██  ░███   ░██        ░██ ░██         ░██    ░██ ░██    ░██ ░██   ░██ 
; ===================================================================
; WELCOME SCREEN
; ===================================================================
; Displays a centered ASCII art welcome screen on startup.
; ===================================================================

global WelcomeAsciiArt := "
(
HybridCapsLock
v2.0
)"

ShowWelcomeScreen() {
    global tooltipConfig
    
    if (!IsSet(tooltipConfig) || !tooltipConfig.enabled) {
        return
    }
    
    Log.i("Showing Welcome Screen (Items Fallback)...", "INIT")
    
    ; Construct command using standard list protocol (safer)
    cmd := Map()
    cmd["show"] := true
    cmd["title"] := "WELCOME"
    cmd["timeout_ms"] := 3000
    
    ; Use items to simulate text lines
    items := []
    
    item1 := Map()
    item1["key"] := "" 
    item1["description"] := "HybridCapsLock"
    items.Push(item1)
    
    item2 := Map()
    item2["key"] := "" 
    item2["description"] := "v2.0"
    items.Push(item2)
    
    cmd["items"] := items
    
    ; Position: Center
    cmd["position"] := Map()
    cmd["position"]["anchor"] := "center"
    cmd["position"]["x"] := 0
    cmd["position"]["y"] := 0
    
    ; Style - Large and Premium
    cmd["style"] := Map()
    cmd["style"]["font_family"] := "Segoe UI, sans-serif"
    cmd["style"]["title_font_size"] := 24
    cmd["style"]["item_font_size"] := 18
    cmd["style"]["background"] := "#1a1b26"
    cmd["style"]["text"] := "#7aa2f7"
    cmd["style"]["border"] := "#7aa2f7"
    cmd["style"]["border_thickness"] := 2
    cmd["style"]["padding"] := [50, 30, 50, 30]
    cmd["style"]["corner_radius"] := 12
    
    ; Force list layout
    cmd["layout"] := "list"
    cmd["columns"] := 1
    cmd["topmost"] := true
    cmd["opacity"] := 0.95
    
    ; Send directly
    StartTooltipApp()
    json := SerializeJson(cmd)
    Tooltip_SendRaw(json)
}
