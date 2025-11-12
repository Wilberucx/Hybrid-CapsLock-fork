; ==============================
; Keymap Registry - Sistema Declarativo Jerárquico
; ==============================
; Central registry Neovim which-key style with hierarchical support
; 
; FILOSOFÍA: El layer/context SIEMPRE es explícito (primer parámetro)
; Esto permite mapear teclas en cualquier layer (leader, scroll, nvim, excel, etc.)
;
; SINTAXIS CONSISTENTE:
; 1. Keymaps de un nivel:
;    RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)
;    RegisterKeymap("scroll", "h", "Scroll Up", WheelScrollUp, false, 1)
;
; 2. Keymaps multinivel (jerárquicos):
;    RegisterKeymap("leader", "c", "a", "d", "List Devices", ADBListDevices, false, 1)
;    Crea: leader → c → a → d
;
; 3. Categorías (submenu navigation):
;    RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
;    RegisterCategoryKeymap("leader", "c", "s", "System Commands", 1)

global KeymapRegistry := Map()      ; Keymaps jerárquicos: layer.path → Map de teclas
global CategoryRegistry := Map()    ; Categories with metadata (legacy flat system)
global CategoryOrder := []          ; Orden de categorías (legacy)

; ==============================
; REGISTRO DE CATEGORÍAS
; ==============================

; RegisterCategory(symbol, internal, title, order := 999)
; SINTAXIS FLAT (legacy compatible):
;   symbol: key to activate (e.g.: "h", "s")
;   internal: internal name for keymaps (e.g.: "hybrid", "system")
;   title: título mostrado
;   order: posición en menú
RegisterCategory(symbol, internal, title, order := 999) {
    global CategoryRegistry, CategoryOrder
    
    CategoryRegistry[symbol] := Map(
        "symbol", symbol,
        "internal", internal,
        "title", title,
        "order", order
    )
    
    CategoryOrder.Push(symbol)
    
    ; Initialize Map of keymaps for this category (flat)
    if (!KeymapRegistry.Has(internal)) {
        KeymapRegistry[internal] := Map()
    }
}

; GetCategoryBySymbol(symbol)
GetCategoryBySymbol(symbol) {
    global CategoryRegistry
    return CategoryRegistry.Has(symbol) ? CategoryRegistry[symbol] : false
}

; GetSortedCategories()
GetSortedCategories() {
    global CategoryRegistry, CategoryOrder
    
    categories := []
    for sym in CategoryOrder {
        if (CategoryRegistry.Has(sym))
            categories.Push(CategoryRegistry[sym])
    }
    
    ; Bubble sort por 'order'
    n := categories.Length
    Loop n - 1 {
        swapped := false
        Loop n - A_Index {
            i := A_Index
            if (categories[i]["order"] > categories[i + 1]["order"]) {
                temp := categories[i]
                categories[i] := categories[i + 1]
                categories[i + 1] := temp
                swapped := true
            }
        }
        if (!swapped)
            break
    }
    
    return categories
}

; ==============================
; REGISTRO DE KEYMAPS (SINTAXIS UNIFICADA)
; ==============================

; RegisterKeymap(layer, key(s)..., desc, action, [confirm], [order])
; El layer/context SIEMPRE es el primer parámetro (explícito)
;
; EJEMPLOS:
; - Un nivel:
;   RegisterKeymap("leader", "s", "Scroll", ActivateScrollLayer, false, 4)
;   RegisterKeymap("scroll", "h", "Scroll Up", WheelScrollUp, false, 1)
;
; - Multinivel (jerárquico):
;   RegisterKeymap("leader", "c", "a", "d", "List Devices", ADBListDevices, false, 1)
;   Resultado: leader.c.a.d → List Devices
;
; Metadata siempre al final:
;   - desc (requerido)
;   - action (requerido)
;   - confirm (opcional, boolean)
;   - order (opcional, integer)

