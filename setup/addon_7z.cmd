@echo off

pushd addon
"%ProgramFiles%\7-Zip\7z.exe" a -t7z -mx=9 -mmt=off -r ..\%1\addon.7z *
popd

pushd %1
md5sum addon.7z >> setup.md5
popd
