# Changelog

All notable changes to the HybridCapslock project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
