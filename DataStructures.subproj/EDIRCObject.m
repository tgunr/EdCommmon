//---------------------------------------------------------------------------------------
//  EDIRCObject.m created by erik
//  @(#)$Id: EDIRCObject.m,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
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
#import <Foundation/NSDebug.h>
#import "EDLightWeightLock.h"
#import "EDIRCObject.h"


//---------------------------------------------------------------------------------------
    @implementation EDIRCObject
//---------------------------------------------------------------------------------------

static EDLightWeightLock retainLock;


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    static BOOL initialized = NO;

    if(initialized == YES)
        return;

    initialized = YES;
    EDLWLInit(&retainLock);
}


//---------------------------------------------------------------------------------------
//	RETAIN COUNT IMPLEMENTATION
//---------------------------------------------------------------------------------------

- (unsigned int)retainCount
{
    return retainCount + 1;
}


- retain
{
    EDLWLLock(&retainLock);

    if(NSKeepAllocationStatistics)
        NSRecordAllocationEvent(NSObjectInternalRefIncrementedEvent, self, NULL, NULL, NULL);
    retainCount += 1;

    EDLWLUnlock(&retainLock);
    return self;
}


- (void)release
{
    EDLWLLock(&retainLock);

    if(NSKeepAllocationStatistics) 
        NSRecordAllocationEvent(NSObjectInternalRefDecrementedEvent, self, NULL, NULL, NULL);
    if(retainCount == 0)
        {
        EDLWLUnlock(&retainLock);
        [self dealloc];
        return;
        }
    retainCount -= 1;

    EDLWLUnlock(&retainLock);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
