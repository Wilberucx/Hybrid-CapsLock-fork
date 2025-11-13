# 🏠 Homerow Mods - Complete Guide

**Homerow Mods** are one of the most powerful features of the Kanata integration. They transform the home row keys (the center row where your fingers rest) into modifiers when held down, eliminating the need to stretch your hands toward Ctrl, Alt, Win, or Shift.

## 🎯 What are Homerow Mods?

**Homerow Mods** = Modifiers on the home row

Each key has **two functions**:

- **Tap (quick press)**: Sends the normal letter (a, s, d, f, j, k, l, ;)
- **Hold (press and hold)**: Acts as a modifier (Ctrl, Alt, Win, Shift)

This is handled by **Kanata at the driver level** with perfect timing (<10ms), without false positives.

## ⌨️ Homerow Mods Layout

### Left Hand (Primary Modifiers)

```
┌─────┬─────┬─────┬─────┬─────┐
│  A  │  S  │  D  │  F  │  G  │
│Ctrl │ Alt │ Win │Shift│     │
└─────┴─────┴─────┴─────┴─────┘
```

| Key | Tap | Hold      | Common Use                                     |
| ----- | --- | --------- | --------------------------------------------- |
| **A** | a   | **Ctrl**  | Copy, Paste, Save, Browser shortcuts   |
| **S** | s   | **Alt**   | Alt+Tab, Alt+F4, Application menus          |
| **D** | d   | **Win**   | Win+D (desktop), Win+number (taskbar apps) |
| **F** | f   | **Shift** | Uppercase, Select text with arrows     |

### Right Hand (Symmetric Modifiers)

```
┌─────┬─────┬─────┬─────┬─────┐
│  H  │  J  │  K  │  L  │  ;  │
│     │Shift│ Win │ Alt │Ctrl │
└─────┴─────┴─────┴─────┴─────┘
```

| Key | Tap | Hold      | Common Use                             |
| ----- | --- | --------- | ------------------------------------- |
| **J** | j   | **Shift** | Uppercase, Shift+Enter (new line) |
| **K** | k   | **Win**   | Windows shortcuts with right hand    |
| **L** | l   | **Alt**   | Alt+Tab, Alt+F4 with right hand      |
| **;** | ;   | **Ctrl**  | Ctrl+C, Ctrl+V with right hand       |

> **Design Note**: The right hand has adjusted timing (tap-hold-press 350 150) to prioritize tapping, avoiding conflicts with Vim navigation (hjkl).

---

## 🚀 Basic Usage

### Example 1: Copy and Paste (One-Handed)

**Traditional**:
```
1. Extend left hand to Ctrl
2. Press C
3. Release Ctrl
4. Move to destination
5. Extend left hand to Ctrl again
6. Press V
```

**With Homerow Mods**:
```
1. Hold A (becomes Ctrl) + C
2. Move to destination
3. Hold A + V
```

✅ **No hand stretching**, fingers stay on home row.

### Example 2: Switch Windows (Alt+Tab)

**Traditional**:
```
Thumb to Alt + Index to Tab
```

**With Homerow Mods**:
```
Hold S (becomes Alt) + Tab
```

✅ **More comfortable**, no thumb movement needed.

### Example 3: Save File (Ctrl+S)

**Paradox solved**: How to press Ctrl+S if S is Ctrl?

**Answer**: Use the **other hand**!

```
Hold A (left hand, becomes Ctrl) + Tap S (right hand, types 's')
```

Or vice versa:
```
Hold ; (right hand, becomes Ctrl) + Tap S (left hand, types 's')
```

✅ **No conflict**, hands work complementarily.

---

## ⚙️ Configuration in Kanata

### Current Configuration

The homerow mods configuration is in `config/kanata.kbd`:

```lisp
;; Homerow mods - Left hand (balanced timing)
(defalias
  a (tap-hold-press 200 200 a lctl)  ;; A = Ctrl when held
  s (tap-hold-press 200 200 s lalt)  ;; S = Alt when held
  d (tap-hold-press 200 200 d lmet)  ;; D = Win when held
  f (tap-hold-press 200 200 f lsft)  ;; F = Shift when held
)

;; Homerow mods - Right hand (prioritize tap for Vim)
(defalias
  j (tap-hold-press 350 150 j rsft)  ;; J = Shift when held (longer tap time)
  k (tap-hold-press 350 150 k rmet)  ;; K = Win when held
  l (tap-hold-press 350 150 l ralt)  ;; L = Alt when held
  scln (tap-hold-press 350 150 ; rctl)  ;; ; = Ctrl when held
)
```

