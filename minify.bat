@ECHO OFF
SETLOCAL

SET PATH=C:\MSYS\bin;%PATH%

ECHO Minifying and combining css and js files...

cat css\jquery.fancybox.css css\jquery.fancybox-thumbs.css | cleancss --s0 -o css\jquery.fancybox.min.css
cat js\jquery.mousewheel.js js\jquery.fancybox.js js\jquery.fancybox-thumbs.js | uglifyjs --no-copyright -o js\pack.js && ^
cleancss css\stylesheet.css -o css\stylesheet.min.css && ^
cleancss css\print.css -o css\print.min.css

ENDLOCAL
PAUSE