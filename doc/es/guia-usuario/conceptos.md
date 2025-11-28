# Conceptos Clave: La Armonía Híbrida

> 📍 **Navegación**: [Inicio](../../../README.md) > Guía de Usuario > Conceptos Clave

HybridCapsLock no es solo un script de AutoHotkey ni solo una configuración de Kanata. Es una **simbiosis** diseñada para obtener lo mejor de ambos mundos.

## ☯️ La Armonía (Harmony)

Esta solución logra una integración perfecta donde ambas herramientas coexisten sin pisarse entre sí:

### 🔄 Flujo de Interacción

```
┌──────────────────────────────────────────────────────────────┐
│  PASO 1: Presionas CapsLock + j                              │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  KANATA (Nivel Kernel) - Timing Perfecto                     │
│  ✓ Detecta CapsLock mantenido (tap-hold preciso)             │
│  ✓ Activa capa vim-nav                                       │
│  ✓ Convierte j → ↓ (flecha abajo)                            │
│  ✓ Envía F23 (tecla virtual) a Windows                       │
└────────────────────┬─────────────────────────────────────────┘
                     │
                     ▼
┌──────────────────────────────────────────────────────────────┐
│  AUTOHOTKEY (Nivel Lógico) - Inteligencia                    │
│  ✓ Detecta F23 (señal de Kanata)                             │
│  ✓ Verifica aplicación activa (Excel? Chrome? VS Code?)      │
│  ✓ Ejecuta acción contextual apropiada                       │
│  ✓ Muestra feedback visual (tooltips)                        │
└──────────────────────────────────────────────────────────────┘
```

### 🎯 División de Responsabilidades

1.  **Kanata (Nivel Kernel)**: Se encarga de lo que requiere *timing perfecto* y *fiabilidad absoluta*.
    *   **Homerow Mods**: Teclas que actúan como modificadores al mantenerlas y como letras al tocarlas. Kanata es superior aquí por trabajar a nivel de driver.
    *   **Tap-Hold**: Detección precisa de cuándo tocas vs. mantienes una tecla.
    *   **Remapeo Base**: Convierte `CapsLock` en teclas virtuales "invisibles" (como F24) para que AHK las detecte.

2.  **AutoHotkey (Nivel Lógico)**: Se encarga de la *inteligencia* y la *interfaz*.
    *   **Context-Aware**: Sabe qué ventana está activa y cambia el comportamiento.
    *   **Interfaz Visual**: Muestra los menús, tooltips y notificaciones.
    *   **Lógica Compleja**: Ejecuta scripts, lanza programas y maneja el portapapeles.

## 🔧 Flexibilidad de Integración

Aunque recomendamos usar Kanata para aprovechar los Homerow Mods (especialmente útil en laptops), el sistema es completamente flexible. El archivo `kanata.kbd` puede ser editado como desees, siempre y cuando la configuración en AutoHotkey coincida.

### Personalizando el "Puente"

La comunicación entre Kanata y AutoHotkey ocurre en `ahk/config/keymap.ahk`. Puedes adaptar esta sección para usar cualquier combinación que prefieras.

Si decides usar Kanata (Recomendado), AHK esperará las teclas virtuales que Kanata envía:

```autohotkey
; ahk/config/keymap.ahk

#SuspendExempt
#HotIf (LeaderLayerEnabled)
F24:: ActivateLeaderLayer()    ; Kanata envía F24 cuando haces CapsLock+Space
#HotIf

#HotIf (DYNAMIC_LAYER_ENABLED)
F23:: ActivateDynamicLayer()    ; Kanata envía F23 cuando tocas CapsLock
#HotIf
#SuspendExempt False
```

### Opción "Solo AutoHotkey"

Si prefieres no usar Kanata, puedes modificar `keymap.ahk` para usar atajos nativos de Windows directamente. Por ejemplo, si quieres activar el modo líder con `Ctrl + Shift + Espacio` o un `CapsLock` nativo de AHK:

```autohotkey
; Ejemplo sin Kanata
#SuspendExempt
#HotIf (LeaderLayerEnabled)
^+Space:: ActivateLeaderLayer()  ; Ctrl+Shift+Space activa el Leader
; O usando la sintaxis nativa de AHK para CapsLock
; CapsLock & Space:: ActivateLeaderLayer()
#HotIf
#SuspendExempt False
```

## 🧪 Probándolo en la Práctica

Para entender mejor esta armonía, prueba este experimento:

### Experimento 1: Ver la Diferencia de Timing

1. **Sin Kanata** (solo AHK): Los tap-hold pueden tener delay o falsos positivos
2. **Con Kanata**: El timing es instantáneo y preciso

### Experimento 2: Dynamic Layer en Acción

El sistema **Dynamic Layer** te permite asignar capas específicas a aplicaciones:

1. Abre **Excel**
2. Presiona `Leader → h → r` (Register Process)
3. Selecciona la capa "excel" de la lista
4. Ahora, cada vez que toques `CapsLock` (tap) en Excel, se activará automáticamente la capa de Excel

**¿Cómo funciona?**
- Kanata detecta el tap de `CapsLock` y envía `F23`
- AutoHotkey recibe `F23` y ejecuta `ActivateDynamicLayer()`
- Esta función verifica qué proceso está activo (ej: EXCEL.EXE)
- Busca en `data/layer_bindings.json` si hay una capa asignada
- Si existe, activa esa capa automáticamente

**Esto es el sistema Dynamic Layer adaptándose al contexto.**

> 💡 **Nota**: La navegación básica con `CapsLock (hold) + hjkl` siempre envía flechas según la configuración de `kanata.kbd`. El comportamiento específico por aplicación requiere crear y asignar capas personalizadas.

## 💡 Recomendación Profesional

Para una experiencia óptima:

1.  **Usa Kanata para la base**: Deja que maneje `CapsLock` y los modificadores en la fila central (Homerow Mods). Su rendimiento es inigualable para evitar errores de escritura.
2.  **Usa AutoHotkey para la magia**: Deja que AHK maneje todo lo que sucede *después* de activar una capa.

Esta arquitectura te da la robustez de un firmware de teclado custom (como QMK/ZMK) pero con la potencia de scripting de Windows.

---

## 📖 Siguiente Paso

Ahora que entiendes cómo funciona la armonía, es hora de **instalar y configurar** el sistema:

**→ [Guía de Instalación](instalacion.md)**

---

<div align="center">

[← Anterior: Introducción](introduccion.md) | [Volver al Inicio](../../../README.md) | [Siguiente: Instalación →](instalacion.md)

</div>
