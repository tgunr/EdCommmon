//---------------------------------------------------------------------------------------
//  EDNumberSet.m created by erik on Sun 04-Jul-1999
//  @(#)$Id: EDNumberSet.m,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
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

#import <Foundation/Foundation.h>
#import "CollectionMapping.h"
#import "EDRedBlackTree.h"
#import "EDRange.h"
#import "EDNumberSet.h"

#define RWL(LOC1, LOC2) [[[EDRange allocWithZone:[self zone]] initWithLocations:(LOC1):(LOC2)] autorelease]


//---------------------------------------------------------------------------------------
    @implementation EDNumberSet
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    rangeTree = [[EDRedBlackTree allocWithZone:[self zone]] initWithComparisonSelector:@selector(compareLocation:)];
    return self;
}


- (id)initWithRanges:(NSArray *)rangeList
{
    NSEnumerator *rangeEnum;
    EDRange		 *range;
    
    [self init];
    rangeEnum = [rangeList objectEnumerator];
    while((range = [rangeEnum nextObject]) != nil)
        [self addNumbersInRange:range];
    return self;
}


- (void)dealloc
{
    [rangeTree release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:[rangeTree allObjects]];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int 	version;
    NSEnumerator	*rangeEnum;
    EDRange			*range;

    [super init];
    version = [decoder versionForClassName:@"EDNumberSet"];
    if(version > 0)
        {
        rangeTree = [[EDRedBlackTree allocWithZone:[self zone]] initWithComparisonSelector:@selector(compareLocation:)];
        rangeEnum = [[decoder decodeObject] objectEnumerator];
        while((range = [rangeEnum nextObject]) != nil)
            [self addNumbersInRange:range];
        }
    return self;
}


//---------------------------------------------------------------------------------------
//	NSCOPYING
//---------------------------------------------------------------------------------------

- (id)copyWithZone:(NSZone *)zone
{
   return [[EDNumberSet allocWithZone:zone] initWithRanges:[rangeTree allObjects]];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    NSMutableArray	*rangeDescs;
    NSEnumerator	*rangeEnum;
    EDRange			*range;

    rangeDescs = [NSMutableArray array];
    rangeEnum = [rangeTree objectEnumerator];
    while((range = [rangeEnum nextObject]) != nil)
        [rangeDescs addObject:[NSString stringWithFormat:@"(%d..%d)", [range location], [range endLocation]]];

    return [NSString stringWithFormat: @"<%@ 0x%x: %@>", NSStringFromClass(isa), (void *)self, [rangeDescs componentsJoinedByString:@", "]];
}


//---------------------------------------------------------------------------------------
//	NUMBER ACCESSORS
//---------------------------------------------------------------------------------------

- (void)addNumber:(NSNumber *)number
{
    [self addNumbersInRange:[EDRange rangeWithLocation:[number unsignedIntValue] length:1]];
}


- (void)removeNumber:(NSNumber *)number
{
    [self removeNumbersInRange:[EDRange rangeWithLocation:[number unsignedIntValue] length:1]];
}


- (BOOL)containsNumber:(NSNumber *)number
{
    unsigned int uival;
    EDRange 	 *member;

    uival = [number unsignedIntValue];
    member = [rangeTree smallerOrEqualMember:[EDRange rangeWithLocation:uival length:1]];

    return [member isLocationInRange:uival];
}


- (NSNumber *)lowestNumber
{
    EDRange *member;

    if((member = [rangeTree minimumObject]) == nil)
        return nil;
    return [NSNumber numberWithInt:[member location]];
}


- (NSNumber *)highestNumber
{
    EDRange *member;

    if((member = [rangeTree maximumObject]) == nil)
        return nil;
    return [NSNumber numberWithInt:[member endLocation]];
}



//---------------------------------------------------------------------------------------
//	RANGE ACCESSORS
//---------------------------------------------------------------------------------------

