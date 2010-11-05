#pragma once

#include "Version_rev.h"

#define DO_STRINGIFY(x) #x
#define STRINGIFY(x) DO_STRINGIFY(x)

#define VERSION_MAJOR 4
#define VERSION_MINOR 1
#define VERSION_BUILD 24

// Setup specific
#define SETUP_VERSION_LABEL  STRINGIFY(VERSION_MAJOR)"."STRINGIFY(VERSION_MINOR)"."STRINGIFY(VERSION_BUILD)" (modified; rev."STRINGIFY(VERSION_REV)")"
#if defined(_WIN64)
  #define SETUP_TITLE_STR      "Notepad2 x64 Setup"
#else
  #define SETUP_TITLE_STR      "Notepad2 Setup"
#endif
#define SETUP_AUTHOR_STR     "XhmikosR"

#undef REBOOT_MESSAGE
