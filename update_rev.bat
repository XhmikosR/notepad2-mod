@ECHO OFF
SETLOCAL

PUSHD %~dp0

SET "SUBWCREV=SubWCRev.exe"

"%SUBWCREV%" . "src\Version.h.in" "src\VersionRev.h" -f
IF %ERRORLEVEL% NEQ 0 GOTO NoSubWCRev

"%SUBWCREV%" . "res\Notepad2.exe.manifest.conf" "res\Notepad2.exe.manifest" -f >NUL
IF %ERRORLEVEL% NEQ 0 GOTO NoSubWCRev

GOTO END

:NoSubWCRev
ECHO. & ECHO SubWCRev, which is part of TortoiseSVN, wasn't found!
ECHO You should (re)install TortoiseSVN.
ECHO I'll use VERSION_REV=0 for now.

TYPE "res\Notepad2.exe.manifest.template" > "res\Notepad2.exe.manifest"
TYPE "src\VersionRev.h.template"          > "src\VersionRev.h"

:END
POPD
ENDLOCAL
EXIT /B
