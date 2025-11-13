# Sistema de Configuración de HybridCapsLock

## Nuevos parámetros de pausa híbrida

En `config/configuration.ini` dentro de la sección `[Behavior]`:

```ini
; Hybrid pause settings
; Minutes for auto-resume when pausing from Commands → Hybrid Management (default 10)
hybrid_pause_minutes=10
; Enable emergency resume hotkey (Ctrl+Alt+Win+R) that always resumes even if Leader is disabled
enable_emergency_resume_hotkey=true
```

- `hybrid_pause_minutes`: tiempo en minutos para reanudar automáticamente tras activar la pausa híbrida desde `Leader → c → h → p`. Si está vacío o inválido, usa 10 por defecto.
- `enable_emergency_resume_hotkey`: habilita un atajo de emergencia `Ctrl+Alt+Win+R` que reanuda el script aunque todos los hotkeys estén suspendidos o el Leader esté deshabilitado.

Comportamiento de la pausa híbrida:
- Al ejecutar `Pause Hybrid` desde `Hybrid Management`, el script suspende sus hotkeys y arma un auto-resume al cabo de `hybrid_pause_minutes`.
- Si presionas `CapsLock+Space` (Leader) mientras está suspendido, el script se reanuda al instante y continúa con el flujo normal del Leader.
- Puedes reanudar manualmente desde el mismo comando (si ya está en pausa) o desde el ícono de la bandeja de AHK.
- Feedback visual: se muestran mensajes “SUSPENDED Xm — press Leader to resume” y “RESUMED/RESUMED (auto)”.


HybridCapsLock utiliza un sistema de configuración modular basado en archivos `.ini` que permite personalizar cada aspecto del comportamiento del script. Esta guía describe las configuraciones actuales del sistema y cómo usarlas. Enfócate en este documento para configurar tu entorno; no se requieren referencias a documentos internos de fases.

## Estructura de Configuración

### Archivo Principal: `configuration.ini`

Contiene la configuración global del sistema y banderas de capas. Hoy, las secciones con efecto en el script son principalmente `[Behavior]`, `[Layers]` y `[Tooltips]`.

- `[Behavior]` – Comportamiento global

  ```ini
  caps_lock_acts_normal=false
  global_timeout_seconds=7
  leader_timeout_seconds=7
  enable_smooth_scrolling=true
  scroll_sensitivity=3
  mouse_click_duration=50
  show_confirmation_global=false
  ```

  Notas:
  - `show_confirmation_global=true` fuerza confirmación en todas las capas/menús.

- `[Layers]` – Banderas de habilitación por capa

  ```ini
  nvim_layer_enabled=true
  excel_layer_enabled=true
  modifier_layer_enabled=true
  leader_layer_enabled=true
  enable_layer_persistence=true
  ```

- `[Tooltips]` – Configuración de tooltips C# (WPF)
  Estas claves son leídas por `tooltip_csharp_integration.ahk`.

  ```ini
  enable_csharp_tooltips=true           ; Usa tooltips C# en lugar de nativos
  options_menu_timeout=10000            ; Duración (ms) para menús/opciones
  status_notification_timeout=2000      ; Duración (ms) para notificaciones de estado
  auto_hide_on_action=true              ; Oculta al seleccionar una opción
  persistent_menus=false                ; Mantiene menús visibles hasta ESC
  tooltip_fade_animation=true           ; Animaciones de fade in/out
  tooltip_click_through=true            ; Permitir click-through
  ```

- Otras secciones presentes en `configuration.ini` (`[General]`, `[UI]`, `[Performance]`, `[Security]`, `[Advanced]`, `[CustomHotkeys]`, `[ApplicationProfiles]`, `[Troubleshooting]`) están documentadas para futuro o uso organizacional, pero muchas claves NO tienen efecto en el código actual. Ver doc/INI_CONFIG_AUDIT.md para detalles.

## Confirmaciones — Modelo de Configuración

- Global
  - `configuration.ini` → `[Behavior]` → `show_confirmation_global=true` fuerza confirmación en todas las capas.
