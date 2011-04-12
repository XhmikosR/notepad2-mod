@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * build_icl12.bat
rem *   Batch file used to build Notepad2 with ICL12
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                       (c) XhmikosR 2010-2011
rem *                                       http://code.google.com/p/notepad2-mod/
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0

rem Check the building environment
IF NOT DEFINED VS100COMNTOOLS    CALL :SUBMSG "ERROR" "Visual Studio 2010 wasn't found!"
IF NOT DEFINED ICPP_COMPOSER2011 CALL :SUBMSG "ERROR" "Intel C++ Composer 2011 wasn't found!"

rem Check for the help switches
IF /I "%~1"=="help"   GOTO SHOWHELP
IF /I "%~1"=="/help"  GOTO SHOWHELP
IF /I "%~1"=="-help"  GOTO SHOWHELP
IF /I "%~1"=="--help" GOTO SHOWHELP
IF /I "%~1"=="/?"     GOTO SHOWHELP


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
CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL


:x86
IF /I "%ARCH%" == "x64" GOTO x64

TITLE Building Notepad2-mod x86 with ICL12...
ECHO. & ECHO.

CALL :SUBMSVC %BUILDTYPE% "Win32"

IF /I "%ARCH%" == "x86" GOTO END
IF /I "%ARCH%" == "x64" GOTO x64
IF /I "%ARCH%" == "all" GOTO x64


:x64
IF /I "%ARCH%" == "x86" GOTO END

TITLE Building Notepad2-mod x64 with ICL12...
ECHO. & ECHO.

CALL :SUBMSVC %BUILDTYPE% "x64"
GOTO END


:END
TITLE Building Notepad2-mod with ICL12 - Finished!
ENDLOCAL
EXIT /B


:SUBMSVC
devenv /nologo ..\Notepad2_icl12.sln /%~1 "Release|%~2"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
EXIT /B


:SHOWHELP
TITLE "%~nx0 %1"
ECHO. & ECHO.
ECHO Usage:   %~nx0 [Clean^|Build^|Rebuild] [x86^|x64^|all]
ECHO.
ECHO Notes:   You can also prefix the commands with "-", "--" or "/".
ECHO          The arguments are case insesitive.
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
