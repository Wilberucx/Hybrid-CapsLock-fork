# 🔢🎵 Capas Numpad y Media (Kanata)

Estas son **capas puras de Kanata** (sin lógica de AutoHotkey) que se activan manteniendo presionadas teclas específicas. Proporcionan acceso instantáneo a teclado numérico y controles multimedia sin salir de la home row.

---

## 🔢 Numpad Layer (Hold O)

### Activación
**Hold O** → Activa el teclado numérico en la mano izquierda

Mientras mantienes presionado `O`, las teclas de la mano izquierda se transforman en un numpad completo.

### Mapa del Teclado Numérico

```
┌─────┬─────┬─────┬─────┬─────┬─────┐
│     │  4  │  5  │  6  │ Bsp │ Del │ → Fila superior (números básicos)
├─────┼─────┼─────┼─────┼─────┼─────┤
│     │  7  │  8  │  9  │  +  │  =  │ → Home row (números altos)
├─────┼─────┼─────┼─────┼─────┼─────┤
│     │  /  │  0  │  .  │  -  │     │ → Fila inferior (operadores)
└─────┴─────┴─────┴─────┴─────┴─────┘
```

### Distribución Detallada

| Posición | Tecla Base | Con Hold O | Descripción |
|----------|-----------|------------|-------------|
| Q | q | **4** | Número 4 |
| W | w | **5** | Número 5 |
| E | e | **6** | Número 6 |
| R | r | **Backspace** | Borrar hacia atrás |
| T (aprox) | t | **Del** | Eliminar (Delete) |
| A | a | **7** | Número 7 |
| S | s | **8** | Número 8 |
| D | d | **9** | Número 9 |
| F | f | **+** | Suma |
| G | g | **=** | Igual |
| Z | z | **/** | División |
| X | x | **0** | Número 0 |
| C | c | **.** | Punto decimal |
| V | v | **-** | Resta/Menos |

### Funciones Especiales
- **U**: F2 (Editar celda en Excel)

### Ejemplos de Uso

#### Calculadora Rápida
```
Hold O + 7 → 7
Hold O + + → +
Hold O + 8 → 8
Hold O + = → =
Resultado: 7+8= en una sola posición de mano
```

#### Entrada de Números en Excel
```
1. Selecciona celda
2. Hold O + 4 5 6 → Escribe "456"
3. Hold O + Tab → Siguiente celda (si configurado)
```

#### Operaciones Matemáticas
```
Hold O + 9 → 9
Hold O + / → /
Hold O + 3 (Hold O + W, X, C combo) → 3
Hold O + = → =
Resultado: 9/3=
```

---

## 🎵 Media Layer (Hold E)

### Activación
**Hold E** → Activa controles multimedia en la home row derecha

Mientras mantienes presionado `E`, las teclas `hjkl;` se convierten en controles de reproducción y volumen.

### Mapa de Controles

```
┌─────┬─────┬─────┬─────┬─────┐
│  H  │  J  │  K  │  L  │  ;  │
│Vol+ │Prev │Play │Next │     │
└─────┴─────┴─────┴─────┴─────┘

┌─────┬─────┬─────┬─────┬─────┐
│  N  │  M  │  ,  │  .  │  /  │
│Vol- │Mute │     │     │     │
└─────┴─────┴─────┴─────┴─────┘
```

### Distribución Detallada

| Posición | Tecla Base | Con Hold E | Descripción |
|----------|-----------|------------|-------------|
| **H** | h | **Volume Up** | Subir volumen |
| **J** | j | **Previous Track** | Canción anterior |
| **K** | k | **Play/Pause** | Reproducir/Pausar |
| **L** | l | **Next Track** | Siguiente canción |
| **N** | n | **Volume Down** | Bajar volumen |
| **M** | m | **Mute** | Silenciar/Desilenciar |

### Ejemplos de Uso

#### Control de Spotify/YouTube
```
Hold E + K → Play/Pause
Hold E + L → Siguiente canción
Hold E + J → Canción anterior
Hold E + H (mantener) → Subir volumen gradualmente
```

#### Ajuste Rápido de Volumen
```
Hold E + H H H → Subir volumen 3 pasos
Hold E + N N → Bajar volumen 2 pasos
Hold E + M → Mute/Unmute
```

#### Uso en Presentaciones
```
1. Hold E + K → Pausar video
2. [Explica el punto]
3. Hold E + K → Reanudar
```

---

## 🎯 Ventajas de estas Capas

### Por qué son 100% Kanata

1. **Timing perfecto**: Detección hardware-level sin delay
2. **Cero dependencias**: No necesitan lógica de AutoHotkey
3. **Funciona en cualquier app**: Incluso en pantallas de login o fullscreen
4. **Bajo overhead**: No consumen recursos de AHK

### Comparación con Capas AHK

| Aspecto | Capas Kanata (Numpad/Media) | Capas AHK (Nvim/Leader) |
|---------|----------------------------|-------------------------|
| **Activación** | Hold físico de tecla | Toggle persistente (F23) |
| **Timing** | <10ms (driver-level) | ~50-100ms (software) |
| **Context-aware** | ❌ No (universales) | ✅ Sí (por app) |
| **Complejidad** | ⭐ Simple (tecla=acción) | ⭐⭐⭐ Compleja (menús, lógica) |
| **Edición** | Editar `kanata.kbd` | Editar archivos `.ahk` + `.ini` |

---

## 🔧 Personalización

### Modificar la Capa Numpad

Edita `kanata.kbd`, busca la sección `(deflayer numpad)`:

```lisp
;; Ejemplo: Cambiar Q de "4" a "*" (multiplicación)
(deflayer numpad
  _    *    5    6    bspc _    _    _    f2   _    _    _    _    _
  _    7    8    9    +    =    _    _    _    _    _    _    _
  _    /    0    .    -    _    _    _    _    _    _    _
  _    _    _              _              _    _    _
)
```

### Modificar la Capa Media

Edita `kanata.kbd`, busca la sección `(deflayer media)`:

```lisp
;; Ejemplo: Agregar controles adicionales
(deflayer media
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    volu prev pp  next  _    _    _
  _    _    _    _    _    _    vold mute brdn brup  _    _
  ;; Agregué: brdn (brightness down), brup (brightness up)
  _    _    _              _              _    _    _
)
```

### Agregar Nuevas Capas Similares

Puedes crear tu propia capa hold en Kanata:

```lisp
;; 1. Define el alias para activar la capa
(defalias
  mycapa (tap-hold 200 200 p (layer-while-held mycapa))
)

;; 2. Usa el alias en la capa base
(deflayer base
  ...
  _    _    _    _    _    _    _    _    _    @mycapa   _    _    _    _
  ;; Ahora Hold P activa "mycapa"
  ...
)

;; 3. Define tu nueva capa
(deflayer mycapa
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _              _              _    _    _
)
```

---

## 🖱️ Mouse Clicks (Bonus)

Kanata también define clicks de mouse con tap-hold en las teclas **N, M, B**:

| Tecla | Tap | Hold | Uso |
|-------|-----|------|-----|
| **N** | n | **Left Click** | Click izquierdo |
| **M** | m | **Right Click** | Click derecho |
| **B** | b | **Middle Click** | Click central/rueda |

### Ejemplos
```
Hold N → Click izquierdo (útil para hacer clic sin usar el mouse)
Hold M → Click derecho (abrir menú contextual)
Hold B → Click central (abrir link en nueva pestaña)
```

> **Nota**: Estos clicks **NO tienen conflicto** con `scroll_layer.ahk` porque:
> - Mouse clicks son **hold** (Kanata detecta mantener presionado)
> - Scroll layer es **toggle persistente** (activado por Leader menu)
> - Diferentes contextos de activación = sin colisión

---

## 🚫 Limitaciones

### 1. No son context-aware
Las capas Numpad y Media son universales (funcionan en todas las apps por igual). No pueden adaptarse según la aplicación activa como lo hacen las capas de AHK.

### 2. No tienen tooltips visuales
A diferencia de Nvim Layer o Leader Mode, estas capas no muestran menús en pantalla porque son puras de Kanata.

**Solución**: Imprime un cheatsheet físico o guárdalo como fondo de pantalla.

### 3. Requieren recargar Kanata para cambios
Después de editar `kanata.kbd`, usa el Leader menu para recargar:
- **Leader → c → h → R**: Reload completo (AHK + Kanata)
- **Leader → c → h → k**: Restart Kanata solamente

Atajo: Hold CapsLock + Space → c → h → R (o k)

---

## 🎓 Tips de Uso

### 1. Combina con otras capas
```
Hold O (numpad) + Homerow Mod A (Ctrl)
→ Ctrl+números (útil para cambiar tabs en navegadores)

Hold E (media) + CapsLock hold (vim-nav hjkl)
→ No recomendado (usa solo una capa a la vez)
```

### 2. Practica la posición de dedos
```
Numpad: Mano izquierda en QWER-ASDF-ZXCV
Media: Mano derecha en HJKL con E hold por mano izquierda
```

### 3. Úsalas fuera de Nvim Layer
Estas capas funcionan mejor cuando **Nvim Layer está desactivado** para evitar confusión con navegación hjkl.

---

## 🔗 Ver También

- **[Homerow Mods](HOMEROW_MODS.md)**: Modificadores en la home row
- **[Configuración de Kanata](../kanata.kbd)**: Archivo de configuración completo
- **[Nvim Layer](NVIM_LAYER.md)**: Navegación persistente estilo Vim
- **[Documentación de Kanata](https://github.com/jtroo/kanata/blob/main/docs/config.adoc)**: Referencia oficial
