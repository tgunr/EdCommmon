//---------------------------------------------------------------------------------------
//  osdep.h created by erik on Wed 28-Jan-1998
//  @(#)$Id: osdep.h,v 2.1 2002-08-28 20:41:32 erik Exp $
//
//  Copyright (c) 1998-1999 by Erik Doernenburg. All rights reserved.
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


#ifndef	__osdep_h_INCLUDE
#define	__osdep_h_INCLUDE


// This file contains stuff that isn't necessarily portable between operating systems.

#if defined(sun)

//---------------------------------------------------------------------------------------
// Solaris
//---------------------------------------------------------------------------------------

#import <iso/limits_iso.h> // UINT_MAX in Solaris 2.8
//#import <sys/types.h> // UINT_MAX in Solaris < 2.8
#import <sys/errno.h>
#import <unistd.h>
#import <alloca.h>
#import <stdlib.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <arpa/inet.h>
#import <arpa/nameser.h>
#import <netdb.h>
#import <resolv.h>

#import <dirent.h>
#import <sys/stat.h>

#import <string.h>
#import <ctype.h>
#import <values.h>  // for MAXINT, MAXDOUBLE, etc

#import <sys/uio.h>
#import <sys/file.h>
#import <fcntl.h>

#import <objc/Protocol.h>

#ifdef __cplusplus
extern "C" {
#endif
extern int res_init(void);
extern int gethostname(char *name, int namelen);
#ifdef __cplusplus
}
#endif

#import <math.h>

// These are defined in a really funky place in Solaris.
#ifndef MIN
#define MIN(a, b) ((a) < (b) ? (a) : (b))
#endif

#ifndef MAX
#define MAX(a, b) ((a) > (b) ? (a) : (b))
#endif

// The Solaris man page for errno says that it is thread safe.  Dunno how that could be.  Either they are refering to perror() and the other functions in the same page, or the -mt thread in the Solaris compiler can do something magic.

#import <errno.h>
#define ED_ERRNO errno
#import <sys/xti_inet.h>

#elif WINNT

//---------------------------------------------------------------------------------------
// Windows (Yellow Box)
//---------------------------------------------------------------------------------------

#import <winnt-pdo.h>
#import <winsock.h>
#import <fcntl.h>
#import <malloc.h>

// WinSock has these defined, but puts an #if 0 around them.
#define ETIMEDOUT    WSAETIMEDOUT
#define ECONNREFUSED WSAECONNREFUSED
#define ENETDOWN     WSAENETDOWN
#define ENETUNREACH  WSAENETUNREACH
#define EHOSTDOWN    WSAEHOSTDOWN
#define EHOSTUNREACH WSAEHOSTUNREACH

// Don't find these anywhere in NT.
#define MAXHOSTNAMELEN (256)
#define IN_CLASSD(i) (((long)(i) & 0xf0000000) == 0xe0000000)
#define IN_MULTICAST(i) IN_CLASSD(i)

// Misc

#define random() rand()
#define srandom(seed) srand(seed)

#undef alloca

// On NT, errno is defined to be '(*_errno())' and presumably this function is thread safe.

#import <errno.h>
#define ED_ERRNO errno

#elif defined(__APPLE__)

//---------------------------------------------------------------------------------------
// MacOS X
//---------------------------------------------------------------------------------------

#ifdef EDCOMMON_OSXBUILD

#define ED_ERRNO errno

#import <stddef.h>
#import <netinet/in.h>
#warning ** excluded header for Jaguar, must test Puma
//#import <netinet/ip_compat.h>
#import <sys/socket.h>
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/dir.h>
#import <sys/errno.h>
#import <sys/stat.h>
#import <sys/uio.h>
#import <sys/file.h>
#import <sys/fcntl.h>
#import <nameser.h>
#import <resolv.h>

#else

#import <bsd/libc.h>
#import <bsd/stddef.h>
#import <bsd/arpa/nameser.h>
#import <bsd/resolv.h>
#import <bsd/netdb.h>
#import <bsd/netinet/tcp.h>
#import <bsd/sys/types.h>
#import <bsd/sys/dir.h>
#import <bsd/sys/errno.h>
#import <bsd/sys/stat.h>
#import <bsd/sys/uio.h>
#import <bsd/sys/file.h>
#import <bsd/fcntl.h>
#import <bsd/c.h> // For MIN()
#import <mach/cthreads.h>
#define ED_ERRNO cthread_errno()

#endif


#elif defined(__FreeBSD__)

//---------------------------------------------------------------------------------------
// FreeBSD
//---------------------------------------------------------------------------------------

#define ED_ERRNO errno

#import <stddef.h>
#import <netinet/in.h>
#import <netinet/ip_compat.h>
#import <netinet/tcp.h>
#import <sys/socket.h>
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/dirent.h>
#import <sys/errno.h>
#import <sys/stat.h>
#import <sys/uio.h>
#import <sys/file.h>
#import <sys/fcntl.h>
#import <resolv.h>


#elif defined(linux)

//---------------------------------------------------------------------------------------
// Linux
//---------------------------------------------------------------------------------------

#define ED_ERRNO errno

#import <stddef.h>
#import <netinet/in.h>
#import <netinet/tcp.h>
#import <sys/socket.h>
#import <sys/ioctl.h>
#import <sys/types.h>
#import <sys/errno.h>
#import <sys/stat.h>
#import <sys/uio.h>
#import <sys/file.h>
#import <sys/fcntl.h>
#import <resolv.h>

#else

//---------------------------------------------------------------------------------------
// Unknown system
//---------------------------------------------------------------------------------------

#error Unknown system!

#endif

#endif	/* __osdep_h_INCLUDE */

