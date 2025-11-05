# Capa Nvim (Activada con Toque a CapsLock)

> Referencia rápida
> - Confirmaciones: no aplica (acciones inmediatas)
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

La Capa Nvim transforma tu teclado en un entorno de navegación y edición inspirado en Vim, proporcionando control preciso sin necesidad de mantener teclas modificadoras.

## 🎯 Activación

**Método:** Presiona y suelta `CapsLock` rápidamente (tap)

Un aviso visual aparecerá indicando el estado:
- `◉ NVIM` - Capa activada
- `○ NVIM` - Capa desactivada

> **Nota:** La capa se desactiva automáticamente al activar el Modo Líder (`leader`)

## 🎮 Modo Visual

La Capa Nvim incluye un **Modo Visual** para seleccionar texto mientras navegas:

| Tecla | Acción | Estado Visual |
|-------|--------|---------------|
| `v` | **Toggle Modo Visual** | `VISUAL MODE ON/OFF` |

Cuando el Modo Visual está activo, todas las teclas de navegación extienden la selección.

## 🧭 Navegación Básica (hjkl)

| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `h` | `←` | `Shift+←` | Mover/seleccionar izquierda |
| `j` | `↓` | `Shift+↓` | Mover/seleccionar abajo |
| `k` | `↑` | `Shift+↑` | Mover/seleccionar arriba |
| `l` | `→` | `Shift+→` | Mover/seleccionar derecha |

## 🚀 Navegación Extendida

### Movimiento por Palabras
| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `w` | `Ctrl+→` | `Ctrl+Shift+→` | Siguiente palabra |
| `b` | `Ctrl+←` | `Ctrl+Shift+←` | Palabra anterior |
| `e` | `Ctrl+→ + ←` | - | Final de palabra actual |

### Movimiento por Líneas
| Tecla | Modo Normal | Modo Visual | Descripción |
|-------|-------------|-------------|-------------|
| `0` | `Home` | `Shift+Home` | Inicio de línea |
| `$` (Shift+4) | `End` | `Shift+End` | Fin de línea |

### Historial de Cambios
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `u` | `Ctrl+Z` | **Undo** - Deshacer último cambio |
| `U` (Shift+u) | `Ctrl+Y` | **Redo** - Rehacer cambio deshecho |

## ✏️ Edición de Texto

### Eliminación de Caracteres
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `x` | `Delete` | Eliminar carácter hacia adelante |
| `X` (Shift+x) | `Backspace` | Eliminar carácter hacia atrás |

### Reemplazo de Caracteres
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `r` | **Replace Mode** | Elimina carácter actual y permite escribir cualquier carácter |

> **Replace Mode:** Después de presionar `r`, escribe cualquier carácter para reemplazar. Presiona `ESC` para volver a la capa nvim o espera 3 segundos para reactivación automática.

### Inserción de Líneas (Estilo Vim)
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `o` | `End + Enter` | Nueva línea debajo del cursor |
| `O` (Shift+o) | `Home + Enter + ↑` | Nueva línea arriba del cursor |

### Modos de Inserción
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `i` | **Insert Mode** | Desactiva capa nvim temporalmente para escribir |
| `A` (Shift+a) | **Append Mode** | Va al final de línea y desactiva capa nvim |

> **Insert/Append Mode:** Presiona `ESC` para reactivar la capa nvim o espera 3 segundos para reactivación automática.

## 📋 Sistema Yank/Paste (Copiar/Pegar)

### Operador Yank (Copiar)
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `y` | **Activar Yank** | Espera segunda tecla para definir qué copiar |

**Después de presionar `y`:**
| Segunda Tecla | Acción | Descripción |
|---------------|--------|-------------|
| `y` | **Copiar línea** | Copia la línea actual completa |
| `p` | **Copiar párrafo** | Copia el párrafo actual |
| `a` | **Copiar todo** | Copia todo el contenido (`Ctrl+A + Ctrl+C`) |

> **Timeout:** Si no presionas una segunda tecla en 600ms, el modo yank se cancela

### Yank en Modo Visual
Si hay texto seleccionado (Modo Visual activo), presionar `y` copia inmediatamente la selección.

### Paste (Pegar)
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `p` | **Pegar normal** | `Ctrl+V` - Pegar con formato |
| `P` (Shift+p) | **Pegar plano** | Pegar solo texto sin formato |

> **Nota:** Si estás en modo yank y presionas `p`, copiará el párrafo actual en lugar de pegar

## 🗑️ Sistema Delete (Eliminar)

### Operador Delete
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `d` | **Activar Delete** | Espera segunda tecla para definir qué eliminar |

**Después de presionar `d`:**
| Segunda Tecla | Acción | Descripción |
|---------------|--------|-------------|
| `d` | **Eliminar línea** | Elimina la línea actual completa |
| `w` | **Eliminar palabra** | Elimina la palabra actual |
| `a` | **Eliminar todo** | Elimina todo el contenido |

> **Timeout:** Si no presionas una segunda tecla en 600ms, el modo delete se cancela

### Delete en Modo Visual
Si hay texto seleccionado (Modo Visual activo), presionar `d` elimina inmediatamente la selección.

## 📜 Desplazamiento Suave

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `E` (Shift+e) | **Scroll abajo** | 3 pasos de rueda hacia abajo |
| `Y` (Shift+y) | **Scroll arriba** | 3 pasos de rueda hacia arriba |
| `Shift` | **Scroll con touchpad** | Mantén `Shift` y mueve el touchpad para scroll trackball |