### Understanding the Numbers

`tap-hold-press 200 200 a lctl`

- **First 200**: Time in ms to distinguish between tap and hold
- **Second 200**: Time before considering it a hold
- **a**: Letter to send on tap
- **lctl**: Modifier to activate on hold (Left Control)

### Timing Adjustments

**Left hand (A/S/D/F)**: `tap-hold 200 200` (balanced)
- Good balance between typing and modifiers
- Use if you don't use Vim navigation

**Right hand (J/K/L/;)**: `tap-hold-press 350 150` (prioritize tap)
- Longer tap time = fewer accidental triggers when using HJKL navigation
- Recommended if you use Nvim Layer

---

## 🎯 Practical Examples

### Daily Workflow

#### 1. Text Editing
```
Hold A + A        → Select all (Ctrl+A)
Hold A + C        → Copy (Ctrl+C)
Hold A + V        → Paste (Ctrl+V)
Hold A + Z        → Undo (Ctrl+Z)
Hold A + F        → Find (Ctrl+F)
```

#### 2. Window Navigation
```
Hold S + Tab      → Switch windows (Alt+Tab)
Hold S + F4       → Close window (Alt+F4)
Hold D + D        → Show desktop (Win+D)
Hold D + E        → Open Explorer (Win+E)
```

#### 3. Browser Navigation
```
Hold A + T        → New tab (Ctrl+T)
Hold A + W        → Close tab (Ctrl+W)
Hold A + Tab      → Switch tabs (Ctrl+Tab)
Hold A + L        → Focus address bar (Ctrl+L)
```

#### 4. Terminal/IDE
```
Hold A + C        → Copy (or interrupt process)
Hold A + V        → Paste
Hold A + Shift+T  → Reopen closed tab
Hold A + K        → Clear terminal (in some terminals)
```

---

## 🧠 Learning Curve

### Week 1: Adaptation
- **Feeling**: Strange, occasional conflicts
- **Tip**: Focus on one hand (left A/S/D/F first)
- **Practice**: Use Ctrl+C, Ctrl+V constantly

### Week 2: Muscle Memory
- **Feeling**: More natural, less thinking
- **Tip**: Add right hand (; for Ctrl)
- **Practice**: Alt+Tab (Hold S + Tab)

### Week 3-4: Mastery
- **Feeling**: Automatic, unconscious
- **Tip**: Advanced combinations (Ctrl+Shift)
- **Practice**: Hold A + Hold F + Arrow (Ctrl+Shift+Arrow)

### After 1 Month
✅ **You won't be able to go back** to stretching for Ctrl/Alt  
✅ **Typing speed unaffected** (or improved)  
✅ **Less hand fatigue**

---

## ⚠️ Common Problems and Solutions

### Problem 1: "When I type fast, it triggers modifiers"

**Cause**: Timing too sensitive (numbers too low).

**Solution**: Increase timing in `kanata.kbd`:
```lisp
;; Change from 200 200 to 250 250
(defalias
  a (tap-hold-press 250 250 a lctl)
)
```

### Problem 2: "I have to hold too long to activate the modifier"

**Cause**: Timing too long.

**Solution**: Reduce timing:
```lisp
;; Change from 250 250 to 150 150
(defalias
  a (tap-hold-press 150 150 a lctl)
)
```

### Problem 3: "Conflicts with Vim navigation (HJKL)"

**Cause**: Right hand timing too fast.

**Solution**: Use asymmetric configuration (already default):
```lisp
;; Left hand: 200 200 (balanced)
;; Right hand: 350 150 (prioritize tap)
```

### Problem 4: "I can't type 'as', 'ad', 'sd' quickly"

**Cause**: Holding keys too long unintentionally.

**Solution**:
1. Practice typing faster
2. Adjust timing if necessary
3. Use the "eager" mode in Kanata (advanced)

### Problem 5: "Ctrl+S doesn't work"

