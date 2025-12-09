# 🧩 Optional Plugins Catalog

> 📍 **Navigation**: [Home](../../README.md) > Plugins Catalog
> 
> 📍 **Navegación**: [Inicio](../../README.md) > Catálogo de Plugins

---

## 🌍 Language / Idioma

- [🇬🇧 English Version](#-english-version)
- [🇪🇸 Versión en Español](#-versión-en-español)

---

# 🇬🇧 English Version

Welcome to the Hybrid CapsLock plugin catalog! This directory contains optional plugins you can add to your configuration to extend the system's capabilities.

## 🎯 Philosophy: You Decide What to Install

The Hybrid CapsLock base system is **intentionally lightweight**. It only includes essential features for navigation and the layer system. Everything else is **optional**.

Why? Because each user has different needs:
- A developer might want Git and ADB integration
- A writer might prefer text snippets and timestamps
- A power user might need energy control and system monitoring

**You choose** which features to install according to your needs.

## 📥 How to Install a Plugin

1. **Browse the catalog** below and find the plugin you need
2. **Download the `.ahk` file** from `doc/plugins/` in the repository
3. **Copy the file** to your `ahk/plugins/` folder
4. **Reload the system**: `Leader → h → R`

Done! The plugin will load automatically and its keymaps will be available.


## 🌟 Recommended Plugins to Get Started

If you're new to Hybrid CapsLock, we recommend starting with these plugins:

### For All Users

1. **[Folder Actions](#folder-actions-folder_actionsahk)** - Quick folder management
   - Fast access to frequent folders
   - Visited folder history
   - Open terminal in current folder

2. **[Timestamp Actions](#timestamp-actions-timestamp_actionsahk)** - Insert dates and times
   - Useful for notes, logs, commits
   - Multiple formats available

### For Developers

3. **[Git Actions](#git-actions-git_actionsahk)** - Quick Git commands
   - Status, push, commit, log without leaving editor
   - Visual feedback of results

4. **[Shell Shortcuts](#shell-shortcuts-shell_shortcutsahk)** - Application launchers
   - Open your favorite tools with 2 keys
   - Easy to customize

### For Power Users

5. **[Power Actions](#power-actions-power_actionsahk)** - Power control
   - Prevent suspension for long downloads
   - Turn off monitor without suspending PC
   - Schedule shutdown/restart

## 💡 Common Use Cases

### Case 1: Web Developer

**You need**: Fast navigation, Git, launch tools, folder management

**Recommended plugins**:
- `git_actions.ahk` - For quick commits and pushes
- `folder_actions.ahk` - To navigate between projects
- `shell_shortcuts.ahk` - To open VS Code, Chrome, Terminal
- `timestamp_actions.ahk` - For dated commits

### Case 2: Writer/Blogger

**You need**: Text snippets, timestamps, file management

**Recommended plugins**:
- `sendinfo_actions.ahk` - For frequent text snippets
- `timestamp_actions.ahk` - For dates in articles
- `folder_actions.ahk` - To organize documents

### Case 3: Android Developer

**You need**: ADB, Git, terminal, project management

**Recommended plugins**:
- `adb_actions.ahk` - To install APKs, connect devices
- `git_actions.ahk` - For version control
- `folder_actions.ahk` - To navigate between projects
- `shell_shortcuts.ahk` - For Android Studio

### Case 4: System Administrator

**You need**: Monitoring, network, power, terminal

**Recommended plugins**:
- `monitoring_actions.ahk` - To view CPU/RAM usage
- `network_actions.ahk` - For network diagnostics
- `power_actions.ahk` - For power management
- `shell_shortcuts.ahk` - For PowerShell, CMD

---

## 📑 Plugin Index

1. [ADB Actions](#adb-actions-adb_actionsahk) - Android Debug Bridge integration
2. [Explorer Actions](#explorer-actions-explorer_actionsahk) - Vim-style Windows Explorer navigation
3. [Folder Actions](#folder-actions-folder_actionsahk) - Smart folder management
4. [Git Actions](#git-actions-git_actionsahk) - Essential Git commands
5. [LazyGit Actions](#lazygit-actions-lazygit_actionsahk) - LazyGit integration
6. [Monitoring Actions](#system-monitoring-monitoring_actionsahk) - System performance monitoring
7. [Network Actions](#network-actions-network_actionsahk) - Network diagnostics
8. [Power Actions](#power-actions-power_actionsahk) - Power state management
9. [Scroll Actions](#scroll-actions-scroll_actionsahk) - Dedicated scroll layer
10. [SendInfo Actions](#sendinfo-actions-sendinfo_actionsahk) - Text snippets manager
11. [Shell Shortcuts](#shell-shortcuts-shell_shortcutsahk) - Application launchers
12. [System Actions](#system-actions-system_actionsahk) - System utilities
13. [Timestamp Actions](#timestamp-actions-timestamp_actionsahk) - Date/time insertion
14. [VaultFlow Actions](#vaultflow-actions-vaultflow_actionsahk) - Obsidian workflow integration
15. [Vim Actions](#vim-actions-vim_actionsahk) - Vim integration
16. [Windows Manager](#windows-manager-windows_managerahk) - Window management

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

> [!WARNING]
> **DEPENDENCIES REQUIRED:**
> - **`vim_actions.ahk`** - Provides Vim motion functions (h/j/k/l, cut, paste, visual mode, etc.)
> - **`folder_actions.ahk`** - Provides navigation shortcuts (GoToDesktop, GoToHome, etc.)
> - **`system_actions.ahk`** - Provides ToggleHiddenFiles function
> 
> **Install these 3 plugins first**, or you'll get "function not found" errors.

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

## 🦥 LazyGit Actions (`lazygit_actions.ahk`)

> [!WARNING]
> **DEPENDENCY REQUIRED:**
> - **`git_actions.ahk`** - Provides `RunGitCommand()` function
> 
> **Install git_actions.ahk first**, or this plugin will fail.

Integration with LazyGit TUI (Terminal User Interface) for Git.

**Key Features:**
- **LazyGit Launcher**: Opens LazyGit in the current directory context.
- **Terminal Integration**: Uses Windows Terminal or fallback to CMD.
- **Context Detection**: Automatically detects git repository context.

**Keymaps (Leader + g):**
- `g`: **Open LazyGit** (In current directory)

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

## ⚙️ System Actions (`system_actions.ahk`)

System utilities and quick access tools.

**Key Features:**
- **Task Manager**: Quick launch of Windows Task Manager.
- **System Info**: Display system information.
- **Registry Editor**: Quick access to regedit.
- **Services Manager**: Open Windows Services.

**Keymaps (Leader + y):**
- `t`: **Task Manager**
- `s`: **System Info**
- `r`: **Registry Editor**
- `v`: **Services Manager**

---

## 🎯 Vim Actions (`vim_actions.ahk`)

Integration with Vim/Neovim editors.

**Key Features:**
- **Quick Launch**: Open Vim or Neovim with context awareness.
- **File Opening**: Open current file in Vim.
- **Terminal Integration**: Launch Vim in terminal or GUI mode.

**Keymaps (Leader + v):**
- `v`: **Open Vim** (GUI or Terminal)
- `e`: **Edit Current File** (In Vim)

---

## 🪟 Windows Manager (`windows_manager.ahk`)

Comprehensive window management and navigation system.

**Key Features:**
- **Smart Window Listing**: Uses Task View (Win+Tab) with Vim-style navigation (hjkl).
- **Tab Management**: Unified interface for closing/creating tabs in browsers and editors.
- **Safety**: Confirmation dialogs for destructive operations.

**Keymaps (Leader + w):**
- `d`: **Close Window** (Native Close)
- `m`: **Toggle Minimize/Restore**
- `M`: **Force Minimize**
- `l`: **List Windows** (Task View with navigation)
- `H`: **Previous Window**
- `L`: **Next Window**
- `b`: **Tab Manager Submenu**
  - `d`: Close Tab
  - `n`: New Tab

---

## 📝 Creating Your Own Plugins

You can use these files as templates to create your own plugins. See [Plugin Architecture](../en/developer-guide/plugin-architecture.md) for technical details.

### Quick Start: Your First Plugin

1. Create a file in `ahk/plugins/my_plugin.ahk`
2. Register a layer: `RegisterLayer("my_layer", "MY LAYER", "#FF6B6B", "#FFFFFF")`
3. Add keymaps: `RegisterKeymap("my_layer", "a", "My Action", () => MsgBox("It works!"))`
4. Create entry from Leader: `RegisterKeymap("leader", "x", "My Plugin", () => SwitchToLayer("my_layer"))`
5. Reload: `Leader → h → R`

For more details, check the [Creating Layers Guide](../en/developer-guide/creating-layers.md).

---

## 📖 Next Steps

Want to create your own plugins? Learn about the system architecture:

**→ [Plugin Architecture](../en/developer-guide/plugin-architecture.md)**

---

<div align="center">

[← Back to Home](../../README.md) | [Create Plugins →](../en/developer-guide/plugin-architecture.md)

</div>

---
---

# 🇪🇸 Versión en Español

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

1. **[Folder Actions](#folder-actions-folder_actionsahk-1)** - Gestión rápida de carpetas
   - Acceso rápido a carpetas frecuentes
   - Historial de carpetas visitadas
   - Abrir terminal en carpeta actual

2. **[Timestamp Actions](#timestamp-actions-timestamp_actionsahk-1)** - Insertar fechas y horas
   - Útil para notas, logs, commits
   - Múltiples formatos disponibles

### Para Desarrolladores

3. **[Git Actions](#git-actions-git_actionsahk-1)** - Comandos Git rápidos
   - Status, push, commit, log sin salir del editor
   - Feedback visual de resultados

4. **[Shell Shortcuts](#shell-shortcuts-shell_shortcutsahk-1)** - Lanzadores de aplicaciones
   - Abre tus herramientas favoritas con 2 teclas
   - Fácil de personalizar

### Para Power Users

5. **[Power Actions](#power-actions-power_actionsahk-1)** - Control de energía
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

## 📑 Índice de Plugins

1. [ADB Actions](#adb-actions-adb_actionsahk-1) - Integración con Android Debug Bridge
2. [Explorer Actions](#explorer-actions-explorer_actionsahk-1) - Navegación estilo Vim en Explorer
3. [Folder Actions](#folder-actions-folder_actionsahk-1) - Gestión inteligente de carpetas
4. [Git Actions](#git-actions-git_actionsahk-1) - Comandos Git esenciales
5. [LazyGit Actions](#lazygit-actions-lazygit_actionsahk-1) - Integración con LazyGit
6. [Monitoring Actions](#system-monitoring-monitoring_actionsahk-1) - Monitoreo de rendimiento
7. [Network Actions](#network-actions-network_actionsahk-1) - Diagnósticos de red
8. [Power Actions](#power-actions-power_actionsahk-1) - Gestión de energía
9. [Scroll Actions](#scroll-actions-scroll_actionsahk-1) - Capa dedicada de scroll
10. [SendInfo Actions](#sendinfo-actions-sendinfo_actionsahk-1) - Gestor de snippets de texto
11. [Shell Shortcuts](#shell-shortcuts-shell_shortcutsahk-1) - Lanzadores de aplicaciones
12. [System Actions](#system-actions-system_actionsahk-1) - Utilidades del sistema
13. [Timestamp Actions](#timestamp-actions-timestamp_actionsahk-1) - Inserción de fecha/hora
14. [VaultFlow Actions](#vaultflow-actions-vaultflow_actionsahk-1) - Integración con Obsidian
15. [Vim Actions](#vim-actions-vim_actionsahk-1) - Integración con Vim
16. [Windows Manager](#windows-manager-windows_managerahk-1) - Gestión de ventanas

---

## 🤖 ADB Actions (`adb_actions.ahk`)

Integración avanzada con Android Debug Bridge para desarrolladores.

**Características Principales:**
- **Gestor de Conexión**: GUI para gestionar y conectar a IPs de dispositivos con historial.
- **Gestor de Paquetes**: GUI para buscar, filtrar y desinstalar/limpiar datos de paquetes instalados.
- **Instalador de APK**: Selección gráfica de archivos para instalar APKs.

**Keymaps (Leader + a):**
- `c`: **Conectar** a dispositivo (GUI con historial)
- `i`: **Instalar APK** (Selector de archivos)
- `u`: **Desinstalar Paquete** (Lista buscable)
- `d`: **Limpiar Datos de App** (Lista buscable)
- `r`: **Reiniciar Dispositivo**
- `k`: **Matar Servidor**

---

## 📁 Explorer Actions (`explorer_actions.ahk`)

> [!WARNING]
> **DEPENDENCIAS REQUERIDAS:**
> - **`vim_actions.ahk`** - Provee funciones de movimiento Vim (h/j/k/l, cut, paste, modo visual, etc.)
> - **`folder_actions.ahk`** - Provee atajos de navegación (GoToDesktop, GoToHome, etc.)
> - **`system_actions.ahk`** - Provee la función ToggleHiddenFiles
> 
> **Instalá estos 3 plugins primero**, o vas a obtener errores de "función no encontrada".

Navegación y gestión de archivos estilo Vim para el Explorador de Windows.

**Características Principales:**
- **Atajos Inspirados en Vim**: Navega el Explorador con comandos vim familiares.
- **Operaciones de Archivos**: Renombrar, agregar archivos/carpetas, editar archivos, mostrar archivos ocultos.
- **Gestión de Pestañas**: Abrir/cerrar ventanas del Explorador, navegar historial de carpetas.
- **Acciones de Copia**: Copiar rutas, nombres de archivos, rutas de directorio con una tecla.

**Punto de Entrada:**
- Acceso vía `Leader → e → x` para activar la capa Explorer

**Keymaps (Capa Explorer):**
- `r`: **Renombrar** (Envía F2, cambia a modo inserción)
- `a`: **Agregar Archivo/Carpeta** (GUI dinámica, detecta tipo automáticamente)
- `e`: **Editar Archivo** (Abre en editor configurado)
- `.`: **Alternar Archivos Ocultos**

**Gestor de Pestañas (b):**
- `bd`: Cerrar ventana actual del Explorador
- `bn`: Abrir nueva ventana del Explorador
- `H`: Navegar a carpeta anterior
- `L`: Navegar a carpeta siguiente

**Acciones de Copia (c):**
- `cp`: Copiar ruta completa del elemento seleccionado
- `cd`: Copiar ruta del directorio actual
- `cf`: Copiar solo nombre de archivo

**Dependencias:**
- Usa `GetSelectedExplorerItem()` de `context_utils.ahk`
- Usa `GetActiveExplorerPath()` de `context_utils.ahk`

---

## 📂 Folder Actions (`folder_actions.ahk`)

Gestión inteligente de carpetas y acceso rápido.

**Características Principales:**
- **Historial Personalizado de Carpetas**: Abre cualquier carpeta y se guarda en el historial.
- **Atajos Dinámicos**: Genera automáticamente `folder_shortcuts.ahk` con atajos (1-9) para tus carpetas más recientes.
- **Integración con Terminal**: Abre Windows Terminal o CMD en la carpeta actual del Explorador.

**Keymaps (Leader + f):**
- `o`: **Abrir Carpeta Personalizada** (GUI con historial)
- `h`: **Carpetas Recientes** (Submenú 1-9)
- `T`: **Abrir en Terminal** (Carpeta actual)
- `y`: **Copiar Ruta** (Carpeta actual)
- `d`: Abrir Descargas
- `p`: Abrir Proyectos
- `w`: Abrir Trabajo

---

## ⚡ Power Actions (`power_actions.ahk`)

Gestión de estados de energía del sistema y programación.

**Características Principales:**
- **Alternar Prevenir Suspensión**: Mantiene el sistema despierto para presentaciones o descargas largas.
- **Apagar Monitor**: Apaga la pantalla sin suspender el PC.
- **Acciones Programadas**: Programa apagado o reinicio después de X minutos.
- **Seguridad Primero**: Todas las acciones destructivas (Apagar, Reiniciar) requieren confirmación.

> [!IMPORTANT]
> **Comportamiento de Prevenir Suspensión**: El toggle "Prevenir Suspensión" solo funciona **mientras el script está en ejecución**. Si sales o cierras el script de AutoHotkey, el sistema volverá a su configuración normal de plan de energía inmediatamente. El estado persiste entre recargas del script, pero no si el script se termina.

**Keymaps (Leader + o):**
- `p`: **Alternar Prevenir Suspensión** (Mantener despierto)
- `m`: **Apagar Monitor**
- `t`: **Programar Apagado**
- `T`: **Programar Reinicio**
- `l`: Bloquear Pantalla
- `s`: Suspender
- `h`: Hibernar
- `r`: Reiniciar
- `S`: Apagar

---

## ℹ️ SendInfo Actions (`sendinfo_actions.ahk`)

Inserción inteligente de texto y gestión de snippets.

**Características Principales:**
- **Gestor de Snippets**: GUI para buscar, gestionar e insertar snippets de texto guardados.
- **Guardador de Portapapeles**: Guarda rápidamente el contenido actual del portapapeles como snippet nombrado.
- **Almacenamiento JSON**: Usa `data/snippets.json` para manejo robusto de texto multilínea y caracteres especiales.
- **Pegado Instantáneo**: Usa inyección de portapapeles para inserción instantánea de bloques grandes de texto.

**Keymaps (Leader + i):**
- `m`: **Gestor de Snippets** (GUI)
- `a`: **Agregar desde Portapapeles**
- `e`: Insertar Email
- `p`: Insertar Teléfono
- `s`: Insertar Firma (Ejemplo multilínea)

---

## 🐙 Git Actions (`git_actions.ahk`)

Comandos Git esenciales para tu flujo de trabajo.

**Características Principales:**
- **Consciente del Contexto**: Detecta si la carpeta actual es un repositorio git.
- **Retroalimentación Visual**: Muestra salida de comandos en tooltips.

**Keymaps (Leader + g):**
- `s`: Status
- `p`: Push
- `c`: Commit (con entrada)
- `l`: Log

---

## 🦥 LazyGit Actions (`lazygit_actions.ahk`)

> [!WARNING]
> **DEPENDENCIA REQUERIDA:**
> - **`git_actions.ahk`** - Provee la función `RunGitCommand()`
> 
> **Instalá git_actions.ahk primero**, o este plugin fallará.

Integración con LazyGit TUI (Interfaz de Usuario de Terminal) para Git.

**Características Principales:**
- **Lanzador de LazyGit**: Abre LazyGit en el contexto del directorio actual.
- **Integración con Terminal**: Usa Windows Terminal o alternativa a CMD.
- **Detección de Contexto**: Detecta automáticamente el contexto del repositorio git.

**Keymaps (Leader + g):**
- `g`: **Abrir LazyGit** (En directorio actual)

---

## 🚀 Shell Shortcuts (`shell_shortcuts.ahk`)

Lanzadores rápidos para tus aplicaciones favoritas.

**Características Principales:**
- Atajos simples de una línea usando la API Core `ShellExec`.
- Fácil de personalizar para tus propias apps.

**Keymaps (Leader + p):**
- `c`: Chrome
- `v`: VS Code
- `t`: Terminal
- `n`: Bloc de Notas

---

## 📊 System Monitoring (`monitoring_actions.ahk`)

Scripts para vigilar el rendimiento del sistema.

**Características Principales:**
- **Procesos Top**: Muestra uso de CPU/RAM de las apps principales.
- **Estadísticas del Sistema**: Vista rápida de recursos del sistema.

**Keymaps (Leader + m):**
- `t`: Procesos Top
- `s`: Estadísticas del Sistema

---

## 🌐 Network Actions (`network_actions.ahk`)

Diagnósticos de red rápidos y herramientas.

**Keymaps (Leader + n):**
- `p`: Ping a Google
- `f`: Vaciar DNS
- `i`: Mostrar Configuración IP

---

## 🕒 Timestamp Actions (`timestamp_actions.ahk`)

Inserta fecha y hora actual en varios formatos.

**Keymaps (Leader + t):**
- `d`: Fecha (YYYY-MM-DD)
- `t`: Hora (HH:mm)
- `f`: Completo (YYYY-MM-DD HH:mm:ss)
- `u`: Timestamp Unix

---

## 💎 VaultFlow Actions (`vaultflow_actions.ahk`)

Integración con VaultFlow (flujo de trabajo de Obsidian).

**Keymaps (Leader + v):**
- `v`: **Menú VaultFlow** (CLI interactivo)
- `c`: **Commit** (Mensaje personalizado)
- `l`: **Log** (Ver historial)
- `s`: **Status** (Verificar cambios)

---

## 📜 Scroll Actions (`scroll_actions.ahk`)

Implementa una **Capa de Scroll** dedicada para navegación sin mantener teclas modificadoras.

**Características Principales:**
- **Capa de Scroll**: Un modo persistente donde las teclas `h/j/k/l` se convierten en controles de scroll.
- **Retroalimentación Visual**: Muestra un indicador de estado (color `#E6C07B`) cuando está activo.
- **Navegación Estilo Vim**: Usa teclas Vim estándar para hacer scroll.

**Keymaps:**
- **Entrar a Capa**: `Leader + s`
- **Salir de Capa**: `s` o `Escape`

**Controles de Capa (Activos solo en Modo Scroll):**
- `k` / `j`: Scroll Arriba / Abajo
- `h` / `l`: Scroll Izquierda / Derecha

---

## ⚙️ System Actions (`system_actions.ahk`)

Utilidades del sistema y herramientas de acceso rápido.

**Características Principales:**
- **Administrador de Tareas**: Lanzamiento rápido del Administrador de Tareas de Windows.
- **Info del Sistema**: Muestra información del sistema.
- **Editor de Registro**: Acceso rápido a regedit.
- **Gestor de Servicios**: Abre Servicios de Windows.

**Keymaps (Leader + y):**
- `t`: **Administrador de Tareas**
- `s`: **Info del Sistema**
- `r`: **Editor de Registro**
- `v`: **Gestor de Servicios**

---

## 🎯 Vim Actions (`vim_actions.ahk`)

Integración con editores Vim/Neovim.

**Características Principales:**
- **Lanzamiento Rápido**: Abre Vim o Neovim con conciencia de contexto.
- **Apertura de Archivos**: Abre el archivo actual en Vim.
- **Integración con Terminal**: Lanza Vim en modo terminal o GUI.

**Keymaps (Leader + v):**
- `v`: **Abrir Vim** (GUI o Terminal)
- `e`: **Editar Archivo Actual** (En Vim)

---

## 🪟 Windows Manager (`windows_manager.ahk`)

Sistema integral de gestión y navegación de ventanas.

**Características Principales:**
- **Listado Inteligente de Ventanas**: Usa Vista de Tareas (Win+Tab) con navegación estilo Vim (hjkl).
- **Gestión de Pestañas**: Interfaz unificada para cerrar/crear pestañas en navegadores y editores.
- **Seguridad**: Diálogos de confirmación para operaciones destructivas.

**Keymaps (Leader + w):**
- `d`: **Cerrar Ventana** (Cierre Nativo)
- `m`: **Alternar Minimizar/Restaurar**
- `M`: **Forzar Minimizar**
- `l`: **Listar Ventanas** (Vista de Tareas con navegación)
- `H`: **Ventana Anterior**
- `L`: **Ventana Siguiente**
- `b`: **Submenú Gestor de Pestañas**
  - `d`: Cerrar Pestaña
  - `n`: Nueva Pestaña

---

## 📝 Creando Tus Propios Plugins

Puedes usar estos archivos como plantillas para crear tus propios plugins. Consulta [Arquitectura de Plugins](../es/guia-desarrollador/arquitectura-plugins.md) para detalles técnicos.

### Inicio Rápido: Tu Primer Plugin

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
