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


CC = cl.exe
LD = link.exe
RC = rc.exe

!IFDEF x64
BINDIR  = ..\bin\WDK\Release_x64
!ELSE
BINDIR  = ..\bin\WDK\Release_x86
!ENDIF
OBJDIR  = $(BINDIR)\obj
EXE     = $(BINDIR)\Notepad2.exe

SCI_OBJDIR      = $(OBJDIR)\scintilla
SCI_LEX_OBJDIR  = $(SCI_OBJDIR)\lexers
SCI_LIB_OBJDIR  = $(SCI_OBJDIR)\lexlib
SCI_SRC_OBJDIR  = $(SCI_OBJDIR)\src
SCI_WIN_OBJDIR  = $(SCI_OBJDIR)\win32
NP2_SRC_OBJDIR  = $(OBJDIR)\notepad2


SCI_DIR         = ..\scintilla
SCI_INC         = $(SCI_DIR)\include
SCI_LEX         = $(SCI_DIR)\lexers
SCI_LIB         = $(SCI_DIR)\lexlib
SCI_SRC         = $(SCI_DIR)\src
SCI_WIN         = $(SCI_DIR)\win32
NP2_SRC         = ..\src
NP2_RES         = ..\res


DEFINES       = /D "BOOKMARK_EDITION" /D "_WINDOWS" /D "NDEBUG" /D "_UNICODE" /D "UNICODE" \
                /D "_STL70_" /D "_STATIC_CPPLIB" /D "WDK_BUILD"
INCLUDEDIRS   = /I "$(SCI_INC)" /I "$(SCI_LEX)" /I "$(SCI_LIB)" /I "$(SCI_SRC)" \
                /I "$(SCI_WIN)"
CXXFLAGS      = /nologo /c /W3 /WX /EHsc /MD /O2 /GL /MP $(DEFINES) $(INCLUDEDIRS)
LDFLAGS       = /NOLOGO /WX /INCREMENTAL:NO /RELEASE /OPT:REF /OPT:ICF /MERGE:.rdata=.text \
                /DYNAMICBASE /NXCOMPAT /LTCG
LIBS          = kernel32.lib user32.lib gdi32.lib advapi32.lib shell32.lib shlwapi.lib \
                comdlg32.lib comctl32.lib winspool.lib imm32.lib ole32.lib oleaut32.lib \
                psapi.lib ntstc_msvcrt.lib
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
BUILD:	PREBUILD $(EXE)

PREBUILD:
	IF NOT EXIST "$(SCI_LEX_OBJDIR)"    MD "$(SCI_LEX_OBJDIR)"
	IF NOT EXIST "$(SCI_LIB_OBJDIR)"    MD "$(SCI_LIB_OBJDIR)"
	IF NOT EXIST "$(SCI_SRC_OBJDIR)"    MD "$(SCI_SRC_OBJDIR)"
	IF NOT EXIST "$(SCI_WIN_OBJDIR)"    MD "$(SCI_WIN_OBJDIR)"
	IF NOT EXIST "$(NP2_SRC_OBJDIR)"    MD "$(NP2_SRC_OBJDIR)"
	CD ..
	CALL "update_version.bat"
	CD "build"
	ECHO.

