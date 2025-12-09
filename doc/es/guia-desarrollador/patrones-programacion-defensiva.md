# Patrones de Programación Defensiva

## Resumen

Esta guía documenta patrones críticos de programación defensiva para el desarrollo de HybridCapsLock, aprendidos de problemas reales en producción.

---

## Patrón 1: Acceso Seguro a Configuración con Fallback

### Problema

Acceder a objetos de configuración durante la inicialización puede fallar debido a race conditions o construcción incompleta de objetos.

### Solución

Siempre validar en capas antes de acceder a propiedades:

```autohotkey
ReadConfig() {
    global ExternalConfig
    
    ; Capa 1: Verificar si existe
    if (!IsSet(ExternalConfig))
        return GetFallbackConfig()
    
    ; Capa 2: Verificar si es un objeto válido
    if (!IsObject(ExternalConfig))
        return GetFallbackConfig()
    
    ; Capa 3: Verificar si tiene la sección requerida
    if (!ExternalConfig.HasOwnProp("section"))
        return GetFallbackConfig()
    
    ; Capa 4: Intentar leer con manejo de errores
    try {
        section := ExternalConfig.section
        if (!IsObject(section))
            return GetFallbackConfig()
        
        ; Crear objeto con TODAS las propiedades definidas desde el inicio
        config := {
            prop1: "default1",
            prop2: "default2",
            prop3: 100
        }
        
        ; Sobrescribir solo si las propiedades existen
        if (section.HasOwnProp("prop1"))
            config.prop1 := section.prop1
        if (section.HasOwnProp("prop2"))
            config.prop2 := section.prop2
        if (section.HasOwnProp("prop3"))
            config.prop3 := section.prop3
        
        return config
    } catch as e {
        ; Loguear error si es necesario
        LogError("Fallo al leer config: " . e.Message)
        return GetFallbackConfig()
    }
}

GetFallbackConfig() {
    return {
        prop1: "default1",
        prop2: "default2",
        prop3: 100
    }
}
```

### Puntos Clave

- ✅ Validar existencia con `IsSet()`
- ✅ Validar tipo con `IsObject()`
- ✅ Verificar propiedades con `HasOwnProp()`
- ✅ Definir TODAS las propiedades en el literal del objeto desde el inicio
- ✅ Usar try-catch para errores inesperados
- ✅ Siempre proveer valores fallback

---

## Patrón 2: Acceso Seguro a Propiedades

### ❌ MAL - Acceso Inseguro a Propiedades

```autohotkey
StartFeature() {
    config := GetConfig()
    if (config.exePath) {  // ← CRASH si exePath no existe
        DoSomething(config.exePath)
    }
}
```

### ✅ BIEN - Acceso Defensivo a Propiedades

```autohotkey
StartFeature() {
    config := GetConfig()
    
    ; Validar objeto
    if (!IsObject(config)) {
        config := GetFallbackConfig()
    }
    
    ; Validar que la propiedad existe
    if (!config.HasOwnProp("exePath")) {
        config := GetFallbackConfig()
    }
    
    ; Validar que el valor no esté vacío
    if (config.exePath != "" && config.exePath) {
        DoSomething(config.exePath)
    }
}
```

---

## Patrón 3: Definición de Objetos Literales en AHK v2

### ❌ MAL - Asignación Dinámica de Propiedades

```autohotkey
config := {}
config.prop1 := value1  // ← La propiedad puede no ser accesible
config.prop2 := value2
```

### ✅ BIEN - Definición Upfront de Propiedades

```autohotkey
config := {
    prop1: value1,  // ← Todas las propiedades definidas en el literal
    prop2: value2,
    prop3: ""       // ← Incluso valores vacíos deben definirse
}
```

**¿Por qué?** En AHK v2, las propiedades definidas en el literal del objeto están garantizadas de ser accesibles con notación de punto. La asignación dinámica puede no crear una OwnProperty correcta.

---

## Patrón 4: Lazy Loading con Validación

### ❌ MAL - Lazy Loading Ingenuo

```autohotkey
GetConfig() {
    global configCache
    if (!IsSet(configCache))
        configCache := ReadConfig()  // ← Si ReadConfig falla, el cache queda corrupto
    return configCache
}
```

### ✅ BIEN - Lazy Loading Validado

