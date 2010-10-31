@echo off

mkdir binaries
mkdir binaries\x86-32
mkdir binaries\x86-64

copy /b /v /y ..\bin.x86-32\Notepad2.exe res\cabinet\notepad2.exe
copy /b /v /y res\cabinet\*.* binaries\x86-32
cabutcd res\cabinet res\cabinet.x86-32.cab

copy /b /v /y ..\bin.x86-64\Notepad2.exe res\cabinet\notepad2.exe
copy /b /v /y res\cabinet\*.* binaries\x86-64
cabutcd res\cabinet res\cabinet.x86-64.cab

vc6build.pl setup.dsp /skippost

move bin.x86-32 setup.x86-32
move bin.x86-64 setup.x86-64
addon_build.pl

mkdir setup-bin
move setup.x86-32\addon.7z      setup-bin\Notepad2Addon.x86-32.7z
move setup.x86-32\setupfull.exe setup-bin\SetupNotepad2.x86-32.exe
move setup.x86-32\setuplite.exe setup-bin\SetupNotepad2Silent.x86-32.exe
move setup.x86-64\addon.7z      setup-bin\Notepad2Addon.x86-64.7z
move setup.x86-64\setupfull.exe setup-bin\SetupNotepad2.x86-64.exe
move setup.x86-64\setuplite.exe setup-bin\SetupNotepad2Silent.x86-64.exe

cd binaries
del x86-32\notepad2.inf x86-32\notepad2.redir.ini
del x86-64\notepad2.inf x86-64\notepad2.redir.ini
zip -q -r -0 ..\setup-bin\Notepad2.zip x86-32 x86-64
cd ..

cd setup-bin
advzip -z -4 Notepad2.zip
md5sum  *.* | grep -U -P -v "\.(md5|sha1)" > .md5
sha1sum *.* | grep -U -P -v "\.(md5|sha1)" > .sha1
cd ..

if ["%1"] == ["/nopause"] goto end
pause

:end
