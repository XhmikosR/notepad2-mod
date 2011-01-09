/******************************************************************************
*
* Notepad2-mod
*
* Version.h
*
* See License.txt for details about distribution and modification.
*
*                                       (c) XhmikosR 2010-2011
*                                       http://code.google.com/p/notepad2-mod/
*
*
******************************************************************************/


#pragma once

#include "Version_rev.h"

#define DO_STRINGIFY(x) #x
#define STRINGIFY(x) DO_STRINGIFY(x)

#define VERSION_MAJOR 4
#define VERSION_MINOR 1
#define VERSION_BUILD 24

#define APPNAME_STRW     L"Notepad2"
#define APPNAME_STRW_X64 L"Notepad2 x64"
#define APPNAME_STRA     "Notepad2"
#define APPNAME_STRA_X64 "Notepad2 x64"


// Setup specific
#if defined(_WIN64)
  #define SETUP_TITLE_STR      "Notepad2 x64 Setup"
  #define SETUP_VERSION_LABEL  STRINGIFY(VERSION_MAJOR)"."STRINGIFY(VERSION_MINOR)"."STRINGIFY(VERSION_BUILD)" x64 (modified; rev."STRINGIFY(VERSION_REV)")"
#else
  #define SETUP_TITLE_STR      "Notepad2 Setup"
  #define SETUP_VERSION_LABEL  STRINGIFY(VERSION_MAJOR)"."STRINGIFY(VERSION_MINOR)"."STRINGIFY(VERSION_BUILD)" (modified; rev."STRINGIFY(VERSION_REV)")"
#endif
#define SETUP_AUTHOR_STR       "XhmikosR"

#undef REBOOT_MESSAGE
