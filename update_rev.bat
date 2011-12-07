@ECHO OFF
SETLOCAL

PUSHD %~dp0%

SET "SUBWCREV=SubWCRev.exe"

"%SUBWCREV%" . "src\Version_in.h" "src\Version_rev.h" -f
IF %ERRORLEVEL% NEQ 0 GOTO NoSubWCRev

"%SUBWCREV%" . "res\Notepad2.exe.manifest.conf" "res\Notepad2.exe.manifest" -f >NUL
IF %ERRORLEVEL% NEQ 0 GOTO NoSubWCRev

"%SUBWCREV%" . "distrib\res\full\setup.manifest.conf" "distrib\res\full\setup.manifest" -f >NUL
IF %ERRORLEVEL% NEQ 0 GOTO NoSubWCRev

"%SUBWCREV%" . "distrib\res\lite\setup.manifest.conf" "distrib\res\lite\setup.manifest" -f >NUL
IF %ERRORLEVEL% NEQ 0 GOTO NoSubWCRev

POPD
ENDLOCAL
EXIT /B


:NoSubWCRev
ECHO. & ECHO SubWCRev, which is part of TortoiseSVN, wasn't found!
ECHO You should (re)install TortoiseSVN.
ECHO I'll use VERSION_REV=0 for now.

COPY /V /Y "src\Version_rev.h.template"               "src\Version_rev.h" >NUL
COPY /V /Y "res\Notepad2.exe.manifest.template"       "res\Notepad2.exe.manifest" >NUL
COPY /V /Y "distrib\res\full\setup.manifest.template" "distrib\res\full\setup.manifest" >NUL
COPY /V /Y "distrib\res\lite\setup.manifest.template" "distrib\res\lite\setup.manifest" >NUL

POPD
ENDLOCAL
EXIT /B
