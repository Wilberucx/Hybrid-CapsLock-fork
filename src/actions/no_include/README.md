# Actions No-Include Folder

This folder contains `.ahk` files that will **NOT** be automatically included by the auto-loader system.

## 🎯 Purpose

Use this folder for:

1. **Archivos incompletos o en desarrollo**: Actions que aún no están listas para usar
2. **Desactivar actions temporalmente**: Mover archivos aquí para deshabilitarlos sin eliminarlos
3. **Testing y debugging**: Versiones experimentales de actions existentes
4. **Backups**: Guardar versiones antiguas de actions antes de refactorizar

## 📋 Cómo Funciona

El auto-loader (`src/core/auto_loader.ahk`) escanea `src/actions/` en cada inicio, pero **ignora** archivos en esta carpeta.

### **Desactivar un Action:**
```bash
# Mover archivo aquí
mv src/actions/my_action.ahk src/actions/no_include/

# En el próximo reinicio, no se incluirá
```

### **Reactivar un Action:**
```bash
# Mover de vuelta
mv src/actions/no_include/my_action.ahk src/actions/

# En el próximo reinicio, se incluirá automáticamente
```

## ⚠️ Importante

- Los archivos aquí **NO** se ejecutan
- Las funciones definidas en estos archivos **NO** están disponibles
- Si otras actions dependen de funciones aquí, causarán errores
- El auto-loader **NO** genera `#Include` para estos archivos

## 📝 Buenas Prácticas

1. **Documentar por qué está aquí**: Agrega comentario al inicio del archivo
   ```ahk
   ; DESACTIVADO: En desarrollo - falta implementar error handling
   ; Fecha: 2025-11-08
   ; Autor: Tu Nombre
   ```

2. **Prefijo de archivo**: Considera usar prefijo `_disabled_` o `_wip_`
   ```
   _disabled_my_action.ahk
   _wip_new_feature.ahk
   ```

3. **Limpiar regularmente**: Elimina archivos obsoletos que ya no necesitas

## 🔍 Ver Qué Está Desactivado

Desde PowerShell/CMD:
```bash
# Listar archivos desactivados
ls src/actions/no_include/*.ahk
```

Desde AutoHotkey:
```ahk
; El auto-loader registra en OutputDebug:
; [AutoLoader] Excluded: my_action.ahk
```

## 🚀 Ejemplo de Uso

### Desarrollo Incremental
```
1. Crear src/actions/no_include/database_actions.ahk
2. Implementar funciones básicas
3. Probar manualmente con #Include temporal en test script
4. Cuando esté listo: mv a src/actions/
5. Auto-loader lo detecta y lo incluye automáticamente
```

### Desactivar Temporalmente
```
1. Bug encontrado en git_actions.ahk
2. mv src/actions/git_actions.ahk src/actions/no_include/
3. Reiniciar script (auto-loader lo excluye)
4. Trabajar en fix
5. mv de vuelta cuando esté arreglado
```

---

**Nota**: Esta carpeta es creada automáticamente por el auto-loader si no existe.
