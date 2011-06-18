#******************************************************************************
#*
#* Notepad2-mod
#*
#* makefile.deps.mak
#*   Contains the dependencies for makefile.mak
#*
#* See License.txt for details about distribution and modification.
#*
#*                                       (c) XhmikosR 2010-2011
#*                                       http://code.google.com/p/notepad2-mod/
#*
#*
#*
#******************************************************************************


########################
##  scintilla\lexers  ##
########################
LEX_HEADERS = \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\WordList.h \
    $(SCI_LIB)\LexAccessor.h \
    $(SCI_LIB)\Accessor.h \
    $(SCI_LIB)\StyleContext.h \
    $(SCI_LIB)\CharacterSet.h \
    $(SCI_LIB)\LexerModule.h

$(SCI_LEX_OBJDIR)\LexAsm.obj: $(SCI_LEX)\LexAsm.cxx $(LEX_HEADERS) $(SCI_LIB)\OptionSet.h
$(SCI_LEX_OBJDIR)\LexConf.obj: $(SCI_LEX)\LexConf.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexCPP.obj: $(SCI_LEX)\LexCPP.cxx $(LEX_HEADERS) $(SCI_LIB)\OptionSet.h $(SCI_LIB)\SparseState.h
$(SCI_LEX_OBJDIR)\LexCSS.obj: $(SCI_LEX)\LexCSS.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexHTML.obj: $(SCI_LEX)\LexHTML.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexOthers.obj: $(SCI_LEX)\LexOthers.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexPascal.obj: $(SCI_LEX)\LexPascal.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexPerl.obj: $(SCI_LEX)\LexPerl.cxx $(LEX_HEADERS) $(SCI_LIB)\OptionSet.h
$(SCI_LEX_OBJDIR)\LexPowerShell.obj: $(SCI_LEX)\LexPowerShell.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexPython.obj: $(SCI_LEX)\LexPython.cxx $(LEX_HEADERS)
$(SCI_LEX_OBJDIR)\LexSQL.obj: $(SCI_LEX)\LexSQL.cxx $(LEX_HEADERS) $(SCI_LIB)\OptionSet.h
$(SCI_LEX_OBJDIR)\LexVB.obj: $(SCI_LEX)\LexVB.cxx $(LEX_HEADERS)


########################
##  scintilla\lexlib  ##
########################
$(SCI_LIB_OBJDIR)\Accessor.obj: \
    $(SCI_LIB)\Accessor.cxx \
    $(SCI_LIB)\Accessor.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\PropSetSimple.h \
    $(SCI_LIB)\WordList.h \
    $(SCI_LIB)\LexAccessor.h

$(SCI_LIB_OBJDIR)\CharacterSet.obj: \
    $(SCI_LIB)\CharacterSet.cxx \
    $(SCI_LIB)\CharacterSet.h

$(SCI_LIB_OBJDIR)\LexerBase.obj: \
    $(SCI_LIB)\LexerBase.cxx \
    $(SCI_LIB)\LexerBase.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\PropSetSimple.h \
    $(SCI_LIB)\WordList.h \
    $(SCI_LIB)\LexAccessor.h \
    $(SCI_LIB)\Accessor.h \
    $(SCI_LIB)\LexerModule.h

$(SCI_LIB_OBJDIR)\LexerModule.obj: \
    $(SCI_LIB)\LexerModule.cxx \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\PropSetSimple.h \
    $(SCI_LIB)\WordList.h \
    $(SCI_LIB)\LexAccessor.h \
    $(SCI_LIB)\Accessor.h \
    $(SCI_LIB)\LexerModule.h \
    $(SCI_LIB)\LexerBase.h \
    $(SCI_LIB)\LexerSimple.h

$(SCI_LIB_OBJDIR)\LexerSimple.obj: \
    $(SCI_LIB)\LexerSimple.cxx \
    $(SCI_LIB)\LexerSimple.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\PropSetSimple.h \
    $(SCI_LIB)\WordList.h \
    $(SCI_LIB)\LexAccessor.h \
    $(SCI_LIB)\Accessor.h \
    $(SCI_LIB)\LexerModule.h \
    $(SCI_LIB)\LexerBase.h

