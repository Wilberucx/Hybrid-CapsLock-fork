# 🚀 GUÍA DE DESPLIEGUE - TOOLTIP SELF-CONTAINED

## ✅ **VENTAJAS DE LA CONFIGURACIÓN SELF-CONTAINED**

- 🎯 **Cero dependencias** - No requiere .NET Runtime instalado
- 📦 **Un solo archivo** - TooltipApp.exe contiene todo
- 🔧 **Plug-and-play** - Funciona en cualquier Windows 10/11
- 🚀 **Fácil distribución** - Solo copiar un archivo

## 📦 **PROCESO DE COMPILACIÓN**

### **1. Compilar (requiere .NET SDK solo una vez):**
```bash
cd tooltip_csharp
dotnet publish -c Release --self-contained true -r win-x64 --single-file
```

### **2. Resultado:**
```
tooltip_csharp/bin/Release/net6.0-windows/win-x64/publish/
└── TooltipApp.exe  (~60MB, self-contained)
```

### **3. Distribución:**
- Copiar `TooltipApp.exe` a cualquier ubicación
- No requiere instalaciones adicionales
- Funciona inmediatamente

## 🔧 **INTEGRACIÓN CON HYBRIDCAPSLOCK**

### **Opción 1: Copiar al directorio principal**
```
HybridCapsLock/
├── HybridCapsLock.ahk
├── TooltipApp.exe          ← Copiar aquí
└── tooltip_commands.json   ← Se crea automáticamente
```

Actualizar AutoHotkey:
```autohotkey
StartTooltipApp() {
    Process, Exist, TooltipApp.exe
    if (ErrorLevel = 0) {
        Run, TooltipApp.exe, , Hide
        Sleep, 500
    }
}
```

### **Opción 2: Mantener en subdirectorio**
```
HybridCapsLock/
├── HybridCapsLock.ahk
├── tooltip_csharp/
│   └── TooltipApp.exe      ← Copiar aquí
└── tooltip_commands.json
```

Usar la función existente:
```autohotkey
Run("tooltip_csharp\\TooltipApp.exe", , "Hide")
```

## 📋 **CHECKLIST DE DESPLIEGUE**

### **Para el Desarrollador (una sola vez):**
- [ ] Instalar .NET SDK 6.0
- [ ] Compilar con `dotnet publish`
- [ ] Verificar que TooltipApp.exe funciona standalone
- [ ] Probar comunicación JSON

### **Para el Usuario Final:**
- [ ] Copiar TooltipApp.exe al directorio deseado
- [ ] Incluir tooltip_csharp_integration.ahk en HybridCapsLock
- [ ] Agregar llamada StartTooltipApp() al inicio
- [ ] Probar tooltips

## 🎯 **VENTAJAS ESPECÍFICAS PARA HYBRIDCAPSLOCK**

### **✅ Simplicidad:**
- No hay que explicar instalación de .NET a usuarios
- Un solo archivo para distribuir
- Funciona "out of the box"

### **✅ Confiabilidad:**
- No depende de versiones de .NET del sistema
- No hay conflictos con otras aplicaciones
- Versión específica incluida

### **✅ Mantenimiento:**
- Actualizaciones simples (reemplazar un archivo)
- No hay problemas de compatibilidad
- Fácil rollback si hay problemas

## 📊 **ESPECIFICACIONES TÉCNICAS**

- **Tamaño:** ~60MB (incluye runtime completo)
- **Inicio:** ~300ms (ligeramente más lento que framework-dependent)
- **Memoria:** ~35MB (incluye overhead del runtime)
- **Compatibilidad:** Windows 10 x64+ (sin dependencias)

## 🔄 **PROCESO DE ACTUALIZACIÓN**

1. **Desarrollador compila nueva versión**
2. **Distribuye nuevo TooltipApp.exe**
3. **Usuario reemplaza archivo existente**
4. **Reinicia HybridCapsLock si es necesario**

¡Listo! La configuración self-contained hace que el despliegue sea extremadamente simple y confiable.