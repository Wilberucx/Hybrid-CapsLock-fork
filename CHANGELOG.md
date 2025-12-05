# Changelog

All notable changes to the HybridCapslock project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased] - 2025-12-03

### Added

- **Kanata Manager Plugin** (`system/plugins/kanata_manager.ahk`): New core plugin that manages Kanata lifecycle (start, stop, restart, toggle) using native AutoHotkey v2 functions.
- **Kanata Configuration Section** in `ahk/config/settings.ahk`: Centralized configuration with auto-start control, custom paths, and automatic path detection.
- **Extended Kanata API**:
  - `KanataToggle()`: Toggle Kanata on/off with single command
  - `KanataShowStatus(duration := 1500)`: Display Kanata status in tooltip with PID info
  - `KanataStartWithRetry(maxRetries := 3, retryDelay := 1000)`: Robust start with automatic retry logic
  - `KanataGetStatus()`: Get human-readable status string
  - `KanataGetPID()`: Get process ID of running Kanata instance
- **Kanata Keymaps** in `system/plugins/hybrid_actions.ahk`: New subcategory under Hybrid category (`h` → `k`) with quick access to:
  - Toggle Kanata on/off
  - Restart Kanata
  - Show Kanata status
- **Automatic Path Detection**: Plugin searches common locations for `kanata.exe` (portable releases, Program Files, AppData, PATH).
- **Config Pre-validation**: `KanataStart()` validates config with `--check` flag before starting Kanata, preventing silent failures.
- **Advanced Error Handling**: Intelligent error parsing with 9 error types (SYNTAX_ERROR, PORT_IN_USE, INVALID_KEY, NOT_FOUND, FILE_ERROR, NO_OUTPUT, RUNTIME_ERROR, etc.).
- **Contextual Error Dialogs**: User-friendly error messages with line numbers, context snippets, and fix suggestions specific to each error type.
- **Process Crash Detection**: Monitors if Kanata crashes immediately after starting (checks twice with delays).
- **Output Capture**: Uses `shell.Exec` COM object to capture STDOUT and STDERR from Kanata for detailed error reporting.
- **ANSI Code Cleaning**: Automatically removes ANSI color codes and box-drawing characters from Kanata output for clean error messages.
- **Error Handling & Logging**: Integrated with HybridCapsLock logging system (`LogKanataInfo`, `LogKanataError`) for better debugging.

### Changed

- **Kanata Management**: Migrated from VBScript-based approach to native AutoHotkey v2 implementation using `Run()` with "Hide" flag and `ProcessClose()`.
- **Plugin Architecture**: Moved Kanata management from `system/core/` to `system/plugins/` following established plugin pattern.
- **Auto-Loading**: Kanata plugin now loads automatically via auto_loader instead of manual include in `init.ahk`.
- **Configuration**: Replaced hardcoded paths in VBS scripts with centralized, user-configurable settings in `settings.ahk`.

### Deprecated

> **DEPRECATED:** Legacy function names (maintained for backward compatibility via aliases):
> - `StartKanataIfNeeded()` → Use `KanataStart()` instead
> - `StopKanata()` → Use `KanataStop()` instead (alias kept to avoid conflicts)
> - `RestartKanata()` → Use `KanataRestart()` instead
> - `IsKanataRunning()` → Use `KanataIsRunning()` instead
> 
> **Note**: Legacy functions remain fully functional as aliases. No code changes required.

### Removed

- **VBScript Files** (replaced by native AHK functions):
  - `system/core/kanata/start_kanata.vbs` → Replaced by `KanataStart()` using `Run(cmd, , "Hide")`
  - `system/core/kanata/stop_kanata.vbs` → Replaced by `KanataStop()` using `ProcessClose()`
  - `system/core/kanata/restart_kanata.vbs` → Replaced by `KanataRestart()` combining stop + start
