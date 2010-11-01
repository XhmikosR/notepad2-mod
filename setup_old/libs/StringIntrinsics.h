/**
 * String Intrinsics Library
 * Last modified: 2009/03/04
 * Copyright (C) Kai Liu.  All rights reserved.
 *
 * This library will direct that certain mem*, str*, and wcs* functions use
 * intrinsic forms even if /Oi is not specified during compilation.
 *
 * This library will also force the use of intrinsics in cases where the
 * compiler does not support them (wcs* on v12/13 compilers) or where the
 * compiler does not honor intrinsic settings (mem* on v14+).
 *
 * Finally, this library will provide definitions for the movs* and stos*
 * functions for cases where the CRT's intrin.h cannot be used.
 **/

#ifndef __STRINGINTRINSICS_H__
#define __STRINGINTRINSICS_H__

#ifdef __cplusplus
extern "C" {
#endif

#include <string.h>

#if _MSC_VER >= 1200

#if _MSC_VER >= 1400
#pragma warning(disable: 4996) // do not mother me about so-called "insecure" funcs
#endif

#if _MSC_VER >= 1500 && _MSC_VER < 1600
#pragma warning(disable: 4985) // appears to be a bug in VC9
#endif

#pragma warning(push)
#pragma warning(disable: 4035) // returns for inline asm functions


/*******************************************************************************
 *
 *
 * movs, stos
 *
 *
 ******************************************************************************/


#if _MSC_VER >= 1400 && (defined(_M_IX86) || defined(_M_AMD64) || defined(_M_X64))
#define __MOVS_STOS_DEFINED
#ifndef __INTRIN_H_
void __movsb( unsigned  char *, unsigned  char const *, size_t );
void __movsw( unsigned short *, unsigned short const *, size_t );
void __movsd( unsigned  long *, unsigned  long const *, size_t );
void __stosb( unsigned  char *, unsigned  char, size_t );
void __stosw( unsigned short *, unsigned short, size_t );
void __stosd( unsigned  long *, unsigned  long, size_t );
#endif
#pragma intrinsic(__movsb, __movsw, __movsd, __stosb, __stosw, __stosd)
#endif


/*******************************************************************************
 *
 *
 * memcmp, memcpy, memset
 *
 *
 ******************************************************************************/


#pragma intrinsic(memcmp, memcpy, memset)

// Compiler versions 14 and higher will often refuse to honor the mem*
// intrinsics, so it may be necessary to override them with movs and stos
#if defined(__MOVS_STOS_DEFINED) && !defined(SI_NO_OVERRIDE_MEM_FUNCS)

__forceinline void * intrin_memcpy( void *dest, const void *src, size_t count )
{
	__movsb((unsigned char *)dest, (unsigned char const *)src, count);
	return(dest);
}

__forceinline void * intrin_memset( void *dest, int c, size_t count )
{
	__stosb((unsigned char *)dest, (unsigned char)c, count);
	return(dest);
}

#define memcpy intrin_memcpy
#define memset intrin_memset
#endif


/*******************************************************************************
 *
 *
 * strlen, wcslen
 *
 *
 ******************************************************************************/


#pragma intrinsic(strlen)
#if _MSC_VER >= 1400
#pragma intrinsic(wcslen)
#elif defined(_M_IX86)

__forceinline size_t intrin_strlen_w( const wchar_t *string )
{
	__asm
	{
		xor         eax,eax
		mov         edi,string
		or          ecx,-1
		repnz scasw
		not         ecx
		dec         ecx
		xchg        eax,ecx
	}
}

#define wcslen intrin_strlen_w
#endif


/*******************************************************************************
 *
 *
 * strcpy, wcscpy
 *
 *
 ******************************************************************************/


#pragma intrinsic(strcpy)
#if _MSC_VER >= 1400
#pragma intrinsic(wcscpy)
#elif defined(_M_IX86)

__forceinline wchar_t * intrin_strcpy_w( wchar_t *dest, const wchar_t *src )
{
	__asm
	{
		xor         eax,eax
		mov         esi,src
		mov         edi,esi
		or          ecx,-1
		repnz scasw
		not         ecx
		mov         edi,dest
		rep movsw
	}

	return(dest);
}

#define wcscpy intrin_strcpy_w
#endif


/*******************************************************************************
 *
 *
 * strcat, wcscat
 *
 *
 ******************************************************************************/


#pragma intrinsic(strcat)
#if _MSC_VER >= 1400
#pragma intrinsic(wcscat)
#elif defined(_M_IX86)

__forceinline wchar_t * intrin_strcat_w( wchar_t *dest, const wchar_t *src )
{
	__asm
	{
		xor         eax,eax
		mov         esi,src
		mov         edi,esi
		or          ecx,-1
		repnz scasw
		not         ecx
		mov         edi,dest
		push        ecx
		or          ecx,-1
		repnz scasw
		pop         ecx
		dec         edi
		dec         edi
		rep movsw
	}

	return(dest);
}

#define wcscat intrin_strcat_w
#endif


#pragma warning(pop)

#endif // _MSC_VER >= 1200

#ifdef __cplusplus
}
#endif

#endif
