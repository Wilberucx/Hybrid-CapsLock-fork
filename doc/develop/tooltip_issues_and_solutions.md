# HybridCapsLock – Tooltip issues and solutions log

Lógica deprecada pendiente por rafctorizar/eliminar:

This document records the main problems found and the solutions applied during the tooltip modernization work (AutoHotkey + C# TooltipApp). It serves as a future reference for behavior, design decisions, and troubleshooting.

Date: 2025-10-13
Owner: Wilber Canto

---

## Index

- Startup welcome tooltip
- NVIM layer – status tooltip (persistent ON, remove OFF)
- NVIM layer – help tooltip (toggle with ?)
- Visual mode (inside NVIM) – status & help tooltips
- Overlap/superposition issues between tooltips
- Unicode symbols rendering as ?
- Native tooltip API constraints
- Configuration notes and timeouts
- Documentation updates
- Open ideas / next steps

---

## Startup welcome tooltip

Problem

- On startup a default “WELCOME” popup appeared with a wrong scheme and centered position.
- It ignored our theme and positioning config and looked like a default template.

Solution

- Removed default title text in MainWindow.xaml.
- The C# window starts hidden and only shows on valid JSON.
- Implemented a startup tooltip via AHK `ShowWelcomeStatusCS()`:
  - Matches Leader visual scheme (style, position, columns) using theme defaults.
  - Title: “Hybrid CapsLock”.
  - Single item: key “>” + description with script version (from [General] script_version). Falls back to “Hybrid CapsLock” if not present.
  - Timeout fixed to 1000 ms.
- Also provided the option to disable the welcome entirely; current setup shows it only if `enable_csharp_tooltips=true`.

Notes

- Welcome no longer blocks or shows centered default UI.

---

## NVIM layer – status tooltip (persistent ON, remove OFF)

Problem

- Status tooltip needed to persist while NVIM layer is ON and show briefly when turning OFF.
- At some point, an empty "items" array made the tooltip not render at all.

Solution

- `ShowNvimLayerToggleCS(isActive)` now:
  - Starts TooltipApp if needed (fallback to native tooltip if process not present).
  - If turning OFF: hides the tooltip and returns (no OFF tooltip).
  - If turning ON: shows a persistent list tooltip (timeout=0) with one item: key “?” and description “help”. This ensures at least one item so the UI renders.
  - Respects theme style/position/topmost/click_through/opacity.

Notes

- We intentionally removed the OFF tooltip to avoid noise.

---

## NVIM layer – help tooltip (toggle with ?)

Problem

- Needed a help tooltip when pressing “?” inside NVIM.
- ESC originally didn’t close reliably.
- Earlier, using unicode ◉/○ caused occasional rendering issues.

Solution

- Hotkey “?” under NVIM toggles the help:
  - If help is not visible: hide the persistent NVIM ON tooltip (avoid overlap), then show `ShowNvimHelpCS()`.
  - If help is visible: close help and restore persistent NVIM ON if layer still active.
- `ShowNvimHelpCS()` shows bottom-right list with title “NVIM HELP” and navigation hint “?: Close”.
- Help content (current):
  - h/j/k/l: Move left/down/up/right
  - v: Visual Mode
  - y: Copy; p: Paste; u: Undo; x: Cut; r: Redo
  - i: Insert Mode
  - w/b: Word right/left; e: End of word
  - C-u/C-d: Scroll up 6 / down 6
  - Esc: Escape/Exit mode
  - f: Find (sends Ctrl+Shift+Alt+2)
  - : Cmd (w/q/wq)
- Help timeout: min 8000 ms or `optionsTimeout` if greater.
- Closing with “?” works reliably; we removed the ESC hint to avoid confusion.

Notes

- The “f: Find” key sends Ctrl+Shift+Alt+2; the user should configure their preferred launcher (Fluent Search, Flow Launcher, PowerToys Run, etc.) to bind that chord to open search.
- We removed Shift-based smooth scroll (E/Y) from both mappings and help.

---

## Visual mode (inside NVIM) – status & help tooltips

Problem

- Visual mode had no dedicated persistent status or help UI. Also needed consistency with NVIM.

Solution

- Status: `ShowVisualLayerToggleCS(isActive)`
  - ON: persistent tooltip (timeout=0) with title “Visual” and single item key “?” + description “help”.
  - OFF: hides the tooltip.
- Help: `ShowVisualHelpCS()`
  - Bottom-right list with title “VISUAL HELP”, hint “?: Close”.
  - Items include: h/j/k/l extend; w/b extend word; y copy selection; d delete selection; a select all; c change→insert; Esc exit.
  - Timeout: min 8000 ms or `optionsTimeout` if greater.
- Hotkey “?” behavior
  - If VisualMode is active: toggles Visual help.
  - Else: toggles NVIM help.

Notes

- On closing Visual help, if VisualMode still ON, we restore “Visual ? help”; if VisualMode OFF but NVIM still ON, we restore NVIM persistent tooltip.

---

## Overlap/superposition issues between tooltips

Problem

- Showing a new tooltip while a persistent one was visible sometimes prevented the new one from appearing.

Solution

- Before showing any help tooltip, we explicitly hide the current persistent tooltip (`HideCSharpTooltip()`), wait a short moment (~30 ms), then show help.
- When help closes, we restore the appropriate persistent tooltip depending on the state (Visual or NVIM).
- On leaving Visual (`ShowVisualModeStatus(false)`), if NVIM is still active, we explicitly call `ShowNvimLayerToggleCS(true)` to restore NVIM persistent tooltip.

---

## Unicode symbols rendering as ?

Problem

- “◉/○” symbols sometimes rendered as “?” in the key slot.

Solution

- We moved away from using those symbols for the NVIM status item.
- Additionally, for other symbol use-cases, changed the key TextBlock font in C# to `Segoe UI Symbol` to improve glyph coverage.

---

## Native tooltip API constraints

Problem

- `ShowCenteredToolTip()` only accepts a single parameter; passing (text, ms) caused runtime errors.

Solution

- Use `ShowCenteredToolTip(text)` and then `SetTimer(() => RemoveToolTip(), -ms)` for timing.

---

## Configuration notes and timeouts

- enable_csharp_tooltips must be true to use the C# TooltipApp.
- TooltipApp executable must be compiled and discoverable; `StartTooltipApp()` launches it.
- JSON writes are handled via `ScheduleTooltipJsonWrite()`.
- Timeouts
  - NVIM status ON: timeout 0 (persistent). OFF: hidden (no OFF tooltip).
  - NVIM help: min 8000 ms, or `optionsTimeout` from INI if larger; closes with “?” too.
  - Visual status ON: timeout 0 (persistent). OFF: hidden.
  - Visual help: min 8000 ms, or `optionsTimeout` if larger; closes with “?” too.
  - Welcome tooltip: 1000 ms.

---

## Documentation updates

- NVIM help: updated to say `f: Find` and note it sends Ctrl+Shift+Alt+2; users should bind this in their launcher of choice.
- Consider adding a small section in NVIM docs describing Visual mode tooltips and the “?” toggle behavior.

---

## Open ideas / next steps

- Make help content configurable from INI (e.g., `nvim_layer.ini [Help]`).
- Expose specific timeouts per help type in INI (e.g., `nvim_help_timeout_ms`, `visual_help_timeout_ms`).
- Add small debounce/delay utilities around tooltip transitions (centralized).
- Add automated checks to ensure at least one item is present on any tooltip.

---

Changelog summary

- Removed default WPF welcome content; window starts hidden.
- Added startup welcome that matches Leader theme and times out in 1s.
- NVIM ON persistent status; removed OFF tooltip.
- NVIM help with “?: Close”, min 8s timeout, robust toggle logic.
- Visual ON persistent status with “? help”. Visual help with “?: Close”.
- Fixed overlap by hiding before showing new tooltip and restoring after.
- Avoided unicode symbol issues and fixed native tooltip API usage.
