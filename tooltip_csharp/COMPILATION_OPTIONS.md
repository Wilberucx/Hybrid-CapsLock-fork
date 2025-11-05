# 🔧 Opciones de compilación (estado real)

## Estado actual
- Ruta activa: .NET 6 (net6.0-windows) con System.Text.Json (sin dependencias externas).
- Las variantes (.NET Framework/Original/Simple) se han archivado y no forman parte del flujo actual.

## 📋 **PROBLEMA ACTUAL**

El proyecto .NET 6.0 tiene problemas de resolución de dependencias. Aquí están las opciones disponibles:

## 🎯 **OPCIÓN 1: .NET 6.0 (Actual) - Requiere Fix**

### **Comandos para Resolver:**
```powershell
cd tooltip_csharp
dotnet restore
dotnet publish -c Release --self-contained true -r win-x64 -p:PublishSingleFile=true
```

### **Ventajas:**
- ✅ Tecnología moderna
- ✅ Mejor rendimiento
- ✅ Self-contained

### **Desventajas:**
- ❌ Requiere resolver problemas de NuGet
- ❌ Archivo más grande (~80-100MB)

## 🎯 **OPCIÓN 2: .NET Framework 4.8 (Alternativa)**

### **Archivo Creado:**
- `TooltipApp_Framework.csproj` - Versión .NET Framework

### **Comandos para Compilar:**
```powershell
# Usando MSBuild (viene con Visual Studio o Build Tools)
msbuild TooltipApp_Framework.csproj /p:Configuration=Release
```

### **Ventajas:**
- ✅ Viene preinstalado en Windows 10/11
- ✅ No requiere dependencias adicionales
- ✅ Archivo pequeño (~500KB + DLLs)
- ✅ Compilación más simple

### **Desventajas:**
- ❌ Tecnología legacy
- ❌ Solo Windows

## 🚀 **RECOMENDACIÓN INMEDIATA**

### **Para Testing Rápido:**
Usar .NET Framework 4.8 para probar la funcionalidad inmediatamente.

### **Para Producción:**
Resolver los problemas de .NET 6.0 para tener la mejor solución a largo plazo.

## 🔧 **PASOS PARA CONTINUAR**

### **Opción A: Resolver .NET 6.0**
1. `dotnet restore` en el directorio del proyecto
2. Verificar que NuGet puede acceder a los paquetes
3. Compilar con el comando corregido

### **Opción B: Usar .NET Framework 4.8**
1. Instalar Visual Studio Build Tools si no están disponibles
2. Compilar con MSBuild
3. Probar funcionalidad básica

### **Opción C: Simplificar Dependencias**
1. Remover Newtonsoft.Json
2. Usar System.Text.Json (incluido en .NET 6.0)
3. Recompilar

¿Cuál opción prefieres probar primero?