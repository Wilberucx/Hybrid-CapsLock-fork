; ===============================
; HYBRIDCAPSLOCK DEBUG LOGGING SYSTEM
; ===============================
; Sistema centralizado inteligente de debug y logging
; Autor: HybridCapsLock Dev Team
; Versión: 2.0 - Refactorizado con performance y simplicidad

; ===============================
; LOG LEVELS
; ===============================
class LogLevel {
    static TRACE := 0
    static DEBUG := 1
    static INFO := 2
    static WARNING := 3
    static ERROR := 4
    static OFF := 99
    
    static FromString(str) {
        switch StrUpper(str) {
            case "TRACE": return LogLevel.TRACE
            case "DEBUG": return LogLevel.DEBUG
            case "INFO": return LogLevel.INFO
            case "WARNING", "WARN": return LogLevel.WARNING
            case "ERROR": return LogLevel.ERROR
            case "OFF": return LogLevel.OFF
            default: return LogLevel.INFO
        }
    }
    
    static ToString(level) {
        switch level {
            case 0: return "TRACE"
            case 1: return "DEBUG"
            case 2: return "INFO"
            case 3: return "WARNING"
            case 4: return "ERROR"
            case 99: return "OFF"
            default: return "INFO"
        }
    }
}

; ===============================
; CORE LOGGING CLASS - API SIMPLIFICADA
; ===============================
class Log {
    static currentLevel := LogLevel.INFO
    static initialized := false
    
    ; API SIMPLIFICADA - Métodos cortos y expresivos
    static t(message, context := "") => Log._write(LogLevel.TRACE, message, context)
    static d(message, context := "") => Log._write(LogLevel.DEBUG, message, context)
    static i(message, context := "") => Log._write(LogLevel.INFO, message, context)
    static w(message, context := "") => Log._write(LogLevel.WARNING, message, context)
    static e(message, context := "") => Log._write(LogLevel.ERROR, message, context)
    
    ; Lazy evaluation para operaciones costosas
    static trace(callback, context := "") => Log._writeLazy(LogLevel.TRACE, callback, context)
    static debug(callback, context := "") => Log._writeLazy(LogLevel.DEBUG, callback, context)
    
    ; Método principal de escritura (optimizado)
    static _write(level, message, context := "") {
        ; Performance: retornar inmediatamente si el nivel no aplica
        if (level < Log.currentLevel) {
            return
        }
        
        ; Construir mensaje solo si es necesario
        levelStr := LogLevel.ToString(level)
        category := (context != "") ? context : levelStr
        fullMsg := "[" . category . "] " . message
        
        Log._sendToOutput(fullMsg)
    }
    
    ; Lazy evaluation - callback solo se ejecuta si el nivel aplica
    static _writeLazy(level, callback, context := "") {
        if (level < Log.currentLevel) {
            return
        }
        
        try {
            message := callback()
            Log._write(level, message, context)
        } catch as e {
            Log._write(LogLevel.ERROR, "Error en lazy evaluation: " . e.Message, "LOG_SYSTEM")
        }
    }
    
    ; Envío optimizado a OutputDebug y Archivo
    static _sendToOutput(message) {
        try {
            ; Obtener timestamp con milisegundos manualmente
            now := A_Now
            timestamp := FormatTime(now, "HH:mm:ss")
            ms := Mod(A_TickCount, 1000)
            msStr := Format("{:03}", ms)
            fullTimestamp := timestamp . "." . msStr
            
            finalMsg := "[" . fullTimestamp . "] " . message . "`n"
            
            ; 1. OutputDebug (para DebugView)
            OutputDebug(finalMsg)
            
            ; 2. Archivo de log (para usuario final)
            try {
                FileAppend(finalMsg, A_ScriptDir . "\hybrid_log.txt", "UTF-8")
            } catch {
                ; Ignorar errores de escritura en disco para no bloquear
            }
        } catch {
            ; Fallback sin timestamp
            try {
                OutputDebug(message . "`n")
                FileAppend(message . "`n", A_ScriptDir . "\hybrid_log.txt", "UTF-8")
            }
        }
    }
    
