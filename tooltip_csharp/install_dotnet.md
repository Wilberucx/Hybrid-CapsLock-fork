# 📦 Instalación de .NET SDK

Para compilar y ejecutar la aplicación C# Tooltip, necesitas instalar .NET 6.0 SDK.

## 🔽 Descargar e Instalar

### Opción 1: Descarga Directa
1. Ve a: https://dotnet.microsoft.com/download/dotnet/6.0
2. Descarga ".NET 6.0 SDK" para Windows x64
3. Ejecuta el instalador y sigue las instrucciones

### Opción 2: Via Winget (Windows 10/11)
```powershell
winget install Microsoft.DotNet.SDK.6
```

### Opción 3: Via Chocolatey
```powershell
choco install dotnet-6.0-sdk
```

## ✅ Verificar Instalación

Después de instalar, abre una nueva terminal PowerShell y ejecuta:
```powershell
dotnet --version
```

Deberías ver algo como: `6.0.xxx`

## 🚀 Compilar y Ejecutar

Una vez instalado .NET SDK:
```powershell
cd tooltip_csharp
dotnet build
dotnet run
```

## 📋 Requisitos del Sistema

- Windows 10 versión 1607+ o Windows 11
- .NET 6.0 Runtime (incluido con SDK)
- ~200MB de espacio en disco

## 🔧 Troubleshooting

Si tienes problemas:
1. Reinicia la terminal después de instalar
2. Verifica que la variable PATH incluya .NET
3. Ejecuta `dotnet --info` para ver detalles de instalación