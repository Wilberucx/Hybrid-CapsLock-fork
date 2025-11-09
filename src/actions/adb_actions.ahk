; ==============================
; ADB Actions - Sistema Declarativo Completo
; ==============================
; Estilo lazy.nvim: UNA SOLA DECLARACIÓN por comando
; Incluye: función + descripción + keymap + configuración

; ==============================
; FUNCIONES DE ACCIÓN
; ==============================

ADBListDevices() {
    Run("cmd.exe /k adb devices")
}

ADBInstallAPK() {
    Run("cmd.exe /k echo Select APK file to install && pause && adb install")
}

ADBUninstallPackage() {
    Run("cmd.exe /k echo Enter package name to uninstall && pause && adb uninstall")
}

ADBLogcat() {
    Run("cmd.exe /k adb logcat")
}

ADBShell() {
    Run("cmd.exe /k adb shell")
}

ADBRebootDevice() {
    Run("cmd.exe /k adb reboot")
}

ADBClearAppData() {
    Run("cmd.exe /k echo Enter package name to clear data && pause && adb shell pm clear")
}

ADBDisconnect() {
    Run("cmd.exe /k adb disconnect")
}

; ==============================
; REGISTRO DECLARATIVO JERÁRQUICO (Estilo which-key)
; ==============================
; Sintaxis jerárquica: RegisterKeymap(path..., desc, action, confirm, order)
; Ruta completa: Leader → c (Commands) → a (ADB) → key
; 
; Parámetros:
;   1-3. path: "c", "a", "d" (Leader.Commands.ADB.ListDevices)
;   4. description: texto del menú
;   5. action: FunctionName (referencia directa, sin Func())
;   6. confirm: mostrar confirmación (opcional, default false)
;   7. order: posición en menú (opcional, default 999)

RegisterADBKeymaps() {
    ; Ruta completa: Leader → c → a → key
    ; Orden lógico: Conexión → Info → Shell → Logs → Reinicio
    RegisterKeymap("c", "a", "d", "List Devices", ADBListDevices, false, 1)
    RegisterKeymap("c", "a", "x", "Disconnect", ADBDisconnect, false, 2)
    RegisterKeymap("c", "a", "s", "Shell", ADBShell, false, 3)
    RegisterKeymap("c", "a", "l", "Logcat", ADBLogcat, false, 4)
    RegisterKeymap("c", "a", "i", "Install APK", ADBInstallAPK, false, 5)
    RegisterKeymap("c", "a", "u", "Uninstall Package", ADBUninstallPackage, false, 6)
    RegisterKeymap("c", "a", "c", "Clear App Data", ADBClearAppData, false, 7)
    RegisterKeymap("c", "a", "r", "Reboot Device", ADBRebootDevice, false, 8)
}

