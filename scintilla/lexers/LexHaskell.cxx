/******************************************************************
 *    LexHaskell.cxx
 *
 *    A haskell lexer for the scintilla code control.
 *    Some stuff "lended" from LexPython.cxx and LexCPP.cxx.
 *    External lexer stuff inspired from the caml external lexer.
 *    Folder copied from Python's.
 *
 *    Written by Tobias Engvall - tumm at dtek dot chalmers dot se
 *
 *    Several bug fixes by Krasimir Angelov - kr.angelov at gmail.com
 *
 *    Improved by kudah <kudahkukarek@gmail.com>
 *
 *    TODO:
 *    * A proper lexical folder to fold group declarations, comments, pragmas,
 *      #ifdefs, explicit layout, lists, tuples, quasi-quotes, splces, etc, etc,
 *      etc.
 *
 *****************************************************************/
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <stdarg.h>
#include <assert.h>
#include <ctype.h>

#include <string>
#include <map>

#include "ILexer.h"
#include "Scintilla.h"
#include "SciLexer.h"

#include "PropSetSimple.h"
#include "WordList.h"
#include "LexAccessor.h"
#include "Accessor.h"
#include "StyleContext.h"
#include "CharacterSet.h"
#include "LexerModule.h"
#include "OptionSet.h"

#ifdef SCI_NAMESPACE
using namespace Scintilla;
#endif

#define HA_MODE_DEFAULT     0
#define HA_MODE_IMPORT1     1
#define HA_MODE_IMPORT2     2
#define HA_MODE_IMPORT3     3
#define HA_MODE_MODULE      4
#define HA_MODE_FFI         5
#define HA_MODE_TYPE        6
#define HA_MODE_PRAGMA      7

#define INDENT_OFFSET       1

static int u_iswalpha(int);
static int u_iswalnum(int);
static int u_iswupper(int);
static int u_IsHaskellSymbol(int);

// #define HASKELL_UNICODE

#ifndef HASKELL_UNICODE

// Stubs

static int u_iswalpha(int) {
   return 0;
}

static int u_iswalnum(int) {
   return 0;
}

static int u_iswupper(int) {
   return 0;
}

static int u_IsHaskellSymbol(int) {
   return 0;
}

#endif

static inline bool IsHaskellLetter(const int ch) {
   if (IsASCII(ch)) {
      return (ch >= 'a' && ch <= 'z')
          || (ch >= 'A' && ch <= 'Z');
   } else {
      return u_iswalpha(ch) != 0;
   }
}

static inline bool IsHaskellAlphaNumeric(const int ch) {
   if (IsASCII(ch)) {
      return IsAlphaNumeric(ch);
   } else {
      return u_iswalnum(ch) != 0;
   }
}

static inline bool IsHaskellUpperCase(const int ch) {
   if (IsASCII(ch)) {
      return ch >= 'A' && ch <= 'Z';
   } else {
      return u_iswupper(ch) != 0;
   }
}

static inline bool IsAnHaskellOperatorChar(const int ch) {
   if (IsASCII(ch)) {
      return
         (  ch == '!' || ch == '#' || ch == '$' || ch == '%'
         || ch == '&' || ch == '*' || ch == '+' || ch == '-'
         || ch == '.' || ch == '/' || ch == ':' || ch == '<'
         || ch == '=' || ch == '>' || ch == '?' || ch == '@'
         || ch == '^' || ch == '|' || ch == '~' || ch == '\\');
   } else {
      return u_IsHaskellSymbol(ch) != 0;
   }
}

static inline bool IsAHaskellWordStart(const int ch) {
   return IsHaskellLetter(ch) || ch == '_';
}

static inline bool IsAHaskellWordChar(const int ch) {
   return (  IsHaskellAlphaNumeric(ch)
          || ch == '_'
          || ch == '\'');
}

static inline bool IsCommentBlockStyle(int style) {
   return (style >= SCE_HA_COMMENTBLOCK && style <= SCE_HA_COMMENTBLOCK3);
}

static inline bool IsCommentStyle(int style) {
   return (style >= SCE_HA_COMMENTLINE && style <= SCE_HA_COMMENTBLOCK3);
}

