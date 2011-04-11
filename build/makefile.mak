#******************************************************************************
#*
#* Notepad2-mod
#*
#* makefile.mak
#*   makefile for building Notepad2 with WDK
#*
#* See License.txt for details about distribution and modification.
#*
#*                                       (c) XhmikosR 2010-2011
#*                                       http://code.google.com/p/notepad2-mod/
#*
#* Use build_wdk.bat and set there your WDK directory.
#*
#******************************************************************************


# Remove the .SILENT directive in order to display all the commands
.SILENT:


!IFDEF x64
BINDIR  = ..\bin\WDK\Release_x64
!ELSE
BINDIR  = ..\bin\WDK\Release_x86
!ENDIF
OBJDIR  = $(BINDIR)\obj
EXE     = $(BINDIR)\Notepad2.exe


SCI_INC = ..\scintilla\include
SCI_LEX = ..\scintilla\lexers
SCI_LIB = ..\scintilla\lexlib
SCI_SRC = ..\scintilla\src
SCI_WIN = ..\scintilla\win32
SRC     = ..\src
RES     = ..\res


DEFINES       = /D "BOOKMARK_EDITION" /D "_WINDOWS" /D "NDEBUG" /D "_UNICODE" /D "UNICODE"
INCLUDEDIRS   = /I "$(SCI_INC)" /I "$(SCI_LEX)" /I "$(SCI_LIB)" /I "$(SCI_SRC)" \
                /I "$(SCI_WIN)"
CXXFLAGS      = /nologo /c /Fo"$(OBJDIR)/" /W3 /WX /EHsc /MD /O2 /GL /MP \
                $(DEFINES) $(INCLUDEDIRS)
LDFLAGS       = /NOLOGO /WX /INCREMENTAL:NO /RELEASE /OPT:REF /OPT:ICF /MERGE:.rdata=.text \
                /DYNAMICBASE /NXCOMPAT /LTCG /DEBUG
LIBS          = kernel32.lib user32.lib gdi32.lib advapi32.lib shell32.lib shlwapi.lib \
                comdlg32.lib comctl32.lib winspool.lib imm32.lib ole32.lib oleaut32.lib \
                psapi.lib
RFLAGS        = /l 0x0409 /d "_UNICODE" /d "UNICODE" /d "BOOKMARK_EDITION"
SCI_CXXFLAGS  = $(CXXFLAGS) /D "STATIC_BUILD" /D "SCI_LEXER"


!IFDEF x64
CXXFLAGS      = $(CXXFLAGS) /D "_WIN64" /D "_WIN32_WINNT=0x0502"
LDFLAGS       = $(LDFLAGS) /SUBSYSTEM:WINDOWS,5.02 /MACHINE:X64
LIBS          = $(LIBS) msvcrt_win2003.obj
RFLAGS        = $(RFLAGS) /d "_WIN64"
SCI_CXXFLAGS  = $(SCI_CXXFLAGS) /wd4244 /wd4267
!ELSE
CXXFLAGS      = $(CXXFLAGS) /D "WIN32" /D "_WIN32_WINNT=0x0501"
LDFLAGS       = $(LDFLAGS) /SUBSYSTEM:WINDOWS,5.01 /MACHINE:X86
LIBS          = $(LIBS) msvcrt_winxp.obj
RFLAGS        = $(RFLAGS) /d "WIN32"
!ENDIF


###############
##  Targets  ##
###############
BUILD:	CHECKDIRS $(EXE)

CHECKDIRS:
	-MKDIR "$(OBJDIR)" >NUL 2>&1

CLEAN:
	ECHO Cleaning... & ECHO.
	-DEL "$(EXE)" "$(OBJDIR)\*.obj" "$(OBJDIR)\Notepad2.res" \
	"$(BINDIR)\Notepad2.pdb" >NUL 2>&1
	-RMDIR /Q "$(OBJDIR)" "$(BINDIR)" >NUL 2>&1

REBUILD:	CLEAN BUILD


####################
##  Object files  ##
####################
SCI_LEX_OBJ = \
    $(OBJDIR)\LexAHK.obj \
    $(OBJDIR)\LexAsm.obj \
    $(OBJDIR)\LexAU3.obj \
    $(OBJDIR)\LexBash.obj \
    $(OBJDIR)\LexCmake.obj \
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
    $(OBJDIR)\LexVB.obj

SCI_LIB_OBJ = \
    $(OBJDIR)\Accessor.obj \
    $(OBJDIR)\CharacterSet.obj \
    $(OBJDIR)\LexerBase.obj \
    $(OBJDIR)\LexerModule.obj \
    $(OBJDIR)\LexerSimple.obj \
    $(OBJDIR)\PropSetSimple.obj \
    $(OBJDIR)\StyleContext.obj \
    $(OBJDIR)\WordList.obj

SCI_SRC_OBJ = \
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
    $(OBJDIR)\XPM.obj

SCI_WIN_OBJ = \
    $(OBJDIR)\PlatWin.obj \
    $(OBJDIR)\ScintillaWin.obj

NOTEPAD2_OBJ = \
    $(OBJDIR)\Dialogs.obj \
    $(OBJDIR)\Dlapi.obj \
    $(OBJDIR)\Edit.obj \
    $(OBJDIR)\Helpers.obj \
    $(OBJDIR)\Notepad2.obj \
    $(OBJDIR)\Notepad2.res \
    $(OBJDIR)\Print.obj \
    $(OBJDIR)\Styles.obj

OBJECTS = $(SCI_LEX_OBJ) $(SCI_LIB_OBJ) $(SCI_SRC_OBJ) $(SCI_WIN_OBJ) $(NOTEPAD2_OBJ)


###################
##  Batch rules  ##
###################
{$(SCI_LEX)}.cxx{$(OBJDIR)}.obj::
    cl $(SCI_CXXFLAGS) /Tp $<

{$(SCI_LIB)}.cxx{$(OBJDIR)}.obj::
    cl $(SCI_CXXFLAGS) /Tp $<

{$(SCI_SRC)}.cxx{$(OBJDIR)}.obj::
    cl $(SCI_CXXFLAGS) /Tp $<

{$(SCI_WIN)}.cxx{$(OBJDIR)}.obj::
    cl $(SCI_CXXFLAGS) /Tp $<

{$(SRC)}.cpp{$(OBJDIR)}.obj::
    cl $(CXXFLAGS) /Tp $<

{$(SRC)}.c{$(OBJDIR)}.obj::
    cl $(CXXFLAGS) /Tc $<


################
##  Commands  ##
################
$(EXE): $(OBJECTS)
	rc $(RFLAGS) /fo"$(OBJDIR)\Notepad2.res" "$(SRC)\Notepad2.rc" >NUL
	link $(LDFLAGS) $(LIBS) $(OBJECTS) /OUT:"$(EXE)"


####################
##  Dependencies  ##
####################
!INCLUDE "makefile.deps.mak"
