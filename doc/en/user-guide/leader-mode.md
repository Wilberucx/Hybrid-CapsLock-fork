# Leader Mode

> Quick reference
>
> - General configuration: see doc/configuration.md (sections [Behavior], [Layers], [Tooltips])
> - Per-layer configuration: / / / INFORMATION_LAYER.md / excel-layer.md /

Leader Mode is a contextual menu system that organizes advanced functions into specialized sub-layers. It provides quick access to window management tools, program launching, and timestamp utilities.

## 🎯 Activation

**Default shortcut:** `Hold CapsLock + Space`

> **How it works:**
>
> 1. Hold down `CapsLock` physically
> 2. While holding it, press `Space`
> 3. The Leader menu will open

**Shortcut customization:** The shortcut is configurable by editing `../../../config/kanata.kbd`. By default, when you hold CapsLock, the `vim-nav` layer is activated where `Space` sends `F24` (which AutoHotkey detects as Leader). You can change this to any other key:

```lisp
;; In ../../../config/kanata.kbd, find the vim-nav layer:
(deflayer vim-nav
  _    f13  _    _   end   _    _    _    _    _   home  _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    left down up   rght _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _             f24             _    _    _
                           ↑
                    Space sends F24 (Leader)
)

;; Example: Change Leader to "Hold CapsLock + L"
;; Replace: _    _    _    _    _    _    left down up   rght _    _    _
;; With:    _    _    _    _    _    _    left down up   f24  _    _    _
;;                                                         ↑
;;                                                   L is now Leader
```

After editing, reload the system: **Leader → c → h → R** (Full reload) or **Leader → c → h → k** (Restart Kanata only).

When activating leader mode, a visual menu appears showing available options.

## 📋 Main Menu

```
LEADER MENU

h - Hybrid Management
p - Programs
t - Time
i - Information

[Esc: Exit]
```

## 🎮 Navigation

### Universal Controls

- Esc: completely exit leader mode (total EXIT)
- Backspace: return to previous menu (smart back with breadcrumb)
- Backslash (\\): reserved as back, but not reliable in all contexts; Backspace is standardized
- Timeout: 7 seconds of inactivity closes automatically

### Navigation Flow

Note on navigation and smart back

- A breadcrumb (navigation stack) is implemented when C# tooltips are enabled, and an internal loop in AHK when they're not, to ensure that Backspace always returns exactly to the previous menu, not drastically to Leader.
- Backspace is the standard back key. Backslash (\\) was attempted as an alternative, but can be captured as normal input in certain submenus; for ergonomics and consistency (Vim/Neovim style), Backspace is preferred.

```
leader → Main Menu
                ↓
        Select sub-layer (w/p/t)
                ↓
        Execute specific action
                ↓
        Exit automatically OR return with Backspace
```

## 💡 Special Features

### ⏸️ Hybrid Pause and Resume with Leader

- If the script is suspended (hybrid pause from `Commands → Hybrid Management → p`), pressing `CapsLock+Space` (Leader) immediately resumes and continues the normal Leader flow.
- Hybrid pause sets up auto-resume after `hybrid_pause_minutes` (configurable in `config/configuration.ini`, default 10).
- Visual feedback: "SUSPENDED Xm — press Leader to resume" and "RESUMED/RESUMED (auto)".

### 📱 Visual Feedback

- Each sub-layer shows its own contextual menu
- Centered tooltips on screen for better visibility
- Status indicators for persistent actions

## 🔧 Customization

1. **Create menu function:**

   ```autohotkey
   ShowNewMenu() {
       ; Define the visual menu
   }
   ```

2. **Update main menu:**

   ```autohotkey
   ShowLeaderMenu() {
       MenuText .= "new_key - New Function`n"
   }
   ```

## 📊 Usage Statistics

Leader mode is optimized for:

- **Quick access:** Maximum 2 keys for any function
- **Muscle memory:** Mnemonic keys (h=Hybrid Management, p=Programs, i=information)
- **Efficiency:** Automatic timeout to avoid locks
- **Flexibility:** Modular system easy to extend with plugins

## ⚠️ Considerations

- **Fullscreen applications:** Some tooltips may not be visible
- **Performance:** Timeouts prevent excessive memory usage
- **Compatibility:** Works best with AutoHotkey v2