inline int StyleFromNestLevel(const unsigned int nestLevel) {
      return SCE_HA_COMMENTBLOCK + (nestLevel % 3);
   }

struct OptionsHaskell {
   bool magicHash;
   bool allowQuotes;
   bool implicitParams;
   bool highlightSafe;
   bool stylingWithinPreprocessor;
   bool fold;
   bool foldComment;
   bool foldCompact;
   bool foldImports;
   bool foldIndentedImports;
   OptionsHaskell() {
      magicHash = true;       // Widespread use, enabled by default.
      allowQuotes = true;     // Widespread use, enabled by default.
      implicitParams = false; // Fell out of favor, seldom used, disabled.
      highlightSafe = true;   // Moderately used, doesn't hurt to enable.
      stylingWithinPreprocessor = false;
      fold = false;
      foldComment = false;
      foldCompact = false;
      foldImports = false;
      foldIndentedImports = true;
   }
};

static const char * const haskellWordListDesc[] = {
   "Keywords",
   "FFI",
   0
};

struct OptionSetHaskell : public OptionSet<OptionsHaskell> {
   OptionSetHaskell() {
      DefineProperty("lexer.haskell.allow.hash", &OptionsHaskell::magicHash,
         "Set to 0 to disallow the '#' character at the end of identifiers and "
         "literals with the haskell lexer "
         "(GHC -XMagicHash extension)");

      DefineProperty("lexer.haskell.allow.quotes", &OptionsHaskell::allowQuotes,
         "Set to 0 to disable highlighting of Template Haskell name quotations "
         "and promoted constructors "
         "(GHC -XTemplateHaskell and -XDataKinds extensions)");

      DefineProperty("lexer.haskell.allow.questionmark", &OptionsHaskell::implicitParams,
         "Set to 1 to allow the '?' character at the start of identifiers "
         "with the haskell lexer "
         "(GHC & Hugs -XImplicitParams extension)");

      DefineProperty("lexer.haskell.import.safe", &OptionsHaskell::highlightSafe,
         "Set to 0 to disallow \"safe\" keyword in imports "
         "(GHC -XSafe, -XTrustworthy, -XUnsafe extensions)");

      DefineProperty("styling.within.preprocessor", &OptionsHaskell::stylingWithinPreprocessor,
         "For Haskell code, determines whether all preprocessor code is styled in the "
         "preprocessor style (0, the default) or only from the initial # to the end "
         "of the command word(1)."
         );

      DefineProperty("fold", &OptionsHaskell::fold);

      DefineProperty("fold.comment", &OptionsHaskell::foldComment);

      DefineProperty("fold.compact", &OptionsHaskell::foldCompact);

      DefineProperty("fold.haskell.imports", &OptionsHaskell::foldImports,
         "Set to 1 to enable folding of import declarations");

      DefineProperty("fold.haskell.imports.indented", &OptionsHaskell::foldIndentedImports,
         "Set this property to 0 to disable folding imports not starting at "
         "column 0 when fold.haskell.imports=1");

      DefineWordListSets(haskellWordListDesc);
   }
};

class LexerHaskell : public ILexer {
   int firstImportLine;
   WordList keywords;
   WordList ffi;
   WordList reserved_operators;
   OptionsHaskell options;
   OptionSetHaskell osHaskell;

   enum HashCount {
       oneHash
      ,twoHashes
      ,unlimitedHashes
   };

   inline void skipMagicHash(StyleContext &sc, const HashCount hashes) {
      if (options.magicHash && sc.ch == '#') {
         sc.Forward();
         if (hashes == twoHashes && sc.ch == '#') {
            sc.Forward();
         } else if (hashes == unlimitedHashes) {
            while (sc.ch == '#') {
               sc.Forward();
            }
         }
      }
   }

