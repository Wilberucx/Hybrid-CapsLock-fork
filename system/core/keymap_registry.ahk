; ==============================
; Keymap Registry - Sistema Declarativo Jerárquico
; ==============================
; Central registry Neovim which-key style with hierarchical support
; 
; FILOSOFÍA: El layer/context SIEMPRE es explícito (primer parámetro)
; Esto permite mapear teclas en cualquier layer (leader, scroll, custom_layer, etc.)
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
global LayerRegistry := Map()       ; Registry for layer metadata (color, display name)

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
; REGISTRO JERÁRQUICO
; ==============================

RegisterKeymapHierarchical(layer, pathKeys, description, actionFunc, needsConfirm, order) {
    global KeymapRegistry
    
    ; Parsear todas las keys en el path
    parsedPathKeys := []
    Loop pathKeys.Length {
        keyInfo := ParseModifierKey(pathKeys[A_Index])
        parsedPathKeys.Push(keyInfo["parsed"])
    }
    
    ; Construir path completo: layer.key1.key2...
    if (parsedPathKeys.Length > 0) {
        fullPath := layer . "." . JoinArray(parsedPathKeys, ".")
        lastKey := parsedPathKeys[parsedPathKeys.Length]
        lastKeyDisplay := pathKeys[pathKeys.Length]  ; Original para display
    } else {
        ; Si no hay keys (solo layer), error
        throw Error("RegisterKeymapHierarchical requiere al menos una key")
    }
    
    ; Construir path del padre
    parentPath := layer
    if (parsedPathKeys.Length > 1) {
        parentKeys := []
        Loop parsedPathKeys.Length - 1 {
            parentKeys.Push(parsedPathKeys[A_Index])
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
    
    ; Registrar en el padre con ambas versiones de la key
    KeymapRegistry[parentPath][lastKey] := Map(
        "key", lastKey,                    ; Parsed (para ejecución)
        "displayKey", lastKeyDisplay,      ; Original (para UI)
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
    
    ; Parsear todas las keys en el path
    parsedPathKeys := []
    Loop pathKeys.Length {
        keyInfo := ParseModifierKey(pathKeys[A_Index])
        parsedPathKeys.Push(keyInfo["parsed"])
    }
    
    ; Construir path completo: layer.key1.key2...
    fullPath := layer . "." . JoinArray(parsedPathKeys, ".")
    lastKey := parsedPathKeys[parsedPathKeys.Length]
    lastKeyDisplay := pathKeys[pathKeys.Length]  ; Original para display
    
    ; Path del padre
    parentPath := layer
    if (parsedPathKeys.Length > 1) {
        parentKeys := []
        Loop parsedPathKeys.Length - 1 {
            parentKeys.Push(parsedPathKeys[A_Index])
        }
        parentPath := layer . "." . JoinArray(parentKeys, ".")
    }
    
    ; Asegurar padre existe
    if (!KeymapRegistry.Has(parentPath)) {
        KeymapRegistry[parentPath] := Map()
    }
    
    ; Registrar como categoría con ambas versiones de la key
    KeymapRegistry[parentPath][lastKey] := Map(
        "key", lastKey,                    ; Parsed (para ejecución)
        "displayKey", lastKeyDisplay,      ; Original (para UI)
        "path", fullPath,
        "desc", title,
        "isCategory", true,
        "order", order
    )
}

; ==============================
; REGISTRO DE METADATA DE LAYERS
; ==============================

; RegisterLayer(layerId, displayName, color, textColor := "#ffffff", suppressUnmapped := true)
; Registra metadata visual para un layer
; layerId: identificador interno (ej: "scroll", "nvim")
; displayName: nombre para mostrar (ej: "SCROLL MODE")
; color: color hex para el status pill background (ej: "#E6C07B")
; textColor: color hex para el texto del status pill (ej: "#ffffff")
; suppressUnmapped: si true (default), suprime teclas no mapeadas. Si false, las deja pasar.
RegisterLayer(layerId, displayName, color, textColor := "#ffffff", suppressUnmapped := true) {
    global LayerRegistry
    
    LayerRegistry[layerId] := Map(
        "id", layerId,
        "name", displayName,
        "color", color,
        "textColor", textColor,
        "suppressUnmapped", suppressUnmapped
    )
    
    ; Persist to centralized JSON file
    UpdateLayersJsonFile()
}

; GetLayerMetadata(layerId)
; Retorna el mapa de metadata o valores por defecto
GetLayerMetadata(layerId) {
    global LayerRegistry
    
    if (LayerRegistry.Has(layerId)) {
        return LayerRegistry[layerId]
    }
    
    ; Default fallback
    return Map(
        "id", layerId,
        "name", StrUpper(layerId),
        "color", "#007acc",      ; Default blue
        "textColor", "#ffffff",  ; Default white
        "suppressUnmapped", true ; Default: suppress unmapped keys
    )
}

; UpdateLayersJsonFile()
; Actualiza el archivo centralizado data/layers.json con todos los layers registrados
; Solo guarda id y name para cada layer
UpdateLayersJsonFile() {
    global LayerRegistry
    
    ; Ensure data directory exists
    dataDir := A_ScriptDir . "\data"
    if (!DirExist(dataDir)) {
        try {
            DirCreate(dataDir)
        } catch as e {
            ; Silently fail if can't create directory
            return
        }
    }
    
    ; Build layers array with only id and name
    layersArray := []
    for layerId, metadata in LayerRegistry {
        layerEntry := Map(
            "id", metadata["id"],
            "name", metadata["name"]
        )
        layersArray.Push(layerEntry)
    }
    
    ; Build complete JSON structure
    jsonData := Map(
        "layers", layersArray,
        "lastUpdate", FormatTime(, "yyyyMMddHHmmss")
    )
    
    ; Serialize to JSON
    try {
        jsonContent := SerializeJson(jsonData)
        
        ; Write to file
        layersFile := dataDir . "\layers.json"
        try {
            FileDelete(layersFile)
        }
        FileAppend(jsonContent, layersFile, "UTF-8")
    } catch as e {
        ; Silently fail if serialization or file write fails
        ; This prevents breaking the layer registration if JSON functions aren't available yet
    }
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
; PARSER DE MODIFICADORES
; ==============================

; ParseModifierKey(key)
; Parsea sintaxis estilo Vim de modificadores: <C-a>, <S-C-a>, <A-S-k>, etc.
; Convierte a sintaxis de AutoHotkey: ^a, +^a, !+k, etc.
;
; Modificadores soportados:
;   C = Ctrl  → ^
;   S = Shift → +
;   A = Alt   → !
;
; Ejemplos:
;   "<C-a>"     → {parsed: "^a", display: "<C-a>"}
;   "<S-C-a>"   → {parsed: "+^a", display: "<S-C-a>"}
;   "<A-S-k>"   → {parsed: "!+k", display: "<A-S-k>"}
;   "<C-A-S-x>" → {parsed: "^!+x", display: "<C-A-S-x>"}
;   "a"         → {parsed: "a", display: "a"}
;   "R"         → {parsed: "R", display: "R"}
;
; Retorna: Map con "parsed" (sintaxis AHK) y "display" (sintaxis original)
;
; NOTA: Shift (S) es solo para combinaciones con Ctrl/Alt.
;       Para Shift+key simple, usar mayúscula: "A" en vez de "<S-a>"
ParseModifierKey(key) {
    ; Si no tiene el patrón <...>, retornar sin cambios
    if (!RegExMatch(key, "^<(.+)>$", &match)) {
        return Map("parsed", key, "display", key)
    }
    
    ; Extraer contenido entre < y >
    content := match[1]
    
    ; Dividir por guión
    parts := StrSplit(content, "-")
    
    ; Si solo hay una parte, es inválido (debería ser <X-key>)
    if (parts.Length < 2) {
        return Map("parsed", key, "display", key)
    }
    
    ; La última parte es la tecla base
    baseKey := parts[parts.Length]
    
    ; Las partes anteriores son modificadores
    hasCtrl := false
    hasAlt := false
    hasShift := false
    
    Loop parts.Length - 1 {
        modifier := parts[A_Index]
        if (modifier = "C") {
            hasCtrl := true
        } else if (modifier = "A") {
            hasAlt := true
        } else if (modifier = "S") {
            hasShift := true
        }
        ; Ignorar modificadores desconocidos
    }
    
    ; Construir sintaxis de AutoHotkey
    ; Orden correcto: ^ (Ctrl), ! (Alt), + (Shift)
    ahkKey := ""
    if (hasCtrl)
        ahkKey .= "^"
    if (hasAlt)
        ahkKey .= "!"
    if (hasShift)
        ahkKey .= "+"
    ahkKey .= baseKey
    
    return Map("parsed", ahkKey, "display", key)
}

; ==============================
; CONSULTA DE KEYMAPS (DUAL MODE)
; ==============================

; GetKeymapsForPath(path)
; JERÁRQUICO: path = "leader.c.a"
GetKeymapsForPath(path) {
    global KeymapRegistry
    
    if (!KeymapRegistry.Has(path))
        return Map()
    
    return KeymapRegistry[path]
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

; ==============================
; EJECUCIÓN (JERÁRQUICO)
; ==============================

; ShowUnifiedConfirmation(description)
; Función unificada que detecta si C# tooltips están activos y usa el apropiado
ShowUnifiedConfirmation(description) {
    ; Native Windows MsgBox with Yes/No/Cancel buttons
    ; More visible and standard than tooltips
    result := MsgBox(
        "Execute: " . description . "?",
        "Confirm Action",
        "YesNoCancel Icon?"
    )
    
    ; Return true only if user clicked "Yes"
    return (result = "Yes")
}

; ExecuteKeymapAtPath(path, key)
; JERÁRQUICO
ExecuteKeymapAtPath(path, key) {
    ; Parsear la key de entrada para soportar sintaxis de modificadores
    keyInfo := ParseModifierKey(key)
    parsedKey := keyInfo["parsed"]
    
    keymaps := GetKeymapsForPath(path)
    
    if (!keymaps.Has(parsedKey))
        return false
    
    data := keymaps[parsedKey]
    
    ; Si es categoría, retornar el nuevo path
    if (data["isCategory"]) {
        return data["path"]
    }
    
    ; Es acción, ejecutar
    if (data["confirm"]) {
        ; Use unified confirmation system
        if (!ShowUnifiedConfirmation(data["desc"])) {
            ; User cancelled - return true to indicate action was handled (just not executed)
            return true
        }
    }
    
    data["action"]()
    return true
}

; ==============================
; GENERACIÓN DE MENÚS
; ==============================

; BuildMenuForPath(path, title := "")
; JERÁRQUICO
BuildMenuForPath(path, title := "") {
    items := GetSortedKeymapsForPath(path)
    
    if (items.Length = 0)
        return ""
    
    menuText := title != "" ? title . "`n`n" : ""
    
    for item in items {
        icon := item["isCategory"] ? "→" : "-"
        ; Usar displayKey si existe, sino usar key
        displayKey := item.Has("displayKey") ? item["displayKey"] : item["key"]
        menuText .= displayKey . " " . icon . " " . item["desc"] . "`n"
    }
    
    return menuText
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
        ; Usar displayKey si existe, sino usar key
        displayKey := item.Has("displayKey") ? item["displayKey"] : item["key"]
        result .= displayKey . ":" . item["desc"]
    }
    
    return result
}

; ==============================
; REGISTRO DE TRIGGERS
; ==============================

; RegisterTrigger(key, action, condition := "")
; Registra un hotkey global con condición opcional y SuspendExempt
; Reemplaza el uso de #HotIf y #SuspendExempt en keymap.ahk
;
; Ejemplos:
;   RegisterTrigger("F24", ActivateLeaderLayer, "LeaderLayerEnabled")
;   RegisterTrigger("F23", ActivateDynamicLayer, "DYNAMIC_LAYER_ENABLED")
;   RegisterTrigger("<C-s>", SaveFile, "EditorActive")
RegisterTrigger(key, action, condition := "") {
    ; Parsear la key para soportar sintaxis de modificadores
    keyInfo := ParseModifierKey(key)
    parsedKey := keyInfo["parsed"]
    
    if (condition != "") {
        ; Si la condición es una variable global, usar una función lambda para evaluarla
        if (Type(condition) = "String") {
            HotIf (*) => %condition%
        } else {
            HotIf condition
        }
    } else {
        HotIf
    }
    
    ; Registrar hotkey con opción "S" (SuspendExempt)
    ; Envolver la acción en una función lambda para crear un callback válido
    Hotkey(parsedKey, (*) => action(), "S")
    
    ; Resetear HotIf
    HotIf
}

; HasKeymaps(category)
; FLAT
HasKeymaps(category) {
    global KeymapRegistry
    return KeymapRegistry.Has(category) && KeymapRegistry[category].Count > 0
}

; ==============================
; DYNAMIC LAYER HELP SYSTEM
; ==============================

; GenerateLayerHelpItems(layerName)
; Genera dinámicamente los items de ayuda para un layer consultando el KeymapRegistry
; Retorna un string formateado para tooltips C# (key:desc|key:desc|...)
GenerateLayerHelpItems(layerName) {
    global KeymapRegistry
    
    ; Verificar que el layer existe
    if (!KeymapRegistry.Has(layerName)) {
        Log.w("Layer not found in registry: " . layerName, "HELP")
        return ""
    }
    
    ; Obtener keymaps ordenados
    items := GetSortedKeymapsForPath(layerName)
    
    if (items.Length = 0) {
        return ""
    }
    
    ; Generar string de items
    result := ""
    for item in items {
        if (result != "")
            result .= "|"
        
        ; Usar displayKey si existe, sino usar key
        displayKey := item.Has("displayKey") ? item["displayKey"] : item["key"]
        
        ; Agregar indicador visual para categorías
        desc := item["desc"]
        if (item["isCategory"]) {
            desc .= " →"
        }
        
        result .= displayKey . ":" . desc
    }
    
    return result
}

; ShowLayerHelp(layerName)
; Muestra un tooltip C# con todos los keymaps disponibles en el layer actual
ShowLayerHelp(layerName) {
    Log.d("Showing help for layer: " . layerName, "HELP")
    
    ; Generar items de ayuda
    items := GenerateLayerHelpItems(layerName)
    
    if (items = "") {
        ShowCenteredToolTip("No keymaps registered for layer: " . layerName)
        SetTimer(() => RemoveToolTip(), -2000)
        return
    }
    
    ; Verificar si tooltips C# están habilitados
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        ; Obtener metadata del layer para el título
        layerMeta := GetLayerMetadata(layerName)
        title := "Layer: " . layerMeta["name"] . " - Help"
        
        ; IMPORTANT: Mark menu as active so ListenForLayerKeymaps knows to handle ESC
        global tooltipMenuActive
        tooltipMenuActive := true
        
        ; Mostrar tooltip C# con timeout 0 (permanece hasta ESC)
        ShowCSharpTooltipWithType(title, items, "Esc: Close", 0, "leader")
    } else {
        ; Fallback a tooltip nativo
        menuText := "Layer: " . StrUpper(layerName) . " - Help`n`n"
        menuText .= BuildMenuForPath(layerName)
        menuText .= "`n[Esc: Close]"
        ShowCenteredToolTip(menuText)
    }
}

; ==============================
; LISTEN FOR PERSISTENT LAYER KEYMAPS
; ==============================
; Similar to NavigateHierarchical but for persistent layers (scroll, custom_layer, etc.)
; Listens for inputs while layer is active and executes registered keymaps

; ListenForLayerKeymaps(layerName, layerActiveVarName)
; layerName: nombre del layer en KeymapRegistry (ej: "scroll", "my_app")
; layerActiveVarName: nombre de la variable global que indica si layer está activo (ej: "isScrollLayerActive")
;
; Uso:
;   En OnScrollLayerActivate():
;     ListenForLayerKeymaps("scroll", "isScrollLayerActive")

ListenForLayerKeymaps(layerName, layerActiveVarName) {
    global CurrentLayerInputHook
    
    Log.t("========================================", "LAYER")
    Log.d("STARTING OPTIMIZED LISTENER", "LAYER")
    Log.d("Layer: " . layerName, "LAYER")
    Log.t("========================================", "LAYER")
    
    ; Verificar que el layer existe en KeymapRegistry
    if (!KeymapRegistry.Has(layerName)) {
        Log.e("Layer not found in KeymapRegistry: " . layerName, "LAYER")
        return false
    }
    
    ; Obtener configuración de supresión de teclas no mapeadas
    layerMeta := GetLayerMetadata(layerName)
    suppressUnmapped := layerMeta.Has("suppressUnmapped") ? layerMeta["suppressUnmapped"] : true
    
    Log.d("Layer suppress mode: " . (suppressUnmapped ? "SUPPRESS" : "PASSTHROUGH"), "LAYER")
    
    ; Loop persistente mientras la layer esté activa
    Loop {
        ; Verificar estado inicial
        try {
            isActive := false
            if (layerActiveVarName == "CurrentActiveLayer") {
                isActive := (CurrentActiveLayer == layerName)
            } else {
                isActive := %layerActiveVarName%
            }
            
            if (!isActive) {
                Log.d("Layer inactive at loop start, stopping", "LAYER")
                break
            }
        } catch {
            break
        }
        
        ; CRITICAL OPTIMIZATION: Persistent InputHook (No Timeout)
        ; We wait indefinitely for a key or for the hook to be stopped by DeactivateLayer
        ; NOTA: Siempre capturamos y suprimimos con "L1"
        ; En modo passthrough, enviamos manualmente las teclas no mapeadas después
        ih := InputHook("L1", "{Escape}{Enter}{Space}")
        ih.KeyOpt("{Escape}", "S")
        ih.KeyOpt("{Enter}", "S")
        ih.KeyOpt("{Space}", "S")
        
        ; Register global hook for external control
        CurrentLayerInputHook := ih
        
        ih.Start()
        ih.Wait() ; Waits forever until key press or Stop()
        
        ; Case 1: Hook stopped externally (DeactivateLayer called Stop)
        if (ih.EndReason = "Stopped") {
            Log.d("InputHook stopped externally (Layer Deactivated)", "LAYER")
            break
        }
        
        ; Case 2: EndKey Pressed (Escape or Enter)
        if (ih.EndReason = "EndKey") {
            endKey := ih.EndKey
            Log.d("ENDKEY PRESSED: " . endKey, "LAYER")
            
            ; Special handling for Escape
            if (endKey = "Escape") {
                ; Check if tooltip is active (e.g. Help Menu)
                ; If so, close tooltip but keep layer active
                if (IsSet(tooltipMenuActive) && tooltipMenuActive) {
                    Log.d("Tooltip active, closing tooltip but keeping layer", "LAYER")
                    HideCSharpTooltip()
                    continue
                }
                
                ; Check if ESC is registered in keymap
                if (ExecuteKeymapAtPath(layerName, "Escape")) {
                    Log.d("Executed registered Escape action", "LAYER")
                } else {
                    Log.d("No Escape action registered - Defaulting to Exit", "LAYER")
                    ReturnToPreviousLayer()
                }
                continue
            }
            
            ; Handle other EndKeys (Enter, etc.) as regular keymaps
            ; Try to execute as if it was a normal key press
            if (!ExecuteKeymapAtPath(layerName, endKey)) {
                ; If not mapped, pass through or suppress based on mode
                if (!suppressUnmapped) {
                    Log.d("EndKey not mapped, passing through: " . endKey, "LAYER")
                    Send("{" . endKey . "}")
                } else {
                    Log.d("EndKey not mapped, suppressed: " . endKey, "LAYER")
                }
            }
            continue
        }

        ; Case 3: Key Pressed
        key := ih.Input
        
        ; Empty or invalid key
        if (key = "" || key = Chr(0)) {
            continue
        }
        
        ; ==============================
        ; HELP KEY INTERCEPTOR
        ; ==============================
        ; Si el usuario presiona '?', mostrar ayuda del layer
        ; FIX: También chequear si es '/' con Shift presionado (para teclados US donde ? es Shift+/)
        if (key = "?" || (key = "/" && GetKeyState("Shift", "P"))) {
            Log.d("Help key pressed, showing layer help", "LAYER")
            try {
                ShowLayerHelp(layerName)
            } catch as helpErr {
                Log.e("Error showing layer help: " . helpErr.Message, "LAYER")
            }
            continue
        }
        
        ; Ejecutar keymap registrado
        Log.d("Key pressed: " . key . " in layer: " . layerName, "LAYER")
        
        try {
            result := ExecuteKeymapAtPath(layerName, key)
            
            if (result) {
                ; Keymap encontrado y ejecutado
                if (Type(result) = "String") {
                    ; Es una categoría, entrar en navegación jerárquica
                    Log.d("Category detected, entering hierarchical navigation: " . result, "LAYER")
                    NavigateHierarchicalInLayer(result, layerActiveVarName)
                }
            } else {
                ; NO se encontró keymap para esta tecla
                if (!suppressUnmapped) {
                    ; MODO PASSTHROUGH: Enviar la tecla manualmente
                    Log.d("Key not mapped, passing through: " . key, "LAYER")
                    Send("{Blind}" . key)
                } else {
                    ; MODO SUPPRESS: No hacer nada (tecla ya fue suprimida por InputHook)
                    Log.d("Key not mapped, suppressed: " . key, "LAYER")
                }
            }
        } catch as execErr {
            Log.e("Error executing keymap: " . execErr.Message, "LAYER")
        }
    }
    
    ; Cleanup
    CurrentLayerInputHook := ""
    Log.d("Stopped listener for layer: " . layerName, "LAYER")
    return true
}

; NavigateHierarchicalInLayer(currentPath, layerActiveVarName)
; Navegación jerárquica dentro de layers persistentes
; Similar a NavigateHierarchical pero respeta el estado de la layer
NavigateHierarchicalInLayer(currentPath, layerActiveVarName) {
    Log.d("Starting hierarchical navigation at path: " . currentPath, "LAYER")
    
    ; Stack para navegación (para back)
    pathStack := [currentPath]
    
    Loop {
        ; Verificar si layer sigue activa
        try {
            isActive := %layerActiveVarName%
            if (!isActive) {
                Log.d("Layer deactivated, exiting navigation", "LAYER")
                break
            }
        } catch {
            Log.e("State variable not found: " . layerActiveVarName, "LAYER")
            break
        }
        
        currentPath := pathStack[pathStack.Length]
        
        ; ==============================
        ; DELAYED FEEDBACK LOGIC
        ; ==============================
        
        ; 1. First attempt: Wait with short timeout (500ms)
        ih := InputHook("L1 T0.5", "{Escape}{Backspace}")
        ih.KeyOpt("{Escape}", "S")
        ih.KeyOpt("{Backspace}", "S")
        ih.Start()
        ih.Wait()
        
        ; 2. Check if timeout occurred (User is thinking...)
        if (ih.EndReason = "Timeout") {
            Log.d("Navigation timeout - Showing help for: " . currentPath, "LAYER")
            
            ; Show menu for current path
            try {
                if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
                    ; Use C# tooltip if available
                    items := GenerateCategoryItemsForPath(currentPath)
                    if (items != "") {
                        ; Extract title from path
                        title := currentPath
                        if (InStr(currentPath, ".")) {
                            parts := StrSplit(currentPath, ".")
                            title := parts[parts.Length]
                        }
                        
                        ; Show tooltip
                        ShowCSharpTooltipWithType("Category: " . title, items, "Esc: Exit", 0, "leader")
                    }
                } else {
                    ; Fallback to native tooltip
                    menuText := BuildMenuForPath(currentPath)
                    if (menuText != "") {
                        ShowCenteredToolTip(menuText . "`n[Backspace: Back] [Esc: Exit]")
                    }
                }
            } catch as tooltipErr {
                Log.e("Error showing tooltip: " . tooltipErr.Message, "LAYER")
            }
            
            ; 3. Second attempt: Wait indefinitely
            ih := InputHook("L1", "{Escape}{Backspace}")
            ih.KeyOpt("{Escape}", "S")
            ih.KeyOpt("{Backspace}", "S")
            ih.Start()
            ih.Wait()
        }
        
        ; Si fue timeout, verificar estado y continuar
        if (ih.EndReason = "Timeout") {
            ih.Stop()
            continue  ; Volver al inicio del loop para verificar isActive
        }
        
        ; Verificar nuevamente si layer sigue activa
        try {
            isActive := %layerActiveVarName%
            if (!isActive) {
                ih.Stop()
                try RemoveToolTip()
                break
            }
        } catch {
            ih.Stop()
            try RemoveToolTip()
            break
        }
        
        ; Handle Escape - exit navigation
        if (ih.EndReason = "EndKey" && ih.EndKey = "Escape") {
            ih.Stop()
            try RemoveToolTip()
            Log.d("Escape pressed, exiting navigation", "LAYER")
            break
        }
        
        ; Handle Backspace - go back
        if (ih.EndReason = "EndKey" && ih.EndKey = "Backspace") {
            ih.Stop()
            try RemoveToolTip()
            if (pathStack.Length > 1) {
                pathStack.Pop()
                Log.d("Going back to: " . pathStack[pathStack.Length], "LAYER")
                continue
            } else {
                Log.d("At root level, exiting navigation", "LAYER")
                break
            }
        }
        
        ; Get pressed key
        key := ih.Input
        ih.Stop()
        try RemoveToolTip()
        
        ; Empty or invalid key
        if (key = "" || key = Chr(0)) {
            continue
        }
        
        Log.d("Key pressed: " . key . " at path: " . currentPath, "LAYER")
        
        ; Execute keymap at current path
        try {
            result := ExecuteKeymapAtPath(currentPath, key)
            
            if (result) {
                if (Type(result) = "String") {
                    ; Es una categoría, navegar más profundo
                    pathStack.Push(result)
                    Log.d("Navigating deeper to: " . result, "LAYER")
                    continue
                } else {
                    ; Es una acción ejecutada, salir de navegación
                    Log.d("Action executed, exiting navigation", "LAYER")
                    break
                }
            } else {
                ; Tecla no encontrada
                Log.d("Key not found: " . key, "LAYER")
                continue
            }
        } catch as execErr {
            Log.e("Error executing keymap: " . execErr.Message, "LAYER")
            continue
        }
    }
    
    Log.d("Stopped hierarchical navigation", "LAYER")
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