$(SCI_LIB_OBJDIR)\PropSetSimple.obj: \
    $(SCI_LIB)\PropSetSimple.cxx \
    $(SCI_INC)\Platform.h

$(SCI_LIB_OBJDIR)\StyleContext.obj: \
    $(SCI_LIB)\StyleContext.cxx \
    $(SCI_LIB)\Accessor.h \
    $(SCI_LIB)\StyleContext.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_LIB)\LexAccessor.h

$(SCI_LIB_OBJDIR)\WordList.obj: \
    $(SCI_LIB)\WordList.cxx \
    $(SCI_LIB)\WordList.h


#####################
##  scintilla\src  ##
#####################
$(SCI_SRC_OBJDIR)\AutoComplete.obj: \
    $(SCI_SRC)\AutoComplete.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_LIB)\CharacterSet.h \
    $(SCI_SRC)\AutoComplete.h

$(SCI_SRC_OBJDIR)\CallTip.obj: \
    $(SCI_SRC)\CallTip.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\CallTip.h

$(SCI_SRC_OBJDIR)\Catalogue.obj: \
    $(SCI_SRC)\Catalogue.cxx \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\LexerModule.h \
    $(SCI_SRC)\Catalogue.h

$(SCI_SRC_OBJDIR)\CellBuffer.obj: \
    $(SCI_SRC)\CellBuffer.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\CellBuffer.h

$(SCI_SRC_OBJDIR)\CharClassify.obj: \
    $(SCI_SRC)\CharClassify.cxx \
    $(SCI_SRC)\CharClassify.h

$(SCI_SRC_OBJDIR)\ContractionState.obj: \
    $(SCI_SRC)\ContractionState.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\ContractionState.h

$(SCI_SRC_OBJDIR)\Decoration.obj: \
    $(SCI_SRC)\Decoration.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\Decoration.h

$(SCI_SRC_OBJDIR)\Document.obj: \
    $(SCI_SRC)\Document.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\CellBuffer.h \
    $(SCI_SRC)\PerLine.h \
    $(SCI_SRC)\CharClassify.h \
    $(SCI_LIB)\CharacterSet.h \
    $(SCI_SRC)\Decoration.h \
    $(SCI_SRC)\Document.h \
    $(SCI_SRC)\RESearch.h \
    $(SCI_SRC)\UniConversion.h

$(SCI_SRC_OBJDIR)\Editor.obj: \
    $(SCI_SRC)\Editor.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\ContractionState.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\CellBuffer.h \
    $(SCI_SRC)\KeyMap.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\Indicator.h \
    $(SCI_SRC)\XPM.h \
    $(SCI_SRC)\LineMarker.h \
    $(SCI_SRC)\Style.h \
    $(SCI_SRC)\ViewStyle.h \
    $(SCI_SRC)\CharClassify.h \
    $(SCI_SRC)\Decoration.h \
    $(SCI_SRC)\Document.h \
    $(SCI_SRC)\Editor.h \
    $(SCI_SRC)\Selection.h \
    $(SCI_SRC)\PositionCache.h

$(SCI_SRC_OBJDIR)\ExternalLexer.obj: \
    $(SCI_SRC)\ExternalLexer.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_INC)\SciLexer.h \
    $(SCI_LIB)\LexerModule.h \
    $(SCI_SRC)\Catalogue.h \
    $(SCI_SRC)\ExternalLexer.h

$(SCI_SRC_OBJDIR)\Indicator.obj: \
    $(SCI_SRC)\Indicator.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\Indicator.h

$(SCI_SRC_OBJDIR)\KeyMap.obj: \
    $(SCI_SRC)\KeyMap.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\KeyMap.h

$(SCI_SRC_OBJDIR)\LineMarker.obj: \
    $(SCI_SRC)\LineMarker.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\XPM.h \
    $(SCI_SRC)\LineMarker.h

$(SCI_SRC_OBJDIR)\PerLine.obj: \
    $(SCI_SRC)\PerLine.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\CellBuffer.h \
    $(SCI_SRC)\PerLine.h

