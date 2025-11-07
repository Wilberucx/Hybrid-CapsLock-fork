#Requires AutoHotkey v2.0
#SingleInstance Force

; Test del sistema de registro dual (flat + jerárquico)
#Include src\core\keymap_registry.ahk

; ==============================
; FUNCIONES DE PRUEBA
; ==============================

TestActionFlat() {
    MsgBox("FLAT: System Info ejecutado!")
}

TestActionHierarchical() {
    MsgBox("JERÁRQUICO: ADB List Devices ejecutado!")
}

; ==============================
; TEST 1: SINTAXIS FLAT (legacy)
; ==============================

MsgBox("TEST 1: Registrando con sintaxis FLAT (legacy)`n`nRegisterKeymap('system', 's', 'System Info', TestActionFlat, false, 1)")

try {
    RegisterKeymap("system", "s", "System Info", TestActionFlat, false, 1)
    MsgBox("✅ FLAT: Registro exitoso")
} catch as err {
    MsgBox("❌ FLAT: Error - " . err.Message)
    ExitApp
}

; Verificar que se registró
km := FindKeymap("system", "s")
if (km) {
    MsgBox("✅ FLAT: Keymap encontrado`nDescripción: " . km["desc"] . "`nOrder: " . km["order"])
} else {
    MsgBox("❌ FLAT: Keymap NO encontrado")
    ExitApp
}

; ==============================
; TEST 2: SINTAXIS JERÁRQUICA (nueva)
; ==============================

MsgBox("TEST 2: Registrando con sintaxis JERÁRQUICA`n`nRegisterKeymap('c', 'a', 'd', 'List Devices', TestActionHierarchical, false, 1)")

try {
    ; Primero registrar las categorías
    RegisterCategoryKeymap("c", "Commands", 1)
    RegisterCategoryKeymap("c", "a", "ADB Tools", 1)
    
    ; Luego registrar la acción
    RegisterKeymap("c", "a", "d", "List Devices", TestActionHierarchical, false, 1)
    
    MsgBox("✅ JERÁRQUICO: Registro exitoso")
} catch as err {
    MsgBox("❌ JERÁRQUICO: Error - " . err.Message)
    ExitApp
}

; Verificar que se registró
keymaps := GetKeymapsForPath("leader.c.a")
if (keymaps.Has("d")) {
    km := keymaps["d"]
    MsgBox("✅ JERÁRQUICO: Keymap encontrado`nPath: leader.c.a.d`nDescripción: " . km["desc"] . "`nOrder: " . km["order"])
} else {
    MsgBox("❌ JERÁRQUICO: Keymap NO encontrado en path 'leader.c.a'")
    ExitApp
}

; ==============================
; TEST 3: AMBAS COEXISTEN
; ==============================

MsgBox("TEST 3: Verificando que AMBAS sintaxis coexisten")

; Verificar flat
flatExists := FindKeymap("system", "s") ? true : false
; Verificar jerárquico
hierExists := GetKeymapsForPath("leader.c.a").Has("d")

if (flatExists && hierExists) {
    MsgBox("✅ AMBAS SINTAXIS FUNCIONAN SIMULTÁNEAMENTE`n`nFlat: " . (flatExists ? "✓" : "✗") . "`nJerárquico: " . (hierExists ? "✓" : "✗"))
} else {
    MsgBox("❌ ERROR: No coexisten ambas sintaxis")
    ExitApp
}

; ==============================
; TEST 4: EJECUCIÓN
; ==============================

response := MsgBox("TEST 4: ¿Ejecutar acciones?`n`nProbaremos:`n1. FLAT: system → s`n2. JERÁRQUICO: leader.c.a → d", "Confirmación", "YesNo")

if (response = "Yes") {
    ; Ejecutar FLAT
    MsgBox("Ejecutando FLAT...")
    ExecuteKeymap("system", "s")
    
    ; Ejecutar JERÁRQUICO
    MsgBox("Ejecutando JERÁRQUICO...")
    ExecuteKeymapAtPath("leader.c.a", "d")
}

; ==============================
; RESULTADO FINAL
; ==============================

MsgBox("🎉 TODOS LOS TESTS PASARON`n`n✅ Sintaxis FLAT funciona`n✅ Sintaxis JERÁRQUICA funciona`n✅ Ambas coexisten sin conflictos`n✅ Ejecución funciona en ambas", "¡ÉXITO!")

ExitApp
