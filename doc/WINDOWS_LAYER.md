# Capa de Ventanas (Líder: leader → `w`)

> Referencia rápida
> - Confirmaciones: no aplica (acciones inmediatas)
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

Esta capa proporciona herramientas avanzadas para la gestión de ventanas, división de pantalla y herramientas de zoom.

## 🎯 Cómo Acceder

1. **Activa el Líder:** Presiona `leader`
2. **Entra en Capa Windows:** Presiona `w`
3. **Ejecuta una acción:** Presiona una de las teclas del mapa

## 🪟 División de Pantalla (Splits)

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `2` | **Split 50/50** | Ventana activa ocupa mitad izquierda |
| `3` | **Split 33/67** | Ventana activa ocupa tercio izquierdo |
| `4` | **Quarter Split** | Ventana en esquina superior izquierda |

## ⚡ Acciones de Ventana

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `x` | **Cerrar** | Cierra la ventana activa (`Alt+F4`) |
| `m` | **Maximizar/Restaurar** | Alterna entre maximizar y restaurar |
| `-` | **Minimizar** | Minimiza la ventana activa |

## 🔍 Herramientas de Zoom

| Tecla | Herramienta | Combinación Enviada | Descripción |
|-------|-------------|-------------------|-------------|
| `d` | **Draw** | `Ctrl+Alt+Shift+2` | Herramienta de dibujo/anotación |
| `z` | **Zoom** | `Ctrl+Alt+Shift+1` | Zoom básico |
| `c` | **Zoom with Cursor** | `Ctrl+Alt+Shift+4` | Zoom que sigue el cursor |

> **Nota:** Estas herramientas de zoom están diseñadas para trabajar con aplicaciones que soporten estas combinaciones de teclas específicas.

## 🔄 Cambio de Ventanas Persistente

### Modo Blind Switch
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `j` | **Siguiente** | Cambia a la siguiente ventana sin vista previa |
| `k` | **Anterior** | Cambia a la ventana anterior sin vista previa |

**Controles en Modo Blind:**
- `j/k` - Continuar navegando
- `Enter/Esc` - Salir del modo

### Modo Visual Switch
| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `l` | **Siguiente** | Cambia con vista previa (Alt+Tab visual) |
| `h` | **Anterior** | Cambia hacia atrás con vista previa |

**Controles en Modo Visual:**
- `l/h` o `→/←` - Continuar navegando
- `Enter` - Confirmar selección
- `Esc` - Cancelar y volver a ventana original

## 🎮 Navegación en el Menú

- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú líder principal
- **Timeout:** 7 segundos de inactividad cierra automáticamente

## 💡 Consejos de Uso

1. **Splits rápidos:** Usa `2` para dividir pantalla rápidamente en tareas multitarea
2. **Zoom tools:** Ideal para presentaciones o cuando necesitas magnificar contenido
3. **Switch persistente:** Perfecto para alternar entre múltiples ventanas sin levantar las manos del teclado
4. **Combinaciones:** Puedes usar splits + zoom tools en secuencia para configuraciones específicas

## 🔧 Personalización

Para añadir nuevas funciones de ventana:

1. Edita `init.ahk`
2. Busca la sección `if (_leaderKey = "w")`
3. Añade la nueva tecla al `Input` statement
4. Añade un nuevo `Case` en el `Switch _winAction`
5. Actualiza `ShowWindowMenu()` para mostrar la nueva opción

## ⚠️ Notas Importantes

- Las herramientas de zoom requieren que la aplicación objetivo soporte las combinaciones `Ctrl+Alt+Shift+[1,2,4]`
- Los splits funcionan mejor en monitores con resolución 1920x1080 o superior
- El modo visual switch puede no funcionar correctamente con algunas aplicaciones en pantalla completa