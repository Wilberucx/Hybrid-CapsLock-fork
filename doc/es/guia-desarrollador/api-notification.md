# API Reference: Notification System

**Archivo**: `system/plugins/notification.ahk`

El **Notification System** es un plugin core que proporciona una interfaz unificada para mostrar retroalimentación visual al usuario. Utiliza el sistema de TooltipApp para notificaciones animadas y ricas visualmente, con fallback automático a tooltips nativos.

## 🚀 Funciones Principales

### ShowTooltipFeedback

Muestra una notificación de retroalimentación en pantalla.

```autohotkey
ShowTooltipFeedback(message, type := "info", timeout := 2000)
```

**Parámetros:**

| Parámetro | Tipo | Default | Descripción |
|-----------|------|---------|-------------|
| `message` | String | - | El mensaje a mostrar al usuario. Soporta múltiples líneas. |
| `type` | String | `"info"` | El tipo de notificación (ver Tipos Soportados). |
| `timeout` | Integer | `2000` | Tiempo en milisegundos antes de ocultar la notificación. |

**Tipos Soportados:**

| Tipo | Color | Icono | Uso Recomendado |
|------|-------|-------|-----------------|
| `info` | 🔵 Azul | 💡 | Información general, estados neutrales. |
| `success` | 🟢 Verde | ✅ | Operaciones exitosas, guardado completado. |
| `warning` | 🟠 Naranja | ⚠️ | Advertencias no críticas, reintentos. |
| `error` | 🔴 Rojo | ❌ | Fallos de operación, errores de validación. |
| `confirm` | 🟣 Morado | ❓ | Solicitudes de confirmación o preguntas. |

**Comportamiento:**
1. Valida el tipo de notificación.
2. Obtiene la configuración de colores del tema actual.
3. Intenta mostrar una notificación animada vía `TooltipApp` (slide_left).
4. Si `TooltipApp` no está disponible, usa `ToolTip` nativo de AHK (ID 19).

## 💡 Ejemplos de Uso

### Notificación Básica

```autohotkey
; Mostrar mensaje simple (info por defecto)
ShowTooltipFeedback("Sistema listo")
```

### Notificación de Éxito

```autohotkey
; Operación completada con éxito
ShowTooltipFeedback("Archivo guardado correctamente", "success")
```

### Notificación de Error Personalizada

```autohotkey
; Error con mayor tiempo de visualización (3 segundos)
ShowTooltipFeedback("Error de conexión: No se pudo contactar al servidor", "error", 3000)
```

### Notificación de Advertencia

```autohotkey
ShowTooltipFeedback("Batería baja: 15%", "warning")
```

## 🎨 Personalización

El sistema respeta la configuración de tema global (`HybridConfig.theme`). Los colores base se toman del tema, y los colores específicos de tipo (bordes e iconos) están hardcoded para consistencia visual:

- **Info**: `#3498db`
- **Success**: `#27ae60`
- **Warning**: `#f39c12`
- **Error**: `#e74c3c`
- **Confirm**: `#9b59b6`

## 🔧 Detalles Técnicos

- **ID de Tooltip (Nativo)**: Usa el ID `19` para evitar conflictos con otros tooltips.
- **ID de Tooltip (App)**: Usa el ID `"notification_feedback"`.
- **Iconos**: Utiliza caracteres Unicode de NerdFonts.
- **Animación**: `slide_left` con duración de 300ms.
- **Posición**: Actualmente `top_left` con offset (20, 20).

## 🔄 Migración

Si estás usando funciones de feedback antiguas o tooltips manuales, migra a `ShowTooltipFeedback`:

**Antes:**
```autohotkey
ToolTip("Guardando...", , , 15)
SetTimer(() => ToolTip(,,,15), -2000)
```

**Después:**
```autohotkey
ShowTooltipFeedback("Guardando...", "info")
```
