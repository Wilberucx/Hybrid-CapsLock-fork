# Homerow Mods: Modifiers on the Home Row

> 📍 **Navigation**: [Home](../../../README.md) > User Guide > Homerow Mods

> **⚠️ IMPORTANT NOTICE**: This guide documents an **OPTIONAL and ADVANCED** configuration. It is not the default HybridCapsLock configuration. This is a template based on the author's personal workflow with timing optimized for specific use cases. **You must adjust the values according to your typing style and needs**.

**Homerow Mods** are an advanced keyboard ergonomics technique that turns home row keys into modifiers when held down, while maintaining their normal function when tapped briefly.

## 🎯 What are Homerow Mods?

Imagine being able to use `Ctrl`, `Alt`, `Win`, and `Shift` without moving your hands from the resting position. That's exactly what homerow mods offer:

```
Normal Home Row:      a  s  d  f      j  k  l  ;
                      ↓  ↓  ↓  ↓      ↓  ↓  ↓  ↓
Homerow Mods (hold): Ctrl Alt Win Shift Shift Win Alt Ctrl
```

### Advantages

✅ **Superior Ergonomics**: Eliminates the need to stretch your pinky to modifier keys  
✅ **Speed**: Keyboard shortcuts are faster when you don't need to move your hands  
✅ **Symmetry**: Modifiers available on both hands for maximum flexibility  
✅ **Reduced Fatigue**: Less strain on hands and wrists

### Disadvantages

⚠️ **Learning Curve**: Requires 1-2 weeks of adaptation  
⚠️ **False Positives**: Initially may accidentally activate modifiers when typing fast  
⚠️ **Fine Tuning**: Requires configuring timing correctly for your typing style

## 🔧 Configuration

HybridCapsLock includes several Kanata configuration templates:

### 1. Basic Configuration (Default - Official)

**File**: `ahk/config/kanata.kbd`  
**Homerow Mods**: ❌ Not included  
**Ideal for**: Beginners, users who prefer traditional modifiers

### 2. Homerow Mods Template (Standard)

**File**: `doc/kanata-configs/kanata-homerow.kbd`  
**Homerow Mods**: ✅ Included with balanced timing  
**Ideal for**: Power users who want homerow mods with conservative configuration

### 3. Advanced Personal Template (Optional)

**File**: `doc/kanata-configs/kanata-advanced-homerow.kbd`  
**Homerow Mods**: ✅ Included with timing optimized for fast workflows  
**Ideal for**: Expert users who want an advanced starting point

> **⚠️ NOTE ABOUT THE ADVANCED TEMPLATE**:  
> This configuration is based on the author's personal workflow with timing values optimized for their specific typing style. **It is NOT a universal configuration**. Use it as a starting point and adjust the `tap-time` and `hold-time` values according to your typing speed and preferences.

### How to Enable Homerow Mods

#### Option A: Standard Template (Recommended)

```powershell
# 1. Navigate to config folder
cd ahk\config

# 2. Backup current configuration
Copy-Item kanata.kbd kanata.kbd.backup

# 3. Copy standard homerow mods configuration
Copy-Item ..\..\doc\kanata-configs\kanata-homerow.kbd kanata.kbd

# 4. Restart Kanata
# Press: Leader → h → k (Restart Kanata Only)
```

#### Option B: Advanced Template (For Experimentation)

```powershell
# 1. Navigate to config folder
cd ahk\config

# 2. Backup current configuration
Copy-Item kanata.kbd kanata.kbd.backup

# 3. Copy advanced template as customizable base
Copy-Item ..\..\doc\kanata-configs\kanata-advanced-homerow.kbd kanata.kbd

# 4. EDIT kanata.kbd and adjust timing values according to your needs
# 5. Restart Kanata: Leader → h → k
```

> **💡 Recommendation**: If you're new to homerow mods, start with **Option A** (standard template). Once you adapt, you can experiment with the advanced template and adjust the timings.

---

## 🔥 Extreme Ergonomic Template: `kanata-advanced-homerow.kbd`

> **🚨 CRITICAL WARNING**: This section documents a configuration that is **RADICALLY DIFFERENT** from a standard keyboard. It is NOT just "homerow mods with adjusted timing". This is a **COMPLETE ergonomic keyboard remapping** designed for maximum efficiency at the cost of compatibility.

### ⚠️ Who is this for?

