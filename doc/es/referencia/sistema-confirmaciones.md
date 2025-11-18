# Sistema de Confirmaciones

El sistema de confirmaciones de HybridCapsLock proporciona diálogos de confirmación unificados que se adaptan automáticamente al sistema de tooltips activo (nativo o C#).

## 📋 Descripción General

El sistema detecta automáticamente si los tooltips C# están habilitados y presenta las confirmaciones usando la interfaz apropiada:

- **Con tooltips C#**: Menú estilizado con tema visual
- **Sin tooltips C#**: Tooltip nativo simple como fallback

## ⚙️ Configuración

### Habilitar Tooltips C#

Para usar confirmaciones estilizadas, editar `config/settings.ahk`:

```ahk
TooltipConfig := {
    enabled: true,        // ← Cambiar a true para habilitar
    handles_input: true,  // ← Permite hotkeys Y/N
    exe_path: "src/ui/TooltipApp.exe"
}
```

### Configuración Recomendada

```ahk
TooltipConfig := {
    enabled: true,
    handles_input: true,
    exe_path: "src/ui/TooltipApp.exe"
}
```

## 🎯 Acciones que Requieren Confirmación

Las siguientes acciones muestran diálogos de confirmación:

| Acción | Combinación | Descripción |
|--------|------------|-------------|
| **Reload Script** | `leader + h + R` | Reinicia HybridCapsLock |
| **Exit Script** | `leader + h + e` | Cierra HybridCapsLock |
| **Git Add All** | `leader + c + g + a` | Ejecuta git add . |
| **Git Pull** | `leader + c + g + p` | Ejecuta git pull |
| **Sign Out** | `leader + o + o` | Cierra sesión del usuario |
| **Restart System** | `leader + o + r` | Reinicia el sistema |
| **Shutdown System** | `leader + o + S` | Apaga el sistema |

## 🎨 Interfaces de Usuario

### Confirmación con Tooltips C#

Cuando los tooltips C# están habilitados:

```
┌─────────────────────────┐
│     CONFIRM ACTION      │
├─────────────────────────┤
│ ▶ Restart System        │
│ ─────────────────────── │
│ Y ✓ Confirm             │
│ N ✗ Cancel              │
└─────────────────────────┘
```

**Controles:**
- `Y` o `y` → Confirmar acción
- `N`, `n`, o `Esc` → Cancelar acción
- Timeout: 10 segundos

### Confirmación con Tooltips Nativos

Cuando los tooltips C# están deshabilitados:

```
Execute: Restart System?
[y: Yes] [n/Esc: No]
```

**Controles:**
- `Y` o `y` → Confirmar acción  
- `N`, `n`, o `Esc` → Cancelar acción
- Timeout: 3 segundos

## 🔧 Implementación Técnica

### Función Principal

```ahk
ShowUnifiedConfirmation(description)
```

Esta función:
1. **Detecta** el sistema de tooltips activo
2. **Presenta** la interfaz apropiada
3. **Captura** la entrada del usuario
4. **Retorna** `true` (confirmado) o `false` (cancelado)

### Lógica de Detección

```ahk
; Prioridad de detección:
if (IsSet(HybridConfig) && HybridConfig.tooltips.enabled) {
    // Usar tooltips C#
} else if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
    // Usar tooltips C# (legacy)
} else {
    // Usar tooltips nativos
}
```

### Ubicación en el Código

- **Función principal**: `src/core/keymap_registry.ahk` → `ShowUnifiedConfirmation()`
- **Integración**: `src/core/keymap_registry.ahk` → `ExecuteKeymapAtPath()`
- **Hotkeys C#**: `src/ui/tooltip_csharp_integration.ahk` → `HandleConfirmationSelection()`

## 🐛 Debug y Logging

El sistema incluye logging detallado para diagnóstico:

```
[2024-12-19 10:15:30] ShowUnifiedConfirmation -> C# Confirmation | Restart System
[2024-12-19 10:15:32] HandleConfirmationSelection -> C# Hotkey Result | User selected | Result: CONFIRMED
```

**Archivo de log**: `tmp_rovodev_confirmation_debug.log` (si debug está habilitado)

## ⚠️ Solución de Problemas

### Problema: Confirmación No Aparece

**Causa**: Keymap no tiene `confirm: true`

**Solución**: Verificar en `config/keymap.ahk`:
```ahk
RegisterKeymap("category", "key", "Description", ActionFunction, true) // ← confirm flag
```

### Problema: "Unknown Option" con Tooltips C#

**Causa**: `handles_input: false` en configuración

**Solución**: Cambiar a `handles_input: true` en `config/settings.ahk`

### Problema: Posición Incorrecta

**Causa**: Configuración de posición en tema

**Solución**: Verificar configuración de tema en `config/colorscheme.ahk`

## 📚 Ver También

- [Sistema de Keymaps](keymap-system.md)
- [Sistema de Tooltips](../developer-guide/tooltip-system.md)
- [Configuración](../getting-started/configuration.md)