RegisterKeymap(args*) {
    global KeymapRegistry
    
    ; Validar mínimo (layer + 1 key + desc + action = 4 args)
    if (args.Length < 4) {
        throw Error("RegisterKeymap requiere al menos: layer, key, description, action")
    }
    
    ; ==============================
    ; PASO 1: Extraer layer (SIEMPRE primer parámetro)
    ; ==============================
    
    layer := args[1]
    
    ; ==============================
    ; PASO 2: Detectar metadata al final
    ; ==============================
    
    metadataStart := args.Length - 1  ; Al menos desc + action
    hasConfirm := false
    hasOrder := false
    
    lastArg := args[args.Length]
    secondLastArg := args[args.Length - 1]
    
    ; Detectar: desc, action, confirm, order
    if (Type(lastArg) = "Integer" && (secondLastArg = true || secondLastArg = false)) {
        metadataStart := args.Length - 3
        hasConfirm := true
        hasOrder := true
    }
    ; Detectar: desc, action, confirm
    else if (lastArg = true || lastArg = false) {
        metadataStart := args.Length - 2
        hasConfirm := true
    }
    ; Detectar: desc, action, order
    else if (Type(lastArg) = "Integer") {
        metadataStart := args.Length - 2
        hasOrder := true
    }
    
    ; ==============================
    ; PASO 3: Extraer path keys (desde arg 2 hasta antes de metadata)
    ; ==============================
    
    pathKeys := []
    Loop metadataStart - 1 {
        if (A_Index > 1) {  ; Saltar el layer (arg 1)
            pathKeys.Push(args[A_Index])
        }
    }
    
    ; ==============================
    ; PASO 4: Extraer metadata
    ; ==============================
    
    description := args[metadataStart]
    actionFunc := args[metadataStart + 1]
    needsConfirm := false
    order := 999
    
    if (hasConfirm && hasOrder) {
        needsConfirm := args[metadataStart + 2]
        order := args[metadataStart + 3]
    } else if (hasConfirm) {
        needsConfirm := args[metadataStart + 2]
    } else if (hasOrder) {
        order := args[metadataStart + 2]
    }
    
    ; ==============================
    ; PASO 5: Registrar en KeymapRegistry
    ; ==============================
    
    RegisterKeymapHierarchical(layer, pathKeys, description, actionFunc, needsConfirm, order)
}

; ==============================
; REGISTRO FLAT (DEPRECATED - Mantener por compatibilidad legacy)
; ==============================
; NOTA: Esta función ya NO se usa en el sistema nuevo
; Todo pasa por RegisterKeymapHierarchical con layer explícito

RegisterKeymapFlat(category, key, description, actionFunc, needsConfirm, order) {
    global KeymapRegistry
    
    ; Crear categoría si no existe
    if (!KeymapRegistry.Has(category)) {
        KeymapRegistry[category] := Map()
    }
    
    ; PRIORIDAD: Solo registrar si no existe (config/keymap.ahk tiene prioridad)
    if (KeymapRegistry[category].Has(key)) {
        ; Ya existe - no sobrescribir (respeta prioridad)
        return false
    }
    
    ; Registrar keymap flat
    KeymapRegistry[category][key] := Map(
        "key", key,
        "desc", description,
        "action", actionFunc,
        "confirm", needsConfirm,
        "order", order,
        "isCategory", false
    )
    
    return true
}

; ==============================
; REGISTRO JERÁRQUICO
; ==============================

RegisterKeymapHierarchical(layer, pathKeys, description, actionFunc, needsConfirm, order) {
    global KeymapRegistry
    
    ; Construir path completo: layer.key1.key2...
    if (pathKeys.Length > 0) {
        fullPath := layer . "." . JoinArray(pathKeys, ".")
        lastKey := pathKeys[pathKeys.Length]
    } else {
        ; Si no hay keys (solo layer), error
        throw Error("RegisterKeymapHierarchical requiere al menos una key")
    }
    
    ; Construir path del padre
    parentPath := layer
    if (pathKeys.Length > 1) {
        parentKeys := []
        Loop pathKeys.Length - 1 {
            parentKeys.Push(pathKeys[A_Index])
        }
        parentPath := layer . "." . JoinArray(parentKeys, ".")
    }
    
    ; Asegurar que el padre existe
    if (!KeymapRegistry.Has(parentPath)) {
        KeymapRegistry[parentPath] := Map()
    }
    
    ; PRIORIDAD: Solo registrar si no existe (config/keymap.ahk tiene prioridad)
    if (KeymapRegistry[parentPath].Has(lastKey)) {
        ; Ya existe - no sobrescribir (respeta prioridad)
        return false
    }
    
    ; Registrar en el padre
    KeymapRegistry[parentPath][lastKey] := Map(
        "key", lastKey,
        "path", fullPath,
        "desc", description,
        "action", actionFunc,
        "confirm", needsConfirm,
        "order", order,
        "isCategory", false
    )
    
    return true
}

; ==============================
; REGISTRO DE CATEGORÍAS JERÁRQUICAS
; ==============================

