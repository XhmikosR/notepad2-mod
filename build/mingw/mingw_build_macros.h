#ifndef MINGW_BUILD_MACROS_H
#define MINGW_BUILD_MACROS_H


#define VERSION_COMPILER__EXPAND_INNER(x) #x
#define VERSION_COMPILER__EXPAND(x) VERSION_COMPILER__EXPAND_INNER(x)
#define VERSION_COMPILER \
(L"MinGW " \
VERSION_COMPILER__EXPAND(__GNUC__) "." \
VERSION_COMPILER__EXPAND(__GNUC_MINOR__) "." \
VERSION_COMPILER__EXPAND(__GNUC_PATCHLEVEL__))


// https://msdn.microsoft.com/en-us/library/ms942642.aspx
#define TBBUTTON_INIT_6(\
iBitmap,idCommand,fsState,fsStyle,dwData,iString){\
iBitmap,idCommand,fsState,fsStyle,dwData,iString}

// https://sourceforge.net/p/mingw-w64/mingw-w64/ci/master/tree/mingw-w64-headers/include/commctrl.h
#define TBBUTTON_INIT_7(\
iBitmap,idCommand,fsState,fsStyle,dwData,iString){\
iBitmap,idCommand,fsState,fsStyle,{0},dwData,iString}

// https://docs.microsoft.com/en-us/windows/desktop/api/commctrl/ns-commctrl-_tbbutton
#define TBBUTTON_INIT_8(\
iBitmap,idCommand,fsState,fsStyle,dwData,iString){\
iBitmap,idCommand,fsState,fsStyle,{0},{0},dwData,iString}


#define EDITFINDREPLACE_INIT_11(\
szFind,szReplace,szFindUTF8,szReplaceUTF8,fuFlags,bTransformBS,\
bObsolete,bFindClose,bReplaceClose,bNoFindWrap,hwnd){\
szFind,szReplace,szFindUTF8,szReplaceUTF8,fuFlags,bTransformBS,\
bObsolete,bFindClose,bReplaceClose,bNoFindWrap,hwnd}

#define EDITFINDREPLACE_INIT_12(\
szFind,szReplace,szFindUTF8,szReplaceUTF8,fuFlags,bTransformBS,\
bObsolete,bFindClose,bReplaceClose,bNoFindWrap,hwnd){\
szFind,szReplace,szFindUTF8,szReplaceUTF8,fuFlags,bTransformBS,\
bObsolete,bFindClose,bReplaceClose,bNoFindWrap,hwnd,FALSE}


#define EDITLEXER_INIT_A(\
iLexer,rid,pszName,pszDefExt,szExtensions,pKeyWords,Styles){\
iLexer,rid,pszName,pszDefExt,szExtensions,pKeyWords,Styles}


#ifdef BOOKMARK_EDITION
#define EDITFINDREPLACE_INIT EDITFINDREPLACE_INIT_12
#else
#define EDITFINDREPLACE_INIT EDITFINDREPLACE_INIT_11
#endif // !BOOKMARK_EDITION


#ifdef MINGW_BUILD
#define TBBUTTON_INIT TBBUTTON_INIT_7
#define FORCE_INLINE __attribute__((always_inline))
// #define UNUSED __attribute__((unused))
// #define UNUSED_VAR(x)
// #define ALLOW_EXTRA_SEMICOLON(counter) char const dummy ## counter
#else
#define TBBUTTON_INIT TBBUTTON_INIT_6
// #define UNUSED
// #define UNUSED_VAR(x) x
// #define ALLOW_EXTRA_SEMICOLON(counter)
#endif // !MINGW_BUILD


#endif // !MINGW_BUILD_MACROS_H
