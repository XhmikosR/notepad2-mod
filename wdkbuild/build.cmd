@ECHO OFF
SETLOCAL
CD /D %~dp0

rem Set the WDK and SDK directories
SET "WDKBASEDIR=C:\WinDDK\7600.16385.1"
SET "SDKDIR=%PROGRAMFILES%\Microsoft SDKs\Windows\v7.1"

rem Check the building environment
IF NOT EXIST "%WDKBASEDIR%" CALL :SUBMSG "ERROR" "Specify your WDK directory!"
IF NOT EXIST "%SDKDIR%" CALL :SUBMSG "ERROR" "Specify your SDK directory!"

rem check for the help switches
IF /I "%1"=="help" GOTO :SHOWHELP
IF /I "%1"=="/help" GOTO :SHOWHELP
IF /I "%1"=="-help" GOTO :SHOWHELP
IF /I "%1"=="--help" GOTO :SHOWHELP
IF /I "%1"=="/?" GOTO :SHOWHELP
GOTO :CHECK

:SHOWHELP
TITLE "build.cmd %1"
ECHO.
ECHO:Usage:  build.cmd [Clean^|Build^|Rebuild] [x86^|x64^|all]
ECHO.
ECHO:Edit "build.cmd" and set your WDK and SDK directories.
ECHO:You shouldn't need to make any changes other than that.
ECHO.
ECHO:Executing "build.cmd" will use the defaults: "build.bat build all"
ECHO.
ENDLOCAL
EXIT /B

:CHECK
REM Check for the switches
IF "%1" == "" (
SET BUILDTYPE=Build
SET ARCH=all
) ELSE (
IF /I "%1" == "Build" SET BUILDTYPE=Build
IF /I "%1" == "/Build" SET BUILDTYPE=Build
IF /I "%1" == "-Build" SET BUILDTYPE=Build
IF /I "%1" == "--Build" SET BUILDTYPE=Build
IF /I "%1" == "Clean" SET BUILDTYPE=Clean
IF /I "%1" == "/Clean" SET BUILDTYPE=Clean
IF /I "%1" == "-Clean" SET BUILDTYPE=Clean
IF /I "%1" == "--Clean" SET BUILDTYPE=Clean
IF /I "%1" == "Rebuild" SET BUILDTYPE=Rebuild
IF /I "%1" == "/Rebuild" SET BUILDTYPE=Rebuild
IF /I "%1" == "-Rebuild" SET BUILDTYPE=Rebuild
IF /I "%1" == "--Rebuild" SET BUILDTYPE=Rebuild
IF /I "%2" == "x86" SET ARCH=x86
IF /I "%2" == "/x86" SET ARCH=x86
IF /I "%2" == "-x86" SET ARCH=x86
IF /I "%2" == "--x86" SET ARCH=x86
IF /I "%2" == "x64" SET ARCH=x64
IF /I "%2" == "/x64" SET ARCH=x64
IF /I "%2" == "-x64" SET ARCH=x64
IF /I "%2" == "--x64" SET ARCH=x64
IF /I "%2" == "all" SET ARCH=all
IF /I "%2" == "/all" SET ARCH=all
IF /I "%2" == "-all" SET ARCH=all
IF /I "%2" == "--all" SET ARCH=all
GOTO :START
)


:START
IF /I "%BUILDTYPE%" == "Clean" GOTO :x86
PUSHD ..
CALL "update_version.bat"
POPD

:x86
SET "INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk"
SET "LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386"
SET "FPATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\x86;%SDKDIR%\Bin"
SET "PATH=%FPATH%"

IF /I "%ARCH%" == "x64" GOTO :x64

TITLE Building Notepad2 x86...
ECHO. && ECHO.

IF /I "%BUILDTYPE%" == "Build" (
CALL :SUBNMAKE
IF /I "%ARCH%" == "x86" GOTO :END
IF /I "%ARCH%" == "x64" GOTO :x64
IF /I "%ARCH%" == "all" GOTO :x64
)

IF /I "%BUILDTYPE%" == "Rebuild" (
CALL :SUBNMAKE clean
CALL :SUBNMAKE
IF /I "%ARCH%" == "x86" GOTO :END
IF /I "%ARCH%" == "x64" GOTO :x64
IF /I "%ARCH%" == "all" GOTO :x64
)

IF /I "%BUILDTYPE%" == "Clean" CALL :SUBNMAKE clean
IF /I "%ARCH%" == "x86" GOTO :END
IF /I "%ARCH%" == "x64" GOTO :x64
IF /I "%ARCH%" == "all" GOTO :x64

:x64
SET "LIB=%WDKBASEDIR%\lib\crt\amd64;%WDKBASEDIR%\lib\win7\amd64"
SET "FPATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\amd64;%SDKDIR%\Bin"
SET "PATH=%FPATH%"

IF /I "%ARCH%" == "x86" GOTO :END

TITLE Building Notepad2 x64...
ECHO. && ECHO.

IF /I "%BUILDTYPE%" == "Build" (
CALL :SUBNMAKE "x64=1"
GOTO :END
)

IF /I "%BUILDTYPE%" == "Rebuild" (
CALL :SUBNMAKE "x64=1" clean
CALL :SUBNMAKE "x64=1"
GOTO :END
)

IF /I "%BUILDTYPE%" == "Clean" CALL :SUBNMAKE "x64=1" clean


:END
TITLE Building Notepad2 - Finished!
ENDLOCAL
EXIT /B


:SUBNMAKE
nmake /NOLOGO /f "makefile.mak" %~1 %2
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
EXIT /B

:SUBMSG
ECHO.&&ECHO:______________________________
ECHO:[%~1] %~2
ECHO:______________________________&&ECHO.
IF /I "%~1"=="ERROR" (
  PAUSE
  EXIT
) ELSE (
  EXIT /B
)
