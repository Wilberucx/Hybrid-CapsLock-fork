# Introducción a Hybrid CapsLock + Kanata

> 📍 **Navegación**: [Inicio](../../../README.md) > Guía de Usuario > Introducción

Este proyecto combina lo mejor de dos mundos: **[Kanata](https://github.com/jtroo/kanata)** (remapper de teclado a nivel bajo con timing perfecto para tap-hold y homerow mods) con **AutoHotkey** (inteligencia context-aware y lógica compleja). El resultado es un sistema de productividad ergonómico que transforma la tecla `CapsLock` y las teclas de la home row en una potente herramienta de navegación y edición, inspirado en editores como Vim.

## 🔗 Proyectos Relacionados

Este es un **fork especializado** del proyecto original [Hybrid-CapsLock](https://github.com/Wilberucx/Hybrid-CapsLock), creado para integrar [Kanata](https://github.com/jtroo/kanata) y aprovechar sus capacidades de remapeo a nivel de kernel.

- **[Hybrid-CapsLock (original)](https://github.com/Wilberucx/Hybrid-CapsLock) [Deprecated]**: Implementación pura con AutoHotkey v2, ideal para quienes prefieren una solución todo-en-uno sin dependencias externas.
- **[Kanata](https://github.com/jtroo/kanata)**: Remapper de teclado multiplataforma (por jtroo), especializado en tap-hold, homerow mods y timing preciso a nivel de driver.

## 🤔 ¿Por qué este Fork con Kanata?

Este fork combina las **fortalezas de Kanata** (ergonomía personalizable, timing perfecto) con las **fortalezas de AutoHotkey** (context-aware, lógica compleja, tooltips visuales):

### ✨ Ventajas de la Integración

- **🎯 Timing Perfecto:** Kanata maneja tap-hold a nivel de driver, eliminando falsos positivos y delay perceptible.
- **⚡ Ergonomía Superior:** CapsLock como hub central de navegación con detección hardware-level.
- **🧠 Inteligencia Context-Aware:** AutoHotkey detecta la aplicación activa, ventana, y adapta el comportamiento dinámicamente.
- **🎨 Visual Feedback:** Tooltips C# elegantes con información contextual y estado del sistema.
- **🔧 Personalización Extrema:** Sistema modular de configuración con archivos en `ahk/config` sin tocar código.
- **🧩 Filosofía Modular:** El sistema base es ligero. Tú decides qué características instalar copiando plugins desde `doc/plugins` a tu carpeta de usuario.
- **📚 Capas Dinámicas:** Creación de capas con `RegisterLayer` con lógica compleja y submenús organizados.

## 🎯 Tu Primer Uso

Después de instalar el sistema (ver [Instalación](instalacion.md)), aquí tienes un ejemplo práctico para entender el poder de Hybrid CapsLock:

### Ejemplo 1: Navegación Básica

Abre cualquier editor de texto (Notepad, VS Code, navegador, etc.) y escribe varias líneas de texto:

```
Línea 1: Esta es la primera línea
Línea 2: Esta es la segunda línea
Línea 3: Esta es la tercera línea
Línea 4: Esta es la cuarta línea
```

Ahora, **sin mover las manos de la fila principal**:

1. Mantén `CapsLock` y presiona `j` → El cursor baja una línea
2. Mantén `CapsLock` y presiona `k` → El cursor sube una línea
3. Mantén `CapsLock` y presiona `h` → El cursor se mueve a la izquierda
4. Mantén `CapsLock` y presiona `l` → El cursor se mueve a la derecha

🎉 **¡Acabas de navegar sin tocar las flechas ni el mouse!**

### Ejemplo 2: Modo Líder

Ahora probemos el sistema de menús:

1. Mantén `CapsLock` + presiona `Space`
2. Verás aparecer un menú visual en pantalla
3. Presiona `h` para ver el menú de "Hybrid Management"
4. Presiona `Escape` para salir

Este es el **Modo Líder**, un sistema de menús contextuales que organiza todas las funcionalidades del sistema.

### Ejemplo 3: Context-Aware

El sistema se adapta a la aplicación activa. Prueba esto:

1. Abre **Excel**
2. Mantén `CapsLock` + presiona `j/k` → Navega entre celdas
3. Abre un **navegador**
4. Mantén `CapsLock` + presiona `j/k` → Hace scroll en la página

El mismo atajo, **diferente comportamiento** según el contexto. Esto es la inteligencia context-aware de AutoHotkey.

## 🏗️ Arquitectura Visual

```
┌─────────────────────────────────────────────────────────┐
│                    TU TECLADO                           │
│  Presionas: CapsLock + j                                │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│               KANATA (Nivel Kernel)                     │
│  • Detecta CapsLock mantenido                           │
│  • Timing perfecto para tap-hold                        │
│  • Envía tecla virtual (F23) a Windows                  │
└────────────────────┬────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────┐
│            AUTOHOTKEY (Nivel Lógico)                    │
│  • Detecta F23 + j                                      │
│  • Verifica qué aplicación está activa                  │
│  • Ejecuta acción contextual:                           │
│    - Excel: Navega celda abajo                          │
│    - Navegador: Scroll down                             │
│    - Editor: Cursor abajo                               │
│  • Muestra tooltips visuales                            │
└─────────────────────────────────────────────────────────┘
```

Esta arquitectura híbrida te da:
- **Velocidad y precisión** de Kanata (nivel kernel)
- **Inteligencia y flexibilidad** de AutoHotkey (nivel aplicación)

---

## 📖 Siguiente Paso

Ahora que entiendes la filosofía del sistema, aprende cómo funciona la **armonía entre Kanata y AutoHotkey**:

**→ [Conceptos Clave: La Armonía Híbrida](conceptos.md)**

---

<div align="center">

[← Volver al Inicio](../../../README.md) | [Siguiente: Conceptos Clave →](conceptos.md)

</div>
