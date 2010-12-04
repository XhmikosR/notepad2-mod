# See License.txt for legal notes.
# Use build.cmd and set there your WDK and SDK directories.

CC=cl
RC=rc
LD=link
MT=$(SDKDIR)\Bin\mt.exe

DEFINES=/D "STATIC_BUILD" /D "SCI_LEXER" /D "BOOKMARK_EDITION" /D "_WINDOWS" /D "NDEBUG" \
		/D "_UNICODE" /D "UNICODE"
INCLUDEDIRS=/I "..\scintilla\include" /I "..\scintilla\lexers" /I "..\scintilla\lexlib" \
		/I "..\scintilla\src" /I "..\scintilla\win32"
CXXFLAGS=/nologo /c /EHsc /MD /O2 /GS /GT /GL /W3 $(DEFINES) $(INCLUDEDIRS)
RFLAGS=/d "_UNICODE" /d "UNICODE" /d "BOOKMARK_EDITION"
LIBS=kernel32.lib user32.lib gdi32.lib advapi32.lib shell32.lib shlwapi.lib comdlg32.lib \
		comctl32.lib winspool.lib imm32.lib ole32.lib oleaut32.lib psapi.lib
LDFLAGS=/NOLOGO /INCREMENTAL:NO /RELEASE /OPT:REF /OPT:ICF /DYNAMICBASE /NXCOMPAT /LTCG \
		/MERGE:.rdata=.text

!IFDEF x64
CXXFLAGS=$(CXXFLAGS) /D "_WIN64" /D "_WIN32_WINNT=0x0502" /wd4133 /wd4244 /wd4267
RFLAGS=$(RFLAGS) /d "_WIN64"
LIBS=$(LIBS) msvcrt_win2003.obj
LDFLAGS=$(LDFLAGS) /SUBSYSTEM:WINDOWS,5.02 /MACHINE:X64 $(LIBS)
!ELSE
CXXFLAGS=$(CXXFLAGS) /D "WIN32" /D "_WIN32_WINNT=0x0501"
RFLAGS=$(RFLAGS) /d "WIN32"
LIBS=$(LIBS) msvcrt_winxp.obj
LDFLAGS=$(LDFLAGS) /SUBSYSTEM:WINDOWS,5.01 /MACHINE:X86 $(LIBS)
!ENDIF

CFLAGS=$(CXXFLAGS)
APP=$(BINDIR)\Notepad2.exe


ALL:	$(APP)

clean:
	-@ del "$(APP)" "$(OBJDIR)\*.idb" "$(OBJDIR)\*.obj" "$(BINDIR)\*.pdb" \
	"$(OBJDIR)\*.res" >NUL 2>&1
	-@ rd /q "$(OBJDIR)" "$(BINDIR)" >NUL 2>&1


