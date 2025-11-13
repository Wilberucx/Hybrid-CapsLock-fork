# 📚 Documentación de HybridCapslock (Español)

Documentación completa para el sistema de personalización de teclado HybridCapslock.

**[🌍 View in English](../en/README.md)** | **[← Volver al Índice Principal](../README.md)**

---

## 📖 Tabla de Contenidos

### 🚀 Primeros Pasos

- **[Guía de Inicio Rápido](primeros-pasos/inicio-rapido.md)** - Comienza en 5 minutos
- **[Instalación](primeros-pasos/instalacion.md)** - Instrucciones detalladas de instalación
- **[Configuración](primeros-pasos/configuracion.md)** - Configura HybridCapslock según tus necesidades

### 👤 Guía de Usuario

- **[Homerow Mods](guia-usuario/homerow-mods.md)** - Usa las teclas de la fila principal como modificadores
- **[Modo Líder](guia-usuario/modo-lider.md)** - Combinaciones poderosas con tecla líder
- **[Capa Nvim](guia-usuario/capa-nvim.md)** - Navegación estilo Vim en todas partes
- **[Modo Colon de Nvim](guia-usuario/modo-colon-nvim.md)** - Modo comando para usuarios avanzados
- **[Capa Excel](guia-usuario/capa-excel.md)** - Capa especializada para productividad en Excel
- **[Capas Numpad y Media](guia-usuario/capas-numpad-media.md)** - Teclado numérico y controles multimedia

### 🔧 Guía de Desarrollador

- **[Crear Nuevas Capas](guia-desarrollador/crear-capas.md)** - Construye tus propias capas personalizadas
- **[Sistema Auto-Loader](guia-desarrollador/sistema-auto-loader.md)** - Cómo funciona la carga automática de módulos
- **[Sistema de Keymaps](guia-desarrollador/sistema-keymaps.md)** - Sistema unificado de registro de keymaps
- **[Referencia de Funciones de Capas](guia-desarrollador/referencia-funciones-capas.md)** - Referencia completa de la API
- **[Guía de Nombres de Capas](guia-desarrollador/guia-nombres-capas.md)** - Convenciones y mejores prácticas
- **[Hotkeys vs Keymaps](guia-desarrollador/hotkeys-vs-keymaps.md)** - Entendiendo la diferencia
- **[Guía de Pruebas](guia-desarrollador/pruebas.md)** - Procedimientos de pruebas manuales

### 📋 Referencia Técnica

- **[Cómo Funciona Register](referencia/como-funciona-register.md)** - Análisis profundo del sistema de registro
- **[Sistema de Debug](referencia/sistema-debug.md)** - Herramientas y técnicas de depuración
- **[Sistema Declarativo](referencia/sistema-declarativo.md)** - Visión general del enfoque declarativo
- **[Resumen de Migración](referencia/resumen-migracion.md)** - Cambios desde versiones anteriores
- **[Refactorización del Sistema de Capas](referencia/refactor-sistema-capas.md)** - Cambios en la arquitectura del sistema de capas
- **[Cambios en el Inicio](referencia/cambios-inicio.md)** - Modificaciones recientes en la secuencia de inicio

---

## 🎯 Enlaces Rápidos

### Guías Más Populares

1. [Homerow Mods](guia-usuario/homerow-mods.md) - La base de la escritura eficiente
2. [Crear Nuevas Capas](guia-desarrollador/crear-capas.md) - Extiende HybridCapslock
3. [Modo Líder](guia-usuario/modo-lider.md) - Domina los atajos de teclado

### Tareas Comunes

- **Personalizar atajos**: Ver [Guía de Configuración](primeros-pasos/configuracion.md)
- **Agregar nueva capa**: Seguir [Crear Nuevas Capas](guia-desarrollador/crear-capas.md)
- **Solucionar problemas**: Revisar [Sistema de Debug](referencia/sistema-debug.md)
- **Entender arquitectura**: Leer [Sistema Declarativo](referencia/sistema-declarativo.md)

---

## 🏗️ Arquitectura del Sistema

HybridCapslock usa una arquitectura híbrida que combina:

- **Kanata** (Bajo nivel)
  - Interceptación de teclas a nivel hardware
  - Timing de homerow mods
  - Teclas modificadoras rápidas y confiables

- **AutoHotkey** (Alto nivel)
  - Lógica contextual según la aplicación
  - Keybindings y macros complejas
  - Retroalimentación visual (tooltips)
  - Gestión de capas

### Estructura del Proyecto

```
HybridCapslock/
├── src/
│   ├── core/           # Sistema central (config, loader, persistencia)
│   ├── actions/        # Módulos de acciones (carga automática)
│   ├── layer/          # Implementaciones de capas (carga automática)
│   └── ui/             # Interfaz de usuario (tooltips)
├── config/             # Archivos de configuración del usuario
│   ├── keymap.ahk      # Definiciones principales de keymaps
│   ├── settings.ahk    # Configuración del sistema
│   ├── colorscheme.ahk # Esquema de colores de UI
│   └── ../../../config/kanata.kbd      # Configuración de Kanata
├── data/               # Datos en tiempo de ejecución (estado de capas, registro)
└── doc/                # Documentación (¡estás aquí!)
```

---

## 🔍 Conceptos Clave

### Capas

Estados modales que cambian el comportamiento del teclado (como los modos de Vim). Cada capa puede definir:

- Keybindings personalizados
- Indicadores visuales (tooltips)
- Comportamiento específico por aplicación
- Activación/desactivación automática

### Homerow Mods

Usa las teclas de la fila principal como teclas modificadoras al mantenerlas presionadas:

- `a` → Alt (al mantener)
- `s` → Shift (al mantener)
- `d` → Ctrl (al mantener)
- `f` → Win (al mantener)

Distribución espejo en la mano derecha: `j/k/l/;`

### Auto-Loader

Detecta y carga automáticamente:

- Nuevos archivos de capas en `src/layer/`
- Nuevos archivos de acciones en `src/actions/`
- ¡No necesitas editar los includes manualmente!

### Sistema Declarativo

Registra keymaps de forma declarativa:

```ahk
RegisterKeymaps("nombre_capa", [
    {key: "h", desc: "Mover Izquierda", action: "Send {Left}"},
    {key: "j", desc: "Mover Abajo", action: "Send {Down}"},
    {key: "k", desc: "Mover Arriba", action: "Send {Up}"},
    {key: "l", desc: "Mover Derecha", action: "Send {Right}"}
])
```

---

## 📚 Recursos Adicionales

### Plantillas

- [Plantilla de Capa](../templates/template_layer.ahk) - Base para nuevas capas

### Notas de Desarrollo

Ver [`../develop/`](../develop/) para notas técnicas de implementación:

- Lógica de mini-capa V de Excel
- Implementación del modo VV de Excel
- Implementación de mini-capa GG
- Problemas y soluciones de tooltips

---

## 🤝 Contribuir

¿Encontraste un error en la documentación? ¿Quieres agregar más ejemplos?

1. Edita el archivo `.md` relevante
2. Mantén la versión en inglés sincronizada (o nota que se necesita traducción)
3. Actualiza el changelog en el [README](../../README.md) principal

---

## 📜 Licencia de la Documentación

Esta documentación es parte del proyecto HybridCapslock. Ver [LICENSE principal para detalles.

---

**Versión**: 2.0.0  
**Última Actualización**: 2025-01-XX  
**[🌍 View in English](../en/README.md)** | **[← Volver al Índice Principal](../README.md)**