; RegisterCategoryKeymap(layer, path..., title, [order])
; Registra una categoría que lleva a otro nivel
; El layer/context es SIEMPRE el primer parámetro (explícito)
; 
; Ejemplos:
;   RegisterCategoryKeymap("leader", "h", "Hybrid Management", 1)
;   RegisterCategoryKeymap("leader", "c", "a", "ADB Tools", 1)
;   RegisterCategoryKeymap("scroll", "advanced", "Advanced Scroll", 1)
RegisterCategoryKeymap(args*) {
    global KeymapRegistry
    
    if (args.Length < 3) {
        throw Error("RegisterCategoryKeymap requiere: layer, key(s)..., title, [order]")
    }
    
    ; PRIMER parámetro SIEMPRE es el layer/context
    layer := args[1]
    
    pathKeys := []
    title := ""
    order := 999
    
    ; Detectar si último es order
    if (Type(args[args.Length]) = "Integer") {
        order := args[args.Length]
        title := args[args.Length - 1]
        ; Extraer keys intermedias (desde arg 2 hasta Length-2)
        Loop args.Length - 3 {
            pathKeys.Push(args[A_Index + 1])
        }
    } else {
        title := args[args.Length]
        ; Extraer keys intermedias (desde arg 2 hasta Length-1)
        Loop args.Length - 2 {
            pathKeys.Push(args[A_Index + 1])
        }
    }
    
    ; Construir path completo: layer.key1.key2...
    fullPath := layer . "." . JoinArray(pathKeys, ".")
    lastKey := pathKeys[pathKeys.Length]
    
    ; Path del padre
    parentPath := layer
    if (pathKeys.Length > 1) {
        parentKeys := []
        Loop pathKeys.Length - 1 {
            parentKeys.Push(pathKeys[A_Index])
        }
        parentPath := layer . "." . JoinArray(parentKeys, ".")
    }
    
    ; Asegurar padre existe
    if (!KeymapRegistry.Has(parentPath)) {
        KeymapRegistry[parentPath] := Map()
    }
    
    ; Registrar como categoría
    KeymapRegistry[parentPath][lastKey] := Map(
        "key", lastKey,
        "path", fullPath,
        "desc", title,
        "isCategory", true,
        "order", order
    )
}

; ==============================
; FUNCIONES AUXILIARES
; ==============================

JoinArray(arr, separator := "") {
    result := ""
    Loop arr.Length {
        result .= arr[A_Index]
        if (A_Index < arr.Length) {
            result .= separator
        }
    }
    return result
}

; ==============================
; CONSULTA DE KEYMAPS (DUAL MODE)
; ==============================

; GetCategoryKeymaps(category)
; FLAT: category = "system"
GetCategoryKeymaps(category) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(category))
        return Map()
    
    return KeymapRegistry[category]
}

; GetKeymapsForPath(path)
; JERÁRQUICO: path = "leader.c.a"
GetKeymapsForPath(path) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(path))
        return Map()
    
    return KeymapRegistry[path]
}

; GetSortedCategoryKeymaps(category)
; FLAT
GetSortedCategoryKeymaps(category) {
    keymaps := GetCategoryKeymaps(category)
    return SortKeymaps(keymaps)
}

; GetSortedKeymapsForPath(path)
; JERÁRQUICO
GetSortedKeymapsForPath(path) {
    keymaps := GetKeymapsForPath(path)
    return SortKeymaps(keymaps)
}

; SortKeymaps(keymapsMap)
; Convierte Map a array ordenado por 'order'
SortKeymaps(keymapsMap) {
    if (keymapsMap.Count = 0)
        return []
    
    ; Convertir a array
    items := []
    for key, data in keymapsMap {
        items.Push(data)
    }
    
    ; Bubble sort por 'order'
    n := items.Length
    Loop n - 1 {
        swapped := false
        Loop n - A_Index {
            i := A_Index
            if (items[i]["order"] > items[i + 1]["order"]) {
                temp := items[i]
                items[i] := items[i + 1]
                items[i + 1] := temp
                swapped := true
            }
        }
        if (!swapped)
            break
    }
    
    return items
}

; FindKeymap(category, key)
; FLAT
FindKeymap(category, key) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(category))
        return false
    
    if (!KeymapRegistry[category].Has(key))
        return false
    
    return KeymapRegistry[category][key]
}

; ==============================
; EJECUCIÓN (DUAL MODE)
; ==============================