CLEAN:
	ECHO Cleaning... & ECHO.
	IF EXIST "$(EXE)"                           DEL "$(EXE)"
	IF EXIST "$(NP2_SRC_OBJDIR)\*.obj"          DEL "$(NP2_SRC_OBJDIR)\*.obj"
	IF EXIST "$(SCI_LEX_OBJDIR)\*.obj"          DEL "$(SCI_LEX_OBJDIR)\*.obj"
	IF EXIST "$(SCI_LIB_OBJDIR)\*.obj"          DEL "$(SCI_LIB_OBJDIR)\*.obj"
	IF EXIST "$(SCI_SRC_OBJDIR)\*.obj"          DEL "$(SCI_SRC_OBJDIR)\*.obj"
	IF EXIST "$(SCI_WIN_OBJDIR)\*.obj"          DEL "$(SCI_WIN_OBJDIR)\*.obj"
	IF EXIST "$(NP2_SRC_OBJDIR)\Notepad2.res"   DEL "$(NP2_SRC_OBJDIR)\Notepad2.res"
	IF EXIST "$(BINDIR)\Notepad2.pdb"           DEL "$(BINDIR)\Notepad2.pdb"
	-IF EXIST "$(SCI_LEX_OBJDIR)"               RD /Q "$(SCI_LEX_OBJDIR)"
	-IF EXIST "$(SCI_LIB_OBJDIR)"               RD /Q "$(SCI_LIB_OBJDIR)"
	-IF EXIST "$(SCI_SRC_OBJDIR)"               RD /Q "$(SCI_SRC_OBJDIR)"
	-IF EXIST "$(SCI_WIN_OBJDIR)"               RD /Q "$(SCI_WIN_OBJDIR)"
	-IF EXIST "$(SCI_OBJDIR)"                   RD /Q "$(SCI_OBJDIR)"
	-IF EXIST "$(NP2_SRC_OBJDIR)"               RD /Q "$(NP2_SRC_OBJDIR)"
	-IF EXIST "$(OBJDIR)"                       RD /Q "$(OBJDIR)"
	-IF EXIST "$(BINDIR)"                       RD /Q "$(BINDIR)"

REBUILD:	CLEAN BUILD


####################
##  Object files  ##
####################
SCI_LEX_OBJ = \
    $(SCI_LEX_OBJDIR)\LexAHK.obj \
    $(SCI_LEX_OBJDIR)\LexAsm.obj \
    $(SCI_LEX_OBJDIR)\LexAU3.obj \
    $(SCI_LEX_OBJDIR)\LexBash.obj \
    $(SCI_LEX_OBJDIR)\LexCmake.obj \
    $(SCI_LEX_OBJDIR)\LexConf.obj \
    $(SCI_LEX_OBJDIR)\LexCPP.obj \
    $(SCI_LEX_OBJDIR)\LexCSS.obj \
    $(SCI_LEX_OBJDIR)\LexHTML.obj \
    $(SCI_LEX_OBJDIR)\LexInno.obj \
    $(SCI_LEX_OBJDIR)\LexLua.obj \
    $(SCI_LEX_OBJDIR)\LexNsis.obj \
    $(SCI_LEX_OBJDIR)\LexOthers.obj \
    $(SCI_LEX_OBJDIR)\LexPascal.obj \
    $(SCI_LEX_OBJDIR)\LexPerl.obj \
    $(SCI_LEX_OBJDIR)\LexPowerShell.obj \
    $(SCI_LEX_OBJDIR)\LexPython.obj \
    $(SCI_LEX_OBJDIR)\LexRuby.obj \
    $(SCI_LEX_OBJDIR)\LexSQL.obj \
    $(SCI_LEX_OBJDIR)\LexTCL.obj \
    $(SCI_LEX_OBJDIR)\LexVB.obj

SCI_LIB_OBJ = \
    $(SCI_LIB_OBJDIR)\Accessor.obj \
    $(SCI_LIB_OBJDIR)\CharacterSet.obj \
    $(SCI_LIB_OBJDIR)\LexerBase.obj \
    $(SCI_LIB_OBJDIR)\LexerModule.obj \
    $(SCI_LIB_OBJDIR)\LexerSimple.obj \
    $(SCI_LIB_OBJDIR)\PropSetSimple.obj \
    $(SCI_LIB_OBJDIR)\StyleContext.obj \
    $(SCI_LIB_OBJDIR)\WordList.obj

