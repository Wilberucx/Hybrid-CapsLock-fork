# 🎯 Leader Mode - Advanced Guide

**Leader Mode** is an advanced feature that allows you to access contextual menus and commands through a **leader key** (similar to Vim's leader or Emacs' prefix keys). It's a powerful way to organize dozens of shortcuts without memorizing complex key combinations.

## 🎯 What is Leader Mode?

**Leader Mode** = Hierarchical menu activated by a leader key

Instead of remembering `Ctrl+Alt+Shift+X`, you do:
```
Leader → P → C  (Launch Chrome)
Leader → W → M  (Maximize window)
Leader → S → T  (Insert timestamp)
```

✅ **Easier to remember** (mnemonic menus)  
✅ **No finger acrobatics** (no Ctrl+Alt+Shift combinations)  
✅ **Infinite extensibility** (add more menus as needed)

---

## ⌨️ Activation

### Default Activation Key

**Hold CapsLock + Space** → Activates Leader Mode

Or configure a dedicated key in `config/kanata.kbd`:
```lisp
(defalias
  leader (tap-hold 200 200 space (layer-while-held leader))
)
```

### Alternative Activations

You can configure:
- **F24** as dedicated leader
- **Double-tap Space**
- **Hold Space for 500ms**
- **Any custom combination**

---

## 📂 Menu Structure

Leader Mode organizes commands in **hierarchical submenus**:

```
Leader
├── P (Programs)
│   ├── C → Chrome
│   ├── V → VS Code
│   ├── T → Terminal
│   └── N → Notepad
├── W (Windows)
│   ├── M → Maximize
│   ├── R → Restore
│   ├── L → Move left
│   └── R → Move right
├── S (System)
│   ├── S → Screenshot
│   ├── R → Reload HybridCapslock
│   ├── K → Restart Kanata
│   └── P → Power menu
└── T (Text/Timestamps)
    ├── D → Date
    ├── T → Time
    ├── F → Full timestamp
    └── I → ISO 8601
```

---

## 🚀 Basic Usage

### Example 1: Launch Application

**Goal**: Open Chrome

**Steps**:
1. **Hold CapsLock + Space** → Leader mode activates
2. Press **P** → Programs submenu
3. Press **C** → Chrome launches

**Visual**:
```
Hold CapsLock+Space → [LEADER] → P → C
                      Tooltip shows menu
```

### Example 2: Window Management

**Goal**: Maximize current window

**Steps**:
1. **Hold CapsLock + Space** → Leader mode
2. Press **W** → Windows submenu
3. Press **M** → Window maximizes

### Example 3: Insert Timestamp

**Goal**: Insert current date and time

**Steps**:
1. **Hold CapsLock + Space** → Leader mode
2. Press **T** → Text/Timestamps submenu
3. Press **F** → Inserts "2025-01-12 15:30:45"

---

## 📋 Available Menus

### Menu P: Programs

| Key | Action | Description |
|-----|--------|-------------|
| **C** | Chrome | Launch Google Chrome |
| **V** | VS Code | Launch Visual Studio Code |
| **T** | Terminal | Launch Windows Terminal |
| **N** | Notepad | Launch Notepad |
| **E** | Explorer | Launch File Explorer |
| **D** | Discord | Launch Discord |
| **S** | Spotify | Launch Spotify |

**Customization**: Edit `src/layer/leader_router.ahk`

### Menu W: Windows Management

| Key | Action | Description |
|-----|--------|-------------|
| **M** | Maximize | Maximize active window |
| **R** | Restore | Restore window size |
| **C** | Center | Center window on screen |
| **L** | Move Left | Move to left half |
| **R** | Move Right | Move to right half |
| **T** | Move Top | Move to top half |
| **B** | Move Bottom | Move to bottom half |
| **F** | Fullscreen | Toggle fullscreen |

### Menu S: System

| Key | Action | Description |
|-----|--------|-------------|
| **S** | Screenshot | Take screenshot |
| **R** | Reload | Reload HybridCapslock |
| **K** | Restart Kanata | Restart Kanata service |
| **P** | Power Menu | Shutdown/Restart options |
| **L** | Lock | Lock Windows |
| **D** | Dark Mode | Toggle dark/light mode |

### Menu T: Text & Timestamps

| Key | Action | Example Output |
|-----|--------|----------------|
| **D** | Date | 2025-01-12 |
| **T** | Time | 15:30:45 |
| **F** | Full Timestamp | 2025-01-12 15:30:45 |
| **I** | ISO 8601 | 2025-01-12T15:30:45Z |
| **U** | Unix Timestamp | 1736695845 |
| **W** | Week Number | Week 02 |

### Menu G: Git (if enabled)

| Key | Action | Description |
|-----|--------|-------------|
| **S** | Status | git status |
| **A** | Add All | git add . |
| **C** | Commit | Open commit message |
| **P** | Push | git push |
| **L** | Pull | git pull |
| **D** | Diff | git diff |

---

## 🎨 Visual Feedback

When Leader Mode is active, a **tooltip** shows available options:

```
╔══════════════════════════════════╗
║       🎯 LEADER MODE             ║
╠══════════════════════════════════╣
║  P - Programs                    ║
║  W - Windows                     ║
║  S - System                      ║
║  T - Text/Timestamps             ║
║  G - Git                         ║
║                                  ║
║  ESC - Cancel                    ║
╚══════════════════════════════════╝
```

