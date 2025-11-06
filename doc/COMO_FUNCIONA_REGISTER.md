# ¿Cómo funciona RegisterADBKeymaps()?

## Sistema Declarativo Completo (Estilo lazy.nvim)

El sistema funciona en **3 fases**:

## Fase 1: Definición (src/actions/adb_actions.ahk)

Defines las funciones de acción y el registro en UN SOLO ARCHIVO:

```ahk
; Funciones de acción
ADBListDevices() {
    Run("cmd.exe /k adb devices")
    ShowCommandExecuted("ADB", "List Devices")
}

ADBDisconnect() {
    Run("cmd.exe /k adb disconnect")
    ShowCommandExecuted("ADB", "Disconnect")
}

; Registro declarativo (UNA LÍNEA POR COMANDO)
RegisterADBKeymaps() {
    RegisterKeymap("adb", "d", "List Devices", ADBListDevices, false, 1)
    RegisterKeymap("adb", "x", "Disconnect", ADBDisconnect, false, 2)
    //                 │      │    │            │                 │      └─ orden en menú
    //                 │      │    │            │                 └─ ¿confirmar? (true/false)
    //                 │      │    │            └─ función a ejecutar (referencia directa)
    //                 │      │    └─ descripción mostrada en menú
    //                 │      └─ tecla asignada
    //                 └─ categoría interna
}
```

**Qué hace `RegisterKeymap()`:**
1. Agrega el comando al `KeymapRegistry` global (Map)
2. Almacena TODA la metadata en un lugar:
   - La tecla (`"d"`, `"x"`)
   - La descripción (`"List Devices"`)
   - La función a ejecutar (`Func("ADBListDevices")`)
   - Si necesita confirmación (`false`)
   - El orden en el menú (`1`, `2`)

## Fase 2: Inicialización (src/core/command_system_init.ahk)

Al inicio del script, se llama `InitializeCommandSystem()`:

```ahk
InitializeCommandSystem() {
    ; 1. Registrar categoría ADB
    RegisterCategory("a", "adb", "ADB Tools", 8)
    //                │    │      │            └─ posición en menú principal
    //                │    │      └─ título mostrado
    //                │    └─ nombre interno
    //                └─ tecla para activar categoría
    
    ; 2. Registrar todos los keymaps de ADB
    RegisterADBKeymaps()  // ← Llama a la función que definiste
    
    // ... registrar otras categorías
}
```

**Qué pasa internamente:**

```
HybridCapsLock.ahk inicia
    ↓
InitializeCommandSystem()
    ↓
RegisterCategory("a", "adb", "ADB Tools", 8)
    → CategoryRegistry["a"] = {symbol: "a", internal: "adb", title: "ADB Tools", order: 8}
    ↓
RegisterADBKeymaps()
    ↓
RegisterKeymap("adb", "d", "List Devices", ADBListDevices, false, 1)
    → KeymapRegistry["adb"]["d"] = {
        key: "d",
        desc: "List Devices",
        action: ADBListDevices,  // referencia directa a la función
        confirm: false,
        order: 1
    }
    ↓
RegisterKeymap("adb", "x", "Disconnect", ADBDisconnect, false, 2)
    → KeymapRegistry["adb"]["x"] = {
        key: "x",
        desc: "Disconnect",
        action: ADBDisconnect,  // referencia directa a la función
        confirm: false,
        order: 2
    }
```

## Fase 3: Ejecución (runtime)

Cuando el usuario presiona `<leader> → c → a → d`:

1. **Mostrar menú principal** (`<leader> → c`):
   ```ahk
   ShowCommandsMenu()
       → BuildMainMenuFromRegistry()  // Lee CategoryRegistry
           → Genera texto:
               "COMMAND PALETTE
               
               s - System Commands
               h - Hybrid Management
               ...
               a - ADB Tools    ← Aquí está
               ..."
   ```

2. **Mostrar submenú ADB** (usuario presiona `a`):
   ```ahk
   HandleCommandCategory("a")
       → GetCategoryBySymbol("a")  // Obtiene {internal: "adb", ...}
       → ShowDynamicCommandsMenu("adb")
           → BuildCategoryMenuFromRegistry("adb")  // Lee KeymapRegistry["adb"]
               → GetSortedCategoryKeymaps("adb")  // Ordena por campo 'order'
               → Genera texto:
                   "ADB TOOLS
                   
                   d - List Devices    ← orden 1
                   x - Disconnect      ← orden 2
                   s - Shell
                   ..."
   ```

3. **Ejecutar comando** (usuario presiona `d`):
   ```ahk
   ExecuteKeymap("adb", "d")
       → FindKeymap("adb", "d")  // Busca en KeymapRegistry
       → km = {
           action: Func("ADBListDevices"),
           confirm: false,
           ...
         }
       → if (km["confirm"]) → ConfirmYN()  // false, skip
       → km["action"].Call()  // ← EJECUTA ADBListDevices()
   ```

