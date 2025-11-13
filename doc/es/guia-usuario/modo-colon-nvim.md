# Implementación de comandos tipo “:w/:q/:wq” con modo lógico temporal en NVIM Layer

Este sistema está deprecado con planes de refactorización para futura implementación dentro del sistema declaritivo de keymaps.

## Resumen

- Objetivo: Reemplazar un mecanismo previo de hotstrings (:w, :q, :wq) por un modo lógico temporal activado con “:”.
- Resultado: Se implementó un flujo por etapas que captura w/q/Enter bajo un gating con `#HotIf`, mostrando un tooltip nativo persistente tipo lista, y resolviendo conflictos de prioridad de hotkeys (w/q) usando `InputLevel` y wildcard keys.

## Problema original

- El mecanismo basado en hotstrings (:w, :q, :wq) resultó conflictivo: interfería con el layer NVIM y requería Enter para ejecución con estado pendiente que no era robusto.
- Shift+; (:) escribía el carácter “:” en lugar de activar el modo.
- El tooltip desaparecía demasiado rápido, y la UX no era clara.
- Conflictos con mapeos existentes de `w` y `q` en NVIM layer (prioridad de hotkeys en AHK).

## Requisitos/constraints

- Activación con “:” (Shift+;) sin insertar “:”.
- Flujo por etapas:
  - Al entrar: espera `w` o `q`.
  - Si `w`: espera `q` o `Enter`.
  - Si `q`: espera `Enter`.
  - Si `w→q`: espera `Enter`.
  - `Enter` ejecuta: `w=Ctrl+S`, `q=Alt+F4`, `wq=guardar+luego cerrar`.
  - `Esc` cancela.
- Tooltip nativo persistente y tipo lista, para reforzar la UX.
- Sin crear un “modo global” nuevo: solo lógica temporal bajo el layer.

## Diseño de la solución

### Entrada robusta a “:”

- Se intercepta la tecla OEM_1 usando `SC027` y `vkBA`.
- `ColonMaybeStart()`:
  - Si `Shift` está físicamente presionado, inicia el modo y bloquea “:”
  - Si no, envía `;` literal (no rompe escritura normal).

### Modo lógico temporal

- Variables: `ColonLogicActive` (bool), `ColonStage` ("", "w", "q", "wq").
- `#HotIf … ColonLogicActive …` para capturar `w`, `q`, `Enter`, `Esc` con wildcard y prioridad.
- Tooltip fijo tipo lista, persistente hasta `Enter`/`Esc`.

### Priorización de hotkeys

- Uso de wildcard (`*w`, `*q`, `*Enter`, `*Esc`).
- `#InputLevel` elevado para el bloque del modo, asegurando prioridad sobre mapeos base.
- Se eliminó el mapeo `q::` en NVIM layer para evitar conflictos residuales.

### Ejecución

- `Enter` despacha según `ColonStage`:
  - `w`: `Ctrl+S`
  - `q`: `Alt+F4`
  - `wq`: `Ctrl+S`, pausa breve, `Alt+F4`

## Implementación (archivos y puntos clave)

- Archivo: `src/layer/nvim_layer.ahk`
- Entrada “:”:
  - Se reemplazó `+;` por detección de OEM_1:
    - `*SC027` / `*vkBA` → `ColonMaybeStart()`
- Estado del modo:
  - `ColonLogicActive` / `ColonStage`
  - `ColonLogicStart()`, `ColonLogicCancel()`
- Manejadores:
  - `ColonLogicHandleW()`: "",w→"w"; w→"wq"; q→"q"
  - `ColonLogicHandleQ()`: "",q→"q"; w→"wq"; q→"q"
  - `ColonLogicEnter()`: ejecuta según stage, luego cancela
- Gating y prioridad:
  - `#HotIf isNvimLayerActive && ColonLogicActive …`
  - `*w`, `*q`, `*Enter`, `*Esc`
  - `#InputLevel` elevado en el bloque del modo (y restablecido después)
- Limpieza del mecanismo anterior:
  - Removidos hotstrings `:w`, `:q`, `:wq` y `NvimPendingCmd`.
  - Eliminadas funciones y variables antiguas (ColonMode/Colon\* anteriores).
  - Eliminado mapeo `q::` de NVIM layer para evitar conflictos.

## UX y comportamiento final

- Shift+; inicia el modo, no imprime “:”.
- Tooltip persistente tipo lista:

```
Cmd:
  :w  (Enter)
  :q  (Enter)
  :wq (Enter)
```

- Secuencias:
  - `:` `w` `Enter` → guardar
  - `:` `q` `Enter` → cerrar
  - `:` `w` `q` `Enter` → guardar y cerrar
  - `Esc` → cancelar

## Pruebas realizadas

- Casos básicos:
  - `:` → `w` → `Enter` → Guardado
  - `:` → `q` → `Enter` → Cierre
  - `:` → `w` → `q` → `Enter` → Guardado + Cierre
  - `:` → `Esc` → Cancelado
- Robustez:
  - Presionar `w` dos veces: `"w"→"wq"` (solo espera Enter).
  - Entrar `q` primero: permanece en `"q"` (espera Enter).
  - Otros mapeos NVIM no interfieren (gating e `InputLevel`).
  - Diferentes layouts: OEM_1 gatea correctamente “:” vs “;”.

## Lecciones aprendidas

- La prioridad de hotkeys en AHK favorece hotkeys “exactos” sobre wildcard; `InputLevel` y el orden de `#HotIf` son críticos.
- Evitar escribir el carácter “:” interceptando por scancode/virtual key es más robusto que confiar en `+;`.
- Un tooltip persistente mejora la percepción de modo temporal.
- Mantener la lógica encapsulada en “capas internas” evita efectos colaterales y simplifica el reasoning.

## Posibles mejoras futuras

- Soporte global del modo “:” (fuera de NVIM layer) configurable.
- Configurar timing de la pausa entre guardar y cerrar.
- Preferencias para el texto/estilo del tooltip.
- Logs opcionales (`OutputDebug`) para depuración en campo.
