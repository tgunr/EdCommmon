//---------------------------------------------------------------------------------------
//  EDLWLock.h created by erik on Sun 21-May-2000
//  $Id: EDLightWeightLock.h,v 2.0 2002-08-16 18:12:45 erik Exp $
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

static __inline__ EDLightWeightLock *EDLWLCreate()
{
    EDLightWeightLock *mutex = malloc(sizeof(EDLightWeightLock));
    pthread_mutex_init(mutex, NULL);
    return mutex;
}

static __inline__ void EDLWLDispose(EDLightWeightLock *mutex)
{
    pthread_mutex_destroy(mutex);
    free(mutex);
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

static __inline__ EDLightWeightLock *EDLWLCreate()
{
    return objc_mutex_allocate();
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

/*" Datatype for a light-weight lock, different implementations are used on the supported platforms. In GNUStep builds we use the runtime lock wrapper, on Mac OS X and Solaris pthreads, and mach mutexes on the rest. %{<<What about Windows?!>>}"*/

typedef struct mutex EDLightWeightLock;


/*" Under certain circumstances even the low overhead of NSLocks is too much and direct access to the platform's locks is required. These four functions allocate, initialise and return a lock, dispose of it and allow to lock and unlock it. "*/

static __inline__ EDLightWeightLock *EDLWLCreate()
{
    EDLightWeightLock *mutex = malloc(sizeof(EDLightWeightLock));
    mutex_init(mutex);
    return mutex;
}

static __inline__ void EDLWLDispose(EDLightWeightLock *mutex)
{
    mutex_clear(mutex);
    free(mutex);
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