   bool LineContainsImport(const int line, Accessor &styler) {
      if (options.foldImports) {
         int currentPos = styler.LineStart(line);
         int style = styler.StyleAt(currentPos);

         if (options.foldIndentedImports) {
            int eol_pos = styler.LineStart(line + 1) - 1;

            while (currentPos < eol_pos) {
               int ch = styler[currentPos];
               style = styler.StyleAt(currentPos);

               if (ch == ' ' || ch == '\t'
                || IsCommentBlockStyle(style)) {
                  currentPos++;
               } else {
                  break;
               }
            }
         }

         return (style == SCE_HA_KEYWORD
              && styler.Match(currentPos, "import"));
      } else {
         return false;
      }
   }
public:
   LexerHaskell() : firstImportLine(-1) {}
   virtual ~LexerHaskell() {}

   void SCI_METHOD Release() {
      delete this;
   }

   int SCI_METHOD Version() const {
      return lvOriginal;
   }

   const char * SCI_METHOD PropertyNames() {
      return osHaskell.PropertyNames();
   }

   int SCI_METHOD PropertyType(const char *name) {
      return osHaskell.PropertyType(name);
   }

   const char * SCI_METHOD DescribeProperty(const char *name) {
      return osHaskell.DescribeProperty(name);
   }

   int SCI_METHOD PropertySet(const char *key, const char *val);

   const char * SCI_METHOD DescribeWordListSets() {
      return osHaskell.DescribeWordListSets();
   }

   int SCI_METHOD WordListSet(int n, const char *wl);

   void SCI_METHOD Lex(unsigned int startPos, int length, int initStyle, IDocument *pAccess);

   void SCI_METHOD Fold(unsigned int startPos, int length, int initStyle, IDocument *pAccess);

   void * SCI_METHOD PrivateCall(int, void *) {
      return 0;
   }

   static ILexer *LexerFactoryHaskell() {
      return new LexerHaskell();
   }
};

int SCI_METHOD LexerHaskell::PropertySet(const char *key, const char *val) {
   if (osHaskell.PropertySet(&options, key, val)) {
      return 0;
   }
   return -1;
}

int SCI_METHOD LexerHaskell::WordListSet(int n, const char *wl) {
   WordList *wordListN = 0;
   switch (n) {
   case 0:
      wordListN = &keywords;
      break;
   case 1:
      wordListN = &ffi;
      break;
   case 2:
      wordListN = &reserved_operators;
      break;
   }
   int firstModification = -1;
   if (wordListN) {
      WordList wlNew;
      wlNew.Set(wl);
      if (*wordListN != wlNew) {
         wordListN->Set(wl);
         firstModification = 0;
      }
   }
   return firstModification;
}

