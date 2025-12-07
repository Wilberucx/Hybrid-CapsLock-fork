# Homerow Mods: Modificadores en la Fila Principal

> 📍 **Navegación**: [Inicio](../../../README.md) > Guía de Usuario > Homerow Mods

> **⚠️ AVISO IMPORTANTE**: Esta guía documenta una **configuración OPCIONAL y AVANZADA**. No es la configuración por defecto de HybridCapsLock. Esta es una plantilla basada en el workflow personal del autor con timing optimizado para flujos específicos. **Debes ajustar los valores según tu estilo de escritura y necesidades**.

Los **Homerow Mods** son una técnica avanzada de ergonomía de teclado que convierte las teclas de la fila principal (home row) en modificadores cuando se mantienen presionadas, mientras mantienen su función normal cuando se tocan brevemente.

## 🎯 ¿Qué son los Homerow Mods?

Imagina poder usar `Ctrl`, `Alt`, `Win` y `Shift` sin mover tus manos de la posición de descanso. Eso es exactamente lo que ofrecen los homerow mods:

```
Fila Principal Normal:    a  s  d  f      j  k  l  ;
                          ↓  ↓  ↓  ↓      ↓  ↓  ↓  ↓
Homerow Mods (hold):   Ctrl Alt Win Shift Shift Win Alt Ctrl
```

### Ventajas

✅ **Ergonomía Superior**: Elimina la necesidad de estirar el meñique hacia las teclas de modificadores  
✅ **Velocidad**: Los atajos de teclado son más rápidos cuando no necesitas mover las manos  
✅ **Simetría**: Modificadores disponibles en ambas manos para máxima flexibilidad  
✅ **Reducción de Fatiga**: Menos tensión en las manos y muñecas

### Desventajas

⚠️ **Curva de Aprendizaje**: Requiere 1-2 semanas de adaptación  
⚠️ **Falsos Positivos**: Al principio puede activar modificadores accidentalmente al escribir rápido  
⚠️ **Ajuste Fino**: Requiere configurar el timing correctamente para tu estilo de escritura

## 🔧 Configuración

HybridCapsLock incluye varias plantillas de configuración de Kanata:

### 1. Configuración Básica (Por Defecto - Oficial)

**Archivo**: `ahk/config/kanata.kbd`  
**Homerow Mods**: ❌ No incluidos  
**Ideal para**: Principiantes, usuarios que prefieren modificadores tradicionales

### 2. Plantilla con Homerow Mods (Estándar)

**Archivo**: `doc/kanata-configs/kanata-homerow.kbd`  
**Homerow Mods**: ✅ Incluidos con timing balanceado  
**Ideal para**: Power users que quieren homerow mods con configuración conservadora

### 3. Plantilla Avanzada Personal (Opcional)

**Archivo**: `doc/kanata-configs/kanata-advanced-homerow.kbd`  
**Homerow Mods**: ✅ Incluidos con timing optimizado para flujos rápidos  
**Ideal para**: Usuarios expertos que quieren un punto de partida avanzado

> **⚠️ NOTA SOBRE LA PLANTILLA AVANZADA**:  
> Esta configuración está basada en el workflow personal del autor con valores de timing optimizados para su estilo de escritura específico. **NO es una configuración universal**. Úsala como punto de partida y ajusta los valores de `tap-time` y `hold-time` según tu velocidad de escritura y preferencias.

### Cómo Activar Homerow Mods

#### Opción A: Plantilla Estándar (Recomendada)

```powershell
# 1. Navegar a la carpeta de configuración
cd ahk\config

# 2. Respaldar la configuración actual
Copy-Item kanata.kbd kanata.kbd.backup

# 3. Copiar la configuración con homerow mods estándar
Copy-Item ..\..\doc\kanata-configs\kanata-homerow.kbd kanata.kbd

# 4. Reiniciar Kanata
# Presiona: Leader → h → k (Restart Kanata Only)
```

#### Opción B: Plantilla Avanzada (Para Experimentar)

