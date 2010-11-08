@ECHO OFF
set SCISRC=..\scintilla

rem create the objects and output directory and delete any files from previous build
md "%OBJDIR%" >NUL 2>&1
del "%OUTDIR%\Notepad2.exe" >NUL 2>&1
del "%OBJDIR%\*.idb" >NUL 2>&1
del "%OBJDIR%\*.obj" >NUL 2>&1
del "%OBJDIR%\*.pdb" >NUL 2>&1

ECHO. && ECHO:______________________________
ECHO:[INFO] compiling stage...
ECHO:______________________________ && ECHO.

rem compiler command line
IF /I "%1"=="x86" (
set CLADDCMD=/D "STATIC_BUILD" /D "SCI_LEXER" /D "_WINDOWS" /D "NDEBUG" /D "_UNICODE" /D "UNICODE" /D "WIN32" /D "_WIN32_WINNT=0x0501"
)
IF /I "%1"=="x64" (
set CLADDCMD=/D "STATIC_BUILD" /D "SCI_LEXER" /D "_WINDOWS" /D "NDEBUG" /D "_UNICODE" /D "UNICODE" /D "_WIN64" /D "_WIN32_WINNT=0x0502" /wd4133 /wd4244 /wd4267
)

cl /Fo"%OBJDIR%/" /I "%SCISRC%\include" /I "%SCISRC%\src" /I "%SCISRC%\win32" %CLADDCMD% /c /EHsc /MD /O2 /GS /GT /GL /W3 /MP^
 /Tp "%SCISRC%\src\AutoComplete.cxx" /Tp "%SCISRC%\src\CallTip.cxx" /Tp "%SCISRC%\src\CellBuffer.cxx"^
 /Tp "%SCISRC%\src\CharClassify.cxx" /Tp "%SCISRC%\src\ContractionState.cxx" /Tp "%SCISRC%\src\Decoration.cxx"^
 /Tp "%SCISRC%\src\Document.cxx" /Tp "%SCISRC%\src\DocumentAccessor.cxx" /Tp "%SCISRC%\src\Editor.cxx"^
 /Tp "%SCISRC%\src\ExternalLexer.cxx" /Tp "%SCISRC%\src\Indicator.cxx" /Tp "%SCISRC%\src\KeyMap.cxx"^
 /Tp "%SCISRC%\src\KeyWords.cxx" /Tp "%SCISRC%\src\LexAsm.cxx" /Tp "%SCISRC%\src\LexAU3.cxx"^
 /Tp "%SCISRC%\src\LexBash.cxx" /Tp "%SCISRC%\src\LexConf.cxx" /Tp "%SCISRC%\src\LexCPP.cxx"^
 /Tp "%SCISRC%\src\LexCSS.cxx" /Tp "%SCISRC%\src\LexHTML.cxx" /Tp "%SCISRC%\src\LexLua.cxx"^
 /Tp "%SCISRC%\src\LexInno.cxx" /Tp "%SCISRC%\src\LexNsis.cxx" /Tp "%SCISRC%\src\LexOthers.cxx"^
 /Tp "%SCISRC%\src\LexPascal.cxx" /Tp "%SCISRC%\src\LexPerl.cxx" /Tp "%SCISRC%\src\LexPowerShell.cxx"^
 /Tp "%SCISRC%\src\LexPython.cxx" /Tp "%SCISRC%\src\LexRuby.cxx" /Tp "%SCISRC%\src\LexSQL.cxx"^
 /Tp "%SCISRC%\src\LexTCL.cxx" /Tp "%SCISRC%\src\LexVB.cxx" /Tp "%SCISRC%\src\LineMarker.cxx"^
 /Tp "%SCISRC%\src\PerLine.cxx" /Tp "%SCISRC%\src\PositionCache.cxx" /Tp "%SCISRC%\src\PropSet.cxx"^
 /Tp "%SCISRC%\src\RESearch.cxx" /Tp "%SCISRC%\src\RunStyles.cxx" /Tp "%SCISRC%\src\ScintillaBase.cxx"^
 /Tp "%SCISRC%\src\Selection.cxx" /Tp "%SCISRC%\src\Style.cxx" /Tp "%SCISRC%\src\StyleContext.cxx"^
 /Tp "%SCISRC%\src\UniConversion.cxx" /Tp "%SCISRC%\src\ViewStyle.cxx" /Tp "%SCISRC%\src\WindowAccessor.cxx"^
 /Tp "%SCISRC%\src\XPM.cxx" /Tp "%SCISRC%\win32\PlatWin.cxx" /Tp "%SCISRC%\win32\ScintillaWin.cxx"^
 /Tc "..\src\Dialogs.c" /Tc "..\src\Dlapi.c" /Tc "..\src\Edit.c" /Tc "..\src\Helpers.c"^
 /Tc "..\src\Notepad2.c" /Tc "..\src\Styles.c" /Tp "..\src\Print.cpp"
IF %ERRORLEVEL% NEQ 0 ECHO:[ERROR]Compilation failed!&&PAUSE&&EXIT

