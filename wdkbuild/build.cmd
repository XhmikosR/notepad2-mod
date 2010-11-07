@echo off
setlocal
set WDKBASEDIR=C:\WinDDK\7600.16385.1

:x86
set INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk
set LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386
set PATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\x86;%PATH%
set OUTDIR=..\Release
set OBJDIR=%OUTDIR%\obj

md "%OBJDIR%" >NUL 2>&1
del "%OUTDIR%\*.exe" >NUL 2>&1
del "%OBJDIR%\*.obj" >NUL 2>&1
del "%OBJDIR%\*.pdb" >NUL 2>&1
del "%OBJDIR%\*.idb" >NUL 2>&1

pushd ..
call update_version.bat
popd

cl -nologo @cl.txt
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&GOTO :end
rc /fo"%OBJDIR%/Notepad2.res" "..\src\Notepad2.rc"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&GOTO :end
link -nologo @link.txt
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&GOTO :end

:x64
set INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk
set LIB=%WDKBASEDIR%\lib\crt\amd64;%WDKBASEDIR%\lib\win7\amd64
set PATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\amd64;%PATH%
set OUTDIR=..\Release_x64
set OBJDIR=%OUTDIR%\obj

md "%OBJDIR%" >NUL 2>&1
del "%OUTDIR%\*.exe" >NUL 2>&1
del "%OBJDIR%\*.obj" >NUL 2>&1
del "%OBJDIR%\*.pdb" >NUL 2>&1
del "%OBJDIR%\*.idb" >NUL 2>&1

pushd ..
call update_version.bat
popd

cl -nologo @cl_x64.txt
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&GOTO :end
rc /fo"%OBJDIR%/Notepad2.res" "..\src\Notepad2.rc"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&GOTO :end
link -nologo @link_x64.txt
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&GOTO :end

:end
endlocal
goto :eof