After selecting a submenu:
```
╔══════════════════════════════════╗
║    📁 PROGRAMS                   ║
╠══════════════════════════════════╣
║  C - Chrome                      ║
║  V - VS Code                     ║
║  T - Terminal                    ║
║  N - Notepad                     ║
║  E - Explorer                    ║
║                                  ║
║  ESC - Back                      ║
╚══════════════════════════════════╝
```

---

## ⚙️ Configuration

### Adding New Commands

Edit `src/layer/leader_router.ahk`:

```ahk
; Add new command to Programs menu
RegisterKeymap("leader_program", [
    {key: "c", desc: "Chrome", action: () => Run("chrome.exe")},
    {key: "v", desc: "VS Code", action: () => Run("code.exe")},
    {key: "f", desc: "Firefox", action: () => Run("firefox.exe")}  ; NEW
])
```

### Creating New Submenus

```ahk
; Create "Music" submenu
RegisterKeymap("leader", [
    {key: "m", desc: "Music", action: () => ActivateSubMenu("leader_music")}
])

RegisterKeymap("leader_music", [
    {key: "s", desc: "Spotify", action: () => Run("spotify.exe")},
    {key: "y", desc: "YouTube Music", action: () => Run("chrome.exe --app=https://music.youtube.com")},
    {key: "p", desc: "Play/Pause", action: () => Send("{Media_Play_Pause}")}
])
```

### Changing Activation Key

In `config/kanata.kbd`:

```lisp
;; Option 1: Use F24 as dedicated leader
(defalias
  leader F24
)

;; Option 2: Double-tap Space
(defalias
  leader (tap-dance 200 (space (layer-toggle leader)))
)

;; Option 3: Long-press Space
(defalias
  leader (tap-hold 500 200 space (layer-toggle leader))
)
```

---

## 💡 Usage Tips

### Tip 1: Mnemonic Keys

Choose keys that make sense:
- **P**rograms
- **W**indows
- **S**ystem
- **T**ext/Timestamps
- **G**it

Easier to remember!

### Tip 2: Group by Context

Organize by workflow, not alphabetically:
```
Leader → D (Development)
  ├── V → VS Code
  ├── G → Git status
  └── T → Terminal

Leader → B (Browser)
  ├── C → Chrome
  ├── F → Firefox
  └── N → New tab
```

### Tip 3: Practice Common Flows

Create muscle memory:
```
Morning routine:
Leader → P → C  (Open Chrome)
Leader → P → V  (Open VS Code)
Leader → P → T  (Open Terminal)
Leader → P → D  (Open Discord)
```

### Tip 4: Use for Infrequent Commands

Don't use Leader for:
- ❌ Copy/Paste (use homerow mods)
- ❌ Navigation (use Nvim layer)

Use Leader for:
- ✅ Launch applications
- ✅ Window management
- ✅ System commands
- ✅ Insert text snippets

---

## 🔧 Advanced Examples

### Example 1: Development Workflow

```ahk
RegisterKeymap("leader_dev", [
    {key: "r", desc: "Run project", action: () => Run("npm start")},
    {key: "t", desc: "Run tests", action: () => Run("npm test")},
    {key: "b", desc: "Build", action: () => Run("npm run build")},
    {key: "l", desc: "Lint", action: () => Run("npm run lint")}
])
```

### Example 2: Personal Information

```ahk
RegisterKeymap("leader_info", [
    {key: "e", desc: "Email", action: () => Send("your@email.com")},
    {key: "p", desc: "Phone", action: () => Send("+1234567890")},
    {key: "a", desc: "Address", action: () => Send("123 Main St")}
])
```

### Example 3: Templates

```ahk
RegisterKeymap("leader_templates", [
    {key: "m", desc: "Meeting notes", action: () => InsertTemplate("meeting")},
    {key: "t", desc: "TODO list", action: () => InsertTemplate("todo")},
    {key: "b", desc: "Bug report", action: () => InsertTemplate("bug")}
])
```

---

## ⚠️ Troubleshooting

### Problem: "Leader mode doesn't activate"

**Solutions**:
1. Check if Kanata is running
2. Verify leader key in `kanata.kbd`
3. Test with `OutputDebug` in leader_router.ahk

### Problem: "Tooltip doesn't show"

**Solutions**:
1. Enable tooltips in `config/settings.ahk`:
   ```ahk
   global EnableTooltips := true
   ```
2. Check C# tooltip integration is working

### Problem: "Key delay too long"

**Solutions**:
Reduce timeout in leader_router.ahk:
```ahk
; Default: 2000ms
SetTimer, CloseLeaderMode, -1000  ; Change to 1 second
```

---

## 🔗 See Also

- **[Nvim Layer](nvim-layer.md)**: Persistent navigation layer
- **[Excel Layer](excel-layer.md)**: Excel-specific commands
- **[Homerow Mods](homerow-mods.md)** - Base modifier system
- **[General Configuration](../getting-started/configuration.md)**: System settings

---

**[🌍 Ver en Español](../../es/guia-usuario/modo-lider.md)** | **[← Back to Index](../README.md)**
