# Custom Commands y CommandFlag

Objetivo: permitir definir comandos reutilizables (qué ejecutar) y, por separado, sus banderas/entorno de ejecución (cómo ejecutarlos), ubicables en cualquier categoría (nueva o existente), sin duplicar confirmaciones.

Resumen del esquema
- [CustomCommands] — qué ejecutar (shell + payload)
- [CommandFlag.<Nombre>] — cómo ejecutarlo (terminal, admin, working_dir, env, etc.)
- [CustomVars] — variables globales opcionales para placeholders
- [<catKey>_category] — UI del menú (título, order, labels). Cada tecla puede apuntar a una acción con k_action=@Nombre o inline tipo:payload
- Confirmación — siempre por la jerarquía actual (global/categoría/per-key); no se define en CommandFlag

1) Catálogo: [CustomCommands]
- Formato: Nombre=tipo:payload
- Tipos soportados: cmd | ps | pwsh | wsl | wt | url

Ejemplos:
```
[CustomCommands]
GitStatus=cmd:git status
SignOut=ps:shutdown.exe -l
OpenDocs=url:https://mi-sitio/docs
```

2) Banderas por comando: [CommandFlag.<Nombre>]
- Define el “cómo” sin tocar el payload (sin confirm aquí)
- Claves soportadas:
  - terminal=hidden|conhost|wt
  - keep_open=true|false
  - admin=true|false
  - working_dir=C:\ruta\proyecto
  - env=NAME1=VAL1;NAME2=VAL2
  - timeout=0            ; 0 = no esperar
  - wt_shell=cmd|ps|pwsh ; si terminal=wt

Ejemplos:
```
[CommandFlag.GitStatus]
terminal=conhost
keep_open=true
working_dir=%USERPROFILE%\projects\acme
env=GIT_PAGER=cat

[CommandFlag.SignOut]
terminal=hidden
admin=false
```

3) Variables globales opcionales: [CustomVars]
- Permiten placeholders amigables en payloads y opciones: {VarName}
- Placeholders predefinidos: {ScriptDir}, {UserProfile}/{Home}, {Clipboard}

Ejemplo:
```
[CustomVars]
Repo=%USERPROFILE%\repos\acme
DocsUrl=https://mi-sitio/docs

[CustomCommands]
GitPush=cmd:git -C "{Repo}" push
OpenDocs=url:{DocsUrl}
```

4) Ubicación en categorías (nuevas o existentes)
- La UI se define en [<catKey>_category]
- Para cada tecla:
  - label: k=Descripción
  - acción: k_action=@Nombre (reutiliza [CustomCommands]) o inline: k_action=tipo:payload

Ejemplo categoría nueva:
```
[Categories]
order=s h g m n f v o t  ; w (Windows) fue integrado en System
t=Tools

[t_category]
title=Tools
order=g o
g=Git Status
g_action=@GitStatus
o=Open Docs
o_action=@OpenDocs
```

5) Confirmación
- NO se configura en CommandFlag
- Se usa la jerarquía actual:
  1) Global: configuration.ini → [Behavior] show_confirmation_global
  2) Categoría: commands.ini → [CategorySettings] <Friendly>_show_confirmation o confirm_keys/no_confirm_keys en [<catKey>_category]
  3) Default de capa → Fallback (power=true, otros=false)

6) Shells: comportamiento sugerido
- cmd: /c (keep_open=false) o /k (keep_open=true)
- ps/pwsh: -Command (o -NoExit si keep_open=true), -NoProfile, ExecutionPolicy Bypass
- wt: abrir nueva pestaña con el shell indicado por wt_shell (cmd/ps/pwsh)
- wsl: ejecutar payload con wsl.exe (opcional bash -lc)
- url: abrir con Run(payload)

7) Buenas prácticas
- Rutas con espacios entre comillas
- En PowerShell, preferir comillas simples internas o escapar dobles
- Probar manualmente payloads en su shell antes de registrarlos

8) Ejemplo completo
```
[CustomVars]
Repo=%USERPROFILE%\projects\acme

[CustomCommands]
GitStatus=cmd:git -C "{Repo}" status
APIConsole=ps:dotnet run --project "{Repo}\\tools\\ApiConsole"

[CommandFlag.GitStatus]
terminal=conhost
keep_open=true

[CommandFlag.APIConsole]
terminal=wt
wt_shell=pwsh
working_dir={Repo}\\tools\\ApiConsole
env=ASPNETCORE_ENVIRONMENT=Development

[t_category]
title=Tools
order=s a
s=Status repo
s_action=@GitStatus
a=API Console
a_action=@APIConsole
; confirmación por categoría si se desea:
; confirm_keys=s
```

9) Migración desde nombres anteriores
- Donde se usaba [CustomCommand.<Nombre>], usar [CommandFlag.<Nombre>].
- Mantener [CustomCommands] (sin cambios).
- Si existieran ambos, CommandFlag.<Nombre> debe prevalecer como la fuente actualizada de banderas.

10) Implementación (estado)
- La UI por categorías ya está implementada
- Lectura/ejecución de k_action y @Nombre + CommandFlag está planificada; se implementará en el handler de categorías con un resolvedor de acciones (sin romper el switch legacy si no hay acción definida).