```autohotkey
GetConfig() {
    global configCache
    
    if (!IsSet(configCache)) {
        configCache := ReadConfig()
        
        ; Validar valor cacheado
        if (!IsObject(configCache)) {
            configCache := GetFallbackConfig()
        }
        
        ; Validar que existan propiedades requeridas
        if (!configCache.HasOwnProp("requiredProp")) {
            configCache := GetFallbackConfig()
        }
    }
    
    return configCache
}
```

---

## Patrón 5: Acceso a Objetos Anidados

### ❌ MAL - Acceso Directo Anidado

```autohotkey
value := config.section.subsection.property  // ← Crash si cualquier nivel falta
```

### ✅ BIEN - Acceso Anidado Validado

```autohotkey
value := defaultValue

if (IsObject(config) && config.HasOwnProp("section")) {
    section := config.section
    if (IsObject(section) && section.HasOwnProp("subsection")) {
        subsection := section.subsection
        if (IsObject(subsection) && subsection.HasOwnProp("property")) {
            value := subsection.property
        }
    }
}
```

**Alternativa - Patrón Early Return:**

```autohotkey
GetNestedValue(config) {
    if (!IsObject(config) || !config.HasOwnProp("section"))
        return defaultValue
    
    section := config.section
    if (!IsObject(section) || !section.HasOwnProp("subsection"))
        return defaultValue
    
    subsection := section.subsection
    if (!IsObject(subsection) || !subsection.HasOwnProp("property"))
        return defaultValue
    
    return subsection.property
}
```

---

## Patrón 6: Prevención de Race Conditions

### Problema

Cuando el código se ejecuta durante la fase de `#Include`, los objetos globales pueden estar en estados intermedios.

### Solución

1. **Diferir ejecución a la fase de startup**:

```autohotkey
; En init.ahk - DESPUÉS de todos los includes
try {
    if (IsSet(HybridConfig)) {
        LoadLayerFlags()
        StartFeatures()  // ← Seguro: Todos los configs cargados
    }
} catch {
}
```

2. **Usar lectura defensiva en código ejecutado temprano**:

```autohotkey
; Esto podría ejecutarse durante la fase #Include
EarlyFunction() {
    ; No asumir que nada está listo
    if (!IsSet(GlobalConfig))
        return GetFallback()
    
    ; Continuar con validación...
}
```

---

## Checklist: Agregar Código Dependiente de Config

Cuando agregues código que accede a configuración externa:

- [ ] ¿Verificaste que el objeto existe con `IsSet()`?
- [ ] ¿Verificaste que es un objeto con `IsObject()`?
- [ ] ¿Usaste `HasOwnProp()` antes de acceder a propiedades?
- [ ] ¿Implementaste fallback si la lectura falla?
- [ ] ¿Definiste TODAS las propiedades en el literal del objeto desde el inicio?
- [ ] ¿Agregaste try-catch para errores inesperados?
- [ ] ¿Probaste en cold start (sin reload)?
- [ ] ¿Probaste con config incompleto?

---

## Ejemplo del Mundo Real: TooltipConfig

**Problema:** Crash de `config.exePath` en cold start

**Solución Aplicada:**

```autohotkey
StartTooltipApp() {
    config := GetTooltipConfig()
    
    ; Triple validación
    if (!IsObject(config)) {
        config := GetFallbackTooltipConfig()
    }
    
    if (!config.HasOwnProp("exePath")) {
        config := GetFallbackTooltipConfig()
    }
    
    ; Ahora es seguro usar
    if (config.exePath != "" && config.exePath) {
        // ... usar exePath
    } else {
        // ... usar paths por defecto
    }
}
```

**Ver:** `.ai-sessions/2025-12-08-fix-config-initialization-race-condition/README.md`

---

## Resumen

**Principios Fundamentales:**

1. **Nunca asumas** - Siempre valida
2. **Define desde el inicio** - Todas las propiedades en literales de objeto
3. **Falla graciosamente** - Siempre ten fallbacks
4. **Valida en capas** - Verifica existencia, tipo, propiedades, valores
5. **Maneja errores** - Usa try-catch para problemas inesperados

**Recordá:** En producción, aplica la Ley de Murphy - si algo PUEDE estar sin inicializar, en algún momento ESTARÁ sin inicializar.
