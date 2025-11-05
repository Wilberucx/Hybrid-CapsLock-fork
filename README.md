# Hybrid CapsLock - Sistema de Productividad Avanzado para AutoHotkey

![HybridCapsLock logo](img/Logo%20HybridCapsLock.png)

Este script transforma la tecla `CapsLock` en una potente herramienta de productividad con un comportamiento híbrido, inspirado en la eficiencia de editores como Vim. Ofrece un entorno de trabajo completamente personalizable para navegar, editar y gestionar tu sistema con una ergonomía mejorada.

## 🤔 ¿Por qué HybridCapsLock?

- **Eficiencia Modal:** Inspirado en Vim, el sistema de capas te permite hacer más sin levantar las manos del teclado, cambiando el comportamiento de las teclas según el contexto.
- **Ergonomía:** Reduce el movimiento de las manos y la tensión en los dedos al concentrar los atajos más comunes alrededor de la tecla `CapsLock`, una de las más accesibles y menos utilizadas.
- **Personalización Extrema:** Con un sistema de configuración modular de 5 archivos `.ini`, puedes adaptar cada capa, atajo y menú a tu flujo de trabajo específico sin tocar una línea de código.
- **Productividad Aumentada:** Automatiza tareas repetitivas, lanza programas, inserta texto y gestiona ventanas a una velocidad superior, minimizando el uso del ratón.

## ✨ Conceptos Clave

> Nota de terminología: En esta documentación usamos el término "leader" para referirnos a la combinación `CapsLock + Space`.

- **🔧 Modo Modificador (Mantener Pulsado):** `CapsLock` actúa como una tecla modificadora (similar a `Ctrl`) para atajos rápidos.
- **📝 Modo "Capa Nvim" (Toque Rápido):** Activa una capa de navegación y edición estilo Vim para moverte por el texto y el sistema de forma eficiente.
- **🎯 Modo Líder (`CapsLock + Space`):** Accede a un menú contextual con sub-capas organizadas para programas, ventanas, comandos y más.

## ⚙️ Instalación y Uso

### Requisitos
1. **Instalar:** [AutoHotkey v2.0](https://www.autohotkey.com/v2/)
2. **Instalar:** [Kanata](https://github.com/jtroo/kanata) - Remapper de teclado a nivel bajo

### Inicio Rápido

**Opción 1 - Todo-en-Uno (Recomendado)**:
```
Doble click en StartAll.ahk
```
Inicia automáticamente Kanata + HybridCapsLock.

**Opción 2 - Manual**:
1. Ejecutar `start_kanata.vbs`
2. Ejecutar `HybridCapsLock.ahk`

**Inicio automático (Opcional):** Crear un acceso directo de `StartAll.ahk` en la carpeta de inicio de Windows (`shell:startup`).

> **⚡ Nota Importante**: Este fork integra **Kanata** (ergonomía, homerow mods) con **AutoHotkey** (inteligencia, context-aware).  
> Ver [MIGRATION.md](MIGRATION.md) para arquitectura completa y [STARTUP.md](STARTUP.md) para configuración de inicio.

## 📚 Documentación Completa

Para una guía detallada sobre todos los atajos, capas, configuración avanzada y desarrollo, consulta nuestro portal de documentación:

- **[➡️ Ir a la Documentación Completa (Carpeta `/doc`)](doc/README.md)**

## 🚧 Desarrollo y Versiones

- Para ver el historial de cambios y versiones, revisa el archivo **[CHANGELOG.md](CHANGELOG.md)**.
- Las características en desarrollo y planes futuros se detallan en la documentación.
