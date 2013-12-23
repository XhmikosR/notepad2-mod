@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * make_all_icl13.bat
rem *   Batch file for building Notepad2 with ICL13
rem *   and creating the installer/zip packages
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                     (c) XhmikosR 2010-2013
rem *                                     https://github.com/XhmikosR/notepad2-mod
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0

CALL "build_icl13.bat" %1
CALL "make_installer.bat" icl13
CALL "make_zip.bat" icl13


:END
TITLE Finished!
ECHO.
PAUSE
ENDLOCAL
EXIT /B
