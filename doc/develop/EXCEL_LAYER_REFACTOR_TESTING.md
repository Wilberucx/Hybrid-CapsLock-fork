# Excel Layer Refactorización - Plan de Testing

## Estado Actual
✅ **Refactorización completada**
- Archivo original: `src/layer/excel_layer.ahk` (347 líneas)
- Archivo refactorizado: `src/layer/excel_layer.ahk` (315 líneas)
- Backup creado: `src/layer/excel_layer.ahk.backup_20251110`
- Reducción: 32 líneas (9.2% menos código)

## Cambios Realizados

### 1. Navegación Básica
- ✅ `h/j/k/l` ahora usan `VimMoveLeft/Down/Up/Right()` de `vim_nav.ahk`
- ✅ `0` usa `VimStartOfLine()`
- ✅ `$` (Shift+4) usa `VimEndOfLine()`
- ✅ `g` usa `VimTopOfFile()`
- ✅ `G` (Shift+G) usa `VimBottomOfFile()`

### 2. Operaciones de Edición
- ✅ `y` usa `VimYank()` de `vim_edit.ahk`
- ✅ `p` usa `VimPaste()` de `vim_edit.ahk`
- ✅ `u` usa `VimUndo()` de `vim_edit.ahk`
- ✅ `r` usa `VimRedo()` de `vim_edit.ahk`

### 3. Modo Visual
- ✅ `v` ahora usa `SwitchToLayer("visual", "excel")`
- ✅ `vv` en VLogic también usa `SwitchToLayer("visual", "excel")`
- ✅ Eliminado todo el código de VVModeActive (~100 líneas)
- ✅ Eliminada función `ExcelVVDirectionalSend()`

### 4. Estructura Mejorada
- ✅ Código más limpio y modular
- ✅ Mejor organización por secciones
- ✅ Comentarios actualizados
- ✅ Notas de refactoring incluidas

## Plan de Testing

### Pre-requisitos
1. Recargar el script de AutoHotkey
2. Tener Excel o una aplicación de hojas de cálculo abierta
3. Activar el Excel Layer (generalmente con Leader → n)

### Test Suite

#### Test 1: Numpad Virtual
```
Descripción: Verificar que el numpad virtual funciona
Pasos:
1. Activar Excel Layer
2. Presionar: 1, 2, 3, q, w, e, a, s, d, z
3. Presionar: . (punto decimal)
4. Presionar: 8 (asterisco), 9 (paréntesis)
Resultado Esperado: Todos los números se ingresan correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 2: Navegación Básica (hjkl)
```
Descripción: Verificar navegación con hjkl
Pasos:
1. Activar Excel Layer
2. Presionar: h (izquierda), j (abajo), k (arriba), l (derecha)
3. Verificar movimiento de celda
Resultado Esperado: Navegación fluida sin errores
Estado: [ ] Pasó / [ ] Falló
```

#### Test 3: Navegación de Línea (0/$)
```
Descripción: Verificar navegación al inicio y fin de línea
Pasos:
1. Activar Excel Layer
2. Presionar: 0 (debe ir a columna A)
3. Presionar: Shift+4 (debe ir al final de la fila)
Resultado Esperado: Navegación correcta a inicio y fin
Estado: [ ] Pasó / [ ] Falló
```

#### Test 4: Navegación de Documento (g/G)
```
Descripción: Verificar navegación al inicio y fin del documento
Pasos:
1. Activar Excel Layer
2. Presionar: g (debe ir a celda A1)
3. Presionar: Shift+G (debe ir al final del documento)
Resultado Esperado: Navegación correcta a inicio y fin
Estado: [ ] Pasó / [ ] Falló
```

#### Test 5: Copy/Paste (y/p)
```
Descripción: Verificar operaciones de copia y pegado
Pasos:
1. Activar Excel Layer
2. Seleccionar una celda con contenido
3. Presionar: y (copiar)
4. Moverse a otra celda
5. Presionar: p (pegar)
Resultado Esperado: Contenido se copia y pega correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 6: Undo/Redo (u/r)
```
Descripción: Verificar deshacer y rehacer
Pasos:
1. Activar Excel Layer
2. Hacer un cambio en una celda
3. Presionar: u (deshacer)
4. Presionar: r (rehacer)
Resultado Esperado: Cambios se deshacen y rehacen correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 7: Visual Mode (v)
```
Descripción: Verificar integración con visual_layer
Pasos:
1. Activar Excel Layer
2. Presionar: v (entrar a visual mode)
3. Verificar tooltip de "VISUAL MODE"
4. Presionar: h/j/k/l (seleccionar celdas)
5. Presionar: y (copiar) o d (borrar)
6. Verificar que regresa a Excel Layer
Resultado Esperado: Visual mode funciona y regresa correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 8: VLogic - Selección de Fila (vr)
```
Descripción: Verificar selección de fila completa
Pasos:
1. Activar Excel Layer
2. Presionar: v (iniciar VLogic)
3. Presionar: r (seleccionar fila)
4. Verificar que toda la fila está seleccionada
Resultado Esperado: Fila completa seleccionada
Estado: [ ] Pasó / [ ] Falló
```