SCI_SRC_OBJ = \
    $(SCI_SRC_OBJDIR)\AutoComplete.obj \
    $(SCI_SRC_OBJDIR)\CallTip.obj \
    $(SCI_SRC_OBJDIR)\Catalogue.obj \
    $(SCI_SRC_OBJDIR)\CellBuffer.obj \
    $(SCI_SRC_OBJDIR)\CharClassify.obj \
    $(SCI_SRC_OBJDIR)\ContractionState.obj \
    $(SCI_SRC_OBJDIR)\Decoration.obj \
    $(SCI_SRC_OBJDIR)\Document.obj \
    $(SCI_SRC_OBJDIR)\Editor.obj \
    $(SCI_SRC_OBJDIR)\ExternalLexer.obj \
    $(SCI_SRC_OBJDIR)\Indicator.obj \
    $(SCI_SRC_OBJDIR)\KeyMap.obj \
    $(SCI_SRC_OBJDIR)\LineMarker.obj \
    $(SCI_SRC_OBJDIR)\PerLine.obj \
    $(SCI_SRC_OBJDIR)\PositionCache.obj \
    $(SCI_SRC_OBJDIR)\RESearch.obj \
    $(SCI_SRC_OBJDIR)\RunStyles.obj \
    $(SCI_SRC_OBJDIR)\ScintillaBase.obj \
    $(SCI_SRC_OBJDIR)\Selection.obj \
    $(SCI_SRC_OBJDIR)\Style.obj \
    $(SCI_SRC_OBJDIR)\UniConversion.obj \
    $(SCI_SRC_OBJDIR)\ViewStyle.obj \
    $(SCI_SRC_OBJDIR)\XPM.obj

SCI_WIN_OBJ = \
    $(SCI_WIN_OBJDIR)\PlatWin.obj \
    $(SCI_WIN_OBJDIR)\ScintillaWin.obj

NOTEPAD2_OBJ = \
    $(NP2_SRC_OBJDIR)\Dialogs.obj \
    $(NP2_SRC_OBJDIR)\Dlapi.obj \
    $(NP2_SRC_OBJDIR)\Edit.obj \
    $(NP2_SRC_OBJDIR)\Helpers.obj \
    $(NP2_SRC_OBJDIR)\Notepad2.obj \
    $(NP2_SRC_OBJDIR)\Notepad2.res \
    $(NP2_SRC_OBJDIR)\Print.obj \
    $(NP2_SRC_OBJDIR)\Styles.obj

OBJECTS = \
    $(SCI_LEX_OBJ) \
    $(SCI_LIB_OBJ) \
    $(SCI_SRC_OBJ) \
    $(SCI_WIN_OBJ) \
    $(NOTEPAD2_OBJ)


###################
##  Batch rules  ##
###################
{$(SCI_LEX)}.cxx{$(SCI_LEX_OBJDIR)}.obj::
    $(CC) $(SCI_CXXFLAGS) /Fo"$(SCI_LEX_OBJDIR)/" /Tp $<

{$(SCI_LIB)}.cxx{$(SCI_LIB_OBJDIR)}.obj::
    $(CC) $(SCI_CXXFLAGS) /Fo"$(SCI_LIB_OBJDIR)/" /Tp $<

{$(SCI_SRC)}.cxx{$(SCI_SRC_OBJDIR)}.obj::
    $(CC) $(SCI_CXXFLAGS) /Fo"$(SCI_SRC_OBJDIR)/" /Tp $<

{$(SCI_WIN)}.cxx{$(SCI_WIN_OBJDIR)}.obj::
    $(CC) $(SCI_CXXFLAGS) /Fo"$(SCI_WIN_OBJDIR)/" /Tp $<

{$(NP2_SRC)}.cpp{$(NP2_SRC_OBJDIR)}.obj::
    $(CC) $(CXXFLAGS) /Fo"$(NP2_SRC_OBJDIR)/" /Tp $<

{$(NP2_SRC)}.c{$(NP2_SRC_OBJDIR)}.obj::
    $(CC) $(CXXFLAGS) /Fo"$(NP2_SRC_OBJDIR)/" /Tc $<


################
##  Commands  ##
################
$(EXE): $(OBJECTS)
	$(RC) $(RFLAGS) /fo"$(NP2_SRC_OBJDIR)\Notepad2.res" "$(NP2_SRC)\Notepad2.rc" >NUL
	$(LD) $(LDFLAGS) $(LIBS) $(OBJECTS) /OUT:"$(EXE)"


####################
##  Dependencies  ##
####################
!INCLUDE "makefile.deps.mak"
