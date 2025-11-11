# 🏗️ Configuration Architecture Blueprint

## 🎯 **VISION: Modern AHK Configuration System**

Migrate from restrictive INI format to expressive AutoHotkey configuration with:
- **Clean architecture** with 2-file structure
- **Theme centralization** in dedicated file
- **Backward compatibility** during transition
- **Type safety** and computed values

## 📊 **CURRENT STATE ANALYSIS (CORRECTED)**

### **Real Configuration Files:**
- ✅ **`config/configuration.ini`** (4520 bytes) - **ONLY ACTIVE INI FILE**
- ❌ **`config/information.ini`** - **OBSOLETE** (removed)

### **Files that Actually Read configuration.ini:**
| File | Status | Configuration Reads | Purpose |
|------|--------|-------------------|---------|
| `src/core/config.ahk` | ✅ ACTIVE | 8+ settings | Core layer/behavior settings |
| `src/ui/tooltip_csharp_integration.ahk` | ✅ ACTIVE | 25+ settings | Complete tooltip system |
| `src/ui/tooltips_native_wrapper.ahk` | ✅ ACTIVE | 2 settings | Fallback tooltip config |
| `src/actions/hybrid_actions.ahk` | ✅ ACTIVE | 1 setting | Version info |

### **Files with False/Deprecated Dependencies:**
| File | Issue | Status | Cleanup Action |
|------|-------|--------|----------------|
| `src/core/globals.ahk` | Only defines paths, doesn't read | ✅ KEEP | Update misleading comments |
| `src/core/mappings.ahk` | Reads non-existent INI files | ⚠️ PARTIAL | Remove deprecated INI reading code |

### **globals.ahk Function Analysis:**
```ahk
// globals.ahk creates GLOBAL STRING VARIABLES with file paths
global ConfigIni := A_ScriptDir . "\\config\\configuration.ini"         ← ✅ EXISTS
global ProgramsIni := A_ScriptDir . "\\config\\programs.ini"           ← ❌ MISSING (dormant feature)
global TimestampsIni := A_ScriptDir . "\\config\\timestamps.ini"       ← ❌ MISSING (dormant feature)  
global InfoIni := A_ScriptDir . "\\config\\information.ini"            ← ❌ OBSOLETE (removed)
global CommandsIni := A_ScriptDir . "\\config\\commands.ini"           ← ❌ MISSING (dormant feature)
```

### **✅ globals.ahk Value:**
- **Path registry function** - Creates string variables with file paths
- **Backward compatibility support** - Easy to reference INI paths during transition
- **Single source of truth** for configuration file locations
- **Essential utility** for configuration system

### **⚠️ mappings.ahk Deprecated Code:**
```ahk
// DEPRECATED: References to non-existent INI files (can be removed)
iniPath := A_ScriptDir . "\\config\\excel_layer.ini"          ← ❌ MISSING
iniPath := A_ScriptDir . "\\config\\nvim_layer.ini"           ← ❌ MISSING

// Functions that read non-existent files:
- LoadSimpleMappings() for missing INI files
- ReloadNvimMappings() fallback behavior
- ReloadExcelMappings() fallback behavior
- Dynamic hotkey registration for missing configs
```

### **🧹 Cleanup Opportunities in mappings.ahk:**
- **Remove dead INI reading** - Code that tries to read non-existent files
- **Remove unused dynamic system** - Complex infrastructure not being used
- **Fix debug_mode system** - Always false, dead code
- **Keep ExecuteAction()** - Still used by static layer implementations
- **Simplify to static-only** - Remove dynamic hotkey complexity

## 🏗️ **NEW ARCHITECTURE: Simple 2-File System**

### **Target Structure:**
```
config/
├── configuration.ini          ← Keep during transition (backward compatibility)
├── colorscheme.ahk           ← NEW: All themes and visual styling  
└── settings.ahk              ← NEW: All non-visual configuration
```

### **Clean Separation of Concerns:**
| File | Purpose | Contains |
|------|---------|----------|
| `colorscheme.ahk` | **Visual Theming** | Colors, fonts, spacing, themes, UI styling |
| `settings.ahk` | **System Behavior** | Layers, timeouts, features, toggles, performance |

## 🎨 **colorscheme.ahk Structure**

