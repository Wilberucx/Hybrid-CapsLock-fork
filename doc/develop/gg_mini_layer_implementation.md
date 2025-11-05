# Implementación de gg (ir al top) con mini-capa en NVIM Layer

Fecha: 2025-10-14
Componente: `src/layer/nvim_layer.ahk`

## Contexto
En la capa NVIM existen movimientos de línea (`0` → Home, `+4` → End) y navegación tipo Vim. Se quería añadir:
- `gg`: ir al inicio del documento (Ctrl+Home)
- `G` (Shift+g): ir al final del documento (Ctrl+End)

Además, en `VisualMode` estos movimientos deben extender la selección (añadiendo Shift al envío de teclas).

## Problema observado
- `G` funcionaba correctamente (final del documento).
- `gg` no funcionaba de forma fiable. Usar un único hotkey `g` esperando un segundo `g` con `InputHook` no capturaba bien la segunda pulsación.

## Síntomas
- Tras pulsar `g`, el segundo `g` no disparaba la acción esperada.
- Parecía que el primer hotkey `g` interceptaba la segunda pulsación o que el contexto del hotkey no cambiaba a tiempo.

## Causa raíz
1) Falta de una "mini-capa" temporal dedicada a la secuencia `g…`, similar a la lógica ya existente para `:` (colon): el segundo `g` debe capturarse bajo otra condición `#HotIf` que esté activa solo durante una ventana corta.
2) Desajuste de unidades en `SetTimer`:
   - `GetEffectiveTimeout("nvim")` devuelve segundos.
   - `SetTimer` con valores negativos espera milisegundos (ms).
   - Estábamos pasando segundos directamente, provocando que el timeout fuera casi inmediato y la mini-capa se cancelara antes de poder pulsar el segundo `g`.

## Solución
- Implementar una mini-capa temporal `GLogicActive` activada con la primera `g`.
- Aislar los hotkeys con `#HotIf` para que el primer `g` no se re-dispare cuando la mini-capa esté activa y el segundo `g` se capture en un bloque distinto.
- Corregir el `SetTimer` multiplicando el timeout por 1000 (segundos → milisegundos).
- Centralizar el envío en `NvimGoToDocEdge(goTop)` respetando `VisualMode`.

## Cambios clave en `src/layer/nvim_layer.ahk`

1) Estado global de la mini-capa:
```ahk
; Estado para mini-capa de 'g'
global GLogicActive := false
```

2) Hotkeys condicionados (fragmento):
```ahk
; Cuando NO está activa la mini-capa, permitir iniciar con 'g' y mantener 'G'
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && !GetKeyState("CapsLock","P") && NvimLayerAppAllowed() && !GLogicActive) : false)
 g::GLogicStart()
 +g::NvimGoToDocEdge(false) ; G → bottom
#HotIf

; Mientras la mini-capa 'g' está activa, capturar el segundo 'g' y Esc
#HotIf (nvimStaticEnabled ? (isNvimLayerActive && GLogicActive && !GetKeyState("CapsLock","P") && NvimLayerAppAllowed()) : false)
 *g::GLogicHandleG()       ; gg → top
 *Esc::GLogicCancel()      ; cancelar
#HotIf
```

3) Lógica de la mini-capa:
```ahk
GLogicStart() {
    global GLogicActive
    GLogicActive := true
    to := GetEffectiveTimeout("nvim")
    ; GetEffectiveTimeout devuelve segundos; SetTimer negativo pide ms
    try SetTimer(GLogicTimeout, -to*1000)
}

GLogicHandleG() {
    GLogicCancel()
    NvimGoToDocEdge(true) ; top
}

GLogicCancel() {
    global GLogicActive
    GLogicActive := false
}

GLogicTimeout() {
    GLogicCancel()
}
```

4) Función de navegación a borde de documento (ya presente y/o añadida):
```ahk
NvimGoToDocEdge(goTop := true) {
    global VisualMode
    mods := "^" ; Ctrl para inicio/fin de documento
    if (VisualMode)
        mods .= "+" ; Shift para extender selección
    Send(mods . "{" . (goTop ? "Home" : "End") . "}")
}
```

5) Tooltip de ayuda actualizado (si aplica) para incluir `gg/G top/bottom`.

## Pruebas
- Modo normal:
  - `gg` mueve el cursor al inicio del documento.
  - `G` mueve el cursor al final del documento.
- Modo visual (`v` antes):
  - `gg` extiende la selección al inicio del documento.
  - `G` extiende la selección al final del documento.
- Cancelación:
  - `g` seguido de `Esc` cancela sin efecto.

## Consideraciones
- Esta aproximación sigue el patrón ya utilizado para `:` en la capa NVIM, manteniendo consistencia y evitando conflictos con otros hotkeys.
- Si se agregan más prefijos `g…` en el futuro, puede ampliarse el bloque de mini-capa para contemplar otras combinaciones (`gw`, `ge`, etc.).

## Futuras mejoras
- Hacer el timeout de `gg` configurable vía `configuration.ini` o `nvim_layer.ini`.
- Mostrar un tooltip breve cuando la mini-capa esté activa para mejorar la percepción de estado.
- Añadir pruebas manuales en `doc/MANUAL_TESTS.md` para `gg/G`.

## Resultado
Con estos cambios, `gg` y `G` se comportan de forma alineada con Vim:
- `gg` → top del documento
- `G` → bottom del documento
- Respetan `VisualMode` añadiendo Shift para extender selección.
