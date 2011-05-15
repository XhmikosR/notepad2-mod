@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * make_installer.bat
rem *   Batch file for building the installer for Notepad2-mod with MSVC2010
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                       (c) XhmikosR 2010-2011
rem *                                       http://code.google.com/p/notepad2-mod/
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0
rem SET "PERL_PATH=H:\progs\thirdparty\Perl"

rem Check the building environment
rem IF NOT EXIST "%PERL_PATH%"    CALL :SUBMSG "INFO" "The Perl directory wasn't found; the addon won't be built"
IF NOT DEFINED VS100COMNTOOLS CALL :SUBMSG "ERROR" "Visual Studio 2010 wasn't found; the installer won't be built"

rem Check for the help switches
IF /I "%~1"=="help"   GOTO SHOWHELP
IF /I "%~1"=="/help"  GOTO SHOWHELP
IF /I "%~1"=="-help"  GOTO SHOWHELP
IF /I "%~1"=="--help" GOTO SHOWHELP
IF /I "%~1"=="/?"     GOTO SHOWHELP


rem Check for the first switch
IF "%~1" == "" (
  SET INPUTDIRx86=bin\WDK\Release_x86
  SET INPUTDIRx64=bin\WDK\Release_x64
  SET SUFFIX=
) ELSE (
  IF /I "%~1" == "WDK" (
    SET INPUTDIRx86=bin\WDK\Release_x86
    SET INPUTDIRx64=bin\WDK\Release_x64
    SET SUFFIX=
    GOTO START
  )
  IF /I "%~1" == "/WDK" (
    SET INPUTDIRx86=bin\WDK\Release_x86
    SET INPUTDIRx64=bin\WDK\Release_x64
    SET SUFFIX=
    GOTO START
  )
  IF /I "%~1" == "-WDK" (
    SET INPUTDIRx86=bin\WDK\Release_x86
    SET INPUTDIRx64=bin\WDK\Release_x64
    SET SUFFIX=
    GOTO START
  )
  IF /I "%~1" == "--WDK" (
    SET INPUTDIRx86=bin\WDK\Release_x86
    SET INPUTDIRx64=bin\WDK\Release_x64
    SET SUFFIX=
    GOTO START
  )
  IF /I "%~1" == "VS2010" (
    SET INPUTDIRx86=bin\VS2010\Release_x86
    SET INPUTDIRx64=bin\VS2010\Release_x64
    SET SUFFIX=_vs2010
    GOTO START
  )
  IF /I "%~1" == "/VS2010" (
    SET INPUTDIRx86=bin\VS2010\Release_x86
    SET INPUTDIRx64=bin\VS2010\Release_x64
    SET SUFFIX=_vs2010
    GOTO START
  )
  IF /I "%~1" == "-VS2010" (
    SET INPUTDIRx86=bin\VS2010\Release_x86
    SET INPUTDIRx64=bin\VS2010\Release_x64
    SET SUFFIX=_vs2010
    GOTO START
  )
  IF /I "%~1" == "--VS2010" (
    SET INPUTDIRx86=bin\VS2010\Release_x86
    SET INPUTDIRx64=bin\VS2010\Release_x64
    SET SUFFIX=_vs2010
    GOTO START
  )
  IF /I "%~1" == "ICL12" (
    SET INPUTDIRx86=bin\ICL12\Release_x86
    SET INPUTDIRx64=bin\ICL12\Release_x64
    SET SUFFIX=_icl12
    GOTO START
  )
  IF /I "%~1" == "/ICL12" (
    SET INPUTDIRx86=bin\ICL12\Release_x86
    SET INPUTDIRx64=bin\ICL12\Release_x64
    SET SUFFIX=_icl12
    GOTO START
  )
  IF /I "%~1" == "-ICL12" (
    SET INPUTDIRx86=bin\ICL12\Release_x86
    SET INPUTDIRx64=bin\ICL12\Release_x64
    SET SUFFIX=_icl12
    GOTO START
  )
  IF /I "%~1" == "--ICL12" (
    SET INPUTDIRx86=bin\ICL12\Release_x86
    SET INPUTDIRx64=bin\ICL12\Release_x64
    SET SUFFIX=_icl12
    GOTO START
  )

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:START
CALL :SubGetVersion
CALL :SubInstaller %INPUTDIRx86% x86
CALL :SubInstaller %INPUTDIRx64% x64


:END
TITLE Finished!
ECHO.
ENDLOCAL
EXIT /B


:SubInstaller
IF "%2"=="x86" (
  SET "ARCH=Win32"
  SET "BINDIR=x86-32"
)
IF "%2"=="x64" (
  SET "ARCH=x64"
  SET "BINDIR=x86-64"
)

PUSHD "..\distrib"

TITLE Building %BINDIR% installer...
CALL :SUBMSG "INFO" "Building %BINDIR% installer..."

IF NOT EXIST "temp\%BINDIR%" MD "temp\%BINDIR%"

COPY /B /V /Y "..\%1\Notepad2.exe"             "temp\%BINDIR%\notepad2.exe"
COPY /B /V /Y "..\License.txt"                 "temp\%BINDIR%\license.txt"
COPY /B /V /Y "res\cabinet\notepad2.inf"       "temp\%BINDIR%\notepad2.inf"
COPY /B /V /Y "res\cabinet\notepad2.ini"       "temp\%BINDIR%\notepad2.ini"
COPY /B /V /Y "res\cabinet\notepad2.redir.ini" "temp\%BINDIR%\notepad2.redir.ini"
COPY /B /V /Y "..\Notepad2.txt"                "temp\%BINDIR%\notepad2.txt"
COPY /B /V /Y "..\Readme.txt"                  "temp\%BINDIR%\readme.txt"
COPY /B /V /Y "..\Readme-mod.txt"              "temp\%BINDIR%\readme-mod.txt"

rem Set the version for the DisplayVersion registry value
CALL "tools\BatchSubstitute.bat" "4.2.25.0" "%NP2_VER%.%VerRev%" "temp\%BINDIR%\notepad2.inf" >notepad2.inf.tmp
COPY /Y "temp\%BINDIR%\notepad2.inf" "notepad2.inf.orig" >NUL
MOVE /Y "notepad2.inf.tmp" "temp\%BINDIR%\notepad2.inf" >NUL

rem get the size and put it in the inf file
PUSHD "temp\%BINDIR%"
FOR /F "tokens=*" %%a IN ('"DIR /-C | FIND "bytes" | FIND /V "free""') DO SET summaryout=%%a
FOR /F "tokens=1,2 delims=)" %%a IN ("%summaryout%") DO SET filesout=%%a & SET sizeout=%%b
SET /A sizeout=%sizeout:bytes=%/1024
POPD

CALL "tools\BatchSubstitute.bat" "1111" "%sizeout%" "temp\%BINDIR%\notepad2.inf" >notepad2.inf.tmp
COPY /Y "temp\%BINDIR%\notepad2.inf" "notepad2.inf.orig" >NUL
MOVE /Y "notepad2.inf.tmp" "temp\%BINDIR%\notepad2.inf" >NUL

"tools\cabutcd.exe" "temp\%BINDIR%" "res\cabinet.%BINDIR%.cab"
IF EXIST "notepad2.inf.orig" DEL "notepad2.inf.orig"
IF EXIST "temp\%BINDIR%"     RD /Q /S "temp\%BINDIR%"


CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL
devenv setup.sln /Rebuild "Full|%ARCH%"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
rem devenv setup.sln /Rebuild "Lite|%ARCH%"
rem IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

rem IF EXIST "%PERL_PATH%" (
rem   PUSHD "tools"
rem   "%PERL_PATH%\perl\bin\perl.exe" "addon_build.pl"
rem   POPD
rem )

IF NOT EXIST "..\build\packages" MD "..\build\packages"
rem IF EXIST "%PERL_PATH%" (
rem   MOVE "setup.%BINDIR%\addon.7z"    "..\build\packages\Notepad2-mod.%NP2_VER%_r%VerRev%_%BINDIR%%SUFFIX%_Addon.7z" >NUL
rem )
MOVE "setup.%BINDIR%\setupfull.exe" "..\build\packages\Notepad2-mod.%NP2_VER%_r%VerRev%_%BINDIR%%SUFFIX%_Setup.exe" >NUL
rem MOVE "setup.%BINDIR%\setuplite.exe" "..\build\packages\Notepad2-mod.%NP2_VER%_r%VerRev%_%BINDIR%%SUFFIX%_Setup_Silent.exe" >NUL

rem Cleanup
IF EXIST "setup.%BINDIR%" RD /Q "setup.%BINDIR%"
IF EXIST "temp"           RD /Q "temp"
IF EXIST "tools\addon"    RD /Q /S "tools\addon"
IF EXIST "obj"            RD /Q /S "obj"

POPD
EXIT /B


:SubGetVersion
rem Get the version
FOR /F "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_MAJOR" "..\src\Version.h"') DO (
  SET "VerMajor=%%K"&Call :SubVerMajor %%VerMajor:*Z=%%)
