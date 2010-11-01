#ifndef __GETARGV_H__
#define __GETARGV_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <windows.h>

/**
 * GetArgv returns a TCHAR string equivalent main's argv
 **/

PSTR * __fastcall GetArgvA( INT *pcArgs );

#define GetArgvW(pcArgs) CommandLineToArgvW(GetCommandLineW(), pcArgs)

#ifdef UNICODE
#define GetArgv GetArgvW
#else
#define GetArgv GetArgvA
#endif

#ifdef __cplusplus
}
#endif

#endif
