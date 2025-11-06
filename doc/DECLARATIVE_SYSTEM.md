# Sistema Declarativo de Comandos - Estilo lazy.nvim

## Arquitectura

```
┌─────────────────────────────────────────────────────┐
│  src/actions/*.ahk                                  │
│  ┌──────────────────────────────────────────────┐   │
│  │ RegisterADBKeymaps() {                       │   │
│  │   RegisterKeymap("adb", "d", "List Devices", │   │
│  │                  Func("ADBListDevices"), 1)  │   │
│  │   // Una línea = toda la configuración      │   │
│  │ }                                             │   │
│  └──────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────┘
                        │ Registra en
                        ▼
┌─────────────────────────────────────────────────────┐
│  src/core/keymap_registry.ahk                       │
│  ┌──────────────────────────────────────────────┐   │
│  │ CategoryRegistry: Map de categorías          │   │
│  │ KeymapRegistry: Map de keymaps por categoría │   │
│  │                                               │   │
│  │ BuildMainMenuFromRegistry()                  │   │
│  │ BuildCategoryMenuFromRegistry()              │   │
│  │ ExecuteKeymap()                              │   │
│  └──────────────────────────────────────────────┘   │
└───────────────────────┬─────────────────────────────┘
                        │ Usado por
                        ▼
┌─────────────────────────────────────────────────────┐
│  src/layer/commands_layer.ahk                       │
│  ┌──────────────────────────────────────────────┐   │
│  │ ShowCommandsMenu() → BuildMainMenuFromRegistry  │
│  │ HandleCommandCategory() → Dispatcher genérico│   │
│  │ ExecuteKeymap(category, key)                 │   │
│  └──────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────┘
```

## Ventajas vs Sistema Anterior

### ❌ Sistema Antiguo (INI + Switch)
```ahk
; config/commands.ini
[a_category]
d=List Devices
x=Disconnect

; commands_layer.ahk
ExecuteADBCommand(cmd) {
    switch cmd {
        case "d": Run("adb devices")
        case "x": Run("adb disconnect")
    }
}
```
**Problemas:**
- Duplicación: INI + switch + función
- Difícil mantener sincronizado
- Orden hardcoded en INI

### ✅ Sistema Nuevo (Declarativo)
```ahk
; src/actions/adb_actions.ahk
RegisterADBKeymaps() {
    RegisterKeymap("adb", "d", "List Devices", Func("ADBListDevices"), false, 1)
    RegisterKeymap("adb", "x", "Disconnect", Func("ADBDisconnect"), false, 2)
}
```
**Beneficios:**
- ✓ Una sola declaración por comando
- ✓ Menús auto-generados
- ✓ Ordenamiento explícito
- ✓ Confirmaciones por comando
- ✓ Sin archivos INI

## Uso

### 1. Registrar categoría (una vez)
```ahk
; HybridCapsLock.ahk o archivo de init
RegisterCategory("a", "adb", "ADB Tools", 7)
;                 │    │      │           └─ orden en menú principal
;                 │    │      └─ título mostrado
;                 │    └─ nombre interno para keymaps
;                 └─ símbolo/tecla para activar
```

### 2. Registrar keymaps
```ahk
RegisterKeymap("adb", "d", "List Devices", Func("ADBListDevices"), false, 1)
;               │      │    │               │                       │      └─ orden en submenú
;               │      │    │               │                       └─ confirmar antes? (true/false)
;               │      │    │               └─ función a ejecutar
;               │      │    └─ descripción en menú
;               │      └─ tecla
;               └─ categoría (interno)
```

### 3. Auto-generación de menús
```ahk
; Menú principal
text := BuildMainMenuFromRegistry()
; Genera:
; COMMAND PALETTE
;
; a - ADB Tools
; s - System Commands
; ...

; Submenú de categoría
text := BuildCategoryMenuFromRegistry("adb")
; Genera:
; ADB TOOLS
;
; d - List Devices
; x - Disconnect
; ...
```

## Migración de otras categorías

Para migrar una categoría existente:

1. Crear archivo `src/actions/CATEGORY_actions.ahk`
2. Mover funciones desde `commands_layer.ahk`
3. Crear `Register[CATEGORY]Keymaps()` con todas las declaraciones
4. Eliminar switch de `commands_layer.ahk`
5. Opcional: eliminar sección del INI

Ver `src/actions/adb_actions.ahk` como ejemplo completo.
