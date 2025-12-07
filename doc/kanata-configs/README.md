# Configuraciones de Kanata

Este directorio contiene múltiples archivos de configuración de Kanata para diferentes necesidades.

## 📁 Archivos Disponibles

### `kanata.kbd` (Configuración Actual)

**Nivel**: Básico  
**Descripción**: Configuración minimalista que solo incluye navegación vim.

**Características**:
- ✅ CapsLock (hold) + hjkl → Flechas de navegación
- ✅ CapsLock (hold) + Space → Modo Líder (F24)
- ✅ CapsLock (tap) → Dynamic Layer (F23)
- ❌ NO incluye homerow mods

**Ideal para**: Usuarios que quieren empezar simple o que ya tienen modificadores configurados de otra manera.

---

### `kanata-homerow.kbd` (Configuración Avanzada)

**Nivel**: Avanzado  
**Descripción**: Configuración completa con homerow mods para máxima ergonomía.

**Características**:
- ✅ CapsLock (hold) + hjkl → Flechas de navegación
- ✅ CapsLock (hold) + Space → Modo Líder (F24)
- ✅ CapsLock (tap) → Dynamic Layer (F23)
- ✅ **Homerow Mods**:
  - `a` (hold) → Ctrl
  - `s` (hold) → Alt
  - `d` (hold) → Win
  - `f` (hold) → Shift
  - `j` (hold) → Shift
  - `k` (hold) → Win
  - `l` (hold) → Alt
  - `;` (hold) → Ctrl

**Ideal para**: Power users que quieren máxima ergonomía sin mover las manos de la fila principal.

**⚠️ Advertencia**: Requiere un período de adaptación. Puede causar falsos positivos al principio si escribes muy rápido.

---

### `kanata-extended.kbd` (Configuración con Plugins)

**Nivel**: Intermedio  
**Descripción**: Igual que la básica pero preparada para usar con plugins adicionales.

**Características**:
- ✅ Mismas características que `kanata.kbd`
- ✅ Optimizada para trabajar con plugins opcionales
- ✅ Comentarios adicionales para facilitar personalización

**Ideal para**: Usuarios que planean instalar plugins opcionales (Git, Folders, Timestamps, etc.)

---

### `kanata-advanced-homerow.kbd` (Configuración Ergonómica Extrema)

**Nivel**: 🔥 **EXTREMO** - Solo para usuarios muy avanzados  
**Descripción**: ⚠️ **ADVERTENCIA CRÍTICA** - Esta NO es solo una configuración con homerow mods. Es una **reasignación ergonómica COMPLETA del teclado** basada en el workflow personal del autor.

**🚨 CAMBIOS RADICALES vs Teclado Estándar:**
- ❌ **Backspace movido a la tecla `[`** - La tecla backspace original no funciona
- ❌ **Numrow superior deshabilitado** - Los números 1-0 en la fila superior no funcionan
- ⚡ **Alt Left = Capa de números/símbolos** - Mantener Alt Izq para acceder a números
- ⚡ **Alt Right = Capa de teclas de función** - Mantener Alt Der para F1-F24
- ⚡ **G (hold) = Numpad** - Teclado numérico en mano derecha
- 🖱️ **Mouse integrado**: N=Click Izq, M=Click Der, B=Click Medio
- 🎯 **Homerow Mods**: a/s/d/f y j/k/l/; como modificadores
- ⚙️ **Timing ultra-optimizado** para escritura rápida

**⚠️ IMPORTANTE**: 
- **ESTO NO ES UN TECLADO NORMAL** - Muchas teclas están reasignadas completamente
- **Lee la documentación COMPLETA** en `doc/[es|en]/guia-usuario/homerow-mods.md` antes de usar
- **NO copies esto directamente** sin entender cada cambio
- Requiere período de adaptación de SEMANAS, no días
- Diseñado para ergonomía extrema, sacrificando compatibilidad

**Ideal para**: Solo usuarios extremadamente avanzados que entienden Kanata a fondo, están dispuestos a reaprender el teclado completamente, y quieren ergonomía al máximo.

