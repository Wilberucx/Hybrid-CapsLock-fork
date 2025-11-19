# Layers No-Include Folder

This folder contains layer `.ahk` files that will **NOT** be automatically included by the auto-loader system.

## 🎯 Purpose

Use this folder for:

1. **Capas en desarrollo**: Layers que aún no están completas o testeadas
2. **Desactivar capas temporalmente**: Deshabilitar layers sin eliminar el código
3. **Testing y debugging**: Versiones experimentales de capas existentes
4. **Backups**: Guardar versiones antiguas antes de cambios mayores

## 📋 Cómo Funciona

El auto-loader (`src/core/auto_loader.ahk`) escanea `src/layer/` en cada inicio, pero **ignora** archivos en esta carpeta.

### **Desactivar una Capa:**
```bash
# Mover archivo aquí
mv src/layer/my_layer.ahk src/layer/no_include/

# En el próximo reinicio, no se incluirá
```

### **Reactivar una Capa:**
```bash
# Mover de vuelta
mv src/layer/no_include/my_layer.ahk src/layer/

# En el próximo reinicio, se incluirá automáticamente
```

## ⚠️ Importante

- Las capas aquí **NO** se cargan
- Los hotkeys de estas capas **NO** están activos
- Las funciones de activación (ej: `ActivateMyLayer()`) **NO** están disponibles
- Si el leader menu referencia estas capas, causará errores

## 📝 Buenas Prácticas

1. **Documentar estado**: Agrega comentario explicando por qué está desactivada
   ```ahk
   ; DESACTIVADO: Conflicto con Excel layer - necesita refactor
   ; Fecha: 2025-11-08
   ; TODO: Resolver conflicto con exit keys
   ```

2. **Prefijo descriptivo**: Usa prefijo para identificar fácilmente
   ```
   _disabled_browser_layer.ahk
   _wip_database_layer.ahk
   _backup_old_nvim_layer.ahk
   ```

3. **Actualizar registros**: Si desactivas una capa del leader menu, comenta su registro en `command_system_init.ahk`
   ```ahk
   ; Desactivado temporalmente
   ; RegisterKeymapFlat("leader", "b", "Browser Layer", ActivateBrowserLayer, false, 5)
   ```

## 🔍 Ver Qué Está Desactivado

Desde PowerShell/CMD:
```bash
# Listar capas desactivadas
ls src/layer/no_include/*.ahk
```

Desde AutoHotkey:
```ahk
; El auto-loader registra en OutputDebug:
; [AutoLoader] Excluded: my_layer.ahk
```

## 🚀 Ejemplo de Uso

### Desarrollo de Nueva Capa
```
1. Copiar plantilla a src/layer/no_include/music_layer.ahk
2. Implementar hotkeys básicos
3. Probar manualmente con #Include temporal
4. Cuando funcione: mv a src/layer/
5. Registrar en command_system_init.ahk
6. Auto-loader lo incluye automáticamente
```

### Desactivar Capa con Problemas
```
1. Bug en excel_layer.ahk causa crash
2. mv src/layer/excel_layer.ahk src/layer/no_include/
3. Reiniciar (auto-loader lo excluye)
4. Debugging y fix
5. mv de vuelta cuando esté arreglado
6. Reiniciar (auto-loader lo detecta)
```

### Usar Template
```
1. Copiar doc/templates/layer_template.ahk aquí
2. Renombrar a my_new_layer.ahk
3. Personalizar (LAYER_NAME, hotkeys, etc.)
4. Cuando esté completo: mv a src/layer/
5. Auto-loader lo incluye
```

## 🎨 Ejemplo: Desactivar y Registrar

**Antes (activo):**
```ahk
; init.ahk (generado por auto-loader)
#Include src\layer\browser_layer.ahk

; command_system_init.ahk
RegisterKeymapFlat("leader", "b", "Browser Layer", ActivateBrowserLayer, false, 5)
```

**Desactivar:**
```bash
mv src/layer/browser_layer.ahk src/layer/no_include/
```

**Después (desactivado):**
```ahk
; init.ahk (auto-actualizado)
; (ya no incluye browser_layer.ahk)

; command_system_init.ahk (debes comentar manualmente)
; RegisterKeymapFlat("leader", "b", "Browser Layer", ActivateBrowserLayer, false, 5)
```

## ⚡ Tips Avanzados

### 1. Desarrollo Paralelo
```
src/layer/excel_layer.ahk              (versión estable)
src/layer/no_include/excel_layer_v2.ahk (refactor en progreso)
```

### 2. Testing A/B
```
# Probar nueva implementación
mv src/layer/scroll_layer.ahk src/layer/no_include/scroll_layer_old.ahk
mv src/layer/no_include/scroll_layer_new.ahk src/layer/scroll_layer.ahk
# Reiniciar y probar
```

### 3. Seasonal Layers
```
# Capas que solo usas a veces
src/layer/no_include/gaming_layer.ahk
src/layer/no_include/presentation_layer.ahk
# Mover a src/layer/ cuando las necesites
```

---

**Nota**: Esta carpeta es creada automáticamente por el auto-loader si no existe.
