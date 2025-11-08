# Layer Templates

Este directorio contiene plantillas reutilizables para crear nuevas capas persistentes en Hybrid-CapsLock.

---

## 📦 Contenido

### **1. `layer_template.ahk`**
Plantilla genérica completamente funcional para crear capas persistentes.

**Características:**
- ✅ Exit key configurable (Esc, Shift+n, toggle, etc.)
- ✅ Sistema de ayuda integrado con `?`
- ✅ Tooltips C# + fallback nativo
- ✅ Whitelist/Blacklist de aplicaciones
- ✅ Soporte para sub-modos (mini-capas)
- ✅ Carga dinámica de configuración (opcional)
- ✅ Comentarios instructivos detallados

**Uso:**
```bash
# Copiar plantilla a src/layer/
cp doc/templates/layer_template.ahk src/layer/my_layer.ahk

# Editar y cambiar LAYER_NAME
# Definir hotkeys específicos
# Incluir en init.ahk
# Registrar en command_system_init.ahk
```

---

### **2. `example_browser_layer.ahk`**
Ejemplo práctico de una capa para navegación en navegadores web.

**Demuestra:**
- ✅ Cómo seguir la plantilla paso a paso
- ✅ Navegación estilo Vim (hjkl, gg, G)
- ✅ Gestión de pestañas (t, w, [, ])
- ✅ Acciones de navegador (r reload, f find, b bookmark)
- ✅ Múltiples exit keys (Esc y q)
- ✅ Sistema de ayuda personalizado
- ✅ Filtrado por aplicaciones (solo navegadores)

**Uso como referencia:**
```bash
# Ver el ejemplo para entender la estructura
cat doc/templates/example_browser_layer.ahk

# Copiar y adaptar para tu caso de uso
cp doc/templates/example_browser_layer.ahk src/layer/my_custom_layer.ahk
```

---

## 📚 Documentación Completa

Para guía detallada, ver:
- **[doc/develop/PERSISTENT_LAYER_TEMPLATE.md](../develop/PERSISTENT_LAYER_TEMPLATE.md)** - Documentación exhaustiva
  - Arquitectura de capas persistentes
  - Guía paso a paso
  - Patrones de diseño
  - Ejemplos completos
  - Checklist para crear capas

---

## 🎯 Quick Start

### **Crear una nueva capa en 5 pasos:**

1. **Copiar plantilla**
   ```bash
   cp doc/templates/layer_template.ahk src/layer/database_layer.ahk
   ```

2. **Cambiar nombre de capa**
   ```ahk
   LAYER_NAME := "Database"  ; Línea 23
   ```

3. **Definir hotkeys**
   ```ahk
   ; En la sección "DEFINE YOUR LAYER'S HOTKEYS HERE"
   h::Send("{Left}")
   j::Send("{Down}")
   c::ConnectToDatabase()
   ```

4. **Incluir en init.ahk**
   ```ahk
   #Include src/layer/database_layer.ahk
   ```

5. **Registrar activación**
   ```ahk
   ; En command_system_init.ahk
   RegisterKeymapFlat("leader", "d", "Database Layer", ActivateMyLayer, false, 5)
   ```

---

## 🔍 Comparación: Template vs Ejemplo

| Aspecto | `layer_template.ahk` | `example_browser_layer.ahk` |
|---------|---------------------|----------------------------|
| **Propósito** | Base reutilizable | Referencia práctica |
| **Hotkeys** | Comentados (ejemplos) | Implementados (navegador) |
| **LAYER_NAME** | "MyLayer" (cambiar) | "Browser" (ejemplo) |
| **Exit Key** | Esc (configurable) | Esc + q (dos opciones) |
| **Funciones** | Genéricas (ActivateMyLayer) | Genéricas (mismo patrón) |
| **Comentarios** | Instrucciones detalladas | Menos comentarios |
| **Uso** | Copiar y personalizar | Ver y aprender |

---

## 💡 Casos de Uso

### **Cuándo usar `layer_template.ahk`:**
- ✅ Crear una capa completamente nueva desde cero
- ✅ Necesitas máxima flexibilidad
- ✅ Quieres entender toda la estructura

### **Cuándo usar `example_browser_layer.ahk`:**
- ✅ Crear una capa similar al ejemplo (navegador, editor, IDE)
- ✅ Ver implementación real y funcional
- ✅ Copiar y adaptar rápidamente

