//---------------------------------------------------------------------------------------
//  EDNumberSet.m created by erik on Sun 04-Jul-1999
//  @(#)$Id: EDNumberSet.m,v 1.2 2002-07-09 15:56:56 erik Exp $
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

/*" #EDNumberSet is a data structure that stores large sets of numbers efficiently. (#NSSet with instances of #NSNumber might be a tad inefficient when you reach a couple of thousand numbers.) As an addeded bonus it also provides operations dealing with ranges that are covered, i.e. all numbers inbetween a a start and an end number are also in the set. The set {7,3,8,9,2} covers two ranges, namely [2..3] and [7..9]. All operations are efficient in that they run in O(lg %n) or less. "*/

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

/*" Initialises a newly allocated number set. "*/

- (id)init
{
    [super init];
    rangeTree = [[EDRedBlackTree allocWithZone:[self zone]] initWithComparisonSelector:@selector(compareLocation:)];
    return self;
}


/*" Initialises a newly allocated number set by adding all numbers in %aRange to it. "*/

- (id)initWithNumbersInRange:(EDRange *)aRange
{
    [self init];
    [self addNumbersInRange:aRange];
    return self;
}


/*" Initialises a newly allocated number set by adding all numbers in the ranges in %rangeList to it. "*/

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

/*" Adds %aNumber to the set. The number object itself is not neccessarily used and retained. "*/

- (void)addNumber:(NSNumber *)aNumber
{
    [self addNumbersInRange:[EDRange rangeWithLocation:[aNumber unsignedIntValue] length:1]];
}


/*" Removes %aNumber from the set. "*/

- (void)removeNumber:(NSNumber *)aNumber
{
    [self removeNumbersInRange:[EDRange rangeWithLocation:[aNumber unsignedIntValue] length:1]];
}


/*" Returns YES if %number is in the set, NO otherwise. "*/

- (BOOL)containsNumber:(NSNumber *)aNumber
{
    unsigned int uival;
    EDRange 	 *member;

    uival = [aNumber unsignedIntValue];
    member = [rangeTree smallerOrEqualMember:[EDRange rangeWithLocation:uival length:1]];

    return [member isLocationInRange:uival];
}


/*" Returns the lowest number in the set. "*/

- (NSNumber *)lowestNumber
{
    EDRange *member;

    if((member = [rangeTree minimumObject]) == nil)
        return nil;
    return [NSNumber numberWithInt:[member location]];
}


/*" Returns the highest number in the set. "*/

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

/*" Adds all numbers in %aRange to the set. "*/

- (void)addNumbersInRange:(EDRange *)aRange
{
    EDRange 		*member, *next;
    unsigned int	startLoc, endLoc;

    startLoc = [aRange location];
    endLoc = [aRange endLocation];

    member = [rangeTree smallerOrEqualMember:aRange];
    if(member != nil)
        {
        if([member containsRange:aRange])
            {
            // aRange contained in members; no work to do.
            return; 
            }
        next = [rangeTree successorForObject:member];
        if([member endLocation] >= [aRange location] - 1)
            {
            // overlaps/adjacent to aRange; will be merged.
            startLoc = [member location];
            [rangeTree removeObject:member];
            }
        member = next;
        }
    else
        {
        // nothing smaller than aRange; just get first.
        member = [rangeTree minimumObject];
        }
    
    while((member != nil) && ([member endLocation] <= [aRange endLocation]))
        {
        next = [rangeTree successorForObject:member];
        [rangeTree removeObject:member];
        member = next;
        }

    if((member != nil) && ([member location] <= [aRange endLocation] + 1))
        {
        // overlaps/adjacent to aRange; merge.
        endLoc = [member endLocation];
        [rangeTree removeObject:member];
        }

    aRange = RWL(startLoc, endLoc);
    [rangeTree addObject:aRange];
}


/*" Removes all numbers in %aRange from the set. "*/

- (void)removeNumbersInRange:(EDRange *)aRange
{
    EDRange 		*member, *next, *mod;

    member = [rangeTree smallerOrEqualMember:aRange];
    if(member != nil)
        {
        next = [rangeTree successorForObject:member];
        if([member endLocation] >= [aRange location])
            {
            // member overlaps aRange; must be modified
            [[member retain] autorelease];
            [rangeTree removeObject:member];
            if([member isEqualToRange:aRange])
                {
                // nothing more to do
                return;
                }
            if([member location] < [aRange location])
                {
                // add section before aRange
                mod = RWL([member location], [aRange location] - 1);
                [rangeTree addObject:mod];
                }
            if([member endLocation] > [aRange endLocation])
                {
                // member contained aRange; add rest and return
                mod = RWL([aRange endLocation] + 1, [member endLocation]);
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
    
    while((member != nil) && ([member endLocation] <= [aRange endLocation]))
        {
        next = [rangeTree successorForObject:member];
        [rangeTree removeObject:member];
        member = next;
        }
    
    if((member != nil) && ([member location] <= [aRange endLocation]))
        {
        mod = RWL([aRange endLocation] + 1, [member endLocation]);
        [rangeTree removeObject:member];
        [rangeTree addObject:mod];
        }
}


/*" Returns an array containing EDRange objects for all ranges covered by the numbers in the set. "*/

- (NSArray *)coveredRanges
{
    return [rangeTree allObjects];
}


/*" Returns an enumerator for all EDRange objects for all ranges covered by the numbers in the set. "*/

- (NSEnumerator *)coveredRangeEnumerator
{
    return [rangeTree objectEnumerator];
}


/*" Returns an array containing EDRange objects for all ranges covered by the numbers in the set within %aRange. "*/

- (NSArray *)coveredRangesInRange:(EDRange *)aRange
{
    NSMutableArray	*resultSet;
    EDRange 		*member;

    resultSet = [NSMutableArray array];
    member =  [rangeTree smallerOrEqualMember:aRange];
    if(member != nil)
        {
        if([member endLocation] < [aRange location])
            member = [rangeTree successorForObject:member];
        }
    else
        {
        member = [rangeTree minimumObject];
        }

    while((member != nil) && ([member location] <= [aRange endLocation]))
        {
        [resultSet addObject:[member intersectionRange:aRange]];
        member = [rangeTree successorForObject:member];
        }

    return resultSet;
}


/*" Returns an array containing EDRange objects for all ranges not covered by the numbers in the set within %aRange. "*/

- (NSArray *)uncoveredRangesInRange:(EDRange *)aRange
{
    NSMutableArray	*resultSet;
    EDRange 		*member, *uncovered;
    unsigned int	startLoc;

    resultSet = [NSMutableArray array];
    member =  [rangeTree smallerOrEqualMember:aRange];
    startLoc = [aRange location];
    if(member != nil)
        {
        if([member endLocation] >= [aRange endLocation])
            return nil;
        
        if([member endLocation] >= [aRange location])
            startLoc = [member endLocation] + 1;
        member = [rangeTree successorForObject:member];
        }
    else
        {
        member = [rangeTree minimumObject];
        }

    while((member != nil) && ([member location] <= [aRange endLocation]))
        {
        uncovered = RWL(startLoc, [member location] - 1);
        [resultSet addObject:uncovered];
        startLoc = [member endLocation] + 1;
        member = [rangeTree successorForObject:member];
        }

    if(startLoc <= [aRange endLocation])
        {
        uncovered = RWL(startLoc, [aRange endLocation]);
        [resultSet addObject:uncovered];
        }
    
    return resultSet;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
