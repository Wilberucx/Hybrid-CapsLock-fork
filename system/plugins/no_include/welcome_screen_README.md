# Welcome Screen Plugin

## Overview

Core plugin that displays a beautiful animated welcome screen when HybridCapsLock starts. Uses TooltipApp v2.1 features including NerdFont icons, smooth animations, and modern styling.

## Features

- 🎨 **NerdFont Icons**: Beautiful icons for visual appeal
- ✨ **Smooth Animations**: Fade-in effect for professional look
- 🎯 **Quick Tips**: Helpful keyboard shortcuts and tips
- ⚙️ **Configurable**: Timeout, animation, and enable/disable options
- 🌈 **Modern Design**: Vibrant colors and clean layout

## Functions

### ShowWelcomeScreen()

Displays the main welcome screen with NerdFont icons and animations.

**Features:**
- Animated fade-in (400ms)
- Centered on screen
- Auto-dismiss after configured timeout
- Shows version, tips, and shortcuts

**Example:**
```ahk
; Call on startup
ShowWelcomeScreen()
```

### ShowWelcomeScreenSimple()

Fallback version without NerdFont icons for systems that don't have NerdFonts installed.

**Example:**
```ahk
; Use if NerdFont is not available
ShowWelcomeScreenSimple()
```

### ShowQuickTip(tipText, icon := "")

Display a small notification with a helpful tip.

**Parameters:**
- `tipText` - The tip text to display
- `icon` - Optional NerdFont icon (default: info icon)

**Example:**
```ahk
; Show a quick tip
ShowQuickTip("Press CapsLock + ? for help menu")

; With custom icon
ShowQuickTip("File saved successfully!", Chr(0xF00C))  ; Check icon
```

### HideWelcomeScreen()

Manually hide the welcome screen before timeout.

**Example:**
```ahk
; Hide welcome screen immediately
HideWelcomeScreen()
```

## Configuration

Add to your `HybridConfig`:

```ahk
HybridConfig.welcome := {
    enabled: true,              ; Enable/disable welcome screen
    timeout_ms: 3000,          ; Auto-dismiss timeout (milliseconds)
    animation: "fade",         ; Animation type
    use_nerdfonts: true        ; Use NerdFont icons
}
```

## Integration

### In init.ahk

```ahk
; Include the plugin
#Include system/plugins/welcome_screen.ahk

; Call after all plugins are loaded
SetTimer(() => ShowWelcomeScreen(), -500)  ; Show after 500ms delay
```

### Manual Trigger

```ahk
; Add to keymaps if you want manual trigger
RegisterKeymap("leader", "h", "w", "Show Welcome", () => ShowWelcomeScreen(), false, 1)
```

## NerdFont Icons Used

The plugin uses the following NerdFont icons:

| Icon | Code | Description |
|------|------|-------------|
|  | `Chr(0xF135)` | Rocket (title) |
|  | `Chr(0xF11C)` | Keyboard |
|  | `Chr(0xF005)` | Star |
|  | `Chr(0xF05A)` | Info |
|  | `Chr(0xF00C)` | Check |
|  | `Chr(0xF004)` | Heart |

## Styling

The welcome screen uses a modern dark theme:

- **Background**: `#1a1b26` (Tokyo Night dark)
- **Text**: `#c0caf5` (Tokyo Night foreground)
- **Accent**: `#7aa2f7` (Tokyo Night blue)
- **Success**: `#9ece6a` (Tokyo Night green)
- **Border**: 2px blue with 12px rounded corners
- **Font**: JetBrainsMono Nerd Font

## Requirements

- TooltipApp v2.1 or higher
- JetBrainsMono Nerd Font (optional, falls back to simple version)
- AutoHotkey v2.0+

## Examples

### Basic Usage

```ahk
; Show welcome screen on startup
ShowWelcomeScreen()
```

### With Custom Timeout

```ahk
; Show for 5 seconds
HybridConfig.welcome.timeout_ms := 5000
ShowWelcomeScreen()
```

### Quick Tips Throughout Session

```ahk
; Show tips at intervals
SetTimer(() => ShowQuickTip("Remember: CapsLock + ? for help"), -60000)  ; After 1 minute
```

## Troubleshooting

### Icons Show as Boxes (�)

**Cause**: NerdFont not installed

**Solution**:
1. Install JetBrainsMono Nerd Font from https://www.nerdfonts.com/
2. Or use `ShowWelcomeScreenSimple()` instead

### Welcome Screen Doesn't Appear

**Check**:
1. Is `TooltipApp.exe` running?
2. Is welcome screen enabled in config?
3. Check `debug.log` for errors

### Animation Not Smooth

**Check**:
1. Ensure TooltipApp v2.1 or higher
2. Check system performance
3. Try reducing `duration_ms`

## See Also

- [TooltipApp API Protocol](../../tooltip_doc/Tooltip_Api_Protocol.md)
- [Core Plugins Documentation](../../doc/en/developer-guide/core-plugins.md)
- [NerdFonts Cheat Sheet](https://www.nerdfonts.com/cheat-sheet)