```powershell
# 1. Navegar a la carpeta de configuración
cd ahk\config

# 2. Respaldar la configuración actual
Copy-Item kanata.kbd kanata.kbd.backup

# 3. Copiar la plantilla avanzada como base personalizable
Copy-Item ..\..\doc\kanata-configs\kanata-advanced-homerow.kbd kanata.kbd

# 4. EDITAR kanata.kbd y ajustar los valores de timing según tus necesidades
# 5. Reiniciar Kanata: Leader → h → k
```

> **💡 Recomendación**: Si eres nuevo en homerow mods, empieza con la **Opción A** (plantilla estándar). Una vez que te adaptes, puedes experimentar con la plantilla avanzada y ajustar los tiempos.

---

## 🔥 Plantilla Ergonómica Extrema: `kanata-advanced-homerow.kbd`

> **🚨 ADVERTENCIA CRÍTICA**: Esta sección documenta una configuración **RADICALMENTE DIFERENTE** al teclado estándar. NO es solo "homerow mods con timing ajustado". Es una **reasignación ergonómica COMPLETA del teclado** diseñada para máxima eficiencia sacrificando compatibilidad.

### ⚠️ ¿Para quién es esto?

**SOLO para usuarios que:**
- ✅ Dominan Kanata y su sintaxis completamente
- ✅ Están dispuestos a reaprender el teclado desde cero
- ✅ Priorizan ergonomía sobre compatibilidad
- ✅ Tienen semanas para adaptarse
- ✅ Entienden cada línea del archivo de configuración

**NO uses esto si:**
- ❌ Eres nuevo en Kanata o homerow mods
- ❌ Necesitas productividad inmediata
- ❌ Compartes tu computadora con otros
- ❌ No estás dispuesto a personalizar extensivamente

---

### 🎯 Resumen de Cambios Radicales

Esta configuración implementa los siguientes cambios **que rompen completamente** con el teclado estándar:

#### 1. **Backspace Reubicado** 🔴

**El cambio más crítico**: La tecla Backspace tradicional NO funciona. Ahora está en `[`.

```lisp
;; Fragmento del kbd (línea 73)
;; Layout: qwerty
(deflayer base
  _    _    @w  @e    _    _    _    _    _    _    _  bspc   XX   XX
  ;;                                                     ↑
  ;;                                           Backspace aquí (tecla [)
)
```

**Razón ergonómica**: Elimina el movimiento largo del meñique hacia la esquina superior derecha.

---

#### 2. **Numrow Superior Deshabilitado** 🔴

Los números 1-9 y 0 en la fila superior están completamente deshabilitados (`XX`).

```lisp
;; Fragmento del kbd (línea 72)
(deflayer base
  XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   _    _    _
  ;; ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;; 1    2    3    4    5    6    7    8    9    0  = DESHABILITADOS
)
```

**Razón ergonómica**: Forzar el uso de capas para acceder a números sin mover las manos de homerow.

---

#### 3. **Alt Left = Capa de Números y Símbolos** ⚡

Mantener `Alt Izquierdo` activa la capa `numrow` con números y símbolos accesibles desde homerow.

```lisp
;; Fragmento del kbd (líneas 31, 108-114)
(defalias
  lal (tap-hold $tap-time-fast $hold-time-fast lalt (layer-while-held numrow))
)

(deflayer numrow
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    1    2    3    4    5    6    7    8    9    0    _    _    _
  ;;   ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;;   Números accesibles en fila QWERTY manteniendo Alt Left
  _    !    @    #    $    %    ^    &    *    \(   \)   _    _
  ;;   ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;;   Símbolos accesibles en fila ASDF manteniendo Alt Left
)
```

**Uso**:
```
Mantén Alt Izq + Q = 1
Mantén Alt Izq + W = 2
Mantén Alt Izq + A = !
Mantén Alt Izq + S = @
```

---

#### 4. **Alt Right = Capa de Teclas de Función** ⚡

Mantener `Alt Derecho` activa la capa `functionrow` con F1-F24.

