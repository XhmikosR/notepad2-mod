@ECHO OFF
SETLOCAL
TITLE Building Notepad2...
SET PERL_PATH=G:\Installation Programs\Programs\Compiling Stuff\Other\ActivePerl-5.12.2.1202-MSWin32-x86-293621

SET TOOLS_PATH=..\..\distrib\tools

CALL build.cmd
CALL build_x64.cmd

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

SET NOTEPAD_VERSION=%VerMajor%.%VerMinor%.%VerBuild%


CALL :SubZipFiles Release x86-32
CALL :SubZipFiles Release_x64 x86-64

CALL :SubInstaller

rem Calulate md5/sha1 hashes
PUSHD packages
"%TOOLS_PATH%\md5sum.exe" *.7z *.zip *.exe >md5hashes
"%TOOLS_PATH%\sha1sum.exe" *.7z *.zip *.exe >sha1hashes

rem Compress everything into a single ZIP file
DEL Notepad2-mod.zip >NUL 2>&1
START "" /B /WAIT "%TOOLS_PATH%\7za.exe" a -tzip -mx=9 Notepad2-mod.zip * -x!md5hashes -x!sha1hashes >NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected
ECHO. && ECHO:Notepad2-mod.zip created successfully!

POPD
GOTO :END

:END
TITLE Finished!
ECHO. && ECHO.
ENDLOCAL && PAUSE
EXIT


:SubZipFiles
TITLE Creating the ZIP files...
ECHO.

MD "temp_zip" >NUL 2>&1
MD "packages" >NUL 2>&1
COPY "..\License.txt" "temp_zip\" /Y /V
COPY "..\%1\Notepad2.exe" "temp_zip\" /Y /V
COPY "..\distrib\res\cabinet\notepad2.ini" "temp_zip\Notepad2.ini" /Y /V
COPY "..\Notepad2.txt" "temp_zip\" /Y /V
COPY "..\ReadMe-mod.txt" "temp_zip\Readme.txt" /Y /V

PUSHD "temp_zip"
START "" /B /WAIT "%TOOLS_PATH%\7za.exe" a -tzip -mx=9^
 "Notepad2-mod.%NOTEPAD_VERSION%_r%VerRev%_%2.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "Notepad2.txt" "ReadMe.txt" >NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected

ECHO:Notepad2-mod.%NOTEPAD_VERSION%_r%VerRev%_%2.zip created successfully!
MOVE /Y "Notepad2-mod.%NOTEPAD_VERSION%_r%VerRev%_%2.zip" "..\packages" >NUL 2>&1
ECHO.
POPD
RD /S /Q "temp_zip" >NUL 2>&1
GOTO :EOF

:SubInstaller
IF NOT DEFINED VS100COMNTOOLS (
  ECHO:Visual Studio 2010 NOT FOUND!!! && PAUSE
  ECHO.
  GOTO :ErrorDetected
)

TITLE Building installer...
ECHO:Building installer...

PUSHD ..\distrib
MD binaries\x86-32 >NUL 2>&1
MD binaries\x86-64 >NUL 2>&1

COPY /B /V /Y ..\Release\Notepad2.exe binaries\x86-32\notepad2.exe
COPY /B /V /Y ..\License.txt binaries\x86-32\license.txt
COPY /B /V /Y res\cabinet\notepad2.inf binaries\x86-32\notepad2.inf
COPY /B /V /Y res\cabinet\notepad2.ini binaries\x86-32\notepad2.ini
COPY /B /V /Y res\cabinet\notepad2.redir.ini binaries\x86-32\notepad2.redir.ini
COPY /B /V /Y ..\Notepad2.txt binaries\x86-32\notepad2.txt
COPY /B /V /Y ..\Readme-mod.txt binaries\x86-32\readme.txt
rem Set the version for the DisplayVersion registry value
CALL tools\BatchSubstitute.bat "0.0.0.0" %NOTEPAD_VERSION%.%VerRev% binaries\x86-32\notepad2.inf >notepad2.inf.temp
COPY /Y binaries\x86-32\notepad2.inf notepad2.inf.orig >NUL
MOVE /Y notepad2.inf.temp binaries\x86-32\notepad2.inf >NUL
tools\cabutcd.exe binaries\x86-32 res\cabinet.x86-32.cab
DEL notepad2.inf.orig >NUL 2>&1
RD /Q /S binaries\x86-32 >NUL 2>&1

COPY /B /V /Y ..\Release_x64\Notepad2.exe binaries\x86-64\notepad2.exe
COPY /B /V /Y ..\License.txt binaries\x86-64\license.txt
COPY /B /V /Y res\cabinet\notepad2.inf binaries\x86-64\notepad2.inf
COPY /B /V /Y res\cabinet\notepad2.ini binaries\x86-64\notepad2.ini
COPY /B /V /Y res\cabinet\notepad2.redir.ini binaries\x86-64\notepad2.redir.ini
COPY /B /V /Y ..\Notepad2.txt binaries\x86-64\notepad2.txt
COPY /B /V /Y ..\Readme-mod.txt binaries\x86-64\readme.txt
rem Set the version for the DisplayVersion registry value
CALL tools\BatchSubstitute.bat "0.0.0.0" %NOTEPAD_VERSION%.%VerRev% binaries\x86-64\notepad2.inf >notepad2.inf.temp
COPY /Y binaries\x86-64\notepad2.inf notepad2.inf.orig >NUL
MOVE /Y notepad2.inf.temp binaries\x86-64\notepad2.inf >NUL
tools\cabutcd.exe binaries\x86-64 res\cabinet.x86-64.cab
DEL notepad2.inf.orig >NUL 2>&1
RD /Q /S binaries\x86-64 >NUL 2>&1
RD /q binaries >NUL 2>&1

CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL
devenv setup.sln /Rebuild "Full|Win32"
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected
devenv setup.sln /Rebuild "Full|x64"
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected
devenv setup.sln /Rebuild "Lite|Win32"
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected
devenv setup.sln /Rebuild "Lite|x64"
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected

"%PERL_PATH%\perl\bin\perl.exe" addon_build.pl

MD ..\wdkbuild\packages >NUL 2>&1
MOVE setup.x86-32\addon.7z      ..\wdkbuild\packages\Notepad2-mod_Addon.x86-32.7z >NUL
MOVE setup.x86-32\setupfull.exe ..\wdkbuild\packages\Notepad2-mod_Setup.x86-32.exe >NUL
MOVE setup.x86-32\setuplite.exe ..\wdkbuild\packages\Notepad2-mod_Setup_Silent.x86-32.exe >NUL
MOVE setup.x86-64\addon.7z      ..\wdkbuild\packages\Notepad2-mod_Addon.x86-64.7z >NUL
MOVE setup.x86-64\setupfull.exe ..\wdkbuild\packages\Notepad2-mod_Setup.x86-64.exe >NUL
MOVE setup.x86-64\setuplite.exe ..\wdkbuild\packages\Notepad2-mod_Setup_Silent.x86-64.exe >NUL

RD setup.x86-32 setup.x86-64 >NUL 2>&1
RD setup.x86-32 setup.x86-64 >NUL 2>&1
RD /Q /S addon >NUL 2>&1
RD /Q /S obj >NUL 2>&1

POPD
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

:ErrorDetected
ECHO. && ECHO.
ECHO:Compilation FAILED!!!
ECHO. && ECHO.
ENDLOCAL
PAUSE
EXIT