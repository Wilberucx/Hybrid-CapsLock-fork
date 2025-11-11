' ==============================
' Start Kanata (Hidden)
' ==============================
' Inicia Kanata sin ventana de consola
' Usa rutas universales detectando automáticamente el usuario y directorios

Dim FSO, WshShell, scriptDir, projectRoot, kanataPath, configPath

Set FSO = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")

' Obtener directorio del proyecto (3 niveles arriba: src/core/kanata -> raíz)
scriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)
projectRoot = FSO.GetParentFolderName(FSO.GetParentFolderName(FSO.GetParentFolderName(scriptDir)))

' Detectar usuario automáticamente
userProfile = WshShell.ExpandEnvironmentStrings("%USERPROFILE%")

' ---- CONFIGURACIÓN DE RUTAS ----

' Opción 1: Kanata en carpeta del usuario (ruta universal)
kanataPath = userProfile & "\kanata\kanata.exe"

' Opción 2: Kanata en el proyecto (descomenta para usar)
' kanataPath = FSO.BuildPath(projectRoot, "kanata.exe")

' Opción 3: Kanata en Program Files (descomenta para usar)
' kanataPath = "C:\Program Files\Kanata\kanata.exe"

' Configuración siempre está en el proyecto
configPath = FSO.BuildPath(projectRoot, "config\kanata.kbd")

' ---- VERIFICACIÓN ----

If Not FSO.FileExists(kanataPath) Then
    MsgBox "ERROR: No se encontró kanata.exe en:" & vbCrLf & kanataPath, vbCritical, "Kanata Launcher"
    WScript.Quit 1
End If

If Not FSO.FileExists(configPath) Then
    MsgBox "ERROR: No se encontró kanata.kbd en:" & vbCrLf & configPath, vbCritical, "Kanata Launcher"
    WScript.Quit 1
End If

' ---- LANZAR KANATA ----
' 0 = Oculto (sin ventana)
' False = No esperar a que termine (continuar inmediatamente)
WshShell.Run Chr(34) & kanataPath & Chr(34) & " --cfg " & Chr(34) & configPath & Chr(34), 0, False

Set WshShell = Nothing
Set FSO = Nothing
