@echo off

rem set WDKBASEDIR=C:\WinDDK\7600.16385.1
set WDKBASEDIR=D:\Programme\Microsoft wdk7

set INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk
set LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386
set LIBPATH=
set VSCOMNTOOLS=

md "../Release"
del "../Release/*.obj"
del "../Release/*.exe"
del "../Release/*.pdb"
del "../Release/*.idb"

"%WDKBASEDIR%\bin\x86\x86\cl.exe" @cl.txt
"%WDKBASEDIR%\bin\x86\rc.exe" /fo"../Release/Notepad2.res" "..\src\Notepad2.rc"
"%WDKBASEDIR%\bin\x86\x86\link.exe" @link.txt
