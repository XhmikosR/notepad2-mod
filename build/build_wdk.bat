@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * build_wdk.bat
rem *   Batch file "wrapper" for makefile.mak, used to build Notepad2 with WDK
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                       (c) XhmikosR 2010-2011
rem *                                       http://code.google.com/p/notepad2-mod/
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0

rem Set the WDK and SDK directories
SET "WDKBASEDIR=C:\WinDDK\7600.16385.1"
SET "SDKDIR=%PROGRAMFILES%\Microsoft SDKs\Windows\v7.1"

rem Check the building environment
IF NOT EXIST "%WDKBASEDIR%" CALL :SUBMSG "ERROR" "Specify your WDK directory!"
IF NOT EXIST "%SDKDIR%"     CALL :SUBMSG "ERROR" "Specify your SDK directory!"

rem Check for the help switches
IF /I "%~1"=="help"   GOTO SHOWHELP
IF /I "%~1"=="/help"  GOTO SHOWHELP
IF /I "%~1"=="-help"  GOTO SHOWHELP
IF /I "%~1"=="--help" GOTO SHOWHELP
IF /I "%~1"=="/?"     GOTO SHOWHELP
GOTO CHECKFIRSTARG


:SHOWHELP
TITLE "%~nx0 %1"
ECHO. & ECHO.
ECHO Usage:   %~nx0 [Clean^|Build^|Rebuild] [x86^|x64^|all]
ECHO.
ECHO Notes:   You can also prefix the commands with "-", "--" or "/".
ECHO          The arguments are case insesitive.
ECHO. & ECHO.
ECHO Edit "%~nx0" and set your WDK and SDK directories.
ECHO You shouldn't need to make any changes other than that.
ECHO. & ECHO.
ECHO Executing "%~nx0" will use the defaults: "%~nx0 build all"
ECHO.
ECHO If you skip the second argument the default one will be used. Example:
ECHO "%~nx0 rebuild" is equivalent to "%~nx0 rebuild all"
ECHO.
ECHO NOTE: "%~nx0 x86" won't work.
ECHO.
ENDLOCAL
EXIT /B


:CHECKFIRSTARG
rem Check for the first switch
IF "%~1" == "" (
  SET "BUILDTYPE=Build"
) ELSE (
  IF /I "%~1" == "Build"     SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "/Build"    SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "-Build"    SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "--Build"   SET "BUILDTYPE=Build"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "Clean"     SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "/Clean"    SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "-Clean"    SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "--Clean"   SET "BUILDTYPE=Clean"   & GOTO CHECKSECONDARG
  IF /I "%~1" == "Rebuild"   SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG
  IF /I "%~1" == "/Rebuild"  SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG
  IF /I "%~1" == "-Rebuild"  SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG
  IF /I "%~1" == "--Rebuild" SET "BUILDTYPE=Rebuild" & GOTO CHECKSECONDARG

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:CHECKSECONDARG
rem Check for the second switch
IF "%~2" == "" (
  SET "ARCH=all"
) ELSE (
  IF /I "%~2" == "x86"   SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "/x86"  SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "-x86"  SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "--x86" SET "ARCH=x86" & GOTO START
  IF /I "%~2" == "x64"   SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "/x64"  SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "-x64"  SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "--x64" SET "ARCH=x64" & GOTO START
  IF /I "%~2" == "all"   SET "ARCH=all" & GOTO START
  IF /I "%~2" == "/all"  SET "ARCH=all" & GOTO START
  IF /I "%~2" == "-all"  SET "ARCH=all" & GOTO START
  IF /I "%~2" == "--all" SET "ARCH=all" & GOTO START

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:START
IF /I "%BUILDTYPE%" == "Clean" GOTO x86

rem Update the svn revision before building
PUSHD ..
CALL "update_version.bat"
POPD


:x86
SET "INCLUDE=%WDKBASEDIR%\inc\crt;%WDKBASEDIR%\inc\api;%WDKBASEDIR%\inc\api\crt\stl60;%WDKBASEDIR%\inc\ddk"
SET "LIB=%WDKBASEDIR%\lib\crt\i386;%WDKBASEDIR%\lib\win7\i386"
SET "PATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\x86;%SDKDIR%\Bin"

IF /I "%ARCH%" == "x64" GOTO x64

TITLE Building Notepad2-mod x86 with WDK...
ECHO. & ECHO.

IF /I "%BUILDTYPE%" == "Build" (
  CALL :SUBNMAKE

  IF /I "%ARCH%" == "x86" GOTO END
  IF /I "%ARCH%" == "x64" GOTO x64
  IF /I "%ARCH%" == "all" GOTO x64
)

IF /I "%BUILDTYPE%" == "Rebuild" (
  CALL :SUBNMAKE

  IF /I "%ARCH%" == "x86" GOTO END
  IF /I "%ARCH%" == "x64" GOTO x64
  IF /I "%ARCH%" == "all" GOTO x64
)

IF /I "%BUILDTYPE%" == "Clean" CALL :SUBNMAKE

IF /I "%ARCH%" == "x86" GOTO END
IF /I "%ARCH%" == "x64" GOTO x64
IF /I "%ARCH%" == "all" GOTO x64


:x64
SET "LIB=%WDKBASEDIR%\lib\crt\amd64;%WDKBASEDIR%\lib\win7\amd64"
SET "PATH=%WDKBASEDIR%\bin\x86;%WDKBASEDIR%\bin\x86\amd64;%SDKDIR%\Bin"

IF /I "%ARCH%" == "x86" GOTO END

TITLE Building Notepad2-mod x64 with WDK...
ECHO. & ECHO.

IF /I "%BUILDTYPE%" == "Build" (
  CALL :SUBNMAKE "x64=1"
  GOTO END
)

IF /I "%BUILDTYPE%" == "Rebuild" (
  CALL :SUBNMAKE "x64=1"
  GOTO END
)

IF /I "%BUILDTYPE%" == "Clean" CALL :SUBNMAKE "x64=1"


:END
TITLE Building Notepad2-mod with WDK - Finished!
ENDLOCAL
EXIT /B


:SUBNMAKE
nmake /NOLOGO /f "makefile.mak" %BUILDTYPE% %1
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
EXIT /B


:SUBMSG
ECHO. & ECHO ______________________________
ECHO [%~1] %~2
ECHO ______________________________ & ECHO.
IF /I "%~1"=="ERROR" (
  PAUSE
  EXIT
) ELSE (
  EXIT /B
)
