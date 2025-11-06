; ==============================
; ADB Actions - Funciones reutilizables
; ==============================
; Extracted from commands_layer.ahk para seguir arquitectura declarativa

; ==============================
; FUNCIONES DE ADB
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

; ==============================
; REGISTRO DE KEYMAPS (Fase 2 - Sistema Declarativo)
; ==============================
RegisterADBKeymaps() {
    RegisterKeymap("adb", "d", "List Devices", Func("ADBListDevices"), false)
    RegisterKeymap("adb", "i", "Install APK", Func("ADBInstallAPK"), false)
    RegisterKeymap("adb", "u", "Uninstall Package", Func("ADBUninstallPackage"), false)
    RegisterKeymap("adb", "l", "Logcat", Func("ADBLogcat"), false)
    RegisterKeymap("adb", "s", "Shell", Func("ADBShell"), false)
    RegisterKeymap("adb", "r", "Reboot Device", Func("ADBRebootDevice"), false)
    RegisterKeymap("adb", "c", "Clear App Data", Func("ADBClearAppData"), false)
}

; ==============================
; NOTA: Estas funciones son reutilizables
; Pueden ser llamadas desde cualquier parte del código
; ==============================
