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
rem *                                     (c) XhmikosR 2010-2014
rem *                                     https://github.com/XhmikosR/notepad2-mod
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
  SET "COMPILER=VS2013"
) ELSE (
  IF /I "%~1" == "WDK"      (SET "COMPILER=WDK"    & GOTO START)
  IF /I "%~1" == "/WDK"     (SET "COMPILER=WDK"    & GOTO START)
  IF /I "%~1" == "-WDK"     (SET "COMPILER=WDK"    & GOTO START)
  IF /I "%~1" == "--WDK"    (SET "COMPILER=WDK"    & GOTO START)
  IF /I "%~1" == "VS2010"   (SET "COMPILER=VS2010" & GOTO START)
  IF /I "%~1" == "/VS2010"  (SET "COMPILER=VS2010" & GOTO START)
  IF /I "%~1" == "-VS2010"  (SET "COMPILER=VS2010" & GOTO START)
  IF /I "%~1" == "--VS2010" (SET "COMPILER=VS2010" & GOTO START)
  IF /I "%~1" == "VS2012"   (SET "COMPILER=VS2012" & GOTO START)
  IF /I "%~1" == "/VS2012"  (SET "COMPILER=VS2012" & GOTO START)
  IF /I "%~1" == "-VS2012"  (SET "COMPILER=VS2012" & GOTO START)
  IF /I "%~1" == "--VS2012" (SET "COMPILER=VS2012" & GOTO START)
  IF /I "%~1" == "VS2013"   (SET "COMPILER=VS2013" & GOTO START)
  IF /I "%~1" == "/VS2013"  (SET "COMPILER=VS2013" & GOTO START)
  IF /I "%~1" == "-VS2013"  (SET "COMPILER=VS2013" & GOTO START)
  IF /I "%~1" == "--VS2013" (SET "COMPILER=VS2013" & GOTO START)

  ECHO.
  ECHO Unsupported commandline switch!
  ECHO Run "%~nx0 help" for details about the commandline switches.
  CALL :SUBMSG "ERROR" "Compilation failed!"
)


:START
IF EXIST "%~dp0..\signinfo_notepad2-mod.txt" SET "SIGN=True"

SET INPUTDIRx86=bin\%COMPILER%\Release_x86
SET INPUTDIRx64=bin\%COMPILER%\Release_x64
IF /I NOT "%COMPILER%" == "VS2013" SET SUFFIX=_%COMPILER%
SET "TEMP_NAME=temp_zip%SUFFIX%"

IF NOT EXIST "..\%INPUTDIRx86%\Notepad2.exe" CALL :SUBMSG "ERROR" "Compile Notepad2 x86 first!"
IF NOT EXIST "..\%INPUTDIRx64%\Notepad2.exe" CALL :SUBMSG "ERROR" "Compile Notepad2 x64 first!"

CALL :SubGetVersion

IF /I "%SIGN%" == "True" CALL :SubSign %INPUTDIRx86%
IF /I "%SIGN%" == "True" CALL :SubSign %INPUTDIRx64%

CALL :SubZipFiles %INPUTDIRx86% x86
CALL :SubZipFiles %INPUTDIRx64% x64

rem Compress everything into a single ZIP file
PUSHD "packages"
IF EXIST "Notepad2-mod.zip" DEL "Notepad2-mod.zip"
IF EXIST "%TEMP_NAME%"      RD /S /Q "%TEMP_NAME%"
IF NOT EXIST "%TEMP_NAME%"  MD "%TEMP_NAME%"

IF EXIST "Notepad2-mod.%NP2_VER%*.exe" COPY /Y /V "Notepad2-mod.%NP2_VER%*.exe" "%TEMP_NAME%\" >NUL
IF EXIST "Notepad2-mod.%NP2_VER%*.zip" COPY /Y /V "Notepad2-mod.%NP2_VER%*.zip" "%TEMP_NAME%\" >NUL

PUSHD "%TEMP_NAME%"

START "" /B /WAIT "..\..\..\distrib\7za.exe" a -tzip -mx=9 Notepad2-mod.zip * >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "Notepad2-mod.zip created successfully!"

MOVE /Y "Notepad2-mod.zip" ".." >NUL

POPD
IF EXIST "%TEMP_NAME%" RD /S /Q "%TEMP_NAME%"

POPD


:END
TITLE Finished!
ECHO.
ENDLOCAL
EXIT /B


:SubZipFiles
SET "ZIP_NAME=Notepad2-mod.%NP2_VER%_%2%SUFFIX%"
TITLE Creating %ZIP_NAME%.zip...
CALL :SUBMSG "INFO" "Creating %ZIP_NAME%.zip..."

IF EXIST "%TEMP_NAME%"     RD /S /Q "%TEMP_NAME%"
IF NOT EXIST "%TEMP_NAME%" MD "%TEMP_NAME%"
IF NOT EXIST "packages"    MD "packages"

FOR %%A IN ("..\License.txt" "..\%1\Notepad2.exe"^
 "..\distrib\Notepad2.ini" "..\Notepad2.txt" "..\Readme-mod.txt"
) DO COPY /Y /V "%%A" "%TEMP_NAME%\"

PUSHD "%TEMP_NAME%"
START "" /B /WAIT "..\..\distrib\7za.exe" a -tzip -mx=9^
 "%ZIP_NAME%.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "Notepad2.txt" "Readme-mod.txt" >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "%ZIP_NAME%.zip created successfully!"

MOVE /Y "%ZIP_NAME%.zip" "..\packages" >NUL
POPD
IF EXIST "%TEMP_NAME%" RD /S /Q "%TEMP_NAME%"
EXIT /B


:SubGetVersion
rem Get the version
FOR /F "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_MAJOR" "..\src\Version.h"') DO (SET "VerMajor=%%K")
FOR /F "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_MINOR" "..\src\Version.h"') DO (SET "VerMinor=%%K")
FOR /F "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_BUILD" "..\src\Version.h"') DO (SET "VerBuild=%%K")
FOR /F "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_REV " "..\src\VersionRev.h"') DO (SET "VerRev=%%K")

SET NP2_VER=%VerMajor%.%VerMinor%.%VerBuild%.%VerRev%
EXIT /B


:SubSign
IF %ERRORLEVEL% NEQ 0 EXIT /B
REM %1 is the subfolder

CALL "%~dp0sign.bat" "..\%1\Notepad2.exe" || (CALL :SUBMSG "ERROR" "Problem signing ..\%1\Notepad2.exe" & GOTO Break)

CALL :SUBMSG "INFO" "..\%1\Notepad2.exe signed successfully."

:Break
EXIT /B


:SHOWHELP
TITLE %~nx0 %1
ECHO. & ECHO.
ECHO Usage:  %~nx0 [VS2010^|VS2012^|VS2013^|WDK]
ECHO.
ECHO Notes:  You can also prefix the commands with "-", "--" or "/".
ECHO         The arguments are not case sensitive.
ECHO. & ECHO.
ECHO Executing %~nx0 without any arguments is equivalent to "%~nx0 WDK"
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
