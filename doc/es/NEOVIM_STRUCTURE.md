# Estructura Neovim en HybridCapsLock

## 📁 Nueva Estructura

```
HybridCapsLock/
├── HybridCapslock.ahk          # Entry point (como 'nvim')
├── init.ahk                     # Config principal (como init.lua)
│
├── ahk/                         # 👤 TU CONFIGURACIÓN (como lua/)
│   ├── config/                  # Tus archivos de configuración
│   │   ├── settings.ahk
│   │   ├── keymap.ahk
│   │   ├── colorscheme.ahk
│   │   └── kanata.kbd
│   ├── actions/                 # Tus acciones personalizadas
│   │   └── (agrega tus archivos .ahk aquí)
│   └── layers/                  # Tus capas personalizadas
│       └── (agrega tus archivos .ahk aquí)
│
├── system/                      # ⚙️ SISTEMA (actualizable, como runtime/)
│   ├── core/                    # Core del sistema
│   │   ├── auto_loader.ahk
│   │   ├── config.ahk
│   │   ├── globals.ahk
│   │   ├── keymap_registry.ahk
│   │   ├── kanata_launcher.ahk
│   │   └── dependency_checker.ahk
│   ├── ui/                      # Sistema UI
│   │   ├── tooltip_csharp_integration.ahk
│   │   └── tooltips_native_wrapper.ahk
│   ├── actions/                 # Acciones base del sistema
│   │   ├── vim_nav.ahk
│   │   ├── vim_edit.ahk
│   │   ├── git_actions.ahk
│   │   └── ... (más acciones)
│   └── layers/                  # Capas base del sistema
│       ├── nvim_layer.ahk
│       ├── leader_router.ahk
│       └── ... (más layers)
│
├── data/                        # Runtime (generado automáticamente)
│   ├── auto_loader_memory.json
│   └── *.log
│
├── doc/                         # Documentación
├── scripts/                     # Scripts de utilidad
└── update.ps1                   # Script de actualización
```

## 🎯 Filosofía (Inspirada en Neovim)

### Como en Neovim:
- **`nvim`** (ejecutable) → **`HybridCapslock.ahk`** (entry point)
- **`init.lua`** (config raíz) → **`init.ahk`** (config raíz)
- **`lua/`** (user config) → **`ahk/`** (user config)
- **Runtime de Neovim** → **`system/`** (actualizable)

### Prioridad de Archivos:
1. **`ahk/` (USER)** - Tu configuración tiene máxima prioridad
2. **`system/` (SYSTEM)** - Sistema por defecto si no hay override

## 🔄 Sistema de Override

### Ejemplo: Personalizar una acción del sistema

**Escenario:** Quieres modificar `git_actions.ahk`

1. **Copia** el archivo del sistema:
   ```powershell
   Copy-Item system\actions\git_actions.ahk ahk\actions\
   ```

2. **Modifica** `ahk\actions\git_actions.ahk` con tus cambios

3. **Resultado:** El auto-loader usará tu versión en `ahk/` en lugar de la del `system/`

### Ejemplo: Crear acción personalizada

1. **Crea** `ahk\actions\my_custom_actions.ahk`

2. **Escribe** tu código:
   ```ahk
   ; Mis acciones personalizadas
   MyCustomFunction() {
       MsgBox("¡Hola desde mi acción personalizada!")
   }
   ```

3. **Resultado:** El auto-loader la cargará automáticamente en el próximo inicio

## 🆕 Actualización del Sistema

### Actualizaciones Automáticas

```powershell
# Descargar última versión desde GitHub
.\update.ps1

# Instalar versión específica
.\update.ps1 -Version "v6.4"

# Instalar desde archivo local
.\update.ps1 -LocalZip "C:\Downloads\HybridCapsLock-v6.4.zip"
```

### ¿Qué se actualiza?
✅ `system/` - Todo el core del sistema
✅ `HybridCapslock.ahk` - Entry point
✅ `README.md`, `CHANGELOG.md` - Documentación
✅ `doc/` - Documentación completa