---

## 🎨 Patrones de Exit Key

Ambas plantillas soportan diferentes estrategias de salida:

### **Patrón 1: Escape (por defecto)**
```ahk
Esc:: {
    DeactivateMyLayer()
}
```

### **Patrón 2: Custom Key (e.g., Shift+n)**
```ahk
+n:: {
    DeactivateMyLayer()
    SetTempStatus("LAYER OFF", 1500)
}
```

### **Patrón 3: Same-Key Toggle**
```ahk
s:: {
    ToggleMyLayer()
}
```

### **Patrón 4: Multiple Options (ejemplo)**
```ahk
Esc:: DeactivateMyLayer()
q:: DeactivateMyLayer()
```

---

## 🏗️ Estructura de Archivos

```
Hybrid-CapsLock-fork/
├── doc/
│   ├── templates/              ← Plantillas aquí
│   │   ├── README.md           ← Este archivo
│   │   ├── layer_template.ahk  ← Plantilla base
│   │   └── example_browser_layer.ahk  ← Ejemplo funcional
│   └── develop/
│       └── PERSISTENT_LAYER_TEMPLATE.md  ← Documentación completa
├── src/
│   ├── layer/                  ← Capas implementadas
│   │   ├── excel_layer.ahk
│   │   ├── nvim_layer.ahk
│   │   ├── scroll_layer.ahk
│   │   └── [tu_nueva_capa.ahk]  ← Copia aquí desde templates
│   └── actions/                ← Funciones reutilizables
├── config/                     ← Archivos de configuración
│   ├── excel_layer.ini
│   └── [tu_capa_layer.ini]     ← Config opcional
└── init.ahk                    ← Incluir nuevas capas aquí
```

---

## ⚡ Pro Tips

1. **Mantén el patrón de nombres consistente:**
   - Template usa funciones genéricas (`ActivateMyLayer()`)
   - Esto permite copy-paste directo
   - Solo cambia `LAYER_NAME` y hotkeys

2. **Usa el ejemplo como referencia visual:**
   - Abre ambos archivos lado a lado
   - Compara estructura vs implementación
   - Entiende dónde personalizar

3. **No modifiques los templates:**
   - Siempre copia a `src/layer/`
   - Los templates deben permanecer puros
   - Facilita mantener consistencia

4. **Prueba incrementalmente:**
   - Define 2-3 hotkeys primero
   - Prueba activación y exit
   - Agrega más hotkeys gradualmente

---

## 🤝 Contribuir

Si creas una capa genérica útil, considera:
1. Documentarla
2. Crear un ejemplo en `doc/templates/`
3. Agregar a la documentación

**Ejemplos de capas genéricas útiles:**
- Editor layer (Vim navigation in any text editor)
- IDE layer (Code navigation shortcuts)
- Database layer (SQL client shortcuts)
- Media layer (Player controls)
- Terminal layer (Shell navigation)

---

## 📖 Ver También

- **[PERSISTENT_LAYER_TEMPLATE.md](../develop/PERSISTENT_LAYER_TEMPLATE.md)** - Documentación completa
- **[GENERIC_ROUTER_ARCHITECTURE.md](../develop/GENERIC_ROUTER_ARCHITECTURE.md)** - Leader menu system
- **[src/layer/excel_layer.ahk](../../src/layer/excel_layer.ahk)** - Ejemplo de capa compleja con sub-modos
- **[src/layer/nvim_layer.ahk](../../src/layer/nvim_layer.ahk)** - Ejemplo de sistema de modos múltiples

---

## ✅ Checklist Rápido

Antes de usar una plantilla:
- [ ] Leer [PERSISTENT_LAYER_TEMPLATE.md](../develop/PERSISTENT_LAYER_TEMPLATE.md)
- [ ] Decidir qué plantilla usar (base o ejemplo)
- [ ] Definir exit key strategy
- [ ] Planear hotkeys principales
- [ ] Verificar conflictos con capas existentes

Después de crear tu capa:
- [ ] Incluir en `init.ahk`
- [ ] Registrar activación
- [ ] Crear config INI (opcional)
- [ ] Probar todos los hotkeys
- [ ] Probar sistema de ayuda (`?`)
- [ ] Documentar (opcional)

---

**¡Feliz creación de capas!** 🚀