- **Core Module**: `system/core/kanata_launcher.ahk` → Replaced by plugin architecture in `system/plugins/kanata_manager.ahk`
- **Kanata Directory**: `system/core/kanata/` and its README → No longer needed with native implementation
- **Reference Directory**: `kanata-info/` (including `kanata-script.ahk`, `kanata.bat`, `kanata-silent.vbs`, `README.md`) → External reference no longer needed after implementation
- **Internal Function**: `GetKanataScriptPath()` → No longer needed without VBS scripts
- **Manual Include**: Line 28 in `init.ahk` removed (plugin auto-loads)

### Fixed

- **Portability**: Eliminated hardcoded absolute paths in VBS scripts. Paths are now configurable and auto-detected.
- **Complexity**: Reduced from 4+ files (AHK + VBS) to single plugin file.
- **Maintenance**: Eliminated dependency on external VBScript files, simplifying codebase.
- **Error Visibility**: Added proper error handling and logging (previously silent failures in VBS).
- **Silent Failures**: Config validation now happens BEFORE starting Kanata, preventing cryptic startup failures.
- **Error Messages**: Users now get detailed, actionable error messages instead of generic "Kanata failed to start".

### Technical Notes

**Architecture Improvements:**
- **Before**: 4 files (kanata_launcher.ahk + 3 VBS scripts), hardcoded in core, manual include
- **After**: 1 plugin file, auto-loaded, configurable, native AHK v2

**Code Metrics:**
- **Files Removed**: 7 (1 AHK + 3 VBS + 3 reference files + README)
- **Files Added**: 1 (kanata_manager.ahk - 742 lines with comprehensive error handling)
- **Net Reduction**: -6 files
- **Technologies**: VBScript eliminated, pure AutoHotkey v2
- **Error Handling**: 9 error types with pattern matching, contextual dialogs, and fix suggestions
- **Validation**: Two-step start process (validate then run) for better reliability

**Backward Compatibility:**
- **100% compatible**: All existing code continues working without changes
- **Aliases maintained**: Legacy function names preserved as aliases
- **Graceful degradation**: Plugin works even if Kanata is not installed

**Configuration Example:**
```autohotkey
HybridConfig.kanata := {
    enabled: true,
    exePath: "kanata.exe",
    configFile: "ahk\config\kanata.kbd",
    startDelay: 500,
    autoStart: true,
    fallbackPaths: [
        A_ScriptDir . "\bin\kanata.exe",
        A_ScriptDir . "\kanata.exe",
        "C:\Program Files\kanata\kanata.exe",
        A_AppData . "\..\Local\kanata\kanata.exe"
    ]
}
```

**Migration Guide:**

For End Users:
- **No action required.** All existing functionality preserved.

For Developers (Optional):
- Old: `StartKanataIfNeeded()` → New: `KanataStart()`
- Old: `RestartKanata()` → New: `KanataRestart()`

For Custom Configurations:
- If you previously modified VBS scripts, migrate customizations to `settings.ahk`:
  ```autohotkey
  ; Example: Custom Kanata path
  HybridConfig.kanata.exePath := "C:\custom\path\kanata.exe"
  HybridConfig.kanata.autoStart := false  ; Disable auto-start
  ```

---

## [3.1.0] - 2025-12-01

### Added

- **Layer Suppression Mode**: `RegisterLayer` now accepts optional `suppressUnmapped` parameter
  - `true` (default): Only mapped keys work, unmapped keys are blocked (original behavior)
  - `false`: Unmapped keys pass through to the application (new feature)
  - Useful for layers that only intercept specific keys (e.g., Vim mode with only ESC mapped)
  - Example: `RegisterLayer("vim", "VIM MODE", "#7F9C5D", "#ffffff", false)`
  - Technical: Uses InputHook with conditional passthrough mode
  - Unmapped keys are sent with `Send("{Blind}" . key)` to preserve modifiers
- **Dynamic Layer Help System**: Press `?` in any active layer to view all available keybindings
  - Automatically queries `KeymapRegistry` for current layer keymaps
  - Displays help using C# tooltip system with consistent styling
  - Works in all layers without requiring manual configuration
