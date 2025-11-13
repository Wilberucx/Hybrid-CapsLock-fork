# Nvim Layer (Activated with CapsLock Tap)

> Quick Reference
> - Confirmations: not applicable (immediate actions)
> - Tooltips (C#): [Tooltips] section in config/configuration.ini (configuration.md)

The Nvim Layer transforms your keyboard into a Vim-inspired navigation and editing environment, providing precise control without needing to hold modifier keys.

## 🎯 Difference: vim-nav (Kanata) vs Nvim Layer (AutoHotkey)

This project has **TWO Vim-style navigation systems** with different purposes:

### 🔹 vim-nav (Kanata) - Hold CapsLock
- **Activation**: Hold down `CapsLock` physically
- **Persistence**: ❌ Not persistent (disappears when you release CapsLock)
- **Purpose**: **Quick and temporary** hjkl navigation at hardware level
- **Advantages**: 
  - Perfect timing (<10ms)
  - Works even on login screens
  - No toggle needed (just hold)
- **Limitations**: 
  - Only basic hjkl (no Visual Mode, no dd/yy/:wq commands)
  - Not context-aware

### 🔸 Nvim Layer (AutoHotkey) - Tap CapsLock
- **Activation**: Tap `CapsLock` quickly (press and release)
- **Persistence**: ✅ Persistent (stays active until you tap CapsLock again)
- **Purpose**: **Complete and advanced** Vim navigation with smart logic
- **Advantages**:
  - Visual Mode (select with v)
  - Advanced commands (gg/G, dd/yy, :wq, c/a)
  - Context-aware (whitelist/blacklist apps)
  - Visual tooltips
  - Temporary insert mode
- **Limitations**:
  - Delay ~50-100ms (software-level)
  - Requires toggle ON/OFF

### 🎯 When to Use Each?

| Situation | Use vim-nav (Hold) | Use Nvim Layer (Tap) |
|-----------|-------------------|----------------------|
| Quick 2-3 second navigation | ✅ | ❌ |
| Long document editing | ❌ | ✅ |
| Need Visual Mode | ❌ | ✅ |
| Want :wq/dd/yy commands | ❌ | ✅ |
| Login screen/BIOS | ✅ | ❌ |
| Inside real Nvim/Vim | ✅ | ❌ |

> **💡 Tip**: Combine them based on task. Hold CapsLock for quick adjustments, Tap CapsLock for editing sessions.

---

## 🎯 Nvim Layer Activation (AutoHotkey)

**Method:** Tap `CapsLock` quickly (press and release)

A visual indicator will appear showing the state:
- `◉ NVIM` - Layer activated
- `○ NVIM` - Layer deactivated

> **Note:** The layer automatically deactivates when activating Leader Mode

## 🎮 Visual Mode

The Nvim Layer includes a **Visual Mode** for selecting text while navigating:

| Key | Action | Visual State |
|-------|--------|---------------|
| `v` | **Toggle Visual Mode** | `VISUAL MODE ON/OFF` |

When Visual Mode is active, all navigation keys extend the selection.

## 🧭 Basic Navigation (hjkl)

| Key | Normal Mode | Visual Mode | Description |
|-------|-------------|-------------|-------------|
| `h` | `←` | `Shift+←` | Move/select left |
| `j` | `↓` | `Shift+↓` | Move/select down |
| `k` | `↑` | `Shift+↑` | Move/select up |
| `l` | `→` | `Shift+→` | Move/select right |

## 🚀 Extended Navigation

### Word Movement
| Key | Normal Mode | Visual Mode | Description |
|-------|-------------|-------------|-------------|
| `w` | `Ctrl+→` | `Ctrl+Shift+→` | Next word |
| `b` | `Ctrl+←` | `Ctrl+Shift+←` | Previous word |
| `e` | `Ctrl+→ + ←` | - | End of current word |

### Line Movement
| Key | Normal Mode | Visual Mode | Description |
|-------|-------------|-------------|-------------|
| `0` | `Home` | `Shift+Home` | Line start |
| `$` (Shift+4) | `End` | `Shift+End` | Line end |

### Change History
| Key | Action | Description |
|-------|--------|-------------|
| `u` | `Ctrl+Z` | Undo last change |
| `Ctrl+r` | `Ctrl+Y` | Redo |

### Page Navigation
| Key | Action | Description |
|-------|--------|-------------|
| `Ctrl+d` | `PgDn` | Half page down |
| `Ctrl+u` | `PgUp` | Half page up |
| `Ctrl+f` | `PgDn` | Full page down |
| `Ctrl+b` | `PgUp` | Full page up |

### Document Navigation
| Key | Action | Description |
|-------|--------|-------------|
| `gg` | `Ctrl+Home` | Go to document start |
| `G` (Shift+g) | `Ctrl+End` | Go to document end |

---

## ✂️ Editing Commands

### Delete Operations
| Key | Action | Description |
|-------|--------|-------------|
| `dd` | `Home + Shift+End + Delete` | Delete entire line |
| `d` + movement | Delete + movement | Delete to movement target |
| `x` | `Delete` | Delete character under cursor |
| `X` (Shift+x) | `Backspace` | Delete character before cursor |

### Copy/Paste Operations
| Key | Action | Description |
|-------|--------|-------------|
| `yy` | `Home + Shift+End + Ctrl+C` | Copy (yank) entire line |
| `y` + movement | Copy + movement | Copy to movement target |
| `p` | `Ctrl+V` | Paste after cursor |
| `P` (Shift+p) | `Ctrl+V` | Paste before cursor |

### Advanced Yank
After pressing `y`, a submenu appears:
```
YANK MENU:
y - Yank line
p - Paste  
a - Yank all
```

| Combination | Action | Description |
|-------------|--------|-------------|
| `yy` | Copy line | Copy current line |
| `yp` | Paste | Paste from clipboard |
| `ya` | Copy all | Select and copy all text |

---

## 🔤 Text Objects

### Change/Delete Around/Inside
| Key | Action | Description |
|-------|--------|-------------|
| `ciw` | Change inner word | Delete word and enter insert mode |
| `diw` | Delete inner word | Delete word under cursor |
| `caw` | Change around word | Delete word with spaces |
| `daw` | Delete around word | Delete word with spaces |

### Change Operations
| Key | Action | Description |
|-------|--------|-------------|
| `cc` | `Home + Shift+End + Delete` | Change line (delete and insert) |
| `c` + movement | Change to target | Delete to target and insert |

---

## 📝 Insert Mode

| Key | Action | Description |
|-------|--------|-------------|
| `i` | Temporary deactivation | Enter insert mode (layer off) |
| `I` (Shift+i) | `Home` + insert | Insert at line start |
| `a` | `→` + insert | Append after cursor |
| `A` (Shift+a) | `End` + insert | Append at line end |
| `o` | `End + Enter` | Open new line below |
| `O` (Shift+o) | `Home + Enter + ↑` | Open new line above |

> **Note:** Insert mode temporarily deactivates the Nvim Layer. Tap CapsLock again to reactivate.

---

## 🔍 Search and Replace

| Key | Action | Description |
|-------|--------|-------------|
| `/` | `Ctrl+F` | Open find dialog |
| `n` | `F3` | Next occurrence |
| `N` (Shift+n) | `Shift+F3` | Previous occurrence |

---

## 💾 Save and Quit Commands

### Vim-style Commands
| Command | Action | Description |
|---------|--------|-------------|
| `:w` | `Ctrl+S` | Save (write) |
| `:q` | `Alt+F4` | Quit window |
| `:wq` | `Ctrl+S` + `Alt+F4` | Save and quit |
| `:q!` | `Alt+F4` (force) | Quit without saving |

### How to Execute Commands
1. Press `:` (colon) - Command mode activates
2. Type the command (`w`, `q`, `wq`, `q!`)
3. Press `Enter` - Command executes

Visual feedback:
```
COMMAND MODE:
:w   - Save
:q   - Quit
:wq  - Save & Quit
:q!  - Force Quit
```

---

## 🕐 Timestamps

The Nvim Layer includes quick timestamp insertion:

| Key | Action | Result |
|-----|--------|--------|
| `ts` | Insert timestamp | Opens format menu |

### Available Formats
After pressing `ts`, a submenu appears:
```
TIMESTAMP FORMAT:
1 - 2025-01-12 15:30:45
2 - 2025-01-12
3 - 15:30:45
4 - 12/01/2025
```

Select the number for the desired format.

---

## 🎨 Visual Feedback

### Visual Indicators
- **Nvim Layer:** `NVIM LAYER ON/OFF`
- **Visual Mode:** `VISUAL MODE ON/OFF`
- **Timestamp Format:** `TIMESTAMP FORMAT [format]`
- **Yank Menu:** Shows `y/p/a` options during yank operation

### Persistence
- Layer state persists until manually deactivated
- Timestamp formats are remembered during session
- Visual Mode resets when layer is deactivated

---

## 🔧 Advanced Features

### Mini-Layers
The Nvim Layer implements "mini-layers" for complex commands:

1. **GG Mini-Layer**: After first `g`, waits for second `g`
2. **DD Mini-Layer**: After first `d`, waits for second `d` or movement
3. **YY Mini-Layer**: After first `y`, waits for second `y` or movement
4. **Command Mini-Layer**: After `:`, waits for command (`w`, `q`, etc.)

### Context-Awareness
The layer can be configured to:
- Auto-disable in specific applications (games, terminals)
- Work only in whitelisted applications
- Different behavior per application

Configuration in `config/settings.ahk`:
```ahk
; Disable in these apps
global NvimLayerBlacklist := ["Game.exe", "Terminal.exe"]

; Enable only in these apps (if not empty)
global NvimLayerWhitelist := []
```

---

## ⚠️ Considerations

### 🔄 Integration with Other Modes
- **Leader Mode:** Automatically deactivates Nvim Layer
- **Modifier Mode:** Doesn't interfere with layer (requires holding CapsLock)

### 📱 Compatibility
- **Text applications:** Works perfectly in editors, browsers, etc.
- **Specific applications:** Some programs may intercept certain keys
- **Games:** Recommended to disable layer before playing

### ⚡ Performance
- **Instant response:** Keys respond immediately
- **Minimal memory:** Doesn't consume significant resources
- **Automatic timeout:** Yank mode auto-cancels

---

## 🔧 Customization

### Adding New Functions
```autohotkey
#If (isNvimLayerActive && !GetKeyState("CapsLock","P"))

new_key::
    if (VisualMode)
        Send, +{new_action}  ; With selection
    else
        Send, {new_action}   ; Without selection
return

#If ; End context
```

### Modifying Timestamp Formats
```autohotkey
global TSFormats := ["format1", "format2", "new_format"]
```

---

## 📊 Comparison with Real Vim

| Feature | Real Vim | Nvim Layer |
|---------|----------|------------|
| **hjkl navigation** | ✅ | ✅ |
| **Visual Mode** | ✅ | ✅ |
| **dd/yy commands** | ✅ | ✅ |
| **ciw/diw** | ✅ | ✅ |
| **:wq commands** | ✅ | ✅ |
| **Macros** | ✅ | ❌ |
| **Registers** | ✅ | ❌ (single clipboard) |
| **Complex motions** | ✅ | ⚠️ (basic) |
| **Works everywhere** | ❌ | ✅ |
| **System-wide** | ❌ | ✅ |

---

## 💡 Usage Tips

### Tip 1: Start Simple
Begin with basic hjkl navigation, then progressively add:
1. Week 1: hjkl + 0/$
2. Week 2: w/b + gg/G
3. Week 3: Visual Mode (v)
4. Week 4: dd/yy commands

### Tip 2: Combine with Homerow Mods
```
CapsLock (Nvim) + Hold A (Ctrl) + C → Copy in Vim mode
```

### Tip 3: Use for Specific Tasks
- ✅ Long document editing
- ✅ Code navigation
- ✅ Text selection and manipulation
- ❌ Quick 2-second adjustments (use vim-nav Hold CapsLock instead)

### Tip 4: Disable in Inappropriate Contexts
Add games and terminals to blacklist:
```ahk
global NvimLayerBlacklist := ["game.exe", "cmd.exe", "powershell.exe"]
```

---

## 🔗 See Also

- **[Homerow Mods](homerow-mods.md)**: Base modifier system
- **[Leader Mode](leader-mode.md)**: Advanced contextual menus  
- **[Nvim Colon Mode](nvim-colon-mode.md)**: Deep dive into command mode
- **[General Configuration](../getting-started/configuration.md)**: System settings

---

> **Tip:** The Nvim Layer is especially useful for writers, programmers, and anyone who works intensively with text.

**[🌍 Ver en Español](../../es/guia-usuario/capa-nvim.md)** | **[← Back to Index](../README.md)**
