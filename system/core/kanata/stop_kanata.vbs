' ==============================
' Stop Kanata
' ==============================
' Detiene el proceso kanata.exe si está corriendo

Dim objWMIService, colProcesses, objProcess
Dim processName, foundProcess

processName = "kanata.exe"
foundProcess = False

' Conectar al servicio WMI
Set objWMIService = GetObject("winmgmts:\\.\root\cimv2")

' Buscar el proceso
Set colProcesses = objWMIService.ExecQuery("Select * from Win32_Process Where Name = '" & processName & "'")

' Terminar todos los procesos encontrados
For Each objProcess in colProcesses
    objProcess.Terminate()
    foundProcess = True
Next

' Mensaje de confirmación
If foundProcess Then
    ' WScript.Echo "Kanata detenido correctamente"
    WScript.Quit 0
Else
    ' WScript.Echo "Kanata no estaba corriendo"
    WScript.Quit 1
End If

Set colProcesses = Nothing
Set objWMIService = Nothing
