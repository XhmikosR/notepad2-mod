@ECHO OFF
SubWCRev .\ src\Version_in.h src\Version_rev.h
SubWCRev .\ res\Notepad2.exe.manifest.conf res\Notepad2.exe.manifest
IF %ERRORLEVEL% NEQ 0 GOTO :NoSubWCRev
GOTO :EOF

:NoSubWCRev
ECHO:NoSubWCRev
ECHO:#define VERSION_REV 0 > src\Version_rev.h
COPY /Y res\Notepad2.exe.manifest.template res\Notepad2.exe.manifest
