//---------------------------------------------------------------------------------------
//  Created by znek on Fri 31-Oct-1997
//  @(#)$Id: EDRange.m,v 1.2 2002-02-05 23:27:00 znek Exp $
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

#import <Foundation/Foundation.h>
#import "EDRange.h"


//---------------------------------------------------------------------------------------
    @implementation EDRange
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)rangeWithLocation:(unsigned int)loc length:(unsigned int)len
{
    return [[[self alloc] initWithLocation:loc length:len] autorelease];
}


+ (id)rangeWithLocations:(unsigned int)startLoc:(unsigned int)endLoc
{
    return [[[self alloc] initWithLocations:startLoc:endLoc] autorelease];
}

    
+ (id)rangeWithRangeValue:(NSRange)aRangeValue
{
    return [[[self alloc] initWithRangeValue:aRangeValue] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT
//---------------------------------------------------------------------------------------

- (id)initWithRangeValue:(NSRange)aRangeValue
{
    [super init];
    range = aRangeValue;
    return self;
}


- (id)initWithLocation:(unsigned int)loc length:(unsigned int)len
{
    return [self initWithRangeValue:NSMakeRange(loc, len)];
}


- (id)initWithLocations:(unsigned int)startLoc:(unsigned int)endLoc
{
    return [self initWithRangeValue:NSMakeRange(startLoc, endLoc - startLoc + 1)];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeValuesOfObjCTypes:"II", &(range.location), &(range.length)];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super init];
    version = [decoder versionForClassName:@"EDRange"];
    if(version > 0)
        {
        [decoder decodeValuesOfObjCTypes:"II", &(range.location), &(range.length)];
        }
    return self;
}


//---------------------------------------------------------------------------------------
//	NSCOPYING
//---------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
    if(NSShouldRetainWithZone(self, zone))
        return [self retain];
    return [[EDRange allocWithZone:zone] initWithRangeValue:range];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
//    return [NSString stringWithFormat: @"<%@ 0x%x: %@>", NSStringFromClass(isa), (void *)self, NSStringFromRange(range)];
    return [NSString stringWithFormat: @"<%@ 0x%x: (%d..%d)>", NSStringFromClass(isa), (void *)self, range.location, range.location + range.length - 1];
}


- (unsigned int)hash
{
    return range.location + NSSwapInt(range.length);
}


- (BOOL)isEqual:(id)otherObject
{
    if(otherObject == nil)
        return NO;
    else if((isa != ((EDRange *)otherObject)->isa) && ([otherObject isKindOfClass:[EDRange class]] == NO))
        return NO;
    return NSEqualRanges(range, ((EDRange *)otherObject)->range);
}


- (BOOL)isEqualToRange:(EDRange *)otherRange
{
    return NSEqualRanges(range, otherRange->range);
}


- (NSComparisonResult)compareLocation:(EDRange *)otherRange
{
    if(range.location < otherRange->range.location)
        return NSOrderedAscending;
    else if(range.location > otherRange->range.location)
        return NSOrderedDescending;
    return NSOrderedSame;
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

- (unsigned int)location
{
    return range.location;
}


- (unsigned int)length
{
    return range.length;
}


- (BOOL)isLocationInRange:(unsigned int)index
{
    return NSLocationInRange(index, range);
}


- (unsigned int)endLocation
{
    return NSMaxRange(range) - 1;
}


- (NSRange)rangeValue
{
    return range;
}


//---------------------------------------------------------------------------------------
//	DERIVED RANGES
//---------------------------------------------------------------------------------------

- (EDRange *)intersectionRange:(EDRange *)otherRange
{
    NSRange	result;

    result = NSIntersectionRange(range, otherRange->range);
    if(result.length == 0)
        return nil;

    return [[[[self class] allocWithZone:[self zone]] initWithRangeValue:result] autorelease];
}


- (EDRange *)unionRange:(EDRange *)otherRange
{
    NSRange	result;

    result = NSUnionRange(range, otherRange->range);
 
    return [[[[self class] allocWithZone:[self zone]] initWithRangeValue:result] autorelease];
}


- (BOOL)containsRange:(EDRange *)otherRange
{
    return ((range.location <= otherRange->range.location) && (NSMaxRange(range) >= NSMaxRange(otherRange->range)));
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

