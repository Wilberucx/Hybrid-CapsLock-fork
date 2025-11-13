# 📚 HybridCapslock Documentation (English)

Complete documentation for the HybridCapslock keyboard customization system.

**[🌍 Ver en Español](../es/README.md)** | **[← Back to Main Index](../README.md)**

---

## 📖 Table of Contents

### 🚀 Getting Started
- **[Quick Start Guide](getting-started/quick-start.md)** - Get up and running in 5 minutes
- **[Installation](getting-started/installation.md)** - Detailed installation instructions
- **[Configuration](getting-started/configuration.md)** - Configure HybridCapslock for your needs

### 👤 User Guide
- **[Homerow Mods](user-guide/homerow-mods.md)** - Use home row keys as modifiers
- **[Leader Mode](user-guide/leader-mode.md)** - Powerful leader key combinations
- **[Nvim Layer](user-guide/nvim-layer.md)** - Vim-style navigation everywhere
- **[Nvim Colon Mode](user-guide/nvim-colon-mode.md)** - Command mode for advanced users
- **[Excel Layer](user-guide/excel-layer.md)** - Specialized Excel productivity layer
- **[Numpad & Media Layers](user-guide/numpad-media-layers.md)** - Number pad and media controls

### 🔧 Developer Guide
- **[Creating New Layers](developer-guide/creating-layers.md)** - Build your own custom layers
- **[Auto-Loader System](developer-guide/auto-loader-system.md)** - How automatic module loading works
- **[Keymap System](developer-guide/keymap-system.md)** - Unified keymap registration system
- **[Layer Functions Reference](developer-guide/layer-functions-reference.md)** - Complete API reference
- **[Layer Name Guide](developer-guide/layer-name-guide.md)** - Naming conventions and best practices
- **[Hotkeys vs Keymaps](developer-guide/hotkeys-vs-keymaps.md)** - Understanding the difference
- **[Testing Guide](developer-guide/testing.md)** - Manual testing procedures

### 📋 Technical Reference
- **[How Register Works](reference/how-register-works.md)** - Deep dive into the registration system
- **[Debug System](reference/debug-system.md)** - Debugging tools and techniques
- **[Declarative System](reference/declarative-system.md)** - Overview of the declarative approach
- **[Migration Summary](reference/migration-summary.md)** - Changes from previous versions
- **[Refactor Layer System](reference/refactor-layer-system.md)** - Layer system architecture changes
- **[Startup Changes](reference/startup-changes.md)** - Recent startup sequence modifications

---

## 🎯 Quick Links

### Most Popular Guides
1. [Homerow Mods](user-guide/homerow-mods.md) - The foundation of efficient typing
2. [Creating New Layers](developer-guide/creating-layers.md) - Extend HybridCapslock
3. [Leader Mode](user-guide/leader-mode.md) - Master keyboard shortcuts

### Common Tasks
- **Customize keybindings**: See [Configuration Guide](getting-started/configuration.md)
- **Add new layer**: Follow [Creating New Layers](developer-guide/creating-layers.md)
- **Troubleshoot issues**: Check [Debug System](reference/debug-system.md)
- **Understand architecture**: Read [Declarative System](reference/declarative-system.md)

---

## 🏗️ System Architecture

HybridCapslock uses a hybrid architecture combining:

- **Kanata** (Low-level)
  - Hardware-level key interception
  - Homerow mods timing
  - Fast, reliable modifier keys

- **AutoHotkey** (High-level)
  - Context-aware application logic
  - Complex keybindings and macros
  - Visual feedback (tooltips)
  - Layer management

### Project Structure
```
HybridCapslock/
├── src/
│   ├── core/           # Core system (config, loader, persistence)
│   ├── actions/        # Action modules (auto-loaded)
│   ├── layer/          # Layer implementations (auto-loaded)
│   └── ui/             # User interface (tooltips)
├── config/             # User configuration files
│   ├── keymap.ahk      # Main keymap definitions
│   ├── settings.ahk    # System settings
│   ├── colorscheme.ahk # UI color scheme
│   └── ../../../config/kanata.kbd      # Kanata configuration
├── data/               # Runtime data (layer state, registry)
└── doc/                # Documentation (you are here!)
```

---

## 🔍 Key Concepts

### Layers
Modal states that change keyboard behavior (like Vim modes). Each layer can define:
- Custom keybindings
- Visual indicators (tooltips)
- Application-specific behavior
- Automatic activation/deactivation

### Homerow Mods
Use home row keys as modifier keys when held:
- `a` → Alt (when held)
- `s` → Shift (when held)
- `d` → Ctrl (when held)
- `f` → Win (when held)

Mirror layout on right hand: `j/k/l/;`

### Auto-Loader
Automatically detects and loads:
- New layer files in `src/layer/`
- New action files in `src/actions/`
- No need to manually edit includes!

### Declarative System
Register keymaps declaratively:
```ahk
RegisterKeymaps("layer_name", [
    {key: "h", desc: "Move Left", action: "Send {Left}"},
    {key: "j", desc: "Move Down", action: "Send {Down}"},
    {key: "k", desc: "Move Up", action: "Send {Up}"},
    {key: "l", desc: "Move Right", action: "Send {Right}"}
])
```

---

## 📚 Additional Resources

### Templates
- [Layer Template](../templates/template_layer.ahk) - Boilerplate for new layers

### Development Notes
See [`../develop/`](../develop/) for technical implementation notes:
- Excel V logic mini-layer
- Excel VV mode implementation
- GG mini-layer implementation
- Tooltip issues and solutions

---

## 🤝 Contributing

Found an error in the documentation? Want to add more examples?

1. Edit the relevant `.md` file
2. Keep the Spanish version in sync (or note that translation is needed)
3. Update the changelog in the main [README](../../README.md)

---

## 📜 Documentation License

This documentation is part of the HybridCapslock project. See main [LICENSE for details.

---

**Version**: 2.0.0  
**Last Updated**: 2025-01-XX  
**[🌍 Ver en Español](../es/README.md)** | **[← Back to Main Index](../README.md)**
