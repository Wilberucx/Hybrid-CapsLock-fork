# Pruebas Manuales de HybridCapsLock

Este sistema está deprecado
Esta guía cubre pruebas manuales esenciales para verificar el comportamiento actual del sistema. Ejecuta `init.ahk` y usa los menús de Leader (`CapsLock + Space`). Al finalizar cada bloque, puedes recargar configuración o script desde Leader → c → h → r/R.

## 1. Timeouts jerárquicos

- En `config/configuration.ini` ajusta:
  - [Behavior] global_timeout_seconds=5
  - [Behavior] leader_timeout_seconds=6
- En `config/timestamps.ini` ajusta:
  - [Settings] timeout_seconds=20
- Verifica:
  - En menús de Timestamps, el timeout efectivo es ~20s.
  - En menús de Leader/Windows, el timeout efectivo es ~6s (fallback a 5 si no está leader_timeout_seconds).

## 2. Tooltips C #

- En `config/configuration.ini` → [Tooltips]
  - enable_csharp_tooltips=true/false y verifica que cambie entre tooltip C# y nativo.
  - options_menu_timeout, status_notification_timeout, persistent_menus, auto_hide_on_action afectan duración y comportamiento de menús/notificaciones.

## 3. Programs — confirmaciones y auto_launch

- En `config/programs.ini` → [Settings]
  - show_confirmation=false, auto_launch=true
- En `config/programs.ini` → [ProgramMapping]
  - Establece confirm_keys=v (o una letra que tengas mapeada)
- Verifica:
  - Leader → p → tecla distinta de v: lanza inmediatamente.
  - Leader → p → v: solicita confirmación (y/n). Con y lanza, n/Esc cancela.
  - Cambia show_confirmation=true y confirma que SIEMPRE pregunta (incluso cuando auto_launch=true).

## 4. Information — show_confirmation y auto_paste

- En `config/information.ini` → [Settings]
  - show_confirmation=false, auto_paste=true
- Verifica:
  - Leader → i → una tecla mapeada: inserta al instante sin confirmación.
- Cambia auto_paste=false
  - Leader → i → misma tecla: muestra detalles y requiere ENTER para insertar; Esc cancela.
- Cambia show_confirmation=true
  - Si auto_paste=true: ahora pide confirmación (y/n) antes de insertar.
  - Si auto_paste=false: después de ENTER, pide confirmación (y/n) si corresponde.

## 5. Timestamps — confirmación por categoría/comando

- En `config/timestamps.ini`:
  - [Settings] show_confirmation=false
  - [CategorySettings] Date_show_confirmation=true
  - [Confirmations.Date] confirm_keys=1,2 (opcional)
- Verifica:
  - Leader → t → d: cualquier selección de fecha pide confirmación (forzada por categoría).
  - Cambia Date_show_confirmation=false y usa confirm_keys=1,2: ahora solo 1 y 2 piden confirmación.

## 6. Commands — jerarquía de confirmación

- En `config/commands.ini`:
  - [Settings] show_confirmation=false
  - [o_category] confirm_keys=S,r,o
  - (Opcional) [CategorySettings] PowerOptions_show_confirmation=true para forzar toda la categoría (verifica que domine sobre listas por comando).
- Verifica:
  - Leader → c → o → S/r/o: pide confirmación; otras teclas no.
  - Con PowerOptions_show_confirmation=true: todas las teclas de o confirman.

## 7. Global — show_confirmation_global

- En `config/configuration.ini`:
  - [Behavior] show_confirmation_global=true
- Verifica que todas las acciones pidan confirmación across Programs/Information/Timestamps/Commands.

## 8. Persistencia de capas (enable_layer_persistence)

- En `config/configuration.ini` → [Layers]
  - enable_layer_persistence=true
- Activa una capa y persístela:
  - Activa Nvim Layer (usa tu hotkey asignada) o Excel Layer, luego cierra y vuelve a ejecutar el script.
  - Verifica que el estado regrese (ON/OFF) según lo último guardado en `data/layer_state.ini`.
- Cambia flags de capa:
  - Desactiva, por ejemplo, nvim_layer_enabled=false y reinicia el script.
  - Verifica que, aunque el estado persistido fuese ON, la capa queda deshabilitada (clamp por flag).

## 9. Recarga en caliente

- Abre Leader → c → h → r (Reload Config) y valida que cambios en `.ini` se apliquen sin reiniciar.
- Prueba r/R tras cambiar show_confirmation/auto_paste/auto_launch.

## 10. Regresión básica

- Verifica que Leader → c → w (Windows), → t (Timestamps), → i (Information), → p (Programs) muestren menús esperados.
- Si Tooltips C# está ON, verifica que los JSON de estado se creen (tooltip*commands.json, status*\*\_commands.json) y que desaparezcan al cerrar.

Notas:

- Si una prueba no se comporta como se espera, captura la configuración y el flujo exacto (pasos, teclas, y valores) para depurar.

