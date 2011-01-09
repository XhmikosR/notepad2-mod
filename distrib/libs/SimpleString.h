/**
 * SimpleString Library
 * Last modified: 2009/03/04
 * Copyright (C) Kai Liu.  All rights reserved.
 *
 * This is a custom C string library that provides wide-character inline
 * intrinsics for older compilers as well as some helpful chained functions.
 **/

#ifndef __SIMPLESTRING_H__
#define __SIMPLESTRING_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <windows.h>
#include "StringIntrinsics.h"

#pragma warning(push)
#pragma warning(disable: 4035) // returns for inline asm functions


/*******************************************************************************
 *
 *
 * Type definitions
 *
 *
 ******************************************************************************/


// I have no idea why MS uses DWORD64 instead of QWORD, esp. since QWORD is the
// name used by x86-64 instructions (just like BYTE, WORD, and DWORD in x86)
#ifndef __QWORD_DEFINED
#define __QWORD_DEFINED
typedef DWORD64 QWORD, *PQWORD;
#endif

// Unaligned pointer types
typedef  WORD UNALIGNED *UPWORD;
typedef DWORD UNALIGNED *UPDWORD;
typedef QWORD UNALIGNED *UPQWORD;

// Function decorations
#define SSINLINE __forceinline
#define SSCALL __stdcall


/*******************************************************************************
 *
 *
 * SSLen, SSCpy, SSCat
 *
 *
 ******************************************************************************/


#define SSLenA strlen
#define SSLenW wcslen

#define SSCpyA strcpy
#define SSCpyW wcscpy

#define SSCatA strcat
#define SSCatW wcscat

#ifdef UNICODE
#define SSLen SSLenW
#define SSCpy SSCpyW
#define SSCat SSCatW
#else
#define SSLen SSLenA
#define SSCpy SSCpyA
#define SSCat SSCatA
#endif


/*******************************************************************************
 *
 *
 * SSChainCpy
 *
 *
 ******************************************************************************/


PSTR SSCALL SSChainCpyA( PSTR pszDest, PCSTR pszSrc );
PWSTR SSCALL SSChainCpyW( PWSTR pszDest, PCWSTR pszSrc );

#ifdef UNICODE
#define SSChainCpy SSChainCpyW
#else
#define SSChainCpy SSChainCpyA
#endif


/*******************************************************************************
 *
 *
 * SSCpyNCh
 * This copy 2 or 4 static constant characters; do not use with variables.
 *
 *
 ******************************************************************************/


SSINLINE VOID SSInternal_Cpy16( PVOID pvDest,  WORD  wSource ) { *( (UPWORD)pvDest) =  wSource; }
SSINLINE VOID SSInternal_Cpy32( PVOID pvDest, DWORD dwSource ) { *((UPDWORD)pvDest) = dwSource; }
SSINLINE VOID SSInternal_Cpy64( PVOID pvDest, QWORD qwSource ) { *((UPQWORD)pvDest) = qwSource; }

#define CAST2BYTE(a)             (( BYTE)((DWORD_PTR)(a) & 0xFF))
#define CAST2WORD(a)             (( WORD)((DWORD_PTR)(a) & 0xFFFF))
#define CAST2DWORD(a)            ((DWORD)((DWORD_PTR)(a) & 0xFFFFFFFF))

#define BYTES2WORD(a, b)         (( WORD)(CAST2BYTE(a)  | (( WORD)CAST2BYTE(b))  <<  8))
#define WORDS2DWORD(a, b)        ((DWORD)(CAST2WORD(a)  | ((DWORD)CAST2WORD(b))  << 16))
#define DWORDS2QWORD(a, b)       ((QWORD)(CAST2DWORD(a) | ((QWORD)CAST2DWORD(b)) << 32))

#define BYTES2DWORD(a, b, c, d)  WORDS2DWORD(BYTES2WORD(a, b), BYTES2WORD(c, d))
#define WORDS2QWORD(a, b, c, d)  DWORDS2QWORD(WORDS2DWORD(a, b), WORDS2DWORD(c, d))

#define  CHARS2WORD              BYTES2WORD
#define  CHARS2DWORD             BYTES2DWORD
#define WCHARS2DWORD             WORDS2DWORD
#define WCHARS2QWORD             WORDS2QWORD

#define SSCpy2ChA(s, a, b)       SSInternal_Cpy16(s, CHARS2WORD(a, b))
#define SSCpy2ChW(s, a, b)       SSInternal_Cpy32(s, WCHARS2DWORD(a, b))
#define SSCpy4ChA(s, a, b, c, d) SSInternal_Cpy32(s, CHARS2DWORD(a, b, c, d))
#define SSCpy4ChW(s, a, b, c, d) SSInternal_Cpy64(s, WCHARS2QWORD(a, b, c, d))