    ; Inicialización del sistema
    static Init() {
        if (Log.initialized) {
            return
        }
        
        Log.initialized := true
        
        try {
            ; Intentar leer de HybridConfig
            if (IsSet(HybridConfig) && IsObject(HybridConfig)) {
                if (HybridConfig.HasOwnProp("app")) {
                    ; Priorizar log_level si existe
                    if (HybridConfig.app.HasOwnProp("log_level")) {
                        Log.currentLevel := LogLevel.FromString(HybridConfig.app.log_level)
                    } else if (HybridConfig.app.HasOwnProp("debug_mode") && HybridConfig.app.debug_mode) {
                        Log.currentLevel := LogLevel.DEBUG
                    }
                }
            } else {
                ; Fallback: leer directamente del archivo
                Log._readFromConfigFile()
            }
            
            ; Siempre mostrar mensaje de inicialización (INFO level)
            Log.i("Sistema de logging inicializado - Nivel: " . LogLevel.ToString(Log.currentLevel), "LOG_SYSTEM")
        } catch as e {
            ; Modo seguro: solo errores
            Log.currentLevel := LogLevel.ERROR
            Log.e("Error al inicializar sistema de logs: " . e.Message, "LOG_SYSTEM")
        }
    }
    
    ; Leer configuración directamente del archivo (fallback)
    static _readFromConfigFile() {
        try {
            configPath := A_ScriptDir . "\ahk\config\settings.ahk"
            if (!FileExist(configPath)) {
                return
            }
            
            configContent := FileRead(configPath)
            
            ; Buscar log_level primero
            if (RegExMatch(configContent, 'log_level:\s*"(\w+)"', &match)) {
                Log.currentLevel := LogLevel.FromString(match[1])
                return
            }
            
            ; Fallback a debug_mode
            if (RegExMatch(configContent, "debug_mode:\s*(true|false)", &match)) {
                Log.currentLevel := (match[1] = "true") ? LogLevel.DEBUG : LogLevel.INFO
            }
        }
    }
    
    ; Control dinámico del nivel
    static SetLevel(level) {
        if (IsInteger(level)) {
            Log.currentLevel := level
        } else {
            Log.currentLevel := LogLevel.FromString(level)
        }
        Log.i("Nivel de logging cambiado a: " . LogLevel.ToString(Log.currentLevel), "LOG_SYSTEM")
    }
    
    static GetLevel() => Log.currentLevel
    static IsEnabled(level) => level >= Log.currentLevel
}

; ===============================
; FUNCIONES LEGACY - COMPATIBILIDAD
; ===============================

; Mantener compatibilidad con código existente
LogDebug(message, category := "DEBUG") => Log.d(message, category)
LogInfo(message, category := "INFO") => Log.i(message, category)
LogError(message, category := "ERROR") => Log.e(message, category)
LogWarning(message, category := "WARNING") => Log.w(message, category)

; Alias para InitDebugSystem
InitDebugSystem() => Log.Init()

; ===============================
; FUNCIONES ESPECIALIZADAS - SIMPLIFICADAS
; ===============================

; Funciones de trace de ejecución
LogFunctionEntry(functionName, params := "") {
    msg := (params != "") 
        ? "→ " . functionName . "(" . params . ")" 
        : "→ " . functionName . "()"
    Log.t(msg, "TRACE")
}

LogFunctionExit(functionName, result := "") {
    msg := (result != "") 
        ? "← " . functionName . " → " . result 
        : "← " . functionName
    Log.t(msg, "TRACE")
}

; Error con contexto enriquecido
LogErrorWithContext(message, functionName, errorObject := "") {
    errorMsg := "ERROR en " . functionName . ": " . message
    if (IsObject(errorObject) && errorObject.HasOwnProp("Message")) {
        errorMsg .= " | " . errorObject.Message
        if (errorObject.HasOwnProp("Line")) {
            errorMsg .= " (línea " . errorObject.Line . ")"
        }
    } else if (errorObject != "") {
        errorMsg .= " | " . errorObject
    }
    Log.e(errorMsg, "ERROR")
}