OBJECTS= \
	$(OBJDIR)\LexAHK.obj \
	$(OBJDIR)\LexAsm.obj \
	$(OBJDIR)\LexAU3.obj \
	$(OBJDIR)\LexBash.obj \
	$(OBJDIR)\LexConf.obj \
	$(OBJDIR)\LexCPP.obj \
	$(OBJDIR)\LexCSS.obj \
	$(OBJDIR)\LexHTML.obj \
	$(OBJDIR)\LexInno.obj \
	$(OBJDIR)\LexLua.obj \
	$(OBJDIR)\LexNsis.obj \
	$(OBJDIR)\LexOthers.obj \
	$(OBJDIR)\LexPascal.obj \
	$(OBJDIR)\LexPerl.obj \
	$(OBJDIR)\LexPowerShell.obj \
	$(OBJDIR)\LexPython.obj \
	$(OBJDIR)\LexRuby.obj \
	$(OBJDIR)\LexSQL.obj \
	$(OBJDIR)\LexTCL.obj \
	$(OBJDIR)\LexVB.obj \
	$(OBJDIR)\Accessor.obj \
	$(OBJDIR)\CharacterSet.obj \
	$(OBJDIR)\LexerBase.obj \
	$(OBJDIR)\LexerModule.obj \
	$(OBJDIR)\LexerSimple.obj \
	$(OBJDIR)\PropSetSimple.obj \
	$(OBJDIR)\StyleContext.obj \
	$(OBJDIR)\WordList.obj \
	$(OBJDIR)\AutoComplete.obj \
	$(OBJDIR)\CallTip.obj \
	$(OBJDIR)\Catalogue.obj \
	$(OBJDIR)\CellBuffer.obj \
	$(OBJDIR)\CharClassify.obj \
	$(OBJDIR)\ContractionState.obj \
	$(OBJDIR)\Decoration.obj \
	$(OBJDIR)\Document.obj \
	$(OBJDIR)\Editor.obj \
	$(OBJDIR)\ExternalLexer.obj \
	$(OBJDIR)\Indicator.obj \
	$(OBJDIR)\KeyMap.obj \
	$(OBJDIR)\LineMarker.obj \
	$(OBJDIR)\PerLine.obj \
	$(OBJDIR)\PositionCache.obj \
	$(OBJDIR)\RESearch.obj \
	$(OBJDIR)\RunStyles.obj \
	$(OBJDIR)\ScintillaBase.obj \
	$(OBJDIR)\Selection.obj \
	$(OBJDIR)\Style.obj \
	$(OBJDIR)\UniConversion.obj \
	$(OBJDIR)\ViewStyle.obj \
	$(OBJDIR)\XPM.obj \
	$(OBJDIR)\PlatWin.obj \
	$(OBJDIR)\ScintillaWin.obj \
	$(OBJDIR)\Dialogs.obj \
	$(OBJDIR)\Dlapi.obj \
	$(OBJDIR)\Edit.obj \
	$(OBJDIR)\Helpers.obj \
	$(OBJDIR)\Notepad2.obj \
	$(OBJDIR)\Print.obj \
	$(OBJDIR)\Styles.obj \
	$(OBJDIR)\Notepad2.res


{..\scintilla\lexers}.cxx{$(OBJDIR)}.obj:
	@$(CC) $(CXXFLAGS) /Fo"$(OBJDIR)/" /Tp "$<"

{..\scintilla\lexlib}.cxx{$(OBJDIR)}.obj:
	@$(CC) $(CXXFLAGS) /Fo"$(OBJDIR)/" /Tp "$<"

{..\scintilla\src}.cxx{$(OBJDIR)}.obj:
	@$(CC) $(CXXFLAGS) /Fo"$(OBJDIR)/" /Tp "$<"

{..\scintilla\win32}.cxx{$(OBJDIR)}.obj:
	@$(CC) $(CXXFLAGS) /Fo"$(OBJDIR)/" /Tp "$<"

{..\src}.cpp{$(OBJDIR)}.obj:
	@$(CC) $(CXXFLAGS) /Fo"$(OBJDIR)/" /Tp "$<"

{..\src}.c{$(OBJDIR)}.obj:
	@$(CC) $(CFLAGS) /Fo"$(OBJDIR)/" /Tc "$<"

{..\src}.rc{$(OBJDIR)}.res:
	@$(RC) $(RFLAGS) /Fo"$@" "$<"


$(APP): $(OBJECTS)
	@$(LD) $(LDFLAGS) /OUT:"$(APP)" $(OBJECTS)
	@"$(MT)" -nologo -manifest "..\res\Notepad2.exe.manifest" -outputresource:"$(APP);#1"


# Dependencies

LEX_HEADERS= ..\scintilla\include\ILexer.h ..\scintilla\include\Scintilla.h \
			..\scintilla\include\SciLexer.h ..\scintilla\lexlib\Accessor.h \
			..\scintilla\lexlib\CharacterSet.h ..\scintilla\lexlib\LexAccessor.h \
			..\scintilla\lexlib\LexerModule.h ..\scintilla\lexlib\StyleContext.h