#ifdef UNICODE
#define SSCpy2Ch SSCpy2ChW
#define SSCpy4Ch SSCpy4ChW
#else
#define SSCpy2Ch SSCpy2ChA
#define SSCpy4Ch SSCpy4ChA
#endif


/*******************************************************************************
 *
 *
 * SSChainNCpy
 * This is the same as using memcpy to copy strings, except that the return is
 * chained; like memcpy, cch should include the terminator, if appropriate.
 *
 *
 ******************************************************************************/


#ifdef __MOVS_STOS_DEFINED

SSINLINE PSTR SSChainNCpyA( PSTR pszDest, PCSTR pszSrc, SIZE_T cch )
{
	__movsb((unsigned char *)pszDest, (unsigned char const *)pszSrc, cch);
	return(pszDest + cch);
}

SSINLINE PWSTR SSChainNCpyW( PWSTR pszDest, PCWSTR pszSrc, SIZE_T cch )
{
	__movsw((unsigned short *)pszDest, (unsigned short const *)pszSrc, cch);
	return(pszDest + cch);
}

#else

SSINLINE PSTR SSChainNCpyA( PSTR pszDest, PCSTR pszSrc, SIZE_T cch )
{
	memcpy(pszDest, pszSrc, cch);
	return(pszDest + cch);
}

SSINLINE PWSTR SSChainNCpyW( PWSTR pszDest, PCWSTR pszSrc, SIZE_T cch )
{
	memcpy(pszDest, pszSrc, cch * sizeof(WCHAR));
	return(pszDest + cch);
}

#endif

#ifdef UNICODE
#define SSChainNCpy SSChainNCpyW
#else
#define SSChainNCpy SSChainNCpyA
#endif


/*******************************************************************************
 *
 *
 * SSChainNCpy2/3
 * This is the same as using memcpy to copy multiple strings, except that the
 * return and all intermediate copies are chained; if appropriate, the final
 * source string and cch should include a terminator.
 *
 *
 ******************************************************************************/


#if _MSC_VER >= 1200 && defined(_M_IX86)

SSINLINE PSTR SSChainNCpy2A( PSTR pszDest, PCSTR pszSrc1, SIZE_T cch1,
                                           PCSTR pszSrc2, SIZE_T cch2 )
{
	__asm
	{
		mov         edi,pszDest
		mov         esi,pszSrc1
		mov         ecx,cch1
		rep movsb
		mov         esi,pszSrc2
		mov         ecx,cch2
		rep movsb
		xchg        eax,edi
	}
}

SSINLINE PSTR SSChainNCpy3A( PSTR pszDest, PCSTR pszSrc1, SIZE_T cch1,
                                           PCSTR pszSrc2, SIZE_T cch2,
                                           PCSTR pszSrc3, SIZE_T cch3 )
{
	__asm
	{
		mov         edi,pszDest
		mov         esi,pszSrc1
		mov         ecx,cch1
		rep movsb
		mov         esi,pszSrc2
		mov         ecx,cch2
		rep movsb
		mov         esi,pszSrc3
		mov         ecx,cch3
		rep movsb
		xchg        eax,edi
	}
}

SSINLINE PWSTR SSChainNCpy2W( PWSTR pszDest, PCWSTR pszSrc1, SIZE_T cch1,
                                             PCWSTR pszSrc2, SIZE_T cch2 )
{
	__asm
	{
		mov         edi,pszDest
		mov         esi,pszSrc1
		mov         ecx,cch1
		rep movsw
		mov         esi,pszSrc2
		mov         ecx,cch2
		rep movsw
		xchg        eax,edi
	}
}

SSINLINE PWSTR SSChainNCpy3W( PWSTR pszDest, PCWSTR pszSrc1, SIZE_T cch1,
                                             PCWSTR pszSrc2, SIZE_T cch2,
                                             PCWSTR pszSrc3, SIZE_T cch3 )
{
	__asm
	{
		mov         edi,pszDest
		mov         esi,pszSrc1
		mov         ecx,cch1
		rep movsw
		mov         esi,pszSrc2
		mov         ecx,cch2
		rep movsw
		mov         esi,pszSrc3
		mov         ecx,cch3
		rep movsw
		xchg        eax,edi
	}
}

#else

SSINLINE PSTR SSChainNCpy2A( PSTR pszDest, PCSTR pszSrc1, SIZE_T cch1,
                                           PCSTR pszSrc2, SIZE_T cch2 )
{
	pszDest = SSChainNCpyA(pszDest, pszSrc1, cch1);
	return(SSChainNCpyA(pszDest, pszSrc2, cch2));
}

