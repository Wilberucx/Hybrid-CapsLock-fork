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
    ShowCommandExecuted("ADB", "List Devices")
}

ADBInstallAPK() {
    Run("cmd.exe /k echo Select APK file to install && pause && adb install")
    ShowCommandExecuted("ADB", "Install APK")
}

ADBUninstallPackage() {
    Run("cmd.exe /k echo Enter package name to uninstall && pause && adb uninstall")
    ShowCommandExecuted("ADB", "Uninstall Package")
}

ADBLogcat() {
    Run("cmd.exe /k adb logcat")
    ShowCommandExecuted("ADB", "Logcat")
}

ADBShell() {
    Run("cmd.exe /k adb shell")
    ShowCommandExecuted("ADB", "Shell")
}

ADBRebootDevice() {
    Run("cmd.exe /k adb reboot")
    ShowCommandExecuted("ADB", "Reboot Device")
}

ADBClearAppData() {
    Run("cmd.exe /k echo Enter package name to clear data && pause && adb shell pm clear")
    ShowCommandExecuted("ADB", "Clear App Data")
}

ADBDisconnect() {
    Run("cmd.exe /k adb disconnect")
    ShowCommandExecuted("ADB", "Disconnect")
}

; ==============================
; REGISTRO DECLARATIVO (Estilo lazy.nvim)
; ==============================
; UNA LÍNEA = UNA FUNCIÓN con toda su configuración
; Parámetros:
;   1. category: nombre interno ("adb")
;   2. key: tecla asignada
;   3. description: texto del menú
;   4. action: FunctionName (referencia directa, sin Func())
;   5. confirm: mostrar confirmación (opcional, default false)
;   6. order: posición en menú (opcional, default 999)

RegisterADBKeymaps() {
    ; Orden lógico: Conexión → Info → Shell → Logs → Reinicio
    RegisterKeymap("adb", "d", "List Devices", ADBListDevices, false, 1)
    RegisterKeymap("adb", "x", "Disconnect", ADBDisconnect, false, 2)
    RegisterKeymap("adb", "s", "Shell", ADBShell, false, 3)
    RegisterKeymap("adb", "l", "Logcat", ADBLogcat, false, 4)
    RegisterKeymap("adb", "i", "Install APK", ADBInstallAPK, false, 5)
    RegisterKeymap("adb", "u", "Uninstall Package", ADBUninstallPackage, false, 6)
    RegisterKeymap("adb", "c", "Clear App Data", ADBClearAppData, false, 7)
    RegisterKeymap("adb", "r", "Reboot Device", ADBRebootDevice, false, 8)
}

; ==============================
; BENEFICIOS DE ESTE ENFOQUE:
; ==============================
; ✓ Todo definido en UN SOLO LUGAR
; ✓ No duplicación con INI
; ✓ Menús auto-generados desde registry
; ✓ Fácil agregar/modificar comandos
; ✓ Ordenamiento explícito
; ✓ Confirmaciones por comando
; ==============================
