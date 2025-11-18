; ===============================
; Dependency Checker Module
; ===============================
; Verifica que AutoHotkey v2 y Kanata estén disponibles
; antes de inicializar HybridCapsLock

; Note: Debug functions are included via init.ahk

class DependencyChecker {
    
    ; ---- Verificar todas las dependencias ----
    static CheckAll() {
        results := {
            autohotkey: this.CheckAutoHotkey(),
            kanata: this.CheckKanata(),
            config: this.CheckConfigFiles()
        }
        
        results.allGood := results.autohotkey.status && results.kanata.status && results.config.status
        
        if (!results.allGood) {
            this.ShowDependencyDialog(results)
            return false
        }
        
        return true
    }
    
    ; ---- Verificar AutoHotkey v2 ----
    static CheckAutoHotkey() {
        ; AutoHotkey v2 siempre está disponible si este script está corriendo
        return {
            status: true,
            version: A_AhkVersion,
            path: A_AhkPath,
            message: "AutoHotkey v" . A_AhkVersion . " ✓"
        }
    }
    
    ; ---- Verificar Kanata ----
    static CheckKanata() {
        ; Buscar kanata.exe en ubicaciones comunes
        locations := [
            A_ScriptDir . "\bin\kanata.exe",              ; Portable release
            A_ScriptDir . "\kanata.exe",                  ; Root directory
            "C:\Program Files\kanata\kanata.exe",         ; Program Files
            A_AppData . "\..\Local\kanata\kanata.exe",    ; Local AppData
            "kanata.exe"                                   ; PATH
        ]
        
        for kanataLocation in locations {
            if (FileExist(kanataLocation)) {
                return {
                    status: true,
                    path: kanataLocation,
                    message: "Kanata found at: " . kanataLocation . " ✓"
                }
            }
        }
        
        ; Verificar si está en PATH
        try {
            RunWait('powershell -Command "Get-Command kanata -ErrorAction Stop"', , "Hide")
            return {
                status: true,
                path: "kanata (in PATH)",
                message: "Kanata found in system PATH ✓"
            }
        } catch {
            ; No encontrado
        }
        
        return {
            status: false,
            path: "",
            message: "Kanata not found ❌",
            downloadUrl: "https://github.com/jtroo/kanata/releases"
        }
    }
    
    ; ---- Verificar archivos de configuración ----
    static CheckConfigFiles() {
        requiredFiles := [
            "config\settings.ahk",
            "config\colorscheme.ahk",
            "config\kanata.kbd",
            "init.ahk"
        ]
        
        missing := []
        
        for requiredFile in requiredFiles {
            fullPath := A_ScriptDir . "\" . requiredFile
            if (!FileExist(fullPath)) {
                missing.Push(requiredFile)
            }
        }
        
        if (missing.Length > 0) {
            return {
                status: false,
                missing: missing,
                message: "Missing config files: " . this.ArrayJoin(missing, ", ") . " ❌"
            }
        }
        
        return {
            status: true,
            message: "All config files found ✓"
        }
    }
    
    ; ---- Mostrar diálogo de dependencias ----
    static ShowDependencyDialog(results) {
        message := "HybridCapsLock Dependency Check Results:`n`n"
        
        ; AutoHotkey status
        message .= "🔧 AutoHotkey: " . results.autohotkey.message . "`n"
        
        ; Kanata status
        message .= "⌨️  Kanata: " . results.kanata.message . "`n"
        if (!results.kanata.status) {
            message .= "    Download: " . results.kanata.downloadUrl . "`n"
        }
        
        ; Config files status
        message .= "📁 Config Files: " . results.config.message . "`n"
        
        if (!results.allGood) {
            message .= "`n❌ Some dependencies are missing!`n"
            message .= "`nOptions:`n"
            message .= "• Download missing components manually`n"
            message .= "• Run the PowerShell installer: install.ps1`n"
            message .= "• Download the Portable Release`n"
            message .= "`nContinue anyway? (HybridCapsLock may not work properly)"
            
            result := MsgBox(message, "HybridCapsLock - Dependencies Check", "YesNo Icon!")
            
            if (result = "No") {
                ExitApp(1)
            }
        } else {
            OutputDebug("[DependencyChecker] All dependencies satisfied ✓")
        }
    }
    
    ; ---- Helper: Join array elements ----
    static ArrayJoin(arr, separator) {
        result := ""
        for i, item in arr {
            if (i > 1) {
                result .= separator
            }
            result .= item
        }
        return result
    }
}

; ===============================
; Funciones de conveniencia
; ===============================

CheckDependencies() {
    return DependencyChecker.CheckAll()
}

IsKanataAvailable() {
    return DependencyChecker.CheckKanata().status
}
