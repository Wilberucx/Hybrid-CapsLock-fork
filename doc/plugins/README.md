# 🧩 Optional Plugins Catalog

> 📍 **Navegación**: [Inicio](../../README.md) > Catálogo de Plugins

¡Bienvenido al catálogo de plugins de Hybrid CapsLock! Este directorio contiene plugins opcionales que puedes añadir a tu configuración para extender las capacidades del sistema.

## 🎯 Filosofía: Tú Decides Qué Instalar

El sistema base de Hybrid CapsLock es **intencionalmente ligero**. Solo incluye las funcionalidades esenciales para la navegación y el sistema de capas. Todo lo demás es **opcional**.

¿Por qué? Porque cada usuario tiene necesidades diferentes:
- Un desarrollador puede querer integración con Git y ADB
- Un escritor puede preferir snippets de texto y timestamps
- Un power user puede necesitar control de energía y monitoreo del sistema

**Tú eliges** qué funcionalidades instalar según tus necesidades.

## 📥 Cómo Instalar un Plugin

1. **Explora el catálogo** más abajo y encuentra el plugin que necesitas
2. **Descarga el archivo `.ahk`** desde `doc/plugins/` en el repositorio
3. **Copia el archivo** a tu carpeta `ahk/plugins/`
4. **Recarga el sistema**: `Leader → h → R`

¡Listo! El plugin se cargará automáticamente y sus keymaps estarán disponibles.

## 🌟 Plugins Recomendados para Empezar

Si eres nuevo en Hybrid CapsLock, te recomendamos empezar con estos plugins:

### Para Todos los Usuarios

