@echo off
setlocal
cd /d %~dp0

rem Set the WDK and SDK directories
set "WDKBASEDIR=C:\WinDDK\7600.16385.1"
set "SDKDIR=%PROGRAMFILES%\Microsoft SDKs\Windows\v7.1"

rem Check the building environment
IF NOT EXIST "%WDKBASEDIR%" (
  ECHO. && ECHO:______________________________
  ECHO:[ERROR] Specify your WDK directory
  ECHO:______________________________ && ECHO.
  PAUSE
  EXIT
)

IF NOT EXIST "%SDKDIR%" (
  ECHO. && ECHO:______________________________
  ECHO:[ERROR] Specify your SDK directory
  ECHO:______________________________ && ECHO.
  PAUSE
  EXIT
)

pushd ..
call "update_version.bat"
popd

rem x86
set "INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk"
set "LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386"
set "PATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\x86;%PATH%"
set OUTDIR=..\Release
set OBJDIR=%OUTDIR%\obj

TITLE Building Notepad2 x86...
call "build_base.bat" x86

rem x64
set "LIB=%WDKBASEDIR%\lib\crt\amd64;%WDKBASEDIR%\lib\win7\amd64"
set "PATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\amd64;%PATH%"
set OUTDIR=..\Release_x64
set OBJDIR=%OUTDIR%\obj

TITLE Building Notepad2 x64...
call "build_base.bat" x64

:end
TITLE Finished!
endlocal
exit /b