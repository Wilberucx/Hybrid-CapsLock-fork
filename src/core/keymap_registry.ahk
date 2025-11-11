; ==============================
; Keymap Registry - Sistema Declarativo Jerárquico
; ==============================
; Central registry Neovim which-key style with hierarchical support
; 
; SOPORTA DOS SINTAXIS:
; 1. Sintaxis flat (legacy):
;    RegisterKeymap("system", "s", "System Info", ShowSystemInfo, false, 1)
;
; 2. Sintaxis jerárquica (nueva):
;    RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
;    Crea: Leader → c → a → d (multinivel)
;
; El sistema detecta automáticamente qué sintaxis se está usando.

global KeymapRegistry := Map()      ; Keymaps jerárquicos y flat
global CategoryRegistry := Map()    ; Categories with metadata
global CategoryOrder := []          ; Orden de categorías
global LeaderRoot := "leader"       ; Raíz del sistema jerárquico

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
; REGISTRO DE KEYMAPS (DUAL SYNTAX)
; ==============================

; RegisterKeymap(args*)
; DETECTA AUTOMÁTICAMENTE LA SINTAXIS:
;
; FLAT (2 keys + metadata):
;   RegisterKeymap(category, key, desc, action, [confirm], [order])
;   Ejemplo: RegisterKeymap("system", "s", "System Info", ShowSystemInfo, false, 1)
;
; JERÁRQUICA (3+ keys + metadata):
;   RegisterKeymap(key1, key2, key3, ..., desc, action, [confirm], [order])
;   Ejemplo: RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
;
; Metadata siempre al final:
;   - desc (requerido)
;   - action (requerido)
;   - confirm (opcional, boolean)
;   - order (opcional, integer)

RegisterKeymap(args*) {
    global KeymapRegistry
    
    ; Validar mínimo (2 keys + desc + action = 4 args)
    if (args.Length < 4) {
        throw Error("RegisterKeymap requiere al menos: key1, key2, description, action")
    }
    
    ; ==============================
    ; PASO 1: Detectar metadata al final
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
    ; PASO 2: Extraer path keys
    ; ==============================
    
    pathKeys := []
    Loop metadataStart - 1 {
        pathKeys.Push(args[A_Index])
    }
    
    ; ==============================
    ; PASO 3: Extraer metadata
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
    ; PASO 4: Determinar sintaxis
    ; ==============================
    
    if (pathKeys.Length = 2) {
        ; SINTAXIS FLAT: RegisterKeymap("system", "s", ...)
        RegisterKeymapFlat(pathKeys[1], pathKeys[2], description, actionFunc, needsConfirm, order)
    } else {
        ; SINTAXIS JERÁRQUICA: RegisterKeymap("c", "a", "d", ...)
        RegisterKeymapHierarchical(pathKeys, description, actionFunc, needsConfirm, order)
    }
}

; ==============================
; REGISTRO FLAT (legacy compatible)
; ==============================

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
; REGISTRO JERÁRQUICO (nuevo)
; ==============================

RegisterKeymapHierarchical(pathKeys, description, actionFunc, needsConfirm, order) {
    global KeymapRegistry, LeaderRoot
    
    ; Detectar si ya comienza con "leader"
    adjustedPathKeys := []
    if (pathKeys[1] = LeaderRoot) {
        ; Si ya comienza con "leader", usar sin duplicar
        Loop pathKeys.Length - 1 {
            adjustedPathKeys.Push(pathKeys[A_Index + 1])
        }
        fullPath := LeaderRoot . "." . JoinArray(adjustedPathKeys, ".")
        lastKey := pathKeys[pathKeys.Length]
    } else {
        ; Comportamiento original para paths sin "leader"
        fullPath := LeaderRoot . "." . JoinArray(pathKeys, ".")
        lastKey := pathKeys[pathKeys.Length]
        adjustedPathKeys := pathKeys
    }
    
    ; Construir path del padre
    parentPath := LeaderRoot
    if (adjustedPathKeys.Length > 1) {
        parentKeys := []
        Loop adjustedPathKeys.Length - 1 {
            parentKeys.Push(adjustedPathKeys[A_Index])
        }
        parentPath := LeaderRoot . "." . JoinArray(parentKeys, ".")
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

; RegisterCategoryKeymap(path..., title, [order])
; Registra una categoría que lleva a otro nivel
; Ejemplo: RegisterCategoryKeymap("c", "a", "ADB Tools", 1)
RegisterCategoryKeymap(args*) {
    global KeymapRegistry, LeaderRoot
    
    if (args.Length < 2) {
        throw Error("RegisterCategoryKeymap requiere: path..., title, [order]")
    }
    
    pathKeys := []
    title := ""
    order := 999
    
    ; Detectar si último es order
    if (Type(args[args.Length]) = "Integer") {
        order := args[args.Length]
        title := args[args.Length - 1]
        Loop args.Length - 2 {
            pathKeys.Push(args[A_Index])
        }
    } else {
        title := args[args.Length]
        Loop args.Length - 1 {
            pathKeys.Push(args[A_Index])
        }
    }
    
    fullPath := LeaderRoot . "." . JoinArray(pathKeys, ".")
    lastKey := pathKeys[pathKeys.Length]
    
    ; Path del padre
    parentPath := LeaderRoot
    if (pathKeys.Length > 1) {
        parentKeys := []
        Loop pathKeys.Length - 1 {
            parentKeys.Push(pathKeys[A_Index])
        }
        parentPath := LeaderRoot . "." . JoinArray(parentKeys, ".")
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
; Ambas sintaxis funcionan simultáneamente en el mismo sistema.
