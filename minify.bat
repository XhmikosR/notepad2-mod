@ECHO OFF
SETLOCAL

ECHO Minifying and combining css and js files...

PUSHD css
TYPE jquery.fancybox.css jquery.fancybox-thumbs.css | cleancss --s0 -o jquery.fancybox.min.css
TYPE stylesheet.css normalize.css | cleancss --s0 -o pack.css
POPD

PUSHD js
cmd /c uglifyjs jquery.mousewheel.js jquery.fancybox.js jquery.fancybox-thumbs.js plugins.js --compress --mangle -o pack.js
POPD

ENDLOCAL
rem PAUSE