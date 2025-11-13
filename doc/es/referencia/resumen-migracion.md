# Resumen de Migración de Configuración

## Descripción General

Este documento resume los cambios importantes en la configuración entre versiones de HybridCapslock y proporciona una guía de migración para usuarios que actualizan desde versiones anteriores.

---

## 🔄 Migración de v1.x a v2.0

### Cambios Principales

#### 1. Sistema de Configuración

**Antes (v1.x):**
```ahk
; Configuración dispersa en múltiples archivos
; config.ahk
; settings.ini
; layer_config.ahk
```

**Ahora (v2.0):**
```ahk
; Centralizado en config/
config/
├── settings.ahk      ; Configuración principal
├── keymap.ahk        ; Definiciones de keymaps
├── colorscheme.ahk   ; Esquema de colores UI
└── ../../../config/kanata.kbd        ; Configuración de Kanata
```

#### 2. Sistema de Capas

**Antes (v1.x):**
```ahk
; Capas con hotkeys manuales
#If LayerActive
h::Send {Left}
#If
```

**Ahora (v2.0):**
```ahk
; Sistema declarativo con RegisterKeymaps
RegisterKeymaps("layer_name", [
    {key: "h", desc: "Left", action: "Send {Left}"}
])
```

#### 3. Persistencia de Estado

**Antes (v1.x):**
```ahk
; Sin persistencia
; Estado se perdía al reiniciar
```

**Ahora (v2.0):**
```ahk
; Estado guardado en data/
data/
├── layer_state.ini    ; Estado de capas
└── layer_registry.ini ; Registro de capas
```

---

## 📝 Guía de Migración Paso a Paso

### Paso 1: Backup

```bash
# Hacer backup de configuración antigua
cp -r config/ config.backup/
cp -r data/ data.backup/
```

### Paso 2: Actualizar Estructura

Mover archivos a nueva ubicación:

```bash
# Antigua: config.ahk
# Nueva: config/settings.ahk

# Antigua: keymaps.ahk
# Nueva: config/keymap.ahk
```

### Paso 3: Migrar Definiciones de Capas

**Antes:**
```ahk
; En layer_custom.ahk
ActivateCustomLayer() {
    Hotkey, h, CustomLayerH, On
    Hotkey, j, CustomLayerJ, On
}

CustomLayerH() {
    Send {Left}
}
CustomLayerJ() {
    Send {Down}
}
```

**Después:**
```ahk
; En src/layer/custom_layer.ahk
InitCustomLayer() {
    RegisterKeymaps("custom", [
        {key: "h", desc: "Left", action: "Send {Left}"},
        {key: "j", desc: "Down", action: "Send {Down}"}
    ])
}

ActivateCustomLayer() {
    ActivateLayer("custom")
    ShowLayerTooltip("CUSTOM LAYER")
}
```

### Paso 4: Actualizar Kanata Config

**Antes (v1.x):**
```kbd
;; kanata.cfg
(defalias
  a (tap-hold 200 200 a lalt)
)
```

**Después (v2.0):**
```kbd
;; ../../../config/kanata.kbd
(defalias
  a (tap-hold 200 150 a lalt)  ; Timing mejorado
)
```

---

## 🆕 Nuevas Características en v2.0

### Auto-Loader

Ya no necesitas incluir manualmente archivos:

```ahk
; ❌ Antes: Editar init.ahk manualmente
#Include src/layer/mi_layer.ahk

; ✅ Ahora: Solo crear el archivo
; src/layer/mi_layer.ahk
; ¡Automáticamente se carga!
```

### Sistema Declarativo

```ahk
; Keymaps auto-documentados con tooltips
RegisterKeymaps("nvim", [
    {key: "h", desc: "Move Left", action: "Send {Left}"},
    {key: "j", desc: "Move Down", action: "Send {Down}"}
])
```

### Tooltips en C#

```ahk
; Tooltips más elegantes y performantes
ShowLayerTooltip("NVIM LAYER ACTIVE")
```

---

## ⚠️ Breaking Changes

### 1. Nombres de Funciones

| v1.x | v2.0 |
|------|------|
| `ActivateNvimMode()` | `ActivateNvimLayer()` |
| `DeactivateNvimMode()` | `DeactivateNvimLayer()` |
| `ShowTooltip()` | `ShowLayerTooltip()` |
| `HideTooltip()` | `HideLayerTooltip()` |

### 2. Variables Globales

| v1.x | v2.0 |
|------|------|
| `NVIM_MODE_ACTIVE` | `NVIM_LAYER_ACTIVE` |
| `EXCEL_MODE_ON` | `EXCEL_LAYER_ACTIVE` |

### 3. Archivos de Configuración

| v1.x | v2.0 |
|------|------|
| `config.ini` | `config/settings.ahk` |
| `kanata.cfg` | `../../../config/kanata.kbd` |
| `colors.ahk` | `config/colorscheme.ahk` |

---

## 🔧 Solución de Problemas

### Error: "Capa no se activa"

**Causa**: Función de activación tiene nombre antiguo.

**Solución**:
```ahk
; ❌ Mal
ActivateNvimMode()

; ✅ Bien
ActivateNvimLayer()
```

### Error: "Variable no definida"

**Causa**: Variables globales cambiaron de nombre.

**Solución**:
```ahk
; ❌ Mal
if (NVIM_MODE_ACTIVE)

; ✅ Bien
if (NVIM_LAYER_ACTIVE)
```

### Error: "Archivo de configuración no encontrado"

**Causa**: Archivos de configuración movidos.

**Solución**:
```bash
# Mover archivos a nueva ubicación
mv config.ini config/settings.ahk
mv kanata.cfg ../../../config/kanata.kbd
```

---

## 📊 Checklist de Migración

- [ ] Backup de configuración antigua
- [ ] Actualizar estructura de carpetas
- [ ] Migrar definiciones de capas al sistema declarativo
- [ ] Actualizar nombres de funciones
- [ ] Actualizar nombres de variables globales
- [ ] Mover archivos de configuración
- [ ] Probar cada capa individualmente
- [ ] Verificar tooltips funcionan
- [ ] Verificar persistencia de estado
- [ ] Revisar logs con DebugView

---

## 💡 Consejos para Migración Suave

1. **Migra una capa a la vez** - No intentes migrar todo de una vez
2. **Usa el sistema de debug** - Habilita `DEBUG_MODE` para ver qué está pasando
3. **Mantén backup** - Guarda la versión antigua hasta confirmar que todo funciona
4. **Lee la documentación nueva** - Muchas cosas cambiaron, familiarízate con el nuevo sistema
5. **Usa el template** - `doc/templates/template_layer.ahk` tiene la estructura correcta

---

## 📚 Recursos Adicionales

- **[Sistema Declarativo](sistema-declarativo.md)** - Entender el nuevo sistema
- **[Crear Capas](../guia-desarrollador/crear-capas.md)** - Guía actualizada
- **[Sistema de Debug](sistema-debug.md)** - Solucionar problemas de migración
- **[Changelog](../../../CHANGELOG.md)** - Lista completa de cambios

---

## 🆘 Ayuda

Si encuentras problemas durante la migración:

1. Revisa el [Sistema de Debug](sistema-debug.md)
2. Consulta los [ejemplos en src/layer/](../../../src/layer/)
3. Busca en la [documentación completa](../../README.md)
4. Abre un issue en GitHub (si aplica)

---

**[🌍 View in English](../../en/reference/migration-summary.md)** | **[← Volver al Índice](../README.md)**
