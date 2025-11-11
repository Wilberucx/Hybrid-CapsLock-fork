; ===============================
; HYBRIDCAPSLOCK THEME SYSTEM
; ===============================
; Visual styling and color schemes for HybridCapsLock
; Supports multiple themes with runtime switching

; Current Active Theme
global CurrentTheme := "light"

; ===============================
; TOKYO NIGHT THEME (DEFAULT)
; ===============================

TokyoNightTheme := {
    name: "Tokyo Night",
    description: "Dark theme inspired by Tokyo Night color scheme",
    
    colors: {
        background: "#1a1b26",
        text: "#c0caf5",
        border: "#24283b",
        accent_options: "#bb9af7",
        accent_navigation: "#7aa2f7",
        navigation_text: "#1a1b26",
        success: "#7bd88f",
        error: "#ff6b6b"
    },
    
    ; Typography System
    typography: {
        title_font_size: 18,
        item_font_size: 14,
        navigation_font_size: 12
    },
    
    spacing: {
        padding: { left: 16, top: 12, right: 16, bottom: 12 },
        border_thickness: 1,
        corner_radius: 4
    },
    
    window: {
        layout: "list",
        columns: 1,
        topmost: true,
        click_through: true,
        opacity: 0.98
    },
    
    position: {
        anchor: "bottom_right",
        offset_x: -10,
        offset_y: -10
    },
    
    navigation: {
        back_label: "BACKSPACE: Back",
        exit_label: "ESC: Exit"
    }
}

; ===============================
; DARK THEME (ALTERNATIVE)
; ===============================

DarkTheme := {
    name: "Dark",
    description: "Clean dark theme",
    
    colors: {
        background: "#101014",
        text: "#f0f0f0",
        border: "#2a2a2a",
        accent_options: "#e6d27a",
        accent_navigation: "#5fb3b3",
        navigation_text: "#a0a0a0",
        success: "#7bd88f",
        error: "#ff6b6b"
    },
    
    typography: {
        title_font_size: 18,
        item_font_size: 14,
        navigation_font_size: 12
    },
    
    spacing: {
        padding: { left: 16, top: 12, right: 16, bottom: 12 },
        border_thickness: 1,
        corner_radius: 4
    },
    
    window: {
        layout: "list",
        columns: 1,
        topmost: true,
        click_through: true,
        opacity: 0.95
    },
    
    position: {
        anchor: "bottom_right",
        offset_x: -10,
        offset_y: -10
    },
    
    navigation: {
        back_label: "BACKSPACE: Back",
        exit_label: "ESC: Exit"
    }
}

; ===============================
; LIGHT THEME
; ===============================

LightTheme := {
    name: "Light",
    description: "Clean light theme",
    
    colors: {
        background: "#ffffff",
        text: "#1a1a1a",
        border: "#d0d0d0",
        accent_options: "#0066cc",
        accent_navigation: "#0099cc",
        navigation_text: "#ffffff",
        success: "#28a745",
        error: "#dc3545"
    },
    
    typography: {
        title_font_size: 18,
        item_font_size: 14,
        navigation_font_size: 12
    },
    
    spacing: {
        padding: { left: 16, top: 12, right: 16, bottom: 12 },
        border_thickness: 1,
        corner_radius: 4
    },
    
    window: {
        layout: "list",
        columns: 1,
        topmost: true,
        click_through: true,
        opacity: 0.95
    },
    
    position: {
        anchor: "bottom_right",
        offset_x: -10,
        offset_y: -10
    },
    
    navigation: {
        back_label: "BACKSPACE: Back",
        exit_label: "ESC: Exit"
    }
}

; ===============================
; THEME REGISTRY
; ===============================

global Themes := Map(
    "tokyo_night", TokyoNightTheme,
    "dark", DarkTheme,
    "light", LightTheme
)

; ===============================
; THEME FUNCTIONS
; ===============================

; Get current active theme
GetCurrentTheme() {
    global CurrentTheme, Themes
    if (Themes.Has(CurrentTheme)) {
        return Themes[CurrentTheme]
    }
    ; Fallback to tokyo_night if theme not found
    return Themes["tokyo_night"]
}

; Switch to a different theme
SetTheme(themeName) {
    global CurrentTheme, Themes
    if (Themes.Has(themeName)) {
        CurrentTheme := themeName
        ; Trigger theme change event
        OnThemeChanged(themeName)
        return true
    }
    return false
}

; Theme change callback (can be overridden by consumers)
OnThemeChanged(themeName) {
    ; Override in main application to refresh UI
}

; List available themes
GetAvailableThemes() {
    global Themes
    themeList := []
    for name, theme in Themes {
        themeList.Push({name: name, title: theme.name, description: theme.description})
    }
    return themeList
}
