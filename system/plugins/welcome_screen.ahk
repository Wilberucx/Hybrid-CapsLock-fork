; ==============================
; Welcome Screen - Core Plugin
; ==============================
; CORE INFRASTRUCTURE: Displays a welcome screen on HybridCapsLock startup
; This plugin shows system information and quick tips using TooltipApp v2.1 features
;
; FEATURES:
; - Animated welcome screen with fade-in effect
; - NerdFont icons for visual appeal
; - System information display (version, uptime, etc.)
; - Quick tips and keyboard shortcuts
; - Auto-dismiss after configured timeout
;
; USAGE:
; This plugin is automatically called during startup via ShowWelcomeScreen()
; Can be manually triggered with: ShowWelcomeScreen()
;
; CONFIGURATION:
; - Timeout duration in HybridConfig.welcome.timeout_ms
; - Enable/disable in HybridConfig.welcome.enabled
; - Animation type in HybridConfig.welcome.animation

/**
 * ShowWelcomeScreen - Display animated welcome screen on startup
 * 
 * Shows a beautiful welcome screen with:
 * - HybridCapsLock version and branding
 * - System information
 * - Quick tips
 * - Smooth fade-in animation
 * 
 * @return void
 */
ShowWelcomeScreen() {
    global HybridConfig, tooltipConfig
    
    ; Check if welcome screen is enabled
    if (IsSet(HybridConfig) && HybridConfig.HasOwnProp("welcome") && !HybridConfig.welcome.enabled) {
        Log.d("Welcome screen disabled in config", "WELCOME")
        return
    }
    
    ; Get version info
    version := "v2.0"
    if (IsSet(HybridConfig) && HybridConfig.HasOwnProp("version")) {
        version := HybridConfig.version
    }
    
    ; NerdFont icons (requires NerdFont installed)
    Icons := Map()
    Icons["rocket"] := Chr(0xF135)      ; 
    Icons["keyboard"] := Chr(0xF11C)    ; 
    Icons["star"] := Chr(0xF005)        ; 
    Icons["info"] := Chr(0xF05A)        ; 
    Icons["check"] := Chr(0xF00C)       ; 
    Icons["heart"] := Chr(0xF004)       ; 
    
    ; Build welcome content
    title := Icons["rocket"] . " HYBRID CAPSLOCK " . version
    
    ; Create items with icons and tips
    items := []
    items.Push(Map("key", Icons["keyboard"], "description", "Press CapsLock to activate Leader mode"))
    items.Push(Map("key", Icons["star"], "description", "Press ? in Leader mode for help"))
    items.Push(Map("key", Icons["info"], "description", "Check README.md for full documentation"))
    items.Push(Map("key", Icons["check"], "description", "All systems ready!"))
    
    ; Navigation hints
    navigation := ["ESC: Close", Icons["heart"] . " Made with love for productivity"]
    
    ; Get timeout from config
    timeout := 3000  ; Default 3 seconds
    if (IsSet(HybridConfig) && HybridConfig.HasOwnProp("welcome") && HybridConfig.welcome.HasOwnProp("timeout_ms")) {
        timeout := HybridConfig.welcome.timeout_ms
    }
    
    ; Build command with v2.1 features
    cmd := Map()
    cmd["id"] := "welcome_screen"
    cmd["show"] := true
    cmd["title"] := title
    cmd["items"] := items
    cmd["navigation"] := navigation
    cmd["timeout_ms"] := timeout
    
    ; Layout configuration
    cmd["layout"] := Map()
    cmd["layout"]["mode"] := "list"
    cmd["layout"]["columns"] := 1
    
    ; Position - centered on screen
    cmd["position"] := Map()
    cmd["position"]["anchor"] := "center"
    
    ; Style - vibrant and welcoming
    cmd["style"] := Map()
    cmd["style"]["background"] := "#1a1b26"
    cmd["style"]["text"] := "#c0caf5"
    cmd["style"]["accent_options"] := "#7aa2f7"
    cmd["style"]["accent_navigation"] := "#414868"
    cmd["style"]["navigation_text"] := "#9ece6a"
    cmd["style"]["border"] := "#7aa2f7"
    cmd["style"]["border_thickness"] := 2
    cmd["style"]["corner_radius"] := 12
    cmd["style"]["padding"] := [24, 20, 24, 20]
    cmd["style"]["title_font_size"] := 16
    cmd["style"]["item_font_size"] := 13
    cmd["style"]["navigation_font_size"] := 11
    cmd["style"]["font_family"] := "JetBrainsMono Nerd Font"
    
    ; Window configuration
    cmd["window"] := Map()
    cmd["window"]["topmost"] := true
    cmd["window"]["click_through"] := false  ; Allow interaction
    cmd["window"]["opacity"] := 0.98
    
    ; Animation - smooth fade in
    cmd["animation"] := Map()
    cmd["animation"]["type"] := "fade"
    cmd["animation"]["duration_ms"] := 400
    cmd["animation"]["easing"] := "ease_out"
    
    ; Send to TooltipApp
    StartTooltipApp()
    json := SerializeJson(cmd)
    Tooltip_SendRaw(json)
    
    Log.i("Welcome screen displayed", "WELCOME")
}

