# Modo Líder

> Referencia rápida
>
> - Configuración general: ver doc/configuration.md (secciones [Behavior], [Layers], [Tooltips])
> - Configuración por capa: / / / INFORMATION_LAYER.md / excel-layer.md /

El Modo Líder es un sistema de menús contextuales que organiza funciones avanzadas en sub-capas especializadas. Proporciona acceso rápido a herramientas de gestión de ventanas, lanzamiento de programas y utilidades de timestamp.

## 🎯 Activación

**Atajo por defecto:** `Hold CapsLock + Space`

> **Cómo funciona:**
>
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

h - Hybrid Management
p - Programs
t - Time
i - Information

[Esc: Exit]
```

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
- Feedback visual: “SUSPENDED Xm — press Leader to resume” y “RESUMED/RESUMED (auto)”.

### 📱 Feedback Visual

- Cada sub-capa muestra su propio menú contextual
- Tooltips centrados en pantalla para mejor visibilidad
- Indicadores de estado para acciones persistentes

## 🔧 Personalización

1. **Crear función de menú:**

   ```autohotkey
   ShowNuevoMenu() {
       ; Definir el menú visual
   }
   ```

2. **Actualizar menú principal:**

   ```autohotkey
   ShowLeaderMenu() {
       MenuText .= "nueva_tecla - Nueva Función`n"
   }
   ```

## 📊 Estadísticas de Uso

El modo líder está optimizado para:

- **Acceso rápido:** Máximo 2 teclas para cualquier función
- **Memoria muscular:** Teclas mnemotécnicas (h=Hybrid Management, p= Programs, i=information)
- **Eficiencia:** Timeout automático para evitar bloqueos
- **Flexibilidad:** Sistema modular fácil de extender con plugins

## ⚠️ Consideraciones

- **Aplicaciones en pantalla completa:** Algunos tooltips pueden no ser visibles
- **Rendimiento:** Los timeouts previenen el uso excesivo de memoria
- **Compatibilidad:** Funciona mejor con AutoHotkey v2

