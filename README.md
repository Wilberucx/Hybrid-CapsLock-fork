# Hybrid CapsLock + Kanata - Sistema de Productividad Ergonómico

![HybridCapsLock logo](img/Logo%20HybridCapsLock.png)

Este proyecto combina lo mejor de dos mundos: **[Kanata](https://github.com/jtroo/kanata)** (remapper de teclado a nivel bajo con timing perfecto para tap-hold y homerow mods) con **AutoHotkey** (inteligencia context-aware y lógica compleja). El resultado es un sistema de productividad ergonómico que transforma la tecla `CapsLock` y las teclas de la home row en una potente herramienta de navegación y edición, inspirado en editores como Vim.

## 🔗 Proyectos Relacionados

Este es un **fork especializado** del proyecto original [Hybrid-CapsLock](https://github.com/Wilberucx/Hybrid-CapsLock), creado para integrar [Kanata](https://github.com/jtroo/kanata) y aprovechar sus capacidades de remapeo a nivel de kernel.

- **[Hybrid-CapsLock (original)](https://github.com/Wilberucx/Hybrid-CapsLock)**: Implementación pura con AutoHotkey v2, ideal para quienes prefieren una solución todo-en-uno sin dependencias externas.
- **[Kanata](https://github.com/jtroo/kanata)**: Remapper de teclado multiplataforma (por jtroo), especializado en tap-hold, homerow mods y timing preciso a nivel de driver.

Ambos proyectos (Hybrid-CapsLock original y este fork) son mantenidos por el mismo autor, cada uno optimizado para diferentes casos de uso.

## 🤔 ¿Por qué este Fork con Kanata?

Este fork combina las **fortalezas de Kanata** (ergonomía, timing perfecto, homerow mods) con las **fortalezas de AutoHotkey** (context-aware, lógica compleja, tooltips visuales):

### ✨ Ventajas de la Integración

- **🎯 Timing Perfecto:** Kanata maneja tap-hold a nivel de driver, eliminando falsos positivos y delay perceptible.
- **🏠 Homerow Mods:** Ctrl/Alt/Win/Shift en las teclas de la home row (a/s/d/f, j/k/l/;) sin salir de la posición base.
- **⚡ Ergonomía Superior:** CapsLock como hub central de navegación con detección hardware-level.
- **🧠 Inteligencia Context-Aware:** AutoHotkey detecta la aplicación activa, ventana, y adapta el comportamiento dinámicamente.
- **🎨 Visual Feedback:** Tooltips C# elegantes con información contextual y estado del sistema.
- **🔧 Personalización Extrema:** Sistema modular de configuración con 5 archivos `.ini` sin tocar código.
- **📚 Capas Dinámicas:** Leader mode, nvim layer, excel layer, y más, con lógica compleja y submenús organizados.

### 🆚 vs Hybrid-CapsLock Original

| Aspecto | Original (Solo AHK) | Este Fork (Kanata + AHK) |
|---------|---------------------|---------------------------|
| **Tap-hold detection** | Software (AHK) | Hardware-level (Kanata) |
| **Homerow mods** | ❌ No disponible | ✅ a/s/d/f, j/k/l/; |
| **Timing precision** | ~100-200ms delay | <10ms (kernel-level) |
| **Ergonomía** | Buena | Excelente |
| **Dependencias** | Solo AHK | AHK + Kanata |
| **Complejidad** | Media | Media-Alta |
| **Context-aware** | ✅ Completo | ✅ Completo |
| **Tooltips visuales** | ✅ C# + nativos | ✅ C# + nativos |

**Recomendación**: Usa el [proyecto original](https://github.com/Wilberucx/Hybrid-CapsLock) si prefieres simplicidad y cero dependencias. Usa este fork si quieres máxima ergonomía con homerow mods y timing perfecto.

## ✨ Conceptos Clave

> **Arquitectura Híbrida**: Kanata maneja ergonomía (tap-hold, homerow mods, navegación hjkl) mientras AutoHotkey maneja inteligencia (context-aware, tooltips, leader menus).

### 🎹 Capas y Modos

#### Kanata (Hardware-Level)
- **🏠 Homerow Mods:** Modificadores sin salir de la home row
  - **Mano izquierda**: `a`=Ctrl, `s`=Alt, `d`=Win, `f`=Shift
  - **Mano derecha**: `j`=Shift, `k`=Win, `l`=Alt, `;`=Ctrl
  - [**📖 Guía Completa de Homerow Mods**](doc/HOMEROW_MODS.md)
  
- **🧭 Navegación Rápida (Hold CapsLock):** Navegación hjkl instantánea mientras mantienes CapsLock presionado (sin persistencia, desaparece al soltar)

- **🔢 Numpad (Hold O):** Teclado numérico completo en mano izquierda
- **🎵 Media (Hold E):** Controles multimedia (play/pause/volume)
- **🖱️ Mouse (Hold N/M/B):** Clicks de mouse desde teclado
- [**📖 Guía de Numpad y Media Layers**](doc/NUMPAD_MEDIA_LAYERS.md)

#### AutoHotkey (Lógica Context-Aware)
- **📝 Nvim Layer (Tap CapsLock):** Toggle persistente de navegación Vim con lógica avanzada (visual mode, comandos :wq, gg/G, etc). A diferencia de `Hold CapsLock`, esta capa permanece activa hasta que vuelvas a tocar CapsLock.

- **🎯 Modo Líder (Hold CapsLock + Space):** Menús contextuales inteligentes para programas, ventanas, comandos del sistema, timestamps, información personal y más. Configurable como atajo en `kanata.kbd` (F24 en capa vim-nav).

## ⚙️ Instalación y Uso

### Requisitos
1. **Instalar:** [AutoHotkey v2.0](https://www.autohotkey.com/v2/)
2. **Instalar:** [Kanata](https://github.com/jtroo/kanata) - Remapper de teclado a nivel bajo

### Inicio Rápido

**Inicio Automático (Recomendado)**:
```
Doble click en HybridCapsLock.ahk
```
Inicia automáticamente Kanata + HybridCapsLock en un solo paso.

**Inicio Manual (Avanzado)**:
1. Ejecutar `start_kanata.vbs`
2. Ejecutar `HybridCapsLock.ahk`

**Inicio automático en Windows (Opcional):** Crear un acceso directo de `HybridCapsLock.ahk` en la carpeta de inicio de Windows (`shell:startup`).

### Recargar Configuración

Después de editar cualquier archivo de configuración (`kanata.kbd`, `.ini`, `.ahk`):

**Atajo de recarga integrado:** `Hold CapsLock + Space → c → h → R`

- **R**: Reload completo (Kanata + AutoHotkey) - recomendado
- **k**: Restart solo Kanata (útil si solo editaste `kanata.kbd`)

> **⚡ Nota Importante**: Este fork integra **Kanata** (ergonomía, homerow mods) con **AutoHotkey** (inteligencia, context-aware).  
> Ver [MIGRATION.md](MIGRATION.md) para arquitectura completa y [STARTUP.md](STARTUP.md) para configuración de inicio.

## 📚 Documentación Completa

Para una guía detallada sobre todos los atajos, capas, configuración avanzada y desarrollo, consulta nuestro portal de documentación:

- **[➡️ Ir a la Documentación Completa (Carpeta `/doc`)](doc/README.md)**

## 🚧 Desarrollo y Versiones

- Para ver el historial de cambios y versiones, revisa el archivo **[CHANGELOG.md](CHANGELOG.md)**.
- Las características en desarrollo y planes futuros se detallan en la documentación.

## 👥 Créditos

- **Autor**: [Wilberucx](https://github.com/Wilberucx) - Hybrid-CapsLock (original) y este fork con Kanata
- **Kanata**: [jtroo/kanata](https://github.com/jtroo/kanata) - Remapper de teclado multiplataforma
- **AutoHotkey**: [AutoHotkey v2](https://www.autohotkey.com/) - Lenguaje de scripting para Windows

## 📄 Licencia

Este proyecto mantiene la misma licencia que el proyecto original Hybrid-CapsLock.
