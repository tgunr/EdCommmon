//---------------------------------------------------------------------------------------
//  EDIRCObject.h created by erik
//  @(#)$Id: EDIRCObject.h,v 1.2 2002-04-14 14:57:55 znek Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDIRCObject_h_INCLUDE
#define	__EDIRCObject_h_INCLUDE


/*" Use this class as superclass when you want to manage the retain count for your instances internally; hence IRC = %{internally retain counted} and not what you might have thought. "*/

#import <Foundation/NSObject.h>

@interface EDIRCObject : NSObject
{
    unsigned int retainCount;
}

@end

#endif	/* __EDIRCObject_h_INCLUDE */
