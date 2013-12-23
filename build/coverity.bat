@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * coverity.bat
rem *   Batch file used to create the coverity scan analysis file
rem *   Originally taken and adapted from  https://github.com/mpc-hc/mpc-hc
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                       (c) XhmikosR 2013
rem *                                       https://github.com/XhmikosR/notepad2-mod
rem *
rem ******************************************************************************


SETLOCAL

PUSHD %~dp0

IF NOT DEFINED COVDIR SET "COVDIR=H:\progs\thirdparty\cov-analysis-win64-6.6.1"
IF DEFINED COVDIR IF NOT EXIST "%COVDIR%" (
  ECHO.
  ECHO ERROR: Coverity not found in "%COVDIR%"
  GOTO End
)


CALL "%VS110COMNTOOLS%..\..\VC\vcvarsall.bat" x86
IF %ERRORLEVEL% NEQ 0 (
  ECHO vcvarsall.bat call failed.
  GOTO End
)

IF EXIST "cov-int" RD /q /s "cov-int"

"%COVDIR%\bin\cov-build.exe" --dir cov-int "build_vs2012.bat" Rebuild All Release

IF EXIST "Notepad2-mod.tar" DEL "Notepad2-mod.tar"
IF EXIST "Notepad2-mod.tgz" DEL "Notepad2-mod.tgz"


:tar
tar --version 1>&2 2>NUL || (ECHO. & ECHO ERROR: tar not found & GOTO SevenZip)
tar czvf "Notepad2-mod.tgz" "cov-int"
GOTO End


:SevenZip
IF NOT EXIST "%PROGRAMFILES%\7za.exe" (
  ECHO.
  ECHO ERROR: "%PROGRAMFILES%\7za.exe" not found
  GOTO End
)
"%PROGRAMFILES%\7za.exe" a -ttar "Notepad2-mod.tar" "cov-int"
"%PROGRAMFILES%\7za.exe" a -tgzip "Notepad2-mod.tgz" "Notepad2-mod.tar"
IF EXIST "Notepad2-mod.tar" DEL "Notepad2-mod.tar"


:End
POPD
ECHO. & ECHO Press any key to close this window...
PAUSE >NUL
ENDLOCAL
EXIT /B
