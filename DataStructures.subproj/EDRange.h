//---------------------------------------------------------------------------------------
//  Created by znek on Fri 31-Oct-1997
//  @(#)$Id: EDRange.h,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
//
//  Copyright (c) 1997,1999 by Erik Doernenburg. All rights reserved.
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

#import "EDIRCObject.h"


@interface EDRange : EDIRCObject <NSCoding, NSCopying>
{
    NSRange		 range;
}

+ (id)rangeWithLocation:(unsigned int)loc length:(unsigned int)len;
+ (id)rangeWithLocations:(unsigned int)startLoc:(unsigned int)endLoc;
+ (id)rangeWithRangeValue:(NSRange)aRangeValue;

- (id)initWithRangeValue:(NSRange)aRangeValue; // designated initializer
- (id)initWithLocation:(unsigned int)loc length:(unsigned int)len;
- (id)initWithLocations:(unsigned int)startLoc:(unsigned int)endLoc;

- (unsigned int)location;
- (unsigned int)length;

- (BOOL)isLocationInRange:(unsigned int)index;
- (unsigned int)endLocation;
- (NSRange)rangeValue;

- (EDRange *)intersectionRange:(EDRange *)otherRange;
- (EDRange *)unionRange:(EDRange *)otherRange;
- (BOOL)containsRange:(EDRange *)otherRange;

- (BOOL)isEqualToRange:(EDRange *)otherRange;
- (NSComparisonResult)compareLocation:(EDRange *)otherRange;

@end
