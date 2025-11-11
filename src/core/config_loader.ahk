; ===============================
; Configuration Loader
; ===============================
; Smart configuration loader with dual INI/AHK support
; Tries new AHK config first, falls back to legacy INI

class ConfigLoader {
    ; Load configuration (AHK format first, INI fallback)
    static Load() {
        try {
            ; Try loading new AHK configuration
            return this.LoadAHKConfig()
        } catch as e {
            ; Fallback to legacy INI
            OutputDebug("[ConfigLoader] AHK config failed, falling back to INI: " . e.Message . "`n")
            return this.LoadLegacyINI()
        }
    }
    
    ; Load modern AHK configuration
    static LoadAHKConfig() {
        ; Load theme system first
        if (!FileExist(A_ScriptDir . "\config\colorscheme.ahk")) {
            throw Error("colorscheme.ahk not found")
        }
        
        ; Load settings
        if (!FileExist(A_ScriptDir . "\config\settings.ahk")) {
            throw Error("settings.ahk not found")
        }
        
        ; Include config files (these set global variables)
        ; Note: GetCurrentTheme() will be available after colorscheme.ahk loads
        global HybridConfig
        
        ; Check if already loaded
        if (!IsSet(HybridConfig)) {
            throw Error("HybridConfig not loaded from settings.ahk")
        }
        
        ; Get theme using the helper function from HybridConfig
        currentTheme := HybridConfig.getTheme()
        
        return {
            config: HybridConfig,
            theme: currentTheme,
            source: "ahk"
        }
    }
    
