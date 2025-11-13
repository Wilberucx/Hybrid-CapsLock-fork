# Guía de Desarrollador

¡Bienvenido a la Guía de Desarrollador de HybridCapslock! Esta sección contiene información detallada para desarrolladores que desean extender, personalizar o contribuir a HybridCapslock.

---

## 📚 Tabla de Contenidos

### Comenzando con el Desarrollo
- **[Sistema Auto-Loader](../guia-desarrollador/sistema-auto-loader.md)** - Cómo funciona la carga automática de módulos
- **[Crear Nuevas Capas](crear-capas.md)** - Construye tus propias capas personalizadas
- **[Sistema de Keymaps](sistema-keymaps.md)** - Sistema unificado de registro de keymaps

### Conceptos Fundamentales
- **[Hotkeys vs Keymaps](hotkeys-vs-keymaps.md)** - Entendiendo la diferencia
- **[Referencia de Funciones de Capas](referencia-funciones-capas.md)** - Referencia completa de la API
- **[Guía de Nombres de Capas](guia-nombres-capas.md)** - Convenciones de nombres y mejores prácticas

### Pruebas y Calidad
- **[Guía de Pruebas](pruebas.md)** - Procedimientos de pruebas manuales

---

## 🚀 Inicio Rápido para Desarrolladores

### 1. Crea Tu Primera Capa

```ahk
; src/layer/mi_capa_personalizada.ahk

global MI_CAPA_PERSONALIZADA_ACTIVA := false

InitMiCapaPersonalizada() {
    RegisterKeymaps("mi_personalizada", [
        {key: "h", desc: "Acción Izquierda", action: "Send {Left}"},
        {key: "l", desc: "Acción Derecha", action: "Send {Right}"}
    ])
}

ActivateMiCapaPersonalizada() {
    MI_CAPA_PERSONALIZADA_ACTIVA := true
    ActivateLayer("mi_personalizada")
    ShowLayerTooltip("MI CAPA PERSONALIZADA")
}

DeactivateMiCapaPersonalizada() {
    MI_CAPA_PERSONALIZADA_ACTIVA := false
    DeactivateLayer("mi_personalizada")
    HideLayerTooltip()
}

InitMiCapaPersonalizada()
```

### 2. Recarga y Prueba

- Presiona `Ctrl+Alt+R` para recargar
- El auto-loader detectará tu nueva capa automáticamente
- ¡No necesitas editar includes manualmente!

### 3. Asigna Tecla de Activación

Edita `config/keymap.ahk`:

```ahk
F13::ToggleMiCapaPersonalizada()
```

---

## 🏗️ Visión General de la Arquitectura

### Estructura del Proyecto

```
HybridCapslock/
├── src/
│   ├── core/           # Componentes del sistema central
│   │   ├── auto_loader.ahk
│   │   ├── keymap_registry.ahk
│   │   └── config.ahk
│   ├── actions/        # Módulos de acciones (carga automática)
│   │   ├── git_actions.ahk
│   │   ├── power_actions.ahk
│   │   └── ...
│   ├── layer/          # Implementaciones de capas (carga automática)
│   │   ├── nvim_layer.ahk
│   │   ├── excel_layer.ahk
│   │   └── ...
│   └── ui/             # Interfaz de usuario (tooltips)
├── config/             # Configuración del usuario
│   ├── keymap.ahk
│   ├── settings.ahk
│   └── kanata.kbd
└── data/               # Datos en tiempo de ejecución
    ├── layer_state.ini
    └── layer_registry.ini
```

### Componentes Clave

1. **Auto-Loader** - Carga automáticamente archivos `.ahk` desde `src/layer/` y `src/actions/`
2. **Keymap Registry** - Registro y gestión centralizada de keybindings
3. **Sistema de Capas** - Capas modales que pueden activarse/desactivarse
4. **Sistema de Tooltip** - Retroalimentación visual usando integración con C#

---

## 📖 Guías Esenciales

### Para Desarrolladores Nuevos
1. Comienza con: [Sistema Auto-Loader](../guia-desarrollador/sistema-auto-loader.md)
2. Luego lee: [Crear Nuevas Capas](crear-capas.md)
3. Entiende: [Hotkeys vs Keymaps](hotkeys-vs-keymaps.md)

### Para Desarrollo Avanzado
1. Estudia: [Sistema de Keymaps](sistema-keymaps.md)
2. Referencia: [Referencia de Funciones de Capas](referencia-funciones-capas.md)
3. Sigue: [Guía de Nombres de Capas](guia-nombres-capas.md)

---

## 🔧 Flujo de Trabajo de Desarrollo

### 1. Configurar Entorno de Desarrollo

```bash
# Habilitar modo debug
# Edita config/settings.ahk:
global DEBUG_MODE := true
```

### 2. Descargar DebugView

- [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview) para logging
- Ejecutar como Administrador para ver logs

### 3. Hacer Cambios

- Edita o crea archivos en `src/layer/` o `src/actions/`
- Usa `OutputDebug()` para logging

### 4. Probar

- Recarga: `Ctrl+Alt+R`
- Revisa DebugView para logs
- Prueba funcionalidad manualmente

### 5. Deshabilitar Módulo (si es necesario)

Mueve a carpeta `no_include/` para deshabilitar temporalmente:

```bash
mv src/layer/experimental.ahk src/layer/no_include/
```

---

## 💡 Mejores Prácticas

### Estilo de Código

1. **Usa nombres descriptivos**: `nvim_layer.ahk` no `layer1.ahk`
2. **Comenta tu código**: Explica el "por qué", no solo el "qué"
3. **Usa OutputDebug**: Ayuda a futuros desarrolladores (y a ti mismo) a depurar
4. **Sigue convenciones**: Ver [Guía de Nombres de Capas](guia-nombres-capas.md)

### Pruebas

1. **Prueba en aislamiento**: Usa `no_include/` para deshabilitar otros módulos
2. **Prueba casos extremos**: ¿Qué pasa cuando la capa ya está activa?
3. **Prueba interacciones**: ¿Entra en conflicto con otras capas?
4. **Pruebas manuales**: Sigue [Guía de Pruebas](pruebas.md)

### Rendimiento

1. **Evita operaciones pesadas en hotkeys**: Usa timers/threads si es necesario
2. **Cachea valores**: No recalcules en cada pulsación de tecla
3. **Perfila con DebugView**: Verifica tiempo de ejecución

---

## 🤝 Contribuir

### Antes de Contribuir

1. Lee todas las guías en esta sección
2. Revisa capas existentes como ejemplos
3. Prueba exhaustivamente
4. Documenta tus cambios

### Checklist de Revisión de Código

- [ ] El código sigue las convenciones de nombres
- [ ] Todas las funciones tienen `OutputDebug` para operaciones importantes
- [ ] La capa tiene funciones `Init*()`, `Activate*()`, `Deactivate*()`
- [ ] Los keymaps están registrados de forma declarativa
- [ ] No hay conflictos con capas existentes
- [ ] Probado manualmente
- [ ] Documentación actualizada

---

## 📚 Recursos Adicionales

- **[Plantillas](../../templates/)** - Código base para nuevas capas
- **[Notas de Desarrollo](../../develop/)** - Notas técnicas de implementación
- **[Documentación de Referencia](../referencia/)** - Detalles de arquitectura del sistema

---

**[🌍 View in English](../../en/developer-guide/README.md)** | **[← Volver al Índice de Documentación](../README.md)**
