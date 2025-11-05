# Capa Excel/Accounting (leader → n)

> Referencia rápida
> - Confirmaciones: no aplica (acciones inmediatas)
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

La Capa Excel es una capa persistente especializada para trabajo con hojas de cálculo y aplicaciones contables. Combina un numpad completo con navegación optimizada y atajos específicos de Excel para máxima productividad.

## 🎯 Activación

**Combinación:** `leader` → `n`

Al activar la capa Excel, aparece una notificación visual confirmando que está activa. La capa permanece activa hasta que se desactive manualmente (`Shift+n`).

## 🔢 Distribución de la Capa Excel

La capa Excel está organizada en tres secciones principales para máxima eficiencia:

### 📊 Sección Numpad

```
Teclas físicas:    Función numpad:
1  2  3           →    1  2  3
q  w  e           →    4  5  6
a  s  d           →    7  8  9
   x              →       0
,  .              →    ,  .
8  9  ;  /        →    *  () -  ÷
```

### 🧭 Sección Navegación

```
Teclas físicas:    Función navegación:
   k              →       ↑
h  j  l           →    ←  ↓  →
```

### 📈 Sección Excel

```
Funciones especializadas para hojas de cálculo
i, f, u, r, g, m, y, p, c, v (minicapas), etc.
```

### 📊 Mapa Completo de Teclas

#### 🔢 Sección Numpad

| Tecla Física | Función Numpad | Descripción |
| ------------ | -------------- | ----------- |
| `1`          | Numpad 1       | Número 1    |
| `2`          | Numpad 2       | Número 2    |
| `3`          | Numpad 3       | Número 3    |
| `q`          | Numpad 4       | Número 4    |
| `w`          | Numpad 5       | Número 5    |
| `e`          | Numpad 6       | Número 6    |
| `a`          | Numpad 7       | Número 7    |
| `s`          | Numpad 8       | Número 8    |
| `d`          | Numpad 9       | Número 9    |
| `x`          | Numpad 0       | Número 0    |

#### 🔣 Símbolos y Operaciones

| Tecla Física       | Función      | Descripción         |
| ------------------ | ------------ | ------------------- |
| `,` (coma)         | , (coma)     | Coma (sin mapeo)    |
| `.` (punto)        | Numpad Dot   | Punto decimal       |
| `8`                | *            | Multiplicación      |
| `9`                | ()           | Paréntesis (función)|
| `;` (punto y coma) | Numpad -     | Resta               |
| `/` (barra)        | Numpad /     | División            |

#### 🧭 Navegación

| Tecla Física | Función     | Descripción               |
| ------------ | ----------- | ------------------------- |
| `h`          | ←           | Flecha izquierda (Vim)    |
| `j`          | ↓           | Flecha abajo (Vim)        |
| `k`          | ↑           | Flecha arriba (Vim)       |
| `l`          | →           | Flecha derecha (Vim)      |
| `[`          | Shift + Tab | Navegación hacia atrás    |
| `]`          | Tab         | Navegación hacia adelante |

#### 📈 Funciones Excel

| Tecla Física | Función         | Descripción                    |
| ------------ | --------------- | ------------------------------ |
| `i`          | F2              | Editar celda                   |
| `I`          | F2 + Exit       | Editar celda y salir de capa   |
| `f`          | Ctrl + F        | Buscar                         |
| `u`          | Ctrl + Z        | Deshacer (Undo)                |
| `r`          | Ctrl + Y        | Rehacer (Redo)                 |
| `g`          | Ctrl + Home     | Ir al inicio de la hoja        |
| `G`          | Ctrl + End      | Ir al final de datos           |
| `m`          | Ctrl + G        | Ir a celda específica          |
| `y`          | Ctrl + C        | Copiar (Yank)                  |
| `p`          | Ctrl + V        | Pegar                          |
| `o`          | Enter           | Confirmar/Bajar celda          |
| `O`          | Shift + Enter   | Subir celda                    |

#### 🎯 Funciones de Selección Avanzadas (Minicapas)

La tecla `v` activa una **mini-capa temporal** (V Logic) que permite acceder a comandos de selección sin ocupar teclas individuales. La mini-capa permanece activa ~3 segundos (configurable) esperando el siguiente comando.

| Comando | Función                  | Descripción                           |
| ------- | ------------------------ | ------------------------------------- |
| `vr`    | Shift + Space           | Seleccionar fila completa             |
| `vc`    | Ctrl + Space            | Seleccionar columna completa           |
| `vv`    | Modo selección visual   | hjkl con Shift+flechas para seleccionar múltiples celdas, Esc/Enter para salir|

