@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * make_zip.bat
rem *   Batch file for creating the zip packages
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                       (c) XhmikosR 2010-2011
rem *                                       http://code.google.com/p/notepad2-mod/
rem *
rem ******************************************************************************

SETLOCAL ENABLEEXTENSIONS
CD /D %~dp0


rem Check for the help switches
IF /I "%~1" == "help"   GOTO SHOWHELP
IF /I "%~1" == "/help"  GOTO SHOWHELP
IF /I "%~1" == "-help"  GOTO SHOWHELP
IF /I "%~1" == "--help" GOTO SHOWHELP
IF /I "%~1" == "/?"     GOTO SHOWHELP


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
SET "TEMP_NAME=temp_zip%SUFFIX%"

CALL :SubGetVersion
CALL :SubZipFiles %INPUTDIRx86% x86-32
CALL :SubZipFiles %INPUTDIRx64% x86-64

rem Compress everything into a single ZIP file
PUSHD "packages"
IF EXIST "Notepad2.zip" DEL "Notepad2.zip"
IF EXIST "%TEMP_NAME%"      RD /S /Q "%TEMP_NAME%"
IF NOT EXIST "%TEMP_NAME%"  MD "%TEMP_NAME%"

IF EXIST "Notepad2.%NP2_VER%_r%VerRev%*.7z"  COPY /Y /V "Notepad2.%NP2_VER%_r%VerRev%*.7z"  "%TEMP_NAME%\" >NUL
IF EXIST "Notepad2.%NP2_VER%_r%VerRev%*.exe" COPY /Y /V "Notepad2.%NP2_VER%_r%VerRev%*.exe" "%TEMP_NAME%\" >NUL
IF EXIST "Notepad2.%NP2_VER%_r%VerRev%*.zip" COPY /Y /V "Notepad2.%NP2_VER%_r%VerRev%*.zip" "%TEMP_NAME%\" >NUL

PUSHD "%TEMP_NAME%"

START "" /B /WAIT "..\..\..\distrib\tools\7za.exe" a -tzip -mx=9 Notepad2.zip * >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "Notepad2.zip created successfully!"

MOVE /Y "Notepad2.zip" ".." >NUL

POPD
IF EXIST "%TEMP_NAME%" RD /S /Q "%TEMP_NAME%"

POPD


:END
TITLE Finished!
ECHO.
ENDLOCAL
EXIT /B


:SubZipFiles
TITLE Creating the %2 ZIP file...
CALL :SUBMSG "INFO" "Creating the %2 ZIP file..."

IF EXIST "%TEMP_NAME%"     RD /S /Q "%TEMP_NAME%"
IF NOT EXIST "%TEMP_NAME%" MD "%TEMP_NAME%"
IF NOT EXIST "packages"    MD "packages"

COPY /Y /V "..\License.txt"                      "%TEMP_NAME%\"
COPY /Y /V "..\%1\Notepad2.exe"                  "%TEMP_NAME%\"
COPY /Y /V "..\distrib\res\cabinet\notepad2.ini" "%TEMP_NAME%\Notepad2.ini"
COPY /Y /V "..\Notepad2.txt"                     "%TEMP_NAME%\"
COPY /Y /V "..\Readme.txt"                       "%TEMP_NAME%\"
COPY /Y /V "..\Readme-mod.txt"                   "%TEMP_NAME%\"

PUSHD "%TEMP_NAME%"
START "" /B /WAIT "..\..\distrib\tools\7za.exe" a -tzip -mx=9^
 "Notepad2.%NP2_VER%_r%VerRev%_%2%SUFFIX%.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "Notepad2.txt" "Readme.txt" "Readme-mod.txt" >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "Notepad2.%NP2_VER%_r%VerRev%_%2%SUFFIX%.zip created successfully!"

MOVE /Y "Notepad2.%NP2_VER%_r%VerRev%_%2%SUFFIX%.zip" "..\packages" >NUL
POPD
IF EXIST "%TEMP_NAME%" RD /S /Q "%TEMP_NAME%"
EXIT /B


:SubGetVersion
rem Get the version
FOR /F "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_MAJOR" "..\src\Version.h"') DO (
  SET "VerMajor=%%K" & Call :SubVerMajor %%VerMajor:*Z=%%)
FOR /F "tokens=3,4 delims= " %%L IN (
  'FINDSTR /I /L /C:"define VERSION_MINOR" "..\src\Version.h"') DO (
  SET "VerMinor=%%L" & Call :SubVerMinor %%VerMinor:*Z=%%)
FOR /F "tokens=3,4 delims= " %%M IN (
  'FINDSTR /I /L /C:"define VERSION_BUILD" "..\src\Version.h"') DO (
  SET "VerBuild=%%M" & Call :SubVerBuild %%VerBuild:*Z=%%)
FOR /F "tokens=3,4 delims= " %%N IN (
  'FINDSTR /I /L /C:"define VERSION_REV" "..\src\Version_rev.h"') DO (
  SET "VerRev=%%N" & Call :SubVerRev %%VerRev:*Z=%%)

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
ECHO          The arguments are not case sensitive.
ECHO. & ECHO.
ECHO Executing "%~nx0" will use the defaults: "%~nx0 WDK"
ECHO.
ENDLOCAL
EXIT /B


:SUBMSG
ECHO. & ECHO ______________________________
ECHO [%~1] %~2
ECHO ______________________________ & ECHO.
IF /I "%~1" == "ERROR" (
  PAUSE
  EXIT
) ELSE (
  EXIT /B
)
