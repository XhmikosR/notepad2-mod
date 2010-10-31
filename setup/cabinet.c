#include <windows.h>
#include <fdi.h>
#include <shlobj.h>
#include "libs\SimpleString.h"
#include "resource.h"

// Use SHCreateDirectoryEx instead of CreateDirectoryTree
#define CreateDirectoryTreeA(path) SHCreateDirectoryExA(NULL, path, NULL)

typedef struct {
	PSTR pszOutputPath;
	PSTR pszOutputPathAppend;
	UINT uExtractedFiles;
} EXTRACTDATA, *PEXTRACTDATA;

typedef struct {
	PBYTE pbStart;
	DWORD cbFile;
	DWORD obPos;
} FILECTX, *PFILECTX;

/**
 * GetResource - Gets a memory pointer for a given resource
 **/
PVOID __fastcall GetResource( PCTSTR pszName, PCTSTR pszType, PDWORD pcbData )
{
	HRSRC hRsrc;
	HGLOBAL hGlobal;
	PVOID pvData;
	DWORD cbData;

	if ( (hRsrc = FindResource(NULL, pszName, pszType)) &&
	     (hGlobal = LoadResource(NULL, hRsrc)) &&
	     (pvData = LockResource(hGlobal)) &&
	     (cbData = SizeofResource(NULL, hRsrc)) )
	{
		if (pcbData) *pcbData = cbData;
		return(pvData);
	}
	else
	{
		if (pcbData) *pcbData = 0;
		return(NULL);
	}
}

/**
 * fdimalloc/fdifree
 **/
#ifdef _WIN64
FNALLOC(fdimalloc) { return(malloc(cb)); }
#else
#define fdimalloc ((PFNALLOC)malloc)
#endif
#define fdifree   ((PFNFREE)free)

/**
 * fdiopen
 * Called only for reading the cabinet, never for writing an extracted file
 **/
FNOPEN(fdiopen)
{
	PFILECTX pContext = fdimalloc(sizeof(FILECTX));

	pContext->pbStart = GetResource(
		MAKEINTRESOURCE(IDR_CABINET),
		RT_RCDATA,
		&pContext->cbFile
	);

	if (pContext->pbStart)
	{
		pContext->obPos = 0;
		return((INT_PTR)pContext);
	}
	else
	{
		fdifree(pContext);
		return(-1);
	}
}

/**
 * fdiread
 * Called only for reading the cabinet, never for writing an extracted file
 **/
FNREAD(fdiread)
{
	PFILECTX pContext = (PFILECTX)hf;

	if (hf != -1)
	{
		UINT cbRead = pContext->cbFile - pContext->obPos;

		if (pContext->obPos > pContext->cbFile)
			cbRead = 0;
		else if (cbRead > cb)
			cbRead = cb;

		memcpy(pv, pContext->pbStart + pContext->obPos, cbRead);
		pContext->obPos += cbRead;

		return(cbRead);
	}

	return(-1);
}

/**
 * fdiwrite
 * Called only for writing an extracted file, never for reading the cabinet
 **/
FNWRITE(fdiwrite)
{
	DWORD cbWritten;
	WriteFile((HANDLE)hf, pv, cb, &cbWritten, NULL);
	return(cbWritten);
}

/**
 * fdiclose
 * Called only for reading the cabinet, never for writing an extracted file
 **/
FNCLOSE(fdiclose)
{
	if (hf != -1)
	{
		fdifree((PVOID)hf);
		return(0);
	}

	return(-1);
}

/**
 * fdiseek
 * Called only for reading the cabinet, never for writing an extracted file
 **/
FNSEEK(fdiseek)
{
	PFILECTX pContext = (PFILECTX)hf;

	if (hf != -1)
	{
		LONG obNewPos = pContext->obPos;

		switch (seektype)
		{
			case FILE_BEGIN:
				obNewPos = dist;
				break;

			case FILE_CURRENT:
				obNewPos += dist;
				break;

			case FILE_END:
				obNewPos = pContext->cbFile + dist;
				break;
		}

		if (obNewPos >= 0)
		{
			pContext->obPos = obNewPos;
			return(obNewPos);
		}
	}

	return(-1);
}

/**
 * fdiNotify
 **/
FNFDINOTIFY(fdiNotify)
{
	PEXTRACTDATA pExtractData = pfdin->pv;

	switch (fdint)
	{
		/* We don't care about the following three cases, so they will just
		 * hit the default return(0) at the end of the function.
		case fdintCABINET_INFO:
		case fdintPARTIAL_FILE:
		case fdintENUMERATE:
		case fdintNEXT_CABINET:
		 */

		case fdintCOPY_FILE:
		{
			HANDLE hFile;
			PSTR pszTail;

			SSCpyA(pExtractData->pszOutputPathAppend, pfdin->psz1);

			if (pszTail = strrchr(pExtractData->pszOutputPath, '\\'))
			{
				*pszTail = 0;
				CreateDirectoryTreeA(pExtractData->pszOutputPath);
				*pszTail = '\\';
			}

			hFile = CreateFileA(
				pExtractData->pszOutputPath,
				GENERIC_WRITE,
				0,
				NULL,
				CREATE_ALWAYS,
				FILE_ATTRIBUTE_ARCHIVE | FILE_FLAG_SEQUENTIAL_SCAN,
				NULL
			);

			return((hFile != INVALID_HANDLE_VALUE) ? (INT_PTR)hFile : 0);
		}

		case fdintCLOSE_FILE_INFO:
		{
			FILETIME ftModified;

			// Set the file time and close the handle
			DosDateTimeToFileTime(pfdin->date, pfdin->time, &ftModified);
			SetFileTime((HANDLE)pfdin->hf, NULL, NULL, &ftModified);
			CloseHandle((HANDLE)pfdin->hf);

			// Bookkeeping...
			++pExtractData->uExtractedFiles;

			return(TRUE);
		}
	}

	return(0);
}

/**
 * ExtractCabResource
 **/
UINT __fastcall ExtractCabResource( PSTR pszOutputPath, PSTR pszOutputPathAppend )
{
	ERF erf;

	EXTRACTDATA ed = {
		pszOutputPath,        // PSTR pszOutputPath
		pszOutputPathAppend,  // PSTR pszOutputPathAppend
		0                     // UINT uExtractedFiles
	};

	HFDI hfdi = FDICreate(
		fdimalloc,
		fdifree,
		fdiopen,
		fdiread,
		fdiwrite,
		fdiclose,
		fdiseek,
		cpuUNKNOWN,
		&erf
	);

	if (hfdi)
	{
		FDICopy(hfdi, "0", pszOutputPath, 0, fdiNotify, NULL, &ed);
		FDIDestroy(hfdi);
	}

	return(ed.uExtractedFiles);
}
