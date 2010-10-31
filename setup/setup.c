#include <windows.h>
#include <commctrl.h>
#include <advpub.h>
#include <stdio.h>
#include "libs\GetArgv.h"
#include "libs\SimpleString.h"
#include "resource.h"
#include "version.h"

#ifndef SETUP_LITE
#define MessageBoxWarn(a)  MessageBox(NULL, a, TEXT(SETUP_TITLE_STR), MB_OK | MB_ICONWARNING)
#define MessageBoxInfo(a)  MessageBox(NULL, a, TEXT(SETUP_TITLE_STR), MB_OK | MB_ICONINFORMATION)
#define MessageBoxError(a) MessageBox(NULL, a, TEXT(SETUP_TITLE_STR), MB_OK | MB_ICONERROR)
#else
#define MessageBoxWarn(a)
#define MessageBoxInfo(a)
#define MessageBoxError(a)
#endif

#ifndef SEE_MASK_NOASYNC
#define SEE_MASK_NOASYNC 0x00000100
#endif

#ifndef SEE_MASK_NOZONECHECKS
#define SEE_MASK_NOZONECHECKS 0x00800000
#endif

#ifndef BCM_SETSHIELD
#define BCM_SETSHIELD 0x160C
#endif

// External dependencies
PVOID __fastcall GetResource( PCTSTR pszName, PCTSTR pszType, PDWORD pcbData );
UINT __fastcall ExtractCabResource( PSTR pszOutputPath, PSTR pszOutputPathAppend );
BOOL DoSetup( PSTR pszPath, PSTR pszPathAppend );

// Internal helpers
__forceinline DWORD SetupMain( HINSTANCE hInstance );
__forceinline BOOL SetupRun( HINSTANCE hInstance, BOOL fInstall, BOOL fNotify );
__forceinline SIZE_T GetTempNameA( PSTR pszTempName, SIZE_T cchTempName );

#ifndef SETUP_LITE
__forceinline BOOL ShowLicense( HINSTANCE hInstance );
INT_PTR CALLBACK LicenseDlgProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam );
#endif

#pragma comment(linker, "/entry:SetupEntry")
void SetupEntry( )
{
	ExitProcess(SetupMain(GetModuleHandleA(NULL)));
}

/**
 * SetupMain - Process command line arguments, display help, display license
 **/
__forceinline DWORD SetupMain( HINSTANCE hInstance )
{
	int argc = 0;
	PTSTR *argv = GetArgv(&argc);

	BOOL fInstall = TRUE;
	#ifndef SETUP_LITE
	BOOL fNotify = TRUE;
	BOOL fHelp = FALSE;
	BOOL fIsRelaunch = FALSE;
	BOOL fUseUAC = LOBYTE(LOWORD(GetVersion())) >= 6;
	#else
	BOOL fNotify = FALSE;
	#endif

	if (argc && argv)
	{
		while (--argc)
		{
			if (lstrcmpi(argv[argc], TEXT("/extract")) == 0)
				fInstall = FALSE;
			#ifndef SETUP_LITE
			else if (lstrcmpi(argv[argc], TEXT("/quiet")) == 0)
				fNotify = FALSE;
			else if (lstrcmpi(argv[argc], TEXT("/uac")) == 0)
				fIsRelaunch = TRUE;
			else if (argv[argc][0] == TEXT('/'))
				fHelp = TRUE;
			#endif
		}

		LocalFree(argv);
	}

	#ifndef SETUP_LITE
	InitCommonControls();

	if (fHelp)
	{
		MessageBoxInfo(TEXT("Command-line options:\n/quiet\tSuppress all messages and dialogs\n/extract\tExtract files without installing"));
		return(0);
	}
	else if (fNotify && fInstall && !(fUseUAC && fIsRelaunch) && !ShowLicense(hInstance))
	{
		// Exit if the user says "No"
		return(0);
	}

	if (fInstall && fUseUAC && !fIsRelaunch)
	{
		SHELLEXECUTEINFO sei;

		TCHAR szModule[MAX_PATH << 1];
		TCHAR szParams[16];

		GetModuleFileName(hInstance, szModule, MAX_PATH << 1);
		SSStaticCpy(szParams, TEXT("/uac"));

		if (!fNotify)
		{
			// Make sure that the relaunched process inherits the quiet setting
			szParams[4] = TEXT(' ');
			SSStaticCpy(szParams + 5, TEXT("/quiet"));
		}

		ZeroMemory(&sei, sizeof(sei));
		sei.cbSize = sizeof(SHELLEXECUTEINFO);
		sei.fMask = SEE_MASK_NOASYNC | SEE_MASK_UNICODE | SEE_MASK_NOZONECHECKS;
		sei.lpVerb = TEXT("runas");
		sei.lpFile = szModule;
		sei.lpParameters = szParams;
		sei.nShow = SW_SHOWNORMAL;

		ShellExecuteEx(&sei);
		return(0);
	}
	#endif

	return((SetupRun(hInstance, fInstall, fNotify)) ? 0 : 1);
}

/**
 * SetupRun - Create temp dir, extract cabinet, install, clean-up
 **/