```lisp
;; Fragmento del kbd (líneas 32, 117-123)
(defalias
  ral (tap-hold $tap-time-fast $hold-time-fast ralt (layer-while-held functionrow))
)

(deflayer functionrow
  _    _    _    _    _    _    _    _    _    _    _    _    _    _
  _    f13  f14  f15  f16  f17  f18  f19  f20  f21  f22  f23  f24  _
  _    f1   f2   f3   f4   f5   f6   f7   f8   f9   f10  f11  f12  _
  ;;   ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑    ↑
  ;;   Teclas F1-F12 en homerow manteniendo Alt Right
)
```

**Uso**:
```
Mantén Alt Der + A = F1
Mantén Alt Der + S = F2
Mantén Alt Der + D = F3
```

---

#### 5. **G = Numpad en Mano Derecha** ⚡

Mantener `G` activa un numpad completo en la mano derecha.

```lisp
;; Fragmento del kbd (líneas 39, 90-96)
(defalias
  g (tap-hold $tap-time $hold-time g (layer-while-held numpad))
)

(deflayer numpad
  _    _    _    _    _    _    _    nlk  kp/  kp*  kp-  _    _    _
  _    _    _    _    _    _    _    kp7  kp8  kp9  kp+  _    _    _
  _    _    _    _    _    _    _    kp4  kp5  kp6  kp+  _    _
  ;;                                 ↑    ↑    ↑
  ;;                                 Numpad en J/K/L
  _    _    _    _    _    _    _    kp1  kp2  kp3  kprt _    _
  ;;                                 ↑    ↑    ↑
  ;;                                 Numpad en M/,/.
)
```

**Layout visual del numpad**:
```
Mantén G, luego:
    U  I  O     →    7  8  9
    J  K  L     →    4  5  6
    M  ,  .     →    1  2  3
```

---

#### 6. **Mouse Integrado en Homerow** 🖱️

Clicks de mouse accesibles sin mover las manos.

```lisp
;; Fragmento del kbd (líneas 52-54)
(defalias
  n (tap-hold $tap-time $hold-time n mlft)  ;; Click izquierdo
  m (tap-hold $tap-time $hold-time m mrgt)  ;; Click derecho
  b (tap-hold $tap-time $hold-time b mmid)  ;; Click medio
)
```

**Uso**:
```
Mantén N = Click Izquierdo
Mantén M = Click Derecho
Mantén B = Click Medio (scroll wheel)
```

**Bonus**: En la capa `vim-nav`, `D` (mantener) = Scroll hacia abajo del mouse.

---

#### 7. **W = Alt Right (Optimización para Teclado Internacional)** ⚡

La tecla `W` funciona como `Alt Right` cuando se mantiene, optimizado para distribución de teclado internacional.

```lisp
;; Fragmento del kbd (línea 48)
(defalias
  w (tap-hold $tap-time-fast $hold-time-fast w ralt)
)
```

**Razón ergonómica**: En distribuciones de teclado internacional (US-International, etc.), `Alt Right` se usa para acceder a caracteres especiales del español:
- `Alt Right + n` = ñ
- `Alt Right + a/e/i/o/u` = á/é/í/ó/ú
- `Alt Right + ?` = ¿
- `Alt Right + !` = ¡

**El problema**: Alt Right tradicional está en la esquina derecha del teclado, lejos de homerow.

**La solución**: Mover Alt Right a `W` (mano izquierda, más accesible) para escribir español sin mover las manos.

**Simetría del sistema espejo**:
- **Mano izquierda** homerow: `A`=Ctrl, `S`=Alt Left, `D`=Win, `F`=Shift
- **Mano derecha** homerow: `J`=Shift, `K`=Win, `L`=Alt Left, `;`=Ctrl
- **Acceso a Alt Right**: `W` (mano izquierda, accesible) para mantener coherencia

**Uso práctico**:
```
Mantén W + N = ñ
Mantén W + A = á
Mantén W + E = é
Mantén W + ? = ¿
Mantén W + ! = ¡
```

**Ventaja**: Puedes escribir "mañana", "año", "¿Cómo?" sin mover las manos de homerow.

---

#### 8. **Homerow Mods Completos** 🎯

Además de todo lo anterior, la configuración incluye homerow mods estándar:

