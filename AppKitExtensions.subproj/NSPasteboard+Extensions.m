//---------------------------------------------------------------------------------------
//  NSPasteboard+Extensions.m created by erik on Mon 28-Jun-1999
//  @(#)$Id: NSPasteboard+Extensions.m,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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
#import "NSPasteboard+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSPasteboard(EDExtensions)
//---------------------------------------------------------------------------------------

- (BOOL)containsType:(NSString *)type
{
    return [[self types] indexOfObject:type] != NSNotFound;
}


- (void)setObject:(id)object forType:(NSString *)pboardType
{
    [self setData:[NSArchiver archivedDataWithRootObject:object] forType:pboardType];
}


- (id)objectForType:(NSString *)pboardType
{
    NSData *data = [self dataForType:pboardType];
    return (data != nil) ? [NSUnarchiver unarchiveObjectWithData:data] : nil;
}


- (void)setObjectByReference:(id)object forType:(NSString *)pboardType
{
    [self setData:[NSData dataWithBytes:&object length:sizeof(id)] forType:pboardType];
}


- (id)objectByReferenceForType:(NSString *)pboardType
{
    NSData *data = [self dataForType:pboardType];
    return (data != nil) ? (*((id *)[[self dataForType:pboardType] bytes])) : nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
