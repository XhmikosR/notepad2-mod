@ECHO OFF
SETLOCAL

SET PATH=C:\MSYS\bin;%PATH%

ECHO Minifying and combining css files...

cleancss stylesheet.css -o stylesheet.min.css
cleancss print.css -o print.min.css

ENDLOCAL
PAUSE