# 📦 Guía de Instalación

Instrucciones completas de instalación para HybridCapslock en Windows.

---

## Prerequisitos

Antes de instalar HybridCapslock, asegúrate de tener:

- **Windows 10 u 11** (64-bit recomendado)
- **Privilegios de Administrador** (requerido para instalación del driver de Kanata)
- **AutoHotkey v2.0+** - [Descargar aquí](https://www.autohotkey.com/)
- **Kanata** - [Descargar aquí](https://github.com/jtroo/kanata/releases)
- Conocimiento básico de línea de comandos (opcional pero útil)

---

## Instalación Paso a Paso

### Paso 1: Instalar AutoHotkey v2

1. **Descargar AutoHotkey v2.0+**
   - Ve a [autohotkey.com](https://www.autohotkey.com/)
   - Descarga el instalador de la última versión v2.0 (NO v1.1)

2. **Ejecutar el instalador**
   - Haz doble clic en el archivo `.exe` descargado
   - Sigue el asistente de instalación
   - Elige "Instalación Express" para configuración por defecto

3. **Verificar la instalación**

   ```powershell
   # Abre PowerShell y ejecuta:
   autohotkey --version

   # Debería mostrar algo como:
   # AutoHotkey v2.0.18
   ```

---

### Paso 2: Instalar Kanata

1. **Descargar Kanata**
   - Ve a [Kanata Releases](https://github.com/jtroo/kanata/releases)
   - Descarga `kanata` la versión para Windows

2. **Crear directorio de Kanata**

   ```powershell
   # Crear directorio en Program Files
   New-Item -Path "C:\Program Files\Kanata" -ItemType Directory -Force

   # Mover kanata.exe al directorio
   Move-Item kanata_wintercept.exe "C:\Program Files\Kanata\kanata.exe"
   ```

---

### Paso 3: Descargar HybridCapslock

#### Opción A: Usando Git (Recomendado)

```bash
cd C:\Users\TuUsuario\Documents
git clone https://github.com/yourusername/HybridCapslock.git
cd HybridCapslock
```

#### Opción B: Descarga Manual

1. Ve al [repositorio de GitHub](https://github.com/yourusername/HybridCapslock)
2. Haz clic en "Code" → "Download ZIP"
3. Extrae a la ubicación deseada (ej: `C:\Users\TuUsuario\Documents\HybridCapslock`)

---

### Paso 4: Configurar Ruta de Kanata

Edita `config/settings.ahk` para apuntar a tu instalación de Kanata:

```ahk
; Ruta al ejecutable de Kanata
global KanataPath := "C:\Program Files\Kanata\kanata.exe"

; Ruta al config de Kanata
global KanataConfigPath := A_ScriptDir . "\config\../../../config/kanata.kbd"
```

**Nota**: Si instalaste Kanata en una ubicación diferente, actualiza `KanataPath` en consecuencia.

---

### Paso 5: Primer Lanzamiento

1. **Navegar al directorio de HybridCapslock**

   ```powershell
   cd C:\Users\TuUsuario\Documents\HybridCapslock
   ```

2. **Lanzar HybridCapslock**
   - Haz doble clic en `HybridCapslock.ahk`
   - O vía línea de comandos: `autohotkey HybridCapslock.ahk`

3. **Verificar que está funcionando**
   - Revisa la bandeja del sistema para el ícono de HybridCapslock
   - Kanata debería iniciarse automáticamente en segundo plano
   - Prueba homerow mods: Mantén `a` (debería actuar como Ctrl)

---

## Pruebas de Verificación

### Prueba 1: Homerow Mods

Abre el Bloc de notas y prueba:

1. **Mantén `a`** → Debería actuar como Ctrl (prueba Ctrl+A para seleccionar todo)
2. **Mantén `s`** → Debería actuar como Alt (prueba Alt+Tab)
3. **Mantén `d`** → Debería actuar como Win (prueba Win+E para abrir Explorador)
4. **Mantén `f`** → Debería actuar como Shift (prueba Shift+Flecha para seleccionar texto)

Si puedes **tocar** estas teclas para escribir normalmente pero actúan como modificadores al **mantenerlas**, ¡está funcionando! ✅

### Prueba 2: Capa Nvim

1. **Toca BloqMayús** → Debería mostrar tooltip "Capa NVIM Activa"
2. Presiona `h/j/k/l` → Debería mover el cursor (izquierda/abajo/arriba/derecha)
3. **Toca Escape** → La capa se desactiva, el tooltip desaparece

### Prueba 3: Modo Líder

1. Mantén **BloqMayús + Espacio** → Debería mostrar el menú líder
2. Prueba algunos atajos (varía según la configuración)

Si todas las pruebas pasan, ¡la instalación está completa! 🎉

---

## Opcional: Iniciar con Windows

### Método 1: Carpeta de Inicio (Recomendado)

1. **Crear acceso directo**
   - Haz clic derecho en `HybridCapslock.ahk`
   - Selecciona "Crear acceso directo"

2. **Mover a carpeta de Inicio**

   ```powershell
   # Abrir carpeta de Inicio
   explorer shell:startup

   # Mover el acceso directo ahí
   ```

### Método 2: Programador de Tareas (Avanzado)

1. Abrir Programador de Tareas
2. Crear Tarea Básica
3. Nombre: "HybridCapslock"
4. Desencadenador: "Al iniciar sesión"
5. Acción: "Iniciar un programa"
6. Programa: `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`
7. Argumentos: `"C:\Users\TuUsuario\Documents\HybridCapslock\HybridCapslock.ahk"`
8. Marcar "Ejecutar con privilegios más altos"

---

## Solución de Problemas

### Problema: AutoHotkey v2 no encontrado

**Síntomas**: Error "Se requiere AutoHotkey v2"

**Soluciones**:

1. Verifica que instalaste **v2.0+** (no v1.1)
2. Revisa la ruta de instalación: `C:\Program Files\AutoHotkey\v2\`
3. Reinstala AutoHotkey v2
4. Agrega AutoHotkey a la variable de entorno PATH

---

### Problema: Las teclas no funcionan

**Síntomas**: Los homerow mods no se activan, las capas no funcionan

**Soluciones**:

1. Verifica que tanto HybridCapslock como Kanata estén ejecutándose
2. Verifica que `KanataPath` en `config/settings.ahk` sea correcto
3. Prueba Kanata solo: `kanata.exe --cfg config\../../../config/kanata.kbd`
4. Busca software de teclado conflictivo (ej: otros scripts AHK)
5. Intenta recargar: `Ctrl+Alt+R`

---

### Problema: Alto uso de CPU

**Síntomas**: AutoHotkey o Kanata consumiendo CPU excesivo

**Soluciones**:

1. Deshabilita el modo debug en `config/settings.ahk`:

   ```ahk
   global DEBUG_MODE := false
   ```

2. Deshabilita tooltips temporalmente:

   ```ahk
   global EnableTooltips := false
   ```

3. Busca bucles infinitos en capas personalizadas
4. Actualiza a la última versión

---

### Problema: Antivirus bloqueando

**Síntomas**: Windows Defender o antivirus bloquea Kanata

**Soluciones**:

1. Agrega Kanata a las exclusiones del antivirus:
   - Seguridad de Windows → Protección contra virus y amenazas → Exclusiones
   - Agregar `C:\Program Files\Kanata\kanata.exe`
2. Descarga Kanata solo desde los releases oficiales de GitHub
3. Verifica la firma del archivo (si está disponible)

---

## Desinstalación

### Remover HybridCapslock

1. Detén HybridCapslock (clic derecho en ícono de bandeja → Salir)
2. Elimina la carpeta de HybridCapslock
3. Elimina el acceso directo de inicio (si se creó)

### Remover Kanata

1. Detén Kanata
2. Elimina la carpeta de Kanata

### Remover AutoHotkey

1. Usa "Agregar o quitar programas" de Windows
2. Encuentra "AutoHotkey v2"
3. Haz clic en "Desinstalar"

---

## Próximos Pasos

Después de una instalación exitosa:

1. **[Guía de Inicio Rápido](../primeros-pasos/inicio-rapido.md)** - Aprende atajos esenciales
2. **[Guía de Configuración](configuracion.md)** - Personaliza según tus necesidades
3. **[Guía de Homerow Mods](../guia-usuario/homerow-mods.md)** - Domina las teclas modificadoras
4. **[Crear Capas](../guia-desarrollador/crear-capas.md)** - Construye capas personalizadas

---

## Requisitos del Sistema

### Mínimo

- Windows 10 (1903 o posterior)
- 2 GB RAM
- 100 MB de espacio libre en disco

### Recomendado

- Windows 11
- 4 GB RAM
- SSD para mejor rendimiento

### Teclados Soportados

- Teclados QWERTY estándar
- Layouts ISO/ANSI
- Teclados de laptop
- Teclados externos
- **No probado**: Layouts no-QWERTY (Dvorak, Colemak, etc.)

---

**¿Necesitas ayuda?** Revisa la [Sección de Solución de Problemas](../referencia/sistema-debug.md) o la [Guía de Inicio Rápido](../primeros-pasos/inicio-rapido.md).

**[🌍 View in English](../../en/getting-started/installation.md)** | **[← Volver al Índice](../README.md)**
