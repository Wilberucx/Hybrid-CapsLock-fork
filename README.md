# Hybrid CapsLock + Kanata

<div align="center">

**Transforma tu teclado en una herramienta de productividad ergonómica**

*La potencia de [Kanata](https://github.com/jtroo/kanata) (remapping a nivel kernel) + la inteligencia de AutoHotkey (context-aware)*

</div>

---

## 🎯 ¿Qué es Hybrid CapsLock?

Imagina poder **navegar, editar y controlar tu sistema** sin mover las manos de la fila principal del teclado. Hybrid CapsLock convierte la tecla `CapsLock` (que casi nunca usas) en un **hub central de productividad** inspirado en editores como Vim.

### El Problema que Resuelve

❌ **Antes:**
- Mover constantemente la mano derecha al mouse o flechas
- Atajos de teclado complejos que requieren contorsiones (`Ctrl+Shift+Alt+...`)
- Cambiar de contexto mental entre aplicaciones
- Tecla CapsLock desperdiciada

✅ **Después:**
- Navegación tipo Vim (`h/j/k/l`) desde cualquier aplicación
- Capas contextuales que se adaptan a la aplicación activa
- Menús visuales que muestran todas las opciones disponibles
- CapsLock como tecla más poderosa del teclado

---

## ✨ Características Principales

### 🎯 **Navegación Ergonómica**
Mantén `CapsLock` y usa `h/j/k/l` para navegar como en Vim, en **cualquier aplicación** (navegador, editor, Excel, etc.)

```
CapsLock (hold) + h/j/k/l  →  ←/↓/↑/→ (flechas)
CapsLock (hold) + Space    →  Modo Líder (menús contextuales)
CapsLock (tap)             →  Dynamic Layer (capas por aplicación)
```

> 💡 **Configuraciones disponibles**: El sistema incluye múltiples archivos `kanata.kbd` de ejemplo en [doc/kanata-configs](doc/kanata-configs/):
> - `kanata.kbd` (básico) - Solo navegación con flechas (configuración actual)
> - `kanata-homerow.kbd` - Incluye homerow mods (a/s/d/f como modificadores)
> - `kanata-extended.kbd` - Listo para plugins adicionales

### 🧠 **Context-Aware Intelligence**
El sistema detecta qué aplicación está activa y adapta el comportamiento automáticamente:
- En **Excel**: `CapsLock + j/k` navega entre celdas
- En **navegadores**: atajos específicos para tabs y navegación
- En **editores**: funciones de edición avanzadas

### 🎨 **Feedback Visual Elegante**
Tooltips C# modernos que muestran:
- Menús contextuales con todas las opciones disponibles
- Estado actual del sistema (capas activas, modo, etc.)
- Información de keybindings organizados por categorías

### 🧩 **Sistema Modular de Plugins**
El core es ligero. **Tú decides** qué funcionalidades instalar:
- 📂 Gestión de carpetas y archivos
- 🐙 Integración con Git
- 📊 Monitoreo del sistema
- ⚡ Acciones de energía
- 🕒 Timestamps y snippets
- ...y más en el [catálogo de plugins](doc/plugins/README.md)

### ⚡ **Timing Perfecto**
Gracias a Kanata (nivel kernel), los tap-hold y homerow mods funcionan sin falsos positivos ni delay perceptible.

---

## 🚀 Inicio Rápido

### 1️⃣ Instalación

```powershell
# Clona el repositorio
git clone https://github.com/Wilberucx/Hybrid-CapsLock-fork.git
cd Hybrid-CapsLock-fork

# Ejecuta el script principal
.\HybridCapslock.ahk
```

> 📖 **Guía completa**: [Instalación detallada](doc/es/guia-usuario/instalacion.md)

### 2️⃣ Tu Primera Acción: Modo Líder

1. **Activa el Modo Líder**: Mantén `CapsLock` + presiona `Space`
2. Verás un menú visual con opciones
3. Prueba presionar `h` para ver el menú de Hybrid Management

```
LEADER MENU (Configuración Básica)

h - Hybrid Management
  p - Pause Hybrid
  l - View Log File
  c - Open Config Folder
  k - Restart Kanata Only
  R - Reload Script
  e - Exit Script
  r - Register Process (Dynamic Layer)
  t - Toggle Dynamic Layer
  b - List Bindings

[Esc: Exit]
```

> 📝 **Nota**: El menú se expande automáticamente al instalar plugins opcionales (Git, Folders, Timestamps, etc.)

### 3️⃣ Prueba la Navegación

Abre cualquier editor de texto y:
1. **Mantén presionado** `CapsLock` (no lo sueltes)
2. Mientras lo mantienes, presiona `j` varias veces → cursor baja (↓)
3. Presiona `k` varias veces → cursor sube (↑)
4. Presiona `h` → cursor izquierda (←)
5. Presiona `l` → cursor derecha (→)
6. Suelta `CapsLock`

🎉 **¡Ya estás navegando sin mover las manos!**

> 💡 **Tip**: Si tocas `CapsLock` sin mantenerlo (tap), activas el **Dynamic Layer** que puede cambiar según la aplicación activa.

---

## 📚 Documentación Completa

### 🌱 Para Empezar

**Flujo de lectura recomendado:**

1. **[Introducción](doc/es/guia-usuario/introduccion.md)** - Entiende la filosofía y ventajas del sistema
2. **[Conceptos Clave](doc/es/guia-usuario/conceptos.md)** - Aprende cómo funciona la armonía Kanata + AHK
3. **[Instalación](doc/es/guia-usuario/instalacion.md)** - Configura el sistema paso a paso
4. **[Configuraciones de Kanata](doc/kanata-configs/README.md)** - Elige la configuración adecuada para ti
5. **[Modo Líder](doc/es/guia-usuario/modo-lider.md)** - Domina el sistema de menús contextuales
6. **[Sistema de Capas](doc/es/guia-usuario/layers.md)** - Crea tus propias capas personalizadas

### 🔌 Extendiendo el Sistema

- **[Catálogo de Plugins](doc/plugins/README.md)** - Explora plugins opcionales listos para usar
- **[Índice de Core Plugins](doc/es/guia-desarrollador/core-plugins-index.md)** - APIs fundamentales del sistema
- **[Arquitectura de Plugins](doc/es/guia-desarrollador/arquitectura-plugins.md)** - Crea tus propios plugins
- **[Crear Capas](doc/es/guia-desarrollador/crear-capas.md)** - Guía para desarrolladores

#### APIs de Core Plugins

- **[API Shell Exec](doc/es/guia-desarrollador/api-shell-exec.md)** - Ejecutar comandos y programas
- **[API Context Utils](doc/es/guia-desarrollador/api-context-utils.md)** - Detectar contexto del sistema
- **[API Dynamic Layer](doc/es/guia-desarrollador/api-dynamic-layer.md)** - Sistema de capas dinámicas
- **[API Hybrid Actions](doc/es/guia-desarrollador/api-hybrid-actions.md)** - Gestión del sistema
- **[API Notification System](doc/es/guia-desarrollador/api-notification.md)** - Sistema de notificaciones unificado
- **[Protocolo Tooltip API](doc/es/guia-desarrollador/Tooltip_Api_Protocol.md)** - Integración con tooltips C#

### 📖 Referencia

- **[Sistema de Keymaps](doc/es/guia-desarrollador/sistema-keymaps.md)** - Cómo funciona el registro de teclas
- **[Sistema Auto-Loader](doc/es/guia-desarrollador/sistema-auto-loader.md)** - Carga automática de plugins
- **[Changelog](CHANGELOG.md)** - Historial de versiones y cambios

---

## 🎬 Demos y Capturas

> 💡 **Próximamente**: Capturas de pantalla y GIFs demostrativos del sistema en acción

---

## 💡 Casos de Uso Comunes

### Para Desarrolladores
- Navegación rápida en código sin mouse
- Integración con Git para commits rápidos
- Lanzamiento de terminales y herramientas
- Gestión de ventanas y espacios de trabajo

### Para Usuarios de Productividad
- Navegación en Excel sin mouse
- Gestión rápida de carpetas y archivos
- Snippets de texto para respuestas frecuentes
- Control de energía y monitoreo del sistema

### Para Power Users
- Creación de capas personalizadas para aplicaciones específicas
- Automatización de flujos de trabajo repetitivos
- Integración con herramientas externas (ADB, VaultFlow, etc.)

---

## 🤝 Créditos

- **Autor**: [Wilberucx](https://github.com/Wilberucx) - Creador de Hybrid-CapsLock original y este fork con Kanata
- **Kanata**: [jtroo/kanata](https://github.com/jtroo/kanata) - Remapper de teclado multiplataforma a nivel kernel
- **AutoHotkey**: [AutoHotkey v2](https://www.autohotkey.com/) - Lenguaje de scripting para Windows

---

## 📄 Licencia

Este proyecto mantiene la misma licencia que el proyecto original Hybrid-CapsLock.

---

<div align="center">

**¿Listo para transformar tu productividad?**

[Comienza aquí →](doc/es/guia-usuario/introduccion.md)

</div>
