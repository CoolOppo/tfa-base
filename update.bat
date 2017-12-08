..\..\..\bin\gmad.exe create -out C:\gma.gma -warninvalid -folder "%~dp0
..\..\..\bin\gmpublish.exe update -id 415143062 -addon "C:\gma.gma"
..\..\..\bin\gmpublish.exe update -id 415143062 -icon "%~dp0/icon.jpg"
del C:\gma.gma
pause