void SCI_METHOD LexerHaskell::Lex(unsigned int startPos, int length, int initStyle
                                 ,IDocument *pAccess) {
   LexAccessor styler(pAccess);

   // Do not leak onto next line
   if (initStyle == SCE_HA_STRINGEOL)
      initStyle = SCE_HA_DEFAULT;

   StyleContext sc(startPos, length, initStyle, styler);

   int lineCurrent = styler.GetLine(startPos);

   int state = lineCurrent ? styler.GetLineState(lineCurrent-1) : 0;
   int mode  = state & 0x7;
   int nestLevel = state >> 3;

   int base = 10;
   bool dot = false;

   bool inDashes = false;

   assert(!(IsCommentBlockStyle(initStyle) && nestLevel <= 0));

   while (sc.More()) {
      // Check for state end

      // For line numbering (and by extension, nested comments) to work,
      // states should always forward one character at a time.
      // states should match on line ends using OnLineEnd function.
      // If a state sometimes does _not_ forward a character, it should check
      // first if it's not on a line end and forward otherwise.
      // If a state forwards more than one character, it should check every time
      // that it is not a line end and cease forwarding otherwise.
      if (sc.atLineEnd) {
         // Remember the line state for future incremental lexing
         styler.SetLineState(lineCurrent, (nestLevel << 3) | mode);
         lineCurrent++;
      }

      if (sc.atLineStart && (sc.state == SCE_HA_STRING || sc.state == SCE_HA_CHARACTER)) {
         // Prevent SCE_HA_STRINGEOL from leaking back to previous line
         sc.SetState(sc.state);
      }

      // Handle line continuation generically.
      if (sc.ch == '\\' &&
         (  sc.state == SCE_HA_STRING
         || sc.state == SCE_HA_PREPROCESSOR)) {
         if (sc.chNext == '\n' || sc.chNext == '\r') {
            sc.Forward();

            // Remember the line state for future incremental lexing
            styler.SetLineState(lineCurrent, (nestLevel << 3) | mode);
            lineCurrent++;

            if (sc.ch == '\r' && sc.chNext == '\n') {
               sc.Forward();
            }
            sc.Forward();
            continue;
         }
      }

         // Operator
      if (sc.state == SCE_HA_OPERATOR) {
         int style = SCE_HA_OPERATOR;

         if (sc.ch == ':' &&
            // except "::"
            !(sc.chNext == ':' && !IsAnHaskellOperatorChar(sc.GetRelative(2)))) {
            style = SCE_HA_CAPITAL;
         }

         while (IsAnHaskellOperatorChar(sc.ch))
               sc.Forward();

         char s[100];
         sc.GetCurrent(s, sizeof(s));

         if (reserved_operators.InList(s))
            style = SCE_HA_RESERVED_OPERATOR;

         sc.ChangeState(style);
         sc.SetState(SCE_HA_DEFAULT);
      }
         // String
      else if (sc.state == SCE_HA_STRING) {
         if (sc.atLineEnd) {
            sc.ChangeState(SCE_HA_STRINGEOL);
            sc.ForwardSetState(SCE_HA_DEFAULT);
         } else if (sc.ch == '\"') {
            sc.Forward();
            skipMagicHash(sc, oneHash);
            sc.SetState(SCE_HA_DEFAULT);
         } else if (sc.ch == '\\') {
            sc.Forward(2);
         } else {
            sc.Forward();
         }
      }
         // Char
      else if (sc.state == SCE_HA_CHARACTER) {
         if (sc.atLineEnd) {
            sc.ChangeState(SCE_HA_STRINGEOL);
            sc.ForwardSetState(SCE_HA_DEFAULT);
         } else if (sc.ch == '\'') {
            sc.Forward();
            skipMagicHash(sc, oneHash);
            sc.SetState(SCE_HA_DEFAULT);
         } else if (sc.ch == '\\') {
            sc.Forward(2);
         } else {
            sc.Forward();
         }
      }
         // Number
      else if (sc.state == SCE_HA_NUMBER) {
         if (IsADigit(sc.ch, base)) {
            sc.Forward();
         } else if (sc.ch=='.' && dot && IsADigit(sc.chNext, base)) {
            sc.Forward(2);
            dot = false;
         } else if ((base == 10) &&
                    (sc.ch == 'e' || sc.ch == 'E') &&
                    (IsADigit(sc.chNext) || sc.chNext == '+' || sc.chNext == '-')) {
            sc.Forward();
            if (sc.ch == '+' || sc.ch == '-')
                sc.Forward();
         } else {
            skipMagicHash(sc, twoHashes);
            sc.SetState(SCE_HA_DEFAULT);
         }
      }
         // Keyword or Identifier
      else if (sc.state == SCE_HA_IDENTIFIER) {
         int style = IsHaskellUpperCase(sc.ch) ? SCE_HA_CAPITAL : SCE_HA_IDENTIFIER;

         assert(IsAHaskellWordStart(sc.ch));

         sc.Forward();

         while (sc.More()) {
            if (IsAHaskellWordChar(sc.ch)) {
               sc.Forward();
            } else if (sc.ch == '.' && style == SCE_HA_CAPITAL) {
               if (IsHaskellUpperCase(sc.chNext)) {
                  sc.Forward();
                  style = SCE_HA_CAPITAL;
               } else if (IsAHaskellWordStart(sc.chNext)) {
                  sc.Forward();
                  style = SCE_HA_IDENTIFIER;
               } else if (IsAnHaskellOperatorChar(sc.chNext)) {
                  sc.Forward();
                  style = sc.ch == ':' ? SCE_HA_CAPITAL : SCE_HA_OPERATOR;
                  while (IsAnHaskellOperatorChar(sc.ch))
                     sc.Forward();
                  break;
               } else {
                  break;
               }
            } else {
               break;
            }
         }

         skipMagicHash(sc, unlimitedHashes);

         char s[100];
         sc.GetCurrent(s, sizeof(s));

         int new_mode = HA_MODE_DEFAULT;

         if (keywords.InList(s)) {
            style = SCE_HA_KEYWORD;
         } else if (style == SCE_HA_CAPITAL) {
            if (mode == HA_MODE_IMPORT1 || mode == HA_MODE_IMPORT3) {
               style    = SCE_HA_MODULE;
               new_mode = HA_MODE_IMPORT2;
            } else if (mode == HA_MODE_MODULE) {
               style = SCE_HA_MODULE;
            }
         } else if (mode == HA_MODE_IMPORT1 &&
                    strcmp(s,"qualified") == 0) {
             style    = SCE_HA_KEYWORD;
             new_mode = HA_MODE_IMPORT1;
         } else if (options.highlightSafe &&
                    mode == HA_MODE_IMPORT1 &&
                    strcmp(s,"safe") == 0) {
             style    = SCE_HA_KEYWORD;
             new_mode = HA_MODE_IMPORT1;
         } else if (mode == HA_MODE_IMPORT2) {
             if (strcmp(s,"as") == 0) {
                style    = SCE_HA_KEYWORD;
                new_mode = HA_MODE_IMPORT3;
            } else if (strcmp(s,"hiding") == 0) {
                style     = SCE_HA_KEYWORD;
            }
         } else if (mode == HA_MODE_TYPE) {
            if (strcmp(s,"family") == 0)
               style    = SCE_HA_KEYWORD;
         }

         if (mode == HA_MODE_FFI) {
            if (ffi.InList(s)) {
               style = SCE_HA_KEYWORD;
               new_mode = HA_MODE_FFI;
            }
         }

         sc.ChangeState(style);
         sc.SetState(SCE_HA_DEFAULT);

         if (strcmp(s,"import") == 0 && mode != HA_MODE_FFI)
            new_mode = HA_MODE_IMPORT1;
         else if (strcmp(s,"module") == 0)
            new_mode = HA_MODE_MODULE;
         else if (strcmp(s,"foreign") == 0)
            new_mode = HA_MODE_FFI;
         else if (strcmp(s,"type") == 0
               || strcmp(s,"data") == 0)
            new_mode = HA_MODE_TYPE;

         mode = new_mode;
      }

         // Comments
            // Oneliner
      else if (sc.state == SCE_HA_COMMENTLINE) {
         if (sc.atLineEnd) {
            sc.SetState(mode == HA_MODE_PRAGMA ? SCE_HA_PRAGMA : SCE_HA_DEFAULT);
            sc.Forward(); // prevent double counting a line
         } else if (inDashes && sc.ch != '-' && mode != HA_MODE_PRAGMA) {
            inDashes = false;
            if (IsAnHaskellOperatorChar(sc.ch))
               sc.ChangeState(SCE_HA_OPERATOR);
         } else {
            sc.Forward();
         }
      }
            // Nested
      else if (IsCommentBlockStyle(sc.state)) {
         if (sc.Match('{','-')) {
            sc.SetState(StyleFromNestLevel(nestLevel));
            sc.Forward(2);
            nestLevel++;
         } else if (sc.Match('-','}')) {
            sc.Forward(2);
            nestLevel--;
            assert(nestLevel >= 0);
            sc.SetState(
               nestLevel <= 0
                  ? (mode == HA_MODE_PRAGMA ? SCE_HA_PRAGMA : SCE_HA_DEFAULT)
                  : StyleFromNestLevel(nestLevel - 1));
         } else {
            sc.Forward();
         }
      }
            // Pragma
      else if (sc.state == SCE_HA_PRAGMA) {
         if (sc.Match("#-}")) {
            mode = HA_MODE_DEFAULT;
            sc.Forward(3);
            sc.SetState(SCE_HA_DEFAULT);
         } else if (sc.Match('-','-')) {
            sc.SetState(SCE_HA_COMMENTLINE);
            sc.Forward(2);
            inDashes = false;
         } else if (sc.Match('{','-')) {
            sc.SetState(StyleFromNestLevel(nestLevel));
            sc.Forward(2);
            nestLevel = 1;
         } else {
            sc.Forward();
         }
      }
            // Preprocessor
      else if (sc.state == SCE_HA_PREPROCESSOR) {
         if (sc.atLineEnd) {
            sc.SetState(SCE_HA_DEFAULT);
            sc.Forward(); // prevent double counting a line
         } else if (options.stylingWithinPreprocessor && !IsHaskellLetter(sc.ch)) {
            sc.SetState(SCE_HA_DEFAULT);
         } else {
            sc.Forward();
         }
      }
            // New state?
      else if (sc.state == SCE_HA_DEFAULT) {
         // Digit
         if (IsADigit(sc.ch)) {
            sc.SetState(SCE_HA_NUMBER);
            if (sc.ch == '0' && (sc.chNext == 'X' || sc.chNext == 'x')) {
               // Match anything starting with "0x" or "0X", too
               sc.Forward(2);
               base = 16;
               dot = false;
            } else if (sc.ch == '0' && (sc.chNext == 'O' || sc.chNext == 'o')) {
               // Match anything starting with "0o" or "0O", too
               sc.Forward(2);
               base = 8;
               dot = false;
            } else {
               sc.Forward();
               base = 10;
               dot = true;
            }
            mode = HA_MODE_DEFAULT;
         }
         // Pragma
         else if (sc.Match("{-#")) {
            mode = HA_MODE_PRAGMA;
            sc.SetState(SCE_HA_PRAGMA);
            sc.Forward(3);
         }
         // Comment line
         else if (sc.Match('-','-')) {
            sc.SetState(SCE_HA_COMMENTLINE);
            sc.Forward(2);
            inDashes = true;
         }
         // Comment block
         else if (sc.Match('{','-')) {
            sc.SetState(StyleFromNestLevel(nestLevel));
            sc.Forward(2);
            nestLevel = 1;
         }
         // String
         else if (sc.ch == '\"') {
            sc.SetState(SCE_HA_STRING);
            sc.Forward();
         }
         // Character or quoted name
         else if (sc.ch == '\'') {
            sc.SetState(SCE_HA_CHARACTER);
            sc.Forward();

            if (options.allowQuotes) {
               // Quoted type ''T
               if (sc.ch=='\'' && IsAHaskellWordStart(sc.chNext)) {
                  sc.Forward();
                  sc.ChangeState(SCE_HA_IDENTIFIER);
               } else if (sc.chNext != '\'') {
                  // Quoted value or promoted constructor 'N
                  if (IsAHaskellWordStart(sc.ch)) {
                     sc.ChangeState(SCE_HA_IDENTIFIER);
                  // Promoted constructor operator ':~>
                  } else if (sc.ch == ':') {
                     sc.ChangeState(SCE_HA_OPERATOR);
                  // Promoted list or tuple '[T]
                  } else if (sc.ch == '[' || sc.ch== '(') {
                     styler.ColourTo(sc.currentPos - 1, SCE_HA_OPERATOR);
                     sc.ChangeState(SCE_HA_DEFAULT);
                  }
               }
            }
         }
         // Operator starting with '?' or an implicit parameter
         else if (sc.ch == '?') {
            sc.SetState(SCE_HA_OPERATOR);

            if (  options.implicitParams
               && IsAHaskellWordStart(sc.chNext)
               && !IsHaskellUpperCase(sc.chNext)) {
               sc.Forward();
               sc.ChangeState(SCE_HA_IDENTIFIER);
            }
         }
         // Preprocessor
         else if (sc.atLineStart && sc.ch == '#') {
            mode = HA_MODE_DEFAULT;
            sc.SetState(SCE_HA_PREPROCESSOR);
            sc.Forward();
         }
         // Operator
         else if (IsAnHaskellOperatorChar(sc.ch)) {
            mode = HA_MODE_DEFAULT;
            sc.SetState(SCE_HA_OPERATOR);
         }
         // Braces and punctuation
         else if (sc.ch == ',' || sc.ch == ';'
               || sc.ch == '(' || sc.ch == ')'
               || sc.ch == '[' || sc.ch == ']'
               || sc.ch == '{' || sc.ch == '}') {
            sc.SetState(SCE_HA_OPERATOR);
            sc.ForwardSetState(SCE_HA_DEFAULT);
         }
         // Keyword or Identifier
         else if (IsAHaskellWordStart(sc.ch)) {
            sc.SetState(SCE_HA_IDENTIFIER);
         // Something we don't care about
         } else {
            sc.Forward();
         }
      }
            // This branch should never be reached.
      else {
         assert(false);
         sc.Forward();
      }
   }
   styler.SetLineState(lineCurrent, (nestLevel << 3) | mode);
   sc.Complete();
}

