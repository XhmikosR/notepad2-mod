@ECHO OFF

IF /I "%1"=="" CALL :SUBMSG "ERROR" "Don't run this script directly, use build.cmd instead!"

rem create the objects and output directory and delete any files from previous build
MD "%OBJDIR%" >NUL 2>&1
DEL "%OUTDIR%\Notepad2.exe" >NUL 2>&1
DEL "%OBJDIR%\*.idb" "%OBJDIR%\*.obj" "%OBJDIR%\*.pdb" "%OBJDIR%\*.res" >NUL 2>&1

TITLE Building Notepad2 %1...
CALL :SUBMSG "INFO" "%1 compilation started!"

rem compiler command line
CALL :SUBMSG "INFO" "compiling stage..."

IF /I "%1"=="x86" (SET CLADDCMD=/D "WIN32" /D "_WIN32_WINNT=0x0501")
IF /I "%1"=="x64" (SET CLADDCMD=/D "_WIN64" /D "_WIN32_WINNT=0x0502" /wd4133 /wd4244 /wd4267)

cl /Fo"%OBJDIR%/" /I "..\scintilla\include" /I "..\scintilla\lexers" /I "..\scintilla\lexlib" /I "..\scintilla\src" /I "..\scintilla\win32"^
 /D "STATIC_BUILD" /D "SCI_LEXER" /D "_WINDOWS" /D "NDEBUG" /D "_UNICODE" /D "UNICODE" %CLADDCMD%^
 /c /EHsc /MD /O1 /W3 /MP^
 /Tp "..\scintilla\lexers\LexAsm.cxx"^
 /Tp "..\scintilla\lexers\LexConf.cxx"^
 /Tp "..\scintilla\lexers\LexCPP.cxx"^
 /Tp "..\scintilla\lexers\LexCSS.cxx"^
 /Tp "..\scintilla\lexers\LexHTML.cxx"^
 /Tp "..\scintilla\lexers\LexOthers.cxx"^
 /Tp "..\scintilla\lexers\LexPascal.cxx"^
 /Tp "..\scintilla\lexers\LexPerl.cxx"^
 /Tp "..\scintilla\lexers\LexPowerShell.cxx"^
 /Tp "..\scintilla\lexers\LexPython.cxx"^
 /Tp "..\scintilla\lexers\LexSQL.cxx"^
 /Tp "..\scintilla\lexers\LexVB.cxx"^
 /Tp "..\scintilla\lexlib\Accessor.cxx"^
 /Tp "..\scintilla\lexlib\CharacterSet.cxx"^
 /Tp "..\scintilla\lexlib\LexerBase.cxx"^
 /Tp "..\scintilla\lexlib\LexerModule.cxx"^
 /Tp "..\scintilla\lexlib\LexerSimple.cxx"^
 /Tp "..\scintilla\lexlib\PropSetSimple.cxx"^
 /Tp "..\scintilla\lexlib\StyleContext.cxx"^
 /Tp "..\scintilla\lexlib\WordList.cxx"^
 /Tp "..\scintilla\src\AutoComplete.cxx"^
 /Tp "..\scintilla\src\CallTip.cxx"^
 /Tp "..\scintilla\src\Catalogue.cxx"^
 /Tp "..\scintilla\src\CellBuffer.cxx"^
 /Tp "..\scintilla\src\CharClassify.cxx"^
 /Tp "..\scintilla\src\ContractionState.cxx"^
 /Tp "..\scintilla\src\Decoration.cxx"^
 /Tp "..\scintilla\src\Document.cxx"^
 /Tp "..\scintilla\src\Editor.cxx"^
 /Tp "..\scintilla\src\ExternalLexer.cxx"^
 /Tp "..\scintilla\src\Indicator.cxx"^
 /Tp "..\scintilla\src\KeyMap.cxx"^
 /Tp "..\scintilla\src\LineMarker.cxx"^
 /Tp "..\scintilla\src\PerLine.cxx"^
 /Tp "..\scintilla\src\PositionCache.cxx"^
 /Tp "..\scintilla\src\RESearch.cxx"^
 /Tp "..\scintilla\src\RunStyles.cxx"^
 /Tp "..\scintilla\src\ScintillaBase.cxx"^
 /Tp "..\scintilla\src\Selection.cxx"^
 /Tp "..\scintilla\src\Style.cxx"^
 /Tp "..\scintilla\src\UniConversion.cxx"^
 /Tp "..\scintilla\src\ViewStyle.cxx"^
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

IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

rem resource compiler command line
CALL :SUBMSG "INFO" "resource compiler stage..."

IF /I "%1"=="x86" (SET RCADDCMD=/d "WIN32")
IF /I "%1"=="x64" (SET RCADDCMD=/d "_WIN64")

rc /d "_UNICODE" /d "UNICODE" %RCADDCMD% /fo"%OBJDIR%/Notepad2.res" "..\src\Notepad2.rc"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

rem linker command line
CALL :SUBMSG "INFO" "linking stage..."

IF /I "%1"=="x86" (
  SET LNKADDCMD=/SUBSYSTEM:WINDOWS,5.0 /MACHINE:X86
  SET WDK_LIB=msvcrt_winxp.obj
)
IF /I "%1"=="x64" (
  SET LNKADDCMD=/SUBSYSTEM:WINDOWS,5.02 /MACHINE:X64
  SET WDK_LIB=msvcrt_win2003.obj
)

link /OUT:"%OUTDIR%/Notepad2.exe" /INCREMENTAL:NO /RELEASE %LNKADDCMD% /OPT:REF /OPT:ICF /MERGE:.rdata=.text^
 kernel32.lib user32.lib gdi32.lib advapi32.lib shell32.lib shlwapi.lib comdlg32.lib comctl32.lib winspool.lib^
 imm32.lib ole32.lib oleaut32.lib psapi.lib^
 "%OBJDIR%\Accessor.obj"^
 "%OBJDIR%\AutoComplete.obj"^
 "%OBJDIR%\CallTip.obj"^
 "%OBJDIR%\Catalogue.obj"^
 "%OBJDIR%\CellBuffer.obj"^
 "%OBJDIR%\CharacterSet.obj"^
 "%OBJDIR%\CharClassify.obj"^
 "%OBJDIR%\ContractionState.obj"^
 "%OBJDIR%\Decoration.obj"^
 "%OBJDIR%\Dialogs.obj"^
 "%OBJDIR%\Dlapi.obj"^
 "%OBJDIR%\Document.obj"^
 "%OBJDIR%\Edit.obj"^
 "%OBJDIR%\Editor.obj"^
 "%OBJDIR%\ExternalLexer.obj"^
 "%OBJDIR%\Helpers.obj"^
 "%OBJDIR%\Indicator.obj"^
 "%OBJDIR%\KeyMap.obj"^
 "%OBJDIR%\LexAsm.obj"^
 "%OBJDIR%\LexConf.obj"^
 "%OBJDIR%\LexCPP.obj"^
 "%OBJDIR%\LexCSS.obj"^
 "%OBJDIR%\LexerBase.obj"^
 "%OBJDIR%\LexerModule.obj"^
 "%OBJDIR%\LexerSimple.obj"^
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
 "%OBJDIR%\PropSetSimple.obj"^
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
 "%OBJDIR%\WordList.obj"^
 "%OBJDIR%\XPM.obj"^
 "%WDK_LIB%"

IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

rem manifest tool command line
CALL :SUBMSG "INFO" "manifest stage..."
"%SDKDIR%\Bin\mt.exe" -manifest "..\res\Notepad2.exe.manifest" -outputresource:"%OUTDIR%\Notepad2.exe;#1"
IF %ERRORLEVEL% NEQ 0 CALL :SUBMSG "ERROR" "Compilation failed!"

CALL :SUBMSG "INFO" "%1 compilation finished!"
EXIT /B


:SUBMSG
ECHO.&&ECHO:______________________________
ECHO:[%~1] %~2
ECHO:______________________________&&ECHO.
IF /I "%~1"=="ERROR" (
  PAUSE
  EXIT
) ELSE (
  EXIT /B
)