## Flujo Completo Resumido

```
Usuario presiona <leader> c a d
         ↓
┌────────────────────────────────────────────┐
│ 1. ShowCommandsMenu()                      │
│    → BuildMainMenuFromRegistry()           │
│    → Lee CategoryRegistry                  │
│    → Muestra: "a - ADB Tools"              │
└────────────────────────────────────────────┘
         ↓ usuario presiona 'a'
┌────────────────────────────────────────────┐
│ 2. HandleCommandCategory("a")              │
│    → ShowDynamicCommandsMenu("adb")        │
│    → BuildCategoryMenuFromRegistry("adb")  │
│    → Lee KeymapRegistry["adb"]             │
│    → Muestra: "d - List Devices"           │
└────────────────────────────────────────────┘
         ↓ usuario presiona 'd'
┌────────────────────────────────────────────┐
│ 3. ExecuteKeymap("adb", "d")               │
│    → FindKeymap("adb", "d")                │
│    → Obtiene Func("ADBListDevices")        │
│    → Ejecuta: ADBListDevices()             │
│    → Run("cmd.exe /k adb devices")         │
└────────────────────────────────────────────┘
```

## Ventajas de este Sistema

### ✅ Una Sola Fuente de Verdad
Todo definido en `src/actions/adb_actions.ahk`:
- Funciones
- Descripciones
- Teclas
- Orden
- Confirmaciones

### ✅ Sin Duplicación
NO necesitas:
- ❌ Definir en `commands.ini`
- ❌ Switch cases en `commands_layer.ahk`
- ❌ Funciones `Show*Menu()` hardcoded

### ✅ Menús Auto-generados
Los menús se generan dinámicamente del registry:
```ahk
BuildMainMenuFromRegistry()      // Menú principal desde CategoryRegistry
BuildCategoryMenuFromRegistry()  // Submenús desde KeymapRegistry
```

### ✅ Fácil Agregar Comandos
Para agregar `ADBPush`:
```ahk
// 1. Definir función
ADBPush() {
    Run("cmd.exe /k adb push")
    ShowCommandExecuted("ADB", "Push Files")
}

// 2. Agregar UNA línea en RegisterADBKeymaps()
RegisterKeymap("adb", "u", "Push Files", Func("ADBPush"), false, 9)
```

**¡Y YA!** El menú se actualiza automáticamente.

## Comparación con Sistema Anterior

### ❌ Sistema Antiguo (INI + Switch + Funciones separadas)

```
commands.ini:
    [a_category]
    d=List Devices
    x=Disconnect
         ↓
commands_layer.ahk:
    BuildADBMenu() {
        // Leer INI
        // Generar texto
    }
    
    ExecuteADBCommand(cmd) {
        switch cmd {
            case "d": Run("adb devices")
            case "x": Run("adb disconnect")
        }
    }
         ↓
adb_actions.ahk:
    ADBListDevices() { Run("...") }
    ADBDisconnect() { Run("...") }
```

**Problemas:**
- 3 lugares diferentes
- Difícil mantener sincronizado
- Orden hardcoded en INI

### ✅ Sistema Nuevo (Declarativo puro)

```
adb_actions.ahk:
    ADBListDevices() { Run("...") }
    ADBDisconnect() { Run("...") }
    
    RegisterADBKeymaps() {
        RegisterKeymap("adb", "d", "List Devices", Func("ADBListDevices"), false, 1)
        RegisterKeymap("adb", "x", "Disconnect", Func("ADBDisconnect"), false, 2)
    }
         ↓
command_system_init.ahk:
    RegisterCategory("a", "adb", "ADB Tools", 8)
    RegisterADBKeymaps()
         ↓
¡Menús auto-generados en runtime!
```

**Beneficios:**
- TODO en un archivo
- Una sola declaración por comando
- Menús dinámicos
- Orden explícito

## Agregar Nueva Categoría

Ejemplo: Agregar "Docker Commands":

1. **Crear** `src/actions/docker_actions.ahk`:
```ahk
DockerPS() {
    Run("cmd.exe /k docker ps")
    ShowCommandExecuted("Docker", "List Containers")
}

RegisterDockerKeymaps() {
    RegisterKeymap("docker", "p", "List Containers", DockerPS, false, 1)
}
```

2. **Agregar includes** en `HybridCapsLock.ahk`:
```ahk
#Include src\actions\docker_actions.ahk
```

3. **Registrar** en `command_system_init.ahk`:
```ahk
InitializeCommandSystem() {
    // ... otras categorías
    RegisterCategory("k", "docker", "Docker Commands", 10)
    
    // ... otros keymaps
    RegisterDockerKeymaps()
}
```

**¡LISTO!** Ahora `<leader> c k p` ejecuta `docker ps`.
