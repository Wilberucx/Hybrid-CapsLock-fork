# Defensive Programming Patterns

## Overview

This guide documents critical defensive programming patterns for HybridCapsLock development, learned from real issues in production.

---

## Pattern 1: Safe Config Access with Fallback

### Problem

Accessing configuration objects during initialization can fail due to race conditions or incomplete object construction.

### Solution

Always validate in layers before accessing properties:

```autohotkey
ReadConfig() {
    global ExternalConfig
    
    ; Layer 1: Check if exists
    if (!IsSet(ExternalConfig))
        return GetFallbackConfig()
    
    ; Layer 2: Check if valid object
    if (!IsObject(ExternalConfig))
        return GetFallbackConfig()
    
    ; Layer 3: Check if has required section
    if (!ExternalConfig.HasOwnProp("section"))
        return GetFallbackConfig()
    
    ; Layer 4: Try to read with error handling
    try {
        section := ExternalConfig.section
        if (!IsObject(section))
            return GetFallbackConfig()
        
        ; Create object with ALL properties defined upfront
        config := {
            prop1: "default1",
            prop2: "default2",
            prop3: 100
        }
        
        ; Override only if properties exist
        if (section.HasOwnProp("prop1"))
            config.prop1 := section.prop1
        if (section.HasOwnProp("prop2"))
            config.prop2 := section.prop2
        if (section.HasOwnProp("prop3"))
            config.prop3 := section.prop3
        
        return config
    } catch as e {
        ; Log error if needed
        LogError("Config read failed: " . e.Message)
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

### Key Points

- ✅ Validate existence with `IsSet()`
- ✅ Validate type with `IsObject()`
- ✅ Check properties with `HasOwnProp()`
- ✅ Define ALL properties in object literal upfront
- ✅ Use try-catch for unexpected errors
- ✅ Always provide fallback values

---

## Pattern 2: Safe Property Access

### ❌ BAD - Unsafe Property Access

```autohotkey
StartFeature() {
    config := GetConfig()
    if (config.exePath) {  // ← CRASH if exePath doesn't exist
        DoSomething(config.exePath)
    }
}
```

### ✅ GOOD - Defensive Property Access

```autohotkey
StartFeature() {
    config := GetConfig()
    
    ; Validate object
    if (!IsObject(config)) {
        config := GetFallbackConfig()
    }
    
    ; Validate property exists
    if (!config.HasOwnProp("exePath")) {
        config := GetFallbackConfig()
    }
    
    ; Validate value is not empty
    if (config.exePath != "" && config.exePath) {
        DoSomething(config.exePath)
    }
}
```

---

## Pattern 3: Object Literal Definition in AHK v2

### ❌ BAD - Dynamic Property Assignment

```autohotkey
config := {}
config.prop1 := value1  // ← Property may not be accessible
config.prop2 := value2
```

### ✅ GOOD - Upfront Property Definition

```autohotkey
config := {
    prop1: value1,  // ← All properties defined in literal
    prop2: value2,
    prop3: ""       // ← Even empty values should be defined
}
```

**Why?** In AHK v2, properties defined in the object literal are guaranteed to be accessible with dot notation. Dynamic assignment may not create proper OwnProperty.

---

## Pattern 4: Lazy Loading with Validation

### ❌ BAD - Naive Lazy Loading

```autohotkey
GetConfig() {
    global configCache
    if (!IsSet(configCache))
        configCache := ReadConfig()  // ← If ReadConfig fails, cache is corrupt
    return configCache
}
```

### ✅ GOOD - Validated Lazy Loading

```autohotkey
GetConfig() {
    global configCache
    
    if (!IsSet(configCache)) {
        configCache := ReadConfig()
        
        ; Validate cached value
        if (!IsObject(configCache)) {
            configCache := GetFallbackConfig()
        }
        
        ; Validate required properties exist
        if (!configCache.HasOwnProp("requiredProp")) {
            configCache := GetFallbackConfig()
        }
    }
    
    return configCache
}
```

---

## Pattern 5: Nested Object Access

### ❌ BAD - Direct Nested Access

```autohotkey
value := config.section.subsection.property  // ← Crashes if any level is missing
```

### ✅ GOOD - Validated Nested Access

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

**Alternative - Early Return Pattern:**

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

## Pattern 6: Race Condition Prevention

### Problem

When code runs during `#Include` phase, global objects may be in intermediate states.

### Solution

1. **Defer execution to startup phase**:

```autohotkey
; In init.ahk - AFTER all includes
try {
    if (IsSet(HybridConfig)) {
        LoadLayerFlags()
        StartFeatures()  // ← Safe: All configs loaded
    }
} catch {
}
```

2. **Use defensive reading in early-executed code**:

```autohotkey
; This might run during #Include phase
EarlyFunction() {
    ; Don't assume anything is ready
    if (!IsSet(GlobalConfig))
        return GetFallback()
    
    ; Continue with validation...
}
```

---

## Checklist: Adding New Config-Dependent Code

When adding code that accesses external configuration:

- [ ] Verified object exists with `IsSet()`?
- [ ] Verified it's an object with `IsObject()`?
- [ ] Used `HasOwnProp()` before accessing properties?
- [ ] Implemented fallback if reading fails?
- [ ] Defined ALL properties in object literal upfront?
- [ ] Added try-catch for unexpected errors?
- [ ] Tested in cold start (no reload)?
- [ ] Tested with incomplete config?

---

## Real-World Example: TooltipConfig

**Issue:** `config.exePath` crash on cold start

**Solution Applied:**

```autohotkey
StartTooltipApp() {
    config := GetTooltipConfig()
    
    ; Triple validation
    if (!IsObject(config)) {
        config := GetFallbackTooltipConfig()
    }
    
    if (!config.HasOwnProp("exePath")) {
        config := GetFallbackTooltipConfig()
    }
    
    ; Safe to use now
    if (config.exePath != "" && config.exePath) {
        // ... use exePath
    } else {
        // ... use default paths
    }
}
```

**See:** `.ai-sessions/2025-12-08-fix-config-initialization-race-condition/README.md`

---

## Summary

**Core Principles:**

1. **Never assume** - Always validate
2. **Define upfront** - All properties in object literals
3. **Fail gracefully** - Always have fallbacks
4. **Validate layers** - Check existence, type, properties, values
5. **Handle errors** - Use try-catch for unexpected issues

**Remember:** In production, Murphy's Law applies - if something CAN be uninitialized, it WILL be uninitialized at some point.
