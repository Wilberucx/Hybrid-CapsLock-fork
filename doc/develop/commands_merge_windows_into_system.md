# Merge: Windows commands into System commands

Date: 2025-10-13
Owner: Wilber Canto
Scope: Commands menu (System + Windows)

Summary

- The former "Windows commands" category was removed and its actions were integrated into the "System commands" category to reduce redundancy and avoid routing conflicts (e vs E).
- Execution is now handled directly in `ExecuteSystemCommand()`; no delegation to `ExecuteWindowsCommand()` is required.

Why

- Overlap and confusion between keys `e` (Event Viewer) and `E` (Environment Variables) when Windows lived as a separate category or was merged via delegation.
- Simpler user experience: a single place (System) for OS-related tools.

What changed

- UI/Menu (C# tooltip menu for Commands → System): include Windows-related items alongside System items.
- Commands routing:
  - Removed the temporary "merge bridge" that delegated `h/r/e/E` to `ExecuteWindowsCommand()`.
  - Implemented those keys natively in `ExecuteSystemCommand()`.
- Optional auto-hide for the tooltip is applied at the top of `ExecuteSystemCommand()` when configured.

Final keymap under System

- s: System Info (cmd → systeminfo)
- t: Task Manager (taskmgr)
- v: Services (services.msc)
- d: Device Manager (devmgmt.msc)
- c: Disk Cleanup (cleanmgr)
- h: Toggle Hidden Files (Explorer)
- r: Registry Editor (regedit)
- e: Event Viewer (eventvwr.msc)
- E: Environment Variables (rundll32 sysdm.cpl,EditEnvironmentVariables)

Technical notes

- Event Viewer: launches via `%SystemRoot%\system32\eventvwr.msc` with fallback to `eventvwr.msc`.
- Environment Variables: `rundll32.exe sysdm.cpl,EditEnvironmentVariables`.
- Toggle Hidden Files: keeps existing implementation; consider enhancing with `SHChangeNotify` and optionally toggling `ShowSuperHidden` for clearer feedback.
- The legacy `ExecuteWindowsCommand()` can be kept temporarily for compatibility but is no longer required by the System flow.

Testing checklist

- Commands → System
  - h toggles Explorer hidden files visibility (refresh Explorer with F5 if needed).
  - r opens Registry Editor.
  - e opens Event Viewer.
  - E (Shift+e) opens Environment Variables.
  - s/t/v/d/c behave as expected.

Future improvements

- Add shell refresh via `SHChangeNotify` after toggling hidden files.
- Parametrize keys in INI for easy remapping.
- Remove old Windows routing once confirmed unused across the codebase.
