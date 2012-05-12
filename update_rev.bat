@ECHO OFF
SETLOCAL

PUSHD %~dp0

IF EXIST "SubWCRev.exe" SET "SUBWCREV=SubWCRev.exe"
FOR %%A IN (SubWCRev.exe) DO (SET SUBWCREV=%%~$PATH:A)
IF NOT DEFINED SUBWCREV GOTO SubNoSubWCRev

"%SUBWCREV%" . "src\Version.h.in" "src\VersionRev.h" -f
IF %ERRORLEVEL% NEQ 0 GOTO SubError

"%SUBWCREV%" . "res\Notepad2.exe.manifest.conf" "res\Notepad2.exe.manifest" -f >NUL
IF %ERRORLEVEL% NEQ 0 GOTO SubError
:END
POPD
ENDLOCAL
EXIT /B


:SubNoSubWCRev
ECHO. & ECHO SubWCRev, which is part of TortoiseSVN, wasn't found!
ECHO You should (re)install TortoiseSVN.
GOTO SubCommon

:SubError
ECHO Something went wrong when generating the revision number.

:SubCommon
ECHO I'll use VERSION_REV=0 for now.

TYPE "res\Notepad2.exe.manifest.template" > "res\Notepad2.exe.manifest"
TYPE "src\VersionRev.h.template"          > "src\VersionRev.h"
GOTO END
