# 🔄 Guía de Migración: Information.ini → SendInfo()

## 🎯 Objetivo
Migrar del sistema antiguo `information.ini` al nuevo sistema moderno usando `SendInfo()` con closures.

---

## ❌ Sistema ANTIGUO (Deprecado)

### Configuración en information.ini (3+ líneas por item):
```ini
[PersonalInfo]
Email=john@example.com
Name=John Doe
Phone=+1-555-1234

[InfoMapping]
order=e n p
e=Email
n=Name
p=Phone
```

**Problemas:**
- ❌ Tedioso (3+ líneas por item)
- ❌ Múltiples secciones
- ❌ Layer no refactorizado
- ❌ Sistema de mini-layers anticuado

---

## ✅ Sistema NUEVO (Moderno)

### Configuración en keymap.ahk (1 línea por item):
```autohotkey
RegisterKeymap("leader", "i", "e", "Email", SendInfo("john@example.com", "EMAIL"), false, 1)
RegisterKeymap("leader", "i", "n", "Name", SendInfo("John Doe", "NAME"), false, 2)
RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-1234", "PHONE"), false, 3)
```

**Ventajas:**
- ✅ UNA línea por item (como ShellExec)
- ✅ Todo en un solo lugar
- ✅ Sistema moderno con closures
- ✅ Integrado con registry jerárquico
- ✅ Flexible - puede incluir lógica

---

## 🔄 Proceso de Migración

### Paso 1: Convertir información a keymap.ahk

**ANTES:**
```ini
[PersonalInfo]
Email=john@example.com
EmailWork=john.work@company.com
Phone=+1-555-1234
Address=123 Main St, City
```

**DESPUÉS:**
```autohotkey
; En config/keymap.ahk
RegisterKeymap("leader", "i", "e", "Email", SendInfo("john@example.com", "EMAIL"), false, 1)
RegisterKeymap("leader", "i", "w", "Work Email", SendInfo("john.work@company.com", "WORK EMAIL"), false, 2)
RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-1234", "PHONE"), false, 3)
RegisterKeymap("leader", "i", "a", "Address", SendInfo("123 Main St, City", "ADDRESS"), false, 4)
```

### Paso 2: Texto multilínea

Para firmas o texto con saltos de línea:

```autohotkey
RegisterKeymap("leader", "i", "s", "Signature", 
    SendInfoMultiline([
        "Saludos cordiales,",
        "Tu Nombre",
        "Tu Cargo"
    ], "SIGNATURE"), 
    false, 5)
```

### Paso 3: Recargar script

```
Ctrl+Alt+R o reiniciar AutoHotkey
```

### Paso 4: Probar

```
Leader → i → e  (inserta email)
Leader → i → p  (inserta teléfono)
Leader → i → s  (inserta firma)
```

### Paso 5: Archivar archivos antiguos (opcional)

```bash
# Renombrar archivos antiguos
mv src/layer/information_layer.ahk src/layer/information_layer.ahk.deprecated
mv config/information.ini config/information.ini.deprecated
```

---

## 📊 Tabla de Conversión

| information.ini | keymap.ahk con SendInfo() |
|-----------------|---------------------------|
| 3+ líneas por item | 1 línea por item |
| [PersonalInfo] Email=... | SendInfo("...", "EMAIL") |
| [InfoMapping] e=Email | Tecla "e" directamente |
| order=e n p a | Orden automático (1, 2, 3...) |

---

## 🚀 Funciones Disponibles

### 1. SendInfo() - Básico
```autohotkey
SendInfo(text, tooltipMsg := "TEXT INSERTED", tooltipDuration := 1500)

// Ejemplos:
SendInfo("john@example.com", "EMAIL")
SendInfo("+1-555-1234")  // Tooltip por defecto
SendInfo("Texto", "MENSAJE", 3000)  // Tooltip 3 segundos
```

### 2. SendInfoMultiline() - Multilínea
```autohotkey
SendInfoMultiline(lines, tooltipMsg := "TEXT INSERTED")

// Ejemplo:
SendInfoMultiline(["Línea 1", "Línea 2", "Línea 3"], "MENSAJE")
```

