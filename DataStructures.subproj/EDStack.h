//---------------------------------------------------------------------------------------
//  EDStack.h created by erik on Sat 19-Jul-1997
//  @(#)$Id: EDStack.h,v 1.3 2002-06-18 14:47:57 erik Exp $
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


#ifndef	__EDStack_h_INCLUDE
#define	__EDStack_h_INCLUDE


@interface EDStack : NSObject
{
    NSMutableArray	*storage;
}

+ (EDStack *)stack;
+ (EDStack *)stackWithObject:(id)object;

- (id)init;
- (id)initWithObject:(id)object;

- (void)pushObject:(id)object;
- (id)popObject;
- (void)clear;
- (id)topObject;
- (NSArray *)topObjects:(int)count;
- (unsigned int)count;


@end

#endif	/* __EDStack_h_INCLUDE */
