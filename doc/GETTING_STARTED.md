# Guía de Inicio Rápido

Este documento proporciona los atajos esenciales y una guía de configuración rápida para que puedas empezar a usar HybridCapsLock en minutos.

## 🚀 Atajos Principales

### Gestión de Ventanas

| Atajo            | Acción                         |
| ---------------- | ------------------------------ |
| `CapsLock + q`   | Cerrar ventana                 |
| `CapsLock + f`   | Maximizar/Restaurar            |
| `CapsLock + Tab` | Navegador de ventanas mejorado |

### Navegación Rápida

| Atajo                | Acción                             |
| -------------------- | ---------------------------------- |
| `CapsLock + h/j/k/l` | Flechas direccionales (estilo Vim) |
| `CapsLock + e/d`     | Scroll suave abajo/arriba          |

### Edición de Texto

| Atajo              | Acción                             |
| ------------------ | ---------------------------------- |
| `CapsLock + s`     | Guardar (`Ctrl+S`)                 |
| `CapsLock + c/v/x` | Copiar/Pegar/Cortar                |
| `CapsLock + z`     | Deshacer                           |
| `CapsLock + a`     | Seleccionar todo                   |
| `CapsLock + o/t/w` | Abrir/Nueva pestaña/Cerrar pestaña |

### Funciones de Mouse

(No hay atajos de mouse en el modo modificador actualmente)

### Utilidades Especiales

| Atajo            | Acción                   |
| ---------------- | ------------------------ |
| `CapsLock + 5`   | Copiar ruta/URL actual   |
| `CapsLock + 9`   | Captura de pantalla      |
| `CapsLock + F10` | Toggle CapsLock original |

## 🔧 Configuración en 2 Minutos

Esta es una mini referencia para la configuración inicial. Para una guía exhaustiva, consulta el documento [CONFIGURATION.md](CONFIGURATION.md).

1.  Ejecuta `HybridCapsLock.ahk` al menos una vez para generar los archivos de configuración.
2.  Abre `config/configuration.ini` y ajusta las opciones más comunes:
    -   `[Behavior]`: `global_timeout_seconds`, `leader_timeout_seconds`, `show_confirmation_global`
    -   `[Layers]`: Habilita o deshabilita capas enteras (`nvim`, `excel`, `modifier`, `leader`).
    -   `[Tooltips]`: `enable_csharp_tooltips`, `options_menu_timeout`, `status_notification_timeout`
3.  Configura las capas que más uses (los archivos se encuentran en la carpeta `config/`):
    -   **Programas:** `programs.ini` (Define atajos para lanzar tus apps en `[ProgramMapping]` y cómo se ven en el menú en `[MenuDisplay]`)
    -   **Información Personal:** `information.ini` (Guarda snippets de texto en `[PersonalInfo]` y asígnales atajos en `[InfoMapping]`)
    -   **Timestamps:** `timestamps.ini` (Define tus formatos de fecha y hora preferidos).
    -   **Comandos:** `commands.ini` (Define comandos de sistema y organízalos en el menú).
4.  **Recarga los cambios:** Usa el atajo `leader → c → h → R` para aplicar la nueva configuración sin reiniciar el script.
