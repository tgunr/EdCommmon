//---------------------------------------------------------------------------------------
//  EDStack.m created by erik on Sat 19-Jul-1997
//  @(#)$Id: EDStack.m,v 1.2 2002-06-18 14:47:57 erik Exp $
//
//  Copyright (c) 1997 by Erik Doernenburg. All rights reserved.
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
#import "EDStack.h"


//---------------------------------------------------------------------------------------
    @implementation EDStack
//---------------------------------------------------------------------------------------

+ (EDStack *)stack
{
    return [[[self alloc] init] autorelease];
}

+ (EDStack *)stackWithObject:(id)object
{
    return [[[self alloc] initWithObject:object] autorelease];
}



//---------------------------------------------------------------------------------------
//	constructors / destructors
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    storage = [[NSMutableArray allocWithZone:[self zone]] init];
    return self;
}

- (id)initWithObject:(id)object
{
    [self init];
    [storage addObject:object];
    return self;
}

- (void)dealloc
{
    [storage release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	push / pop
//---------------------------------------------------------------------------------------

- (void)pushObject:(id)object
{
    [storage addObject:object];
}

- (id)popObject
{
    id object = [[[storage lastObject] retain] autorelease];
    [storage removeLastObject];
    return object;
}

- (void)clear
{
    [storage removeAllObjects];
}


//---------------------------------------------------------------------------------------
//	peeking around
//---------------------------------------------------------------------------------------

- (id)topObject
{
    return [storage lastObject];
}

- (NSArray *)topObjects:(int)count
{
    return [storage subarrayWithRange:NSMakeRange([storage count] - count , count)];
}

- (unsigned int)count
{
    return [storage count];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
