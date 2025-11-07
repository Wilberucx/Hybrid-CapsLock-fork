; ==============================
; Keymap Registry - Sistema Declarativo (Estilo lazy.nvim)
; ==============================
; Registro central de keymaps estilo Neovim which-key
; TODO LO DEFINIDO UNA SOLA VEZ: categorías + keymaps con metadata completa

; ---- Estructura de Keymap ----
; Map con:
;   category: "hybrid" | "system" | "git" | etc
;   key: "R" | "k" | "s" | etc  
;   desc: "Reload Script" | "Restart Kanata" | etc
;   action: Func("ReloadHybridScript") | etc
;   confirm: true | false
;   order: número para ordenamiento (opcional)

; ---- Estructura de Categoría ----
; Map con:
;   symbol: "h" | "s" | "g" | etc (tecla para activar)
;   internal: "hybrid" | "system" | "git" | etc (nombre interno)
;   title: "Hybrid Management" | "System Commands" | etc
;   order: número para ordenamiento en menú principal

global KeymapRegistry := Map()
global CategoryRegistry := Map()  ; Map indexed por symbol
global CategoryOrder := []        ; Array de symbols en orden

; ==============================
; REGISTRO DE CATEGORÍAS
; ==============================

; RegisterCategory(symbol, internal, title, order := 999)
; symbol: tecla para activar (ej: "h", "s", "g")
; internal: nombre interno para keymaps (ej: "hybrid", "system")
; title: título mostrado en menú
; order: posición en menú (menor = primero)
RegisterCategory(symbol, internal, title, order := 999) {
    global CategoryRegistry, CategoryOrder
    
    CategoryRegistry[symbol] := Map(
        "symbol", symbol,
        "internal", internal,
        "title", title,
        "order", order
    )
    
    ; Mantener orden
    CategoryOrder.Push(symbol)
    
    ; Inicializar Map de keymaps para esta categoría
    if (!KeymapRegistry.Has(internal)) {
        KeymapRegistry[internal] := Map()
    }
}

; Obtener categoría por símbolo
GetCategoryBySymbol(symbol) {
    global CategoryRegistry
    return CategoryRegistry.Has(symbol) ? CategoryRegistry[symbol] : false
}

; Obtener todas las categorías ordenadas
GetSortedCategories() {
    global CategoryRegistry, CategoryOrder
    
    categories := []
    for sym in CategoryOrder {
        if (CategoryRegistry.Has(sym))
            categories.Push(CategoryRegistry[sym])
    }
    
    ; Ordenar por campo 'order' usando bubble sort
    n := categories.Length
    Loop n - 1 {
        swapped := false
        Loop n - A_Index {
            i := A_Index
            if (categories[i]["order"] > categories[i + 1]["order"]) {
                ; Swap
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
; REGISTRO DE KEYMAPS
; ==============================

; RegisterKeymap(category, key, description, actionFunc, needsConfirm := false, order := 999)
; category: nombre interno (ej: "hybrid", "system")
; key: tecla (ej: "R", "k", "s")
; description: texto mostrado en menú
; actionFunc: Func("FunctionName") o closure
; needsConfirm: mostrar confirmación antes de ejecutar
; order: posición en submenú (opcional)
RegisterKeymap(category, key, description, actionFunc, needsConfirm := false, order := 999) {
    global KeymapRegistry
    
    ; Crear subcategoría si no existe
    if (!KeymapRegistry.Has(category)) {
        KeymapRegistry[category] := Map()
    }
    
    ; Registrar keymap con metadata completa
    KeymapRegistry[category][key] := Map(
        "key", key,
        "desc", description,
        "action", actionFunc,
        "confirm", needsConfirm,
        "order", order
    )
}

; ==============================
; CONSULTA DE KEYMAPS
; ==============================

; Obtener todos los keymaps de una categoría (sin ordenar)
GetCategoryKeymaps(category) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(category))
        return Map()
    
    return KeymapRegistry[category]
}

; Obtener keymaps ordenados de una categoría
GetSortedCategoryKeymaps(category) {
    keymaps := GetCategoryKeymaps(category)
    
    if (keymaps.Count = 0)
        return []
    
    ; Convertir a array
    kmArray := []
    for key, km in keymaps {
        kmArray.Push(km)
    }
    
    ; Ordenar por campo 'order' usando bubble sort
    n := kmArray.Length
    Loop n - 1 {
        swapped := false
        Loop n - A_Index {
            i := A_Index
            if (kmArray[i]["order"] > kmArray[i + 1]["order"]) {
                ; Swap
                temp := kmArray[i]
                kmArray[i] := kmArray[i + 1]
                kmArray[i + 1] := temp
                swapped := true
            }
        }
        if (!swapped)
            break
    }
    
    return kmArray
}

; ---- Función: Buscar keymap específico ----
FindKeymap(category, key) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(category))
        return false
    
    if (!KeymapRegistry[category].Has(key))
        return false
    
    return KeymapRegistry[category][key]
}

; ---- Función: Ejecutar keymap (con confirmación si necesita) ----
ExecuteKeymap(category, key) {
    km := FindKeymap(category, key)
    
    if (!km) {
        ; No encontrado → retornar false para que use fallback INI
        return false
    }
    
    ; Verificar confirmación
    if (km["confirm"]) {
        if (!ConfirmYN("Execute: " . km["desc"] . "?"))
            return true  ; confirmación cancelada, pero keymap existe
    }
    
    ; Ejecutar acción
    try {
        km["action"].Call()
        return true
    } catch as err {
        ShowCenteredToolTip("Error: " . km["desc"] . " - " . err.Message)
        SetTimer(() => RemoveToolTip(), -2000)
        return true
    }
}

; ==============================
; GENERACIÓN DE MENÚS DESDE REGISTRY
; ==============================

; Generar texto de menú principal desde categorías registradas
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

; Generar texto de submenú de categoría desde keymaps registrados
BuildCategoryMenuFromRegistry(categoryInternal) {
    ; Obtener título de categoría
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

; Generar string de items para tooltip C# desde keymaps
; Formato: "k:descripción|R:otra descripción|..."
GenerateCategoryItems(category) {
    keymaps := GetSortedCategoryKeymaps(category)
    
    if (keymaps.Length = 0)
        return ""  ; Sin keymaps, usar fallback INI
    
    items := ""
    
    for km in keymaps {
        if (items != "")
            items .= "|"
        items .= km["key"] . ":" . km["desc"]
    }
    
    return items
}

; ---- Función: Verificar si categoría tiene keymaps registrados ----
HasKeymaps(category) {
    global KeymapRegistry
    return KeymapRegistry.Has(category) && KeymapRegistry[category].Count > 0
}

; ==============================
; NOTA: Este sistema es híbrido
; - Si existe keymap registrado → usar registry
; - Si no existe → fallback a commands.ini (backward compatible)
; ==============================