**ONLY for users who:**
- ✅ Fully master Kanata and its syntax
- ✅ Are willing to relearn the keyboard from scratch
- ✅ Prioritize ergonomics over compatibility
- ✅ Have weeks to adapt
- ✅ Understand every line of the configuration file

**DO NOT use this if:**
- ❌ You're new to Kanata or homerow mods
- ❌ You need immediate productivity
- ❌ You share your computer with others
- ❌ You're not willing to customize extensively

---

### 🎯 Summary of Radical Changes

This configuration implements the following changes that **completely break** with the standard keyboard:

#### 1. **Backspace Relocated** 🔴

**The most critical change**: The traditional Backspace key does NOT work. It's now at `[`.

```lisp
;; kbd snippet (line 73)
;; Layout: qwerty
(deflayer base
  _    _    @w  @e    _    _    _    _    _    _    _  bspc   XX   XX
  ;;                                                     ↑
  ;;                                           Backspace here ([ key)
)
```

**Ergonomic reason**: Eliminates the long pinky movement to the upper right corner.

---

#### 2. **Top Number Row Disabled** 🔴

Numbers 1-9 and 0 in the top row are completely disabled (`XX`).

```lisp
;; kbd snippet (line 72)
(deflayer base
  XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   _    _    _
  ;; ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;; 1    2    3    4    5    6    7    8    9    0  = DISABLED
)
```

**Ergonomic reason**: Force the use of layers to access numbers without moving hands from homerow.

---

#### 3. **Alt Left = Numbers and Symbols Layer** ⚡

Holding `Alt Left` activates the `numrow` layer with numbers and symbols accessible from homerow.

```lisp
;; kbd snippet (lines 31, 108-114)
(defalias
  lal (tap-hold $tap-time-fast $hold-time-fast lalt (layer-while-held numrow))
)

(deflayer numrow
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    1    2    3    4    5    6    7    8    9    0    _    _    _
  ;;   ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;;   Numbers accessible on QWERTY row while holding Alt Left
  _    !    @    #    $    %    ^    &    *    \(   \)   _    _
  ;;   ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;;   Symbols accessible on ASDF row while holding Alt Left
)
```

**Usage**:
```
Hold Alt Left + Q = 1
Hold Alt Left + W = 2
Hold Alt Left + A = !
Hold Alt Left + S = @
```

---

#### 4. **Alt Right = Function Keys Layer** ⚡

Holding `Alt Right` activates the `functionrow` layer with F1-F24.

```lisp
;; kbd snippet (lines 32, 117-123)
(defalias
  ral (tap-hold $tap-time-fast $hold-time-fast ralt (layer-while-held functionrow))
)

(deflayer functionrow
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    f13  f14  f15  f16  f17  f18  f19  f20  f21  f22  f23  f24  _
  _    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  _
  ;;   ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;;   F1-F12 keys on homerow while holding Alt Right
)
```

**Usage**:
```
Hold Alt Right + A = F1
Hold Alt Right + S = F2
Hold Alt Right + D = F3
```

---

#### 5. **G = Numpad on Right Hand** ⚡

Holding `G` activates a complete numpad on the right hand.

```lisp
;; kbd snippet (lines 39, 90-96)
(defalias
  g (tap-hold $tap-time $hold-time g (layer-while-held numpad))
)

(deflayer numpad
  _    _    _    _    _    _    _    nlk  kp/  kp*  kp-  _    _    _
  _    _    _    _    _    _    _    kp7  kp8  kp9  kp+  _    _    _
  _    _    _    _    _    _    _    kp4  kp5  kp6  kp+  _    _
  ;;                                 ↑    ↑    ↑
  ;;                                 Numpad on J/K/L
  _    _    _    _    _    _    _    kp1  kp2  kp3  kprt _    _
  ;;                                 ↑    ↑    ↑
  ;;                                 Numpad on M/,/.
)
```

**Visual numpad layout**:
```
Hold G, then:
    U  I  O     →    7  8  9
    J  K  L     →    4  5  6
    M  ,  .     →    1  2  3
```

---

#### 6. **Mouse Integrated in Homerow** 🖱️

Mouse clicks accessible without moving hands.

```lisp
;; kbd snippet (lines 52-54)
(defalias
  n (tap-hold $tap-time $hold-time n mlft)  ;; Left click
  m (tap-hold $tap-time $hold-time m mrgt)  ;; Right click
  b (tap-hold $tap-time $hold-time b mmid)  ;; Middle click
)
```

