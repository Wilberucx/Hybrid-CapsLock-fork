# Changelog

All notable changes to the HybridCapslock project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]

### Added
- Documentation internationalization (i18n) structure with English and Spanish support
- Comprehensive documentation plan in `DOCUMENTATION_I18N_PLAN.md`
- This CHANGELOG file to track project changes

### Changed
- Documentation structure reorganization in progress

### Fixed
- Removed duplicate documentation files (COMO_FUNCIONA_REGISTER.md / HOW_WORKS_REGISTER.md)

---

## [2.0.0] - Previous Version

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

- For migration information from version 1.x, see [MIGRATION_SUMMARY.md](doc/en/reference/migration-summary.md)
- For detailed changes in specific modules, see documentation in `/doc`
