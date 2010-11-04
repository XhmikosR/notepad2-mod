@ECHO OFF
SETLOCAL
TITLE Building Notepad2...
SET NOTEPAD_VERSION=4.1.24

CALL build.cmd
CALL build_x64.cmd

CALL :SubZipFiles Release x86-32
CALL :SubZipFiles Release_x64 x86-64

GOTO :END


:END
TITLE Finished!
ECHO. && ECHO.
ENDLOCAL && PAUSE
EXIT


:SubZipFiles
TITLE Creating the ZIP files
ECHO.

FOR /f "tokens=3,4 delims= " %%K IN (
  'FINDSTR /I /L /C:"define VERSION_REV" "..\src\Version_rev.h"') DO (
  SET "buildnum=%%K"&Call :SubRevNumber %%buildnum:*Z=%%)

MD "temp_zip" >NUL 2>&1
COPY "..\License.txt" "temp_zip\" /Y /V
COPY "..\%1\Notepad2.exe" "temp_zip\" /Y /V
COPY "..\distrib\res\cabinet\Notepad2.ini" "temp_zip\" /Y /V
COPY "..\Notepad2.txt" "temp_zip\" /Y /V
COPY "..\ReadMe-mod.txt" "temp_zip\Readme.txt" /Y /V

PUSHD "temp_zip"
START "" /B /WAIT "..\..\distrib\tools\7za.exe" a -tzip -mx=9^
 "Notepad2-mod.%NOTEPAD_VERSION%_r%buildnum%_%2.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "Notepad2.txt" "ReadMe.txt" >NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected

ECHO:Notepad2-mod.%NOTEPAD_VERSION%_r%buildnum%_%2.zip created successfully!
MOVE /Y "Notepad2-mod.%NOTEPAD_VERSION%_r%buildnum%_%2.zip" ".." >NUL 2>&1
ECHO.
POPD
RD /S /Q "temp_zip" >NUL 2>&1
GOTO :EOF

:ErrorDetected
ECHO. && ECHO.
ECHO:Compilation FAILED!!!
ECHO. && ECHO.
ENDLOCAL
PAUSE
EXIT

:SubRevNumber
SET buildnum=%*
GOTO :EOF
