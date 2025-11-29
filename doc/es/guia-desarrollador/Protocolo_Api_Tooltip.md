# Protocolo API de Tooltip

Este documento describe el protocolo de comunicación para la aplicación Tooltip. La aplicación opera como un **Servidor de Named Pipe**, escuchando comandos JSON para actualizar su interfaz.

## 📡 Mecanismo de Comunicación

- **Nombre del Pipe**: `\\\\.\\pipe\\TooltipPipe`
- **Formato**: JSON (UTF-8)
- **Método**: Fire-and-forget unidireccional. El cliente se conecta, escribe la cadena JSON y se desconecta.

## 📜 Estructura de Comandos

El objeto raíz es un **TooltipCommand**. Todos los campos son opcionales, pero `show` típicamente es requerido para tomar acción.

### Campos Principales

| Campo | Tipo | Por Defecto | Descripción |
| :--- | :--- | :--- | :--- |
| `show` | `bool` | `false` | `true` para mostrar el tooltip, `false` para ocultarlo. |
| `id` | `string` | `\"main\"` | Identificador único para la ventana de tooltip. Permite múltiples tooltips independientes (ej: uno para menú, uno para estado). |
| `title` | `string` | `\"\"` | El texto del encabezado principal del tooltip. |
| `timeout_ms` | `int` | `7000` | Tiempo en milisegundos antes de que el tooltip se oculte automáticamente. Establecer en `0` para persistente. |
| `tooltip_type` | `string` | `\"leader\"` | Presets para comportamiento/diseño. Opciones: `\"leader\"`, `\"status_persistent\"`, `\"sidebar_right\"`, `\"bottom_right_list\"`, `\"text_block\"`. |

### Campos de Contenido

| Campo | Tipo | Descripción |
| :--- | :--- | :--- |
| `items` | `Array` | Lista de elementos a mostrar (ver **Objeto Item** abajo). Usado para menús estándar. |
| `content` | `string` | Contenido de texto sin procesar. Usado cuando `tooltip_type` es `\"text_block\"`. Preserva espacios/saltos de línea. |
| `navigation` | `Array<string>` | Lista de cadenas para mostrar en la barra de navegación inferior (ej: `[\"ESC: Cerrar\", \"ENTER: Seleccionar\"]`). |

### Diseño y Comportamiento

| Campo | Tipo | Por Defecto | Descripción |
| :--- | :--- | :--- | :--- |
| `layout` | `string` | `\"grid\"` | `\"grid\"` (multi-columna) o `\"list\"` (columna única). |
| `columns` | `int` | `4` | Número de columnas cuando `layout` es `\"grid\"`. |
| `topmost` | `bool` | `null` | Si es `true`, fuerza la ventana a permanecer encima de todas las demás. |
| `click_through` | `bool` | `null` | Si es `true`, los clics del mouse pasan a través de la ventana. |
| `opacity` | `double` | `null` | Opacidad de la ventana (0.0 a 1.0). |

---

## 🧩 Objetos de Datos

### Objeto Item (`items`)

Representa un elemento accionable individual en el menú.

```json
{
  \"key\": \"w\",             // El disparador de tecla (mostrado en negrita)
  \"description\": \"Trabajo\",  // El texto de descripción
  \"color\": \"#ff0000\"      // (Opcional) Sobrescribir color para esta tecla específica
}
```

### Objeto Style (`style`)

Personaliza la apariencia visual. Todos los colores soportan formato Hex (`#RRGGBB` o `#AARRGGBB`).

```json
{
  \"background\": \"#1e1e1e\",
  \"text\": \"#ffffff\",
  \"border\": \"#333333\",
  \"accent_options\": \"#dbd6b9\",      // Color para teclas de elementos
  \"accent_navigation\": \"#2d2d2d\",   // Fondo para pills de navegación
  \"navigation_text\": \"#888888\",
  
  \"border_thickness\": 1,
  \"corner_radius\": 8,
  \"padding\": [16, 16, 16, 16],      // [izquierda, arriba, derecha, abajo]
  
  \"title_font_size\": 14,
  \"item_font_size\": 12,
  \"navigation_font_size\": 11,
  \"font_family\": \"Segoe UI\",        // Familia de fuente para texto (por defecto \"Consolas\" para text_block)
  
  \"max_width\": 800,
  \"max_height\": 600
}
```

