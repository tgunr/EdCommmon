//---------------------------------------------------------------------------------------
//  functions.h created by erik
//  @(#)$Id: functions.h,v 1.1 2002-08-16 18:10:45 erik Exp $
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


#ifndef	__functions_h_INCLUDE
#define	__functions_h_INCLUDE

#import "osdep.h"

/*" Takes an IP address in the POSIX structure and returns an #NSString with the address in the typical dotted number representation. "*/
NSString *EDStringFromInAddr(struct in_addr address);
/*" Takes an #NSString with an IP address in the typical dotted number representation and returns the address in the POSIX structure. "*/
struct in_addr EDInAddrFromString(NSString *string);

#endif	/* __functions_h_INCLUDE */
