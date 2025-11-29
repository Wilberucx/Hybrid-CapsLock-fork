# Introduction to Hybrid CapsLock + Kanata

> 📍 **Navigation**: [Home](../../../README.md) > User Guide > Introduction

This project combines the best of two worlds: **[Kanata](https://github.com/jtroo/kanata)** (low-level keyboard remapper with perfect timing for tap-hold and homerow mods) with **AutoHotkey** (context-aware intelligence and complex logic). The result is an ergonomic productivity system that transforms the `CapsLock` key and home row keys into a powerful navigation and editing tool, inspired by editors like Vim.

## 🔗 Related Projects

This is a **specialized fork** of the original [Hybrid-CapsLock](https://github.com/Wilberucx/Hybrid-CapsLock) project, created to integrate [Kanata](https://github.com/jtroo/kanata) and leverage its kernel-level remapping capabilities.

- **[Hybrid-CapsLock (original)](https://github.com/Wilberucx/Hybrid-CapsLock) [Deprecated]**: Pure AutoHotkey v2 implementation, ideal for those who prefer an all-in-one solution without external dependencies.
- **[Kanata](https://github.com/jtroo/kanata)**: Cross-platform keyboard remapper (by jtroo), specialized in tap-hold, homerow mods, and precise driver-level timing.

## 🤔 Why This Fork with Kanata?

This fork combines the **strengths of Kanata** (customizable ergonomics, perfect timing) with the **strengths of AutoHotkey** (context-aware, complex logic, visual tooltips):

### ✨ Integration Advantages

- **🎯 Perfect Timing:** Kanata handles tap-hold at the driver level, eliminating false positives and perceptible delay.
- **⚡ Superior Ergonomics:** CapsLock as a central navigation hub with hardware-level detection.
- **🧠 Context-Aware Intelligence:** AutoHotkey detects the active application, window, and adapts behavior dynamically.
- **🎨 Visual Feedback:** Elegant C# tooltips with contextual information and system status.
- **🔧 Extreme Customization:** Modular configuration system with files in `ahk/config` without touching code.
- **🧩 Modular Philosophy:** The base system is lightweight. You decide which features to install by copying plugins from `doc/plugins` to your user folder.
- **📚 Dynamic Layers:** Layer creation with `RegisterLayer` with complex logic and organized submenus.

## 🎯 Your First Use

After installing the system (see [Installation](installation.md)), here's a practical example to understand the power of Hybrid CapsLock:

### Example 1: Basic Navigation

Open any text editor (Notepad, VS Code, browser, etc.) and type several lines of text:

```
Line 1: This is the first line
Line 2: This is the second line
Line 3: This is the third line
Line 4: This is the fourth line
```

Now, **without moving your hands from the home row**:

1. Hold `CapsLock` and press `j` → Cursor moves down one line
2. Hold `CapsLock` and press `k` → Cursor moves up one line
3. Hold `CapsLock` and press `h` → Cursor moves left
4. Hold `CapsLock` and press `l` → Cursor moves right

🎉 **You just navigated without touching the arrow keys or mouse!**

### Example 2: Leader Mode

Now let's try the menu system:

1. Hold `CapsLock` + press `Space`
2. You'll see a visual menu appear on screen
3. Press `h` to see the "Hybrid Management" menu
4. Press `Escape` to exit

This is **Leader Mode**, a contextual menu system that organizes all system functionalities.

### Example 3: Context-Aware

The system adapts to the active application. Try this:

1. Open **Excel**
2. Hold `CapsLock` + press `j/k` → Navigate between cells
3. Open a **browser**
4. Hold `CapsLock` + press `j/k` → Scrolls the page

The same shortcut, **different behavior** depending on context. This is AutoHotkey's context-aware intelligence.

## 🏗️ Visual Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    YOUR KEYBOARD                        │
│  You press: CapsLock + j                                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│               KANATA (Kernel Level)                     │
│  • Detects CapsLock held                                │
│  • Perfect timing for tap-hold                          │
│  • Sends virtual key (F23) to Windows                   │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│            AUTOHOTKEY (Logic Level)                     │
│  • Detects F23 + j                                      │
│  • Checks which application is active                   │
│  • Executes contextual action:                          │
│    - Excel: Navigate cell down                          │
│    - Browser: Scroll down                               │
│    - Editor: Cursor down                                │
│  • Shows visual tooltips                                │
└─────────────────────────────────────────────────────────┘
```

This hybrid architecture gives you:
- **Speed and precision** from Kanata (kernel level)
- **Intelligence and flexibility** from AutoHotkey (application level)

---

## 📖 Next Step

Now that you understand the system's philosophy, learn how the **harmony between Kanata and AutoHotkey** works:

**→ [Key Concepts: The Hybrid Harmony](concepts.md)**

---

<div align="center">

[← Back to Home](../../../README.md) | [Next: Key Concepts →](concepts.md)

</div>
