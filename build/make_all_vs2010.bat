@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * make_all_vs2010.bat
rem *   Batch file for building Notepad2 with MSVC2010
rem *   and creating the installer/zip packages
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                       (c) XhmikosR 2010-2011
rem *                                       http://code.google.com/p/notepad2-mod/
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0

CALL "build_vs2010.bat"
CALL "make_installer.bat" vs2010
CALL "make_zip.bat" vs2010


:END
TITLE Finished!
ECHO.
ENDLOCAL
PAUSE
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