**Usage**:
```
Hold N = Left Click
Hold M = Right Click
Hold B = Middle Click (scroll wheel)
```

**Bonus**: In `vim-nav` layer, `D` (hold) = Mouse scroll down.

---

#### 7. **W = Alt Right (International Keyboard Optimization)** ⚡

The `W` key works as `Alt Right` when held, optimized for international keyboard layouts.

```lisp
;; kbd snippet (line 48)
(defalias
  w (tap-hold $tap-time-fast $hold-time-fast w ralt)
)
```

**Ergonomic reason**: In international keyboard layouts (US-International, etc.), `Alt Right` is used to access Spanish special characters:
- `Alt Right + n` = ñ
- `Alt Right + a/e/i/o/u` = á/é/í/ó/ú
- `Alt Right + ?` = ¿
- `Alt Right + !` = ¡

**The problem**: Traditional Alt Right is in the bottom right corner of the keyboard, far from homerow.

**The solution**: Move Alt Right to `W` (left hand, more accessible) to write Spanish without moving hands.

**Mirror system symmetry**:
- **Left hand** homerow: `A`=Ctrl, `S`=Alt Left, `D`=Win, `F`=Shift
- **Right hand** homerow: `J`=Shift, `K`=Win, `L`=Alt Left, `;`=Ctrl
- **Alt Right access**: `W` (left hand, accessible) to maintain coherence

**Practical usage**:
```
Hold W + N = ñ
Hold W + A = á
Hold W + E = é
Hold W + ? = ¿
Hold W + ! = ¡
```

**Advantage**: You can type "mañana", "año", "¿Cómo?" without moving your hands from homerow.

---

#### 8. **Complete Homerow Mods** 🎯

In addition to everything above, the configuration includes standard homerow mods:

```lisp
;; kbd snippet (lines 34-46)
;; Homerow mods - left hand
(defalias
  a (tap-hold $tap-time-fast $hold-time-fast a lctl)  ;; Ctrl
  s (tap-hold $tap-time $hold-time s lalt)            ;; Alt
  d (tap-hold $tap-time $hold-time d lmet)            ;; Win
  f (tap-hold $tap-time-fast $hold-time-fast f lsft)  ;; Shift
)

;; Homerow mods - right hand
(defalias
  j (tap-hold $tap-time-fast $hold-time-fast j lsft)  ;; Shift
  k (tap-hold $tap-time $hold-time k lmet)            ;; Win
  l (tap-hold $tap-time $hold-time l lalt)            ;; Alt
  ; (tap-hold $tap-time-fast $hold-time-fast ; lctl)  ;; Ctrl
)
```

---

### 📊 Visual Comparison: Before vs After

#### Standard Keyboard:
```
[1][2][3][4][5][6][7][8][9][0]  ← Numbers work normally
[Q][W][E][R][T][Y][U][I][O][P][[] ← [ is [, Backspace in corner
[A][S][D][F][G][H][J][K][L][;]    ← Just letters
                                  [Backspace] ← Normally here
```

#### Extreme Ergonomic Configuration:
```
[X][X][X][X][X][X][X][X][X][X]  ← Numbers DISABLED
[Q][W][E][R][T][Y][U][I][O][P][⌫] ← [ is BACKSPACE now
[A][S][D][F][G][H][J][K][L][;]    ← Homerow mods + layers
 ↓  ↓  ↓  ↓  ↓        ↓  ↓  ↓  ↓
Ctrl Alt Win Sft     Sft Win Alt Ctrl

Additional layers:
- Alt Left (hold) → Numbers on QWERTY, symbols on ASDF
- Alt Right (hold) → F1-F24 on ASDF
- G (hold) → Numpad on right hand
- N/M/B (hold) → Mouse clicks
```

---

### 🎓 Specific Adaptation Guide

#### Week 1: Backspace and Numbers
1. **Days 1-3**: Practice only Backspace on `[`. Use an empty text editor.
2. **Days 4-7**: Learn numbers with Alt Left. Practice: `Alt Left + Q/W/E/R...`

#### Week 2-3: Homerow Mods
3. **Days 8-14**: Basic homerow mods (Ctrl+C, Ctrl+V with `a`)
4. **Days 15-21**: Complex shortcuts (Ctrl+Shift+T, etc.)