```ahk
; config/colorscheme.ahk - Visual Theme System

; ===============================
; HYBRIDCAPSLOCK THEME SYSTEM
; ===============================

; Current Active Theme
global CurrentTheme := "default"

; Theme Registry
global Themes := Map(
    "default", DefaultTheme,
    "dark", DarkTheme, 
    "light", LightTheme,
    "high_contrast", HighContrastTheme
)

; ===============================
; DEFAULT THEME
; ===============================

DefaultTheme := {
    name: "Default",
    description: "Clean, professional theme",
    
    ; Color System
    colors: {
        ; Semantic colors
        primary: "#2D3748",
        secondary: "#4A5568",
        accent: "#3182CE",
        success: "#38A169",
        warning: "#D69E2E",
        error: "#E53E3E",
        
        ; Context-specific
        text: {
            primary: "#FFFFFF",
            secondary: "#CBD5E0", 
            muted: "#A0AEC0",
            inverse: "#1A202C"
        },
        
        background: {
            primary: "#1A202C",
            secondary: "#2D3748",
            overlay: "#4A5568",
            tooltip: "#2D3748"
        },
        
        border: {
            default: "#4A5568",
            focus: "#3182CE",
            error: "#E53E3E"
        }
    },
    
    ; Typography System
    typography: {
        scale: 1.0,
        
        fonts: {
            ui: { 
                family: "Segoe UI", 
                size: 11, 
                weight: 400 
            },
            header: { 
                family: "Segoe UI", 
                size: 13, 
                weight: 600 
            },
            mono: { 
                family: "Consolas", 
                size: 10, 
                weight: 400 
            },
            navigation: {
                family: "Segoe UI",
                size: 10,
                weight: 500
            }
        }
    },
    
    ; Spacing System
    spacing: {
        scale: 1.0,
        base: 8,  ; 8px base unit
        
        ; Computed spacing
        xs: () => this.base * 0.5,    ; 4px
        sm: () => this.base * 1,      ; 8px  
        md: () => this.base * 2,      ; 16px
        lg: () => this.base * 3,      ; 24px
        xl: () => this.base * 4,      ; 32px
        
        ; Specific use cases
        tooltip: {
            padding: { x: 12, y: 8 },
            margin: { x: 4, y: 4 },
            border_radius: 6
        },
        
        menu: {
            padding: { x: 16, y: 12 },
            item_height: 28,
            separator: 8
        }
    },
    
    ; Animation Settings
    animations: {
        enabled: true,
        duration: 200,
        easing: "ease-out",
        
        ; Specific animations
        tooltip: {
            fade: true,
            duration: 150
        },
        
        menu: {
            slide: true,
            duration: 250
        }
    },
    
    ; Window Properties  
    window: {
        opacity: 0.95,
        topmost: true,
        click_through: false,
        shadow: true,
        border_width: 1
    }
}

; Additional theme definitions...
DarkTheme := { /* ... */ }
LightTheme := { /* ... */ }
HighContrastTheme := { /* ... */ }

; ===============================
; THEME FUNCTIONS
; ===============================

; Get current theme
GetCurrentTheme() {
    return Themes[CurrentTheme]
}

; Switch theme
SetTheme(themeName) {
    if (Themes.Has(themeName)) {
        CurrentTheme := themeName
        ; Trigger theme change event
        OnThemeChanged(themeName)
        return true
    }
    return false
}

; Theme change callback (to be overridden by consumers)
OnThemeChanged(themeName) {
    ; Override in main application
}
```

## ⚙️ **settings.ahk Structure**

