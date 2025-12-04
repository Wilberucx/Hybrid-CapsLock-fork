; ===============================
; HYBRIDCAPSLOCK SETTINGS
; ===============================
; System configuration for HybridCapsLock
; Non-visual settings (behavior, layers, features)

; ===============================
; APPLICATION CONFIG
; ===============================

AppConfig := {
    name: "HybridCapsLock",
    version: "3.1.0",
    debug_mode: false,
    log_level: "INFO",  ; TRACE, DEBUG, INFO, WARNING, ERROR
    config_version: 1,
    
    ; Paths
    paths: {
        config_dir: A_ScriptDir . "\config",
        data_dir: A_ScriptDir . "\data",
        scripts_dir: A_ScriptDir . "\src"
    }
}

; ===============================
; LAYER SYSTEM CONFIG
; ===============================

LayerConfig := {
    ; Global layer settings
    global: {
        persistence_enabled: true,
        debug_switches: false
    },
    
    ; Individual layer configurations
    layers: {
        nvim: {
            enabled: true,
            timeout: 5000,
            tap_threshold_ms: 250,
            yank_feedback_return: true
        },
        
        excel: {
            enabled: true,
            timeout: 8000
        },
        
        leader: {
            enabled: true,
            timeout: 7000
        }
    }
}

; ===============================
; TOOLTIP SYSTEM CONFIG
; ===============================

TooltipConfig := {
    enabled: true,
    handles_input: false,
    exe_path: "",  ; Empty = auto-detect
    
    ; Timeouts (milliseconds)
    timeouts: {
        options_menu: 10000,
        status_notification: 2000
    },
    
    ; Features
    features: {
        auto_hide_on_action: true,
        persistent_menus: false,
        fade_animation: true,
        click_through: true
    },
    
    ; Layout
    layout: {
        menu_layout: "list_vertical"  ; "list_vertical" or "grid"
    }
}

; ===============================
; BEHAVIOR CONFIG
; ===============================

BehaviorConfig := {
    ; Timeouts (seconds)
    timeouts: {
        global: 7,
        leader: 7
    },
    
    ; Emergency systems
    emergency: {
        hybrid_pause_minutes: 3,
        enable_emergency_resume_hotkey: true
    }
}

; ===============================
; KANATA MANAGER CONFIG
; ===============================

KanataConfig := {
    enabled: true,                              ; Enable Kanata management
    exePath: "kanata.exe",                      ; Kanata binary path (can be full path or in PATH)
    configFile: "ahk\config\kanata.kbd",        ; Config file path (relative to script dir)
    startDelay: 500,                            ; Milliseconds to wait after starting
    autoStart: true,                            ; Start Kanata automatically with HybridCapsLock
    fallbackPaths: [                            ; Paths to search for kanata.exe
        A_ScriptDir . "\bin\kanata.exe",
        A_ScriptDir . "\kanata.exe",
        "C:\Program Files\kanata\kanata.exe",
        A_AppData . "\..\Local\kanata\kanata.exe"
    ]
}

; ===============================
; UNIFIED CONFIG EXPORT
; ===============================

global HybridConfig := {
    app: AppConfig,
    layers: LayerConfig,
    tooltips: TooltipConfig,
    behavior: BehaviorConfig,
    kanata: KanataConfig,
    
    ; Computed properties
    isDeveloper: AppConfig.debug_mode,
    isProduction: !AppConfig.debug_mode,
    
    ; Helper functions (defined in colorscheme.ahk)
    getTheme: (*) => GetCurrentTheme(),
    setTheme: (name, *) => SetTheme(name)
}
