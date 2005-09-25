//---------------------------------------------------------------------------------------
//  EDXMLNodeList.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLNodeList.m,v 1.2 2005-09-25 11:06:31 erik Exp $
//
//  Copyright (c) 2003 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mulle Kybernetik in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#include "EDXMLNodeList.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLNodeList
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithArray:(NSArray *)anArray
{
    [super init];
    array = [anArray retain];
    return self;
}


- (void)dealloc
{
    [array release];
    [super dealloc];
    
}


//---------------------------------------------------------------------------------------
//	DOM Impl
//---------------------------------------------------------------------------------------

- (unsigned)length
{
    return [array count];

}


- (id)objectAtIndex:(unsigned)_idx
{
    return [array objectAtIndex:_idx];
}


//---------------------------------------------------------------------------------------
//	Goodies
//---------------------------------------------------------------------------------------

- (NSEnumerator *)objectEnumerator
{
	return [array objectEnumerator];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
