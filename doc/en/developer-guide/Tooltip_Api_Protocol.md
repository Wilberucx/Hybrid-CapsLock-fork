# Tooltip API Protocol

This document outlines the communication protocol for the Tooltip application. The application operates as a **Named Pipe Server**, listening for JSON commands to update its UI.

## 📡 Communication Mechanism

-   **Pipe Name**: `\\.\pipe\TooltipPipe`
-   **Format**: JSON (UTF-8)
-   **Method**: One-way fire-and-forget. The client connects, writes the JSON string, and disconnects.

## 📜 Command Structure

The root object is a **TooltipCommand**. All fields are optional, but `show` is typically required to take action.

### Core Fields

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `show` | `bool` | `false` | `true` to display the tooltip, `false` to hide it. |
| `id` | `string` | `"main"` | Unique identifier for the tooltip window. Allows multiple independent tooltips (e.g., one for menu, one for status). |
| `title` | `string` | `""` | The main header text of the tooltip. |
| `timeout_ms` | `int` | `7000` | Time in milliseconds before the tooltip automatically hides. Set to `0` for persistent. |
| `tooltip_type` | `string` | `"leader"` | **⚠️ DEPRECATED:** Use granular objects instead. Presets: `"leader"`, `"status_persistent"`, `"sidebar_right"`, `"bottom_right_list"`, `"text_block"`. |

### Content Fields

| Field | Type | Description |
| :--- | :--- | :--- |
| `items` | `Array` | List of items to display (see **Item Object** below). Used for standard menus. |
| `content` | `string` | Raw text content. Used when `tooltip_type` is `"text_block"`. Preserves whitespace/newlines. |
| `navigation` | `Array<string>` | List of strings to display in the bottom navigation bar (e.g., `["ESC: Close", "ENTER: Select"]`). |

### Layout & Behavior (v2.1+ Granular Configuration)

**New in v2.1:** Use granular configuration objects for better control:

| Object | Type | Description |
| :--- | :--- | :--- |
| `layout` | `object` | Layout configuration: `{ mode: "grid", columns: 4 }` |
| `window` | `object` | Window properties: `{ topmost: true, click_through: false, opacity: 1.0 }` |
| `animation` | `object` | Animation settings: `{ type: "fade", duration_ms: 300, easing: "ease_out" }` |
| `position` | `object` | Position settings: `{ monitor: 1, x: 100, y: 100 }` |
| `style` | `object` | Style settings including `font_family` for NerdFont support |

#### Layout Object

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `mode` | `string` | `"grid"` | `"grid"` (multi-column) or `"list"` (single column). |
| `columns` | `int` | `4` | Number of columns when mode is `"grid"`. |

#### Window Object

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `topmost` | `bool` | `true` | If `true`, forces the window to stay on top. |
| `click_through` | `bool` | `false` | If `true`, mouse clicks pass through the window. |
| `opacity` | `double` | `1.0` | Opacity of the window (0.0 to 1.0). |

#### Animation Object (New in v2.1!)

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `type` | `string` | `"none"` | Animation type: `"none"`, `"fade"`, `"slide_left"`, `"slide_right"`, `"slide_up"`, `"slide_down"` |
| `duration_ms` | `int` | `300` | Animation duration in milliseconds |
| `easing` | `string` | `"ease_out"` | Easing function: `"linear"`, `"ease_in"`, `"ease_out"`, `"ease_in_out"`, `"bounce"` |

#### Position Object

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `monitor` | `int` | `0` | Monitor index for multi-monitor setups (DPI-aware) |
| `x` | `int` | `null` | X position (optional, auto-calculated if not set) |
| `y` | `int` | `null` | Y position (optional, auto-calculated if not set) |

#### Style Object

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `font_family` | `string` | System font | Font family name (e.g., `"FiraCode Nerd Font"` for NerdFont icons) |
| `font_size` | `int` | `12` | Font size |
| `bg_color` | `string` | `"#1e1e1e"` | Background color |
| `text_color` | `string` | `"#ffffff"` | Text color |

---

### Legacy Fields (Backward Compatible)

> ⚠️ **DEPRECATED:** The following fields are still supported for backward compatibility but should be migrated to granular objects.

