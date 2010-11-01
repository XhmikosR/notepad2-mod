@echo off
setlocal
set WDKBASEDIR=C:\WinDDK\7600.16385.1

set INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk
set LIB=%WDKBASEDIR%\lib\crt\amd64;%WDKBASEDIR%\lib\win7\amd64

md "../Release_x64/obj" >NUL 2>&1
del "../Release_x64/*.exe" >NUL 2>&1
del "../Release_x64/obj/*.obj" >NUL 2>&1
del "../Release_x64/obj/*.pdb" >NUL 2>&1
del "../Release_x64/obj/*.idb" >NUL 2>&1

"%WDKBASEDIR%\bin\x86\amd64\cl.exe" @cl_x64.txt
"%WDKBASEDIR%\bin\x86\rc.exe" /fo"../Release_x64/obj/Notepad2.res" "..\src\Notepad2.rc"
"%WDKBASEDIR%\bin\x86\amd64\link.exe" @link_x64.txt

endlocal
pause