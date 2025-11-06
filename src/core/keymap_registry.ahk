; ==============================
; Keymap Registry - Sistema Declarativo
; ==============================
; Registro central de keymaps estilo Neovim
; Cada keymap define: categoría + tecla → función + descripción + confirmación

; ---- Estructura de Keymap ----
; Map con:
;   category: "hybrid" | "system" | "git" | etc
;   key: "R" | "k" | "s" | etc  
;   desc: "Reload Script" | "Restart Kanata" | etc
;   action: Func("ReloadHybridScript") | etc
;   confirm: true | false

global KeymapRegistry := Map()

; ---- Función: Registrar un keymap ----
; RegisterKeymap(category, key, description, actionFunc, needsConfirm := false)
RegisterKeymap(category, key, description, actionFunc, needsConfirm := false) {
    global KeymapRegistry
    
    ; Crear subcategoría si no existe
    if (!KeymapRegistry.Has(category)) {
        KeymapRegistry[category] := Map()
    }
    
    ; Registrar keymap
    KeymapRegistry[category][key] := Map(
        "desc", description,
        "action", actionFunc,
        "confirm", needsConfirm
    )
}

; ---- Función: Obtener todos los keymaps de una categoría ----
GetCategoryKeymaps(category) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(category))
        return Map()
    
    return KeymapRegistry[category]
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

; ---- Función: Generar string de items para tooltip desde keymaps ----
; Formato: "k:descripción|R:otra descripción|..."
GenerateCategoryItems(category) {
    keymaps := GetCategoryKeymaps(category)
    
    if (keymaps.Count = 0)
        return ""  ; Sin keymaps, usar fallback INI
    
    items := ""
    
    ; Iterar sobre keymaps (orden de registro)
    for key, km in keymaps {
        if (items != "")
            items .= "|"
        items .= key . ":" . km["desc"]
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