; ExecuteKeymap(category, key)
; FLAT
ExecuteKeymap(category, key) {
    km := FindKeymap(category, key)
    
    if (!km)
        return false
    
    if (km["confirm"]) {
        ; Simple Y/N confirmation (replacing complex confirmations.ahk system)
        ShowCenteredToolTip("Execute: " . km["desc"] . "?`n[y: Yes] [n/Esc: No]")
        ih := InputHook("L1 T3")  ; 3 second timeout
        ih.KeyOpt("{Escape}", "+")
        ih.Start()
        ih.Wait()
        confirmed := false
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            confirmed := false
        } else if (ih.EndReason = "Timeout") {
            confirmed := false
        } else {
            key := ih.Input
            if (key = "y" || key = "Y")
                confirmed := true
        }
        ih.Stop()
        SetTimer(() => RemoveToolTip(), -200)
        
        if (!confirmed)
            return true
    }
    
    try {
        km["action"].Call()
        return true
    } catch as e {
        ShowCenteredToolTip("Error: " . km["desc"] . " - " . e.Message)
        SetTimer(() => RemoveToolTip(), -2000)
        return true
    }
}

; ExecuteKeymapAtPath(path, key)
; JERÁRQUICO
ExecuteKeymapAtPath(path, key) {
    keymaps := GetKeymapsForPath(path)
    
    if (!keymaps.Has(key))
        return false
    
    data := keymaps[key]
    
    ; Si es categoría, retornar el nuevo path
    if (data["isCategory"]) {
        return data["path"]
    }
    
    ; Es acción, ejecutar
    if (data["confirm"]) {
        ; Simple Y/N confirmation
        ShowCenteredToolTip("Execute: " . data["desc"] . "?`n[y: Yes] [n/Esc: No]")
        ih := InputHook("L1 T3")  ; 3 second timeout
        ih.KeyOpt("{Escape}", "+")
        ih.Start()
        ih.Wait()
        confirmed := false
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            confirmed := false
        } else if (ih.EndReason = "Timeout") {
            confirmed := false
        } else {
            key := ih.Input
            if (key = "y" || key = "Y")
                confirmed := true
        }
        ih.Stop()
        SetTimer(() => RemoveToolTip(), -200)
        
        if (!confirmed)
            return false
    }
    
    data["action"]()
    return true
}

; ==============================
; GENERACIÓN DE MENÚS
; ==============================

; BuildMainMenuFromRegistry()
; FLAT (legacy)
BuildMainMenuFromRegistry() {
    text := "COMMAND PALETTE`n`n"
    
    categories := GetSortedCategories()
    
    if (categories.Length = 0) {
        text .= "[No categories registered]`n"
        return text
    }
    
    for cat in categories {
        text .= cat["symbol"] . " - " . cat["title"] . "`n"
    }
    
    text .= "`n[Backspace: Back] [Esc: Exit]"
    return text
}

; BuildCategoryMenuFromRegistry(categoryInternal)
; FLAT (legacy)
BuildCategoryMenuFromRegistry(categoryInternal) {
    global CategoryRegistry
    
    title := categoryInternal
    for sym, cat in CategoryRegistry {
        if (cat["internal"] = categoryInternal) {
            title := cat["title"]
            break
        }
    }
    
    text := title . "`n`n"
    keymaps := GetSortedCategoryKeymaps(categoryInternal)
    
    if (keymaps.Length = 0) {
        text .= "[No keymaps registered]`n"
    } else {
        for km in keymaps {
            text .= km["key"] . " - " . km["desc"] . "`n"
        }
    }
    
    text .= "`n[Backspace: Back] [Esc: Exit]"
    return text
}

; BuildMenuForPath(path, title := "")
; JERÁRQUICO
BuildMenuForPath(path, title := "") {
    items := GetSortedKeymapsForPath(path)
    
    if (items.Length = 0)
        return ""
    
    menuText := title != "" ? title . "`n`n" : ""
    
    for item in items {
        icon := item["isCategory"] ? "→" : "-"
        menuText .= item["key"] . " " . icon . " " . item["desc"] . "`n"
    }
    
    return menuText
}

