@ECHO OFF
SETLOCAL

PUSHD %~dp0

IF EXIST "build.user.bat" (CALL "build.user.bat")

SET PATH=%MSYS%\bin;%PATH%

FOR %%G IN (bash.exe) DO (SET FOUND=%%~$PATH:G)
IF NOT DEFINED FOUND GOTO MissingVar

bash.exe ./version.sh


:END
POPD
ENDLOCAL
EXIT /B


:MissingVar
COLOR 0C
TITLE ERROR
ECHO MSYS (bash.exe) wasn't found. Create a file build.user.bat and set the variable there.
ECHO.
ECHO SET "MSYS=H:\progs\MSYS"
ECHO. & ECHO.
ECHO Press any key to exit...
PAUSE >NUL
ENDLOCAL
EXIT /B
