@ECHO OFF
rem ******************************************************************************
rem *
rem * Notepad2-mod
rem *
rem * sign.bat
rem *   Batch file used to sign the binaries
rem *   Originally taken and adapted from  https://github.com/mpc-hc/mpc-hc
rem *
rem * See License.txt for details about distribution and modification.
rem *
rem *                                     (c) XhmikosR 2013-2015
rem *                                     https://github.com/XhmikosR/notepad2-mod
rem *
rem ******************************************************************************


SETLOCAL
SET "FILE_DIR=%~dp0"

IF "%~1" == "" (
  ECHO %~nx0: No input specified!
  SET SIGN_ERROR=True
  GOTO END
)

IF NOT DEFINED VS140COMNTOOLS (
  ECHO %~nx0: Visual Studio 2015 does not seem to be installed...
  SET SIGN_ERROR=True
  GOTO END
)

IF NOT EXIST "%FILE_DIR%..\signinfo.txt" (
  ECHO %~nx0: %FILE_DIR%..\signinfo.txt is not present!
  SET SIGN_ERROR=True
  GOTO END
)

signtool /? 2>NUL || CALL "%VS140COMNTOOLS%..\..\VC\vcvarsall.bat" 2>NUL
IF %ERRORLEVEL% NEQ 0 (
  ECHO vcvarsall.bat call failed.
  GOTO End
)

REM Repeat n times when signing fails
SET REPEAT=5
FOR /F "delims=" %%A IN (%FILE_DIR%..\signinfo.txt) DO (SET "SIGN_CMD=%%A" && CALL :START_SIGN %1)

:END
IF /I "%SIGN_ERROR%" == "True" (
  IF "%~1" == "" PAUSE
  ENDLOCAL
  EXIT /B 1
)
ENDLOCAL
EXIT /B

:START_SIGN
IF /I "%SIGN_ERROR%" == "True" EXIT /B
REM %1 is name of the file to sign
TITLE Signing "%~1"...
ECHO. & ECHO Signing "%~1"...
SET TRY=0

:SIGN
SET /A TRY+=1
signtool sign %SIGN_CMD% %1
IF %ERRORLEVEL% EQU 0 EXIT /B
IF %TRY% LSS %REPEAT% (
  REM Wait 5 seconds before next try
  PING -n 5 127.0.0.1 > NUL
  GOTO SIGN
)
SET SIGN_ERROR=True
