# Key Concepts: The Hybrid Harmony

> 📍 **Navigation**: [Home](../../../README.md) > User Guide > Key Concepts

HybridCapsLock is not just an AutoHotkey script nor just a Kanata configuration. It's a **symbiosis** designed to get the best of both worlds.

## ☯️ The Harmony

This solution achieves a perfect integration where both tools coexist without stepping on each other:

### 🔄 Interaction Flow

```
┌──────────────────────────────────────────────────────────────┐
│  STEP 1: You press CapsLock + j                              │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  KANATA (Kernel Level) - Perfect Timing                      │
│  ✓ Detects CapsLock held (precise tap-hold)                  │
│  ✓ Activates vim-nav layer                                   │
│  ✓ Converts j → ↓ (down arrow)                               │
│  ✓ Sends F23 (virtual key) to Windows                        │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  AUTOHOTKEY (Logic Level) - Intelligence                     │
│  ✓ Detects F23 (signal from Kanata)                          │
│  ✓ Checks active application (Excel? Chrome? VS Code?)       │
│  ✓ Executes appropriate contextual action                    │
│  ✓ Shows visual feedback (tooltips)                          │
└──────────────────────────────────────────────────────────────┘
```

### 🎯 Division of Responsibilities

1. **Kanata (Kernel Level)**: Handles what requires _perfect timing_ and _absolute reliability_.
    - **Homerow Mods**: Keys that act as modifiers when held and as letters when tapped. Kanata excels here by working at the driver level.
    - **Tap-Hold**: Precise detection of when you tap vs. hold a key.
    - **Base Remapping**: Converts `CapsLock` into "invisible" virtual keys (like F24) for AHK to detect.

2. **AutoHotkey (Logic Level)**: Handles the _intelligence_ and _interface_.
    - **Context-Aware**: Knows which window is active and changes behavior accordingly.
    - **Visual Interface**: Shows menus, tooltips, and notifications.
    - **Complex Logic**: Executes scripts, launches programs, and manages the clipboard.

## 🔧 Integration Flexibility

Although we recommend using Kanata to leverage Homerow Mods (especially useful on laptops), the system is completely flexible. The `kanata.kbd` file can be edited as you wish, as long as the AutoHotkey configuration matches.

### Customizing the "Bridge"

The communication between Kanata and AutoHotkey happens in `ahk/config/keymap.ahk`. You can adapt this section to use any combination you prefer.

If you decide to use Kanata (Recommended), AHK will wait for the virtual keys that Kanata sends:

```autohotkey
; ahk/config/keymap.ahk

#SuspendExempt
#HotIf (LeaderLayerEnabled)
F24:: ActivateLeaderLayer()    ; Kanata sends F24 when you do CapsLock+Space
#HotIf

#HotIf (DYNAMIC_LAYER_ENABLED)
F23:: ActivateDynamicLayer()    ; Kanata sends F23 when you tap CapsLock
#HotIf
#SuspendExempt False
```

### "AutoHotkey Only" Option

If you prefer not to use Kanata, you can modify `keymap.ahk` to use native Windows shortcuts directly. For example, if you want to activate leader mode with `Ctrl + Shift + Space` or native AHK `CapsLock`:

```autohotkey
; Example without Kanata
#SuspendExempt
#HotIf (LeaderLayerEnabled)
^+Space:: ActivateLeaderLayer()  ; Ctrl+Shift+Space activates Leader
; Or using AHK's native syntax for CapsLock
; CapsLock & Space:: ActivateLeaderLayer()
#HotIf
#SuspendExempt False
```

## 🧪 Testing in Practice

To better understand this harmony, try this experiment:

### Experiment 1: See the Timing Difference

1. **Without Kanata** (AHK only): Tap-hold may have delay or false positives
2. **With Kanata**: Timing is instant and precise

### Experiment 2: Dynamic Layer in Action

The **Dynamic Layer** system allows you to assign specific layers to applications:

1. Open **Excel**
2. Press `Leader → h → r` (Register Process)
3. Select the "excel" layer from the list
4. Now, every time you tap `CapsLock` in Excel, it will automatically activate the Excel layer

**How does it work?**

- Kanata detects the `CapsLock` tap and sends `F23`
- AutoHotkey receives `F23` and executes `ActivateDynamicLayer()`
- This function checks which process is active (e.g., EXCEL.EXE)
- Searches in `data/layer_bindings.json` if there's an assigned layer
- If it exists, activates that layer automatically

**This is the Dynamic Layer system adapting to context.**

> 💡 **Note**: Basic navigation with `CapsLock (hold) + hjkl` always sends arrows according to `kanata.kbd` configuration. Application-specific behavior requires creating and assigning custom layers.

## 💡 Professional Recommendation

For an optimal experience:

1. **Use Kanata for the foundation**: Let it handle `CapsLock` and modifiers on the home row (Homerow Mods). Its performance is unmatched for avoiding typing errors.
2. **Use AutoHotkey for the magic**: Let AHK handle everything that happens _after_ activating a layer.

This architecture gives you the robustness of custom keyboard firmware (like QMK/ZMK) but with the scripting power of Windows.

---

## 📖 Next Step

Now that you understand how the harmony works, it's time to **install and configure** the system:

**→ [Installation Guide](installation.md)**

---

<div align="center">

[← Previous: Introduction](introduction.md) | [Back to Home](../../../README.md) | [Next: Installation →](installation.md)

</div>