// Mangled version of lexlib/Accessor.cxx IndentAmount.
// Modified to treat comment blocks as whitespace
// plus special case for commentline/preprocessor.
static int HaskellIndentAmount(Accessor &styler, int line) {

   // Determines the indentation level of the current line
   // Comment blocks are treated as whitespace

   int pos = styler.LineStart(line);
   int eol_pos = styler.LineStart(line + 1) - 1;

   char ch = styler[pos];
   int style = styler.StyleAt(pos);

   int indent = 0;
   bool inPrevPrefix = line > 0;

   int posPrev = inPrevPrefix ? styler.LineStart(line-1) : 0;

   while ((ch == ' ' || ch == '\t' || IsCommentBlockStyle(style)) && (pos < eol_pos)) {
      if (inPrevPrefix) {
         char chPrev = styler[posPrev++];
         if (chPrev != ' ' && chPrev != '\t') {
            inPrevPrefix = false;
         }
      }
      if (ch == '\t') {
         indent = (indent / 8 + 1) * 8;
      } else { // Space or comment block
         indent++;
      }
      pos++;
      ch = styler[pos];
      style = styler.StyleAt(pos);
   }

   indent += SC_FOLDLEVELBASE;
   // if completely empty line or the start of a comment or preprocessor...
   if (  styler.LineStart(line) == styler.Length()
      || ch == ' '
      || ch == '\t'
      || ch == '\n'
      || ch == '\r'
      || IsCommentStyle(style)
      || style == SCE_HA_PREPROCESSOR)
      return indent | SC_FOLDLEVELWHITEFLAG;
   else
      return indent;
}