    ; Fallback: Load legacy INI configuration
    static LoadLegacyINI() {
        global ConfigIni
        
        ; Create INI-compatible config object
        iniConfig := {
            app: {
                name: "HybridCapsLock",
                version: this.ReadIniValue(ConfigIni, "General", "script_version", "6.3"),
                debug_mode: this.ReadIniBool(ConfigIni, "General", "debug_mode", false)
            },
            
            layers: {
                global: {
                    persistence_enabled: this.ReadIniBool(ConfigIni, "Layers", "enable_layer_persistence", true)
                },
                layers: {
                    nvim: {
                        enabled: this.ReadIniBool(ConfigIni, "Layers", "nvim_layer_enabled", true),
                        timeout: this.ReadIniNumber(ConfigIni, "Behavior", "global_timeout_seconds", 7) * 1000,
                        tap_threshold_ms: this.ReadIniNumber(ConfigIni, "Behavior", "nvim_tap_threshold_ms", 250),
                        yank_feedback_return: this.ReadIniBool(ConfigIni, "Nvim", "yank_feedback_return", true)
                    },
                    excel: {
                        enabled: this.ReadIniBool(ConfigIni, "Layers", "excel_layer_enabled", true),
                        timeout: this.ReadIniNumber(ConfigIni, "Behavior", "global_timeout_seconds", 7) * 1000
                    },
                    leader: {
                        enabled: this.ReadIniBool(ConfigIni, "Layers", "leader_layer_enabled", true),
                        timeout: this.ReadIniNumber(ConfigIni, "Behavior", "leader_timeout_seconds", 7) * 1000
                    }
                }
            },
            
            tooltips: {
                enabled: this.ReadIniBool(ConfigIni, "Tooltips", "enable_csharp_tooltips", true),
                handles_input: this.ReadIniBool(ConfigIni, "Tooltips", "tooltip_handles_input", false),
                exe_path: this.ReadIniValue(ConfigIni, "Tooltips", "tooltip_exe_path", ""),
                timeouts: {
                    options_menu: this.ReadIniNumber(ConfigIni, "Tooltips", "options_menu_timeout", 10000),
                    status_notification: this.ReadIniNumber(ConfigIni, "Tooltips", "status_notification_timeout", 2000)
                },
                features: {
                    auto_hide_on_action: this.ReadIniBool(ConfigIni, "Tooltips", "auto_hide_on_action", true),
                    persistent_menus: this.ReadIniBool(ConfigIni, "Tooltips", "persistent_menus", false),
                    fade_animation: this.ReadIniBool(ConfigIni, "Tooltips", "tooltip_fade_animation", true),
                    click_through: this.ReadIniBool(ConfigIni, "Tooltips", "tooltip_click_through", true)
                },
                layout: {
                    menu_layout: this.ReadIniValue(ConfigIni, "Tooltips", "menu_layout", "list_vertical")
                }
            },
            
            behavior: {
                timeouts: {
                    global: this.ReadIniNumber(ConfigIni, "Behavior", "global_timeout_seconds", 7),
                    leader: this.ReadIniNumber(ConfigIni, "Behavior", "leader_timeout_seconds", 7)
                },
                emergency: {
                    hybrid_pause_minutes: this.ReadIniNumber(ConfigIni, "Behavior", "hybrid_pause_minutes", 3),
                    enable_emergency_resume_hotkey: this.ReadIniBool(ConfigIni, "Behavior", "enable_emergency_resume_hotkey", true)
                }
            }
        }
        
        ; Create theme object from INI
        iniTheme := {
            name: "INI Theme",
            colors: {
                background: this.ReadIniValue(ConfigIni, "TooltipStyle", "background", "#1a1b26"),
                text: this.ReadIniValue(ConfigIni, "TooltipStyle", "text", "#c0caf5"),
                border: this.ReadIniValue(ConfigIni, "TooltipStyle", "border", "#24283b"),
                accent_options: this.ReadIniValue(ConfigIni, "TooltipStyle", "accent_options", "#bb9af7"),
                accent_navigation: this.ReadIniValue(ConfigIni, "TooltipStyle", "accent_navigation", "#7aa2f7"),
                navigation_text: this.ReadIniValue(ConfigIni, "TooltipStyle", "navigation_text", "#1a1b26"),
                success: this.ReadIniValue(ConfigIni, "TooltipStyle", "success", "#7bd88f"),
                error: this.ReadIniValue(ConfigIni, "TooltipStyle", "error", "#ff6b6b")
            },
            typography: {
                title_font_size: this.ReadIniNumber(ConfigIni, "TooltipStyle", "title_font_size", 18),
                item_font_size: this.ReadIniNumber(ConfigIni, "TooltipStyle", "item_font_size", 14),
                navigation_font_size: this.ReadIniNumber(ConfigIni, "TooltipStyle", "navigation_font_size", 12)
            },
            spacing: {
                border_thickness: this.ReadIniNumber(ConfigIni, "TooltipStyle", "border_thickness", 1),
                corner_radius: this.ReadIniNumber(ConfigIni, "TooltipStyle", "corner_radius", 4),
                padding: this.ParsePadding(this.ReadIniValue(ConfigIni, "TooltipStyle", "padding", "16,12,16,12"))
            },
            window: {
                layout: this.ReadIniValue(ConfigIni, "TooltipWindow", "layout", "list"),
                columns: this.ReadIniNumber(ConfigIni, "TooltipWindow", "columns", 1),
                topmost: this.ReadIniBool(ConfigIni, "TooltipWindow", "topmost", true),
                click_through: this.ReadIniBool(ConfigIni, "TooltipWindow", "click_through", true),
                opacity: Float(this.ReadIniValue(ConfigIni, "TooltipWindow", "opacity", "0.98"))
            },
            position: {
                anchor: this.ReadIniValue(ConfigIni, "TooltipPosition", "anchor", "bottom_right"),
                offset_x: this.ReadIniNumber(ConfigIni, "TooltipPosition", "offset_x", -10),
                offset_y: this.ReadIniNumber(ConfigIni, "TooltipPosition", "offset_y", -10)
            },
            navigation: {
                back_label: "BACKSPACE: Back",
                exit_label: "ESC: Exit"
            }
        }
        
        return {
            config: iniConfig,
            theme: iniTheme,
            source: "ini"
        }
    }
    
    ; Helper: Read INI value with fallback
    static ReadIniValue(iniPath, section, key, default := "") {
        value := IniRead(iniPath, section, key, default)
        if (value = "" || value = "ERROR") {
            return default
        }
        ; Remove inline comments
        if (InStr(value, ";")) {
            value := Trim(SubStr(value, 1, InStr(value, ";") - 1))
        }
        return Trim(value)
    }
    
    ; Helper: Read INI boolean
    static ReadIniBool(iniPath, section, key, default := false) {
        value := this.ReadIniValue(iniPath, section, key, default ? "true" : "false")
        return (StrLower(value) = "true" || value = "1")
    }
    
    ; Helper: Read INI number
    static ReadIniNumber(iniPath, section, key, default := 0) {
        value := this.ReadIniValue(iniPath, section, key, String(default))
        if (value = "" || value = "ERROR") {
            return default
        }
        return Integer(value)
    }
    
    ; Helper: Parse padding string "L,T,R,B"
    static ParsePadding(paddingStr) {
        parts := StrSplit(paddingStr, ",")
        if (parts.Length >= 4) {
            return {
                left: Integer(Trim(parts[1])),
                top: Integer(Trim(parts[2])),
                right: Integer(Trim(parts[3])),
                bottom: Integer(Trim(parts[4]))
            }
        }
        return { left: 16, top: 12, right: 16, bottom: 12 }
    }
}
