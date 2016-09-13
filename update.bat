D:\Games\Steam\steamapps\common\GarrysMod\bin\gmad.exe create -folder %~dp0 -out %~dp0/gma.gma -warninvalid
D:\Games\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe update -id 415143062 -addon %~dp0/gma.gma
D:\Games\Steam\steamapps\common\GarrysMod\bin\gmpublish.exe update -id 415143062 -icon %~dp0/icon.jpg
del gma.gma
pause