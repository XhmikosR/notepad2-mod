@ECHO OFF
SETLOCAL

ECHO Minifying and combining css and js files...

TYPE css\jquery.fancybox.css css\jquery.fancybox-thumbs.css | cleancss --s0 -o css\jquery.fancybox.min.css
TYPE css\stylesheet.css css\print.css css\normalize.css | cleancss --s0 -o css\pack.css
cmd /c uglifyjs js\jquery.mousewheel.js js\jquery.fancybox.js js\jquery.fancybox-thumbs.js --compress --mangle -o js\pack.js

ENDLOCAL
rem PAUSE