**Cause**: Using the same hand for both keys.

**Solution**: Use **opposite hand**:
```
✅ Hold A (left) + S (right)  → Works!
❌ Hold S (left) + S (left)   → Doesn't work
```

---

## 🔬 Technical Details

### How It Works

1. **Kanata intercepts** keystrokes at driver level (before Windows)
2. **Measures timing** from key press to release
3. **Decides**:
   - If < 200ms → **Tap** → Sends normal letter
   - If > 200ms → **Hold** → Activates modifier
4. **Sends** the appropriate command to Windows

### Advantages over Software Solutions (AutoHotkey)

| Aspect | Kanata (Driver) | AutoHotkey (Software) |
|--------|-----------------|----------------------|
| **Latency** | <10ms | 20-50ms |
| **Reliability** | 99.9% | 95% (depends on load) |
| **CPU** | Minimal | Low but measurable |
| **Conflicts** | None | Can conflict with games/apps |
| **Timing** | Perfect | Variable |

---

## 💡 Advanced Tips

### Tip 1: One-Handed Combinations

When you need Ctrl+Shift+Something:
```
Hold A (Ctrl) + Hold F (Shift) + Arrow
```

All with the left hand!

### Tip 2: Rapid Macros

For repetitive tasks:
```
Hold A + C → Copy
Hold A + Tab → Switch window
Hold A + V → Paste
```

Everything without moving hands from home row.

### Tip 3: Synergy with Nvim Layer

Combine with [Nvim Layer](nvim-layer.md):
```
CapsLock (Nvim Layer) + Hold A + C → Copy in Vim mode
```

### Tip 4: Custom Timing Per Key

You can have different timing for each key:
```lisp
(defalias
  a (tap-hold-press 150 150 a lctl)  ;; Ctrl fast
  s (tap-hold-press 250 250 s lalt)  ;; Alt slower
)
```

---

## 📊 Recommended Configurations

### For Programmers
```lisp
;; Left hand: balanced
a (tap-hold-press 200 200 a lctl)
s (tap-hold-press 200 200 s lalt)
d (tap-hold-press 200 200 d lmet)
f (tap-hold-press 200 200 f lsft)

;; Right hand: prioritize tap (for HJKL)
j (tap-hold-press 350 150 j rsft)
k (tap-hold-press 350 150 k rmet)
l (tap-hold-press 350 150 l ralt)
scln (tap-hold-press 350 150 ; rctl)
```

### For Writers
```lisp
;; All balanced (no HJKL conflict)
a (tap-hold-press 200 200 a lctl)
s (tap-hold-press 200 200 s lalt)
d (tap-hold-press 200 200 d lmet)
f (tap-hold-press 200 200 f lsft)
j (tap-hold-press 200 200 j rsft)
k (tap-hold-press 200 200 k rmet)
l (tap-hold-press 200 200 l ralt)
scln (tap-hold-press 200 200 ; rctl)
```

### For Fast Typists
```lisp
;; Shorter timing (more aggressive)
a (tap-hold-press 150 150 a lctl)
s (tap-hold-press 150 150 s lalt)
d (tap-hold-press 150 150 d lmet)
f (tap-hold-press 150 150 f lsft)
```

---

## 🎓 Learning Exercises

### Exercise 1: Basic Copy/Paste (5 min)
1. Open Notepad
2. Type: "Hello World"
3. Hold A + A (Select all)
4. Hold A + C (Copy)
5. Hold A + V (Paste)
6. Repeat 20 times

### Exercise 2: Window Switching (5 min)
1. Open 3 windows
2. Hold S + F4 → Close windows quickly
3. Hold D + D → Show desktop
4. Hold A + arrows → Navigate through documents
5. Hold S + Tab → Switch apps with Alt+Tab

---

## 🔗 See Also

- **[Nvim Layer](nvim-layer.md)**: Persistent Vim-style navigation
- **[Leader Mode](leader-mode.md)**: Advanced contextual menus
- **[Kanata Configuration](../../../config/kanata.kbd)**: Kanata configuration file
- **[General Configuration](../getting-started/configuration.md)**: Global system options

---

**[🌍 Ver en Español](../../es/guia-usuario/homerow-mods.md)** | **[← Back to Index](../README.md)**
