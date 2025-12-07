# API Reference: Notification System

**File**: `system/plugins/notification.ahk`

The **Notification System** is a core plugin that provides a unified interface for displaying visual feedback to the user. It leverages the TooltipApp system for animated, visually rich notifications, with automatic fallback to native tooltips.

## 🚀 Main Functions

### ShowTooltipFeedback

Displays a feedback notification on the screen.

```autohotkey
ShowTooltipFeedback(message, type := "info", timeout := 2000)
```

**Parameters:**

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `message` | String | - | The message to display. Supports multiple lines. |
| `type` | String | `"info"` | The notification type (see Supported Types). |
| `timeout` | Integer | `2000` | Time in milliseconds before hiding the notification. |

**Supported Types:**

| Type | Color | Icon | Recommended Usage |
|------|-------|-------|-------------------|
| `info` | 🔵 Blue | 💡 | General information, neutral states. |
| `success` | 🟢 Green | ✅ | Successful operations, completed saves. |
| `warning` | 🟠 Orange | ⚠️ | Non-critical warnings, retries. |
| `error` | 🔴 Red | ❌ | Operation failures, validation errors. |
| `confirm` | 🟣 Purple | ❓ | Confirmation requests or questions. |

**Behavior:**
1. Validates the notification type.
2. Retrieves color configuration from the current theme.
3. Attempts to show an animated notification via `TooltipApp` (slide_left).
4. If `TooltipApp` is not available, uses native AHK `ToolTip` (ID 19).

## 💡 Usage Examples

### Basic Notification

```autohotkey
; Show simple message (default info)
ShowTooltipFeedback("System ready")
```

### Success Notification

```autohotkey
; Operation completed successfully
ShowTooltipFeedback("File saved successfully", "success")
```

### Custom Error Notification

```autohotkey
; Error with longer display time (3 seconds)
ShowTooltipFeedback("Connection error: Could not reach server", "error", 3000)
```

### Warning Notification

```autohotkey
ShowTooltipFeedback("Low battery: 15%", "warning")
```

## 🎨 Customization

The system respects the global theme configuration (`HybridConfig.theme`). Base colors are taken from the theme, while type-specific colors (borders and icons) are hardcoded for visual consistency:

- **Info**: `#3498db`
- **Success**: `#27ae60`
- **Warning**: `#f39c12`
- **Error**: `#e74c3c`
- **Confirm**: `#9b59b6`

## 🔧 Technical Details

- **Tooltip ID (Native)**: Uses ID `19` to avoid conflicts with other tooltips.
- **Tooltip ID (App)**: Uses ID `"notification_feedback"`.
- **Icons**: Uses NerdFonts Unicode characters.
- **Animation**: `slide_left` with 300ms duration.
- **Position**: Currently `top_left` with offset (20, 20).

## 🔄 Migration

If you are using legacy feedback functions or manual tooltips, migrate to `ShowTooltipFeedback`:

**Before:**
```autohotkey
ToolTip("Saving...", , , 15)
SetTimer(() => ToolTip(,,,15), -2000)
```

**After:**
```autohotkey
ShowTooltipFeedback("Saving...", "info")
```
