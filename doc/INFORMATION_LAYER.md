# Capa de Information (Líder: leader → `i`)

> Referencia rápida
> - Configuración: config/information.ini
> - Confirmaciones: ver “Confirmaciones — Modelo de Configuración” en doc/CONFIGURATION.md y la sección "Developers — Confirmation configuration (Information)" en doc/CONFIGURATION.md
> - Tooltips (C#): sección [Tooltips] en config/configuration.ini (CONFIGURATION.md)

La Capa de Information proporciona inserción rápida de información personal, datos comunes y snippets personalizados para evitar escribir repetidamente la misma información.

## 🎯 Cómo Acceder

1. **Activa el Líder:** Presiona `leader`
2. **Entra en Capa Information:** Presiona `i`
3. **Selecciona información:** Presiona la tecla del dato que quieres insertar

## 🎮 Navegación

- **`Esc`** - Salir completamente del modo líder
- **`Backspace`** - Volver al menú líder principal
- **Timeout:** 10 segundos de inactividad cierra automáticamente

## 📝 Información Disponible (Configuración por Defecto)

### 👤 Información Personal
| Tecla | Información | Descripción |
|-------|-------------|-------------|
| `e` | **Email** | Dirección de correo electrónico |
| `n` | **Name** | Nombre completo |
| `p` | **Phone** | Número de teléfono |
| `a` | **Address** | Dirección física completa |

### 🏢 Información Profesional
| Tecla | Información | Descripción |
|-------|-------------|-------------|
| `c` | **Company** | Nombre de la empresa |
| `w` | **Website** | Sitio web personal o profesional |
| `g` | **GitHub** | Perfil de GitHub |
| `l` | **LinkedIn** | Perfil de LinkedIn |

**Navegación:** `leader → i → [tecla de información]`

## ⚙️ Configuración Personalizada

### 📁 Archivo de Configuración: `information.ini`

La capa de información es completamente configurable editando el archivo `information.ini`:

```ini
[PersonalInfo]
; Tu información personal
Email=tu.email@ejemplo.com
Name=Tu Nombre Completo
Phone=+1-555-123-4567
Address=123 Calle Principal, Ciudad, Estado 12345

[InfoMapping]
; Mapeo de teclas a información
key_e=Email
key_n=Name
key_p=Phone
key_a=Address

[MenuDisplay]
; Líneas del tooltip
line1=e - Email          n - Name
line2=p - Phone          a - Address
```

### 🔧 Añadir Nueva Información

1. **Agregar la información en `[PersonalInfo]`:**
   ```ini
   Signature=Saludos cordiales,\nTu Nombre\nTu Cargo\nTu Empresa
   ```

2. **Mapear una tecla en `[InfoMapping]`:**
   ```ini
   key_s=Signature
   ```

3. **Actualizar el menú en `[MenuDisplay]`:**
   ```ini
   line3=s - Signature
   ```

### 📝 Tipos de Información Soportados

#### 📧 Información de Contacto
- **Email personal/profesional**
- **Números de teléfono**
- **Direcciones físicas**
- **Códigos postales**

#### 🌐 Información Digital
- **URLs de sitios web**
- **Perfiles de redes sociales**
- **Nombres de usuario**
- **Identificadores únicos**

#### 📄 Snippets de Texto
- **Firmas de email**
- **Frases comunes**
- **Plantillas de respuesta**
- **Información legal/copyright**

## 🎨 Características Avanzadas

### ✅ Inserción Inteligente
- **SendRaw:** Inserta texto exactamente como está configurado
- **Soporte multilínea:** Usa `\n` para saltos de línea
- **Caracteres especiales:** Soporta acentos, símbolos y emojis
- **Feedback visual:** Confirma la inserción con tooltip

### 🔄 Manejo de Errores
- **Información no encontrada:** Muestra mensaje de error específico
- **Tecla no mapeada:** Indica cómo agregar el mapeo
- **Archivo faltante:** Guía para crear la configuración

### ⚡ Optimizaciones
- **Carga dinámica:** Lee la configuración en tiempo real
- **Sin reinicio:** Los cambios en `information.ini` se aplican inmediatamente
- **Memoria eficiente:** Solo carga la configuración cuando se necesita

## 📊 Ejemplos de Configuración

### 🏠 Configuración Personal
```ini
[PersonalInfo]
Email=juan.perez@gmail.com
Name=Juan Pérez
Phone=+34-666-123-456
Address=Calle Mayor 123, 28001 Madrid, España
GitHub=https://github.com/juanperez
LinkedIn=https://linkedin.com/in/juan-perez

[InfoMapping]
key_e=Email
key_n=Name
key_p=Phone
key_a=Address
key_g=GitHub
key_l=LinkedIn
```

### 🏢 Configuración Empresarial
```ini
[PersonalInfo]
WorkEmail=juan.perez@empresa.com
PersonalEmail=juan@gmail.com
CompanyName=Empresa Tecnológica S.L.
Position=Desarrollador Senior
Signature=Saludos cordiales,\nJuan Pérez\nDesarrollador Senior\nEmpresa Tecnológica S.L.\n+34-666-123-456

[InfoMapping]
key_w=WorkEmail
key_p=PersonalEmail
key_c=CompanyName
key_o=Position
key_s=Signature
```

### 🔧 Configuración de Desarrollador
```ini
[PersonalInfo]
Email=dev@ejemplo.com
GitHub=https://github.com/miusuario
Portfolio=https://miportfolio.dev
License=MIT License - Copyright (c) 2024 Mi Nombre
CodeSignature=// Autor: Mi Nombre\n// Email: dev@ejemplo.com\n// Fecha: 

[InfoMapping]
key_e=Email
key_g=GitHub
key_p=Portfolio
key_l=License
key_c=CodeSignature
```

## 🚀 Casos de Uso Comunes

### 📧 Formularios Web
- **Registro rápido** en sitios web
- **Información de contacto** en formularios
- **Datos de facturación** para compras online

### 💼 Comunicación Profesional
- **Firmas de email** consistentes
- **Información de contacto** en documentos
- **Datos de empresa** en propuestas

### 👨‍💻 Desarrollo
- **Headers de código** con información del autor
- **Licencias** en proyectos
- **URLs de repositorios** frecuentes

## 🔧 Consejos de Uso

### ⌨️ Teclas Recomendadas
- **`e`** - Email (mnemotécnico)
- **`n`** - Name (mnemotécnico)
- **`p`** - Phone (mnemotécnico)
- **`a`** - Address (mnemotécnico)

### 🎯 Mejores Prácticas
1. **Usa teclas mnemotécnicas** para fácil memorización
2. **Agrupa información relacionada** en el menú visual
3. **Mantén máximo 8 elementos** para evitar saturar el tooltip
4. **Usa nombres descriptivos** en la configuración

### 🔒 Consideraciones de Seguridad
- **Información sensible:** Ten cuidado con datos personales
- **Compartir configuración:** Revisa antes de subir a repositorios públicos
- **Backup:** Mantén copias de seguridad de tu configuración

## 🔧 Solución de Problemas

### ❌ Información no se inserta
1. Verifica la configuración en `[PersonalInfo]`
2. Asegúrate de que el nombre coincide exactamente
3. Revisa caracteres especiales o saltos de línea

### ❌ Tecla no responde
1. Verifica el mapeo en `[InfoMapping]`
2. Asegúrate de que el nombre coincide exactamente
3. Revisa que la tecla esté en la lista de Input

### ❌ Menú no se actualiza
1. Verifica la sintaxis en `[MenuDisplay]`
2. Asegúrate de usar `line1`, `line2`, etc.
3. Reinicia el script si es necesario

### ❌ Caracteres especiales no funcionan
1. Usa `SendRaw` para caracteres especiales
2. Verifica la codificación del archivo .ini
3. Prueba con caracteres simples primero

---

**¿Necesitas más información?** Edita `information.ini` y añade tus propios datos siguiendo los ejemplos de esta documentación.