**⚠️ Cómo usar (SOLO SI SABES LO QUE HACES)**:
```powershell
# 1. LEE PRIMERO la documentación completa
# 2. Revisa TODO el archivo kanata-advanced-homerow.kbd línea por línea
# 3. Haz backup de tu config actual
Copy-Item ahk\config\kanata.kbd ahk\config\kanata.kbd.backup

# 4. Copia como base y PERSONALIZA (NO uses tal cual)
Copy-Item doc\kanata-configs\kanata-advanced-homerow.kbd ahk\config\kanata-custom.kbd

# 5. EDITA kanata-custom.kbd según TUS necesidades
# 6. Prueba en un documento de texto antes de usar en producción
```

**📚 Documentación detallada**: Ver sección "Plantilla Ergonómica Extrema" en las guías de usuario.

---

## 🔄 Cómo Cambiar de Configuración

### Método 1: Renombrar archivos (Recomendado)

```powershell
# Navegar a la carpeta de configuración
cd ahk\config

# Respaldar la configuración actual
Copy-Item kanata.kbd kanata.kbd.backup

# Copiar la configuración con homerow mods desde la documentación
Copy-Item ..\..\doc\kanata-configs\kanata-homerow.kbd kanata.kbd

# Reiniciar Kanata
# Leader → h → k (Restart Kanata Only)
```

### Método 2: Editar settings.ahk

Edita `ahk/config/settings.ahk` y cambia la ruta del archivo:

```autohotkey
; Ruta al config de Kanata
global KanataConfigPath := A_ScriptDir . "\config\kanata.kbd"
```

Luego copia el archivo de configuración deseado desde `doc/kanata-configs/` a `ahk/config/kanata.kbd` y recarga: `Leader → h → R`

---

## 🎓 Guía de Selección

### ¿Cuál configuración debo usar?

```
┌─────────────────────────────────────────────────────────┐
│ ¿Eres nuevo en Hybrid CapsLock?                        │
│                                                         │
│ SÍ → Usa kanata.kbd (básico)                           │
│      Aprende primero la navegación vim                 │
│                                                         │
│ NO → ¿Quieres homerow mods?                            │
│                                                         │
│      SÍ → Usa kanata-homerow.kbd                       │
│           Máxima ergonomía                             │
│                                                         │
│      NO → ¿Vas a instalar plugins?                     │
│                                                         │
│           SÍ → Usa kanata-extended.kbd                 │
│           NO → Mantén kanata.kbd                       │
└─────────────────────────────────────────────────────────┘
```

---

## 📝 Crear Tu Propia Configuración

Puedes crear tu propio archivo `.kbd` personalizado:

1. Copia uno de los archivos existentes
2. Renómbralo (ej: `kanata-custom.kbd`)
3. Edita según tus necesidades
4. Actualiza `settings.ahk` para usarlo

### Recursos para Aprender Kanata

- [Documentación oficial de Kanata](https://github.com/jtroo/kanata)
- [Tutorial de configuración](https://github.com/jtroo/kanata/blob/main/docs/config.adoc)
- [Ejemplos de la comunidad](https://github.com/jtroo/kanata/tree/main/cfg_samples)

---

## 🐛 Troubleshooting

### Las teclas no funcionan después de cambiar

1. Verifica que el archivo `.kbd` no tenga errores de sintaxis
2. Reinicia Kanata: `Leader → h → k`
3. Revisa el log: `Leader → h → l`

### Homerow mods causan falsos positivos

Ajusta los valores de `tap-hold` en el archivo `.kbd`:

```lisp
;; Aumenta el delay para reducir falsos positivos
(defalias
  a (tap-hold 250 250 a lctl)  ;; Era 200, ahora 250
)
```

### Kanata no inicia

1. Verifica que la ruta en `settings.ahk` sea correcta
2. Ejecuta Kanata manualmente para ver errores:
   ```powershell
   & "C:\Program Files\Kanata\kanata.exe" --cfg "ahk\config\kanata.kbd"
   ```

---

## 📖 Siguiente Paso

Después de elegir tu configuración, aprende a usar el sistema:

**→ [Volver a la Guía de Instalación](../es/guia-usuario/instalacion.md)**

---

<div align="center">

[← Volver al Inicio](../../README.md)

</div>
