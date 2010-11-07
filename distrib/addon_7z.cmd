@echo off

pushd addon
..\tools\7za.exe a -t7z -mx=9 -mmt=off -r ..\%1\addon.7z * >NUL
popd
