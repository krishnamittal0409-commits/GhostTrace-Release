Set oShell = CreateObject("Wscript.Shell")
oShell.Run "powershell.exe -ExecutionPolicy Bypass -WindowStyle Hidden -File """ & Left(WScript.ScriptFullName, InStrRev(WScript.ScriptFullName, "\")) & "license-gui.ps1""", 0, False