> **Nota:** El scroll con touchpad (`Shift`) replica la funcionalidad de ratones trackball con ejes invertidos para mayor naturalidad. La tecla `e` ahora se usa para navegación (final de palabra) y `y` para el sistema yank.

## 🖱️ Funciones de Mouse

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `;` | **Click izquierdo sostenido** | Mantiene click izquierdo hasta soltar la tecla |
| `'` | **Click derecho** | Click derecho simple |

> **Nota:** Las funciones de mouse en la capa Nvim permiten control preciso sin salir del modo de navegación.

## ⏰ Timestamps

> **Nota:** La funcionalidad de timestamps fue movida al Modo Líder. Usa `leader → t` para acceder a las opciones de timestamp.

## 🔧 Función Especial

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `f` | **Desactivar capa + Ctrl+Alt+K** | Desactiva Nvim Layer y envía `Ctrl+Alt+K` |

Esta función es útil para aplicaciones que usan `Ctrl+Alt+K` como atajo, permitiendo acceso rápido sin conflictos.

## 💡 Flujos de Trabajo Comunes

### 📝 Edición Rápida
```
1. CapsLock (activar capa)
2. hjkl (navegar al texto)
3. v (activar visual)
4. w/b/e (seleccionar palabras)
5. y (copiar selección)
6. o (nueva línea)
7. p (pegar)
```

### 🔄 Replace y Delete
```
1. CapsLock (activar capa)
2. hjkl (navegar al carácter)
3. r (replace mode)
4. [escribir nuevo carácter]
5. ESC (volver a capa nvim)

O para eliminar:
3. d → d (eliminar línea completa)
```

### 📋 Copia Masiva
```
1. CapsLock (activar capa)
2. y → a (copiar todo)
3. Cambiar aplicación
4. CapsLock (activar capa)
5. p (pegar)
```

### 🎯 Navegación Precisa
```
1. CapsLock (activar capa)
2. 0 (inicio de línea)
3. w w w (tres palabras adelante)
4. v (activar visual)
5. $ (seleccionar hasta fin de línea)
```

### ↩️ Undo/Redo
```
1. CapsLock (activar capa)
2. u (undo - deshacer)
3. U (redo - rehacer)
```

## 🔄 Actualizaciones recientes (NVIM Layer)

- Indicadores nativos: `◉ NVIM` activado / `○ NVIM` desactivado; Visual: `◉ VISUAL` / `○ VISUAL`.
- Navegación con modificadores: `Ctrl/Alt/Shift` + `h/j/k/l` envían flechas con esos modificadores.
- Saltos por palabra: `w` (Ctrl+→), `b` (Ctrl+←). En Visual, extienden selección (Ctrl+Shift+flecha).
- Edición simplificada: `y` copia (Ctrl+C); `d` borra (Delete). En Visual ambos salen del modo Visual.
- Guardar: comandos estilo NVIM dentro de la capa (esperan Enter): `:w` (guardar), `:q` (salir), `:wq` (guardar y salir).
- Insert: `i` desactiva la capa y envía `Ctrl+Alt+Shift+I`; regresas con `Esc`.
- Find: `f` envía `Ctrl+Shift+Alt+2` y desactiva la capa. Configura en tu herramienta favorita (Fluent Search, Flow Launcher, PowerToys Run, etc.) que esta combinación abra la búsqueda/lanzador.
- Visual-only: `c` borra selección y entra a “insert” (desactiva capa); `a` selecciona todo (`Ctrl+A`).
- Scroll: `Ctrl+U` arriba, `Ctrl+D` abajo.

## ⚙️ Configuración y Estados

### Estados Visuales
- **Capa Nvim:** `NVIM LAYER ON/OFF`
- **Modo Visual:** `VISUAL MODE ON/OFF`
- **Formato Timestamp:** `TIMESTAMP FORMAT [formato]`
- **Yank Menu:** Muestra opciones `y/p/a` durante operación yank

### Persistencia
- El estado de la capa se mantiene hasta que se desactive manualmente
- Los formatos de timestamp se recuerdan durante la sesión
- El Modo Visual se resetea al desactivar la capa

## ⚠️ Consideraciones

### 🔄 Integración con Otros Modos
- **Modo Líder:** Desactiva automáticamente la Capa Nvim
- **Modo Modificador:** No interfiere con la capa (requiere mantener CapsLock)

### 📱 Compatibilidad
- **Aplicaciones de texto:** Funciona perfectamente en editores, navegadores, etc.
- **Aplicaciones específicas:** Algunos programas pueden interceptar ciertas teclas
- **Juegos:** Recomendado desactivar la capa antes de jugar

### ⚡ Rendimiento
- **Respuesta instantánea:** Las teclas responden inmediatamente
- **Memoria mínima:** No consume recursos significativos
- **Timeout automático:** El modo yank se cancela automáticamente

## 🔧 Personalización

### Añadir Nuevas Funciones
```autohotkey
#If (isNvimLayerActive && !GetKeyState("CapsLock","P"))

nueva_tecla::
    if (VisualMode)
        Send, +{nueva_accion}  ; Con selección
    else
        Send, {nueva_accion}   ; Sin selección
return

#If ; Fin del contexto
```

### Modificar Formatos de Timestamp
```autohotkey
global TSFormats := ["formato1", "formato2", "nuevo_formato"]
```

> **Tip:** La Capa Nvim es especialmente útil para escritores, programadores y cualquiera que trabaje intensivamente con texto.