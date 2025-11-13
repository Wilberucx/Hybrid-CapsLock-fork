# Numpad & Media Layers

This guide covers the **temporary layers** for numpad and media controls, which are activated by holding specific keys and automatically deactivate when released.

## 🎯 Overview

HybridCapslock provides three temporary layers for quick access to common functions:

| Layer | Activation | Purpose |
|-------|------------|---------|
| **Numpad** | Hold `O` | Number pad on left hand |
| **Media** | Hold `E` | Media controls (play/pause/volume) |
| **Mouse** | Hold `N`, `M`, `B` | Mouse clicks from keyboard |

All three layers are **temporary** - they only work while you hold the activation key.

---

## 🔢 Numpad Layer (Hold O)

### Activation

**Hold the `O` key** - Numpad layer activates  
**Release `O`** - Layer deactivates

### Layout

The numpad is mapped to your **left hand** for ergonomic access:

```
Physical keys:    Numpad function:
7  8  9           →    7  8  9
u  i  o           →    4  5  6
j  k  l           →    1  2  3
m  ,  .           →    0  ,  .

Additional:
p  [  ]           →    +  -  *
;  '              →    /  =
```

### Complete Key Map

| Physical Key | Numpad Function | Description |
|--------------|-----------------|-------------|
| `7` | Numpad 7 | Number 7 |
| `8` | Numpad 8 | Number 8 |
| `9` | Numpad 9 | Number 9 |
| `u` | Numpad 4 | Number 4 |
| `i` | Numpad 5 | Number 5 |
| `o` | Numpad 6 | Number 6 |
| `j` | Numpad 1 | Number 1 |
| `k` | Numpad 2 | Number 2 |
| `l` | Numpad 3 | Number 3 |
| `m` | Numpad 0 | Number 0 |
| `,` | Numpad , | Comma |
| `.` | Numpad . | Decimal point |
| `p` | Numpad + | Plus/Add |
| `[` | Numpad - | Minus/Subtract |
| `]` | Numpad * | Multiply |
| `;` | Numpad / | Divide |
| `'` | Numpad = | Equals |

### Usage Examples

#### Example 1: Quick Calculator

**Scenario:** You need to do a quick calculation

**Steps:**
```
1. Open calculator (or any app)
2. Hold O with right hand
3. Type numbers with left hand: 7,8,9,u,i,o,j,k,l
4. Use operators: p(+), [(-)], ](*)
5. Release O when done
```

#### Example 2: Data Entry

**Scenario:** Entering numbers in a form

**Steps:**
```
1. Navigate to field with Tab
2. Hold O
3. Enter numbers: 123.45
   - j (1), k (2), l (3), . (decimal), u (4), i (5)
4. Release O
5. Tab to next field
```

#### Example 3: Spreadsheet Work

**Scenario:** Entering values in Excel

**Steps:**
```
1. Position cursor in cell
2. Hold O
3. Enter value: 789
   - 7, 8, 9 keys
4. Release O
5. Press Enter to move to next cell
```

### Benefits

✅ **No hand movement** - Left hand stays on home row  
✅ **Faster than number row** - More ergonomic layout  
✅ **Works on laptops** - Full numpad without external keyboard  
✅ **Temporary** - No need to toggle on/off  

---

## 🎵 Media Layer (Hold E)

### Activation

**Hold the `E` key** - Media layer activates  
**Release `E`** - Layer deactivates

### Layout

Media controls are mapped for intuitive access:

```
Physical keys:    Media function:
i  o  p           →    Vol-  Vol+  Mute
j  k  l           →    Prev  Play  Next
u                 →    Stop
```

### Complete Key Map

| Physical Key | Media Function | Description |
|--------------|----------------|-------------|
| `i` | Volume Down | Decrease volume |
| `o` | Volume Up | Increase volume |
| `p` | Mute | Toggle mute |
| `j` | Previous Track | Previous song/video |
| `k` | Play/Pause | Play or pause media |
| `l` | Next Track | Next song/video |
| `u` | Stop | Stop playback |

### Usage Examples

#### Example 1: Quick Volume Adjust

**Scenario:** Music is too loud

**Steps:**
```
1. Hold E
2. Press i repeatedly to lower volume
3. Release E
```

#### Example 2: Skip Song

**Scenario:** Don't like current song

**Steps:**
```
1. Hold E
2. Press l (next track)
3. Release E
```

#### Example 3: Pause During Call

**Scenario:** Phone call comes in

**Steps:**
```
1. Hold E
2. Press k (play/pause)
3. Release E
```

### Benefits

✅ **System-wide** - Works with any media player (Spotify, YouTube, VLC, etc.)  
✅ **Quick access** - No need to switch windows  
✅ **Keyboard-only** - Control media without mouse  
✅ **Temporary** - Natural hold-and-press flow  

---

## 🖱️ Mouse Click Layers

### Overview

Three keys provide mouse clicks from the keyboard:

| Hold Key | Click Type | Use Case |
|----------|------------|----------|
| `N` | Left Click | Primary click |
| `M` | Right Click | Context menu |
| `B` | Middle Click | Open link in new tab |

