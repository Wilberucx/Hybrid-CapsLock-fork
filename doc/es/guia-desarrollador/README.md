# Guía del Desarrollador - Índice

Bienvenido a la Guía del Desarrollador de HybridCapsLock. Esta documentación te ayudará a entender, extender y contribuir al proyecto.

---

## 📚 Documentación Central

### Arquitectura del Sistema

- **[Arquitectura de Plugins](arquitectura-plugins.md)** - Cómo funciona el sistema de plugins
- **[Sistema Auto-Loader](sistema-auto-loader.md)** - Carga automática e integración de archivos
- **[Índice de Plugins Core](core-plugins-index.md)** - Lista completa de plugins del sistema
- **[Sistema de Keymaps](sistema-keymaps.md)** - Cómo funcionan los keymaps y bindings

### Sistema de Capas

- **[Crear Capas](crear-capas.md)** - Guía para crear capas personalizadas
- **[API: Dynamic Layer](api-dynamic-layer.md)** - API de gestión dinámica de capas

### APIs y Utilidades

- **[API: Context Utils](api-context-utils.md)** - Helpers de contexto de ventana/aplicación
- **[API: Hybrid Actions](api-hybrid-actions.md)** - API de acciones híbridas de teclas
- **[API: Notification](api-notification.md)** - API del sistema de notificaciones
- **[API: Shell Exec](api-shell-exec.md)** - API de ejecución de comandos shell
- **[Protocolo API Tooltip](Protocolo_Api_Tooltip.md)** - Protocolo de comunicación con Tooltip C#

---

## 🛡️ Mejores Prácticas

### **[Patrones de Programación Defensiva](patrones-programacion-defensiva.md)** ⭐

**Lectura esencial para todos los desarrolladores.** Aprende patrones críticos para evitar crashes y race conditions:

- Acceso seguro a configuración con fallback
- Validación de propiedades de objetos
- Mejores prácticas de lazy loading
- Prevención de race conditions
- Ejemplos del mundo real y checklists

**Por qué importa:** Previene crashes de inicialización y asegura código robusto.

---

## 🚀 Inicio Rápido para Contribuidores

1. **Lee:** [Arquitectura de Plugins](arquitectura-plugins.md)
2. **Lee:** [Patrones de Programación Defensiva](patrones-programacion-defensiva.md) ⚠️ **CRÍTICO**
3. **Aprende:** [Sistema de Keymaps](sistema-keymaps.md)
4. **Explora:** [Índice de Plugins Core](core-plugins-index.md)
5. **Construye:** [Crear Capas](crear-capas.md)

---

## 📖 Recursos Adicionales

- **Guía de Usuario:** `../guia-usuario/`
- **Ejemplos de Plugins:** `doc/plugins/`
- **Configs de Kanata:** `doc/kanata-configs/`
- **AI Sessions:** `.ai-sessions/` (historial de desarrollo y fixes)

---

## 🐛 Solución de Problemas

### Problemas Comunes

**¿Errores de inicialización de config?**  
→ Ver [Patrones de Programación Defensiva](patrones-programacion-defensiva.md) - Patrón 1

**¿Race conditions al iniciar?**  
→ Ver [Patrones de Programación Defensiva](patrones-programacion-defensiva.md) - Patrón 6

**¿Crashes de propiedades de objetos?**  
→ Ver [Patrones de Programación Defensiva](patrones-programacion-defensiva.md) - Patrón 2

---

## 📝 Flujo de Desarrollo

1. **Planificar** - Documenta tus cambios
2. **Codear** - Sigue patrones defensivos
3. **Testear** - Cold start + Reload + Casos extremos
4. **Documentar** - Actualiza docs relevantes
5. **Commit** - Mensajes de commit claros

---

## 🤝 Contribuir

Antes de enviar PRs:

- [ ] Lee [Patrones de Programación Defensiva](patrones-programacion-defensiva.md)
- [ ] Prueba en cold start (sin reload)
- [ ] Prueba con configs incompletos
- [ ] Actualiza la documentación
- [ ] Sigue las convenciones de estilo del código

---

**¡Feliz Código!** 🚀
