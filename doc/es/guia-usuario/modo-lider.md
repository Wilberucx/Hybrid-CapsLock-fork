# Modo Líder

> Referencia rápida
> - Configuración general: ver doc/configuration.md (secciones [Behavior], [Layers], [Tooltips])
> - Configuración por capa:  /  /  / INFORMATION_LAYER.md / excel-layer.md / 

El Modo Líder es un sistema de menús contextuales que organiza funciones avanzadas en sub-capas especializadas. Proporciona acceso rápido a herramientas de gestión de ventanas, lanzamiento de programas y utilidades de timestamp.

## 🎯 Activación

**Atajo por defecto:** `Hold CapsLock + Space`

> **Cómo funciona:**
> 1. Mantén presionado `CapsLock` físicamente
> 2. Mientras lo mantienes, presiona `Space`
> 3. Se abrirá el menú de Leader

**Personalización del atajo:** El atajo es configurable editando `../../../config/kanata.kbd`. Por defecto, cuando mantienes CapsLock, se activa la capa `vim-nav` donde `Space` envía `F24` (que AutoHotkey detecta como Leader). Puedes cambiar esto a cualquier otra tecla:

```lisp
;; En ../../../config/kanata.kbd, busca la capa vim-nav:
(deflayer vim-nav
  _    f13  _    _   end   _    _    _    _    _   home  _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _    _    _    _    left down up   rght _    _    _
  _    _    _    _    _    _    _    _    _    _    _    _
  _    _    _             f24             _    _    _
                           ↑
                    Space envía F24 (Leader)
)

;; Ejemplo: Cambiar Leader a "Hold CapsLock + L"
;; Reemplaza: _    _    _    _    _    _    left down up   rght _    _    _
;; Por:       _    _    _    _    _    _    left down up   f24  _    _    _
;;                                                          ↑
;;                                                    L ahora es Leader
```

Después de editar, recarga el sistema: **Leader → c → h → R** (Reload completo) o **Leader → c → h → k** (Restart Kanata solamente).

Al activar el modo líder, aparece un menú visual que muestra las opciones disponibles.

## 📋 Menú Principal

```
LEADER MENU

(Windows fue integrado en System)
p - Programs  
t - Time
c - Commands
i - Information
n - Excel

[Esc: Exit]
```

## 🌟 Sub-Capas Disponibles

### 🪟 [Capa Windows]() - Tecla `w`
Gestión avanzada de ventanas y herramientas de zoom.

**Funciones principales:**
- División de pantalla (splits 50/50, 33/67, cuadrantes)
- Acciones de ventana (cerrar, maximizar, minimizar)
- Herramientas de zoom (Draw, Zoom, Zoom with cursor)
- Cambio de ventanas persistente (blind/visual switch)

### 🚀 [Capa Programas]() - Tecla `p`
Lanzador rápido de aplicaciones comunes.

**Aplicaciones disponibles:**
- Explorador, Terminal, Visual Studio/Code
- Navegadores, Notepad
- Bitwarden, Configuración de Windows
- Y más...

### ⏰ [Capa Timestamp]() - Tecla `t`
Herramientas para insertar y formatear fechas/horas.

**Funciones principales:**
- Inserción de fecha, hora o datetime
- Cambio de formatos de fecha y hora
- Configuración de separadores
- Formatos persistentes entre sesiones

### ⚡ [Capa Comandos]() - Tecla `c`
Paleta de comandos jerárquica para ejecutar scripts y herramientas del sistema.

**Funciones principales:**
- Comandos del sistema (Task Manager, Services, etc.)
- Herramientas de red (IP Config, Ping, etc.)
- Comandos Git integrados
- Monitoreo del sistema
- Acceso rápido a carpetas
- Toggle de archivos ocultos

### 📝 Capa Information - Tecla `i`
Inserción rápida de información personal y snippets configurables desde archivo .ini.

**Funciones principales:**
- Información personal (email, nombre, teléfono, dirección)
- Datos de empresa y redes sociales
- Snippets personalizados y plantillas
- Configuración fácil desde information.ini

### 📊 [Capa Excel](capa-excel.md) - Tecla `n`
Capa persistente especializada para trabajo con hojas de cálculo y aplicaciones contables.