# scintilla\lexers
$(OBJDIR)\LexAHK.obj: ..\scintilla\lexers\LexAHK.cxx $(LEX_HEADERS)
$(OBJDIR)\LexAsm.obj: ..\scintilla\lexers\LexAsm.cxx $(LEX_HEADERS)
$(OBJDIR)\LexAU3.obj: ..\scintilla\lexers\LexAU3.cxx $(LEX_HEADERS)
$(OBJDIR)\LexBash.obj: ..\scintilla\lexers\LexBash.cxx $(LEX_HEADERS)
$(OBJDIR)\LexConf.obj: ..\scintilla\lexers\LexConf.cxx $(LEX_HEADERS)
$(OBJDIR)\LexCPP.obj: ..\scintilla\lexers\LexCPP.cxx $(LEX_HEADERS)
$(OBJDIR)\LexCSS.obj: ..\scintilla\lexers\LexCSS.cxx $(LEX_HEADERS)
$(OBJDIR)\LexHTML.obj: ..\scintilla\lexers\LexHTML.cxx $(LEX_HEADERS)
$(OBJDIR)\LexInno.obj: ..\scintilla\lexers\LexInno.cxx $(LEX_HEADERS)
$(OBJDIR)\LexLua.obj: ..\scintilla\lexers\LexLua.cxx $(LEX_HEADERS)
$(OBJDIR)\LexNsis.obj: ..\scintilla\lexers\LexNsis.cxx $(LEX_HEADERS)
$(OBJDIR)\LexOthers.obj: ..\scintilla\lexers\LexOthers.cxx $(LEX_HEADERS)
$(OBJDIR)\LexPascal.obj: ..\scintilla\lexers\LexPascal.cxx $(LEX_HEADERS)
$(OBJDIR)\LexPerl.obj: ..\scintilla\lexers\LexPerl.cxx $(LEX_HEADERS)
$(OBJDIR)\LexPowerShell.obj: ..\scintilla\lexers\LexPowerShell.cxx $(LEX_HEADERS)
$(OBJDIR)\LexPython.obj: ..\scintilla\lexers\LexPython.cxx $(LEX_HEADERS)
$(OBJDIR)\LexRuby.obj: ..\scintilla\lexers\LexRuby.cxx $(LEX_HEADERS)
$(OBJDIR)\LexSQL.obj: ..\scintilla\lexers\LexSQL.cxx $(LEX_HEADERS)
$(OBJDIR)\LexTCL.obj: ..\scintilla\lexers\LexTCL.cxx $(LEX_HEADERS)
$(OBJDIR)\LexVB.obj: ..\scintilla\lexers\LexVB.cxx $(LEX_HEADERS)

# scintilla\lexlib
$(OBJDIR)\Accessor.obj: ..\scintilla\lexlib\Accessor.cxx ..\scintilla\lexlib\Accessor.h
$(OBJDIR)\CharacterSet.obj: ..\scintilla\lexlib\CharacterSet.cxx ..\scintilla\lexlib\CharacterSet.h
$(OBJDIR)\LexerBase.obj: ..\scintilla\lexlib\LexerBase.cxx ..\scintilla\lexlib\LexerBase.h
$(OBJDIR)\LexerModule.obj: ..\scintilla\lexlib\LexerModule.cxx ..\scintilla\lexlib\LexerModule.h
$(OBJDIR)\LexerSimple.obj: ..\scintilla\lexlib\LexerSimple.cxx ..\scintilla\lexlib\LexerSimple.h
$(OBJDIR)\PropSetSimple.obj: ..\scintilla\lexlib\PropSetSimple.cxx ..\scintilla\include\Platform.h
$(OBJDIR)\StyleContext.obj: ..\scintilla\lexlib\StyleContext.cxx ..\scintilla\lexlib\Accessor.h \
	..\scintilla\lexlib\StyleContext.h
$(OBJDIR)\WordList.obj: ..\scintilla\lexlib\WordList.cxx ..\scintilla\lexlib\WordList.h

# scintilla\src
$(OBJDIR)\AutoComplete.obj: ..\scintilla\src\AutoComplete.cxx ..\scintilla\include\Platform.h \
	..\scintilla\src\AutoComplete.h
$(OBJDIR)\CallTip.obj: ..\scintilla\src\CallTip.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\CallTip.h
$(OBJDIR)\Catalogue.obj: ..\scintilla\src\Catalogue.cxx
$(OBJDIR)\CellBuffer.obj: ..\scintilla\src\CellBuffer.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\SVector.h ..\scintilla\src\SplitVector.h \
	..\scintilla\src\Partitioning.h ..\scintilla\src\CellBuffer.h
$(OBJDIR)\CharClassify.obj: ..\scintilla\src\CharClassify.cxx ..\scintilla\src\CharClassify.h
$(OBJDIR)\ContractionState.obj: ..\scintilla\src\ContractionState.cxx ..\scintilla\include\Platform.h \
	..\scintilla\src\ContractionState.h