#### Week 4: Advanced Layers
5. **Days 22-28**: Numpad with G, mouse clicks, function keys

#### Month 2+: Optimization
6. Adjust `tap-time` and `hold-time` values according to your needs
7. Customize additional layers

---

### ⚙️ Optimized Timing Values

This configuration uses ultra-fast timing:

```lisp
;; kbd snippet (lines 4-9)
(defvar
  tap-time 200          ;; Standard: 200ms
  hold-time 201         ;; Standard: 201ms
  tap-time-fast 175     ;; Fast: 175ms (25ms less)
  hold-time-fast 176    ;; Fast: 176ms
)
```

**Comparison**:
- **Standard**: 200ms - More tolerant, fewer false positives
- **Fast**: 175ms - For ultra-fast typing, requires precision

**Customization**:
```lisp
;; For slower typing users
(defvar
  tap-time-fast 225
  hold-time-fast 226
)

;; For extremely fast typing users
(defvar
  tap-time-fast 150
  hold-time-fast 151
)
```

---

### 🗺️ Complete Layer Map

The configuration includes the following layers:

1. **base**: Homerow mods + main reassignments
2. **vim-nav**: Vim-style navigation (activated with CapsLock)
3. **numpad**: Numeric keypad (activated with G)
4. **numrow**: Numbers and symbols (activated with Alt Left)
5. **functionrow**: F1-F24 keys (activated with Alt Right)
6. **media**: Media controls

**Layer navigation**:
```
base
 ├─ [CapsLock hold] → vim-nav
 ├─ [G hold] → numpad
 ├─ [Alt Left hold] → numrow
 └─ [Alt Right hold] → functionrow
```

---

### 🔧 How to Customize

#### Step 1: Copy as base
```powershell
Copy-Item doc\kanata-configs\kanata-advanced-homerow.kbd ahk\config\kanata-custom.kbd
```

#### Step 2: Modify as needed

**Example: Restore traditional Backspace**
```lisp
;; Change this line (73):
_    _    @w  @e    _    _    _    _    _    _    _  bspc   XX   XX
;;                                                     ↑
;; To:
_    _    @w  @e    _    _    _    _    _    _    _  _      XX   XX
;;                                                     ↑
;;                                              Disable backspace on [
```

**Example: Enable traditional numrow**
```lisp
;; Change this line (72):
XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   _    _    _
;; To:
_    _    _    _    _    _    _    _    _    _    _    _    _    _
```

#### Step 3: Test extensively
- Use a disposable text document
- Practice each layer separately
- Adjust timing if there are false positives

---

### ❓ Frequently Asked Questions

**Q: Can I use only some parts of this configuration?**  
A: Absolutely! You can copy only the elements that interest you. It's highly modular.

**Q: How do I go back to normal keyboard if I regret it?**  
A: Restore your backup: `Copy-Item kanata.kbd.backup kanata.kbd` and restart Kanata.

**Q: Why backspace on `[`?**  
A: It's the closest key to the rest position that can assume the backspace role without conflicts. Eliminates the long pinky movement.

**Q: Can I use this at work?**  
A: Only if you're willing to be less productive for 2-4 weeks while adapting. Not recommended for close deadlines.

**Q: Does this work in all programs?**  
A: Yes, Kanata operates at the system level. But some programs with hardcoded shortcuts may behave differently.

---

### 📚 Additional Resources

- **Complete file**: `doc/kanata-configs/kanata-advanced-homerow.kbd`
- **Kanata Documentation**: https://github.com/jtroo/kanata
- **Ergonomic Keyboards Community**: r/ErgoMechKeyboards

---

## 🎮 Usage

### Key Mapping

| Key | Tap (brief touch) | Hold (maintain) |
|-----|-------------------|-----------------|
| `a` | Letter 'a' | **Ctrl** (left) |
| `s` | Letter 's' | **Alt** (left) |
| `d` | Letter 'd' | **Win** (left) |
| `f` | Letter 'f' | **Shift** (left) |
| `j` | Letter 'j' | **Shift** (right) |
| `k` | Letter 'k' | **Win** (right) |
| `l` | Letter 'l' | **Alt** (right) |
| `;` | Semicolon | **Ctrl** (right) |

### Practical Examples

#### Copy and Paste

