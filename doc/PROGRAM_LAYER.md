# Capa de Programas (Líder: leader → `p`)

> Referencia rápida
> - Configuración: config/programs.ini
> - Confirmaciones: ver “Confirmaciones — Modelo de Configuración” en doc/CONFIGURATION.md y la sección "Developers — Confirmation configuration (Programs)" en este documento
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

Esta capa proporciona un lanzador rápido de aplicaciones comunes, con búsqueda automática de ejecutables via Windows Registry para mayor compatibilidad.

## 🎯 Cómo Acceder

1. **Activa el Líder:** Presiona `leader`
2. **Entra en Capa Programas:** Presiona `p`
3. **Lanza una aplicación:** Presiona una de las teclas del mapa

## 🎮 Navegación en el Menú

- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú líder principal
- **Timeout:** 7 segundos de inactividad cierra automáticamente

## 🚀 Aplicaciones Disponibles

| Tecla | Aplicación | Ejecutable | Descripción |
|-------|------------|------------|-------------|
| `e` | **Explorador** | `explorer.exe` | Explorador de archivos de Windows |
| `s` | **Configuración** | `ms-settings:` | Configuración de Windows |
| `t` | **Terminal** | `wt.exe` | Windows Terminal |
| `v` | **Visual Studio/Code** | `devenv.exe` / `code.exe` | IDE/Editor de código |
| `n` | **Notepad** | `notepad.exe` | Bloc de notas |
| `b` | **Navegador** | (Predeterminado) | Navegador web por defecto |
| `z` | **Zen Browser** | `zen.exe` | Navegador Zen |
| `m` | **Thunderbird** | `thunderbird.exe` | Cliente de correo |
| `w` | **WezTerm** | `wezterm.exe` | Terminal alternativo |
| `l` | **WSL** | `wsl.exe` | Windows Subsystem for Linux |
| `r` | **Beeper** | `beeper.exe` | Cliente de mensajería |
| `q` | **Quick Share** | `quickshare.exe` | Compartir archivos rápido |
| `p` | **Bitwarden** | `bitwarden.exe` | Gestor de contraseñas |

## 🔧 Sistema de Búsqueda Automática (v6.0)

El script utiliza un sistema avanzado de búsqueda de ejecutables que **no depende del PATH del sistema**:

### 🎯 Métodos de Búsqueda
1. **Windows Registry (App Paths)** - Búsqueda automática en el registro
2. **Ubicaciones estándar** - Carpetas comunes de instalación
3. **PATH del sistema** - Como respaldo final

### ✅ Ventajas del Nuevo Sistema
- **Funciona como administrador** - No hay problemas de permisos
- **Detección automática** - Encuentra programas sin configuración manual
- **Mayor compatibilidad** - Funciona con más instalaciones
- **Sin configuración** - No necesitas modificar variables de entorno

### 🔍 Verificación de Disponibilidad

Para comprobar si una aplicación está disponible:

```cmd
# En terminal/cmd
where nombre_ejecutable
```

**Ejemplos:**
- `where wt` - Windows Terminal
- `where code` - Visual Studio Code

### 📋 Comportamiento Específico

| Aplicación | Búsqueda Primaria | Alternativa | Notas |
|------------|-------------------|-------------|--------|
| **Visual Studio/Code** | `devenv.exe` | `code.exe` | Prioriza Visual Studio |
| **Navegador** | Navegador predeterminado | - | Usa configuración del sistema |
| **Terminal** | `wt.exe` | - | Windows Terminal moderno |

## 🛠️ Personalización

### Añadir Nueva Aplicación

1. **Editar el Input:**
   ```autohotkey
   ih := InputHook("L1 T7", "{Escape}{Backspace}")
ih.Start()
ih.Wait()
_appKey := ih.Input
   ```

2. **Añadir Case al Switch:**
   ```autohotkey
   Case "nueva_tecla": LaunchNuevaApp()
   ```

3. **Crear función de lanzamiento:**
   ```autohotkey
   LaunchNuevaApp() {
       Run("nueva_aplicacion.exe")
   }
   ```

4. **Actualizar menú visual:**
   ```autohotkey
   ShowProgramMenu() {
       MenuText .= "nueva_tecla - Nueva App`n"
   }
   ```

### Modificar Aplicación Existente

Busca la función correspondiente (ej: `LaunchTerminal()`) y modifica el comando:

```autohotkey
LaunchTerminal() {
    Run("tu_terminal_preferido.exe")
}
```

## 💡 Consejos de Uso

### 🚀 Flujo Rápido
```
leader → p → t (Terminal en 3 teclas)
leader → p → v (VS Code en 3 teclas)
```

### 🎯 Aplicaciones Frecuentes
- **Desarrollo:** `t` (Terminal), `v` (VS Code), `l` (WSL)
- **Productividad:** `n` (Notepad), `e` (Explorador)
- **Comunicación:** `m` (Thunderbird), `r` (Beeper), `b` (Navegador)

### ⚡ Memoria Muscular
Las teclas siguen patrones mnemotécnicos:
- `t` = **T**erminal
- `v` = **V**isual Studio
- `o` = **O**bsidian
- `b` = **B**rowser

## ⚠️ Solución de Problemas

### Aplicación No Se Abre
1. **Verificar instalación:** `where nombre_ejecutable`
2. **Comprobar permisos:** Ejecutar script como administrador
3. **Revisar logs:** Buscar errores en la consola de AutoHotkey

### Aplicación Incorrecta Se Abre
1. **Múltiples versiones:** El script puede encontrar una versión diferente
2. **Personalizar función:** Modifica la función específica con la ruta exacta

### Rendimiento Lento
1. **Primera ejecución:** La búsqueda en registry puede tardar unos segundos
2. **Caché automático:** Las siguientes ejecuciones son más rápidas

## 🔄 Migración desde Versiones Anteriores

Si vienes de una versión anterior que dependía del PATH:

1. **No necesitas configurar PATH** - El nuevo sistema es automático
2. **Funciona como administrador** - Ya no hay problemas de permisos
3. **Mismas teclas** - La interfaz no ha cambiado
4. **Mejor detección** - Encuentra más aplicaciones automáticamente