$(SCI_SRC_OBJDIR)\PositionCache.obj: \
    $(SCI_SRC)\PositionCache.cxx \
    $(SCI_INC)\Platform.h  \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h  \
    $(SCI_SRC)\Partitioning.h  \
    $(SCI_SRC)\RunStyles.h  \
    $(SCI_SRC)\ContractionState.h  \
    $(SCI_SRC)\CellBuffer.h \
    $(SCI_SRC)\KeyMap.h  \
    $(SCI_SRC)\Indicator.h  \
    $(SCI_SRC)\XPM.h  \
    $(SCI_SRC)\LineMarker.h  \
    $(SCI_SRC)\Style.h \
    $(SCI_SRC)\ViewStyle.h \
    $(SCI_SRC)\CharClassify.h  \
    $(SCI_SRC)\Decoration.h  \
    $(SCI_INC)\ILexer.h  \
    $(SCI_SRC)\Document.h  \
    $(SCI_SRC)\Selection.h \
    $(SCI_SRC)\PositionCache.h

$(SCI_SRC_OBJDIR)\RESearch.obj: \
    $(SCI_SRC)\RESearch.cxx \
    $(SCI_SRC)\CharClassify.h \
    $(SCI_SRC)\RESearch.h

$(SCI_SRC_OBJDIR)\RunStyles.obj: \
    $(SCI_SRC)\RunStyles.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h

$(SCI_SRC_OBJDIR)\ScintillaBase.obj: \
    $(SCI_SRC)\ScintillaBase.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_LIB)\PropSetSimple.h \
    $(SCI_SRC)\ContractionState.h \
    $(SCI_SRC)\SVector.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\CellBuffer.h \
    $(SCI_SRC)\CallTip.h \
    $(SCI_SRC)\KeyMap.h \
    $(SCI_SRC)\Indicator.h \
    $(SCI_SRC)\XPM.h \
    $(SCI_SRC)\LineMarker.h \
    $(SCI_SRC)\Style.h \
    $(SCI_SRC)\ViewStyle.h \
    $(SCI_SRC)\AutoComplete.h \
    $(SCI_SRC)\CharClassify.h \
    $(SCI_SRC)\Decoration.h \
    $(SCI_SRC)\Document.h \
    $(SCI_SRC)\Editor.h \
    $(SCI_SRC)\Selection.h \
    $(SCI_SRC)\ScintillaBase.h

$(SCI_SRC_OBJDIR)\Selection.obj: \
    $(SCI_SRC)\Selection.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\Selection.h

$(SCI_SRC_OBJDIR)\Style.obj: \
    $(SCI_SRC)\Style.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\Style.h

$(SCI_SRC_OBJDIR)\UniConversion.obj: \
    $(SCI_SRC)\UniConversion.cxx \
    $(SCI_SRC)\UniConversion.h

$(SCI_SRC_OBJDIR)\ViewStyle.obj: \
    $(SCI_SRC)\ViewStyle.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\Indicator.h \
    $(SCI_SRC)\XPM.h \
    $(SCI_SRC)\LineMarker.h \
    $(SCI_SRC)\Style.h \
    $(SCI_SRC)\ViewStyle.h

$(SCI_SRC_OBJDIR)\XPM.obj: \
    $(SCI_SRC)\XPM.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_SRC)\XPM.h


#######################
##  scintilla\win32  ##
#######################
$(SCI_WIN_OBJDIR)\PlatWin.obj: \
    $(SCI_WIN)\PlatWin.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_SRC)\UniConversion.h \
    $(SCI_SRC)\XPM.h \
    $(SCI_SRC)\FontQuality.h

