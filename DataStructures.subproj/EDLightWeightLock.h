//---------------------------------------------------------------------------------------
//  EDLWLock.h created by erik on Sun 21-May-2000
//  $Id: EDLightWeightLock.h,v 1.2 2002-04-14 14:57:55 znek Exp $
//
//  Copyright (c) 2000 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDLightWeightLock_h_INCLUDE
#define	__EDLightWeightLock_h_INCLUDE


// On Mac OS X and PDO Solaris we use pthreads.

#if ((defined(__APPLE__) && !defined(ppc)) || (defined(__SVR4) && defined(sun)))

#import <pthread.h>

typedef pthread_mutex_t EDLightWeightLock;

static __inline__ void EDLWLInit(EDLightWeightLock *mutex)
{
    pthread_mutex_init(mutex, NULL);
}

static __inline__ void EDLWLDispose(EDLightWeightLock *mutex)
{
    pthread_mutex_destroy(mutex);
}

static __inline__ void EDLWLLock(EDLightWeightLock *mutex)
{
    pthread_mutex_lock(mutex);
}

static __inline__ void EDLWLUnlock(EDLightWeightLock *mutex)
{
    pthread_mutex_unlock(mutex);
}


#elif defined(GNU_RUNTIME)


typedef struct objc_mutex EDLightWeightLock;

static __inline__ void EDLWLInit(EDLightWeightLock *mutex)
{
    mutex = objc_mutex_allocate();
}

static __inline__ void EDLWLDispose(EDLightWeightLock *mutex)
{
    objc_mutex_deallocate(mutex);
}

static __inline__ void EDLWLLock(EDLightWeightLock *mutex)
{
    objc_mutex_lock(mutex);
}

static __inline__ void EDLWLUnlock(EDLightWeightLock *mutex)
{
    objc_mutex_unlock(mutex);
}


#else


#import <mach/cthreads.h>

typedef struct mutex EDLightWeightLock;

static __inline__ void EDLWLInit(EDLightWeightLock *mutex)
{
    mutex_init(mutex);
}

static __inline__ void EDLWLDispose(EDLightWeightLock *mutex)
{
    mutex_clear(mutex);
}

static __inline__ void EDLWLLock(EDLightWeightLock *mutex)
{
    mutex_lock(mutex);
}

static __inline__ void EDLWLUnlock(EDLightWeightLock *mutex)
{
    mutex_unlock(mutex);
}


#endif

#endif	/* __EDLightWeightLock_h_INCLUDE */