- **Category Feedback with Timeout**: Categories now show available keymaps after 500ms delay
  - Similar behavior to leader menu for better user experience
  - Helps users discover available options without memorization
  - Maintains fast navigation for experienced users
- **New Plugin**: `explorer_actions.ahk` - Optional plugin providing vim-style navigation and file management for Windows Explorer
  - Explorer layer with vim-inspired keybindings
  - Rename action (`r`) that sends F2 and switches to insert mode
  - Tab manager category (`b`) with window management actions
  - Copy actions category (`c`) for path operations
  - File operations: toggle hidden files (`.`), add file/folder (`a`), edit file (`e`)
  - Entry point: `Leader → e → x` to activate explorer layer
- **Core Function**: `GetSelectedExplorerItem()` in `context_utils.ahk` - Returns the full path of the currently selected file/folder in Windows Explorer using COM
- **New Plugin**: `welcome_screen.ahk` - Displays an animated welcome screen on startup with system info and tips
  - Auto-start functionality (800ms delay)
  - `ShowQuickTip()` function for displaying temporary notifications with icons
- **TooltipApp v2.1 Compatibility**: Full support for new TooltipApp features
  - NerdFont icon support in tooltips via `style.font_family` and Unicode glyphs
  - Animation system with fade and slide effects (`animation.type`, `animation.duration_ms`, `animation.easing`)
  - Multi-monitor positioning with DPI awareness (`position.monitor`)
  - Multi-window support for simultaneous independent tooltips (unique `id` per window)
  - Granular configuration objects: `layout`, `window`, `animation`, `position`, `style`
- **Helper Functions**: New utility functions for advanced tooltip features
  - Support for `layout.mode` (grid/list) and `layout.columns`
  - Support for `window.topmost`, `window.click_through`, `window.opacity`
  - Support for animation easing functions: `linear`, `ease_in`, `ease_out`, `ease_in_out`, `bounce`
- **Vim-Style Modifier Key Syntax**: Support for Vim-style modifier syntax in all keymap registration functions
  - New `ParseModifierKey(key)` function for parsing modifier syntax: `<C-a>`, `<S-C-a>`, `<A-S-k>`, etc.
  - Automatic conversion to AutoHotkey format (e.g., `<C-a>` → `^a`)
  - Dual key storage: `"key"` (parsed for execution) and `"displayKey"` (original for UI)
  - Support for complex modifier combinations: `<C-A-S-x>` → Ctrl+Alt+Shift+x
- **Declarative Trigger Registration**: New `RegisterTrigger(key, action, condition)` function for global hotkey registration
  - Declarative way to register global hotkey triggers with conditions and SuspendExempt behavior
  - Support for conditional triggers using string variable names or function references
  - Automatic HotIf context management to prevent condition leakage
  - Lambda wrapper for proper callback handling in dynamic hotkey registration

### Changed

- **tooltip_csharp_integration.ahk**: Updated to support TooltipApp v2.1 API
  - Enhanced `SerializeJson()` to handle new nested configuration objects
  - Updated `ReadTooltipThemeDefaults()` to support animation and layout configs
  - Improved `ShowCSharpTooltipAdvanced()` to accept animation and window options
- **Configuration System**: Extended theme configuration to include animation defaults
  - Added support for `animation` object in theme configuration
  - Added support for `layout` object in theme configuration
  - Added support for `window` object properties
- **vim_actions.ahk** plugin now uses passthrough mode (`suppressUnmapped := false`)
  - Vim, Visual, and Insert modes now allow unmapped keys to work normally
  - Users can now type freely in Vim mode while only specific keys (like ESC) are intercepted