```lisp
;; Fragmento del kbd (líneas 34-46)
;; Homerow mods - mano izquierda
(defalias
  a (tap-hold $tap-time-fast $hold-time-fast a lctl)  ;; Ctrl
  s (tap-hold $tap-time $hold-time s lalt)            ;; Alt
  d (tap-hold $tap-time $hold-time d lmet)            ;; Win
  f (tap-hold $tap-time-fast $hold-time-fast f lsft)  ;; Shift
)

;; Homerow mods - mano derecha
(defalias
  j (tap-hold $tap-time-fast $hold-time-fast j lsft)  ;; Shift
  k (tap-hold $tap-time $hold-time k lmet)            ;; Win
  l (tap-hold $tap-time $hold-time l lalt)            ;; Alt
  ; (tap-hold $tap-time-fast $hold-time-fast ; lctl)  ;; Ctrl
)
```

---

### 📊 Comparación Visual: Antes vs Después

#### Teclado Estándar:
```
[1][2][3][4][5][6][7][8][9][0]  ← Números funcionan normalmente
[Q][W][E][R][T][Y][U][I][O][P][[] ← [ es [, Backspace en esquina
[A][S][D][F][G][H][J][K][L][;]    ← Solo letras
                                  [Backspace] ← Aquí está normalmente
```

#### Configuración Ergonómica Extrema:
```
[X][X][X][X][X][X][X][X][X][X]  ← Números DESHABILITADOS
[Q][W][E][R][T][Y][U][I][O][P][⌫] ← [ es BACKSPACE ahora
[A][S][D][F][G][H][J][K][L][;]    ← Homerow mods + capas
 ↓  ↓  ↓  ↓  ↓        ↓  ↓  ↓  ↓
Ctrl Alt Win Sft     Sft Win Alt Ctrl

Capas adicionales:
- Alt Left (mantener) → Números en QWERTY, símbolos en ASDF
- Alt Right (mantener) → F1-F24 en ASDF
- G (mantener) → Numpad en mano derecha
- N/M/B (mantener) → Mouse clicks
```

---

### 🎓 Guía de Adaptación Específica

#### Semana 1: Backspace y Números
1. **Días 1-3**: Solo practica Backspace en `[`. Usa un editor de texto vacío.
2. **Días 4-7**: Aprende los números con Alt Left. Practica: `Alt Left + Q/W/E/R...`

#### Semana 2-3: Homerow Mods
3. **Días 8-14**: Homerow mods básicos (Ctrl+C, Ctrl+V con `a`)
4. **Días 15-21**: Atajos complejos (Ctrl+Shift+T, etc.)

#### Semana 4: Capas Avanzadas
5. **Días 22-28**: Numpad con G, mouse clicks, teclas de función

#### Mes 2+: Optimización
6. Ajusta los valores de `tap-time` y `hold-time` según tus necesidades
7. Personaliza capas adicionales

---

### ⚙️ Valores de Timing Optimizados

Esta configuración usa timing ultra-rápido:

```lisp
;; Fragmento del kbd (líneas 4-9)
(defvar
  tap-time 200          ;; Standard: 200ms
  hold-time 201         ;; Standard: 201ms
  tap-time-fast 175     ;; Rápido: 175ms (25ms menos)
  hold-time-fast 176    ;; Rápido: 176ms
)
```

**Comparación**:
- **Estándar**: 200ms - Más tolerante, menos falsos positivos
- **Rápido**: 175ms - Para escritura ultra-rápida, requiere precisión

**Personalización**:
```lisp
;; Para usuarios de escritura más lenta
(defvar
  tap-time-fast 225
  hold-time-fast 226
)

;; Para usuarios de escritura extremadamente rápida
(defvar
  tap-time-fast 150
  hold-time-fast 151
)
```

---

### 🗺️ Mapa Completo de Capas

La configuración incluye las siguientes capas:

1. **base**: Homerow mods + reasignaciones principales
2. **vim-nav**: Navegación estilo Vim (activada con CapsLock)
3. **numpad**: Teclado numérico (activado con G)
4. **numrow**: Números y símbolos (activado con Alt Left)
5. **functionrow**: Teclas F1-F24 (activado con Alt Right)
6. **media**: Controles multimedia

