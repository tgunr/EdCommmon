//---------------------------------------------------------------------------------------
//  EDRedBlackTree.h created by erik on Sun 13-Sep-1998
//  @(#)$Id: EDRedBlackTree.h,v 1.2 2002-04-14 14:57:55 znek Exp $
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


#ifndef	__EDRedBlackTree_h_INCLUDE
#define	__EDRedBlackTree_h_INCLUDE


#import <Foundation/Foundation.h>


@interface EDRedBlackTree : NSObject
{
    SEL		comparator;
    void	*sentinel;
    void 	*rootNode;
    void 	*minimumNode;
}

- (id)initWithComparisonSelector:(SEL)aSelector;
- (SEL)comparisonSelector;

- (BOOL)containsObject:(id)anObject;
- (id)member:(id)anObject;
- (id)smallerOrEqualMember:(id)anObject;
- (id)successorForObject:(id)anObject;
- (id)minimumObject;
- (id)maximumObject;

- (NSEnumerator *)objectEnumerator;
- (NSArray *)allObjects;

- (void)addObject:(id)anObject;
- (void)addObjectsFromArray:(NSArray *)someObjects;
- (void)removeObject:(id)anObject;

- (id)objectAtIndex:(unsigned int)index;
- (unsigned int)indexOfObject:(id)anObject;
- (void)removeObjectAtIndex:(unsigned int)index;
- (unsigned int)count;

@end

#endif	/* __EDRedBlackTree_h_INCLUDE */