**Funciones principales:**
- Numpad completo con distribución ergonómica (7-8-9, u-i-o, j-k-l)
- Navegación con flechas (WASD) y Tab/Shift+Tab
- Atajos específicos de Excel (Ctrl+Enter, F2, Ctrl+F, etc.)
- Operaciones matemáticas y símbolos del numpad
- Modo persistente optimizado para trabajo continuo

## 🎮 Navegación

### Controles Universales
- Esc: salir completamente del modo líder (EXIT total)
- Backspace: volver al menú anterior (back inteligente con breadcrumb)
- Backslash (\): reservado como back, pero no es confiable en todos los contextos; se estandariza Backspace
- Timeout: 7 segundos de inactividad cierra automáticamente

### Flujo de Navegación

Nota sobre navegación y back inteligente
- Se implementó un breadcrumb (pila de navegación) cuando los tooltips C# están habilitados, y un bucle interno en AHK cuando no lo están, para garantizar que Backspace siempre regrese exactamente al menú anterior, no drásticamente al Leader.
- Backspace es la tecla estándar de retroceso. Backslash (\) se intentó como alternativa, pero puede quedar capturado como entrada normal en ciertos submenús; por ergonomía y consistencia (estilo Vim/Neovim), se privilegia Backspace.

```
leader → Menú Principal
                ↓
        Seleccionar sub-capa (w/p/t)
                ↓
        Ejecutar acción específica
                ↓
        Salir automáticamente O volver con Backspace
```

## 💡 Características Especiales

### ⏸️ Pausa Híbrida y Reanudación con Leader
- Si el script está suspendido (pausa híbrida desde `Commands → Hybrid Management → p`), al presionar `CapsLock+Space` (Leader) se reanuda inmediatamente y continúa el flujo normal del Leader.
- La pausa híbrida arma un auto-resume tras `hybrid_pause_minutes` (configurable en `config/configuration.ini`, por defecto 10).
- Opcionalmente existe un hotkey de emergencia `Ctrl+Alt+Win+R` (configurable) que reanuda el script incluso si el Leader estuviera deshabilitado.
- Feedback visual: “SUSPENDED Xm — press Leader to resume” y “RESUMED/RESUMED (auto)”.


### 🔄 Integración con Capa Nvim
- Si la Capa Nvim está activa al llamar al líder, se desactiva automáticamente
- Esto evita conflictos entre modos y proporciona una transición limpia

### 📱 Feedback Visual
- Cada sub-capa muestra su propio menú contextual
- Tooltips centrados en pantalla para mejor visibilidad
- Indicadores de estado para acciones persistentes

### ⚡ Modos Persistentes
Algunas funciones (como el cambio de ventanas) mantienen el modo activo para operaciones continuas:
- **Blind Switch** - Navegación rápida sin vista previa
- **Visual Switch** - Navegación con vista previa estilo Alt+Tab

## 🔧 Personalización

### Añadir Nueva Sub-Capa

1. **Editar el Input principal:**
   ```autohotkey
   ih := InputHook("L1 T7", "{Escape}") ; Añadir nueva tecla aquí
ih.Start()
ih.Wait()
_leaderKey := ih.Input
   ```

2. **Añadir nuevo bloque condicional:**
   ```autohotkey
   if (_leaderKey = "nueva_tecla") {
       ShowNuevoMenu()
       ih := InputHook("L1 T7", "{Escape}{Backspace}")
ih.Start()
ih.Wait()
_nuevaAccion := ih.Input
       ; Lógica de la nueva sub-capa
   }
   ```

3. **Crear función de menú:**
   ```autohotkey
   ShowNuevoMenu() {
       ; Definir el menú visual
   }
   ```

4. **Actualizar menú principal:**
   ```autohotkey
   ShowLeaderMenu() {
       MenuText .= "nueva_tecla - Nueva Función`n"
   }
   ```

## 📊 Estadísticas de Uso

El modo líder está optimizado para:
- **Acceso rápido:** Máximo 2 teclas para cualquier función
- **Memoria muscular:** Teclas mnemotécnicas (w=windows, p=programs, t=time)
- **Eficiencia:** Timeout automático para evitar bloqueos
- **Flexibilidad:** Sistema modular fácil de extender

## ⚠️ Consideraciones

- **Conflictos de teclas:** El líder desactiva automáticamente la Capa Nvim
- **Aplicaciones en pantalla completa:** Algunos tooltips pueden no ser visibles
- **Rendimiento:** Los timeouts previenen el uso excesivo de memoria
- **Compatibilidad:** Funciona mejor con AutoHotkey v1.1+