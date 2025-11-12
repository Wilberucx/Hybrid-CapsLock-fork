# Templates para Layers

Este directorio contiene plantillas para crear nuevos layers en HybridCapslock.

## 📄 Archivos Disponibles

### `template_layer.ahk`
**Plantilla completa y documentada para crear layers dinámicos**

Este es el archivo principal que debes copiar para crear un nuevo layer. Incluye:

✓ **Documentación exhaustiva** de cada función y sección
✓ **Explicaciones en español** de cómo funciona cada parte
✓ **Ejemplos de uso** para cada función
✓ **Diagramas de flujo** explicando la ejecución
✓ **Sistema de ayuda automático** que lee keymaps del registry
✓ **Compatibilidad completa** con SwitchToLayer y auto_loader

### Características Incluidas

1. **Configuración:** Variables globales y feature flags
2. **Función de Activación:** Punto de entrada público (`ActivateLayer`)
3. **Hooks de Activación/Desactivación:** Funciones automáticas del sistema
4. **Acciones Específicas:** Funciones de control del layer (Exit, etc.)
5. **Sistema de Ayuda:** Help dinámico que lee KeymapRegistry automáticamente
6. **Registro de Keymaps:** Ejemplos de cómo registrar teclas

## 🚀 Inicio Rápido

### Paso 1: Copiar Template
```bash
cp doc/templates/template_layer.ahk src/layer/mi_layer.ahk
```

### Paso 2: Reemplazar Placeholders

Buscar y reemplazar en tu editor:

| Buscar | Reemplazar | Ejemplo |
|--------|-----------|---------|
| `LAYER_ID` | Tu identificador (lowercase) | `excel`, `scroll`, `myfeature` |
| `LAYER_NAME` | Tu nombre (PascalCase) | `Excel`, `Scroll`, `MyFeature` |
| `LAYER_DISPLAY` | Texto para mostrar | `EXCEL LAYER`, `MY FEATURE` |

### Paso 3: Registrar Keymaps

En `config/keymap.ahk`, agregar:

```autohotkey
RegisterMyFeatureKeymaps() {
    ; Acciones básicas
    RegisterKeymap("myfeature", "h", "Move Left", VimMoveLeft, false, 1)
    RegisterKeymap("myfeature", "j", "Move Down", VimMoveDown, false, 2)
    
    ; Salir del layer
    RegisterKeymap("myfeature", "Escape", "Exit", MyFeatureExit, false, 10)
    
    ; Sistema de ayuda
    RegisterKeymap("myfeature", "?", "Toggle Help", MyFeatureToggleHelp, false, 100)
}

; Llamar dentro de InitializeCategoryKeymaps():
RegisterMyFeatureKeymaps()
```

### Paso 4: Activar desde Leader

```autohotkey
RegisterKeymap("leader", "m", "My Feature", ActivateMyFeatureLayer, false)
```

## 📚 Documentación Adicional

### Dentro del Template
El archivo `template_layer.ahk` incluye documentación detallada inline:

- **Sección 1:** Configuración y variables globales
- **Sección 2:** Función de activación (punto de entrada)
- **Sección 3:** Hooks de activación/desactivación
- **Sección 4:** Acciones específicas del layer
- **Sección 5:** Sistema de ayuda dinámico

### Referencia de Funciones
Ver `doc/LAYER_FUNCTIONS_REFERENCE.md` para:
- Lista completa de funciones del sistema
- Parámetros y valores de retorno
- Ejemplos de uso
- Flujos de ejecución completos

### Guías Adicionales
- `doc/CREATING_NEW_LAYERS.md` - Guía paso a paso
- `doc/KEYMAP_SYSTEM_UNIFIED.md` - Sistema de keymaps
- `doc/DEBUG_SYSTEM.md` - Debugging de layers

## ❓ Preguntas Frecuentes

### ¿Qué es LAYER_ID vs LAYER_NAME?

- **LAYER_ID** (lowercase): Identificador técnico usado en funciones del sistema
  - Ejemplo: `"excel"`, `"scroll"`, `"myfeature"`
  - Usado en: `SwitchToLayer()`, `ListenForLayerKeymaps()`, `RegisterKeymap()`

- **LAYER_NAME** (PascalCase): Nombre usado en funciones y variables
  - Ejemplo: `"Excel"`, `"Scroll"`, `"MyFeature"`
  - Usado en: `ActivateExcelLayer()`, `isExcelLayerActive`

### ¿Por qué ListenForLayerKeymaps() es bloqueante?

Esta función mantiene un loop infinito que:
1. Espera inputs del usuario
2. Ejecuta keymaps registrados
3. Continúa hasta que la variable de estado sea false

El código después de `ListenForLayerKeymaps()` NO se ejecuta hasta que el layer se desactive.

### ¿Cómo funciona el sistema de ayuda automático?

El sistema de ayuda:
1. Lee `KeymapRegistry[LAYER_ID]` automáticamente
2. Genera el menú con todos los keymaps registrados
3. Muestra tooltip (C# o nativo)
4. Se actualiza automáticamente cuando registras nuevos keymaps

**NO necesitas escribir el menú manualmente** - el sistema lo genera por ti.

### ¿Dónde van las acciones genéricas vs específicas?

- **Específicas del layer** → `src/layer/{nombre}_layer.ahk`
  - Ejemplo: `ExcelExit()`, `ScrollToggleHelp()`
  
- **Genéricas/reutilizables** → `src/actions/`
  - Ejemplo: `VimMoveLeft()`, `ScrollUp()`, `GitCommit()`

## 🔗 Ejemplos Reales

Ver layers existentes como referencia:

- **Excel Layer:** `src/layer/excel_layer.ahk`
  - Layer completo con sistema de ayuda
  - Keymaps de navegación estilo Vim
  
- **Scroll Layer:** `src/layer/scroll_layer.ahk`
  - Layer simple de scroll
  - Ejemplo de tooltip persistente
  
- **Nvim Layer:** `src/layer/nvim_layer.ahk`
  - Layer complejo con múltiples modos
  - Navegación jerárquica avanzada

## ✅ Checklist de Integración

Antes de considerar tu layer completo:

- [ ] Template copiado y placeholders reemplazados
- [ ] LAYER_ID (lowercase) usado en todas las funciones del sistema
- [ ] LAYER_NAME (PascalCase) usado en nombres de funciones
- [ ] Acciones específicas implementadas
- [ ] Keymaps registrados en `config/keymap.ahk`
- [ ] Sistema de ayuda funcional (tecla `?`)
- [ ] Status tooltips implementados
- [ ] Activación desde leader menu configurada
- [ ] Probado: activación, keymaps, desactivación
- [ ] Probado: sistema de ayuda muestra keymaps correctos
- [ ] Probado: navegación entre layers funciona

## 🎯 Próximos Pasos

Después de crear tu layer:

1. **Testear exhaustivamente** todas las funciones
2. **Documentar** keymaps en comentarios
3. **Agregar ejemplos** de uso si es complejo
4. **Considerar** si necesitas tooltips customizados
5. **Optimizar** performance si tiene muchas acciones

---

**¿Necesitas ayuda?** Consulta `doc/LAYER_FUNCTIONS_REFERENCE.md` para referencia completa de funciones.
