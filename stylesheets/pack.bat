@ECHO OFF
SETLOCAL

SET PATH=C:\MSYS\bin;%PATH%

ECHO Minifying and combining css files...

cat print.css pygment_trac.css stylesheet.css | cleancss -o pack.css
cleancss -o print.min.css print.css && cleancss -o pygment_trac.min.css pygment_trac.css && cleancss -o stylesheet.min.css stylesheet.css

ENDLOCAL
PAUSE