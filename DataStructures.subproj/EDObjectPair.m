//---------------------------------------------------------------------------------------
//  EDKeyValuePair.m created by erik on Sat 29-Aug-1998
//  @(#)$Id: EDObjectPair.m,v 1.3 2002-02-05 23:27:00 znek Exp $
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

#import <Foundation/Foundation.h>
#import "EDObjectPair.h"


//---------------------------------------------------------------------------------------
    @implementation EDObjectPair
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

+ (id)pairWithObjectPair:(EDObjectPair *)pair
{
    return [[[self alloc] initWithObjects:[pair firstObject]:[pair secondObject]] autorelease];
}


+ (id)pairWithObjects:(id)anObject:(id)anotherObject
{
    return [[[self alloc] initWithObjects:anObject:anotherObject] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT
//---------------------------------------------------------------------------------------

- (id)initWithObjectPair:(EDObjectPair *)pair
{
    return [self initWithObjects:[pair firstObject]:[pair secondObject]];
}


- (id)initWithObjects:(id)anObject:(id)anotherObject
{
    [super init];
    firstObject = [anObject retain];
    secondObject = [anotherObject retain];
    return self;
}


- (void)dealloc
{
    [firstObject release];
    [secondObject release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [encoder encodeObject:firstObject];
    [encoder encodeObject:secondObject];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super init];
    version = [decoder versionForClassName:@"EDObjectPair"];
    if(version > 0)
        {
        firstObject = [[decoder decodeObject] retain];
        secondObject = [[decoder decodeObject] retain];
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
    return [[EDObjectPair allocWithZone:zone] initWithObjects:firstObject:secondObject];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ 0x%x: (%@, %@)>", NSStringFromClass(isa), (void *)self, firstObject, secondObject];
}


- (unsigned int)hash
{
    return [firstObject hash] ^ [secondObject hash];
}


- (BOOL)isEqual:(id)otherObject
{
    if(otherObject == nil)
        return NO;
    else if((isa != ((EDObjectPair *)otherObject)->isa) && ([otherObject isKindOfClass:[EDObjectPair class]] == NO))
        return NO;
    return [((EDObjectPair *)otherObject)->firstObject isEqual:firstObject] &&
        [((EDObjectPair *)otherObject)->secondObject isEqual:secondObject];
}


//---------------------------------------------------------------------------------------
//	ATTRIBUTES
//---------------------------------------------------------------------------------------

- (id)firstObject
{
    return firstObject;
}


- (id)secondObject
{
    return secondObject;
}


//---------------------------------------------------------------------------------------
//	CONVENIENCE
//---------------------------------------------------------------------------------------

- (NSArray *)allObjects
{
    if(firstObject == nil)
        return [NSArray arrayWithObjects:secondObject, nil];
    return [NSArray arrayWithObjects:firstObject, secondObject, nil];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
