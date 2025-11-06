# Kanata Scripts

Scripts VBS para gestionar Kanata desde AutoHotkey.

## 📁 Archivos

### `start_kanata.vbs`
Inicia Kanata de forma oculta (sin ventana de consola).

**Características**:
- ✅ Detecta automáticamente el usuario (`%USERPROFILE%`)
- ✅ Ruta universal (no hardcoded)
- ✅ Busca kanata.exe en: `%USERPROFILE%\kanata\kanata.exe`
- ✅ Usa kanata.kbd del proyecto (ruta relativa)
- ✅ Verifica que archivos existan antes de ejecutar

**Configuración**:
Edita la línea 19 si tu kanata.exe está en otro lugar:
```vbscript
' Por defecto (universal):
kanataPath = userProfile & "\kanata\kanata.exe"

' O usa una de estas alternativas:
' kanataPath = FSO.BuildPath(projectRoot, "kanata.exe")
' kanataPath = "C:\Program Files\Kanata\kanata.exe"
```

### `stop_kanata.vbs`
Detiene Kanata si está corriendo.

**Uso**: Doble click o ejecutar desde AHK con `StopKanata()`

### `restart_kanata.vbs`
Reinicia Kanata (stop + start).

**Uso**: Doble click o ejecutar desde AHK con `RestartKanata()`

---

## 🔧 Uso desde AutoHotkey

Estas funciones están disponibles en `kanata_launcher.ahk`:

```autohotkey
; Iniciar Kanata si no está corriendo
StartKanataIfNeeded()

; Detener Kanata
StopKanata()

; Reiniciar Kanata
RestartKanata()
```

---

## 📂 Estructura de Directorios

```
Hybrid-CapsLock-fork/
├── kanata.kbd                     ← Config de Kanata
├── src/
│   └── core/
│       ├── kanata/
│       │   ├── start_kanata.vbs   ← Iniciar
│       │   ├── stop_kanata.vbs    ← Detener
│       │   ├── restart_kanata.vbs ← Reiniciar
│       │   └── README.md          ← Este archivo
│       └── kanata_launcher.ahk    ← Módulo AHK
└── HybridCapsLock.ahk             ← Script principal

Usuario/
└── kanata/
    └── kanata.exe                 ← Ejecutable de Kanata
```

---

## ⚙️ Configuración Inicial

### Opción 1: Kanata en carpeta del usuario (Recomendado)

1. Crea la carpeta: `C:\Users\TuUsuario\kanata\`
2. Coloca `kanata.exe` ahí
3. Los scripts ya están configurados para esta ubicación

### Opción 2: Kanata en el proyecto

1. Coloca `kanata.exe` en la raíz del proyecto
2. Edita `start_kanata.vbs` línea 22:
   ```vbscript
   kanataPath = FSO.BuildPath(projectRoot, "kanata.exe")
   ```

### Opción 3: Kanata en Program Files

1. Instala Kanata en `C:\Program Files\Kanata\`
2. Edita `start_kanata.vbs` línea 25:
   ```vbscript
   kanataPath = "C:\Program Files\Kanata\kanata.exe"
   ```

---

## 🧪 Testing

Para probar que funciona:

1. **Test manual**: Doble click en `start_kanata.vbs`
   - Si hay error, mostrará un MsgBox
   - Si funciona, Kanata inicia sin ventana

2. **Verificar**: Abre Task Manager
   - Busca `kanata.exe` en procesos
   - Debería estar corriendo

3. **Test desde AHK**: Ejecuta `HybridCapsLock.ahk`
   - Kanata debería iniciarse automáticamente
   - Prueba: Hold CapsLock + hjkl (navegación)

---

## 🐛 Troubleshooting

### Error: "No se encontró kanata.exe"
- Verifica la ruta en `start_kanata.vbs` línea 19
- Asegúrate que `kanata.exe` existe en esa ubicación

### Error: "No se encontró kanata.kbd"
- El archivo debe estar en la raíz del proyecto
- Nombre exacto: `kanata.kbd` (lowercase)

### Kanata no inicia desde HybridCapsLock
- Verifica que `src/core/kanata/start_kanata.vbs` existe
- Ejecuta manualmente para ver el error
- Revisa permisos de ejecución de VBS

---

**Última actualización**: 2025-11-05
