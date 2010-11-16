@ECHO OFF
SETLOCAL
rem SET "PERL_PATH=G:\Installation Programs\Programs\Compiling Stuff\Other\ActivePerl-5.12.2.1202-MSWin32-x86-293621"

rem Check the building environment
rem IF NOT EXIST "%PERL_PATH%" CALL :SUBMSG "INFO" "The Perl direcotry wasn't found; the addon won't be built"
IF NOT DEFINED VS100COMNTOOLS CALL :SUBMSG "INFO" "Visual Studio 2010 wasn't found; the installer won't be built"

CD /D %~dp0

CALL build.cmd
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SubVersion

CALL :SubZipFiles Release x86-32
CALL :SubZipFiles Release_x64 x86-64

IF DEFINED VS100COMNTOOLS (
  CALL :SubInstaller x86
  CALL :SubInstaller x64
)

rem Calulate md5/sha1 hashes
PUSHD packages
rem "..\..\distrib\tools\md5sum.exe" *.7z *.zip *.exe >md5hashes
rem "..\..\distrib\tools\sha1sum.exe" *.7z *.zip *.exe >sha1hashes

rem Compress everything into a single ZIP file
DEL Notepad2-mod.zip >NUL 2>&1
START "" /B /WAIT "..\..\distrib\tools\7za.exe" a -tzip -mx=9 Notepad2-mod.zip * -x!md5hashes -x!sha1hashes >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "Notepad2-mod.zip created successfully!"

POPD

:END
TITLE Finished!
ECHO.
ENDLOCAL
PAUSE
EXIT /B


:SubZipFiles
TITLE Creating the %2 ZIP file...
CALL :SUBMSG "INFO" "Creating the %2 ZIP file..."

MD "temp_zip" "packages" >NUL 2>&1
COPY /Y /V "..\License.txt" "temp_zip\"
COPY /Y /V "..\%1\Notepad2.exe" "temp_zip\"
COPY /Y /V "..\distrib\res\cabinet\notepad2.ini" "temp_zip\Notepad2.ini"
COPY /Y /V "..\Notepad2.txt" "temp_zip\"
COPY /Y /V "..\Readme.txt" "temp_zip\"
COPY /Y /V "..\Readme-mod.txt" "temp_zip\"

PUSHD "temp_zip"
START "" /B /WAIT "..\..\distrib\tools\7za.exe" a -tzip -mx=9^
 "Notepad2-mod.%NP2_VER%_r%VerRev%_%2.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "Notepad2.txt" "Readme.txt" "Readme-mod.txt" >NUL
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "Notepad2-mod.%NP2_VER%_r%VerRev%_%2.zip created successfully!"

MOVE /Y "Notepad2-mod.%NP2_VER%_r%VerRev%_%2.zip" "..\packages" >NUL 2>&1
POPD
RD /S /Q "temp_zip" >NUL 2>&1
GOTO :EOF

:SubInstaller
IF /I "%1"=="x86" (
  SET ARCH=Win32
  SET BINDIR=x86-32
  SET OUTDIR=Release
)
IF /I "%1"=="x64" (
  SET ARCH=x64
  SET BINDIR=x86-64
  SET OUTDIR=Release_x64
)

TITLE Building %BINDIR% installer...
CALL :SUBMSG "INFO" "Building %BINDIR% installer..."

PUSHD ..\distrib
MD temp\%BINDIR% >NUL 2>&1

COPY /B /V /Y ..\%OUTDIR%\Notepad2.exe temp\%BINDIR%\notepad2.exe
COPY /B /V /Y ..\License.txt temp\%BINDIR%\license.txt
COPY /B /V /Y res\cabinet\notepad2.inf temp\%BINDIR%\notepad2.inf
COPY /B /V /Y res\cabinet\notepad2.ini temp\%BINDIR%\notepad2.ini
COPY /B /V /Y res\cabinet\notepad2.redir.ini temp\%BINDIR%\notepad2.redir.ini
COPY /B /V /Y ..\Notepad2.txt temp\%BINDIR%\notepad2.txt
COPY /B /V /Y ..\Readme.txt temp\%BINDIR%\readme.txt
COPY /B /V /Y ..\Readme-mod.txt temp\%BINDIR%\readme-mod.txt
rem Set the version for the DisplayVersion registry value
CALL tools\BatchSubstitute.bat "0.0.0.0" %NP2_VER%.%VerRev% temp\%BINDIR%\notepad2.inf >notepad2.inf.tmp
COPY /Y temp\%BINDIR%\notepad2.inf notepad2.inf.orig >NUL
MOVE /Y notepad2.inf.tmp temp\%BINDIR%\notepad2.inf >NUL
tools\cabutcd.exe temp\%BINDIR% res\cabinet.%BINDIR%.cab
DEL notepad2.inf.orig >NUL 2>&1
RD /Q /S temp\%BINDIR% >NUL 2>&1

CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL
devenv setup.sln /Rebuild "Full|%ARCH%"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"
rem devenv setup.sln /Rebuild "Lite|%ARCH%"
rem IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

rem IF EXIST "%PERL_PATH%" (
rem   "%PERL_PATH%\perl\bin\perl.exe" addon_build.pl
rem )

MD ..\wdkbuild\packages >NUL 2>&1
rem IF EXIST "%PERL_PATH%" (
rem   MOVE setup.%BINDIR%\addon.7z    ..\wdkbuild\packages\Notepad2-mod_Addon.%BINDIR%.7z >NUL
rem )
MOVE setup.%BINDIR%\setupfull.exe ..\wdkbuild\packages\Notepad2-mod_Setup.%BINDIR%.exe >NUL
rem MOVE setup.%BINDIR%\setuplite.exe ..\wdkbuild\packages\Notepad2-mod_Setup_Silent.%BINDIR%.exe >NUL

rem Cleanup
RD /Q setup.%BINDIR% temp >NUL 2>&1
RD /Q /S addon obj >NUL 2>&1

POPD
GOTO :EOF

:SubVersion
rem Get the version
FOR /f "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_MAJOR" "..\src\Version.h"') DO (
  SET "VerMajor=%%K"&Call :SubVerMajor %%VerMajor:*Z=%%)
FOR /f "tokens=3,4 delims= " %%L IN (
  'FINDSTR /I /L /C:"define VERSION_MINOR" "..\src\Version.h"') DO (
  SET "VerMinor=%%L"&Call :SubVerMinor %%VerMinor:*Z=%%)
FOR /f "tokens=3,4 delims= " %%M IN (
  'FINDSTR /I /L /C:"define VERSION_BUILD" "..\src\Version.h"') DO (
  SET "VerBuild=%%M"&Call :SubVerBuild %%VerBuild:*Z=%%)
FOR /f "tokens=3,4 delims= " %%N IN (
  'FINDSTR /I /L /C:"define VERSION_REV" "..\src\Version_rev.h"') DO (
  SET "VerRev=%%N"&Call :SubVerRev %%VerRev:*Z=%%)

SET NP2_VER=%VerMajor%.%VerMinor%.%VerBuild%
GOTO :EOF

:SubVerMajor
SET VerMajor=%*
GOTO :EOF
:SubVerMinor
SET VerMinor=%*
GOTO :EOF
:SubVerBuild
SET VerBuild=%*
GOTO :EOF
:SubVerRev
SET VerRev=%*
GOTO :EOF

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