| Field | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `layout` | `string` | `"grid"` | Use `layout.mode` instead |
| `columns` | `int` | `4` | Use `layout.columns` instead |
| `topmost` | `bool` | `null` | Use `window.topmost` instead |
| `click_through` | `bool` | `null` | Use `window.click_through` instead |
| `opacity` | `double` | `null` | Use `window.opacity` instead |

---

## 🧩 Data Objects

### Item Object (`items`)

Represents a single actionable item in the menu.

```json
{
  "key": "w",             // The hotkey trigger (displayed boldly)
  "description": "Work",  // The description text
  "color": "#ff0000"      // (Optional) Override color for this specific key
}
```

### Style Object (`style`)

Customizes the visual appearance. All colors support Hex format (`#RRGGBB` or `#AARRGGBB`).

```json
{
  "background": "#1e1e1e",
  "text": "#ffffff",
  "border": "#333333",
  "accent_options": "#dbd6b9",      // Color for item keys
  "accent_navigation": "#2d2d2d",   // Background for nav pills
  "navigation_text": "#888888",
  
  "border_thickness": 1,
  "corner_radius": 8,
  "padding": [16, 16, 16, 16],      // [left, top, right, bottom]
  
  "title_font_size": 14,
  "item_font_size": 12,
  "title_font_size": 14,
  "item_font_size": 12,
  "navigation_font_size": 11,
  "font_family": "Segoe UI",        // Font family for text (default "Consolas" for text_block)
  
  "max_width": 800,
  "max_height": 600
}
```

### Position Object (`position`)

Controls where the tooltip appears on screen.

```json
{
  "anchor": "bottom_center",  // See Anchor Options below
  "offset_x": 0,
  "offset_y": 50,
  "x": 100,                   // Absolute X (only if anchor="manual")
  "y": 100                    // Absolute Y (only if anchor="manual")
}
```

**Anchor Options**:
- `top_left`, `top_center`, `top_right`
- `center_left`, `center`, `center_right`
- `bottom_left`, `bottom_center`, `bottom_right`
- `manual` (uses `x` and `y` coordinates)

---

## 💡 Examples

### 1. Basic Menu (AutoHotkey)

```autohotkey
json := '
(
  {
    "show": true,
    "title": "MY MENU",
    "items": [
      {"key": "1", "description": "Option One"},
      {"key": "2", "description": "Option Two"}
    ]
  }
)'
Tooltip_SendRaw(json)
```

### 2. Persistent Status Pill

Displays a small status indicator in the bottom right that doesn't disappear automatically.

```json
{
  "id": "status_pill",
  "show": true,
  "title": "INSERT MODE",
  "timeout_ms": 0,
  "position": {
    "anchor": "bottom_right",
    "offset_x": -20,
    "offset_y": -20
  },
  "style": {
    "background": "#007acc",
    "text": "#ffffff",
    "padding": [8, 4, 8, 4],
    "corner_radius": 4,
    "title_font_size": 10
  }
}
```

### 3. Hide a Specific Tooltip

```json
{
  "id": "status_pill",
  "show": false
}
```

### 4. Complex Layout (Grid)

```json
{
  "show": true,
  "title": "COMMAND PALETTE",
  "layout": "grid",
  "columns": 3,
  "items": [
    {"key": "f", "description": "File"},
    {"key": "e", "description": "Edit"},
    {"key": "v", "description": "View"},
    {"key": "g", "description": "Go"},
    {"key": "r", "description": "Run"},
    {"key": "t", "description": "Terminal"}
  ],
  "navigation": ["ESC: Cancel", "ENTER: Confirm"]
}
```

### 5. Text Block / Welcome Screen (ASCII Art)

Displays raw, multiline text with whitespace preservation. Ideal for ASCII art or welcome messages.

```json
{
  "show": true,
  "tooltip_type": "text_block",
  "title": "WELCOME",
  "content": "  __  __       _          _     _ \n |  \\/  |     | |        (_)   | |\n | \\  / |_   _| |__  _ __ _  __| |\n | |\\/| | | | | '_ \\| '__| |/ _` |\n | |  | | |_| | |_) | |  | | (_| |\n |_|  |_|\\__, |_.__/|_|  |_|\\__,_|\n          __/ |                   \n         |___/                    ",
  "position": { "anchor": "center" },
  "style": {
    "font_family": "Consolas",
    "item_font_size": 14,
    "background": "#1a1b26",
    "text": "#7aa2f7"
  }
}
```
