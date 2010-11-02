@echo off
setlocal
set WDKBASEDIR=C:\WinDDK\7600.16385.1

set INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk
set LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386

md "..\Release\obj" >NUL 2>&1
del "..\Release\*.exe" >NUL 2>&1
del "..\Release\obj\*.obj" >NUL 2>&1
del "..\Release\obj\*.pdb" >NUL 2>&1
del "..\Release\obj\*.idb" >NUL 2>&1

"%WDKBASEDIR%\bin\x86\x86\cl.exe" @cl.txt
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT
"%WDKBASEDIR%\bin\x86\rc.exe" /fo"../Release/obj/Notepad2.res" "..\src\Notepad2.rc"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT
"%WDKBASEDIR%\bin\x86\x86\link.exe" @link.txt
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT

endlocal
rem pause