static inline int IndentAmountWithOffset(Accessor &styler, int line) {
   int indent = HaskellIndentAmount(styler, line);
   int indentLevel = indent & SC_FOLDLEVELNUMBERMASK;
   return indentLevel == (SC_FOLDLEVELBASE & SC_FOLDLEVELNUMBERMASK)
            ? indent
            : (indentLevel + INDENT_OFFSET) | (indent & ~SC_FOLDLEVELNUMBERMASK);
}

static inline int RemoveIndentOffset(int indentLevel) {
   return indentLevel == (SC_FOLDLEVELBASE & SC_FOLDLEVELNUMBERMASK)
         ? indentLevel
         : indentLevel - INDENT_OFFSET;
}

void SCI_METHOD LexerHaskell::Fold(unsigned int startPos, int length, int // initStyle
                                  ,IDocument *pAccess) {
   if (!options.fold)
      return;

   Accessor styler(pAccess, NULL);

   const int maxPos = startPos + length;
   const int maxLines =
      maxPos == styler.Length()
         ? styler.GetLine(maxPos)
         : styler.GetLine(maxPos - 1);  // Requested last line
   const int docLines = styler.GetLine(styler.Length()); // Available last line

   // Backtrack to previous non-blank line so we can determine indent level
   // for any white space lines
   // and so we can fix any preceding fold level (which is why we go back
   // at least one line in all cases)
   int lineCurrent = styler.GetLine(startPos);
   bool importHere = LineContainsImport(lineCurrent, styler);
   int indentCurrent = IndentAmountWithOffset(styler, lineCurrent);

   while (lineCurrent > 0) {
      lineCurrent--;
      importHere = LineContainsImport(lineCurrent, styler);
      indentCurrent = IndentAmountWithOffset(styler, lineCurrent);
      if (!(indentCurrent & SC_FOLDLEVELWHITEFLAG))
         break;
   }

   int indentCurrentLevel = indentCurrent & SC_FOLDLEVELNUMBERMASK;

   if (lineCurrent <= firstImportLine) {
      firstImportLine = -1; // readjust first import position
   }

   if (importHere) {
      if (firstImportLine == -1) {
         firstImportLine = lineCurrent;
      }
      indentCurrentLevel = RemoveIndentOffset(indentCurrentLevel);
      if (firstImportLine != lineCurrent) {
         indentCurrentLevel++;
      }
   }

   indentCurrent = indentCurrentLevel | (indentCurrent & ~SC_FOLDLEVELNUMBERMASK);

   // Process all characters to end of requested range
   //that hangs over the end of the range.  Cap processing in all cases
   // to end of document.
   while (lineCurrent <= docLines && lineCurrent <= maxLines) {

      // Gather info
      int lineNext = lineCurrent + 1;
      importHere = false;
      int indentNext = indentCurrent;

      if (lineNext <= docLines) {
         // Information about next line is only available if not at end of document
         importHere = LineContainsImport(lineNext, styler);
         indentNext = IndentAmountWithOffset(styler, lineNext);
      }
      if (indentNext & SC_FOLDLEVELWHITEFLAG)
         indentNext = SC_FOLDLEVELWHITEFLAG | indentCurrentLevel;

      // Skip past any blank lines for next indent level info; we skip also
      // comments (all comments, not just those starting in column 0)
      // which effectively folds them into surrounding code rather
      // than screwing up folding.

      while (lineNext < docLines && (indentNext & SC_FOLDLEVELWHITEFLAG)) {
         lineNext++;
         importHere = LineContainsImport(lineNext, styler);
         indentNext = IndentAmountWithOffset(styler, lineNext);
      }

      int indentNextLevel = indentNext & SC_FOLDLEVELNUMBERMASK;

      if (importHere) {
         if (firstImportLine == -1) {
            firstImportLine = lineNext;
         }
         indentNextLevel = RemoveIndentOffset(indentNextLevel);
         if (firstImportLine != lineNext) {
            indentNextLevel++;
         }
      }

      indentNext = indentNextLevel | (indentNext & ~SC_FOLDLEVELNUMBERMASK);

      const int levelBeforeComments = Maximum(indentCurrentLevel,indentNextLevel);

      // Now set all the indent levels on the lines we skipped
      // Do this from end to start.  Once we encounter one line
      // which is indented more than the line after the end of
      // the comment-block, use the level of the block before

      int skipLine = lineNext;
      int skipLevel = indentNextLevel;

      while (--skipLine > lineCurrent) {
         int skipLineIndent = IndentAmountWithOffset(styler, skipLine);

         if (options.foldCompact) {
            if ((skipLineIndent & SC_FOLDLEVELNUMBERMASK) > indentNextLevel) {
               skipLevel = levelBeforeComments;
            }

            int whiteFlag = skipLineIndent & SC_FOLDLEVELWHITEFLAG;

            styler.SetLevel(skipLine, skipLevel | whiteFlag);
         } else {
            if (  (skipLineIndent & SC_FOLDLEVELNUMBERMASK) > indentNextLevel
               && !(skipLineIndent & SC_FOLDLEVELWHITEFLAG)) {
               skipLevel = levelBeforeComments;
            }

            styler.SetLevel(skipLine, skipLevel);
         }
      }

      int lev = indentCurrent;

      if (!(indentCurrent & SC_FOLDLEVELWHITEFLAG)) {
         if ((indentCurrent & SC_FOLDLEVELNUMBERMASK) < (indentNext & SC_FOLDLEVELNUMBERMASK))
            lev |= SC_FOLDLEVELHEADERFLAG;
      }

      // Set fold level for this line and move to next line
      styler.SetLevel(lineCurrent, options.foldCompact ? lev : lev & ~SC_FOLDLEVELWHITEFLAG);

      indentCurrent = indentNext;
      indentCurrentLevel = indentNextLevel;
      lineCurrent = lineNext;
   }

   // NOTE: Cannot set level of last line here because indentCurrent doesn't have
   // header flag set; the loop above is crafted to take care of this case!
   //styler.SetLevel(lineCurrent, indentCurrent);
}

LexerModule lmHaskell(SCLEX_HASKELL, LexerHaskell::LexerFactoryHaskell, "haskell", haskellWordListDesc);