#### Test 9: VLogic - Selección de Columna (vc)
```
Descripción: Verificar selección de columna completa
Pasos:
1. Activar Excel Layer
2. Presionar: v (iniciar VLogic)
3. Presionar: c (seleccionar columna)
4. Verificar que toda la columna está seleccionada
Resultado Esperado: Columna completa seleccionada
Estado: [ ] Pasó / [ ] Falló
```

#### Test 10: VLogic Visual (vv)
```
Descripción: Verificar que vv usa visual_layer
Pasos:
1. Activar Excel Layer
2. Presionar: v (iniciar VLogic)
3. Presionar: v (entrar a visual mode)
4. Verificar tooltip de "VISUAL MODE"
5. Presionar: hjkl para seleccionar
6. Presionar: Esc para salir
Resultado Esperado: Visual mode funciona desde VLogic
Estado: [ ] Pasó / [ ] Falló
```

#### Test 11: Modo Edit (i/I)
```
Descripción: Verificar modo de edición de celda
Pasos:
1. Activar Excel Layer
2. Presionar: i (editar celda - F2)
3. Verificar que celda está en modo edición
4. Salir de Excel Layer
5. Activarlo de nuevo
6. Presionar: Shift+I (editar y salir de layer)
Resultado Esperado: F2 funciona correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 12: Salir del Layer (Shift+N)
```
Descripción: Verificar salida del Excel Layer
Pasos:
1. Activar Excel Layer
2. Presionar: Shift+N
3. Verificar tooltip "EXCEL LAYER OFF"
4. Verificar que hotkeys de Excel no funcionan
Resultado Esperado: Layer se desactiva correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 13: Help System (?)
```
Descripción: Verificar sistema de ayuda
Pasos:
1. Activar Excel Layer
2. Presionar: ? (o Shift+/)
3. Verificar que aparece ayuda
4. Presionar: ? de nuevo para cerrar
Resultado Esperado: Ayuda se muestra y oculta correctamente
Estado: [ ] Pasó / [ ] Falló
```

#### Test 14: Tab Navigation ([/])
```
Descripción: Verificar navegación con Tab
Pasos:
1. Activar Excel Layer
2. Presionar: ] (Tab - siguiente campo)
3. Presionar: [ (Shift+Tab - campo anterior)
Resultado Esperado: Navegación entre campos funciona
Estado: [ ] Pasó / [ ] Falló
```

#### Test 15: Find (f) y Go To (m)
```
Descripción: Verificar funciones de búsqueda
Pasos:
1. Activar Excel Layer
2. Presionar: f (Ctrl+F - Find)
3. Presionar: m (Ctrl+G - Go To)
Resultado Esperado: Diálogos de Excel se abren
Estado: [ ] Pasó / [ ] Falló
```

## Regresión Testing

### Test de Integración
- [ ] Visual Layer regresa correctamente a Excel Layer
- [ ] Estado de Excel Layer se preserva
- [ ] Tooltips muestran información correcta
- [ ] No hay conflictos con otros layers
- [ ] CapsLock physical press desactiva hotkeys correctamente

### Test de Performance
- [ ] No hay lag en navegación
- [ ] Switching entre layers es instantáneo
- [ ] No hay memory leaks

## Rollback Plan

Si hay problemas críticos:

```bash
# Restaurar versión anterior
cp src/layer/excel_layer.ahk.backup_20251110 src/layer/excel_layer.ahk

# Recargar script
# Ctrl+Alt+R o reiniciar manualmente
```

## Checklist de Completitud

- [x] Backup creado
- [x] Archivo refactorizado
- [x] Documentación actualizada
- [ ] Testing básico completado
- [ ] Testing de integración completado
- [ ] Testing de regresión completado
- [ ] Sign-off final

## Notas

### Diferencias Esperadas
- Visual mode ahora usa visual_layer.ahk (más robusto)
- Tooltips pueden variar ligeramente
- Performance puede ser ligeramente mejor (menos código)

### Comportamiento Idéntico
- Todas las teclas funcionan igual
- Numpad virtual funciona igual
- VLogic vr/vc funcionan igual
- Help system funciona igual

## Próximos Pasos

1. **Ejecutar todos los tests**
2. **Documentar resultados**
3. **Reportar issues si los hay**
4. **Si todo funciona:** Eliminar backup después de 1 semana de uso
5. **Si hay problemas:** Rollback y reportar

## Contacto

Si encuentras problemas o tienes sugerencias, documéntalos en:
- GitHub Issues
- CANTO.LOG
- Este documento (sección de issues)

---

## Issues Encontrados

### Issue #1
```
Fecha: 
Descripción: 
Pasos para reproducir: 
Solución: 
```

### Issue #2
```
Fecha: 
Descripción: 
Pasos para reproducir: 
Solución: 
```
