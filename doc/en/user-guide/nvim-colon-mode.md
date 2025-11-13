# Nvim Colon Mode - Advanced Commands

`Note: This functionality don't be implementd yet because is in development.`

**Nvim Colon Mode** is an advanced feature of the Nvim Layer that emulates Vim's command-line mode, allowing you to execute commands by typing `:command` followed by Enter.

## 🎯 What is Colon Mode?

In Vim, you can execute commands by typing `:` followed by a command. For example:

- `:w` - Save file
- `:q` - Quit
- `:wq` - Save and quit
- `:q!` - Quit without saving

The Nvim Layer implements this functionality system-wide in any application.

---

## ⌨️ Activation

**Prerequisites**: Nvim Layer must be active (tap CapsLock to activate)

**Activation**: Press `:` (colon key)

When colon mode activates, you'll see:

```
╔══════════════════════════════════╗
║       COMMAND MODE               ║
╠══════════════════════════════════╣
║  :w   - Save (Ctrl+S)            ║
║  :q   - Quit (Alt+F4)            ║
║  :wq  - Save & Quit              ║
║  :q!  - Force Quit               ║
║                                  ║
║  ESC  - Cancel                   ║
╚══════════════════════════════════╝
```

---

## 📋 Available Commands

### Basic Commands

| Command | Action      | Keyboard Equivalent | Description               |
| ------- | ----------- | ------------------- | ------------------------- |
| `:w`    | Save        | `Ctrl+S`            | Write (save) current file |
| `:q`    | Quit        | `Alt+F4`            | Quit current window       |
| `:wq`   | Save & Quit | `Ctrl+S` + `Alt+F4` | Save and quit             |
| `:q!`   | Force Quit  | `Alt+F4`            | Quit without saving       |

### How to Use

1. **Activate Nvim Layer**: Tap CapsLock
2. **Enter Command Mode**: Press `:`
3. **Type Command**: Type `w`, `q`, `wq`, or `q!`
4. **Execute**: Press `Enter`
5. **Cancel**: Press `ESC` to exit without executing

---

## 🚀 Usage Examples

### Example 1: Save Document

**Scenario**: You're editing a document and want to save

**Steps**:

```
1. [Nvim Layer active]
2. Press :
3. Press w
4. Press Enter
→ Document saves (Ctrl+S)
```

### Example 2: Close Window

**Scenario**: You want to close the current window

**Steps**:

```
1. [Nvim Layer active]
2. Press :
3. Press q
4. Press Enter
→ Window closes (Alt+F4)
```

### Example 3: Save and Close

**Scenario**: Finish editing and close

**Steps**:

```
1. [Nvim Layer active]
2. Press :
3. Press w
4. Press q
5. Press Enter
→ Saves then closes
```

### Example 4: Force Quit Without Saving

**Scenario**: Made unwanted changes, want to discard

**Steps**:

```
1. [Nvim Layer active]
2. Press :
3. Press q
4. Press !
5. Press Enter
→ Closes without saving
```

---

## 🎨 Visual Feedback

### Command Input Display

As you type, you'll see what command you're building:

```
:         → Command mode started
:w        → Save command
:q        → Quit command
:wq       → Save and quit command
:q!       → Force quit command
```

### Tooltip States

| State               | Display                      |
| ------------------- | ---------------------------- |
| Waiting for command | `COMMAND MODE: (ready)`      |
| Typing :w           | `COMMAND: :w (save)`         |
| Typing :wq          | `COMMAND: :wq (save & quit)` |
| Invalid command     | `COMMAND: Unknown`           |

---

## ⚙️ Technical Details

### Command Recognition

The system recognizes commands by listening to key sequence:

1. `:` activates command mode
2. Subsequent keypresses build command
3. `Enter` executes the command
4. `ESC` cancels

### Timeout

Commands have a timeout of **2 seconds**. If you don't press Enter within 2 seconds, command mode auto-cancels.

### Command Validation

Only valid commands are recognized:

- ✅ `:w`, `:q`, `:wq`, `:q!`
- ❌ Other Vim commands (`:e`, `:bn`, etc.) are not implemented

---

## 🔧 Customization

### Adding New Commands

You can extend colon mode by editing `src/layer/nvim_layer.ahk`:

```autohotkey
; Add new command :e (for example, to open Explorer)
if (command = "e") {
    Run, explorer.exe
    return
}
```

### Modifying Existing Commands

```autohotkey
; Change :w to use your preferred save shortcut
if (command = "w") {
    Send, ^s  ; Default: Ctrl+S
    ; Or customize:
    ; Send, !{F2}  ; Alt+F2
    return
}
```

### Custom Timeout

```autohotkey
; Change timeout from 2000ms to 3000ms
SetTimer, CancelColonMode, -3000
```

---

## ⚠️ Limitations

### Not Implemented

The following Vim commands are **not implemented**:

- `:e` (edit file)
- `:bn` / `:bp` (buffer navigation)
- `:s` (substitute/replace)
- `:set` (settings)
- Line numbers (`:10`, `:$`)
- Ranges (`:%s/old/new/`)

### Why These Limitations?

Nvim Layer is designed for **system-wide navigation**, not as a full Vim replacement. For advanced Vim features, use:

- Real Neovim/Vim
- VS Code with Vim extension
- Other editors with Vim modes

---

## 💡 Tips

### Tip 1: Muscle Memory from Vim

If you're a Vim user, colon mode will feel natural:

```
:w → Automatic muscle memory
:wq → Just like in Vim
```

### Tip 2: Combine with Other Features

```
1. Navigate with hjkl
2. Edit with dd/yy
3. Save with :w
4. Close with :q
```

### Tip 3: Quick Save Workflow

Instead of reaching for `Ctrl+S`:

```
Tap CapsLock → : → w → Enter
```

Feels natural after muscle memory builds up.

---

## 🔗 See Also

- **[Nvim Layer](nvim-layer.md)** - Main Nvim Layer documentation
- **[Visual Mode](nvim-layer.md#visual-mode)** - Text selection
- **[Homerow Mods](homerow-mods.md)** - Modifier keys system

---

**[🌍 Ver en Español](../../es/guia-usuario/modo-colon-nvim.md)** | **[← Back to Index](../README.md)**