```
❌ Traditional Way:
   Ctrl (pinky) + C → Stretch hand
   Ctrl (pinky) + V → Stretch hand

✅ With Homerow Mods:
   Hold 'a' + C → Without moving hands
   Hold 'a' + V → Without moving hands
```

#### Navigation Shortcuts

```
❌ Traditional Way:
   Ctrl + Left Arrow → Stretch both hands

✅ With Homerow Mods:
   Hold 'a' + Left Arrow → One hand on home row, other on arrows
   Or better: CapsLock + h (vim navigation) with homerow mods
```

#### Application Shortcuts

```
Save:      Hold 'a' + s  (Ctrl+S)
Find:      Hold 'a' + f  (Ctrl+F)
Redo:      Hold 'a' + y  (Ctrl+Y)
New Tab:   Hold 'a' + t  (Ctrl+T)
```

## 🏋️ Adaptation Exercises

### Week 1: Basic Adaptation

**Day 1-3**: Use only left hand
- Practice `Ctrl+C`, `Ctrl+V`, `Ctrl+S`
- Hold `a` + other keys

**Day 4-7**: Incorporate right hand
- Practice with `;` (right Ctrl)
- Alternate between left and right hands

### Week 2: Advanced Usage

**Day 8-10**: Multiple modifiers
- `Ctrl+Shift` = Hold `a` + `f` (or `j`)
- `Ctrl+Alt` = Hold `a` + `s`

**Day 11-14**: Natural usage
- Try using homerow mods for all shortcuts
- Allow false positives to naturally decrease

## ⚙️ Timing Adjustment

If you experience false positives (modifiers activating while typing), adjust the `tap-hold` values in the configuration file:

### File: `ahk/config/kanata.kbd`

```lisp
;; Default configuration
(defalias
  a (tap-hold 200 200 a lctl)  ; 200ms timing
)

;; To reduce false positives (fast typing)
(defalias
  a (tap-hold 250 250 a lctl)  ; Increase to 250ms
)

;; For expert users (very fast typing)
(defalias
  a (tap-hold 150 150 a lctl)  ; Reduce to 150ms
)
```

**Parameters**:
- **First number**: Minimum delay to consider a "tap"
- **Second number**: Maximum timeout before activating "hold"

## 🐛 Troubleshooting

### Problem: Modifiers activate while typing

**Solution**: Increase `tap-hold` value in `.kbd` file

```lisp
; Change from 200 to 250 or 300
(defalias
  a (tap-hold 250 250 a lctl)
)
```

### Problem: Modifiers take too long to activate

**Solution**: Reduce `tap-hold` value

```lisp
; Change from 200 to 150
(defalias
  a (tap-hold 150 150 a lctl)
)
```

### Problem: Can't type "as", "sad", etc.

**Solution**: This is normal at first. Kanata is configured to detect rolls (keys pressed in fast sequence). With practice, your brain will learn the correct timing.

**Alternative**: Temporarily increase `tap-hold` value while adapting.

### Problem: Prefer traditional modifiers in certain situations

**Solution**: Traditional modifiers still work. Use whatever is most comfortable in each situation:
- Homerow mods for frequent shortcuts
- Traditional modifiers for complex or infrequent combinations

## 💡 Pro Tips

1. **Don't force the change**: Use homerow mods gradually
2. **Practice with frequent actions**: Start with Ctrl+C, Ctrl+V, Ctrl+S
3. **Trust the system**: False positives disappear over time
4. **Adjust timing to your style**: There's no "perfect" universal configuration
5. **Combine with CapsLock navigation**: The real power comes from combining homerow mods with HybridCapsLock's vim navigation

## 🎓 Additional Resources

### Kanata Documentation
- [Tap-Hold Configuration](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#tap-hold)
- [Community Examples](https://github.com/jtroo/kanata/tree/main/cfg_samples)

### Communities
- [r/ErgoMechKeyboards](https://www.reddit.com/r/ErgoMechKeyboards/)
- [Kanata Discord](https://discord.gg/kanata)

## 📖 Next Step

Once you've mastered homerow mods, learn to combine them with HybridCapsLock layers:

**→ [Layer System](layers.md)**

---

<div align="center">

[← Previous: Leader Mode](leader-mode.md) | [Back to Home](../../../README.md) | [Next: Concepts →](concepts.md)

</div>