```ahv
; config/settings.ahk - System Configuration

; ===============================
; HYBRIDCAPSLOCK SETTINGS
; ===============================

; Application Info
AppConfig := {
    name: "HybridCapsLock",
    version: "2.1.0", 
    debug_mode: false,
    config_version: 1,
    
    ; Paths (using globals.ahk pattern)
    paths: {
        config_dir: A_ScriptDir . "\\config",
        data_dir: A_ScriptDir . "\\data",
        temp_dir: A_ScriptDir . "\\temp"
    }
}

; Layer System Configuration
LayerConfig := {
    ; Global settings
    global: {
        persistence_enabled: true,
        transition_timeout: 300,
        debug_switches: false
    },
    
    ; Individual layers
    layers: {
        nvim: {
            enabled: true,
            timeout: 5000,
            
            ; Auto-activation rules
            auto_activate: ["notepad.exe", "Code.exe", "nvim.exe"],
            
            ; Persistence settings
            persistence: {
                remember_visual_mode: true,
                remember_position: false
            },
            
            ; Context-aware behavior
            context_rules: Map(
                "excel", () => "Use arrow keys instead of hjkl",
                "browser", () => "Enable scrolling mode"
            )
        },
        
        excel: {
            enabled: true,
            timeout: 8000,
            auto_activate: ["EXCEL.EXE"],
            
            features: {
                smart_selection: true,
                formula_detection: true,
                enhanced_navigation: true
            },
            
            vlogic: {
                row_ops: ["vr", "dr", "yr"],
                col_ops: ["vc", "dc", "yc"]
            }
        },
        
        leader: {
            enabled: true,
            timeout: 8000,
            
            categories: {
                hybrid: { symbol: "h", priority: 1 },
                programming: { symbol: "c", priority: 2 },
                system: { symbol: "o", priority: 3 }
            }
        }
    }
}

; Tooltip System Configuration
TooltipConfig := {
    ; Core settings
    enabled: true,
    handles_input: true,
    exe_path: A_ScriptDir . "\\bin\\TooltipApp.exe",
    
    ; Timeouts
    timeouts: {
        menu: 5000,
        notification: 2000,
        quick: 1500,
        persistent: 0,
        
        ; Dynamic timeout based on content length
        dynamic: (text) => Max(1000, StrLen(text) * 50)
    },
    
    ; Window behavior
    window: {
        layout: "vertical",
        columns: 2,
        
        ; Smart positioning
        position: {
            anchor: "center", 
            offset: { x: 0, y: -50 },
            fallbacks: ["center-bottom", "top-center", "mouse"]
        }
    },
    
    ; Features
    features: {
        auto_hide_on_action: true,
        persistent_menus: false,
        multi_monitor_aware: true,
        fade_animation: true,
        
        ; Context-aware positioning
        smart_position: (context) => {
            switch context {
                case "leader": return "bottom-right"
                case "nvim": return "center"
                case "excel": return "top-right"
                default: return "center"
            }
        }
    }
}

; System Behavior Configuration
BehaviorConfig := {
    ; Performance settings
    performance: {
        adaptive_timeouts: true,
        gc_interval: 30000,
        monitor_cpu: false,
        max_memory_mb: 100
    },
    
    ; Emergency systems
    emergency: {
        resume_enabled: true,
        resume_hotkey: "Ctrl+Alt+H",
        
        ; Auto-resume conditions
        auto_resume_when: [
            () => ProcessExist("kanata.exe") == 0,
            () => !isNvimLayerActive && WinActive("ahk_exe Code.exe")
        ]
    },
    
    ; User experience
    ux: {
        show_confirmations: true,
        learning_mode: false,
        reduced_motion: false,
        high_contrast: false
    },
    
    ; System integration
    system: {
        startup_with_windows: false,
        minimize_to_tray: true,
        check_updates: true,
        telemetry: false
    }
}

; Export unified configuration
global HybridConfig := {
    app: AppConfig,
    layers: LayerConfig,
    tooltips: TooltipConfig,
    behavior: BehaviorConfig,
    
    ; Computed properties
    isDeveloper: AppConfig.debug_mode,
    isProduction: !AppConfig.debug_mode,
    
    ; Helper functions
    getTheme: () => GetCurrentTheme(),
    setTheme: (name) => SetTheme(name)
}
```

## 🧹 **CLEANUP PHASE: Remove Deprecated Code**

### **Before Migration - Code Cleanup:**

#### **1. src/core/mappings.ahk Cleanup**
```ahk
// REMOVE: Dead dynamic hotkey system
- LoadSimpleMappings() for non-existent INI files
- ReloadNvimMappings() INI fallback logic  
- ReloadExcelMappings() INI fallback logic
- References to excel_layer.ini and nvim_layer.ini

// KEEP: Still-used functions
+ ExecuteAction() - Used by static layers for macro support
+ Hotkey registration/unregistration infrastructure
+ Context function utilities

// FIX: Debug system
- Remove dead debug_mode checks (always false)
+ Or implement real debug configuration
```

#### **2. src/core/globals.ahk Cleanup**
```ahk
// FIX: Misleading comments
- ; Debug flag (loaded from configuration.ini [General].debug_mode)
+ ; Debug flag (currently hardcoded, could be made configurable)

// REMOVE: References to obsolete files
- global InfoIni := A_ScriptDir . "\\config\\information.ini"
- global ProgramsIni := A_ScriptDir . "\\config\\programs.ini"  
- global TimestampsIni := A_ScriptDir . "\\config\\timestamps.ini"
- global CommandsIni := A_ScriptDir . "\\config\\commands.ini"

// KEEP: Essential path
+ global ConfigIni := A_ScriptDir . "\\config\\configuration.ini"
```

