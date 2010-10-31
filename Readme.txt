
=======================================================================
=                                                                     =
=                                                                     =
=   Notepad2 - light-weight Scintilla-based text editor for Windows   =
=                                                                     =
=                                                                     =
=                                                   Notepad2 4.1.24   =
=                                      (c) Florian Balmer 2004-2010   =
=                                       http://www.flos-freeware.ch   =
=                                                                     =
=                                                                     =
=======================================================================


The Notepad2 Source Code

  This package contains the full source code of Notepad2 4.1.24 for
  Windows. Project files for Visual C++ 7.0 are included. Chances are
  that Notepad2 can be rebuilt with other development tools, including
  the free Visual C++ Express Edition, but I haven't tested this.


Rebuilding from the Source Code

  To be able to rebuild Notepad2, the source code of the Scintilla
  editing component [1] has to be unzipped to the "Scintilla"
  subdirectory of the Notepad2 source code directory.

  [1] http://www.scintilla.org

  Notepad2 4.1.24 has been created with Scintilla 2.03. The following
  modification to the Scintilla source code is necessary:

  Scintilla/src/KeyWords.cxx:

      #define LINK_LEXER(lexer) extern LexerModule lexer; ...

    must be replaced with:

      #define LINK_LEXER(lexer) void(0)


Creating a Compact Executable Program File

  Linking to the system CRT slightly improves disk footprint, memory
  usage and startup because the pages for the system CRT are already
  loaded and shared in memory. To achieve this, the release version of
  Notepad2.exe is built using the Windows Driver Kit (WDK) 7.1.0 tools,
  available as a free download from Microsoft. The appropriate build
  scripts can be found in the "wdkbuild" subdirectory. Set %WDKBASEDIR%
  to the directory where the WDK tools are located on your system.


How to add or modify Syntax Schemes

  The Scintilla documentation has an overview of syntax highlighting,
  and how to write your own lexing module, in case the language you
  would like to add is not currently supported by Scintilla.

  Add your own lexer data structs to the global pLexArray (Styles.c),
  then adjust NUMLEXERS (Styles.h) to the new total number of syntax
  schemes. The style definitions can be found in SciLexer.h of the
  Scintilla source code. Include the Lex*.cxx file from Scintilla
  required for your language into your project.


Copyright

  See License.txt for details about distribution and modification.

  If you have any comments or questions, please drop me a note:
  florian.balmer@gmail.com

  (c) Florian Balmer 2004-2010
  http://www.flos-freeware.ch

###
