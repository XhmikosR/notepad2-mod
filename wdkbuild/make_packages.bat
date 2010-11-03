@ECHO OFF
SETLOCAL
TITLE Building Notepad2...
SET NOTEPAD_VERSION=4.1.24.6

PUSHD ..
FOR /f "usebackq tokens=1,2 delims== " %%i IN (`svn --xml info`) DO IF "%%i"=="revision" SET SVNREV=%%j
SET SVNREV=%SVNREV:~1,-2%
POPD

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
MD "temp_zip" >NUL 2>&1
COPY "..\License.txt" "temp_zip\" /Y /V
COPY "..\%1\Notepad2.exe" "temp_zip\" /Y /V
COPY "..\distrib\Notepad2.ini" "temp_zip\" /Y /V
COPY "..\distrib\notepad2.redir.ini" "temp_zip\" /Y /V
COPY "..\distrib\setup_old\res\cabinet\Notepad2.inf" "temp_zip\" /Y /V
COPY "..\Notepad2.txt" "temp_zip\" /Y /V
COPY "..\ReadMe-mod.txt" "temp_zip\Readme.txt" /Y /V

PUSHD "temp_zip"
START "" /B /WAIT "..\..\distrib\setup_old\tools\7za.exe" a -tzip -mx=9^
 "Notepad2-mod.%NOTEPAD_VERSION%_r%SVNREV%_%2.zip" "License.txt" "Notepad2.exe"^
 "Notepad2.ini" "notepad2.redir.ini" "Notepad2.inf" "Notepad2.txt" "ReadMe.txt" >NUL
IF %ERRORLEVEL% NEQ 0 GOTO :ErrorDetected

ECHO:Notepad2-mod.%NOTEPAD_VERSION%_r%SVNREV%_%2.zip created successfully!
MOVE /Y "Notepad2-mod.%NOTEPAD_VERSION%_r%SVNREV%_%2.zip" ".." >NUL 2>&1
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