### 3. SendInfoWithDelay() - Con delay
```autohotkey
SendInfoWithDelay(text, delayMs := 50, tooltipMsg := "TEXT INSERTED")

// Ejemplo (para formularios que validan en tiempo real):
SendInfoWithDelay("texto@email.com", 100, "EMAIL")
```

---

## 💡 Comparación Lado a Lado

### Insertar Email

**Sistema Antiguo (information.ini):**
```ini
; Línea 1: Definir información
[PersonalInfo]
Email=john@example.com

; Línea 2: Mapear tecla
[InfoMapping]
e=Email

; Línea 3: Definir orden
order=e n p a
```

**Sistema Nuevo (keymap.ahk):**
```autohotkey
RegisterKeymap("leader", "i", "e", "Email", SendInfo("john@example.com", "EMAIL"), false, 1)
```

**Resultado:** De 3+ líneas → 1 línea

---

## 🎯 Ejemplo Completo

```autohotkey
; En config/keymap.ahk - Sección Information

; Información Personal
RegisterKeymap("leader", "i", "e", "Email", SendInfo("tu.email@example.com", "EMAIL"), false, 1)
RegisterKeymap("leader", "i", "w", "Work Email", SendInfo("work@company.com", "WORK EMAIL"), false, 2)
RegisterKeymap("leader", "i", "p", "Phone", SendInfo("+1-555-123-4567", "PHONE"), false, 3)
RegisterKeymap("leader", "i", "m", "Mobile", SendInfo("+1-555-987-6543", "MOBILE"), false, 4)
RegisterKeymap("leader", "i", "n", "Name", SendInfo("Tu Nombre Completo", "NAME"), false, 5)
RegisterKeymap("leader", "i", "a", "Address", SendInfo("123 Main St, City, State 12345", "ADDRESS"), false, 6)

; URLs y Social
RegisterKeymap("leader", "i", "u", "Website", SendInfo("https://tu-sitio.com", "WEBSITE"), false, 7)
RegisterKeymap("leader", "i", "g", "GitHub", SendInfo("https://github.com/tu-usuario", "GITHUB"), false, 8)

; Saludos Comunes
RegisterKeymap("leader", "i", "h", "Hola", SendInfo("Hola, cómo estás?", "TEXT"), false, 9)
RegisterKeymap("leader", "i", "t", "Thanks", SendInfo("Muchas gracias por tu ayuda!", "TEXT"), false, 10)

; Firma
RegisterKeymap("leader", "i", "s", "Signature", 
    SendInfoMultiline([
        "Saludos cordiales,",
        "Tu Nombre",
        "Tu Cargo",
        "Tu Empresa"
    ], "SIGNATURE"), 
    false, 11)
```

---

## ✅ Ventajas del Nuevo Sistema

1. **Más simple:** 1 línea vs 3+ líneas
2. **Más legible:** Todo junto, fácil de ver
3. **Más flexible:** Puede incluir lógica AHK
4. **Más moderno:** Usa closures y registry jerárquico
5. **Más mantenible:** Todo en un solo archivo
6. **Más rápido de editar:** No saltar entre secciones

---

## 🎓 Conceptos

### ¿Qué es SendInfo()?
Es una función que retorna otra función (closure) que captura el texto y tooltip.

```autohotkey
SendInfo("texto", "TOOLTIP")
// Retorna: (*) => { SendText("texto"); ShowTooltip("TOOLTIP"); }
```

### ¿Por qué funciona?
`RegisterKeymap` necesita una **referencia a función**, no texto directo.
`SendInfo()` se ejecuta y retorna una función que será llamada al presionar la tecla.

### Similar a ShellExec
```autohotkey
ShellExec("notepad.exe")    // Retorna función
SendInfo("texto", "MSG")    // Retorna función
```

---

## 📝 Checklist de Migración

- [ ] Identificar toda la información en `information.ini`
- [ ] Convertir cada item a `SendInfo()` en `keymap.ahk`
- [ ] Convertir texto multilínea a `SendInfoMultiline()`
- [ ] Recargar script
- [ ] Probar cada información
- [ ] Archivar `information.ini` y `information_layer.ahk`
- [ ] Actualizar documentación personal si es necesario

---

**Estado:** ✅ Sistema listo para usar
**Fecha:** 2024-11-10
