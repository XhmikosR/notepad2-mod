@ECHO OFF
SETLOCAL

PUSHD %~dp0

sh.exe ./version.sh

:END
POPD
ENDLOCAL
EXIT /B