SSINLINE PSTR SSChainNCpy3A( PSTR pszDest, PCSTR pszSrc1, SIZE_T cch1,
                                           PCSTR pszSrc2, SIZE_T cch2,
                                           PCSTR pszSrc3, SIZE_T cch3 )
{
	pszDest = SSChainNCpyA(pszDest, pszSrc1, cch1);
	pszDest = SSChainNCpyA(pszDest, pszSrc2, cch2);
	return(SSChainNCpyA(pszDest, pszSrc3, cch3));
}

SSINLINE PWSTR SSChainNCpy2W( PWSTR pszDest, PCWSTR pszSrc1, SIZE_T cch1,
                                             PCWSTR pszSrc2, SIZE_T cch2 )
{
	pszDest = SSChainNCpyW(pszDest, pszSrc1, cch1);
	return(SSChainNCpyW(pszDest, pszSrc2, cch2));
}

SSINLINE PWSTR SSChainNCpy3W( PWSTR pszDest, PCWSTR pszSrc1, SIZE_T cch1,
                                             PCWSTR pszSrc2, SIZE_T cch2,
                                             PCWSTR pszSrc3, SIZE_T cch3 )
{
	pszDest = SSChainNCpyW(pszDest, pszSrc1, cch1);
	pszDest = SSChainNCpyW(pszDest, pszSrc2, cch2);
	return(SSChainNCpyW(pszDest, pszSrc3, cch3));
}

#endif

#ifdef UNICODE
#define SSChainNCpy2 SSChainNCpy2W
#define SSChainNCpy3 SSChainNCpy3W
#else
#define SSChainNCpy2 SSChainNCpy2A
#define SSChainNCpy3 SSChainNCpy3A
#endif


/*******************************************************************************
 *
 *
 * SSChainNCpy2F/3F
 * This is the non-inline variant of SSChainNCpy2/3.
 *
 *
 ******************************************************************************/


PSTR  SSCALL SSChainNCpy2FA( PSTR  pszDest, PCSTR  pszSrc1, SIZE_T cch1,
                                            PCSTR  pszSrc2, SIZE_T cch2 );
PSTR  SSCALL SSChainNCpy3FA( PSTR  pszDest, PCSTR  pszSrc1, SIZE_T cch1,
                                            PCSTR  pszSrc2, SIZE_T cch2,
                                            PCSTR  pszSrc3, SIZE_T cch3 );
PWSTR SSCALL SSChainNCpy2FW( PWSTR pszDest, PCWSTR pszSrc1, SIZE_T cch1,
                                            PCWSTR pszSrc2, SIZE_T cch2 );
PWSTR SSCALL SSChainNCpy3FW( PWSTR pszDest, PCWSTR pszSrc1, SIZE_T cch1,
                                            PCWSTR pszSrc2, SIZE_T cch2,
                                            PCWSTR pszSrc3, SIZE_T cch3 );

#ifdef UNICODE
#define SSChainNCpy2F SSChainNCpy2FW
#define SSChainNCpy3F SSChainNCpy3FW
#else
#define SSChainNCpy2F SSChainNCpy2FA
#define SSChainNCpy3F SSChainNCpy3FA
#endif


/*******************************************************************************
 *
 *
 * SSChainCpyCat
 *
 *
 ******************************************************************************/


PSTR SSCALL SSChainCpyCatA( PSTR pszDest, PCSTR pszSrc1, PCSTR pszSrc2 );
PWSTR SSCALL SSChainCpyCatW( PWSTR pszDest, PCWSTR pszSrc1, PCWSTR pszSrc2 );

#ifdef UNICODE
#define SSChainCpyCat SSChainCpyCatW
#else
#define SSChainCpyCat SSChainCpyCatA
#endif


/*******************************************************************************
 *
 *
 * SSStaticCpy
 * This should be used to copy static constant strings whose length is known by
 * the compiler; do not use with variables!
 *
 *
 ******************************************************************************/


#ifdef __MOVS_STOS_DEFINED
#define SSStaticCpyA(dest, src) SSChainNCpyA(dest, src, sizeof(src))
#define SSStaticCpyW(dest, src) SSChainNCpyW(dest, src, sizeof(src)/sizeof(WCHAR))
#else
#define SSStaticCpyA(dest, src) memcpy(dest, src, sizeof(src))
#define SSStaticCpyW(dest, src) memcpy(dest, src, sizeof(src))
#endif

#ifdef UNICODE
#define SSStaticCpy SSStaticCpyW
#else
#define SSStaticCpy SSStaticCpyA
#endif


#pragma warning(pop)

#ifdef __cplusplus
}
#endif

#endif