**Cómo usar:**
1. Presiona `v` → Se activa V Logic (mini-capa temporal)
2. Presiona `r`, `c` o `v` → Ejecuta la acción y sale de la mini-capa
3. Si no presionas nada en ~3s, la mini-capa se cancela automáticamente

**Nota técnica:** Esta mini-capa usa InputLevel 2 para tener prioridad sobre los hotkeys normales de Excel. Ver [implementación técnica](develop/excel_v_logic_mini_layer.md) para detalles.

*Nota: Enter y Space mantienen su comportamiento normal*

#### 🚪 Control de Capa

| Tecla Física | Función         | Descripción            |
| ------------ | --------------- | ---------------------- |
| `Shift+n`    | Desactivar capa | Salir de la capa Excel |

## 💡 Casos de Uso

### 📊 Trabajo con Excel/Hojas de Cálculo

Optimizado específicamente para Excel, Google Sheets, LibreOffice Calc y otras aplicaciones de hojas de cálculo.

### 💰 Contabilidad y Finanzas

Perfecto para contadores, analistas financieros y profesionales que trabajan con números constantemente.

### 📈 Análisis de Datos

Ideal para científicos de datos, analistas y cualquiera que necesite navegar y manipular grandes conjuntos de datos.

### 📱 Laptops sin Numpad

Solución completa para usuarios de laptops que no tienen teclado numérico físico pero necesitan productividad de escritorio.

### 🏢 Trabajo de Oficina

Excelente para cualquier trabajo que involucre entrada intensiva de datos, reportes financieros o análisis numérico.

## 🔧 Características Especiales

### 🔄 Modo Persistente

- La capa permanece activa hasta que se desactive manualmente
- No interfiere con otras capas del sistema
- Se puede usar junto con modificadores como Ctrl, Alt, etc.

### 📱 Feedback Visual

- Notificación al activar/desactivar la capa
- Indicador visual claro del estado actual

### ⚡ Ergonomía

- Distribución intuitiva que respeta la posición natural de los dedos
- Acceso rápido a todas las funciones numéricas sin mover las manos

## 🎮 Navegación y Control

### Activación

```
leader → Menú Principal
       ↓
   Presionar 'n'
       ↓
   Capa Excel Activa
```

### Desactivación

- **`Esc`** - Desactiva la capa Excel inmediatamente
- **`Leader + n`** - Alterna el estado (activa/desactiva)

## 💡 Consejos de Uso

### 🎯 Memoria Muscular

- La distribución numpad sigue un orden natural de arriba hacia abajo (1-9)
- Las teclas `1`, `2`, `3` representan directamente los números 1, 2, 3
- Las teclas `q`, `w`, `e` están naturalmente alineadas con `4`, `5`, `6`
- Las teclas `a`, `s`, `d` siguen la secuencia lógica para `7`, `8`, `9`
- La navegación con `h`, `j`, `k`, `l` sigue el estándar de Vim para máxima familiaridad

### ⚡ Flujo de Trabajo

1. Activa la capa cuando necesites introducir números
2. Usa la distribución natural del numpad
3. Aprovecha las operaciones matemáticas integradas
4. Desactiva cuando termines la tarea numérica

### 🔄 Integración

- Compatible con todas las aplicaciones
- Funciona en calculadoras, hojas de cálculo, formularios web
- No interfiere con otros atajos del sistema

## ⚠️ Consideraciones

### 🎯 Contexto de Uso

- La capa se desactiva automáticamente si se mantiene presionado CapsLock
- Esto permite usar los atajos del modo modificador sin conflictos

### 📱 Aplicaciones Específicas

- Algunas aplicaciones pueden interpretar diferente las teclas del numpad
- En caso de problemas, usar `Esc` para desactivar temporalmente

### 🔧 Personalización

- La distribución está optimizada para uso general
- Se puede modificar en el código fuente si se necesitan ajustes específicos

## 📊 Ventajas

- **🚀 Velocidad**: Acceso inmediato a funciones numéricas
- **🎯 Precisión**: Distribución familiar y ergonómica
- **💪 Productividad**: Elimina la necesidad de numpad físico
- **🔄 Flexibilidad**: Modo persistente para trabajo continuo
- **⚡ Eficiencia**: Integración perfecta con el flujo de trabajo

---

**¿Necesitas más funciones numéricas?** Esta capa se puede extender fácilmente para incluir más operaciones matemáticas o funciones especializadas.