- Programs
  - `[Settings]` → `show_confirmation` (por defecto `false`).
  - Listas por tecla en `[ProgramMapping]` → `confirm_keys` / `no_confirm_keys`.
  - Si `show_confirmation=false` y `auto_launch=true` → lanzamiento inmediato (sin confirmar).
- Information
  - `[Settings]` → `show_confirmation` (por defecto `false`).
  - Listas por tecla en `[InfoMapping]` → `confirm_keys` / `no_confirm_keys`.
- Timestamps
  - `[Settings]` → `show_confirmation` (por defecto `false`).
  - `[CategorySettings]` → `<Friendly>_show_confirmation` para forzar confirmación por categoría (`Date`, `Time`, `DateTime`).
  - `[Confirmations.<Friendly>]` → `confirm_keys` / `no_confirm_keys` por submenú.
- Commands
  - `[Settings]` → `show_confirmation` (default de capa).
  - `[CategorySettings]` → `<Friendly>_show_confirmation` (categoría domina per-command si `true`).
  - `[Confirmations.<Friendly>]` → `confirm_keys` / `no_confirm_keys` por comando.

### Archivos de Capa Específicos

#### `programs.ini` – Configuración del Lanzador

```ini
[Settings]
timeout_seconds=7
show_confirmation=false
auto_launch=true

[ProgramMapping]
; confirm_keys: keys that MUST confirm (case-sensitive), e.g.: "d,z"
confirm_keys=
; no_confirm_keys: keys that MUST NOT confirm (optional)
; no_confirm_keys=
```

Developers — Confirmation configuration (Programs)

- Precedencia: Global → [ProgramMapping] lists → [Settings].show_confirmation → default false
- Función: `ShouldConfirmPrograms(key)`
- Ejemplo:

```ini
[Settings]
show_confirmation=false
[ProgramMapping]
confirm_keys=d,z
```

#### `timestamps.ini` – Configuración de formatos de fecha/hora

```ini
[Settings]
timeout_seconds=20
show_confirmation=true
; Otros flags documentados (auto_insert/preview_format/remember_last_format/feedback_duration)
; hoy no alteran el flujo de ejecución.
```

Developers — Confirmation configuration (Timestamps)

- Precedencia (mayor a menor):
  1. Global: `configuration.ini` → `[Behavior]` → `show_confirmation_global`
  2. Categoría: `timestamps.ini` → `[CategorySettings]` `<Friendly>_show_confirmation`
  3. Listas por comando: `timestamps.ini` → `[Confirmations.<Friendly>]` (`confirm_keys` / `no_confirm_keys`)
  4. Default de capa: `timestamps.ini` → `[Settings]` → `show_confirmation`
  5. Fallback: `false`
- Función: `ShouldConfirmTimestamp(mode, key)`

#### `commands.ini` – Configuración de Comandos

Ver también: `doc/COMMANDS_CUSTOM.md` para el esquema de Custom Commands (qué ejecutar) y CommandFlag (cómo ejecutar).


```ini
[Settings]
show_output=true
close_on_success=false
timeout_seconds=30
enable_custom_commands=true
show_confirmation=false

[CategorySettings]
; ... timeouts por categoría, feedback, etc. (parte planificada/no funcional en su mayoría)

[Confirmations.<Friendly>]
; Per-command confirmation (lists): confirm_keys / no_confirm_keys
```