#### **3. Remove Obsolete INI References**
```ahk
// Search and remove all references to:
- ProgramsIni variable usage
- TimestampsIni variable usage  
- InfoIni variable usage
- CommandsIni variable usage
- Any IniRead() calls using these paths
```

### **Post-Cleanup Benefits:**
- ✅ **Cleaner codebase** - No dead code or false dependencies
- ✅ **Accurate documentation** - What reads what is clear
- ✅ **Better performance** - No unnecessary file operations
- ✅ **Easier maintenance** - Simplified, focused functionality

## 🔄 **Migration Strategy: Dual System Support**

### **Phase 1: Create New Architecture (Week 1)**
```ahk
; src/core/config_loader.ahk - Smart configuration loader

class ConfigLoader {
    static Load() {
        ; Try new AHK config first
        try {
            ; Load theme system
            #Include ..\config\colorscheme.ahk
            
            ; Load main settings  
            #Include ..\config\settings.ahk
            
            return {
                config: HybridConfig,
                theme: GetCurrentTheme(),
                source: "ahk"
            }
        } catch {
            ; Fallback to legacy INI
            return this.LoadLegacyINI()
        }
    }
    
    static LoadLegacyINI() {
        ; Use globals.ahk paths (backward compatibility)
        return {
            config: this.ConvertINIToObject(),
            theme: this.CreateDefaultTheme(),
            source: "ini"
        }
    }
    
    static Migrate() {
        ; Auto-convert configuration.ini to new AHK format
        ; Preserve user customizations
        ; Create colorscheme.ahk and settings.ahk
    }
}
```

### **Phase 2: Gradual File Migration (Week 2)**

#### **Update each consumer to use new loader:**
```ahk
; Before:
enabledValue := IniRead(ConfigIni, "Tooltips", "enable_csharp_tooltips", "true")

; After:  
config := ConfigLoader.Load()
enabled := config.config.tooltips.enabled
```

### **Phase 3: Legacy Cleanup (Week 3)**
- Remove configuration.ini when all consumers migrated
- Keep globals.ahk for path utilities
- Update documentation

## ✅ **Benefits of New Architecture**

### **🎨 Theme System:**
- **Centralized theming** in colorscheme.ahk
- **Multiple theme support** (default, dark, light, high contrast)
- **Runtime theme switching** 
- **Computed colors** and responsive design

### **⚙️ Configuration System:**
- **Type safety** - Objects instead of strings
- **Computed values** - Dynamic timeouts and smart positioning
- **Nested structures** - Organized settings hierarchy
- **Validation** - Catch configuration errors early

### **🔧 Development Experience:**
- **Native AHK syntax** - No string parsing
- **IDE support** - Syntax highlighting and autocomplete
- **Version control friendly** - Proper diffs
- **Modular structure** - Easy to maintain and extend

### **🔄 Backward Compatibility:**
- **globals.ahk preserved** - Path utility functions remain
- **Dual system support** - Both INI and AHK work during transition
- **Auto-migration** - Convert existing settings automatically
- **User settings preserved** - No data loss

## 🎯 **Implementation Timeline**

| Week | Focus | Deliverable |
|------|-------|-------------|
| 1 | Foundation | New architecture + dual loader |
| 2 | Migration | Convert all consumers to new system |
| 3 | Cleanup | Remove legacy INI, finalize documentation |

## 🛡️ **Risk Mitigation**

### **Low Risk Implementation:**
- ✅ **Keep globals.ahk unchanged** - Preserves path utilities
- ✅ **Dual system support** - Both formats work during transition  
- ✅ **Auto-migration utility** - Convert user settings
- ✅ **Rollback capability** - Can revert to INI if needed

### **User Impact: Zero**
- **Transparent migration** - Users don't need to do anything
- **Settings preserved** - All customizations maintained
- **Enhanced features** - Better theming and configuration options

---

## 🏆 **Result: World-Class Configuration System**

### **Professional Architecture:**
- **2-file structure** - Clean separation (themes vs. settings)
- **Type-safe configuration** - Native AHK objects
- **Theme system** - Multiple themes with runtime switching
- **Backward compatibility** - Smooth migration path

### **Developer Experience:**
- **Native syntax** - TOML/Lua-like expressiveness
- **IDE integration** - Full tooling support
- **Maintainable code** - Modular, organized structure
- **Future-proof** - Easy to extend and enhance

**Blueprint ready for implementation! 🚀**