@ECHO OFF

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

cl /Fo"%OBJDIR%/" /I "..\scintilla\include" /I "..\scintilla\src" /I "..\scintilla\win32" %CLADDCMD% /c /EHsc /MD /O1 /W3 /MP^
 /Tp "..\scintilla\src\AutoComplete.cxx"^
 /Tp "..\scintilla\src\CallTip.cxx"^
 /Tp "..\scintilla\src\CellBuffer.cxx"^
 /Tp "..\scintilla\src\CharClassify.cxx"^
 /Tp "..\scintilla\src\ContractionState.cxx"^
 /Tp "..\scintilla\src\Decoration.cxx"^
 /Tp "..\scintilla\src\Document.cxx"^
 /Tp "..\scintilla\src\DocumentAccessor.cxx"^
 /Tp "..\scintilla\src\Editor.cxx"^
 /Tp "..\scintilla\src\ExternalLexer.cxx"^
 /Tp "..\scintilla\src\Indicator.cxx"^
 /Tp "..\scintilla\src\KeyMap.cxx"^
 /Tp "..\scintilla\src\KeyWords.cxx"^
 /Tp "..\scintilla\src\LexAsm.cxx"^
 /Tp "..\scintilla\src\LexConf.cxx"^
 /Tp "..\scintilla\src\LexCPP.cxx"^
 /Tp "..\scintilla\src\LexCSS.cxx"^
 /Tp "..\scintilla\src\LexHTML.cxx"^
 /Tp "..\scintilla\src\LexOthers.cxx"^
 /Tp "..\scintilla\src\LexPascal.cxx"^
 /Tp "..\scintilla\src\LexPerl.cxx"^
 /Tp "..\scintilla\src\LexPowerShell.cxx"^
 /Tp "..\scintilla\src\LexPython.cxx"^
 /Tp "..\scintilla\src\LexSQL.cxx"^
 /Tp "..\scintilla\src\LexVB.cxx"^
 /Tp "..\scintilla\src\LineMarker.cxx"^
 /Tp "..\scintilla\src\PerLine.cxx"^
 /Tp "..\scintilla\src\PositionCache.cxx"^
 /Tp "..\scintilla\src\PropSet.cxx"^
 /Tp "..\scintilla\src\RESearch.cxx"^
 /Tp "..\scintilla\src\RunStyles.cxx"^
 /Tp "..\scintilla\src\ScintillaBase.cxx"^
 /Tp "..\scintilla\src\Selection.cxx"^
 /Tp "..\scintilla\src\Style.cxx"^
 /Tp "..\scintilla\src\StyleContext.cxx"^
 /Tp "..\scintilla\src\UniConversion.cxx"^
 /Tp "..\scintilla\src\ViewStyle.cxx"^
 /Tp "..\scintilla\src\WindowAccessor.cxx"^
 /Tp "..\scintilla\src\XPM.cxx"^
 /Tp "..\scintilla\win32\PlatWin.cxx"^
 /Tp "..\scintilla\win32\ScintillaWin.cxx"^
 /Tc "..\src\Dialogs.c"^
 /Tc "..\src\Dlapi.c"^
 /Tc "..\src\Edit.c"^
 /Tc "..\src\Helpers.c"^
 /Tc "..\src\Notepad2.c"^
 /Tc "..\src\Styles.c"^
 /Tp "..\src\Print.cpp"
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
set LNKADDCMD=/SUBSYSTEM:WINDOWS,5.0 /MACHINE:X86
set WDK_LIB=msvcrt_winxp.obj
)
IF /I "%1"=="x64" (
set LNKADDCMD=/SUBSYSTEM:WINDOWS,5.02 /MACHINE:X64
set WDK_LIB=msvcrt_win2003.obj
)

link /OUT:"%OUTDIR%/Notepad2.exe" /INCREMENTAL:NO /RELEASE %LNKADDCMD% /OPT:REF /OPT:ICF /MERGE:.rdata=.text^
 kernel32.lib user32.lib gdi32.lib advapi32.lib shell32.lib shlwapi.lib comdlg32.lib comctl32.lib winspool.lib^
 imm32.lib ole32.lib oleaut32.lib psapi.lib^
 "%OBJDIR%\AutoComplete.obj"^
 "%OBJDIR%\CallTip.obj"^
 "%OBJDIR%\CellBuffer.obj"^
 "%OBJDIR%\CharClassify.obj"^
 "%OBJDIR%\ContractionState.obj"^
 "%OBJDIR%\Decoration.obj"^
 "%OBJDIR%\Dialogs.obj"^
 "%OBJDIR%\Dlapi.obj"^
 "%OBJDIR%\Document.obj"^
 "%OBJDIR%\DocumentAccessor.obj"^
 "%OBJDIR%\Edit.obj"^
 "%OBJDIR%\Editor.obj"^
 "%OBJDIR%\ExternalLexer.obj"^
 "%OBJDIR%\Helpers.obj"^
 "%OBJDIR%\Indicator.obj"^
 "%OBJDIR%\KeyMap.obj"^
 "%OBJDIR%\KeyWords.obj"^
 "%OBJDIR%\LexAsm.obj"^
 "%OBJDIR%\LexConf.obj"^
 "%OBJDIR%\LexCPP.obj"^
 "%OBJDIR%\LexCSS.obj"^
 "%OBJDIR%\LexHTML.obj"^
 "%OBJDIR%\LexOthers.obj"^
 "%OBJDIR%\LexPascal.obj"^
 "%OBJDIR%\LexPerl.obj"^
 "%OBJDIR%\LexPowerShell.obj"^
 "%OBJDIR%\LexPython.obj"^
 "%OBJDIR%\LexSQL.obj"^
 "%OBJDIR%\LexVB.obj"^
 "%OBJDIR%\LineMarker.obj"^
 "%OBJDIR%\Notepad2.obj"^
 "%OBJDIR%\Notepad2.res"^
 "%OBJDIR%\PerLine.obj"^
 "%OBJDIR%\PlatWin.obj"^
 "%OBJDIR%\PositionCache.obj"^
 "%OBJDIR%\Print.obj"^
 "%OBJDIR%\PropSet.obj"^
 "%OBJDIR%\RESearch.obj"^
 "%OBJDIR%\RunStyles.obj"^
 "%OBJDIR%\ScintillaBase.obj"^
 "%OBJDIR%\ScintillaWin.obj"^
 "%OBJDIR%\Selection.obj"^
 "%OBJDIR%\Style.obj"^
 "%OBJDIR%\StyleContext.obj"^
 "%OBJDIR%\Styles.obj"^
 "%OBJDIR%\UniConversion.obj"^
 "%OBJDIR%\ViewStyle.obj"^
 "%OBJDIR%\WindowAccessor.obj"^
 "%OBJDIR%\XPM.obj"^
 "%WDK_LIB%"
IF %ERRORLEVEL% NEQ 0 ECHO:[ERROR]Compilation failed!&&PAUSE&&EXIT

ECHO. && ECHO:______________________________
ECHO:[INFO] manifest stage...
ECHO:______________________________ && ECHO.

rem manifest tool command line
"%SDKDIR%\Bin\mt.exe" -manifest "..\res\Notepad2.exe.manifest" -outputresource:"%OUTDIR%\Notepad2.exe;#1"
IF %ERRORLEVEL% NEQ 0 ECHO:[ERROR]Compilation failed!&&PAUSE&&EXIT

ECHO. && ECHO:______________________________
