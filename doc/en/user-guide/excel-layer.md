# Excel/Accounting Layer (leader → n)

> Quick Reference
>
> - Confirmations: not applicable (immediate actions)
> - Tooltips (C#): [Tooltips] section in config/configuration.ini (configuration.md)

The Excel Layer is a specialized persistent layer for spreadsheet and accounting work. It combines a complete numpad (which can also be accessed quickly and temporarily by holding the O key) with optimized navigation and Excel-specific shortcuts for maximum productivity.

## 🎯 Activation

**Combination:** `leader` → `n`

When activating the Excel layer, a visual notification confirms it's active. The layer remains active until manually deactivated (`Shift+n`).

## 🔢 Excel Layer Layout

The Excel layer is organized into three main sections for maximum efficiency:

### 📊 Numpad Section

```
Physical keys:    Numpad function:
1  2  3           →    1  2  3
q  w  e           →    4  5  6
a  s  d           →    7  8  9
   x              →       0
,  .              →    ,  .
8  9  ;  /        →    *  () -  ÷
```

### 🧭 Navigation Section

```
Physical keys:    Navigation function:
   k              →       ↑
h  j  l           →    ←  ↓  →
```

### 📈 Excel Section

This is pending refactoring for better clarity, but essentially:

```
Specialized functions for spreadsheets
i, f, u, r, g, m, y, p, c, v (mini-layers), etc.
```

### 📊 Complete Key Map

#### 🔢 Numpad Section

| Physical Key | Numpad Function | Description |
| ------------ | --------------- | ----------- |
| `1`          | Numpad 1        | Number 1    |
| `2`          | Numpad 2        | Number 2    |
| `3`          | Numpad 3        | Number 3    |
| `q`          | Numpad 4        | Number 4    |
| `w`          | Numpad 5        | Number 5    |
| `e`          | Numpad 6        | Number 6    |
| `a`          | Numpad 7        | Number 7    |
| `s`          | Numpad 8        | Number 8    |
| `d`          | Numpad 9        | Number 9    |
| `x`          | Numpad 0        | Number 0    |
| `,`          | Numpad ,        | Comma       |
| `.`          | Numpad .        | Decimal point |
| `8`          | Numpad *        | Multiply    |
| `9`          | Numpad (        | Left paren  |
| `;`          | Numpad )        | Right paren |
| `/`          | Numpad /        | Divide      |

#### 🧭 Navigation Section

| Physical Key | Function | Description |
| ------------ | -------- | ----------- |
| `h`          | Left     | Move left   |
| `j`          | Down     | Move down   |
| `k`          | Up       | Move up     |
| `l`          | Right    | Move right  |

#### 📈 Excel Functions Section

| Key | Function | Description |
| --- | -------- | ----------- |
| `i` | Insert row | Insert row above |
| `f` | Format | Cell formatting |
| `u` | Undo | Undo last action |
| `r` | Redo | Redo last action |
| `g` | Go to | Go to cell |
| `m` | Merge | Merge cells |
| `y` | Copy | Copy cell |
| `p` | Paste | Paste cell |
| `c` | Copy format | Copy cell format |
| `v` | Mini-layer V | Advanced Excel commands |

---

## 💡 Use Cases

### 📊 Working with Excel/Spreadsheets

**Scenario:** Data entry in a spreadsheet

**Workflow:**
```
1. Activate Excel layer: leader → n
2. Navigate with hjkl
3. Enter numbers with left-hand numpad (1,2,3,q,w,e,a,s,d,x)
4. Quick calculations with operators (8=*, /=÷)
5. Continue working without moving hands
```

**Benefits:**
- ✅ No need to reach for external numpad
- ✅ Navigation and input without moving hands
- ✅ Faster than mouse navigation

### 💰 Accounting and Finance

**Scenario:** Invoice creation, balance reconciliation

**Workflow:**
```
1. Activate Excel layer
2. Enter amounts with numpad
3. Use operators for calculations
4. Navigate between cells with hjkl
5. Copy/paste with y/p
```

**Benefits:**
- ✅ Ergonomic for long accounting sessions
- ✅ All tools at your fingertips
- ✅ Reduces errors from hand movement

### 📈 Data Analysis

**Scenario:** Working with large datasets

**Workflow:**
```
1. Activate Excel layer
2. Fast navigation with hjkl
3. Quick numerical input
4. Formatting with specialized shortcuts
5. Copy formulas with c/v mini-layers
```

### 📱 Laptops without Numpad

**Scenario:** Working on laptop without physical numpad

**Benefits:**
- ✅ Full numpad on main keyboard
- ✅ More ergonomic than reaching for numbers row
- ✅ Faster for intensive numerical input

### 🏢 Office Work

**Scenario:** General office work with frequent numerical input

**Applications:**
- Spreadsheets (Excel, Google Sheets)
- Accounting software (QuickBooks, etc.)
- Data entry forms
- Calculator operations

---

## 🔧 Special Features

### 🔄 Persistent Mode

The Excel layer remains active until you manually deactivate it:
- **Activate:** `leader → n`
- **Deactivate:** `Shift+n` or `leader → n` again

This is ideal for extended work sessions where you need constant access to numpad and Excel functions.

### 📱 Visual Feedback

When the layer activates, you'll see:
```
╔══════════════════════════════════╗
║     📊 EXCEL LAYER ACTIVE        ║
╠══════════════════════════════════╣
║  Numpad: 1-9, qwe, asd, x        ║
║  Navigation: hjkl                ║
║  Functions: i,f,u,r,g,m,y,p,c,v  ║
║                                  ║
║  Shift+N to deactivate           ║
╚══════════════════════════════════╝
```

### 🎯 Context-Aware

The layer can be configured to:
- Auto-activate when opening Excel/spreadsheet apps
- Different behavior per application
- Integration with application-specific shortcuts

Configuration in `config/settings.ahk`:
```ahk
; Auto-activate in these apps
global ExcelLayerAutoActivate := ["EXCEL.EXE", "CALC.EXE"]
```

---

## 🔍 V Mini-Layer

The `v` key activates an advanced mini-layer for complex Excel operations:

**Activation:** Press `v` while Excel layer is active

**Available commands:**
- `v` → Visual select mode
- `v` + navigation → Extend selection
- `v` + `c` → Copy selection
- `v` + `x` → Cut selection

For more details, see technical notes: [Excel V Logic](../../develop/excel_v_logic_mini_layer.md)

---

## ⚙️ Configuration

### Customize Numpad Layout

Edit `src/layer/excel_layer.ahk`:

```ahk
; Change numpad mapping
RegisterKeymap("excel", [
    {key: "1", desc: "Num 1", action: "Send {Numpad1}"},
    {key: "q", desc: "Num 4", action: "Send {Numpad4}"},
    ; Add custom mappings
])
```

### Add Excel Functions

```ahk
; Add new Excel function
RegisterKeymap("excel", [
    {key: "b", desc: "Bold", action: "Send ^b"},  ; Ctrl+B for bold
    {key: "t", desc: "Table", action: "Send ^t"}  ; Ctrl+T for table
])
```

### Change Activation Key

In `src/layer/leader_router.ahk`:

```ahk
; Change from 'n' to 'e' for Excel
RegisterKeymap("leader", [
    {key: "e", desc: "Excel Layer", action: () => ToggleExcelLayer()}
])
```

---

## 💡 Tips and Tricks

### Tip 1: Combine with Homerow Mods

```
Excel layer active + Hold A (Ctrl) → Ctrl+shortcuts
Example: Hold A + C → Copy (Ctrl+C)
```

### Tip 2: Quick Toggle

For temporary numpad access without full Excel layer:
```
Hold O → Temporary numpad
Release O → Back to normal
```

This is faster for quick number entry.

### Tip 3: Learn the Layout

Practice the numpad layout:
```
1 2 3      Phone keypad layout
q w e   →  Intuitive for touch typing
a s d      Easy to memorize
  x        Zero centered
```

### Tip 4: Workflow Optimization

For accounting work:
```
1. Open spreadsheet
2. Activate Excel layer (leader → n)
3. Work entire session with layer active
4. Deactivate when done (Shift+n)
```

No need to toggle constantly.

---

## ⚠️ Troubleshooting

### Problem: "Numpad numbers don't work"

**Solution:** Check if NumLock is on. The layer sends numpad keys, which require NumLock.

### Problem: "Conflicts with Excel shortcuts"

**Solution:** Disable Excel layer when using specific Excel features. Or customize mappings to avoid conflicts.

### Problem: "hjkl moves in wrong direction"

**Solution:** Some applications interpret navigation keys differently. Check application-specific settings.

---

## 🔗 See Also

- **[Numpad Layer](numpad-media-layers.md)** - Standalone numpad layer (Hold O)
- **[Leader Mode](leader-mode.md)** - How to activate layers
- **[Nvim Layer](nvim-layer.md)** - Similar navigation system
- **[General Configuration](../getting-started/configuration.md)** - System settings

---

**[🌍 Ver en Español](../../es/guia-usuario/capa-excel.md)** | **[← Back to Index](../README.md)**