ECHO. && ECHO:______________________________
ECHO:[INFO] resource compiler stage...
ECHO:______________________________ && ECHO.

rem resource compiler command line
IF /I "%1"=="x86" (
set RCADDCMD=/d "WIN32"
)
IF /I "%1"=="x64" (
set RCADDCMD=/d "_WIN64"
)

rc /d "_UNICODE" /d "UNICODE" %RCADDCMD% /fo"%OBJDIR%/Notepad2.res" "..\src\Notepad2.rc"
IF %ERRORLEVEL% NEQ 0 ECHO:[ERROR]Compilation failed!&&PAUSE&&EXIT

ECHO. && ECHO:______________________________
ECHO:[INFO] linking stage...
ECHO:______________________________ && ECHO.

rem linker command line
IF /I "%1"=="x86" (
set LNKADDCMD=/SUBSYSTEM:WINDOWS,5.01 /MACHINE:X86
set WDK_LIB=msvcrt_winxp.obj
)
IF /I "%1"=="x64" (
set LNKADDCMD=/SUBSYSTEM:WINDOWS,5.02 /MACHINE:X64
set WDK_LIB=msvcrt_win2003.obj
)

link /OUT:"%OUTDIR%/Notepad2.exe" /INCREMENTAL:NO /RELEASE %LNKADDCMD% /OPT:REF /OPT:ICF /DYNAMICBASE /NXCOMPAT^
 /MERGE:.rdata=.text /LTCG kernel32.lib user32.lib gdi32.lib advapi32.lib shell32.lib shlwapi.lib comdlg32.lib^
 comctl32.lib winspool.lib imm32.lib ole32.lib oleaut32.lib psapi.lib^
 "%OBJDIR%\AutoComplete.obj" "%OBJDIR%\CallTip.obj" "%OBJDIR%\CellBuffer.obj" "%OBJDIR%\CharClassify.obj"^
 "%OBJDIR%\ContractionState.obj" "%OBJDIR%\Decoration.obj" "%OBJDIR%\Dialogs.obj" "%OBJDIR%\Dlapi.obj"^
 "%OBJDIR%\Document.obj" "%OBJDIR%\DocumentAccessor.obj" "%OBJDIR%\Edit.obj" "%OBJDIR%\Editor.obj"^
 "%OBJDIR%\ExternalLexer.obj" "%OBJDIR%\Helpers.obj" "%OBJDIR%\Indicator.obj" "%OBJDIR%\KeyMap.obj"^
 "%OBJDIR%\KeyWords.obj" "%OBJDIR%\LexAsm.obj" "%OBJDIR%\LexAU3.obj" "%OBJDIR%\LexBash.obj" "%OBJDIR%\LexConf.obj"^
 "%OBJDIR%\LexCPP.obj" "%OBJDIR%\LexCSS.obj" "%OBJDIR%\LexHTML.obj" "%OBJDIR%\LexInno.obj" "%OBJDIR%\LexLua.obj"^
 "%OBJDIR%\LexNsis.obj" "%OBJDIR%\LexOthers.obj" "%OBJDIR%\LexPascal.obj" "%OBJDIR%\LexPerl.obj" "%OBJDIR%\LexPowerShell.obj"^
 "%OBJDIR%\LexPython.obj" "%OBJDIR%\LexRuby.obj" "%OBJDIR%\LexSQL.obj" "%OBJDIR%\LexTCL.obj" "%OBJDIR%\LexVB.obj"^
 "%OBJDIR%\LineMarker.obj" "%OBJDIR%\Notepad2.obj" "%OBJDIR%\Notepad2.res" "%OBJDIR%\PerLine.obj" "%OBJDIR%\PlatWin.obj"^
 "%OBJDIR%\PositionCache.obj" "%OBJDIR%\Print.obj" "%OBJDIR%\PropSet.obj" "%OBJDIR%\RESearch.obj" "%OBJDIR%\RunStyles.obj"^
 "%OBJDIR%\ScintillaBase.obj" "%OBJDIR%\ScintillaWin.obj" "%OBJDIR%\Selection.obj" "%OBJDIR%\Style.obj"^
 "%OBJDIR%\StyleContext.obj" "%OBJDIR%\Styles.obj" "%OBJDIR%\UniConversion.obj" "%OBJDIR%\ViewStyle.obj"^
 "%OBJDIR%\WindowAccessor.obj" "%OBJDIR%\XPM.obj" "%WDK_LIB%"
IF %ERRORLEVEL% NEQ 0 ECHO:[ERROR]Compilation failed!&&PAUSE&&EXIT

ECHO. && ECHO:______________________________
ECHO:[INFO] manifest stage...
ECHO:______________________________ && ECHO.

rem manifest tool command line
"%SDKDIR%\Bin\mt.exe" -manifest "..\res\Notepad2.exe.manifest" -outputresource:"%OUTDIR%\Notepad2.exe;#1"
IF %ERRORLEVEL% NEQ 0 ECHO:[ERROR]Compilation failed!&&PAUSE&&EXIT

ECHO. && ECHO:______________________________
