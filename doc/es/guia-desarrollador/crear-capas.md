# 🛠️ Crear Capas (Layers)

Esta guía explica cómo crear y gestionar capas en HybridCapsLock utilizando el sistema de registro centralizado.

## Conceptos Básicos

El sistema se basa en tres funciones principales:

1.  **`RegisterLayer`**: Define la *identidad* de la capa (nombre, color, ID).
2.  **`RegisterKeymap`**: Define *qué hace* cada tecla dentro de esa capa.
3.  **`RegisterCategoryKeymap`**: Crea *submenús* organizados dentro de una capa.

---

## 1. Registrar la Capa (`RegisterLayer`)

Antes de asignar teclas, debes registrar la capa. Esto es crucial porque el sistema usa esta información para:
*   Mostrar el nombre correcto en la interfaz.
*   Pintar los indicadores visuales (pills) con el color correcto.
*   **Persistencia**: Guardar la configuración en `data/layers.json` para que otras herramientas (como la UI de configuración) sepan que esta capa existe.

### Sintaxis

```autohotkey
RegisterLayer(layerId, displayName, color, textColor, suppressUnmapped)
```

*   **`layerId`** (string): Identificador único interno (ej: `"gaming"`, `"photoshop"`).
*   **`displayName`** (string): Nombre legible que verá el usuario (ej: `"GAMING MODE"`).
*   **`color`** (string): Color de fondo del indicador en formato HEX (ej: `"#FF0000"`).
*   **`textColor`** (string): Color del texto del indicador (opcional, por defecto `"#ffffff"`).
*   **`suppressUnmapped`** (boolean): Controla el comportamiento de teclas no mapeadas (opcional, por defecto `true`)
    - `true`: Solo las teclas mapeadas funcionan, las no mapeadas se bloquean (comportamiento por defecto)
    - `false`: Las teclas no mapeadas pasan a la aplicación

### Ejemplos

```autohotkey
; Layer estándar (bloquea todas las teclas no mapeadas)
RegisterLayer("gaming", "GAMING MODE", "#FF5555", "#FFFFFF")

; Layer de passthrough (solo intercepta teclas específicas)
RegisterLayer("vim", "VIM MODE", "#7F9C5D", "#ffffff", false)
```

**Cuándo usar `suppressUnmapped := false`:**
- Layers estilo Vim que solo necesitan interceptar ESC o comandos específicos
- Layers donde quieres que la escritura normal funcione mientras interceptas atajos
- Contextos de edición de texto donde bloquear teclas no mapeadas sería disruptivo

---

## 2. Asignar Teclas (`RegisterKeymap`)

Una vez registrada la capa, puedes asignarle comportamientos.

### Sintaxis

```autohotkey
RegisterKeymap(layerId, key, description, action, [confirm], [order])
```

*   **`layerId`**: El ID que definiste en `RegisterLayer`.
*   **`key`**: La tecla a mapear (ej: `"w"`, `"Esc"`, o `"<C-s>"` para Ctrl+s).
*   **`description`**: Texto que aparecerá en el menú de ayuda/tooltip.
*   **`action`**: La función que se ejecutará. Puede ser una función existente o una lambda `() => ...`.
*   **`confirm`** (bool, opcional): Si es `true`, pedirá confirmación antes de ejecutar.
*   **`order`** (int, opcional): Para ordenar los ítems en el menú (1 aparece primero).

### Ejemplos

```autohotkey
; Acción simple
RegisterKeymap("gaming", "w", "Move Up", () => Send("{Up}"), false, 1)

; Llamando a una función existente
RegisterKeymap("gaming", "r", "Reload", ReloadWeapon, false, 2)

; Acción con confirmación
RegisterKeymap("gaming", "q", "Quit Game", () => WinClose("A"), true, 9)

; Usando sintaxis de modificadores estilo Vim (recomendado para modificadores)
RegisterKeymap("gaming", "<C-s>", "Guardado Rápido", QuickSave, false, 3)
RegisterKeymap("gaming", "<S-C-r>", "Recarga Forzada", ForceReload, false, 4)
```

### Ayuda Integrada de Layer

¡Presiona `?` en cualquier layer activo para ver automáticamente todos los keymaps registrados! No requiere configuración.

---

## 3. Menús Jerárquicos (`RegisterCategoryKeymap`)

Si tienes muchas acciones, puedes organizarlas en submenús.

### Sintaxis

```autohotkey
RegisterCategoryKeymap(layerId, key, title, [order])
```

*   **`layerId`**: La capa padre.
*   **`key`**: La tecla que abre el submenú.
*   **`title`**: El título del submenú.

### Ejemplo

Imagina que quieres un menú de "Armas" dentro de tu capa Gaming:

```autohotkey
; 1. Crear la categoría (el "folder")
RegisterCategoryKeymap("gaming", "a", "Weapons Menu", 3)

; 2. Asignar teclas DENTRO de esa categoría
; Nota cómo los argumentos de tecla se acumulan: "a", "1"
RegisterKeymap("gaming", "a", "1", "Primary Weapon", EquipPrimary, false, 1)
RegisterKeymap("gaming", "a", "2", "Secondary Weapon", EquipSecondary, false, 2)
```

Esto crea una estructura: `Gaming Layer` -> presiona `a` -> `Weapons Menu` -> presiona `1` -> `EquipPrimary`.

---

## 4. Activar la Capa

Finalmente, necesitas una forma de entrar a tu capa. Usualmente esto se hace desde la capa `leader` (la capa por defecto).

```autohotkey
; Función helper para cambiar de capa
SwitchToGaming() {
    SwitchToLayer("gaming")
}

; Asignar en el menú Leader
RegisterKeymap("leader", "g", "Enter Gaming Mode", SwitchToGaming, false, 5)
```

## Resumen del Flujo

1.  **Definir**: `RegisterLayer("mi_capa", ...)`
2.  **Poblar**: `RegisterKeymap("mi_capa", ...)`
3.  **Conectar**: `RegisterKeymap("leader", ..., SwitchToLayer("mi_capa"))`

¡Y listo! El sistema se encarga de gestionar los menús, los tooltips y la persistencia automáticamente.