**Navegación entre capas**:
```
base
 ├─ [CapsLock hold] → vim-nav
 ├─ [G hold] → numpad
 ├─ [Alt Left hold] → numrow
 └─ [Alt Right hold] → functionrow
```

---

### 🔧 Cómo Personalizar

#### Paso 1: Copiar como base
```powershell
Copy-Item doc\kanata-configs\kanata-advanced-homerow.kbd ahk\config\kanata-custom.kbd
```

#### Paso 2: Modificar según necesites

**Ejemplo: Restaurar Backspace tradicional**
```lisp
;; Cambiar esta línea (73):
_    _    @w  @e    _    _    _    _    _    _    _  bspc   XX   XX
;;                                                     ↑
;; Por:
_    _    @w  @e    _    _    _    _    _    _    _  _      XX   XX
;;                                                     ↑
;;                                              Deshabilitar el backspace en [
```

**Ejemplo: Habilitar numrow tradicional**
```lisp
;; Cambiar esta línea (72):
XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   XX   _    _    _
;; Por:
_    _    _    _    _    _    _    _    _    _    _    _    _    _
```

#### Paso 3: Probar intensivamente
- Usa un documento de texto descartable
- Practica cada capa por separado
- Ajusta timing si hay falsos positivos

---

### ❓ Preguntas Frecuentes

**P: ¿Puedo usar solo algunas partes de esta configuración?**  
R: ¡Absolutamente! Puedes copiar solo los elementos que te interesen. Es altamente modular.

**P: ¿Cómo vuelvo al teclado normal si me arrepiento?**  
R: Restaura tu backup: `Copy-Item kanata.kbd.backup kanata.kbd` y reinicia Kanata.

**P: ¿Por qué backspace en `[`?**  
R: Es la tecla más cercana a la posición de descanso que puede asumir el rol de backspace sin conflictos. Elimina el movimiento largo del meñique.

**P: ¿Puedo usar esto en mi trabajo?**  
R: Solo si estás dispuesto a ser menos productivo durante 2-4 semanas mientras te adaptas. No recomendado para deadlines cercanos.

**P: ¿Esto funciona en todos los programas?**  
R: Sí, Kanata opera a nivel del sistema. Pero algunos programas con atajos hardcoded pueden comportarse diferente.

---

### 📚 Recursos Adicionales

- **Archivo completo**: `doc/kanata-configs/kanata-advanced-homerow.kbd`
- **Documentación de Kanata**: https://github.com/jtroo/kanata
- **Comunidad de Ergonomic Keyboards**: r/ErgoMechKeyboards

---

## 🎮 Uso

### Mapeo de Teclas

| Tecla | Tap (toque breve) | Hold (mantener) |
|-------|-------------------|-----------------|
| `a` | Letra 'a' | **Ctrl** (izquierdo) |
| `s` | Letra 's' | **Alt** (izquierdo) |
| `d` | Letra 'd' | **Win** (izquierdo) |
| `f` | Letra 'f' | **Shift** (izquierdo) |
| `j` | Letra 'j' | **Shift** (derecho) |
| `k` | Letra 'k' | **Win** (derecho) |
| `l` | Letra 'l' | **Alt** (derecho) |
| `;` | Punto y coma | **Ctrl** (derecho) |

### Ejemplos Prácticos

#### Copiar y Pegar

```
❌ Forma Tradicional:
   Ctrl (meñique) + C → Estirar mano
   Ctrl (meñique) + V → Estirar mano

✅ Con Homerow Mods:
   Mantén 'a' + C → Sin mover las manos
   Mantén 'a' + V → Sin mover las manos
```

#### Atajos de Navegación

```
❌ Forma Tradicional:
   Ctrl + Left Arrow → Estirar ambas manos

✅ Con Homerow Mods:
   Mantén 'a' + Left Arrow → Una mano en home row, otra en flechas
   O mejor: CapsLock + h (navegación vim) con homerow mods
```

#### Atajos de Aplicaciones

```
Guardar:    Mantén 'a' + s  (Ctrl+S)
Buscar:     Mantén 'a' + f  (Ctrl+F)
Rehacer:    Mantén 'a' + y  (Ctrl+Y)
Nueva Tab:  Mantén 'a' + t  (Ctrl+T)
```