; Helpers especializados - unified API
LogVariable(varName, varValue, category := "VAR") => Log.d(varName . " = " . ToString(varValue), category)
LogLayerEvent(layerName, action, details := "") => Log.d("Layer '" . layerName . "' → " . action . (details != "" ? " | " . details : ""), "LAYER")
LogKeyEvent(key, action, context := "") => Log.d("Key '" . key . "' → " . action . (context != "" ? " | " . context : ""), "KEY")

; ===============================
; UTILIDADES - ToString mejorado
; ===============================

ToString(value, depth := 0, maxDepth := 3) {
    ; Prevenir recursión infinita
    if (depth > maxDepth) {
        return "[MAX_DEPTH]"
    }
    
    try {
        if (!IsSet(value)) {
            return "[UNSET]"
        }
        
        if (IsObject(value)) {
            ; Array
            if (value.HasOwnProp("Length") && IsInteger(value.Length)) {
                if (value.Length = 0) {
                    return "[]"
                }
                result := "["
                loop Min(value.Length, 10) {
                    if (A_Index > 1) result .= ", "
                    result .= ToString(value[A_Index], depth + 1, maxDepth)
                }
                if (value.Length > 10) {
                    result .= ", ... +" . (value.Length - 10) . " más"
                }
                return result . "]"
            }
            
            ; Map
            if (value.HasOwnProp("Count")) {
                return "{Map:" . value.Count . "}"
            }
            
            ; Objeto genérico
            result := "{"
            count := 0
            maxProps := 5
            for (prop, val in value.OwnProps()) {
                if (count >= maxProps) {
                    result .= ", ..."
                    break
                }
                if (count > 0) result .= ", "
                result .= prop . ": " . ToString(val, depth + 1, maxDepth)
                count++
            }
            return result . "}"
        }
        
        ; Valores primitivos
        if (value = "") {
            return '""'
        }
        if (value = true) {
            return "true"
        }
        if (value = false) {
            return "false"
        }
        
        return String(value)
    } catch {
        return "[ERROR_STRINGIFY]"
    }
}

; ===============================
; CONTROL Y HELPERS
; ===============================

; Control temporal del nivel de logging
EnableDebugTemporarily() => Log.SetLevel(LogLevel.DEBUG)
DisableDebugTemporarily() => Log.SetLevel(LogLevel.INFO)
IsDebugEnabled() => Log.IsEnabled(LogLevel.DEBUG)

; Wrapper mejorado con logging automático
SafeExecute(functionName, callback, errorHandler := "") {
    try {
        LogFunctionEntry(functionName)
        result := callback()
        LogFunctionExit(functionName, "OK")
        return result
    } catch as e {
        LogErrorWithContext("Función falló", functionName, e)
        if (errorHandler != "" && IsObject(errorHandler)) {
            return errorHandler(e)
        }
        throw e
    }
}

; ===============================
; CATEGORÍAS - Constantes para evitar typos
; ===============================
class LogCategory {
    static TRACE := "TRACE"
    static DEBUG := "DEBUG"
    static INFO := "INFO"
    static WARNING := "WARNING"
    static ERROR := "ERROR"
    static LAYER := "LAYER"
    static KEY := "KEY"
    static CONFIG := "CONFIG"
    static INIT := "INIT"
    static NVIM := "NVIM"
    static EXCEL := "EXCEL"
    static LEADER := "LEADER"
    static TOOLTIP := "TOOLTIP"
    static REGISTRY := "REGISTRY"
    static VAR := "VAR"
    static SYSTEM := "SYSTEM"
}

; ===============================
; AUTO-INIT
; ===============================
; Inicialización automática al incluir el archivo
Log.Init()