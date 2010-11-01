#include <windows.h>
#include <advpub.h>
#include "libs\SimpleString.h"
#include "version.h"

__forceinline BOOL HardLinkOldNP( )
{
	CHAR szNPOld[MAX_PATH + 0x20];
	CHAR szNPNew[MAX_PATH + 0x20];
	UINT uSize;

	uSize = GetSystemWindowsDirectoryA(szNPOld, MAX_PATH);
	if (uSize < 4 || uSize >= MAX_PATH) return(FALSE);

	memcpy(szNPNew, szNPOld, sizeof(szNPOld));
	SSStaticCpyA(szNPOld + uSize, "\\notepad.exe");
	SSStaticCpyA(szNPNew + uSize, "\\notepad1.exe");

	return(CreateHardLinkA(szNPNew, szNPOld, NULL) || CopyFileA(szNPOld, szNPNew, TRUE));
}

BOOL DoSetup( PSTR pszPath, PSTR pszPathAppend )
{
	static const CHAR szSetup[] = "notepad2.inf\",DefaultInstall,,12,N";

	CHAR szCmdLine[MAX_PATH << 1];
	szCmdLine[0] = '"';

	SSChainNCpy2A(
		szCmdLine + 1,
		pszPath, pszPathAppend - pszPath,
		szSetup, sizeof(szSetup)
	);

	if (LaunchINFSectionEx(NULL, NULL, szCmdLine, 0) == S_OK)
	{
		if (LOBYTE(LOWORD(GetVersion())) < 6)
			HardLinkOldNP();

		return(TRUE);
	}

	return(FALSE);
}
