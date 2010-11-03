@echo off

set perl_path=G:\Installation Programs\Programs\Compiling Stuff\Other\ActivePerl-5.12.2.1202-MSWin32-x86-293621

IF NOT DEFINED VS100COMNTOOLS (
	ECHO:Visual Studio 2010 NOT FOUND!!! && PAUSE
	ECHO.
	GOTO :end
)

mkdir binaries\x86-32 >NUL 2>&1
mkdir binaries\x86-64 >NUL 2>&1

copy /b /v /y ..\Release\Notepad2.exe binaries\x86-32\notepad2.exe
copy /b /v /y ..\License.txt binaries\x86-32\license.txt
copy /b /v /y res\cabinet\notepad2.inf binaries\x86-32\notepad2.inf
copy /b /v /y res\cabinet\notepad2.ini binaries\x86-32\notepad2.ini
copy /b /v /y res\cabinet\notepad2.redir.ini binaries\x86-32\notepad2.redir.ini
copy /b /v /y res\cabinet\notepad2.txt binaries\x86-32\notepad2.txt
copy /b /v /y ..\Readme-mod.txt binaries\x86-32\readme.txt
tools\cabutcd.exe binaries\x86-32 res\cabinet.x86-32.cab
rd /q /s binaries\x86-32 >NUL 2>&1

copy /b /v /y ..\Release_x64\Notepad2.exe binaries\x86-64\notepad2.exe
copy /b /v /y ..\License.txt binaries\x86-64\license.txt
copy /b /v /y res\cabinet\notepad2.inf binaries\x86-64\notepad2.inf
copy /b /v /y res\cabinet\notepad2.ini binaries\x86-64\notepad2.ini
copy /b /v /y res\cabinet\notepad2.redir.ini binaries\x86-64\notepad2.redir.ini
copy /b /v /y res\cabinet\notepad2.txt binaries\x86-64\notepad2.txt
copy /b /v /y ..\Readme-mod.txt binaries\x86-64\readme.txt
tools\cabutcd.exe binaries\x86-64 res\cabinet.x86-64.cab
rd /q /s binaries\x86-64 >NUL 2>&1
rd /q binaries >NUL 2>&1

CALL "%VS100COMNTOOLS%vsvars32.bat" >NUL
devenv setup.sln /Rebuild "Full|Win32"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT
devenv setup.sln /Rebuild "Full|x64"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT
devenv setup.sln /Rebuild "Lite|Win32"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT
devenv setup.sln /Rebuild "Lite|x64"
IF %ERRORLEVEL% NEQ 0 ECHO:Compilation failed!&&PAUSE&&EXIT

"%perl_path%\perl\bin\perl.exe" addon_build.pl

mkdir setup-bin >NUL 2>&1
move setup.x86-32\addon.7z      setup-bin\Notepad2_Addon.x86-32.7z >NUL
move setup.x86-32\setupfull.exe setup-bin\Notepad2_Setup.x86-32.exe >NUL
move setup.x86-32\setuplite.exe setup-bin\Notepad2_Setup_Silent.x86-32.exe >NUL
move setup.x86-64\addon.7z      setup-bin\Notepad2_Addon.x86-64.7z >NUL
move setup.x86-64\setupfull.exe setup-bin\Notepad2_Setup.x86-64.exe >NUL
move setup.x86-64\setuplite.exe setup-bin\Notepad2_Setup_Silent.x86-64.exe >NUL

rd setup.x86-32 setup.x86-64 >NUL 2>&1
rd setup.x86-32 setup.x86-64 >NUL 2>&1
rd /q /s addon >NUL 2>&1
rd /q /s obj >NUL 2>&1

pushd setup-bin
rem advzip -z -4 Notepad2.zip
md5sum  *.* | grep -U -v "\.(md5|sha1)" > md5hashes
sha1sum *.* | grep -U -v "\.(md5|sha1)" > sha1hashes
popd

if ["%1"] == ["/nopause"] goto end
pause

:end
