# 🚀 Guía de Inicio Rápido

¡Pon HybridCapslock en funcionamiento en 5 minutos!

---

## Prerequisitos

- **Windows 10/11** (64-bit recomendado)
- **AutoHotkey v2.0+** - [Descargar aquí](https://www.autohotkey.com/)
- **Kanata** - [Descargar aquí](https://github.com/jtroo/kanata/releases)
- Conocimiento básico de atajos de teclado

---

## 📦 Instalación

### Paso 1: Instalar AutoHotkey v2

1. Descarga AutoHotkey v2.0+ desde [autohotkey.com](https://www.autohotkey.com/)
2. Ejecuta el instalador
3. Verifica la instalación: Abre el Símbolo del Sistema y escribe `autohotkey --version`

### Paso 2: Instalar Kanata

1. Descarga la última versión de Kanata para Windows
2. Extrae `kanata.exe` a una ubicación permanente (ej: `C:\Program Files\Kanata\`)
3. Anota la ruta - la necesitarás para la configuración

### Paso 3: Clonar HybridCapslock

```bash
git clone https://github.com/yourusername/HybridCapslock.git
cd HybridCapslock
```

O descarga como ZIP y extrae.

### Paso 4: Configurar la Ruta de Kanata

Edita `config/settings.ahk` y establece la ruta de Kanata:

```ahk
; Ruta al ejecutable de Kanata
global KanataPath := "C:\Program Files\Kanata\kanata.exe"
```

---

## ▶️ Primer Lanzamiento

### Opción 1: Doble Clic (Más Fácil)

1. Haz doble clic en `HybridCapslock.ahk` en el directorio raíz
2. Deberías ver aparecer un ícono en la bandeja del sistema
3. Kanata se iniciará automáticamente en segundo plano

### Opción 2: Línea de Comandos

```bash
autohotkey HybridCapslock.ahk
```

---

## ✅ Verificar que Funciona

### Probar Homerow Mods

1. Abre cualquier editor de texto (Bloc de notas, VS Code, etc.)
2. **Mantén presionada la tecla `a`** (debería actuar como Alt)
3. **Mantén presionada la tecla `s`** (debería actuar como Shift)
4. **Mantén presionada la tecla `d`** (debería actuar como Ctrl)
5. **Mantén presionada la tecla `f`** (debería actuar como Win)

Si las teclas funcionan normalmente al **presionarlas** pero actúan como modificadores al **mantenerlas**, ¡está funcionando! ✨

### Probar Capa Nvim

1. Presiona **BloqMayús** para entrar a la capa Nvim
2. Presiona `h/j/k/l` para mover el cursor (izquierda/abajo/arriba/derecha)
3. Deberías ver un tooltip mostrando "Capa NVIM Activa"
4. Presiona **BloqMayús** nuevamente para salir

---

## 🎮 Atajos Esenciales

### Atajos Globales

| Atajo | Acción |
|----------|--------|
| `BloqMayús` | Activar/desactivar Capa Nvim (navegación Vim) |
| `Espacio + Espacio` | Modo Líder (mostrar todos los comandos) |
| `Ctrl+Alt+R` | Recargar HybridCapslock |
| `Ctrl+Alt+K` | Reiniciar Kanata |

### Homerow Mods (al mantener presionado)

| Tecla | Modificador |
|-----|----------|
| `a` | Alt |
| `s` | Shift |
| `d` | Ctrl |
| `f` | Win |
| `j` | Win |
| `k` | Ctrl |
| `l` | Shift |
| `;` | Alt |

### Capa Nvim (BloqMayús activo)

| Tecla | Acción |
|-----|--------|
| `h` | Izquierda |
| `j` | Abajo |
| `k` | Arriba |
| `l` | Derecha |
| `w` | Siguiente palabra |
| `b` | Palabra anterior |
| `0` | Inicio de línea |
| `$` | Fin de línea |

---

## 🔧 Próximos Pasos

### Personaliza tu Configuración

1. **[Guía de Configuración](configuracion.md)** - Aprende sobre todas las opciones
2. **[Homerow Mods](../guia-usuario/homerow-mods.md)** - Domina las teclas modificadoras
3. **[Modo Líder](../guia-usuario/modo-lider.md)** - Descubre atajos poderosos

### Explora las Capas

- **[Capa Nvim](../guia-usuario/capa-nvim.md)** - Navegación estilo Vim
- **[Capa Excel](../guia-usuario/capa-excel.md)** - Impulso de productividad en Excel

### Para Desarrolladores

- **[Crear Nuevas Capas](../guia-desarrollador/crear-capas.md)** - Construye capas personalizadas
- **[Sistema Auto-Loader](../guia-desarrollador/sistema-auto-loader.md)** - Entiende la carga de módulos

---

## 🐛 Solución de Problemas

### Kanata no Inicia

**Problema**: Kanata falla al iniciarse o se cierra inmediatamente.

**Soluciones**:
1. Verifica que `KanataPath` en `config/settings.ahk` sea correcto
2. Comprueba si `../../../config/kanata.kbd` es válido
3. Ejecuta Kanata manualmente: `kanata.exe -c ../../../config/kanata.kbd`
4. Revisa el Visor de Eventos de Windows para errores

### Las Teclas no Funcionan

**Problema**: Los homerow mods o capas no responden.

**Soluciones**:
1. Verifica que AutoHotkey v2 esté instalado (no v1.1)
2. Comprueba si HybridCapslock está ejecutándose (el ícono de bandeja debe ser visible)
3. Recarga: Presiona `Ctrl+Alt+R`
4. Revisa `data/layer_state.ini` - podría estar corrupto

### Problemas de Timing con Homerow Mods

**Problema**: Las teclas se activan muy rápido/lento al mantenerlas.

**Soluciones**:
1. Ajusta el timing en `../../../config/kanata.kbd`:
   ```kbd
   (defsrc
     caps a s d f j k l scln
   )
   (deflayer base
     @cap @a @s @d @f @j @k @l @;
   )
   (defalias
     a (tap-hold 200 150 a lalt)  ; Aumenta el primer número (tiempo de tap)
     s (tap-hold 200 150 s lsft)
     ;; ... ajusta según sea necesario
   )
   ```
2. Experimenta con valores: 150-250ms generalmente funciona bien

### Alto Uso de CPU

**Problema**: AutoHotkey o Kanata usando CPU excesivo.

**Soluciones**:
1. Verifica bucles infinitos en capas personalizadas
2. Deshabilita animaciones de tooltip en `config/settings.ahk`:
   ```ahk
   global EnableTooltips := false
   ```
3. Revisa cambios recientes - podría ser un problema de script personalizado

---

## 📚 Aprende Más

- **[Índice de Documentación Completa](../README.md)**
- **[Referencia de Configuración](configuracion.md)**
- **[Sistema de Debug](../referencia/sistema-debug.md)** - Solución avanzada de problemas

---

## 💡 Consejos para Principiantes

1. **Empieza Pequeño**: No personalices todo de una vez. ¡Domina primero los homerow mods!
2. **Practica Diariamente**: La memoria muscular tarda 1-2 semanas en desarrollarse
3. **Usa Tooltips**: La retroalimentación visual ayuda mientras aprendes
4. **Únete a la Comunidad**: Comparte consejos y obtén ayuda (si está disponible)

---

**¿Listo para personalizar?** → [Guía de Configuración](configuracion.md)

**¿Quieres entender el sistema?** → [Visión General de Arquitectura](../referencia/sistema-declarativo.md)

---

**[🌍 View in English](../../en/getting-started/quick-start.md)** | **[← Volver al Índice](../README.md)**