### ¿Qué NO se toca?
✅ `ahk/` - Tu configuración personal
✅ `data/` - Tus logs y settings
✅ `init.ahk` - Tu config principal (si la has modificado)

## 🛡️ Seguridad

### Backups Automáticos

- **Migración:** Se crea backup completo en `backup_before_migration_YYYYMMDD_HHMMSS/`
- **Actualización:** Se crea backup de `ahk/` en `backup_ahk_YYYYMMDD_HHMMSS/`

### Rollback

Si algo sale mal durante la migración:

```powershell
.\migrate_to_neovim_structure.ps1 -Rollback
```

## 📝 .gitignore

La carpeta `ahk/` está excluida del repositorio principal (como `lua/` en Neovim):

```gitignore
# User config (no tracked in main repo)
ahk/

# Except README files
!ahk/actions/README.md
!ahk/layers/README.md
```

**Tip:** Puedes crear tu propio repositorio Git dentro de `ahk/` para versionar tu configuración personal:

```powershell
cd ahk
git init
git remote add origin https://github.com/TU-USUARIO/mi-config-hybridcapslock.git
git add .
git commit -m "Mi configuración personalizada"
git push -u origin main
```

## 🚀 Flujo de Trabajo

### Desarrollo Normal
1. Edita archivos en `ahk/config/`, `ahk/actions/`, `ahk/layers/`
2. Reinicia HybridCapslock
3. Tus cambios se aplican inmediatamente

### Cuando Hay Actualización
1. Ejecuta `.\update.ps1`
2. El script actualiza `system/` automáticamente
3. Tu `ahk/` se mantiene intacto
4. Reinicia y ya tienes la nueva versión

### Compartir Configuración
1. Tu `ahk/` es portable
2. Puedes compartirla con otros usuarios
3. Cada uno puede tener su propia `ahk/` personalizada

## 📚 Comandos Útiles

### Ver diferencias entre tu config y el sistema
```powershell
# Comparar tu settings.ahk con el del sistema
fc ahk\config\settings.ahk system\config\settings.ahk
```

### Restaurar un archivo desde el sistema
```powershell
# Si quieres volver al default del sistema
Remove-Item ahk\actions\git_actions.ahk
# Ahora usará el de system/actions/git_actions.ahk
```

### Sincronizar configuración con otro PC
```powershell
# PC 1: Exportar tu config
Compress-Archive -Path ahk\ -DestinationPath mi_config.zip

# PC 2: Importar config
Expand-Archive -Path mi_config.zip -DestinationPath .
```

## ❓ FAQ

### ¿Puedo seguir modificando init.ahk?
**Sí**, `init.ahk` está en la raíz y es editable (como `init.lua` en Neovim). El script de actualización lo preserva si detecta cambios personalizados.

### ¿Qué pasa si borro ahk/?
El sistema usará los archivos por defecto de `system/`. Tu aplicación seguirá funcionando normalmente.

### ¿Puedo usar git en ahk/?
**Sí**, puedes crear tu propio repositorio Git dentro de `ahk/` para versionar tu configuración personal.

### ¿Cómo vuelvo al sistema original?
Simplemente borra los archivos en `ahk/` que quieras resetear. El auto-loader usará automáticamente los de `system/`.

### ¿Las carpetas antiguas src/ y config/ se pueden borrar?
**Sí**, después de verificar que todo funcione correctamente, puedes eliminar manualmente:
- `src/`
- `config/`

Estos directorios ya no se usan en la nueva estructura.

## 🔗 Enlaces

- [Migración Original](migrate_to_neovim_structure.ps1) - Script de migración
- [Script de Actualización](update.ps1) - Actualizar sistema preservando config
- [README Principal](README.md) - Documentación general
- [CHANGELOG](CHANGELOG.md) - Historial de cambios
