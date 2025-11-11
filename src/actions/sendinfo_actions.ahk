; ==============================
; Text Insert Actions - Sistema inteligente para insertar texto
; ==============================
; Función estilo ShellExec que usa closures para capturar texto
;
; ARQUITECTURA:
; - SendInfo(text, tooltipMsg) retorna una función que captura los parámetros
; - Similar a ShellExec, usa closures para evitar crear funciones individuales
; - Un solo patrón para toda la información

; ==============================
; FUNCIÓN PRINCIPAL (Estilo ShellExec)
; ==============================

/**
 * SendInfo - Crea una función que inserta texto con tooltip opcional
 * 
 * Similar a ShellExec, esta función retorna una closure que captura
 * el texto y mensaje de tooltip, permitiendo configurar en una sola línea.
 *
 * @param text - El texto a insertar
 * @param tooltipMsg - Mensaje del tooltip (opcional, por defecto "TEXT INSERTED")
 * @param tooltipDuration - Duración del tooltip en ms (opcional, por defecto 1500)
 * @return Una función que inserta el texto cuando se ejecuta
 *
 * @example
 * ; En config/keymap.ahk:
 * RegisterKeymap("leader", "i", "e", "Email", SendInfo("john@example.com", "EMAIL"), false, 1)
 * RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-1234"), false, 2)
 * RegisterKeymap("leader", "i", "h", "Hola", SendInfo("Hola, cómo estás?"), false, 3)
 */
SendInfo(text, tooltipMsg := "TEXT INSERTED", tooltipDuration := 1500) {
    ; Retorna una closure que captura text, tooltipMsg y tooltipDuration
    return (*) => InsertTextHelper(text, tooltipMsg, tooltipDuration)
}

InsertTextHelper(text, tooltipMsg, tooltipDuration) {
    SendText(text)
    try ShowCenteredToolTip(tooltipMsg)
    try SetTimer(() => RemoveToolTip(), -tooltipDuration)
    OutputDebug("[TEXT_INSERT] Inserted: " . text)
}

; ==============================
; FUNCIONES AVANZADAS (Opcionales)
; ==============================

/**
 * SendInfoMultiline - Para texto con múltiples líneas
 * Facilita la escritura de texto multilínea sin escapar `n
 *
 * @param lines - Array de líneas de texto
 * @param tooltipMsg - Mensaje del tooltip (opcional)
 * @return Una función que inserta el texto multilínea
 *
 * @example
 * RegisterKeymap("leader", "i", "s", "Signature", 
 *     SendInfoMultiline(["Saludos cordiales,", "Tu Nombre", "Tu Cargo"], "SIGNATURE"), 
 *     false, 1)
 */
SendInfoMultiline(lines, tooltipMsg := "TEXT INSERTED") {
    text := ""
    for index, line in lines {
        text .= line
        if (index < lines.Length)
            text .= "`n"
    }
    return SendInfo(text, tooltipMsg)
}

/**
 * SendInfoWithDelay - Inserta texto con delay entre caracteres
 * Útil para formularios que validan en tiempo real
 *
 * @param text - El texto a insertar
 * @param delayMs - Delay entre caracteres en ms
 * @param tooltipMsg - Mensaje del tooltip (opcional)
 * @return Una función que inserta el texto con delay
 */
SendInfoWithDelay(text, delayMs := 50, tooltipMsg := "TEXT INSERTED") {
    return (*) => InsertTextWithDelayHelper(text, delayMs, tooltipMsg)
}

InsertTextWithDelayHelper(text, delayMs, tooltipMsg) {
    SetKeyDelay(delayMs)
    SendText(text)
    SetKeyDelay(-1)
    try ShowCenteredToolTip(tooltipMsg)
    try SetTimer(() => RemoveToolTip(), -1500)
}

/**
 * SendInfoWithCallback - Inserta texto y ejecuta callback
 * Para casos que requieren procesamiento adicional
 *
 * @param text - El texto a insertar
 * @param callback - Función a ejecutar después
 * @param tooltipMsg - Mensaje del tooltip (opcional)
 * @return Una función que inserta texto y ejecuta callback
 */
SendInfoWithCallback(text, callback, tooltipMsg := "TEXT INSERTED") {
    return (*) => InsertTextWithCallbackHelper(text, callback, tooltipMsg)
}

InsertTextWithCallbackHelper(text, callback, tooltipMsg) {
    SendText(text)
    try ShowCenteredToolTip(tooltipMsg)
    try SetTimer(() => RemoveToolTip(), -1500)
    if (IsObject(callback))
        callback()
}

; ==============================
; FUNCIONES DE COMPATIBILIDAD (Deprecadas pero mantenidas)
; ==============================
; Estas funciones se mantienen para compatibilidad hacia atrás
; pero se recomienda usar SendInfo() en su lugar

InsertHola() {
    SendText("Hola, cómo estás?")
    try ShowCenteredToolTip("TEXT INSERTED: Hola")
    SetTimer(() => RemoveToolTip(), -1500)
}

; ==============================
; NOTAS DE USO
; ==============================
; NUEVO SISTEMA (Recomendado):
; ================================
; Todo en UNA sola línea en config/keymap.ahk:
;
; RegisterKeymap("leader", "i", "e", "Email", SendInfo("john@example.com", "EMAIL"), false, 1)
; RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-1234", "PHONE"), false, 2)
; RegisterKeymap("leader", "i", "n", "Name", SendInfo("John Doe", "NAME"), false, 3)
; RegisterKeymap("leader", "i", "a", "Address", SendInfo("123 Main St, City", "ADDRESS"), false, 4)
; RegisterKeymap("leader", "i", "h", "Hola", SendInfo("Hola, cómo estás?"), false, 5)
;
; VENTAJAS:
; - ✅ TODO en una línea (como ShellExec)
; - ✅ No necesitas crear función por cada texto
; - ✅ Fácil de leer y mantener
; - ✅ Tooltip personalizable
; - ✅ Usa closures (captura de contexto)
;
; ANTIGUO SISTEMA (Deprecado):
; ================================
; RegisterKeymap("leader", "i", "h", "Hola", InsertHola, false, 1)
; Requiere crear InsertHola() en este archivo
;
; COMPARACIÓN CON information.ini:
; ================================
; ANTES (information.ini - 3+ líneas por item):
; [PersonalInfo]
; Email=john@example.com
; [InfoMapping]
; e=Email
; order=e n p a
;
; DESPUÉS (keymap.ahk - 1 línea por item):
; RegisterKeymap("leader", "i", "e", "Email", SendInfo("john@example.com", "EMAIL"), false, 1)