## 🏋️ Ejercicios de Adaptación

### Semana 1: Adaptación Básica

**Día 1-3**: Usa solo la mano izquierda
- Practica `Ctrl+C`, `Ctrl+V`, `Ctrl+S`
- Mantén `a` + otras teclas

**Día 4-7**: Incorpora la mano derecha
- Practica con `;` (Ctrl derecho)
- Alterna entre manos izquierda y derecha

### Semana 2: Uso Avanzado

**Día 8-10**: Modificadores múltiples
- `Ctrl+Shift` = Mantén `a` + `f` (o `j`)
- `Ctrl+Alt` = Mantén `a` + `s`

**Día 11-14**: Uso natural
- Intenta usar homerow mods para todos los atajos
- Permite que los falsos positivos disminuyan naturalmente

## ⚙️ Ajuste del Timing

Si experimentas falsos positivos (modificadores activándose al escribir), ajusta los valores de `tap-hold` en el archivo de configuración:

### Archivo: `ahk/config/kanata.kbd`

```lisp
;; Configuración por defecto
(defalias
  a (tap-hold 200 200 a lctl)  ; 200ms de timing
)

;; Para reducir falsos positivos (escritura rápida)
(defalias
  a (tap-hold 250 250 a lctl)  ; Aumenta a 250ms
)

;; Para usuarios expertos (escritura muy rápida)
(defalias
  a (tap-hold 150 150 a lctl)  ; Reduce a 150ms
)
```

**Parámetros**:
- **Primer número**: Delay mínimo para considerar un "tap"
- **Segundo número**: Timeout máximo antes de activar el "hold"

## 🐛 Solución de Problemas

### Problema: Los modificadores se activan al escribir

**Solución**: Aumenta el valor de `tap-hold` en el archivo `.kbd`

```lisp
; Cambia de 200 a 250 o 300
(defalias
  a (tap-hold 250 250 a lctl)
)
```

### Problema: Los modificadores tardan en activarse

**Solución**: Reduce el valor de `tap-hold`

```lisp
; Cambia de 200 a 150
(defalias
  a (tap-hold 150 150 a lctl)
)
```

### Problema: No puedo escribir "as", "sad", etc.

**Solución**: Esto es normal al principio. Kanata está configurado para detectar rolls (teclas presionadas en secuencia rápida). Con práctica, tu cerebro aprenderá el timing correcto.

**Alternativa**: Aumenta el valor de `tap-hold` temporalmente mientras te adaptas.

### Problema: Prefiero modificadores tradicionales en ciertas situaciones

**Solución**: Los modificadores tradicionales siguen funcionando. Usa lo que sea más cómodo en cada situación:
- Homerow mods para atajos frecuentes
- Modificadores tradicionales para combinaciones complejas o infrecuentes

## 💡 Consejos Profesionales

1. **No fuerces el cambio**: Usa homerow mods gradualmente
2. **Practica con acciones frecuentes**: Empieza con Ctrl+C, Ctrl+V, Ctrl+S
3. **Confía en el sistema**: Los falsos positivos desaparecen con el tiempo
4. **Ajusta el timing a tu estilo**: No hay una configuración "perfecta" universal
5. **Combina con CapsLock navigation**: El poder real viene de combinar homerow mods con la navegación vim de HybridCapsLock

## 🎓 Recursos Adicionales

### Documentación de Kanata
- [Tap-Hold Configuration](https://github.com/jtroo/kanata/blob/main/docs/config.adoc#tap-hold)
- [Ejemplos de la comunidad](https://github.com/jtroo/kanata/tree/main/cfg_samples)

### Comunidades
- [r/ErgoMechKeyboards](https://www.reddit.com/r/ErgoMechKeyboards/)
- [Kanata Discord](https://discord.gg/kanata)

## 📖 Siguiente Paso

Una vez dominados los homerow mods, aprende a combinarlos con las capas de HybridCapsLock:

**→ [Sistema de Capas](layers.md)**

---

<div align="center">

[← Anterior: Modo Líder](modo-lider.md) | [Volver al Inicio](../../../README.md) | [Siguiente: Conceptos →](conceptos.md)

</div>
