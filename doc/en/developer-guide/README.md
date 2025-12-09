# Developer Guide - Index

Welcome to the HybridCapsLock Developer Guide. This documentation will help you understand, extend, and contribute to the project.

---

## 📚 Core Documentation

### System Architecture

- **[Plugin Architecture](plugin-architecture.md)** - How the plugin system works
- **[Auto-Loader System](auto-loader-system.md)** - Automatic file loading and integration
- **[Core Plugins Index](core-plugins-index.md)** - Complete list of system plugins
- **[Keymap System](keymap-system.md)** - How keymaps and bindings work

### Layer System

- **[Creating Layers](creating-layers.md)** - Guide to creating custom layers
- **[API: Dynamic Layer](api-dynamic-layer.md)** - Dynamic layer management API

### APIs and Utilities

- **[API: Context Utils](api-context-utils.md)** - Window/application context helpers
- **[API: Hybrid Actions](api-hybrid-actions.md)** - Hybrid key actions API
- **[API: Notification](api-notification.md)** - Notification system API
- **[API: Shell Exec](api-shell-exec.md)** - Shell command execution API
- **[Tooltip API Protocol](Tooltip_Api_Protocol.md)** - C# Tooltip communication protocol

---

## 🛡️ Best Practices

### **[Defensive Programming Patterns](defensive-programming-patterns.md)** ⭐

**Essential reading for all developers.** Learn critical patterns to avoid crashes and race conditions:

- Safe config access with fallback
- Object property validation
- Lazy loading best practices
- Race condition prevention
- Real-world examples and checklists

**Why it matters:** Prevents initialization crashes and ensures robust code.

---

## 🚀 Quick Start for Contributors

1. **Read:** [Plugin Architecture](plugin-architecture.md)
2. **Read:** [Defensive Programming Patterns](defensive-programming-patterns.md) ⚠️ **CRITICAL**
3. **Learn:** [Keymap System](keymap-system.md)
4. **Explore:** [Core Plugins Index](core-plugins-index.md)
5. **Build:** [Creating Layers](creating-layers.md)

---

## 📖 Additional Resources

- **User Guide:** `../user-guide/`
- **Plugin Examples:** `doc/plugins/`
- **Kanata Configs:** `doc/kanata-configs/`
- **AI Sessions:** `.ai-sessions/` (development history and fixes)

---

## 🐛 Troubleshooting

### Common Issues

**Config initialization errors?**  
→ See [Defensive Programming Patterns](defensive-programming-patterns.md) - Pattern 1

**Race conditions on startup?**  
→ See [Defensive Programming Patterns](defensive-programming-patterns.md) - Pattern 6

**Object property crashes?**  
→ See [Defensive Programming Patterns](defensive-programming-patterns.md) - Pattern 2

---

## 📝 Development Workflow

1. **Plan** - Document your changes
2. **Code** - Follow defensive patterns
3. **Test** - Cold start + Reload + Edge cases
4. **Document** - Update relevant docs
5. **Commit** - Clear commit messages

---

## 🤝 Contributing

Before submitting PRs:

- [ ] Read [Defensive Programming Patterns](defensive-programming-patterns.md)
- [ ] Test cold start (no reload)
- [ ] Test with incomplete configs
- [ ] Update documentation
- [ ] Follow code style conventions

---

**Happy Coding!** 🚀