FOR /F "tokens=3,4 delims= " %%L IN (
  'FINDSTR /I /L /C:"define VERSION_MINOR" "..\src\Version.h"') DO (
  SET "VerMinor=%%L"&Call :SubVerMinor %%VerMinor:*Z=%%)
FOR /F "tokens=3,4 delims= " %%M IN (
  'FINDSTR /I /L /C:"define VERSION_BUILD" "..\src\Version.h"') DO (
  SET "VerBuild=%%M"&Call :SubVerBuild %%VerBuild:*Z=%%)
FOR /F "tokens=3,4 delims= " %%N IN (
  'FINDSTR /I /L /C:"define VERSION_REV" "..\src\Version_rev.h"') DO (
  SET "VerRev=%%N"&Call :SubVerRev %%VerRev:*Z=%%)

SET NP2_VER=%VerMajor%.%VerMinor%.%VerBuild%
EXIT /B


:SubVerMajor
SET VerMajor=%*
EXIT /B


:SubVerMinor
SET VerMinor=%*
EXIT /B


:SubVerBuild
SET VerBuild=%*
EXIT /B


:SubVerRev
SET VerRev=%*
EXIT /B


:SHOWHELP
TITLE "%~nx0 %1"
ECHO. & ECHO.
ECHO Usage:   %~nx0 [ICL12^|VS2010^|WDK]
ECHO.
ECHO Notes:   You can also prefix the commands with "-", "--" or "/".
ECHO          The arguments are case insesitive.
ECHO. & ECHO.
ECHO Executing "%~nx0" will use the defaults: "%~nx0 WDK"
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