Notas:
- UI (C# Tooltips) se construye desde `[Categories]` y secciones `[<key>_category]` (por ejemplo `s_category`, `n_category`, etc.).
- `[MenuDisplay]` quedó como legado para la capa de comandos.

Developers — Confirmation configuration (Commands)

- Precedencia (mayor a menor):
  1. Global: `configuration.ini` → `[Behavior]` → `show_confirmation_global`
  2. Categoría: `commands.ini` → `[CategorySettings]` `<Friendly>_show_confirmation`
     - `true`: fuerza confirmación para toda la categoría (no mira per-command)
     - `false`: delega a per-command
  3. Listas por comando: `commands.ini` → `[Confirmations.<Friendly>]`
     - `confirm_keys`: teclas que DEBEN confirmar (case-sensitive)
     - `no_confirm_keys`: lista opcional de teclas que NO deben confirmar
  4. Default de capa: `commands.ini` → `[Settings]` → `show_confirmation`
  5. Fallback: `power=true`, otros `false`
- Funciones:
  - `ShouldConfirmCommand(categoryInternal, key)`
  - Helpers: `ParseKeyList`, `KeyInList`

#### `information.ini` – Configuración de Información

```ini
[Settings]
timeout_seconds=10
show_confirmation=true
; auto_paste: si false, muestra detalles y requiere ENTER; si true, inserta directamente.

[Confirmations.Information]
; confirm_keys: keys that MUST confirm (case-sensitive), e.g.: "e,p"
confirm_keys=
; no_confirm_keys: keys that MUST NOT confirm (optional)
; no_confirm_keys=
```

Developers — Confirmation configuration (Information)

- Precedencia: Global → [InfoMapping] lists → [Settings].show_confirmation → default false
- Función: `ShouldConfirmInformation(key)`

## Personalización Avanzada

### Timeouts jerárquicos (InputHook)

El script utiliza `GetEffectiveTimeout(layer)` para calcular timeouts de forma consistente:

- Por capa (`*.ini` → `[Settings]` → `timeout_seconds`)
- Líder: `configuration.ini` → `[Behavior]` → `leader_timeout_seconds`
- Global: `configuration.ini` → `[Behavior]` → `global_timeout_seconds`
- Fallback por defecto: 10 segundos

Ejemplos de uso en código (simplificados):

```autohotkey
; Obtener timeout efectivo para distintos menús
ih := InputHook("L1 T" . GetEffectiveTimeout("programs"))
winIH := InputHook("L1 T" . GetEffectiveTimeout("windows"))

; Timestamps (submenús)
dateIH := InputHook("L1 T" . GetEffectiveTimeout("timestamps_date"))
```

### Tooltips (C#) configurables

Las notificaciones y menús en C# se controlan vía `[Tooltips]`. Ejemplo:

```ini
[Tooltips]
enable_csharp_tooltips=true
options_menu_timeout=10000
status_notification_timeout=2000
auto_hide_on_action=true
persistent_menus=false
tooltip_fade_animation=true
tooltip_click_through=true
```

## Funciones de configuración en el script (referencia)

- Confirmaciones por capa/categoría:
  - `ShouldConfirmPrograms(key)`
  - `ShouldConfirmInformation(key)`
  - `ShouldConfirmTimestamp(mode, key)`
  - `ShouldConfirmCommand(categoryInternal, key)`
  - `ShouldConfirmAction(layer)` — envoltura simple por capa (`programs`/`information`/`timestamps`/`power`)

- Helpers:
  - `ParseKeyList(s)`, `KeyInList(key, listStr)` — listas separadas por coma/espacio, case-sensitive.
  - `CleanIniBool(value, default)`, `CleanIniNumber(value)` — lectura segura de INI.
  - `LoadLayerFlags()` — carga banderas globales: `nvimLayerEnabled`, `excelLayerEnabled`, `modifierLayerEnabled`, `leaderLayerEnabled`, `enableLayerPersistence`.
  - `GetEffectiveTimeout(layer)` — jerarquía de timeouts descrita arriba.

Ejemplo práctico:

```autohotkey
; Confirmación global
if (CleanIniBool(IniRead(ConfigIni, "Behavior", "show_confirmation_global", "false"), false))
    ; forzar confirmación

; Flags de capa
LoadLayerFlags()
if (nvimLayerEnabled) {
    ; Activar navegación Nvim
}
```

## Solución de Problemas

- Configuración no se aplica
  1. Verifica la sintaxis del archivo `.ini`
  2. Asegúrate de que la sección existe: `[Settings]`
  3. Usa Reload Script (leader → c → h → R) para aplicar cambios

- Valores no válidos
  1. Usa solo números para timeouts y duraciones
  2. Usa `true`/`false` para valores booleanos
  3. Evita comillas en los valores a menos que sean rutas con espacios

- Archivo de configuración faltante
  1. El script creará archivos por defecto si no existen
  2. Copia los ejemplos de la documentación
  3. Verifica permisos de escritura en el directorio
