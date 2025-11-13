# Sistema de Debug - HybridCapsLock

## Descripción General

El sistema de debug proporciona control centralizado sobre el logging de desarrollo en HybridCapslock. Cuando `debug_mode` está habilitado, el logging verboso ayuda a los desarrolladores a rastrear el flujo de ejecución, solucionar problemas y entender el comportamiento del sistema.

---

## 🔧 Configuración

### Habilitar/Deshabilitar Debug Mode

Edita `config/settings.ahk`:

```ahk
; Activar modo debug
global DEBUG_MODE := true

; Desactivar modo debug
global DEBUG_MODE := false
```

### Configuración Granular

Puedes controlar el nivel de detalle del logging:

```ahk
; En config/settings.ahk
global DEBUG_MODE := true
global DEBUG_LEVEL := 2  ; 0=Error, 1=Warning, 2=Info, 3=Verbose

; O por módulo
global DEBUG_LAYERS := true      ; Debug de capas
global DEBUG_KEYMAPS := true     ; Debug de keymaps
global DEBUG_TOOLTIPS := false   ; No debug de tooltips
```

---

## 📝 Uso de OutputDebug

### Logging Básico

```ahk
OutputDebug("Mi mensaje de debug")
```

### Logging Condicional

```ahk
if (DEBUG_MODE) {
    OutputDebug("Capa activada: " . layer_name)
}
```

### Logging con Contexto

```ahk
OutputDebug("=== INICIO: MiFuncion ===")
OutputDebug("Parámetro1: " . param1)
OutputDebug("Parámetro2: " . param2)
; ... código ...
OutputDebug("=== FIN: MiFuncion ===")
```

---

## 🔍 Ver Logs con DebugView

### Descargar DebugView

1. Descarga [DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview) de Microsoft Sysinternals
2. Extrae y ejecuta `Dbgview.exe`
3. **Importante**: Ejecutar como Administrador para ver logs de AutoHotkey

### Configuración Recomendada

En DebugView:
1. **Capture → Capture Global Win32** ✅
2. **Capture → Capture Events** ✅
3. **Edit → Filter/Highlight** → Agregar filtros:
   - `*HybridCapslock*` - Solo mensajes del proyecto
   - `*ERROR*` - Resaltar errores en rojo

### Filtrar por Módulo

```ahk
; En tu código, usa prefijos
OutputDebug("[NVIM] Capa activada")
OutputDebug("[EXCEL] Mini-capa V iniciada")
OutputDebug("[LOADER] Archivo cargado: " . filename)

; En DebugView, filtra por: [NVIM]
```

---

## 🐛 Técnicas de Debugging

### 1. Tracing de Flujo de Ejecución

```ahk
MiFuncionComplicada() {
    OutputDebug(">>> MiFuncionComplicada: INICIO")
    
    if (condicion1) {
        OutputDebug(">>> Rama: condicion1 = true")
        ; código
    } else {
        OutputDebug(">>> Rama: condicion1 = false")
        ; código
    }
    
    OutputDebug(">>> MiFuncionComplicada: FIN")
}
```

### 2. Inspección de Variables

```ahk
; Ver valor de variable
OutputDebug("Valor de X: " . x)

; Ver tipo
OutputDebug("Tipo de X: " . Type(x))

; Ver objeto completo
OutputDebug("Objeto: " . JSON.stringify(myObject))
```

### 3. Timing de Operaciones

```ahk
start_time := A_TickCount
; ... operación lenta ...
elapsed := A_TickCount - start_time
OutputDebug("Operación tardó: " . elapsed . "ms")
```

### 4. Stack Trace Manual

```ahk
FuncionA() {
    OutputDebug("[STACK] FuncionA")
    FuncionB()
}

FuncionB() {
    OutputDebug("[STACK] FuncionA > FuncionB")
    FuncionC()
}

FuncionC() {
    OutputDebug("[STACK] FuncionA > FuncionB > FuncionC")
    ; aquí está el bug
}
```

---

## 🚨 Manejo de Errores

### Try/Catch con Logging

```ahk
try {
    ; Código que puede fallar
    resultado := OperacionRiesgosa()
    OutputDebug("[SUCCESS] Operación exitosa: " . resultado)
} catch Error as err {
    OutputDebug("[ERROR] Operación falló")
    OutputDebug("[ERROR] Mensaje: " . err.Message)
    OutputDebug("[ERROR] Línea: " . err.Line)
    OutputDebug("[ERROR] Archivo: " . err.File)
}
```

### Assert Personalizado

