//---------------------------------------------------------------------------------------
//  EDLRUCache.m created by erik on Fri 29-Oct-1999
//  @(#)$Id: EDLRUCache.m,v 1.2 2001-03-29 16:01:48 erik Exp $
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
#import "NSDate+Extensions.h"
#import "EDLRUCache.h"


//---------------------------------------------------------------------------------------
    @implementation EDLRUCache
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithCacheSize:(unsigned int)value
{
    [super init];
    NSParameterAssert(value > 0);
    size = value;
    entries = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:size];
    timestamps = [[NSMutableDictionary allocWithZone:[self zone]] initWithCapacity:size];
    return self;
}


- (void)dealloc
{
    [entries release];
    [timestamps release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)addObject:(id)newObject withKey:(id)newKey
{
    NSDate			*date, *earliestDate;
    NSEnumerator	*keyEnum;
    id				key, keyForEarliestDate;

    while([entries count] >= size)
        {
        earliestDate = nil;
        keyEnum = [timestamps keyEnumerator];
        while((key = [keyEnum nextObject]) != nil)
            {
            date = [timestamps objectForKey:key];
            if((earliestDate == nil) || ([date precedesDate:earliestDate]))
                {
                earliestDate = date;
                keyForEarliestDate = key;
                }
            }
        [entries removeObjectForKey:keyForEarliestDate];
        [timestamps removeObjectForKey:keyForEarliestDate];
        }

    [entries setObject:newObject forKey:newKey];
    [timestamps setObject:[NSDate date] forKey:newKey];
}


- (id)objectWithKey:(id)key
{
    id	object;

    if((object = [entries objectForKey:key]) != nil)
        [timestamps setObject:[NSDate date] forKey:key];
    return object;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
