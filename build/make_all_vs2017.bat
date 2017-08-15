@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * make_all_vs2015.bat
rem *   Batch file for building Notepad2 with MSVC2015
rem *   and creating the installer/zip packages
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                     (c) XhmikosR 2010-2015, 2017
rem *                                     https://github.com/XhmikosR/notepad2-mod
rem *
rem ******************************************************************************

SETLOCAL
CD /D %~dp0

CALL "build_vs2017.bat" %1
CALL "make_installer.bat" vs2017
CALL "make_zip.bat" vs2017


:END
TITLE Finished!
ECHO.
PAUSE
ENDLOCAL
EXIT /B
