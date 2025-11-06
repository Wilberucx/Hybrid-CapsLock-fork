' ==============================
' Restart Kanata
' ==============================
' Detiene y reinicia Kanata

Dim FSO, WshShell, scriptDir, stopScript, startScript

Set FSO = CreateObject("Scripting.FileSystemObject")
Set WshShell = CreateObject("WScript.Shell")

' Obtener directorio de este script
scriptDir = FSO.GetParentFolderName(WScript.ScriptFullName)

' Rutas de los scripts
stopScript = FSO.BuildPath(scriptDir, "stop_kanata.vbs")
startScript = FSO.BuildPath(scriptDir, "start_kanata.vbs")

' ---- DETENER KANATA ----
If FSO.FileExists(stopScript) Then
    WshShell.Run Chr(34) & stopScript & Chr(34), 0, True
    WScript.Sleep 500  ' Esperar medio segundo
End If

' ---- INICIAR KANATA ----
If FSO.FileExists(startScript) Then
    WshShell.Run Chr(34) & startScript & Chr(34), 0, False
Else
    MsgBox "ERROR: No se encontró start_kanata.vbs", vbCritical, "Kanata Restart"
    WScript.Quit 1
End If

Set WshShell = Nothing
Set FSO = Nothing
