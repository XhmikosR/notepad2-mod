@ECHO OFF
SETLOCAL

ECHO Minifying and combining css and js files...

TYPE css\jquery.fancybox.css css\jquery.fancybox-thumbs.css | cleancss --s0 -o css\jquery.fancybox.min.css
TYPE js\jquery.mousewheel.js js\jquery.fancybox.js js\jquery.fancybox-thumbs.js | uglifyjs --no-copyright -o js\pack.js
TYPE css\stylesheet.css css\normalize.css | cleancss --s0 -o css\stylesheet.min.css
TYPE css\print.css css\normalize.css | cleancss --s0 -o css\print.min.css

ENDLOCAL
PAUSE