```ahk
Assert(condition, message) {
    if (!condition) {
        error_msg := "[ASSERT FAILED] " . message
        OutputDebug(error_msg)
        MsgBox(error_msg)
        throw Error(error_msg)
    }
}

; Uso
Assert(layer_name != "", "layer_name no puede estar vacío")
Assert(IsObject(keymaps), "keymaps debe ser un objeto")
```

---

## 📊 Herramientas Adicionales

### 1. ListVars / ListLines

```ahk
; Mostrar todas las variables
#v::ListVars

; Mostrar líneas ejecutadas recientemente
#l::ListLines
```

### 2. Pause para Inspección

```ahk
; Pausar ejecución para inspeccionar estado
#p::Pause

; En tu código
if (DEBUG_MODE && condition) {
    OutputDebug("PUNTO DE PAUSA: Inspeccionar estado aquí")
    Pause  ; Script se pausa aquí
}
```

### 3. Tooltips de Debug

```ahk
; Mostrar tooltip temporal con info de debug
DebugTooltip(message, duration := 2000) {
    if (DEBUG_MODE) {
        ToolTip(message)
        SetTimer(() => ToolTip(), -duration)
    }
}

; Uso
DebugTooltip("Valor de X: " . x)
```

---

## 🎯 Casos de Uso Comunes

### Debug de Capa que no se Activa

```ahk
ActivateMiCapa() {
    OutputDebug("=== ActivateMiCapa LLAMADA ===")
    
    if (MI_CAPA_ACTIVE) {
        OutputDebug(">>> Capa ya está activa, saliendo")
        return
    }
    
    OutputDebug(">>> Activando capa...")
    MI_CAPA_ACTIVE := true
    
    OutputDebug(">>> Llamando ActivateLayer...")
    ActivateLayer("mi_capa")
    
    OutputDebug(">>> Mostrando tooltip...")
    ShowLayerTooltip("MI CAPA")
    
    OutputDebug("=== ActivateMiCapa COMPLETA ===")
}
```

### Debug de Keymap que no Funciona

```ahk
; En el sistema de keymaps
ExecuteKeymap(layer_name, key) {
    OutputDebug(">>> ExecuteKeymap: layer=" . layer_name . ", key=" . key)
    
    if (!LayerIsActive(layer_name)) {
        OutputDebug(">>> ERROR: Capa no está activa")
        return
    }
    
    keymap := GetKeymap(layer_name, key)
    if (!keymap) {
        OutputDebug(">>> ERROR: Keymap no encontrado")
        return
    }
    
    OutputDebug(">>> Ejecutando acción: " . keymap.desc)
    keymap.action()
    OutputDebug(">>> Acción completada")
}
```

### Debug de Timing Issues

```ahk
; Verificar timing de homerow mods
a::
{
    static press_time := 0
    static release_time := 0
    
    if (GetKeyState("a", "P")) {
        press_time := A_TickCount
        OutputDebug(">>> 'a' PRESIONADA en t=" . press_time)
    } else {
        release_time := A_TickCount
        duration := release_time - press_time
        OutputDebug(">>> 'a' SOLTADA en t=" . release_time . " (duración: " . duration . "ms)")
        
        if (duration < 200) {
            OutputDebug(">>> TAP detectado")
        } else {
            OutputDebug(">>> HOLD detectado")
        }
    }
}
```

---

## ⚡ Optimización para Producción

### Remover Debug en Release

```ahk
; Macro para debug condicional
#If DEBUG_MODE
    #Warn  ; Habilitar advertencias
    SetBatchLines -1  ; Ejecutar a máxima velocidad para timing preciso
#EndIf

; Función helper
Log(message, level := 2) {
    if (DEBUG_MODE && DEBUG_LEVEL >= level) {
        OutputDebug(message)
    }
}

; Uso
Log("Mensaje de info", 2)
Log("Mensaje verbose", 3)
```

### Performance Impact

- `OutputDebug` tiene overhead mínimo (~0.1ms por llamada)
- DebugView puede consumir recursos si hay muchos logs
- Considera deshabilitar tooltips de debug en producción

---

## 📚 Ver También

- **[Sistema de Keymaps](../guia-desarrollador/sistema-keymaps.md)** - Debug de keymaps
- **[Crear Capas](../guia-desarrollador/crear-capas.md)** - Debug de capas personalizadas
- **[Auto-Loader](../guia-desarrollador/sistema-auto-loader.md)** - Debug de carga de módulos

---

**[🌍 View in English](../../en/reference/debug-system.md)** | **[← Volver al Índice](../README.md)**