__forceinline BOOL SetupRun( HINSTANCE hInstance, BOOL fInstall, BOOL fNotify )
{
	BOOL fSuccess = FALSE;
	CHAR szPath[MAX_PATH << 1];
	PSTR pszPathAppend = szPath;

	if (fInstall)
	{
		// Installation: Extract to temp directory, call DoSetup, and clean up
		// if necessary

		SIZE_T cchPathRoot = GetTempNameA(szPath, MAX_PATH);
		pszPathAppend += cchPathRoot;

		SSCpy2ChA(pszPathAppend, '\\', 0);
		++pszPathAppend;

		if (cchPathRoot && ExtractCabResource(szPath, pszPathAppend))
		{
			#ifdef REBOOT_MESSAGE
			DWORD dwRebootCookie = NeedRebootInit();
			#endif

			if (DoSetup(szPath, pszPathAppend))
			{
				if (fNotify)
				{
					MessageBoxInfo(TEXT("Installation complete!"));

					#ifdef REBOOT_MESSAGE
					if (NeedReboot(dwRebootCookie))
						MessageBoxInfo(REBOOT_MESSAGE);
					#endif
				}

				fSuccess = TRUE;
			}
			else if (fNotify)
			{
				MessageBoxWarn(TEXT("Installation error encountered"));
			}
		}
		else if (fNotify)
		{
			MessageBoxError(TEXT("Unexpected file error"));
		}

		if (cchPathRoot)
		{
			SHFILEOPSTRUCTA fileop;
			ZeroMemory(&fileop, sizeof(fileop));
			fileop.wFunc = FO_DELETE;
			fileop.pFrom = szPath;
			fileop.fFlags = FOF_SILENT | FOF_NOCONFIRMATION | FOF_NOERRORUI;

			// We want a double-null termination so that SHFileOperation is happy.
			SSCpy2ChA(--pszPathAppend, 0, 0);

			SHFileOperationA(&fileop);
		}
	}
	else
	{
		// Extraction: Just extract to the current location; no need for temp

		UINT uExtracted;

		DWORD cchPathRoot = GetCurrentDirectoryA(MAX_PATH, szPath);

		if (cchPathRoot >= MAX_PATH)
			cchPathRoot = 0;

		if (cchPathRoot)
		{
			pszPathAppend += cchPathRoot;

			if (*(pszPathAppend - 1) != '\\')
			{
				SSCpy2ChA(pszPathAppend, '\\', 0);
				++pszPathAppend;
			}
		}

		if (cchPathRoot && (uExtracted = ExtractCabResource(szPath, pszPathAppend)))
		{
			#ifndef SETUP_LITE
			if (fNotify)
			{
				TCHAR szMessage[0x30];
				wsprintf(szMessage, TEXT("%u file(s) successfully extracted"), uExtracted);
				MessageBoxInfo(szMessage);
			}
			#endif

			fSuccess = TRUE;
		}
		else if (fNotify)
		{
			MessageBoxError(TEXT("Unexpected file error"));
		}
	}

	return(fSuccess);
}

/**
 * GetTempNameA - Gets an unused temporary name; does not create file/dir
 **/
__forceinline SIZE_T GetTempNameA( PSTR pszTempName, SIZE_T cchTempName )
{
	PSTR pszBuffer = _tempnam(NULL, "setup");
	SIZE_T cchBuffer;

	if (pszBuffer && (cchBuffer = SSLenA(pszBuffer)) < cchTempName)
	{
		// The null terminator is omitted because we will be appending to
		// this string before using it anyway.
		SSChainNCpyA(pszTempName, pszBuffer, cchBuffer);
		free(pszBuffer);
		return(cchBuffer);
	}

	if (pszBuffer)
		free(pszBuffer);

	return(0);
}

#ifndef SETUP_LITE

/**
 * ShowLicense - Open license dialog
 **/
__forceinline BOOL ShowLicense( HINSTANCE hInstance )
{
	return(IDYES == DialogBoxParam(
		hInstance,
		MAKEINTRESOURCE(IDD_LICENSE),
		NULL,
		LicenseDlgProc,
		(LPARAM)hInstance
	));
}

/**
 * LicenseDlgProc - License dialog UI
 **/
INT_PTR CALLBACK LicenseDlgProc( HWND hWnd, UINT uMsg, WPARAM wParam, LPARAM lParam )
{
	switch (uMsg)
	{
		case WM_INITDIALOG:
		{
			PSTR pszLicense = GetResource(MAKEINTRESOURCE(IDR_LICENSE), RT_RCDATA, NULL);

			if (pszLicense)
			{
				// Set the window icon
				SendMessage(
					hWnd,
					WM_SETICON,
					ICON_BIG, // No need to explicitly set the small icon
					(LPARAM)LoadIcon((HINSTANCE)lParam, MAKEINTRESOURCE(IDI_SETUP))
				);

				// Set the shield icon
				SendDlgItemMessageA(hWnd, IDYES, BCM_SETSHIELD, 0, TRUE);

				// Set license text
				SendDlgItemMessageA(hWnd, IDC_LICENSE_BOX, WM_SETTEXT, 0, (LPARAM)pszLicense);
			}
			else
			{
				EndDialog(hWnd, IDYES);
			}

			return(TRUE);
		}

		case WM_CLOSE:
		{
			EndDialog(hWnd, IDNO);
			return(TRUE);
		}

		case WM_COMMAND:
		{
			switch (LOWORD(wParam))
			{
				case IDYES:
				case IDNO:
				{
					EndDialog(hWnd, LOWORD(wParam));
					return(TRUE);
				}
			}
		}
	}

	return(FALSE);
}

#endif
