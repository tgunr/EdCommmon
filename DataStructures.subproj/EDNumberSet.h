//---------------------------------------------------------------------------------------
//  EDNumberSet.h created by erik on Sun 04-Jul-1999
//  @(#)$Id: EDNumberSet.h,v 1.3 2002-07-09 15:56:55 erik Exp $
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
    EDRedBlackTree	*rangeTree;	/*" All instance variables are private. "*/
}

/*" Creating number sets "*/
- (id)init;
- (id)initWithNumbersInRange:(EDRange *)aRange;
- (id)initWithRanges:(NSArray *)rangeList;

/*" Adding/removing numbers "*/
- (void)addNumber:(NSNumber *)aNumber;
- (void)removeNumber:(NSNumber *)aNumber;
- (void)addNumbersInRange:(EDRange *)aRange;
- (void)removeNumbersInRange:(EDRange *)aRange;

/*" Checking individual numbers "*/
- (BOOL)containsNumber:(NSNumber *)aNumber;
- (NSNumber *)lowestNumber;
- (NSNumber *)highestNumber;

/*" Checking ranges "*/
- (NSArray *)coveredRanges;
- (NSEnumerator *)coveredRangeEnumerator;
- (NSArray *)coveredRangesInRange:(EDRange *)aRange;
- (NSArray *)uncoveredRangesInRange:(EDRange *)aRange;

@end

#endif	/* __EDNumberSet_h_INCLUDE */
