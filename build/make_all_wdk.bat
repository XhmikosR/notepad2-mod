@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * make_all_wdk.bat
rem *   Batch file for building Notepad2 with WDK
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

CALL "build_wdk.bat" %1
CALL "make_installer.bat" wdk
CALL "make_zip.bat" wdk


:END
TITLE Finished!
ECHO.
PAUSE
ENDLOCAL
EXIT /B
