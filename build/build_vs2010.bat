@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * build_vs2010.bat
rem *   Batch file used to build Notepad2 with MSVC2010
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
IF NOT DEFINED VS100COMNTOOLS CALL :SUBMSG "ERROR" "Visual Studio 2010 NOT FOUND!"

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
  IF /I "%~2" == "x86"   SET "ARCH=x86" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "/x86"  SET "ARCH=x86" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "-x86"  SET "ARCH=x86" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "--x86" SET "ARCH=x86" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "x64"   SET "ARCH=x64" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "/x64"  SET "ARCH=x64" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "-x64"  SET "ARCH=x64" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "--x64" SET "ARCH=x64" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "all"   SET "ARCH=all" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "/all"  SET "ARCH=all" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "-all"  SET "ARCH=all" & GOTO CHECKTHIRDARG
  IF /I "%~2" == "--all" SET "ARCH=all" & GOTO CHECKTHIRDARG

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:CHECKTHIRDARG
rem Check for the third switch
IF "%~3" == "" (
  SET "CONFIG=Release"
) ELSE (
  IF /I "%~3" == "Debug"     SET "CONFIG=Debug"   & GOTO START
  IF /I "%~3" == "/Debug"    SET "CONFIG=Debug"   & GOTO START
  IF /I "%~3" == "-Debug"    SET "CONFIG=Debug"   & GOTO START
  IF /I "%~3" == "--Debug"   SET "CONFIG=Debug"   & GOTO START
  IF /I "%~3" == "Release"   SET "CONFIG=Release" & GOTO START
  IF /I "%~3" == "/Release"  SET "CONFIG=Release" & GOTO START
  IF /I "%~3" == "-Release"  SET "CONFIG=Release" & GOTO START
  IF /I "%~3" == "--Release" SET "CONFIG=Release" & GOTO START
  IF /I "%~3" == "all"       SET "CONFIG=all"     & GOTO START
  IF /I "%~3" == "/all"      SET "CONFIG=all"     & GOTO START
  IF /I "%~3" == "-all"      SET "CONFIG=all"     & GOTO START
  IF /I "%~3" == "--all"     SET "CONFIG=all"     & GOTO START

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:START
CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL


:x86
IF "%ARCH%" == "x64" GOTO x64

IF "%BUILDTYPE%" == "Build" (
  IF "%CONFIG%" == "Release" CALL :SUBMSVC %BUILDTYPE% Release Win32
  IF "%CONFIG%" == "Debug"   CALL :SUBMSVC %BUILDTYPE% Debug Win32
  IF "%CONFIG%" == "all"     CALL :SUBMSVC %BUILDTYPE% Release Win32 && CALL :SUBMSVC %BUILDTYPE% Debug Win32

  IF "%ARCH%" == "x86" GOTO END
  IF "%ARCH%" == "x64" GOTO x64
  IF "%ARCH%" == "all" GOTO x64
)

IF "%BUILDTYPE%" == "Rebuild" (
  IF "%CONFIG%" == "Release" CALL :SUBMSVC %BUILDTYPE% Release Win32
  IF "%CONFIG%" == "Debug"   CALL :SUBMSVC %BUILDTYPE% Debug Win32
  IF "%CONFIG%" == "all"     CALL :SUBMSVC %BUILDTYPE% Release Win32 && CALL :SUBMSVC %BUILDTYPE% Debug Win32

  IF "%ARCH%" == "x86" GOTO END
  IF "%ARCH%" == "x64" GOTO x64
  IF "%ARCH%" == "all" GOTO x64
)

IF "%BUILDTYPE%" == "Clean" (
  IF "%CONFIG%" == "Release" CALL :SUBMSVC %BUILDTYPE% Release Win32
  IF "%CONFIG%" == "Debug"   CALL :SUBMSVC %BUILDTYPE% Debug Win32
  IF "%CONFIG%" == "all"     CALL :SUBMSVC %BUILDTYPE% Release Win32 && CALL :SUBMSVC %BUILDTYPE% Debug Win32
)

IF "%ARCH%" == "x86" GOTO END
IF "%ARCH%" == "x64" GOTO x64
IF "%ARCH%" == "all" GOTO x64


:x64
IF "%ARCH%" == "x86" GOTO END

IF "%BUILDTYPE%" == "Build" (
  IF "%CONFIG%" == "Release" CALL :SUBMSVC %BUILDTYPE% Release x64
  IF "%CONFIG%" == "Debug"   CALL :SUBMSVC %BUILDTYPE% Debug x64
  IF "%CONFIG%" == "all"     CALL :SUBMSVC %BUILDTYPE% Release x64 && CALL :SUBMSVC %BUILDTYPE% Debug x64
  GOTO END
)

IF "%BUILDTYPE%" == "Rebuild" (
  IF "%CONFIG%" == "Release" CALL :SUBMSVC %BUILDTYPE% Release x64
  IF "%CONFIG%" == "Debug"   CALL :SUBMSVC %BUILDTYPE% Debug x64
  IF "%CONFIG%" == "all"     CALL :SUBMSVC %BUILDTYPE% Release x64 && CALL :SUBMSVC %BUILDTYPE% Debug x64
  GOTO END
)

IF "%BUILDTYPE%" == "Clean" (
  IF "%CONFIG%" == "Release" CALL :SUBMSVC %BUILDTYPE% Release x64
  IF "%CONFIG%" == "Debug"   CALL :SUBMSVC %BUILDTYPE% Debug x64
  IF "%CONFIG%" == "all"     CALL :SUBMSVC %BUILDTYPE% Release x64 && CALL :SUBMSVC %BUILDTYPE% Debug x64
)


:END
TITLE Building Notepad2-mod with MSVC2010 - Finished!
ENDLOCAL
EXIT /B


:SUBMSVC
ECHO.
TITLE Building Notepad2-mod with MSVC2010 - %~1 "%~2|%~3"...
devenv /nologo Notepad2.sln /%~1 "%~2|%~3"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
EXIT /B


:SHOWHELP
TITLE "%~nx0 %1"
ECHO. & ECHO.
ECHO Usage:  %~nx0 [Clean^|Build^|Rebuild] [x86^|x64^|all] [Debug^|Release^|all]
ECHO.
ECHO Notes:  You can also prefix the commands with "-", "--" or "/".
ECHO         The arguments are case insesitive.
ECHO. & ECHO.
ECHO Executing "%~nx0" will use the defaults: "%~nx0 build all release"
ECHO.
ECHO If you skip the second argument the default one will be used.
ECHO The same goes for the third argument. Examples:
ECHO "%~nx0 rebuild" is the same as "%~nx0 rebuild all release"
ECHO "%~nx0 rebuild x86" is the same as "%~nx0 rebuild x86 release"
ECHO.
ECHO WARNING: "%~nx0 x86" or "%~nx0 debug" won't work.
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
