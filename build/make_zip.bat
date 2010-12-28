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
rem *                                       (c) XhmikosR 2010
rem *                                       http://code.google.com/p/notepad2-mod/
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0

CALL :SubGetVersion


rem Check for the first switch
IF "%1" == "" (
SET INPUTDIRx86=bin\WDK\Release_x86
SET INPUTDIRx64=bin\WDK\Release_x64
SET SUFFIX=
) ELSE (
IF /I "%1" == "VS2010" (
SET INPUTDIRx86=bin\VS2010\Release_Win32
SET INPUTDIRx64=bin\VS2010\Release_x64
SET SUFFIX=_vs2010
GOTO :START)
IF /I "%1" == "/VS2010" (
SET INPUTDIRx86=bin\VS2010\Release_Win32
SET INPUTDIRx64=bin\VS2010\Release_x64
SET SUFFIX=_vs2010
GOTO :START)
IF /I "%1" == "-VS2010" (
SET INPUTDIRx86=bin\VS2010\Release_Win32
SET INPUTDIRx64=bin\VS2010\Release_x64
SET SUFFIX=_vs2010
GOTO :START)
IF /I "%1" == "--VS2010" (
SET INPUTDIRx86=bin\VS2010\Release_Win32
SET INPUTDIRx64=bin\VS2010\Release_x64
SET SUFFIX=_vs2010
GOTO :START)
IF /I "%1" == "ICL12" (
SET INPUTDIRx86=bin\ICL12\Release_Win32
SET INPUTDIRx64=bin\ICL12\Release_x64
SET SUFFIX=_icl12
GOTO :START)
IF /I "%1" == "/ICL12" (
SET INPUTDIRx86=bin\ICL12\Release_Win32
SET INPUTDIRx64=bin\ICL12\Release_x64
SET SUFFIX=_icl12
GOTO :START)
IF /I "%1" == "-ICL12" (
SET INPUTDIRx86=bin\ICL12\Release_Win32
SET INPUTDIRx64=bin\ICL12\Release_x64
SET SUFFIX=_icl12
GOTO :START)
IF /I "%1" == "--ICL12" (
SET INPUTDIRx86=bin\ICL12\Release_Win32
SET INPUTDIRx64=bin\ICL12\Release_x64
SET SUFFIX=_icl12
GOTO :START)
ECHO.
ECHO:Unsupported commandline switch!
ECHO:Run "make_zip.bat help" for details about the commandline switches.
CALL :SUBMSG "ERROR" "Compilation failed!"
)

:START
CALL :SubZipFiles %INPUTDIRx86% x86-32
CALL :SubZipFiles %INPUTDIRx64% x86-64

rem Compress everything into a single ZIP file
PUSHD "packages"
DEL "Notepad2-mod.zip" >NUL 2>&1

START "" /B /WAIT "..\..\distrib\tools\7za.exe" a -tzip -mx=9 Notepad2-mod.zip * >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "Notepad2-mod.zip created successfully!"
POPD

:END
TITLE Finished!
ECHO.
ENDLOCAL
rem PAUSE
EXIT /B


:SubZipFiles
TITLE Creating the %2 ZIP file...
CALL :SUBMSG "INFO" "Creating the %2 ZIP file..."

RD /S /Q "temp_zip" >NUL 2>&1
MD "temp_zip" "packages" >NUL 2>&1

COPY /Y /V "..\License.txt" "temp_zip\"
COPY /Y /V "..\%1\Notepad2.exe" "temp_zip\"
COPY /Y /V "..\distrib\res\cabinet\notepad2.ini" "temp_zip\Notepad2.ini"
COPY /Y /V "..\Notepad2.txt" "temp_zip\"
COPY /Y /V "..\Readme.txt" "temp_zip\"
COPY /Y /V "..\Readme-mod.txt" "temp_zip\"

PUSHD "temp_zip"
START "" /B /WAIT "..\..\distrib\tools\7za.exe" a -tzip -mx=9^
 "Notepad2-mod.%NP2_VER%_r%VerRev%_%2%SUFFIX%.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "Notepad2.txt" "Readme.txt" "Readme-mod.txt" >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" Notepad2-mod.%NP2_VER%_r%VerRev%_%2%SUFFIX%.zip created successfully!"

MOVE /Y "Notepad2-mod.%NP2_VER%_r%VerRev%_%2%SUFFIX%.zip" "..\packages" >NUL 2>&1
POPD
RD /S /Q "temp_zip" >NUL 2>&1
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
