//---------------------------------------------------------------------------------------
//  EDNumberSet.h created by erik on Sun 04-Jul-1999
//  @(#)$Id: EDNumberSet.h,v 1.2 2002-04-14 14:57:55 znek Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDNumberSet_h_INCLUDE
#define	__EDNumberSet_h_INCLUDE


#import <Foundation/Foundation.h>


@class EDRedBlackTree, EDRange;


@interface EDNumberSet : NSObject <NSCoding, NSCopying>
{
    EDRedBlackTree	*rangeTree;
}

- (id)initWithRanges:(NSArray *)rangeList;

- (void)addNumber:(NSNumber *)number;
- (void)removeNumber:(NSNumber *)number;

- (BOOL)containsNumber:(NSNumber *)number;
- (NSNumber *)lowestNumber;
- (NSNumber *)highestNumber;

- (void)addNumbersInRange:(EDRange *)range;
- (void)removeNumbersInRange:(EDRange *)range;

- (NSArray *)coveredRanges;
- (NSEnumerator *)coveredRangeEnumerator;
- (NSArray *)coveredRangesInRange:(EDRange *)range;
- (NSArray *)uncoveredRangesInRange:(EDRange *)range;

@end

#endif	/* __EDNumberSet_h_INCLUDE */
