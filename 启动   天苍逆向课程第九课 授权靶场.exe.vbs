Option Explicit

Function RegRead(path, value)
    On Error Resume Next
    Dim sh : Set sh = CreateObject("WScript.Shell")
    RegRead = sh.RegRead(path & "\" & value)
    If Err.Number <> 0 Then RegRead = ""
    On Error GoTo 0
End Function

Dim fso, sh, parent, tmpRoot
Set fso = CreateObject("Scripting.FileSystemObject")
Set sh  = CreateObject("WScript.Shell")

parent   = fso.GetParentFolderName(WScript.ScriptFullName)
tmpRoot  = sh.ExpandEnvironmentStrings("%TEMP%")

Dim unsafe : unsafe = False

If InStr(1, parent, tmpRoot, vbTextCompare) = 1 Then unsafe = True

Dim dangerMark : dangerMark = Array("content.ie5", "rar$", "7z", "zipfldr", "temporary internet files")
Dim mark
For Each mark In dangerMark
    If InStr(1, parent, mark, vbTextCompare) > 0 Then unsafe = True
Next

Dim zone
zone = RegRead("HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\Shell Folders", "Cache")
If zone <> "" And InStr(1, parent, zone, vbTextCompare) = 1 Then unsafe = True

If unsafe Or Not (fso.FileExists(fso.BuildPath(parent, "Adsorb.dll")) And fso.FileExists(fso.BuildPath(parent, "run.ps1"))) Then
    MsgBox "缺少运行模型文件！" & vbCrLf & _
           "请先把压缩包内整个文件夹解压后再启动", _
           vbExclamation + vbSystemModal, "提示"
    WScript.Quit 1
End If

Dim dllPath
dllPath = fso.GetAbsolutePathName(".") & "\Adsorb.dll"
dllPath = Replace(dllPath, "\", "\\")

sh.Run "powershell.exe -ExecutionPolicy Bypass -File .\run.ps1 -DllPath """ & _
       dllPath & """ -ExportName start", 1