$(OBJDIR)\Decoration.obj: ..\scintilla\src\Decoration.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\SplitVector.h ..\scintilla\src\Partitioning.h \
	..\scintilla\src\RunStyles.h ..\scintilla\src\Decoration.h
$(OBJDIR)\Document.obj: ..\scintilla\src\Document.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\SVector.h ..\scintilla\src\SplitVector.h \
	..\scintilla\src\Partitioning.h ..\scintilla\src\RunStyles.h ..\scintilla\src\CellBuffer.h \
	..\scintilla\src\CharClassify.h ..\scintilla\src\Decoration.h ..\scintilla\src\Document.h \
	..\scintilla\src\RESearch.h ..\scintilla\src\PerLine.h
$(OBJDIR)\Editor.obj: ..\scintilla\src\Editor.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\ContractionState.h ..\scintilla\src\SVector.h \
	..\scintilla\src\SplitVector.h ..\scintilla\src\Partitioning.h ..\scintilla\src\CellBuffer.h \
	..\scintilla\src\KeyMap.h ..\scintilla\src\RunStyles.h ..\scintilla\src\Indicator.h \
	..\scintilla\src\XPM.h ..\scintilla\src\LineMarker.h ..\scintilla\src\Style.h \
	..\scintilla\src\ViewStyle.h ..\scintilla\src\CharClassify.h ..\scintilla\src\Decoration.h \
	..\scintilla\src\Document.h ..\scintilla\src\Editor.h ..\scintilla\src\Selection.h \
	..\scintilla\src\PositionCache.h
$(OBJDIR)\ExternalLexer.obj: ..\scintilla\src\ExternalLexer.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\include\SciLexer.h \
	..\scintilla\lexlib\Accessor.h ..\scintilla\src\ExternalLexer.h
$(OBJDIR)\Indicator.obj: ..\scintilla\src\Indicator.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\Indicator.h
$(OBJDIR)\KeyMap.obj: ..\scintilla\src\KeyMap.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\KeyMap.h
$(OBJDIR)\LineMarker.obj: ..\scintilla\src\LineMarker.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\XPM.h ..\scintilla\src\LineMarker.h
$(OBJDIR)\PerLine.obj: ..\scintilla\src\PerLine.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\SVector.h ..\scintilla\src\SplitVector.h \
	..\scintilla\src\Partitioning.h ..\scintilla\src\RunStyles.h ..\scintilla\src\PerLine.h
$(OBJDIR)\PositionCache.obj: ..\scintilla\src\PositionCache.cxx ..\scintilla\src\SplitVector.h \
	..\scintilla\src\Partitioning.h ..\scintilla\src\RunStyles.h ..\scintilla\src\ContractionState.h \
	..\scintilla\src\CellBuffer.h ..\scintilla\src\KeyMap.h ..\scintilla\src\Indicator.h \
	..\scintilla\src\XPM.h ..\scintilla\src\LineMarker.h ..\scintilla\src\Style.h \
	..\scintilla\src\ViewStyle.h ..\scintilla\src\CharClassify.h ..\scintilla\src\Decoration.h \
	..\scintilla\src\Document.h ..\scintilla\src\Selection.h ..\scintilla\src\PositionCache.h
$(OBJDIR)\RESearch.obj: ..\scintilla\src\RESearch.cxx ..\scintilla\src\CharClassify.h \
	..\scintilla\src\RESearch.h
$(OBJDIR)\RunStyles.obj: ..\scintilla\src\RunStyles.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\SplitVector.h ..\scintilla\src\Partitioning.h \
	..\scintilla\src\RunStyles.h
$(OBJDIR)\ScintillaBase.obj: ..\scintilla\src\ScintillaBase.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h \
	..\scintilla\src\ContractionState.h ..\scintilla\src\SVector.h ..\scintilla\src\SplitVector.h \
	..\scintilla\src\Partitioning.h ..\scintilla\src\RunStyles.h ..\scintilla\src\CellBuffer.h \
	..\scintilla\src\CallTip.h ..\scintilla\src\KeyMap.h ..\scintilla\src\Indicator.h \
	..\scintilla\src\XPM.h ..\scintilla\src\LineMarker.h ..\scintilla\src\Style.h \
	..\scintilla\src\ViewStyle.h ..\scintilla\src\AutoComplete.h ..\scintilla\src\CharClassify.h \
	..\scintilla\src\Decoration.h ..\scintilla\src\Document.h ..\scintilla\src\Editor.h \
	..\scintilla\src\Selection.h ..\scintilla\src\ScintillaBase.h