$(SCI_WIN_OBJDIR)\ScintillaWin.obj: \
    $(SCI_WIN)\ScintillaWin.cxx \
    $(SCI_INC)\Platform.h \
    $(SCI_INC)\ILexer.h \
    $(SCI_INC)\Scintilla.h \
    $(SCI_SRC)\ContractionState.h \
    $(SCI_SRC)\SVector.h \
    $(SCI_SRC)\SplitVector.h \
    $(SCI_SRC)\Partitioning.h \
    $(SCI_SRC)\RunStyles.h \
    $(SCI_SRC)\CellBuffer.h \
    $(SCI_SRC)\CallTip.h \
    $(SCI_SRC)\KeyMap.h \
    $(SCI_SRC)\Indicator.h \
    $(SCI_SRC)\XPM.h \
    $(SCI_SRC)\LineMarker.h \
    $(SCI_SRC)\Style.h \
    $(SCI_SRC)\AutoComplete.h \
    $(SCI_SRC)\ViewStyle.h \
    $(SCI_SRC)\CharClassify.h \
    $(SCI_SRC)\Decoration.h \
    $(SCI_SRC)\Document.h \
    $(SCI_SRC)\Editor.h \
    $(SCI_SRC)\ScintillaBase.h \
    $(SCI_SRC)\Selection.h \
    $(SCI_SRC)\UniConversion.h


###########
##  src  ##
###########
$(NP2_SRC_OBJDIR)\Dialogs.obj: \
    $(NP2_SRC)\Dialogs.c \
    $(NP2_SRC)\Notepad2.h \
    $(NP2_SRC)\Edit.h \
    $(NP2_SRC)\Helpers.h \
    $(NP2_SRC)\Dlapi.h \
    $(NP2_SRC)\Dialogs.h \
    $(NP2_SRC)\resource.h \
    $(NP2_SRC)\Version.h \
    $(NP2_SRC)\Version_rev.h

$(NP2_SRC_OBJDIR)\Dlapi.obj: \
    $(NP2_SRC)\Dlapi.c \
    $(NP2_SRC)\Dlapi.h

$(NP2_SRC_OBJDIR)\Edit.obj: \
    $(NP2_SRC)\Edit.c \
    $(NP2_SRC)\Notepad2.h \
    $(NP2_SRC)\Helpers.h \
    $(NP2_SRC)\Dialogs.h \
    $(NP2_SRC)\Styles.h \
    $(NP2_SRC)\Edit.h \
    $(NP2_SRC)\resource.h

$(NP2_SRC_OBJDIR)\Helpers.obj: \
    $(NP2_SRC)\Helpers.c \
    $(NP2_SRC)\Helpers.h

$(NP2_SRC_OBJDIR)\Notepad2.obj: \
    $(NP2_SRC)\Notepad2.c \
    $(NP2_SRC)\Edit.h \
    $(NP2_SRC)\Styles.h \
    $(NP2_SRC)\Helpers.h \
    $(NP2_SRC)\Dialogs.h \
    $(NP2_SRC)\Notepad2.h \
    $(NP2_SRC)\resource.h

$(NP2_SRC_OBJDIR)\Notepad2.res: \
    $(NP2_SRC)\Notepad2.rc \
    $(NP2_SRC)\Notepad2.ver \
    $(NP2_SRC)\Version.h \
    $(NP2_SRC)\Version_rev.h \
    $(NP2_RES)\Copy.cur \
    $(NP2_RES)\Encoding.bmp \
    $(NP2_RES)\Next.bmp \
    $(NP2_RES)\Notepad2.exe.manifest \
    $(NP2_RES)\Notepad2.ico \
    $(NP2_RES)\Open.bmp \
    $(NP2_RES)\Pick.bmp \
    $(NP2_RES)\Prev.bmp \
    $(NP2_RES)\Run.ico \
    $(NP2_RES)\Styles.ico \
    $(NP2_RES)\Toolbar.bmp

$(NP2_SRC_OBJDIR)\Print.obj: \
    $(NP2_SRC)\Print.cpp \
    $(NP2_SRC)\Dialogs.h \
    $(NP2_SRC)\Helpers.h \
    $(NP2_SRC)\resource.h

$(NP2_SRC_OBJDIR)\Styles.obj: \
    $(NP2_SRC)\Styles.c \
    $(NP2_SRC)\Dialogs.h \
    $(NP2_SRC)\Helpers.h \
    $(NP2_SRC)\Notepad2.h \
    $(NP2_SRC)\Edit.h \
    $(NP2_SRC)\Styles.h \
    $(NP2_SRC)\resource.h