/**
 * ShowWelcomeScreenSimple - Simple welcome without NerdFonts
 * 
 * Fallback version for systems without NerdFont installed
 * 
 * @return void
 */
ShowWelcomeScreenSimple() {
    global HybridConfig
    
    ; Get version
    version := "v2.0"
    if (IsSet(HybridConfig) && HybridConfig.HasOwnProp("version")) {
        version := HybridConfig.version
    }
    
    title := "HYBRID CAPSLOCK " . version
    
    ; Simple text items
    items := []
    items.Push(Map("key", ">", "description", "Press CapsLock for Leader mode"))
    items.Push(Map("key", "?", "description", "Press ? for help menu"))
    items.Push(Map("key", "✓", "description", "System ready!"))
    
    navigation := ["ESC: Close", "Welcome to HybridCapsLock!"]
    
    ; Build command
    cmd := Map()
    cmd["id"] := "welcome_screen"
    cmd["show"] := true
    cmd["title"] := title
    cmd["items"] := items
    cmd["navigation"] := navigation
    cmd["timeout_ms"] := 3000
    
    ; Layout
    cmd["layout"] := Map()
    cmd["layout"]["mode"] := "list"
    
    ; Position
    cmd["position"] := Map()
    cmd["position"]["anchor"] := "center"
    
    ; Style
    cmd["style"] := Map()
    cmd["style"]["background"] := "#1a1b26"
    cmd["style"]["text"] := "#c0caf5"
    cmd["style"]["accent_options"] := "#7aa2f7"
    
    ; Animation
    cmd["animation"] := Map()
    cmd["animation"]["type"] := "fade"
    cmd["animation"]["duration_ms"] := 300
    cmd["animation"]["easing"] := "ease_out"
    
    ; Send
    StartTooltipApp()
    json := SerializeJson(cmd)
    Tooltip_SendRaw(json)
    
    Log.i("Simple welcome screen displayed", "WELCOME")
}

/**
 * ShowQuickTip - Display a quick tip notification
 * 
 * Shows a small notification with a helpful tip
 * 
 * @param tipText - The tip text to display
 * @param icon - Optional NerdFont icon (default: info icon)
 * @return void
 */
ShowQuickTip(tipText, icon := "") {
    if (icon = "") {
        icon := Chr(0xF05A)  ; Info icon
    }
    
    cmd := Map()
    cmd["id"] := "quick_tip"
    cmd["show"] := true
    cmd["title"] := icon . " TIP"
    cmd["content"] := tipText
    cmd["timeout_ms"] := 4000
    
    ; Position - bottom right
    cmd["position"] := Map()
    cmd["position"]["anchor"] := "bottom_right"
    cmd["position"]["offset_x"] := -20
    cmd["position"]["offset_y"] := -20
    
    ; Style - compact
    cmd["style"] := Map()
    cmd["style"]["background"] := "#2d3748"
    cmd["style"]["text"] := "#e2e8f0"
    cmd["style"]["accent_options"] := "#4299e1"
    cmd["style"]["padding"] := [12, 8, 12, 8]
    cmd["style"]["corner_radius"] := 8
    cmd["style"]["title_font_size"] := 11
    cmd["style"]["item_font_size"] := 10
    
    ; Animation - slide up
    cmd["animation"] := Map()
    cmd["animation"]["type"] := "slide_up"
    cmd["animation"]["duration_ms"] := 250
    cmd["animation"]["easing"] := "ease_out"
    
    StartTooltipApp()
    json := SerializeJson(cmd)
    Tooltip_SendRaw(json)
}

/**
 * HideWelcomeScreen - Manually hide the welcome screen
 * 
 * @return void
 */
HideWelcomeScreen() {
    cmd := Map()
    cmd["id"] := "welcome_screen"
    cmd["show"] := false
    
    json := SerializeJson(cmd)
    Tooltip_SendRaw(json)
}

; ===================================================================
; AUTO-START ON PLUGIN LOAD
; ===================================================================
; Show welcome screen automatically when HybridCapsLock starts
; Uses a timer to ensure TooltipApp is ready and all plugins are loaded

SetTimer(() => ShowWelcomeScreen(), -800)  ; Show after 800ms delay