$(OBJDIR)\Selection.obj: ..\scintilla\src\Selection.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\Selection.h
$(OBJDIR)\Style.obj: ..\scintilla\src\Style.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\Style.h
$(OBJDIR)\UniConversion.obj: ..\scintilla\src\UniConversion.cxx ..\scintilla\src\UniConversion.h
$(OBJDIR)\ViewStyle.obj: ..\scintilla\src\ViewStyle.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\SplitVector.h ..\scintilla\src\Partitioning.h \
	..\scintilla\src\RunStyles.h ..\scintilla\src\Indicator.h ..\scintilla\src\XPM.h \
	..\scintilla\src\LineMarker.h ..\scintilla\src\Style.h ..\scintilla\src\ViewStyle.h
$(OBJDIR)\XPM.obj: ..\scintilla\src\XPM.cxx ..\scintilla\include\Platform.h ..\scintilla\src\XPM.h

# scintilla\win32
$(OBJDIR)\PlatWin.obj: ..\scintilla\win32\PlatWin.cxx ..\scintilla\include\Platform.h \
	..\scintilla\win32\PlatformRes.h ..\scintilla\src\UniConversion.h ..\scintilla\src\XPM.h
$(OBJDIR)\ScintillaWin.obj: ..\scintilla\win32\ScintillaWin.cxx ..\scintilla\include\Platform.h \
	..\scintilla\include\Scintilla.h ..\scintilla\src\ContractionState.h ..\scintilla\src\SVector.h \
	..\scintilla\src\SplitVector.h ..\scintilla\src\Partitioning.h ..\scintilla\src\RunStyles.h \
	..\scintilla\src\CellBuffer.h ..\scintilla\src\CallTip.h ..\scintilla\src\KeyMap.h \
	..\scintilla\src\Indicator.h ..\scintilla\src\XPM.h ..\scintilla\src\LineMarker.h \
	..\scintilla\src\Style.h ..\scintilla\src\AutoComplete.h ..\scintilla\src\ViewStyle.h \
	..\scintilla\src\CharClassify.h ..\scintilla\src\Decoration.h ..\scintilla\src\Document.h \
	..\scintilla\src\Editor.h ..\scintilla\src\ScintillaBase.h ..\scintilla\src\Selection.h \
	..\scintilla\src\UniConversion.h

# src
$(OBJDIR)\Dialogs.obj: ..\src\Dialogs.c ..\src\Notepad2.h \
		..\src\Edit.h \
		..\src\Helpers.h \
		..\src\Dlapi.h \
		..\src\Dialogs.h \
		..\src\resource.h \
		..\src\Version.h \
		..\src\Version_rev.h
$(OBJDIR)\Dlapi.obj: ..\src\Dlapi.c ..\src\Dlapi.h
$(OBJDIR)\Edit.obj: ..\src\Edit.c ..\src\Notepad2.h \
		..\src\Helpers.h \
		..\src\Dialogs.h \
		..\src\Styles.h \
		..\src\Edit.h \
		..\src\SciCall.h \
		..\src\resource.h
$(OBJDIR)\Helpers.obj: ..\src\Helpers.c ..\src\Helpers.h
$(OBJDIR)\Notepad2.obj: ..\src\Notepad2.c ..\src\Edit.h \
		..\src\Styles.h \
		..\src\Helpers.h \
		..\src\Dialogs.h \
		..\src\Notepad2.h \
		..\src\SciCall.h \
		..\src\resource.h
$(OBJDIR)\Notepad2.res: ..\src\Notepad2.rc ..\src\Version.h \
		..\src\Version_rev.h
$(OBJDIR)\Print.obj: ..\src\Print.cpp ..\src\Dialogs.h \
		..\src\Helpers.h \
		..\src\resource.h
$(OBJDIR)\Styles.obj: ..\src\Styles.c ..\src\Dialogs.h \
		..\src\Helpers.h \
		..\src\Notepad2.h \
		..\src\Edit.h \
		..\src\Styles.h \
		..\src\SciCall.h \
		..\src\resource.h
