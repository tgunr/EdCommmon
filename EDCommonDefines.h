//---------------------------------------------------------------------------------------
//  EDCommonDefines.h created by erik on Fri 28-Mar-1997
//  @(#)$Id: EDCommonDefines.h,v 1.4 2001-11-03 18:01:35 znek Exp $
//
//  Copyright (c) 1997-2000 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#ifndef _EDCOMMON_DEFINES
#define _EDCOMMON_DEFINES 1

// Defines to handle extern declarations on different platforms

#if defined(__MACH__)

#ifdef __cplusplus
   // This isnt extern "C" because the compiler will not allow this if it has
   // seen an extern "Objective-C"
#  define EDCOMMON_EXTERN		extern
#else
#  define EDCOMMON_EXTERN		extern
#endif


#elif defined(WIN32)

#ifdef _BUILDING_EDCOMMON_DLL
#  define EDCOMMON_DLL_GOOP		__declspec(dllexport)
#else
#  define EDCOMMON_DLL_GOOP		__declspec(dllimport)
#endif

#ifdef __cplusplus
#  define EDCOMMON_EXTERN		extern "C" EDCOMMON_DLL_GOOP
#else
#  define EDCOMMON_EXTERN		EDCOMMON_DLL_GOOP extern
#endif


#elif defined(__svr4__) || defined(sun) || defined(hpux)

#ifdef __cplusplus
#  define EDCOMMON_EXTERN		extern "C"
#else
#  define EDCOMMON_EXTERN		extern
#endif


#endif


// Neither YES nor NO...

#define UNKNOWN 2


//	A shortcut to get the default notification center

#define DNC [NSNotificationCenter defaultCenter]

// 	A shortcut to get the standard user defaults

#define DEFAULTS [NSUserDefaults standardUserDefaults]

//	A shortcut to instantiate a CalendarDate object containing the current time
//	and date

#define NOW [NSCalendarDate calendarDate]


// 	A really useful data type

typedef unsigned char byte;


// 	A macro to do asserted casts

static __inline__ id EDCast(id object, Class aClass, SEL cmd, id self, const char *file, int line)
{
    if((object != nil) && ([object isKindOfClass:aClass] == NO))
        [[NSAssertionHandler currentHandler] handleFailureInMethod:cmd object:self file:[NSString stringWithCString:file] lineNumber:line description:@"cast failure; cannot cast instance of %@ to %@", NSStringFromClass([object class]), NSStringFromClass(aClass)];
    return object;
}

#define CAST(ID, CLASSNAME) \
    ((CLASSNAME *)EDCast(ID, [CLASSNAME class], _cmd, self, __FILE__, __LINE__))


//	A global variable that determines the output generated by the log macros.

EDCOMMON_EXTERN unsigned int EDLogMask;

//	Macros to conditionally print messages. This looks scary and is in fact a
//	bad C hack. It is done because this is the only way to prevent the arguments
//	from even being created if no output would be made anyway. If this would
// 	be implemented as a function and called like, say,
//		EDLog1(4, @"array = %@", [array description])
//  then a poentially large description of the array would be created just
//	to be discarded if the log mask does not include the area in question.
//	On the downside, variable argument lists don't work and hence the number of
//	parameters must be given with the macro name.

EDCOMMON_EXTERN void (*_EDLogFunction)(NSString *);

#define EDLogBody(area, format, arg1, arg2, arg3, arg4)	\
    do { \
        if(EDLogMask & area) \
            (*_EDLogFunction)([NSString stringWithFormat:format, arg1, arg2, arg3, arg4]); \
    } while(0)

#define EDLog(l, f)								EDLogBody((l), (f), 0, 0, 0, 0)
#define EDLog1(l, f, arg1)						EDLogBody((l), (f), arg1, 0, 0, 0)
#define EDLog2(l, f, arg1, arg2)				EDLogBody((l), (f), arg1, arg2, 0, 0)
#define EDLog3(l, f, arg1, arg2, arg3)			EDLogBody((l), (f), arg1, arg2, arg3, 0)
#define EDLog4(l, f, arg1, arg2, arg3, arg4)	EDLogBody((l), (f), arg1, arg2, arg3, arg4)

#endif
