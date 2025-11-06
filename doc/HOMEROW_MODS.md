# 🏠 Homerow Mods - Guía Completa

Los **Homerow Mods** son una de las características más potentes de la integración con Kanata. Transforman las teclas de la home row (la fila central donde reposan tus dedos) en modificadores cuando las mantienes presionadas, eliminando la necesidad de extender las manos hacia Ctrl, Alt, Win o Shift.

## 🎯 ¿Qué son los Homerow Mods?

**Homerow Mods** = Modificadores en la fila de inicio (home row)

Cada tecla tiene **dos funciones**:

- **Tap (pulsación rápida)**: Envía la letra normal (a, s, d, f, j, k, l, ;)
- **Hold (mantener presionada)**: Actúa como modificador (Ctrl, Alt, Win, Shift)

Esto es manejado por **Kanata a nivel de driver** con timing perfecto (<10ms), sin falsos positivos.

## ⌨️ Mapa de Homerow Mods

### Mano Izquierda (Modificadores principales)

```
┌─────┬─────┬─────┬─────┬─────┐
│  A  │  S  │  D  │  F  │  G  │
│Ctrl │ Alt │ Win │Shift│     │
└─────┴─────┴─────┴─────┴─────┘
```

| Tecla | Tap | Hold      | Uso común                                     |
| ----- | --- | --------- | --------------------------------------------- |
| **A** | a   | **Ctrl**  | Copiar, Pegar, Guardar, Atajos de navegador   |
| **S** | s   | **Alt**   | Alt+Tab, Alt+F4, Menús de aplicación          |
| **D** | d   | **Win**   | Win+D (escritorio), Win+número (apps taskbar) |
| **F** | f   | **Shift** | Mayúsculas, Seleccionar texto con flechas     |

### Mano Derecha (Modificadores simétricos)

```
┌─────┬─────┬─────┬─────┬─────┐
│  H  │  J  │  K  │  L  │  ;  │
│     │Shift│ Win │ Alt │Ctrl │
└─────┴─────┴─────┴─────┴─────┘
```

| Tecla | Tap | Hold      | Uso común                             |
| ----- | --- | --------- | ------------------------------------- |
| **J** | j   | **Shift** | Mayúsculas, Shift+Enter (línea nueva) |
| **K** | k   | **Win**   | Atajos de Windows con mano derecha    |
| **L** | l   | **Alt**   | Alt+Tab, Alt+F4 con mano derecha      |
| **;** | ;   | **Ctrl**  | Ctrl+C, Ctrl+V con mano derecha       |

> **Nota de diseño**: La mano derecha tiene timing ajustado (tap-hold-press 350 150) para priorizar el tap, evitando conflictos con navegación Vim (hjkl).

## 💡 Ejemplos de Uso

### Copiar y Pegar sin salir de la home row

```
Antes: Ctrl físico + C, Ctrl físico + V
Ahora: Hold A + C, Hold A + V
      (o bien: Hold ; + C, Hold ; + V)
```

### Cerrar ventana

```
Antes: Alt físico + F4
Ahora: Hold S + F4
      (o bien: Hold L + F4)
```

### Guardar archivo

```
Antes: Ctrl físico + S
Ahora: Hold A + S
```

### Cambiar de aplicación

```
Antes: Alt físico + Tab
Ahora: Hold S + Tab
      (o bien: Hold L + Tab)
```

### Minimizar todas las ventanas (mostrar escritorio)

```
Antes: Win físico + D
Ahora: Hold D + D
      (o bien: Hold K + D)
```

### Abrir app desde taskbar

```
Antes: Win físico + 1 (abre primera app del taskbar)
Ahora: Hold D + 1
      (o bien: Hold K + 1)
```

### Seleccionar texto con flechas

```
Antes: Shift físico + flechas
Ahora: Hold F + flechas (mano izquierda)
      (o bien: Hold J + flechas, mano derecha)
```

## 🎓 Tips para Dominar Homerow Mods

### 1. **Empieza con lo básico**

Practica primero los modificadores más comunes:

- **A (Ctrl)**: Hold A + C (copiar), Hold A + V (pegar), Hold A + S (guardar)
- **S (Alt)**: Hold S + Tab (cambiar ventana), Hold S + F4 (cerrar)

### 2. **Usa la mano opuesta cuando sea posible**

Para evitar "chord" incómodo (presionar dos teclas con la misma mano):

- ✅ Bueno: Hold A (mano izq) + V (mano izq) → Funciona, pero...
- ✅ Mejor: Hold ; (mano der) + V (mano izq) → Más cómodo y simétrico

### 3. **Combina con Nvim Layer**

Los homerow mods funcionan **fuera de Nvim Layer** pero **NO dentro** de Nvim Layer activo (para evitar conflictos con hjkl):

- ✅ Nvim Layer OFF: Hold A + hjkl = Ctrl+flechas (navegar por palabras)
- ❌ Nvim Layer ON: Hold A no funciona (hjkl son flechas puras)

### 4. **Timing ajustado por Kanata**