; GenerateCategoryItems(category)
; FLAT (para tooltip C#)
GenerateCategoryItems(category) {
    keymaps := GetSortedCategoryKeymaps(category)
    
    if (keymaps.Length = 0)
        return ""
    
    items := ""
    for km in keymaps {
        if (items != "")
            items .= "|"
        items .= km["key"] . ":" . km["desc"]
    }
    
    return items
}

; GenerateCategoryItemsForPath(path)
; JERÁRQUICO (para tooltip C#)
GenerateCategoryItemsForPath(path) {
    items := GetSortedKeymapsForPath(path)
    
    if (items.Length = 0)
        return ""
    
    result := ""
    for item in items {
        if (result != "")
            result .= "|"
        result .= item["key"] . ":" . item["desc"]
    }
    
    return result
}

; HasKeymaps(category)
; FLAT
HasKeymaps(category) {
    global KeymapRegistry
    return KeymapRegistry.Has(category) && KeymapRegistry[category].Count > 0
}

; ==============================
; LISTEN FOR PERSISTENT LAYER KEYMAPS
; ==============================
; Similar to NavigateHierarchical but for persistent layers (nvim, scroll, excel, etc.)
; Listens for inputs while layer is active and executes registered keymaps

; ListenForLayerKeymaps(layerName, layerActiveVarName)
; layerName: nombre del layer en KeymapRegistry (ej: "scroll", "nvim")
; layerActiveVarName: nombre de la variable global que indica si layer está activo (ej: "isScrollLayerActive")
;
; Uso:
;   En OnScrollLayerActivate():
;     ListenForLayerKeymaps("scroll", "isScrollLayerActive")
;
ListenForLayerKeymaps(layerName, layerActiveVarName) {
    OutputDebug("[LayerListener] Starting listener for layer: " . layerName)
    
    ; Verificar que el layer existe en KeymapRegistry
    if (!KeymapRegistry.Has(layerName)) {
        OutputDebug("[LayerListener] ERROR: Layer not found in KeymapRegistry: " . layerName)
        return false
    }
    
    ; Loop persistente mientras la layer esté activa
    Loop {
        ; Verificar si layer sigue activa
        try {
            isActive := %layerActiveVarName%
            if (!isActive) {
                OutputDebug("[LayerListener] Layer deactivated: " . layerName)
                break
            }
        } catch {
            OutputDebug("[LayerListener] ERROR: State variable not found: " . layerActiveVarName)
            break
        }
        
        ; Esperar input (sin timeout - persistente)
        ih := InputHook("L1", "{Escape}")
        ih.KeyOpt("{Escape}", "S")
        ih.Start()
        ih.Wait()
        
        ; Verificar nuevamente si layer sigue activa (puede haberse desactivado durante input)
        try {
            isActive := %layerActiveVarName%
            if (!isActive) {
                ih.Stop()
                break
            }
        } catch {
            ih.Stop()
            break
        }
        
        ; Handle Escape - try to execute keymap if registered
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            ih.Stop()
            OutputDebug("[LayerListener] Escape pressed in layer: " . layerName)
            
            ; Try to execute registered Escape keymap if it exists
            try {
                result := ExecuteKeymapAtPath(layerName, "Escape")
                if (result) {
                    ; Keymap executed successfully
                    continue
                }
            } catch as execErr {
                OutputDebug("[LayerListener] ERROR executing Escape keymap: " . execErr.Message)
            }
            
            ; If no Escape keymap registered or execution failed, just exit
            OutputDebug("[LayerListener] No Escape keymap registered, exiting layer")
            break
        }
        
        ; Get pressed key
        key := ih.Input
        ih.Stop()
        
        ; Empty or invalid key
        if (key = "" || key = Chr(0)) {
            continue
        }
        
        ; Ejecutar keymap registrado (reusa ExecuteKeymapAtPath existente)
        ; Nota: Las persistent layers NO tienen jerarquía, solo acciones directas
        OutputDebug("[LayerListener] Key pressed: " . key . " in layer: " . layerName)
        
        try {
            ExecuteKeymapAtPath(layerName, key)
        } catch as execErr {
            OutputDebug("[LayerListener] ERROR executing keymap: " . execErr.Message)
        }
    }
    
    OutputDebug("[LayerListener] Stopped listener for layer: " . layerName)
    return true
}

; ==============================
; EJEMPLOS DE USO:
; ==============================
; FLAT (legacy):
;   RegisterCategory("s", "system", "System Commands", 1)
;   RegisterKeymap("system", "s", "System Info", ShowSystemInfo, false, 1)
;
; JERÁRQUICO (nuevo):
;   RegisterCategoryKeymap("c", "Commands", 1)
;   RegisterCategoryKeymap("c", "a", "ADB Tools", 1)
;   RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
;
; PERSISTENT LAYERS (nuevo):
;   RegisterKeymap("scroll", "h", "Scroll Left", ScrollLeft, false, 1)
;   RegisterKeymap("scroll", "j", "Scroll Down", ScrollDown, false, 2)
;   ; En scroll_layer.ahk:
;   OnScrollLayerActivate() {
;       isScrollLayerActive := true
;       ListenForLayerKeymaps("scroll", "isScrollLayerActive")
;   }
;
; Todas las sintaxis funcionan simultáneamente en el mismo sistema.