- **keymap_registry.ahk**: Enhanced keymap registration and navigation
  - Modified `ListenForLayerKeymaps` to intercept `?` key for help display
  - Enhanced `NavigateHierarchicalInLayer` with 500ms timeout to show category keymaps automatically
  - Refined `Esc` key behavior: pressing `Esc` while help tooltip is active now closes only the tooltip, keeping the layer active
  - Fixed `?` key detection issues on US layouts by also accepting `Shift` + `/` combination
  - `RegisterKeymapHierarchical()` now parses all path keys and stores both parsed and display versions
  - `RegisterCategoryKeymap()` now parses category keys and stores both versions
  - `RegisterTrigger()` now parses trigger keys to support modifier syntax in global hotkeys
  - `ExecuteKeymapAtPath()` now parses input keys for proper matching against registry
  - `BuildMenuForPath()` and `GenerateCategoryItemsForPath()` now use `displayKey` for user-friendly display
  - UI now displays original modifier syntax (`<C-a>`) instead of AutoHotkey symbols (`^a`)
- **keymap.ahk**: Refactored to use `RegisterTrigger()` instead of verbose `#HotIf` blocks
  - Simplified F24 (Leader Layer) and F23 (Dynamic Layer) trigger registration from 9 lines to 2 lines
  - Improved code aesthetics and maintainability

### Deprecated

- **tooltip_type field**: Replaced by granular `layout`, `window`, and `animation` objects
  - Still supported for backward compatibility
  - Recommended to migrate to new configuration objects
- **Hardcoded layout logic**: Use `layout.mode` and `layout.columns` instead
- **Manual `#SuspendExempt` + `#HotIf` blocks**: Use `RegisterTrigger(key, action, condition)` instead
  - Old pattern still works but is not recommended
  - New triggers should use `RegisterTrigger()` for consistency

### Fixed

- Runtime error in `welcome_screen.ahk` where `.Has()` was used on `HybridConfig` (Object) instead of `.HasOwnProp()`
- **JSON Serialization**: Improved handling of nested Map objects for new TooltipApp API structure
- **Theme Loading**: Better fallback handling when HybridConfig is not available

### Technical Notes

- **Backward Compatibility**: All existing scripts continue to work without modifications
- **Migration Path**: New features are opt-in; gradual migration recommended
- **Performance**: No performance degradation; animations run at 60 FPS
- **Layer Help**: New functions `GenerateLayerHelpItems(layerName)` and `ShowLayerHelp(layerName)` for dynamic help generation
- **Modifier Parsing**: Negligible impact (parsing at registration time only)
- **Trigger Registration**: Uses `Hotkey()` function with "S" option for SuspendExempt behavior

---

## [3.0.0] - 2025-11-28

### Added

- Documentation in English for all core features
- Comprehensive English documentation structure in `doc/en/`
- Developer guides and API documentation

### Changed

- Complete documentation reorganization and internationalization
- Improved documentation structure for better accessibility

---

## [2.0.1] - 2025-11-27

### Fixed

- Switch between layers, can exit on original layer

---

## [2.0.0] - Previous Version

### Added

- Documentation internationalization (i18n) structure with English and Spanish support
- Comprehensive documentation plan in `DOCUMENTATION_I18N_PLAN.md`
- This CHANGELOG file to track project changes

### Changed

- Documentation structure reorganization in progress

### Fixed

- Removed duplicate documentation files (COMO_FUNCIONA_REGISTER.md / HOW_WORKS_REGISTER.md)

---

## [1.0.0]

### Added

- Hybrid system combining Kanata (timing/homerow mods) with AutoHotkey (context-aware logic)
- Declarative keymap system inspired by lazy.nvim and which-key
- Auto-loader system for automatic detection of layers and actions
- Multiple layers: nvim, excel, scroll, visual, leader
- Homerow mods implementation (a/s/d/f, j/k/l/;)
- C# tooltip integration for visual feedback
- Hot-reload support
- Comprehensive documentation in `/doc`

### Changed

- Complete refactor from original CapsLockX fork
- New modular architecture with clear separation:
  - `/src/core` - Core system
  - `/src/actions` - Action modules
  - `/src/layer` - Layer implementations
  - `/src/ui` - User interface components

---

## Notes

- For detailed changes in specific modules, see documentation in `/doc`
- For user guides, see [English Documentation](doc/en/) or [Spanish Documentation](doc/es/)
