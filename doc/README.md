# 📚 Portal de Documentación de HybridCapsLock

Bienvenido al centro de documentación de HybridCapsLock. Aquí encontrarás toda la información detallada para dominar y personalizar el script.

## ⭐ Lo Nuevo

**🎉 Sistema Declarativo de Comandos** - Inspirado en lazy.nvim/which-key de Neovim
- ✨ Cada comando en una sola línea
- 🚀 Menús auto-generados dinámicamente  
- 📦 Sin archivos de configuración externa
- 🔧 Extensibilidad trivial

📖 **[Ver COMMAND_LAYER.md](COMMAND_LAYER.md)** | **[Arquitectura](DECLARATIVE_SYSTEM.md)** | **[Cómo funciona](COMO_FUNCIONA_REGISTER.md)**

---

## 🚀 Primeros Pasos

- **[Guía de Inicio Rápido](GETTING_STARTED.md)**: ¿Nuevo aquí? Empieza con los atajos esenciales y una guía de configuración de 2 minutos.

## 🎯 Guías de Funcionalidades (Capas)

Cada capa tiene un propósito específico. Aprende a usarlas y configurarlas en sus documentos dedicados:

### Capas de Kanata (Hardware-Level)
- **[🏠 Homerow Mods](HOMEROW_MODS.md)**: Modificadores (Ctrl/Alt/Win/Shift) en las teclas a/s/d/f y j/k/l/; sin salir de la home row. **¡Característica clave de ergonomía!**
- **[🔢 Numpad y Media Layers](NUMPAD_MEDIA_LAYERS.md)**: Teclado numérico (Hold O) y controles multimedia (Hold E) manejados 100% por Kanata.

### Capas de AutoHotkey (Lógica Context-Aware)
- **[Capa Nvim](NVIM_LAYER.md)**: Navegación y edición estilo Vim persistente al *pulsar* `CapsLock` (toggle ON/OFF).
- **[Modo Líder](LEADER_MODE.md)**: Menús contextuales inteligentes que se activan con `Hold CapsLock + Space`.

### Sub-Capas del Modo Líder
- **[Capa Windows](WINDOWS_LAYER.md)**: Gestión de ventanas, escritorios virtuales y zoom.
- **[Capa Programas](PROGRAM_LAYER.md)**: Lanzador de aplicaciones configurable.
- **[Capa Timestamp](TIMESTAMP_LAYER.md)**: Inserción de fechas y horas en múltiples formatos.
- **[Capa Comandos](COMMAND_LAYER.md)**: Paleta de comandos de sistema (CMD/PowerShell).
- **[Capa Información](INFORMATION_LAYER.md)**: Snippets de texto e información personal.
- **[Capa Excel](EXCEL_LAYER.md)**: Capa especializada para Microsoft Excel.

## ⚙️ Configuración y Desarrollo

- **[Guía Completa de Configuración](CONFIGURATION.md)**: Una referencia exhaustiva de los 5 archivos `.ini` y más de 75 opciones de personalización.
- **[Integración de Tooltips (C#)](../tooltip_csharp/README.md)**: Detalles técnicos sobre el sistema de notificaciones visuales.
- **[Pruebas Manuales](MANUAL_TESTS.md)**: Checklist para verificar que todo funciona correctamente.

## 🛠️ Plantillas y Desarrollo

- **[📦 Layer Templates](templates/)**: Plantillas reutilizables para crear nuevas capas persistentes.
  - **[layer_template.ahk](templates/layer_template.ahk)**: Plantilla base con exit key configurable, sistema de ayuda, y soporte para sub-modos.
  - **[example_browser_layer.ahk](templates/example_browser_layer.ahk)**: Ejemplo funcional de una capa para navegadores web.
  - **[📖 Documentación Completa](develop/PERSISTENT_LAYER_TEMPLATE.md)**: Guía detallada para crear capas personalizadas.

## 🔗 Enlaces Globales

- **[README Principal](../README.md)**: Volver a la página principal del proyecto.
- **[Historial de Cambios](../CHANGELOG.md)**: Ver las novedades de cada versión.