- (void)addNumbersInRange:(EDRange *)new
{
    EDRange 		*member, *next;
    unsigned int	startLoc, endLoc;

    startLoc = [new location];
    endLoc = [new endLocation];

    member = [rangeTree smallerOrEqualMember:new];
    if(member != nil)
        {
        if([member containsRange:new])
            {
            // new contained in members; no work to do.
            return; 
            }
        next = [rangeTree successorForObject:member];
        if([member endLocation] >= [new location] - 1)
            {
            // overlaps/adjacent to new; will be merged.
            startLoc = [member location];
            [rangeTree removeObject:member];
            }
        member = next;
        }
    else
        {
        // nothing smaller than new; just get first.
        member = [rangeTree minimumObject];
        }
    
    while((member != nil) && ([member endLocation] <= [new endLocation]))
        {
        next = [rangeTree successorForObject:member];
        [rangeTree removeObject:member];
        member = next;
        }

    if((member != nil) && ([member location] <= [new endLocation] + 1))
        {
        // overlaps/adjacent to new; merge.
        endLoc = [member endLocation];
        [rangeTree removeObject:member];
        }

    new = RWL(startLoc, endLoc);
    [rangeTree addObject:new];
}


- (void)removeNumbersInRange:(EDRange *)del
{
    EDRange 		*member, *next, *mod;

    member = [rangeTree smallerOrEqualMember:del];
    if(member != nil)
        {
        next = [rangeTree successorForObject:member];
        if([member endLocation] >= [del location])
            {
            // member overlaps del; must be modified
            [[member retain] autorelease];
            [rangeTree removeObject:member];
            if([member isEqualToRange:del])
                {
                // nothing more to do
                return;
                }
            if([member location] < [del location])
                {
                // add section before del
                mod = RWL([member location], [del location] - 1);
                [rangeTree addObject:mod];
                }
            if([member endLocation] > [del endLocation])
                {
                // member contained del; add rest and return
                mod = RWL([del endLocation] + 1, [member endLocation]);
                [rangeTree addObject:mod];
                return; 
                }
            }
        member = next;
        }
    else
        {
        member = [rangeTree minimumObject];
        }
    
    while((member != nil) && ([member endLocation] <= [del endLocation]))
        {
        next = [rangeTree successorForObject:member];
        [rangeTree removeObject:member];
        member = next;
        }
    
    if((member != nil) && ([member location] <= [del endLocation]))
        {
        mod = RWL([del endLocation] + 1, [member endLocation]);
        [rangeTree removeObject:member];
        [rangeTree addObject:mod];
        }
}


- (NSArray *)coveredRanges
{
    return [rangeTree allObjects];
}


- (NSEnumerator *)coveredRangeEnumerator
{
    return [rangeTree objectEnumerator];
}


- (NSArray *)coveredRangesInRange:(EDRange *)range
{
    NSMutableArray	*resultSet;
    EDRange 		*member;

    resultSet = [NSMutableArray array];
    member =  [rangeTree smallerOrEqualMember:range];
    if(member != nil)
        {
        if([member endLocation] < [range location])
            member = [rangeTree successorForObject:member];
        }
    else
        {
        member = [rangeTree minimumObject];
        }

    while((member != nil) && ([member location] <= [range endLocation]))
        {
        [resultSet addObject:[member intersectionRange:range]];
        member = [rangeTree successorForObject:member];
        }

    return resultSet;
}


- (NSArray *)uncoveredRangesInRange:(EDRange *)range
{
    NSMutableArray	*resultSet;
    EDRange 		*member, *uncovered;
    unsigned int	startLoc;

    resultSet = [NSMutableArray array];
    member =  [rangeTree smallerOrEqualMember:range];
    startLoc = [range location];
    if(member != nil)
        {
        if([member endLocation] >= [range endLocation])
            return nil;
        
        if([member endLocation] >= [range location])
            startLoc = [member endLocation] + 1;
        member = [rangeTree successorForObject:member];
        }
    else
        {
        member = [rangeTree minimumObject];
        }

    while((member != nil) && ([member location] <= [range endLocation]))
        {
        uncovered = RWL(startLoc, [member location] - 1);
        [resultSet addObject:uncovered];
        startLoc = [member endLocation] + 1;
        member = [rangeTree successorForObject:member];
        }

    if(startLoc <= [range endLocation])
        {
        uncovered = RWL(startLoc, [range endLocation]);
        [resultSet addObject:uncovered];
        }
    
    return resultSet;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
