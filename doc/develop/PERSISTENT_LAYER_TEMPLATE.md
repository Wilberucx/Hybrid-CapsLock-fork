# Persistent Layer Template - Documentation

## 🎯 Overview

The **Persistent Layer Template** provides a standardized, reusable foundation for creating new persistent layers (modes) in the Hybrid-CapsLock system. This template eliminates code duplication and ensures consistency across all layers.

---

## 🏗️ Architecture

### **What is a Persistent Layer?**

A persistent layer is a **modal state** that remains active until explicitly exited, similar to Vim's modes:

- **Normal Mode** (Neovim's default state)
- **Insert Mode** (for editing)
- **Visual Mode** (for selection)
- **Excel Mode** (for spreadsheet navigation)
- **Custom Modes** (database, browser, IDE-specific, etc.)

### **Persistent Layers vs Mini-Layers**

| Feature | Persistent Layer | Mini-Layer (Leader Menu) |
|---------|-----------------|-------------------------|
| **Duration** | Stays active until exit key | Temporary (auto-timeout) |
| **Exit** | Explicit key (Esc, Shift+n, etc.) | Timeout or action execution |
| **Example** | Excel, NVIM, Scroll | Leader -> Windows, Leader -> Commands |
| **Use Case** | Extended workflow in single context | Quick action selection |
| **Tooltip** | Persistent status indicator | Menu with options |

---

## 📂 Template Location

```
doc/templates/layer_template.ahk
doc/templates/example_browser_layer.ahk
```

**Templates are located in `doc/templates/` for easy reference and copying.**

---

## 🚀 Quick Start Guide

### **Step 1: Copy Template**

```bash
cp doc/templates/layer_template.ahk src/layer/database_layer.ahk
```

### **Step 2: Configure Layer Name**

Edit the new file and change:

```ahk
; Line 32 in template
LAYER_NAME := "MyLayer"  ; ← CHANGE THIS
```

To:

```ahk
LAYER_NAME := "Database"
```

This automatically generates:
- `DatabaseLayerEnabled`
- `DatabaseLayerActive`
- `DatabaseHelpActive`
- `DatabaseStaticEnabled`

### **Step 3: Define Exit Key**

Choose your exit strategy:

**Option A: Default Escape Key** (already implemented)
```ahk
Esc:: {
    DeactivateMyLayer()
}
```

**Option B: Custom Exit Key** (e.g., Shift+n like Excel)
```ahk
+n:: {  ; Shift+n
    DeactivateMyLayer()
    SetTempStatus("DATABASE LAYER OFF", 1500)
}
```

**Option C: Same-Key Toggle** (press 'd' to enter and exit)
```ahk
d:: {
    ToggleMyLayer()
}
```

**Option D: Multiple Exit Keys**
```ahk
Esc:: DeactivateMyLayer()
q:: DeactivateMyLayer()
^c:: DeactivateMyLayer()
```

### **Step 4: Define Hotkeys**

Add your layer-specific hotkeys in the designated section:

```ahk
; ==============================
; DEFINE YOUR LAYER'S HOTKEYS HERE
; ==============================

; Navigation
h::Send("{Left}")
j::Send("{Down}")
k::Send("{Up}")
l::Send("{Right}")

; Database-specific actions
c::Send("^n")  ; New connection
r::Send("{F5}") ; Refresh
q::RunQueryUnderCursor()
e::ExplainQuery()
t::ShowTables()
```

### **Step 5: Customize Help System**

Update help text to reflect your hotkeys:

```ahk
ShowLayerHelpCS() {
    helpItems := "h/j/k/l:Navigate|c:Connect|r:Refresh|q:Query|e:Explain|t:Tables|?:Help"
    title := "DATABASE HELP"
    footer := "ESC: Close Help"
    ShowCSharpOptionsMenu(title, helpItems, footer)
}
```

### **Step 6: Include in init.ahk**

Add to `init.ahk`:

```ahk
#Include src/layer/database_layer.ahk
```

### **Step 7: Register Activation**

**Option A: Leader Menu Integration**

In `command_system_init.ahk`:

```ahk
RegisterKeymapFlat("leader", "d", "Database Layer", ActivateMyLayer, false, 4)
```

Now accessible via: `<CapsLock+Space> -> d`

**Option B: Standalone Hotkey**

In your layer file or `init.ahk`:

```ahk
F20::ActivateMyLayer()  ; Toggle with F20
```

**Option C: Context-Specific Activation**

```ahk
#HotIf WinActive("ahk_exe DataGrip64.exe")
^!d::ActivateMyLayer()  ; Ctrl+Alt+D in DataGrip
#HotIf
```

---

## 🎨 Configuration Features

### **1. App Filtering (Whitelist/Blacklist)**

Create `config/database_layer.ini`:

```ini
[Settings]
; Only activate in these apps (comma-separated)
whitelist=DataGrip64.exe,ssms.exe,pgAdmin4.exe

; Or block in these apps
blacklist=notepad.exe,chrome.exe
```

The `LayerAppAllowed()` function automatically enforces these rules.

### **2. Dynamic Hotkey Loading (Optional)**

Load hotkeys from config file instead of hardcoding:

```ini
[Normal]
order=1,2,3,4
1=h,Send("{Left}"),Navigate Left
2=j,Send("{Down}"),Navigate Down
3=k,Send("{Up}"),Navigate Up
4=l,Send("{Right}"),Navigate Right
```

Uncomment this section in the template:

```ahk
try {
    global DatabaseMappings
    DatabaseMappings := LoadSimpleMappings(A_ScriptDir . "\\config\\database_layer.ini", "Normal", "order")
    if (DatabaseMappings.Count > 0)
        ApplyGenericMappings("database_normal", DatabaseMappings, (*) => (layerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed()))
} catch {
}
```

---

## 🔍 Template Structure

### **Global Variables**

```ahk
LAYER_NAME := "MyLayer"  ; Your layer name

; Auto-generated globals:
%LAYER_NAME . "LayerEnabled"% := true   ; Feature flag
%LAYER_NAME . "LayerActive"% := false   ; Current state
%LAYER_NAME . "HelpActive"% := false    ; Help menu state
%LAYER_NAME . "StaticEnabled"% := true  ; Static vs dynamic hotkeys
```

### **Activation Functions**

```ahk
ActivateMyLayer()     ; Turn on layer
DeactivateMyLayer()   ; Turn off layer
ToggleMyLayer()       ; Toggle on/off
```

### **Context Conditions**

```ahk
#HotIf (layerStaticEnabled ? (layerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed()) : false)
```

Hotkeys only active when:
- ✅ `layerStaticEnabled` is true (not using dynamic config)
- ✅ `layerActive` is true (layer is on)
- ✅ CapsLock is **not** physically pressed (avoid conflicts with Kanata)
- ✅ `LayerAppAllowed()` returns true (whitelist/blacklist check)

### **Status Display**

```ahk
ShowLayerStatus(isActive)      ; Show ON/OFF status
ShowLayerToggleCS(isActive)    ; C# tooltip version
```

### **Help System**

```ahk
LayerShowHelp()      ; Display help menu
LayerCloseHelp()     ; Hide help menu
ShowLayerHelpCS()    ; C# tooltip help
ShowLayerHelpNative() ; Fallback native tooltip
```

---

## 🎓 Advanced Features

### **Sub-Modes (Mini-Layers Within Layer)**

Create temporary modes within your persistent layer:

```ahk
global VisualModeActive := false

; Entry hotkey (InputLevel 1)
#HotIf (layerActive && !VisualModeActive)
v:: {
    global VisualModeActive
    VisualModeActive := true
    ShowVisualModeStatus(true)
}
#HotIf

; Sub-mode hotkeys (InputLevel 2)
#InputLevel 2
#HotIf (layerActive && VisualModeActive)
h::Send("+{Left}")   ; Select left
j::Send("+{Down}")   ; Select down
y::Send("^c"), VisualModeActive := false  ; Copy and exit
Esc:: {
    global VisualModeActive
    VisualModeActive := false
    ShowVisualModeStatus(false)
}
#HotIf
#InputLevel 1
```

**Real Examples:**
- **Excel Layer**: `vr` (select row), `vc` (select column), `vv` (visual mode)
- **NVIM Layer**: `v` (visual mode), `:` (command mode), `g` (go mode)

### **Timeout Logic**

Add timeout for sub-modes:

```ahk
SubModeStart() {
    global SubModeActive
    SubModeActive := true
    to := GetEffectiveTimeout("myLayer")
    SetTimer(SubModeTimeout, -to * 1000)
}

SubModeTimeout() {
    global SubModeActive
    SubModeActive := false
    ShowStatus("Timeout")
}
```

### **Directional Send with Modifiers**

Handle Ctrl/Shift/Alt modifiers intelligently:

```ahk
MyLayerDirectionalSend(dir) {
    mods := ""
    if GetKeyState("Ctrl", "P")
        mods .= "^"
    if GetKeyState("Alt", "P")
        mods .= "!"
    if GetKeyState("Shift", "P")
        mods .= "+"
    
    ; In selection mode, force Shift
    if (SelectionModeActive && !InStr(mods, "+"))
        mods .= "+"
    
    Send(mods . "{" . dir . "}")
}
```

---

## 📋 Complete Example: Browser Layer

```ahk
; ==============================
; Browser Navigation Layer
; ==============================

LAYER_NAME := "Browser"

global BrowserLayerEnabled := true
global BrowserLayerActive := false
global BrowserHelpActive := false
global BrowserStaticEnabled := true

ActivateBrowserLayer() {
    global BrowserLayerActive
    BrowserLayerActive := true
    ShowLayerStatus(true)
}

DeactivateBrowserLayer() {
    global BrowserLayerActive
    BrowserLayerActive := false
    ShowLayerStatus(false)
}

#InputLevel 1
#HotIf (BrowserStaticEnabled ? (BrowserLayerActive && !GetKeyState("CapsLock", "P") && LayerAppAllowed()) : false)

; Navigation
h::Send("!{Left}")      ; Back
l::Send("!{Right}")     ; Forward
j::Send("{WheelDown}")  ; Scroll down
k::Send("{WheelUp}")    ; Scroll up

; Tabs
t::Send("^t")           ; New tab
w::Send("^w")           ; Close tab
[::Send("^+{Tab}")      ; Previous tab
]::Send("^{Tab}")       ; Next tab

; Actions
r::Send("^r")           ; Reload
f::Send("^f")           ; Find
u::Send("^l")           ; URL bar
d::Send("^d")           ; Bookmark

; Exit with Esc
Esc:: {
    DeactivateBrowserLayer()
    SetTempStatus("BROWSER LAYER OFF", 1500)
}

; Help
?:: (BrowserHelpActive ? LayerCloseHelp() : LayerShowHelp())

#HotIf

; Help Functions
LayerShowHelp() {
    global BrowserHelpActive
    BrowserHelpActive := true
    helpItems := "h:Back|l:Forward|j:Down|k:Up|t:New Tab|w:Close Tab|r:Reload|f:Find|?:Help"
    ShowCSharpOptionsMenu("BROWSER HELP", helpItems, "ESC: Close")
    SetTimer(LayerHelpAutoClose, -8000)
}

LayerHelpAutoClose() {
    if (BrowserHelpActive)
        LayerCloseHelp()
}

LayerCloseHelp() {
    global BrowserHelpActive
    BrowserHelpActive := false
    try HideCSharpTooltip()
    if (BrowserLayerActive)
        ShowLayerStatus(true)
}

ShowLayerStatus(isActive) {
    if (IsSet(tooltipConfig) && tooltipConfig.enabled) {
        title := isActive ? "BROWSER ON" : "BROWSER OFF"
        msg := isActive ? "Press ? for help" : ""
        ShowCSharpStatusNotification(title, msg)
    } else {
        ToolTip(isActive ? "BROWSER LAYER ON" : "BROWSER LAYER OFF")
        SetTimer(() => ToolTip(), -1200)
    }
}

LayerAppAllowed() {
    try {
        ini := A_ScriptDir . "\\config\\browser_layer.ini"
        wl := IniRead(ini, "Settings", "whitelist", "")
        bl := IniRead(ini, "Settings", "blacklist", "")
        proc := WinGetProcessName("A")
        if (bl != "" && InStr("," . StrLower(bl) . ",", "," . StrLower(proc) . ","))
            return false
        if (wl = "")
            return true
        return InStr("," . StrLower(wl) . ",", "," . StrLower(proc) . ",")
    } catch {
        return true
    }
}
```

**Config file** (`config/browser_layer.ini`):

```ini
[Settings]
whitelist=chrome.exe,firefox.exe,msedge.exe,brave.exe
```

**Registration** (in `command_system_init.ahk`):

```ahk
RegisterKeymapFlat("leader", "b", "Browser Layer", ActivateBrowserLayer, false, 5)
```

---

## 🎯 Design Patterns

### **Pattern 1: Same-Key Toggle**

Layer activates and deactivates with same key:

```ahk
s:: {
    global ScrollLayerActive
    ScrollLayerActive := !ScrollLayerActive
    ShowLayerStatus(ScrollLayerActive)
}
```

**Use Case:** Scroll layer, translation layer, mouse mode

### **Pattern 2: Explicit Exit Key**

Different key for entry vs exit:

```ahk
; Entry: <Leader> -> e (from leader menu)
; Exit: Shift+n
+n:: {
    DeactivateMyLayer()
}
```

**Use Case:** Excel layer (exit conflicts with editing)

### **Pattern 3: Multiple Exit Options**

Provide flexibility:

```ahk
Esc:: ExitLayer()
q:: ExitLayer()
^c:: ExitLayer()
```

**Use Case:** Complex layers with different exit contexts

### **Pattern 4: Conditional Exit**

Exit only in certain states:

```ahk
Esc:: {
    global SubModeActive
    if (SubModeActive) {
        SubModeActive := false
        return
    }
    DeactivateMyLayer()
}
```

**Use Case:** Nested modes (exit sub-mode first, then layer)

---

## 🔧 Checklist for Creating New Layer

- [ ] Copy `doc/templates/layer_template.ahk` to `src/layer/my_layer.ahk`
- [ ] Change `LAYER_NAME` variable
- [ ] Define layer hotkeys
- [ ] Configure exit key strategy
- [ ] Update help text
- [ ] Include file in `init.ahk`
- [ ] Register activation (leader menu or hotkey)
- [ ] Create optional config file (`config/my_layer.ini`)
- [ ] Test activation
- [ ] Test all hotkeys
- [ ] Test exit mechanism
- [ ] Test help system
- [ ] Test whitelist/blacklist (if configured)
- [ ] Document layer in user docs (optional)

---

## 📊 Comparison with Existing Layers

| Layer | Exit Key | Special Features | Config File |
|-------|----------|------------------|-------------|
| **Excel** | `Shift+n` | VV mode (visual), VR (row), VC (column) | `excel_layer.ini` |
| **NVIM** | `F23` (toggle) | Visual mode, Insert mode, Command mode (`:`) | `nvim_layer.ini` |
| **Scroll** | `s` (same-key) | Simple hjkl scrolling | None |
| **Template** | `Esc` (configurable) | Help system, app filtering, sub-mode support | Optional |

---

## 🚀 Benefits of Using Template

### **For Developers**
- ✅ **Consistency**: All layers follow same structure
- ✅ **Less boilerplate**: Copy and customize instead of writing from scratch
- ✅ **Best practices**: Built-in help system, status display, app filtering
- ✅ **Maintainability**: Updates to template propagate to all layers

### **For Users**
- ✅ **Predictability**: All layers behave similarly
- ✅ **Discoverability**: Help system always accessible with `?`
- ✅ **Flexibility**: Exit keys customizable per layer
- ✅ **Performance**: Efficient context-based activation

---

## 📚 Related Documentation

- **GENERIC_ROUTER_ARCHITECTURE.md** - Leader menu system
- **LAYERS_CONCEPT.md** - Understanding layers vs mini-layers (if exists)
- **COMMAND_LAYER.md** - User-facing documentation
- **Excel Layer** - Example of complex persistent layer with sub-modes
- **NVIM Layer** - Example of mode system with Insert/Visual/Command modes

---

## 🎉 Conclusion

The Persistent Layer Template provides a **professional-grade** foundation for creating new layers with:

- 🎯 **Configurable exit keys** (Esc, Shift+n, same-key toggle, etc.)
- 🔧 **App filtering** (whitelist/blacklist)
- 📖 **Built-in help system** (C# tooltips + native fallback)
- 🎨 **Sub-mode support** (nested mini-layers)
- ⚙️ **Dynamic config loading** (optional)
- 🔄 **Consistent activation** (leader menu or standalone hotkey)

**Start creating your custom layers today!** 🚀
