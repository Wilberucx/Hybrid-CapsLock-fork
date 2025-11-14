# Hybrid CapsLock + Kanata - Sistema de Productividad Ergonómico


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

| Aspecto                | Original (Solo AHK) | Este Fork (Kanata + AHK) |
| ---------------------- | ------------------- | ------------------------ |
| **Tap-hold detection** | Software (AHK)      | Hardware-level (Kanata)  |
| **Homerow mods**       | ❌ No disponible    | ✅ a/s/d/f, j/k/l/;      |
| **Timing precision**   | ~100-200ms delay    | <10ms (kernel-level)     |
| **Ergonomía**          | Buena               | Excelente                |
| **Dependencias**       | Solo AHK            | AHK + Kanata             |
| **Complejidad**        | Media               | Media-Alta               |
| **Context-aware**      | ✅ Completo         | ✅ Completo              |
| **Tooltips visuales**  | ✅ C# + nativos     | ✅ C# + nativos          |

**Recomendación**: Usa el [proyecto original](https://github.com/Wilberucx/Hybrid-CapsLock) si prefieres simplicidad y cero dependencias. Usa este fork si quieres máxima ergonomía con homerow mods y timing perfecto.

## ✨ Conceptos Clave

> **Arquitectura Híbrida**: Kanata maneja ergonomía (tap-hold, homerow mods, navegación hjkl) mientras AutoHotkey maneja inteligencia (context-aware, tooltips, leader menus).

> **Sistema Declarativo**: Inspirado en lazy.nvim/which-key de Neovim - cada comando se define en una sola línea, sin archivos de configuración externa, con menús auto-generados dinámicamente.

### 🎹 Capas y Modos

#### Kanata (Hardware-Level)

- **🏠 Homerow Mods:** Modificadores sin salir de la home row
  - **Mano izquierda**: `a`=Ctrl, `s`=Alt, `d`=Win, `f`=Shift
  - **Mano derecha**: `j`=Shift, `k`=Win, `l`=Alt, `;`=Ctrl
  - [**📖 Guía Completa de Homerow Mods**](doc/en/user-guide/homerow-mods.md) | [ES](doc/es/guia-usuario/homerow-mods.md)
- **🧭 Navegación Rápida (Hold CapsLock):** Navegación hjkl instantánea mientras mantienes CapsLock presionado (sin persistencia, desaparece al soltar)

- **🔢 Numpad (Hold O):** Teclado numérico completo en mano izquierda
- **🎵 Media (Hold E):** Controles multimedia (play/pause/volume)
- **🖱️ Mouse (Hold N/M/B):** Clicks de mouse desde teclado
- [**📖 Guía de Numpad y Media Layers**](doc/en/user-guide/numpad-media-layers.md)

#### AutoHotkey (Lógica Context-Aware)

- **📝 Nvim Layer (Tap CapsLock):** Toggle persistente de navegación Vim con lógica avanzada (visual mode, comandos :wq, gg/G, etc). A diferencia de `Hold CapsLock`, esta capa permanece activa hasta que vuelvas a tocar CapsLock.
  - [**📖 Guía de Nvim Layer**](doc/en/user-guide/nvim-layer.md)

- **🎯 Modo Líder (Hold CapsLock + Space):** Menús contextuales inteligentes para programas, ventanas, comandos del sistema, timestamps, información personal y más. Configurable como atajo en `kanata.kbd` (F24 en capa vim-nav).
  - [**📖 Guía de Modo Líder**](doc/en/user-guide/leader-mode.md)

### Opción 1: Descarga Portable (Sin Instalación)

1. **Descarga:** [HybridCapsLock-Portable.zip](https://github.com/Wilberucx/Hybrid-CapsLock-fork/releases)
2. **Extrae** a cualquier carpeta
3. **Instala AutoHotkey v2:** [Descargar aquí](https://www.autohotkey.com/download/ahk-v2.exe)
4. Instala [Kanata](https://github.com/jtroo/kanata/releases)
5. **Ejecuta:** Doble-click en `HybridCapslock.ahk`
6. (opcional) Si quieres tooltips modernos descarga [tooltip_csharp.zip](https://github.com/Wilberucx/Hybrid-CapsLock-fork/releases)

### Opción 2: Instalación Manual

1. Clona este repositorio
2. Instala [AutoHotkey v2](https://www.autohotkey.com/download/ahk-v2.exe)
3. Instala [Kanata](https://github.com/jtroo/kanata/releases)


📚 **Guía de instalación detallada:** [Quick-Install.md](Quick-Install.md)

## ⚙️ Uso Diario

### Verificación de Dependencias

HybridCapsLock ahora **verifica automáticamente** todas las dependencias al iniciar:
- ✅ AutoHotkey v2 (requerido)
- ✅ Kanata (opcional, con fallback)
- ✅ Archivos de configuración

Si falta algo, aparecerá un diálogo claro con enlaces de descarga.

### Inicio Rápido

**Inicio Automático (Recomendado)**:

```
Doble click en HybridCapslock.ahk
```

Inicia automáticamente Kanata + HybridCapsLock en un solo paso.

> **⚠️ Importante:** Siempre ejecuta `HybridCapslock.ahk`, no `init.ahk` directamente. El auto-loader necesita ejecutarse primero para detectar archivos en `src/actions/` y `src/layer/`.

**Inicio Manual (Avanzado)**:

1. Ejecutar `start_kanata.vbs`
2. Ejecutar `init.ahk`

**Inicio automático en Windows (Opcional):** Crear un acceso directo de `Hybrid-CapsLock.ahk` en la carpeta de inicio de Windows (`shell:startup`).

### Recargar Configuración

Después de editar cualquier archivo de configuración (`kanata.kbd`, `.ini`, `.ahk`):

**Atajo de recarga integrado:** `Hold CapsLock + Space → c → h → R`

- **R**: Reload completo (Kanata + AutoHotkey) - recomendado
- **k**: Restart solo Kanata (útil si solo editaste `kanata.kbd`)

> **⚡ Nota Importante**: Este fork integra **Kanata** (ergonomía, homerow mods) con **AutoHotkey** (inteligencia, context-aware).  
> Ver [MIGRATION.md](MIGRATION.md) para arquitectura completa y [STARTUP.md](STARTUP.md) para configuración de inicio.

## 📚 Documentación Completa

Para una guía detallada sobre todos los atajos, capas, configuración avanzada y desarrollo, consulta nuestro portal de documentación:

### 🌍 Documentación Bilingüe / Bilingual Documentation

- **[📖 English Documentation](doc/en/README.md)** - Complete documentation in English
- **[📖 Documentación en Español](doc/es/README.md)** - Documentación completa en español
- **[🏠 Documentation Hub](doc/README.md)** - Portal principal con selector de idioma

### 🚀 Enlaces Rápidos / Quick Links

| Tema | English | Español |
|------|---------|---------|
| **Inicio Rápido** | [Quick Start](doc/en/getting-started/quick-start.md) | [Inicio Rápido](doc/es/primeros-pasos/inicio-rapido.md) |
| **Configuración** | [Configuration](doc/en/getting-started/configuration.md) | En progreso |
| **Crear Capas** | [Creating Layers](doc/en/developer-guide/creating-layers.md) | En progreso |
| **Sistema de Debug** | [Debug System](doc/en/reference/debug-system.md) | En progreso |

## 🚧 Desarrollo y Versiones

- **[CHANGELOG.md](CHANGELOG.md)** - Historial de cambios y versiones
- **[DOCUMENTATION_I18N_PLAN.md](DOCUMENTATION_I18N_PLAN.md)** - Plan de internacionalización de documentación
- **[Architecture Overview](doc/en/reference/declarative-system.md)** - Sistema declarativo y arquitectura
- **[Developer Guide](doc/en/developer-guide/creating-layers.md)** - Guía para crear nuevas capas

## 👥 Créditos

- **Autor**: [Wilberucx](https://github.com/Wilberucx) - Hybrid-CapsLock (original) y este fork con Kanata
- **Kanata**: [jtroo/kanata](https://github.com/jtroo/kanata) - Remapper de teclado multiplataforma
- **AutoHotkey**: [AutoHotkey v2](https://www.autohotkey.com/) - Lenguaje de scripting para Windows

## 📄 Licencia

Este proyecto mantiene la misma licencia que el proyecto original Hybrid-CapsLock.
