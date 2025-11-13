# Developer Guide

Welcome to the HybridCapslock Developer Guide! This section contains detailed information for developers who want to extend, customize, or contribute to HybridCapslock.

---

## 📚 Table of Contents

### Getting Started with Development
- **[Auto-Loader System](../developer-guide/auto-loader-system.md)** - How automatic module loading works
- **[Creating New Layers](creating-layers.md)** - Build your own custom layers
- **[Keymap System](keymap-system.md)** - Unified keymap registration system

### Core Concepts
- **[Hotkeys vs Keymaps](hotkeys-vs-keymaps.md)** - Understanding the difference
- **[Layer Functions Reference](layer-functions-reference.md)** - Complete API reference
- **[Layer Name Guide](layer-name-guide.md)** - Naming conventions and best practices

### Testing & Quality
- **[Testing Guide](testing.md)** - Manual testing procedures

---

## 🚀 Quick Start for Developers

### 1. Create Your First Layer

```ahk
; src/layer/my_custom_layer.ahk

global MY_CUSTOM_LAYER_ACTIVE := false

InitMyCustomLayer() {
    RegisterKeymaps("my_custom", [
        {key: "h", desc: "Action Left", action: "Send {Left}"},
        {key: "l", desc: "Action Right", action: "Send {Right}"}
    ])
}

ActivateMyCustomLayer() {
    MY_CUSTOM_LAYER_ACTIVE := true
    ActivateLayer("my_custom")
    ShowLayerTooltip("MY CUSTOM LAYER")
}

DeactivateMyCustomLayer() {
    MY_CUSTOM_LAYER_ACTIVE := false
    DeactivateLayer("my_custom")
    HideLayerTooltip()
}

InitMyCustomLayer()
```

### 2. Reload and Test

- Press `Ctrl+Alt+R` to reload
- The auto-loader will detect your new layer automatically
- No need to manually edit includes!

### 3. Assign Activation Key

Edit `config/keymap.ahk`:

```ahk
F13::ToggleMyCustomLayer()
```

---

## 🏗️ Architecture Overview

### Project Structure

```
HybridCapslock/
├── src/
│   ├── core/           # Core system components
│   │   ├── auto_loader.ahk
│   │   ├── keymap_registry.ahk
│   │   └── config.ahk
│   ├── actions/        # Action modules (auto-loaded)
│   │   ├── git_actions.ahk
│   │   ├── power_actions.ahk
│   │   └── ...
│   ├── layer/          # Layer implementations (auto-loaded)
│   │   ├── nvim_layer.ahk
│   │   ├── excel_layer.ahk
│   │   └── ...
│   └── ui/             # User interface (tooltips)
├── config/             # User configuration
│   ├── keymap.ahk
│   ├── settings.ahk
│   └── kanata.kbd
└── data/               # Runtime data
    ├── layer_state.ini
    └── layer_registry.ini
```

### Key Components

1. **Auto-Loader** - Automatically loads `.ahk` files from `src/layer/` and `src/actions/`
2. **Keymap Registry** - Centralized registration and management of keybindings
3. **Layer System** - Modal layers that can be activated/deactivated
4. **Tooltip System** - Visual feedback using C# integration

---

## 📖 Essential Guides

### For New Developers
1. Start with: [Auto-Loader System](../developer-guide/auto-loader-system.md)
2. Then read: [Creating New Layers](creating-layers.md)
3. Understand: [Hotkeys vs Keymaps](hotkeys-vs-keymaps.md)

### For Advanced Development
1. Study: [Keymap System](keymap-system.md)
2. Reference: [Layer Functions Reference](layer-functions-reference.md)
3. Follow: [Layer Name Guide](layer-name-guide.md)

---

## 🔧 Development Workflow

### 1. Setup Development Environment

```bash
# Enable debug mode
# Edit config/settings.ahk:
global DEBUG_MODE := true
```

### 2. Download DebugView

- [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview) for logging
- Run as Administrator to see logs

### 3. Make Changes

- Edit or create files in `src/layer/` or `src/actions/`
- Use `OutputDebug()` for logging

### 4. Test

- Reload: `Ctrl+Alt+R`
- Check DebugView for logs
- Test functionality manually

### 5. Disable Module (if needed)

Move to `no_include/` folder to temporarily disable:

```bash
mv src/layer/experimental.ahk src/layer/no_include/
```

---

## 💡 Best Practices

### Code Style

1. **Use descriptive names**: `nvim_layer.ahk` not `layer1.ahk`
2. **Comment your code**: Explain the "why", not just the "what"
3. **Use OutputDebug**: Help future developers (and yourself) debug
4. **Follow conventions**: See [Layer Name Guide](layer-name-guide.md)

### Testing

1. **Test in isolation**: Use `no_include/` to disable other modules
2. **Test edge cases**: What happens when layer is already active?
3. **Test interactions**: Does it conflict with other layers?
4. **Manual tests**: Follow [Testing Guide](testing.md)

### Performance

1. **Avoid heavy operations in hotkeys**: Use timers/threads if needed
2. **Cache values**: Don't recompute on every keypress
3. **Profile with DebugView**: Check execution time

---

## 🤝 Contributing

### Before Contributing

1. Read all guides in this section
2. Check existing layers for examples
3. Test thoroughly
4. Document your changes

### Code Review Checklist

- [ ] Code follows naming conventions
- [ ] All functions have `OutputDebug` for important operations
- [ ] Layer has `Init*()`, `Activate*()`, `Deactivate*()` functions
- [ ] Keymaps are registered declaratively
- [ ] No conflicts with existing layers
- [ ] Tested manually
- [ ] Documentation updated

---

## 📚 Additional Resources

- **[Templates](../../templates/)** - Boilerplate code for new layers
- **[Development Notes](develop/)** - Technical implementation notes
- **[Reference Documentation](../reference/)** - System architecture details

---

**[🌍 Ver en Español](../../es/guia-desarrollador/README.md)** | **[← Back to Documentation Index](../README.md)**