- **Mano izquierda (A/S/D/F)**: tap-hold 200 200 (balanceado)
- **Mano derecha (J/K/L/;)**: tap-hold-press 350 150 (prioridad tap para Vim)

Si sientes que se activan por error:

1. Ajusta los valores en `kanata.kbd`:

   ```lisp
   ;; Ejemplo: aumentar el tiempo de hold a 250ms
   a (tap-hold 250 250 a lctl)
   ```

2. Recarga el sistema: **Leader → c → h → R** (Reload Script completo) o **Leader → c → h → k** (Restart Kanata solamente)

# 🚫 Limitaciones Conocidas

### 1. **No funcionan dentro de Nvim Layer**

Cuando **Nvim Layer está activo** (tap CapsLock para activarlo), los homerow mods se desactivan para que hjkl funcionen como navegación pura. Esto es intencional.

**Solución**:

- Si necesitas Ctrl+hjkl dentro de Nvim Layer, usa los modificadores físicos del teclado
- O sal temporalmente de Nvim Layer (vuelve a tap CapsLock)

### 2. **Conflictos con aplicaciones que usan teclas de modificación rápida**

Algunos juegos o software especializado pueden detectar mal el hold.

**Solución**:

- Usa blacklist en Nvim Layer para excluir esas apps
- O presiona los modificadores físicos del teclado en esas situaciones

### 3. **Timing de aprendizaje**

Al principio puede sentirse antinatural. Dale **1-2 semanas de práctica constante** para desarrollar la memoria muscular.

## 🔧 Configuración Avanzada

### Cambiar el timing de tap-hold

Edita `kanata.kbd`:

```lisp
;; Formato: (tap-hold tap-timeout hold-timeout tap-action hold-action)
;; tap-timeout: milisegundos para considerar "tap"
;; hold-timeout: milisegundos para considerar "hold"

;; Ejemplo: Hacer F más sensible (menos tiempo para activar Shift)
f (tap-hold 150 150 f lsft)

;; Ejemplo: Hacer J menos sensible (más tiempo para evitar activaciones falsas)
j (tap-hold-press 400 200 j lsft)
```

Después de editar, recarga el sistema usando el Leader menu:

1. **Hold CapsLock + Space** (abrir Leader)
2. Presiona **c** (Commands)
3. Presiona **h** (Hybrid Management)
4. Presiona **R** (Reload Script - recarga AHK + Kanata) o **k** (Restart Kanata solamente)

### Desactivar homerow mods específicos

Si no quieres usar alguna tecla como modificador, edita `kanata.kbd`:

```lisp
;; Desactivar "D" como Win (solo dejar como letra normal)
d d  ; en lugar de: d (tap-hold 200 200 d lmet)
```

### Agregar más homerow mods

Kanata permite extender el concepto a otras teclas. Ejemplo:

```lisp
;; Agregar "G" como Ctrl derecho
g (tap-hold 200 200 g rctl)

;; Agregar "H" como Shift
h (tap-hold 200 200 h lsft)
```

## 📊 Comparación: Antes vs Después

| Acción      | Sin Homerow Mods       | Con Homerow Mods | Ventaja                     |
| ----------- | ---------------------- | ---------------- | --------------------------- |
| Copiar      | Ctrl físico + C        | Hold A + C       | ✅ Manos en home row        |
| Alt+Tab     | Alt físico + Tab       | Hold S + Tab     | ✅ 0 movimiento de dedos    |
| Guardar     | Ctrl físico + S        | Hold A + S       | ✅ Más ergonómico           |
| Cerrar      | Alt físico + F4        | Hold S + F4      | ✅ Menos tensión en meñique |
| Seleccionar | Shift físico + flechas | Hold F + flechas | ✅ Ambas manos centradas    |

## 🎬 Flujo de Trabajo Recomendado

### Para Programadores

```
1. Hold A + S (Ctrl+S) → Guardar archivo
2. Hold A + T (Ctrl+T) → Nueva pestaña en IDE
3. Hold A + P (Ctrl+P) → Comando de búsqueda rápida
4. Hold S + Tab → Cambiar entre ventanas de código
```

### Para Escritores/Editores

```
1. Hold F + flechas → Seleccionar texto sin salir de home row
2. Hold A + C/V → Copiar y pegar fragmentos
3. Hold A + Z → Deshacer cambios rápidamente
4. Nvim Layer ON (tap CapsLock) → Navegación Vim-style
```

### Para Uso General

```
1. Hold S + F4 → Cerrar ventanas rápidamente
2. Hold D + D → Mostrar escritorio
3. Hold A + flechas → Navegar por documentos
4. Hold S + Tab → Cambiar apps con Alt+Tab
```

## 🔗 Ver También

- **[Nvim Layer](NVIM_LAYER.md)**: Navegación persistente estilo Vim
- **[Modo Líder](LEADER_MODE.md)**: Menús contextuales avanzados
- **[Kanata Configuration](../kanata.kbd)**: Archivo de configuración de Kanata
- **[Configuración General](CONFIGURATION.md)**: Opciones globales del sistema
