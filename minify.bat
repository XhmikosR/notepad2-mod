@ECHO OFF
SETLOCAL

SET PATH=C:\MSYS\bin;%PATH%

ECHO Minifying and combining css and js files...

rem cat css\jquery.fancybox.css css\stylesheet.css | cleancss -o css\pack.css
cleancss css\jquery.fancybox.css -o css\jquery.fancybox.min.css && ^
cleancss css\stylesheet.css -o css\stylesheet.min.css && ^
cleancss css\print.css -o css\print.min.css && ^
uglifyjs --no-copyright -o js\jquery.fancybox.min.js js\jquery.fancybox.js

ENDLOCAL
PAUSE