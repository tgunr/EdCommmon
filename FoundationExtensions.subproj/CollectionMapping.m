//---------------------------------------------------------------------------------------
//  EDCollectionMapping.m created by erik on Wed 17-Mar-1999
//  @(#)$Id: CollectionMapping.m,v 1.4 2002-04-14 14:57:56 znek Exp $
//
//  Copyright (c) 1997-1999 by Erik Doernenburg. All rights reserved.
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
#import "EDObjcRuntime.h"


//---------------------------------------------------------------------------------------
    @implementation NSArray(EDCollectionMapping)
//---------------------------------------------------------------------------------------

- (NSArray *)arrayByMappingWithDictionary:(NSDictionary *)mapping
{
    NSMutableArray	*mappedArray;
    unsigned int	i, n = [self count];

    mappedArray = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:n] autorelease];
    for(i = 0; i < n; i++)
        [mappedArray addObject:[mapping objectForKey:[self objectAtIndex:i]]];

    return mappedArray;
}


- (NSArray *)arrayByMappingWithSelector:(SEL)selector
{
    NSMutableArray	*mappedArray;
    unsigned int	i, n = [self count];

    mappedArray = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:n] autorelease];
    for(i = 0; i < n; i++)
        [mappedArray addObject:EDObjcMsgSend([self objectAtIndex:i], selector)];

    return mappedArray;
}


- (NSArray *)arrayByMappingWithSelector:(SEL)selector withObject:(id)object
{
    NSMutableArray	*mappedArray;
    unsigned int	i, n = [self count];

    mappedArray = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:n] autorelease];
   for(i = 0; i < n; i++)
        [mappedArray addObject:EDObjcMsgSend1([self objectAtIndex:i], selector, object)];

    return mappedArray;
}


- (NSArray *)flattenedArray
{
    NSMutableArray	*flattenedArray;
    id				object;
    unsigned int	i, n = [self count];

    flattenedArray = [[[NSMutableArray allocWithZone:[self zone]] init] autorelease];
    for(i = 0; i < n; i++)
        {
        object = [self objectAtIndex:i];
        if([object isKindOfClass:[NSArray class]])
            [flattenedArray addObjectsFromArray:[object flattenedArray]];
        else
            [flattenedArray addObject:object];
        }

    return flattenedArray;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation NSSet(EDCollectionMapping)
//---------------------------------------------------------------------------------------

- (NSSet *)setByMappingWithDictionary:(NSDictionary *)mapping
{
    NSMutableSet	*mappedSet;
    NSEnumerator	*objectEnum;
    id				object;
    
    mappedSet = [[[NSMutableSet allocWithZone:[self zone]] initWithCapacity:[self count]] autorelease];
    objectEnum = [self objectEnumerator];
    while((object = [objectEnum nextObject]) != nil)
        [mappedSet addObject:[mapping objectForKey:object]];

    return mappedSet;
}


- (NSSet *)setByMappingWithSelector:(SEL)selector
{
    NSMutableSet	*mappedSet;
    NSEnumerator	*objectEnum;
    id				object;

    mappedSet = [[[NSMutableSet allocWithZone:[self zone]] initWithCapacity:[self count]] autorelease];
    objectEnum = [self objectEnumerator];
    while((object = [objectEnum nextObject]) != nil)
        [mappedSet addObject:EDObjcMsgSend(object, selector)];

    return mappedSet;
}


- (NSSet *)setByMappingWithSelector:(SEL)selector withObject:(id)otherObject
{
    NSMutableSet	*mappedSet;
    NSEnumerator	*objectEnum;
    id				object;

    mappedSet = [[[NSMutableSet allocWithZone:[self zone]] initWithCapacity:[self count]] autorelease];
    objectEnum = [self objectEnumerator];
    while((object = [objectEnum nextObject]) != nil)
        [mappedSet addObject:EDObjcMsgSend1(object, selector, otherObject)];

    return mappedSet;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------
    @implementation NSObject(EDCollectionMapping)
//---------------------------------------------------------------------------------------

- (NSArray *)mapArray:(NSArray *)array withSelector:(SEL)selector
{
    NSMutableArray	*mappedArray;
    unsigned int	i, n = [array count];

    mappedArray = [[[NSMutableArray allocWithZone:[self zone]] initWithCapacity:n] autorelease];
    for(i = 0; i < n; i++)
        [mappedArray addObject:EDObjcMsgSend1(self, selector, [array objectAtIndex:i])];

    return mappedArray;
}


- (void)performSelector:(SEL)selector withObjects:(NSArray *)array
{
    unsigned int	i, n = [array count];

    for(i = 0; i < n; i++)
        EDObjcMsgSend1(self, selector, [array objectAtIndex:i]);
}


- (void)performSelector:(SEL)selector withObjectsEnumeratedBy:(NSEnumerator *)enumerator
{
    id object;

    while((object = [enumerator nextObject]) != nil)
        EDObjcMsgSend1(self, selector, object);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
