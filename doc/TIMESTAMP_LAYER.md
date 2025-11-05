# Capa Timestamp (Líder: leader → `t`)

> Referencia rápida
> - Configuración: config/timestamps.ini
> - Confirmaciones: ver “Confirmaciones — Modelo de Configuración” en doc/CONFIGURATION.md y la sección específica en este documento
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

Esta capa proporciona un sistema avanzado de 3 niveles para insertar fechas, horas y timestamps con formatos completamente configurables.

## 🎯 Cómo Acceder

1. **Activa el Líder:** Presiona `leader`
2. **Entra en Capa Timestamp:** Presiona `t`
3. **Selecciona tipo:** `d` (fecha), `t` (hora), `h` (fecha+hora)
4. **Selecciona formato:** Número específico o letra para default

## ⏰ Inserción de Timestamps

| Tecla | Acción | Ejemplo de Salida |
|-------|--------|-------------------|
| `d` | **Fecha** | `2024-01-15` |
| `t` | **Hora** | `14:30:25` |
| `h` | **DateTime** | `2024-01-15 14:30:25` |

> **Nota:** Los formatos exactos dependen de la configuración actual (ver sección de formatos)

## 🔧 Configuración de Formatos

### Formatos de Fecha
| Tecla | Acción | Formatos Disponibles |
|-------|--------|---------------------|
| `D` | **Cambiar formato de fecha** | `yyyy-MM-dd` → `dd/MM/yyyy` → `yyyyMMdd` → `ddd, dd MMM yyyy` |

**Ejemplos:**
- `yyyy-MM-dd` → `2024-01-15`
- `dd/MM/yyyy` → `15/01/2024`
- `yyyyMMdd` → `20240115`
- `ddd, dd MMM yyyy` → `Mon, 15 Jan 2024`

### Formatos de Hora
| Tecla | Acción | Formatos Disponibles |
|-------|--------|---------------------|
| `H` | **Cambiar formato de hora** | `HH:mm:ss` → `HH:mm` → `HHmmss` |

**Ejemplos:**
- `HH:mm:ss` → `14:30:25`
- `HH:mm` → `14:30`
- `HHmmss` → `143025`

### Separador DateTime
| Tecla | Acción | Opciones |
|-------|--------|----------|
| `S` | **Cambiar separador** | Espacio (` `) ↔ Sin separador (``) |

**Ejemplos:**
- Con espacio: `2024-01-15 14:30:25`
- Sin separador: `2024-01-1514:30:25`

## 💾 Persistencia de Configuración

Todas las configuraciones se guardan automáticamente en `HybridCapsLock.ini` y se mantienen entre sesiones:

```ini
[Timestamp]
DateFmtIdx=1
TimeFmtIdx=1
Separator= 
```

## 🎮 Navegación en el Menú

- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú líder principal
- **Timeout:** 7 segundos de inactividad cierra automáticamente

## ⚙️ Confirmaciones en Timestamps

### Precedencia de Confirmación (Timestamps)

Orden (mayor a menor):
1) Global: `configuration.ini` → `[Behavior]` → `show_confirmation_global`
2) Categoría: `timestamps.ini` → `[CategorySettings]` `<Friendly>_show_confirmation`
3) Per-command (listas): `timestamps.ini` → `[Confirmations.<Friendly>]` → `confirm_keys` / `no_confirm_keys`
4) Default de capa: `timestamps.ini` → `[Settings]` → `show_confirmation`
5) Fallback: `false`

Ejemplos:
```ini
; Confirmar todo DateTime
[CategorySettings]
DateTime_show_confirmation=true

; Confirmar valores individuales en Date
[Confirmations.Date]
confirm_keys=1 2 3
```

## 📝 Timestamp en Capa Nvim

La Capa Nvim también incluye funciones de timestamp independientes:

| Tecla | Acción | Descripción |
|-------|--------|-------------|
| `,` | **Escribir timestamp** | Usa el formato actual de la capa Nvim |
| `.` | **Cambiar formato** | Cicla entre formatos predefinidos |

### Formatos de Capa Nvim
1. `yyyy-MM-dd HH:mm:ss`
2. `dd/MM/yyyy HH:mm`
3. `yyyyMMdd_HHmmss`
4. `HH:mm:ss`
5. `yyyy-MM-dd`
6. `yyyy-MM-ddTHH:mm:ssZ` (ISO 8601)

## 💡 Casos de Uso Comunes

### 📊 Documentación y Logs
```
# Reunión del 2024-01-15
Inicio: 14:30:25
...
```

### 📁 Nombres de Archivos
```
backup_20240115_143025.zip
reporte_2024-01-15.pdf
```

### 📧 Comunicaciones
```
Estimado cliente,
Como acordamos en nuestra reunión del lun, 15 ene 2024...
```

### 🔬 Desarrollo y Testing
```
// Test ejecutado: 2024-01-15T14:30:25Z
console.log("Timestamp:", "20240115143025");
```

## 🔧 Personalización

### Añadir Nuevos Formatos

1. **Editar arrays de formatos:**
   ```autohotkey
   global DateFormats := ["yyyy-MM-dd", "dd/MM/yyyy", "nuevo-formato"]
   global TimeFormats := ["HH:mm:ss", "HH:mm", "nuevo-formato"]
   ```

2. **Para Capa Nvim:**
   ```autohotkey
   global TSFormats := ["formato1", "formato2", "nuevo-formato"]
   ```

### Añadir Nuevas Acciones

1. **Añadir tecla al Input:**
   ```autohotkey
   ih := InputHook("L1 T7", "{Escape}{Backspace}")
ih.Start()
ih.Wait()
_tsKey := ih.Input
   ```

2. **Añadir Case al Switch:**
   ```autohotkey
   Case "nueva_tecla":
       ; Nueva funcionalidad
   ```

## ⚠️ Consideraciones Técnicas

- **Formato AutoHotkey:** Usa la sintaxis de `FormatTime` de AutoHotkey
- **Localización:** Los formatos de fecha respetan la configuración regional del sistema
- **Rendimiento:** Los timestamps se generan en tiempo real
- **Compatibilidad:** Funciona en cualquier aplicación que acepte entrada de texto

## 🌍 Formatos Internacionales

El sistema soporta formatos comunes internacionales:

- **ISO 8601:** `yyyy-MM-ddTHH:mm:ssZ`
- **Europeo:** `dd/MM/yyyy HH:mm`
- **Americano:** `MM/dd/yyyy HH:mm`
- **Compacto:** `yyyyMMdd_HHmmss`
- **Legible:** `ddd, dd MMM yyyy`

> **Tip:** Usa `D` y `H` repetidamente para encontrar el formato que mejor se adapte a tu flujo de trabajo.