### Usage

**Hold N** → Next key press acts as left click  
**Hold M** → Next key press acts as right click  
**Hold B** → Next key press acts as middle click  

### Usage Examples

#### Example 1: Context Menu

**Scenario:** Need right-click menu

**Steps:**
```
1. Position cursor (with mouse or trackpad)
2. Hold M
3. Press any key (or click)
4. Context menu appears
5. Release M
```

#### Example 2: Open Link in New Tab

**Scenario:** Want to open link without leaving page

**Steps:**
```
1. Hover over link
2. Hold B
3. Click
4. Link opens in new tab
5. Release B
```

### Benefits

✅ **Accessibility** - Useful if mouse buttons are broken  
✅ **Gaming** - Remap mouse buttons to keyboard  
✅ **Automation** - Combine with macros  

---

## ⚙️ Configuration

### Numpad Configuration

In `config/kanata.kbd`:

```lisp
;; Customize numpad layout
(defalias
  o (tap-hold 200 200 o (layer-while-held numpad))
)

(deflayer numpad
  _    _    _    _    _    _    kp7  kp8  kp9  _    _    _    _    _
  _    _    _    _    _    _    kp4  kp5  kp6  _    _    _    _    _
  _    _    _    _    _    _    kp1  kp2  kp3  _    _    _    _
  _    _    _    _    _    kp0  _    _    _    _    _    _
  _    _    _              _              _    _    _
)
```

### Media Layer Configuration

```lisp
;; Customize media layer
(defalias
  e (tap-hold 200 200 e (layer-while-held media))
)

(deflayer media
  _    _    _    _    _    _    _    voldec volinc mute _    _    _    _
  _    _    _    _    _    _    prev pp    next   _    _    _    _    _
  _    _    _    _    _    _    _    stop   _      _    _    _    _
  _    _    _    _    _    _    _    _      _      _    _    _
  _    _    _              _              _    _    _
)
```

### Change Activation Keys

You can change which keys activate these layers:

```lisp
;; Use P for numpad instead of O
(defalias
  p (tap-hold 200 200 p (layer-while-held numpad))
)
```

---

## 💡 Tips and Tricks

### Tip 1: Combine Layers

You can combine the temporary layers with other features:

```
Hold O (numpad) + Hold A (Ctrl from homerow mods)
→ Ctrl+Number shortcuts
```

### Tip 2: Quick Calculations

For quick math:
```
1. Hold O
2. Type: 7 ] 8 p 9  (7 * 8 + 9)
3. Release O
4. Press Enter
```

### Tip 3: Media Control During Work

While working:
```
Hold E + l → Skip song without interrupting workflow
```

### Tip 4: Learn the Numpad Layout

The numpad layout mirrors standard numpad:
```
7 8 9    Phone keypad
4 5 6  → Easy to learn
1 2 3    Muscle memory builds fast
  0
```

---

## 🔄 Comparison: Temporary vs Persistent

### Temporary Layers (Hold O/E/N/M/B)

✅ **Advantages:**
- No toggle needed
- Natural flow (hold and release)
- Can't forget to disable
- Quick for short tasks

❌ **Disadvantages:**
- Can't use for extended work
- Requires holding key constantly
- One hand occupied

### Persistent Layers (Tap CapsLock, Leader → N)

✅ **Advantages:**
- Both hands free
- Ideal for extended work
- Can combine with other features

❌ **Disadvantages:**
- Need to remember to toggle off
- Can interfere if forgotten
- Requires explicit activation

### When to Use Each

| Task | Use Temporary | Use Persistent |
|------|---------------|----------------|
| Quick calculation | ✅ Hold O | ❌ |
| 5-minute data entry | ❌ | ✅ Excel Layer |
| Skip song | ✅ Hold E + l | ❌ |
| Hour-long accounting | ❌ | ✅ Excel Layer |
| Adjust volume | ✅ Hold E + i/o | ❌ |

---

## ⚠️ Troubleshooting

### Problem: "Numpad doesn't work"

**Solutions:**
1. Check if NumLock is on
2. Verify O key isn't remapped elsewhere
3. Test in calculator app

### Problem: "Media keys don't control my player"

**Solutions:**
1. Ensure media player is focused
2. Check if player supports system media keys
3. Some apps (Spotify web) need browser focus

### Problem: "Mouse clicks don't work"

**Solutions:**
1. This feature may be disabled by default
2. Check `config/settings.ahk` for mouse layer settings
3. Verify cursor is positioned correctly

---

## 🔗 See Also

- **[Excel Layer](excel-layer.md)** - Persistent numpad and Excel functions
- **[Nvim Layer](nvim-layer.md)** - Persistent navigation
- **[Homerow Mods](homerow-mods.md)** - Modifier keys system
- **[Kanata Configuration](../../../config/kanata.kbd)** - Layer configuration

---

**[🌍 Ver en Español](../../es/guia-usuario/capas-numpad-media.md)** | **[← Back to Index](../README.md)**