1. **[Folder Actions](#folder-actions-folder_actionsahk)** - Gestión rápida de carpetas
   - Acceso rápido a carpetas frecuentes
   - Historial de carpetas visitadas
   - Abrir terminal en carpeta actual

2. **[Timestamp Actions](#timestamp-actions-timestamp_actionsahk)** - Insertar fechas y horas
   - Útil para notas, logs, commits
   - Múltiples formatos disponibles

### Para Desarrolladores

3. **[Git Actions](#git-actions-git_actionsahk)** - Comandos Git rápidos
   - Status, push, commit, log sin salir del editor
   - Feedback visual de resultados

4. **[Shell Shortcuts](#shell-shortcuts-shell_shortcutsahk)** - Lanzadores de aplicaciones
   - Abre tus herramientas favoritas con 2 teclas
   - Fácil de personalizar

### Para Power Users

5. **[Power Actions](#power-actions-power_actionsahk)** - Control de energía
   - Prevenir suspensión para descargas largas
   - Apagar monitor sin suspender PC
   - Programar apagado/reinicio

## 💡 Casos de Uso Comunes

### Caso 1: Desarrollador Web

**Necesitas**: Navegación rápida, Git, lanzar herramientas, gestión de carpetas

**Plugins recomendados**:
- `git_actions.ahk` - Para commits y push rápidos
- `folder_actions.ahk` - Para navegar entre proyectos
- `shell_shortcuts.ahk` - Para abrir VS Code, Chrome, Terminal
- `timestamp_actions.ahk` - Para commits con fecha

### Caso 2: Escritor/Blogger

**Necesitas**: Snippets de texto, timestamps, gestión de archivos

**Plugins recomendados**:
- `sendinfo_actions.ahk` - Para snippets de texto frecuentes
- `timestamp_actions.ahk` - Para fechas en artículos
- `folder_actions.ahk` - Para organizar documentos

### Caso 3: Desarrollador Android

**Necesitas**: ADB, Git, terminal, gestión de proyectos

**Plugins recomendados**:
- `adb_actions.ahk` - Para instalar APKs, conectar dispositivos
- `git_actions.ahk` - Para control de versiones
- `folder_actions.ahk` - Para navegar entre proyectos
- `shell_shortcuts.ahk` - Para Android Studio

### Caso 4: Administrador de Sistemas

**Necesitas**: Monitoreo, red, energía, terminal

**Plugins recomendados**:
- `monitoring_actions.ahk` - Para ver uso de CPU/RAM
- `network_actions.ahk` - Para diagnósticos de red
- `power_actions.ahk` - Para gestión de energía
- `shell_shortcuts.ahk` - Para PowerShell, CMD

---

## 📑 Index

- [ADB Actions](#adb-actions-adb_actionsahk)
- [Explorer Actions](#explorer-actions-explorer_actionsahk)
- [Folder Actions](#folder-actions-folder_actionsahk)
- [Power Actions](#power-actions-power_actionsahk)
- [SendInfo Actions](#sendinfo-actions-sendinfo_actionsahk)
- [Git Actions](#git-actions-git_actionsahk)
- [Shell Shortcuts](#shell-shortcuts-shell_shortcutsahk)
- [System Monitoring](#system-monitoring-monitoring_actionsahk)
- [Network Actions](#network-actions-network_actionsahk)
- [Timestamp Actions](#timestamp-actions-timestamp_actionsahk)
- [VaultFlow Actions](#vaultflow-actions-vaultflow_actionsahk)

---

## 🤖 ADB Actions (`adb_actions.ahk`)

Advanced integration with Android Debug Bridge for developers.

**Key Features:**
- **Connect Manager**: GUI to manage and connect to device IPs with history support.
- **Package Manager**: GUI to search, filter, and uninstall/clear data for installed packages.
- **APK Installer**: Graphical file selection for installing APKs.

**Keymaps (Leader + a):**
- `c`: **Connect** to device (GUI with history)
- `i`: **Install APK** (File selector)
- `u`: **Uninstall Package** (Searchable list)
- `d`: **Clear App Data** (Searchable list)
- `r`: **Reboot Device**
- `k`: **Kill Server**

---

## 📁 Explorer Actions (`explorer_actions.ahk`)

Vim-style navigation and file management for Windows Explorer.

**Key Features:**
- **Vim-Inspired Keybindings**: Navigate Explorer with familiar vim commands.
- **File Operations**: Rename, add files/folders, edit files, toggle hidden files.
- **Tab Management**: Open/close Explorer windows, navigate folder history.
- **Copy Actions**: Copy paths, filenames, directory paths with one key.

**Entry Point:**
- Access via `Leader → e → x` to activate Explorer layer

**Keymaps (Explorer Layer):**
- `r`: **Rename** (Sends F2, switches to insert mode)
- `a`: **Add File/Folder** (Dynamic GUI, auto-detects type)
- `e`: **Edit File** (Opens in configured editor)
- `.`: **Toggle Hidden Files**

**Tab Manager (b):**
- `bd`: Close current Explorer window
- `bn`: Open new Explorer window
- `H`: Navigate to previous folder
- `L`: Navigate to next folder

**Copy Actions (c):**
- `cp`: Copy full path of selected item
- `cd`: Copy current directory path
- `cf`: Copy filename only

**Dependencies:**
- Uses `GetSelectedExplorerItem()` from `context_utils.ahk`
- Uses `GetActiveExplorerPath()` from `context_utils.ahk`

---

## 📂 Folder Actions (`folder_actions.ahk`)

Smart folder management and quick access.

**Key Features:**
- **Custom Folder History**: Open any folder and it's saved to history.
- **Dynamic Shortcuts**: Automatically generates `folder_shortcuts.ahk` with shortcuts (1-9) for your most recent folders.
- **Terminal Integration**: Open Windows Terminal or CMD in the current Explorer folder.

**Keymaps (Leader + f):**
- `o`: **Open Custom Folder** (GUI with history)
- `h`: **Recent Folders** (Sub-menu 1-9)
- `T`: **Open in Terminal** (Current folder)
- `y`: **Copy Path** (Current folder)
- `d`: Open Downloads
- `p`: Open Projects
- `w`: Open Work

---

## ⚡ Power Actions (`power_actions.ahk`)

System power state management and scheduling.

**Key Features:**
- **Prevent Sleep Toggle**: Keeps the system awake for presentations or long downloads.
- **Monitor Off**: Turns off the screen without suspending the PC.
- **Scheduled Actions**: Schedule shutdown or restart after X minutes.
- **Safety First**: All destructive actions (Shutdown, Restart) require confirmation.

> [!IMPORTANT]
> **Prevent Sleep Behavior**: The "Prevent Sleep" toggle only works **while the script is running**. If you exit or close the AutoHotkey script, the system will revert to its normal power plan settings immediately. The state is persisted across script reloads, but not if the script is terminated.

**Keymaps (Leader + o):**
- `p`: **Toggle Prevent Sleep** (Keep awake)
- `m`: **Monitor Off**
- `t`: **Schedule Shutdown**
- `T`: **Schedule Restart**
- `l`: Lock Screen
- `s`: Sleep
- `h`: Hibernate
- `r`: Restart
- `S`: Shutdown

---

## ℹ️ SendInfo Actions (`sendinfo_actions.ahk`)

Intelligent text insertion and snippet management.

**Key Features:**
- **Snippet Manager**: GUI to search, manage, and insert saved text snippets.
- **Clipboard Saver**: Quickly save current clipboard content as a named snippet.
- **JSON Storage**: Uses `data/snippets.json` for robust handling of multiline text and special characters.
- **Instant Paste**: Uses clipboard injection for instant insertion of large text blocks.

**Keymaps (Leader + i):**
- `m`: **Snippet Manager** (GUI)
- `a`: **Add from Clipboard**
- `e`: Insert Email
- `p`: Insert Phone
- `s`: Insert Signature (Multiline example)

---

## 🐙 Git Actions (`git_actions.ahk`)

Essential Git commands for your workflow.

**Key Features:**
- **Context Aware**: Detects if current folder is a git repo.
- **Visual Feedback**: Shows command output in tooltips.

**Keymaps (Leader + g):**
- `s`: Status
- `p`: Push
- `c`: Commit (with input)
- `l`: Log

---

## 🚀 Shell Shortcuts (`shell_shortcuts.ahk`)

Quick launchers for your favorite applications.

**Key Features:**
- Simple one-line shortcuts using the Core `ShellExec` API.
- Easy to customize for your own apps.

**Keymaps (Leader + p):**
- `c`: Chrome
- `v`: VS Code
- `t`: Terminal
- `n`: Notepad

---

## 📊 System Monitoring (`monitoring_actions.ahk`)

Scripts to keep an eye on system performance.

**Key Features:**
- **Top Processes**: Shows CPU/RAM usage of top apps.
- **System Stats**: Quick overview of system resources.

**Keymaps (Leader + m):**
- `t`: Top Processes
- `s`: System Stats

---

## 🌐 Network Actions (`network_actions.ahk`)

Quick network diagnostics and tools.

**Keymaps (Leader + n):**
- `p`: Ping Google
- `f`: Flush DNS
- `i`: Show IP Configuration

---

## 🕒 Timestamp Actions (`timestamp_actions.ahk`)

Insert current date and time in various formats.

**Keymaps (Leader + t):**
- `d`: Date (YYYY-MM-DD)
- `t`: Time (HH:mm)
- `f`: Full (YYYY-MM-DD HH:mm:ss)
- `u`: Unix Timestamp

---

## 💎 VaultFlow Actions (`vaultflow_actions.ahk`)

Integration with VaultFlow (Obsidian workflow).

**Keymaps (Leader + v):**
- `v`: **VaultFlow Menu** (Interactive CLI)
- `c`: **Commit** (Custom message)
- `l`: **Log** (View history)
- `s`: **Status** (Check changes)

---

## 📜 Scroll Actions (`scroll_actions.ahk`)

Implements a dedicated **Scroll Layer** for navigation without holding modifier keys.

**Key Features:**
- **Scroll Layer**: A persistent mode where keys `h/j/k/l` become scroll controls.
- **Visual Feedback**: Shows a status indicator (color `#E6C07B`) when active.
- **Vim-like Navigation**: Uses standard Vim keys for scrolling.

**Keymaps:**
- **Enter Layer**: `Leader + s`
- **Exit Layer**: `s` or `Escape`

**Layer Controls (Active only in Scroll Mode):**
- `k` / `j`: Scroll Up / Down
- `h` / `l`: Scroll Left / Right


---

## 📝 Creating Your Own

You can use these files as templates to create your own plugins. See [Plugin Architecture](../es/guia-desarrollador/arquitectura-plugins.md) for technical details.

### Quick Start: Tu Primer Plugin

1. Crea un archivo en `ahk/plugins/mi_plugin.ahk`
2. Registra una capa: `RegisterLayer("mi_capa", "MI CAPA", "#FF6B6B", "#FFFFFF")`
3. Añade keymaps: `RegisterKeymap("mi_capa", "a", "Mi Acción", () => MsgBox("¡Funciona!"))`
4. Crea entrada desde Leader: `RegisterKeymap("leader", "x", "Mi Plugin", () => SwitchToLayer("mi_capa"))`
5. Recarga: `Leader → h → R`

Para más detalles, consulta la [Guía de Creación de Capas](../es/guia-desarrollador/crear-capas.md).

---

## 📖 Siguiente Paso

¿Quieres crear tus propios plugins? Aprende sobre la arquitectura del sistema:

**→ [Arquitectura de Plugins](../es/guia-desarrollador/arquitectura-plugins.md)**

---

<div align="center">

[← Volver al Inicio](../../README.md) | [Crear Plugins →](../es/guia-desarrollador/arquitectura-plugins.md)

</div>
