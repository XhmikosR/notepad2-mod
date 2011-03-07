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


#ifndef NOTEPAD2_VERSION_H
#define NOTEPAD2_VERSION_H

#include "Version_rev.h"

#define DO_STRINGIFY(x) #x
#define STRINGIFY(x) DO_STRINGIFY(x)

#define VERSION_MAJOR 4
#define VERSION_MINOR 2
#define VERSION_BUILD 25

#define APPNAME_STRW                 L"Notepad2-mod"
#define APPNAME_STRW_X64             L"Notepad2-mod x64"
#define APPNAME_STRA                 "Notepad2-mod"
#define APPNAME_STRA_X64             "Notepad2-mod x64"


#define VERSION_FILEVERSION_NUM      VERSION_MAJOR,VERSION_MINOR,VERSION_BUILD,VERSION_REV
#define VERSION_FILEVERSION          STRINGIFY(VERSION_MAJOR) ", " STRINGIFY(VERSION_MINOR) ", " STRINGIFY(VERSION_BUILD) ", " STRINGIFY(VERSION_REV)
#define VERSION_LEGALCOPYRIGHT_SHORT L"Copyright © 2004-2011"
#define VERSION_LEGALCOPYRIGHT_LONG  L"© Florian Balmer 2004-2011"
#define VERSION_AUTHORNAME           L"Florian Balmer"
#define VERSION_WEBPAGEDISPLAY       L"flo's freeware - http://www.flos-freeware.ch"
#define VERSION_EMAILDISPLAY         L"florian.balmer@gmail.com"
#define VERSION_MODPAGEDISPLAY       L"http://code.google.com/p/notepad2-mod/"


// Setup specific
#if defined(_WIN64)
  #define SETUP_TITLE_STR            "Notepad2-mod x64 Setup"
  #define SETUP_VERSION_LABEL        STRINGIFY(VERSION_MAJOR)"."STRINGIFY(VERSION_MINOR)"."STRINGIFY(VERSION_BUILD)" x64 (modified; rev."STRINGIFY(VERSION_REV)")"
#else
  #define SETUP_TITLE_STR            "Notepad2-mod Setup"
  #define SETUP_VERSION_LABEL        STRINGIFY(VERSION_MAJOR)"."STRINGIFY(VERSION_MINOR)"."STRINGIFY(VERSION_BUILD)" (modified; rev."STRINGIFY(VERSION_REV)")"
#endif
#define SETUP_AUTHOR_STR             "XhmikosR"


#endif

