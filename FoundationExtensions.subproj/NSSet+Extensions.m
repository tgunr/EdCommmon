//---------------------------------------------------------------------------------------
//  NSSet+Extensions.m created by erik on Sat 10-Mar-2001
//  $Id: NSSet+Extensions.m,v 1.2 2002-07-02 15:05:33 erik Exp $
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

#import <Foundation/Foundation.h>
#import "NSSet+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSSet(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSSet. "*/

/*" Adds all objects from %otherSet to the receiver. "*/

- (NSSet *)setByAddingObjectsFromSet:(NSSet *)otherSet
{
    NSMutableSet	*temp;

    temp = [[[NSMutableSet allocWithZone:[self zone]] initWithSet:self] autorelease];
    [temp unionSet:otherSet];

    return temp;
}


/*" Adds all objects from %anArray to the receiver. "*/

- (NSSet *)setByAddingObjectsFromArray:(NSArray *)anArray
{
    NSMutableSet	*temp;

    temp = [[[NSMutableSet allocWithZone:[self zone]] initWithSet:self] autorelease];
    [temp addObjectsFromArray:anArray];

    return temp;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