### Objeto Position (`position`)

Controla dónde aparece el tooltip en pantalla.

```json
{
  \"anchor\": \"bottom_center\",  // Ver Opciones de Anclaje abajo
  \"offset_x\": 0,
  \"offset_y\": 50,
  \"x\": 100,                   // X absoluta (solo si anchor=\"manual\")
  \"y\": 100                    // Y absoluta (solo si anchor=\"manual\")
}
```

**Opciones de Anclaje**:
- `top_left`, `top_center`, `top_right`
- `center_left`, `center`, `center_right`
- `bottom_left`, `bottom_center`, `bottom_right`
- `manual` (usa coordenadas `x` e `y`)

---

## 💡 Ejemplos

### 1. Menú Básico (AutoHotkey)

```autohotkey
json := '
(
  {
    \"show\": true,
    \"title\": \"MI MENÚ\",
    \"items\": [
      {\"key\": \"1\", \"description\": \"Opción Uno\"},
      {\"key\": \"2\", \"description\": \"Opción Dos\"}
    ]
  }
)'
Tooltip_SendRaw(json)
```

### 2. Pill de Estado Persistente

Muestra un pequeño indicador de estado en la esquina inferior derecha que no desaparece automáticamente.

```json
{
  \"id\": \"status_pill\",
  \"show\": true,
  \"title\": \"MODO INSERTAR\",
  \"timeout_ms\": 0,
  \"position\": {
    \"anchor\": \"bottom_right\",
    \"offset_x\": -20,
    \"offset_y\": -20
  },
  \"style\": {
    \"background\": \"#007acc\",
    \"text\": \"#ffffff\",
    \"padding\": [8, 4, 8, 4],
    \"corner_radius\": 4,
    \"title_font_size\": 10
  }
}
```

### 3. Ocultar un Tooltip Específico

```json
{
  \"id\": \"status_pill\",
  \"show\": false
}
```

### 4. Diseño Complejo (Grid)

```json
{
  \"show\": true,
  \"title\": \"PALETA DE COMANDOS\",
  \"layout\": \"grid\",
  \"columns\": 3,
  \"items\": [
    {\"key\": \"f\", \"description\": \"Archivo\"},
    {\"key\": \"e\", \"description\": \"Editar\"},
    {\"key\": \"v\", \"description\": \"Ver\"},
    {\"key\": \"g\", \"description\": \"Ir\"},
    {\"key\": \"r\", \"description\": \"Ejecutar\"},
    {\"key\": \"t\", \"description\": \"Terminal\"}
  ],
  \"navigation\": [\"ESC: Cancelar\", \"ENTER: Confirmar\"]
}
```

### 5. Bloque de Texto / Pantalla de Bienvenida (Arte ASCII)

Muestra texto multilínea sin procesar con preservación de espacios. Ideal para arte ASCII o mensajes de bienvenida.

```json
{
  \"show\": true,
  \"tooltip_type\": \"text_block\",
  \"title\": \"BIENVENIDO\",
  \"content\": \"  __  __       _          _     _ \\n |  \\\\/  |     | |        (_)   | |\\n | \\\\  / |_   _| |__  _ __ _  __| |\\n | |\\\\/| | | | | '_ \\\\| '__| |/ _` |\\n | |  | | |_| | |_) | |  | | (_| |\\n |_|  |_|\\\\__, |_.__/|_|  |_|\\\\__,_|\\n          __/ |                   \\n         |___/                    \",
  \"position\": { \"anchor\": \"center\" },
  \"style\": {
    \"font_family\": \"Consolas\",
    \"item_font_size\": 14,
    \"background\": \"#1a1b26\",
    \"text\": \"#7aa2f7\"
  }
}
```
