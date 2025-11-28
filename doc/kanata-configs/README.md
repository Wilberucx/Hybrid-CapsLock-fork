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
