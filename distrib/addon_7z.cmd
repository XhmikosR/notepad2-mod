@echo off

pushd addon
..\tools\7za.exe a -t7z -mx=9 -mmt=off -r ..\%1\addon.7z *
popd

rem pushd %1
rem md5sum addon.7z >> setup.md5
rem popd
