@echo off

set perl_path=G:\Installation Programs\Programs\Compiling Stuff\Other\ActivePerl-5.12.2.1202-MSWin32-x86-293621

mkdir binaries >NUL 2>&1
mkdir binaries\x86-32 >NUL 2>&1
mkdir binaries\x86-64 >NUL 2>&1

copy /b /v /y ..\Release\Notepad2.exe res\cabinet\notepad2.exe
copy /b /v /y res\cabinet\*.* binaries\x86-32
cabutcd res\cabinet res\cabinet.x86-32.cab

copy /b /v /y ..\Release_x64\Notepad2.exe res\cabinet\notepad2.exe
copy /b /v /y res\cabinet\*.* binaries\x86-64
cabutcd res\cabinet res\cabinet.x86-64.cab

CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL
devenv setup.sln /Rebuild "Full|Win32"
devenv setup.sln /Rebuild "Full|x64"
devenv setup.sln /Rebuild "Lite|Win32"
devenv setup.sln /Rebuild "Lite|x64"

move bin.x86-32 setup.x86-32
move bin.x86-64 setup.x86-64
"%perl_path%\perl\bin\perl.exe" addon_build.pl

mkdir setup-bin >NUL 2>&1
move setup.x86-32\addon.7z      setup-bin\Notepad2Addon.x86-32.7z
move setup.x86-32\setupfull.exe setup-bin\SetupNotepad2.x86-32.exe
move setup.x86-32\setuplite.exe setup-bin\SetupNotepad2Silent.x86-32.exe
move setup.x86-64\addon.7z      setup-bin\Notepad2Addon.x86-64.7z
move setup.x86-64\setupfull.exe setup-bin\SetupNotepad2.x86-64.exe
move setup.x86-64\setuplite.exe setup-bin\SetupNotepad2Silent.x86-64.exe

rem cd binaries
rem del x86-32\notepad2.inf x86-32\notepad2.redir.ini
rem del x86-64\notepad2.inf x86-64\notepad2.redir.ini
rem zip -q -r -0 ..\setup-bin\Notepad2.zip x86-32 x86-64
rem cd ..

rem cd setup-bin
rem advzip -z -4 Notepad2.zip
rem md5sum  *.* | grep -U -P -v "\.(md5|sha1)" > .md5
rem sha1sum *.* | grep -U -P -v "\.(md5|sha1)" > .sha1
rem cd ..

if ["%1"] == ["/nopause"] goto end
pause

:end
