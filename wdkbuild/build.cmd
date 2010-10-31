@echo off
setlocal
set WDKBASEDIR=C:\progs\WinDDK\7600.16385.1

set INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk
set LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386
set LIBPATH=
set VSCOMNTOOLS=

md "../Release" >NUL 2>&1
del "../Release/*.obj" >NUL 2>&1
del "../Release/*.exe" >NUL 2>&1
del "../Release/*.pdb" >NUL 2>&1
del "../Release/*.idb" >NUL 2>&1

"%WDKBASEDIR%\bin\x86\x86\cl.exe" @cl.txt
"%WDKBASEDIR%\bin\x86\rc.exe" /fo"../Release/Notepad2.res" "..\src\Notepad2.rc"
"%WDKBASEDIR%\bin\x86\x86\link.exe" @link.txt

endlocal
pause