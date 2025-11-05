# 🔷 HybridCapsLock Tooltip App

Aplicación C# + WPF para mostrar tooltips estilo Nvim que reemplaza la implementación fallida de Rust.

## 🚀 Estado Actual

### ✅ Fase 1 Completada: Tooltip Básico Estático
- Ventana posicionada centro-inferior
- Colores especificados aplicados
- Click-through habilitado
- Always-on-top configurado
- Layout básico con 4 columnas

### 🔄 Próximas Fases
- **Fase 2:** Comunicación JSON completa
- **Fase 3:** Layout dinámico avanzado
- **Fase 4:** Estados de capas (posterior)

## 🔧 Comandos de Desarrollo

### Compilar (Self-Contained):
```bash
cd tooltip_csharp
dotnet publish -c Release --self-contained true -r win-x64 --single-file
```

### Ejecutar (Desarrollo):
```bash
dotnet run
```

### Ejecutar (Producción):
```bash
# Después de compilar, ejecutar el .exe generado:
.\bin\Release\net6.0-windows\win-x64\publish\TooltipApp.exe
```

## 📄 Esquema JSON (Contrato)

La app C# lee `tooltip_commands.json` en el mismo directorio de ejecución (A_ScriptDir en AHK).

Ejemplo completo v2 (personalizable):
```json
{
  "show": true,
  "tooltip_type": "leader",         
  "layout": "grid",                 
  "columns": 3,                      
  "title": "COMMAND PALETTE",
  "items": [
    {"key": "w", "description": "Windows"},
    {"key": "p", "description": "Programs"}
  ],
  "navigation": ["\\: Back", "ESC: Exit"],
  "timeout_ms": 5000,
  "style": {
    "background": "#101014",
    "text": "#f0f0f0",
    "border": "#2a2a2a",
    "accent_options": "#e6d27a",
    "accent_navigation": "#5fb3b3",
    "border_thickness": 1,
    "corner_radius": 6,
    "padding": [16, 12, 16, 12],
    "title_font_size": 14,
    "item_font_size": 12,
    "navigation_font_size": 10,
    "max_width": 900,
    "max_height": 700
  },
  "position": {
    "anchor": "bottom_center",
    "offset_x": 0,
    "offset_y": -10
  },
  "topmost": true,
  "click_through": true,
  "opacity": 0.98
}
```
Notas:
- `layout`: `grid` o `list`. Si es grid, `columns` define columnas.
- `tooltip_type` se mantiene para compatibilidad: `leader`, `status_persistent`, `sidebar_right`, `bottom_right_list`. `layout` tiene prioridad.
- `position.anchor`: `bottom_center` (default), `bottom_right`, `bottom_left`, `top_center`, `top_left`, `top_right`, `center`, `manual`.
- `position.offset_x/offset_y`: offsets adicionales. Con `manual` se usan `x`/`y` absolutos.
- `style` permite personalizar colores, tamaños, padding y límites de tamaño. Cualquier campo omitido usa valores por defecto.
- Timeout 0 hace que el tooltip permanezca visible hasta recibir `show=false`.
- La ventana se reposiciona automáticamente cuando cambia su tamaño.
- Escritura recomendada desde AHK: atómica (archivo .tmp + move) y con throttle para evitar parpadeos.

## 📋 Testing

### Fase 1 - Tooltip Básico:
1. Ejecutar aplicación
2. Verificar posición centro-inferior
3. Verificar colores (#dbd6b9 dorado, #6c958e verde, #1e1e1e fondo)
4. Verificar click-through (clicks pasan a través)
5. Verificar always-on-top

### Fase 2 - Comunicación JSON:
1. Crear archivo `tooltip_commands.json` con:
```json
{
  "show": true,
  "title": "TEST DYNAMIC",
  "items": [
    {"key": "w", "description": "Windows"},
    {"key": "p", "description": "Programs"}
  ],
  "navigation": ["ESC: Exit", "ENTER: Select"],
  "timeout_ms": 5000
}
```
2. Verificar que el tooltip se actualiza automáticamente

## 🎨 Especificaciones de Diseño

- **Posición:** Centro horizontal, 50px desde abajo
- **Colores:**
  - Opciones: `#dbd6b9` (dorado)
  - Navegación: `#6c958e` (verde)
  - Fondo: `#1e1e1e` (oscuro)
  - Texto: `#ffffff` (blanco)
  - Borde: `#404040` (gris)

## 🔗 Integración con AutoHotkey

La aplicación lee comandos desde `tooltip_commands.json` para mostrar/ocultar tooltips dinámicamente. El archivo debe ubicarse en el mismo directorio donde se ejecuta el script AHK (`A_ScriptDir`).

Ejemplo de integración en HybridCapsLock.ahk (v2):
```autohotkey
; Al inicio del script principal
#Include tooltip_csharp_integration.ahk

; Al arrancar
StartTooltipApp()
StartStatusApp() ; inicia los 4 PS1 de estado (nvim/visual/yank/excel)

; Mostrar un menú con C#
ShowLeaderModeMenuCS()

; Ocultar tooltip manualmente (si es necesario)
HideCSharpTooltip()
```

Ejemplo de integración en HybridCapsLock.ahk:
```autohotkey
ShowCSharpTooltip(title, items, navigation := "", timeout := 7000) {
    ; Crear JSON y escribir a archivo
    ; La aplicación C# detectará el cambio automáticamente
}
```