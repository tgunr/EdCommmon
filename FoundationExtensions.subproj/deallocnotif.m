//---------------------------------------------------------------------------------------
//  deallocnotif-next.h created by erik on Mon Jul 15 2002
//  @(#)$Id: deallocnotif.m,v 2.2 2003-04-08 16:51:35 znek Exp $
//
//  Copyright (c) 2002 by Erik Doernenburg. All rights reserved.
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
#include "EDObjcRuntime.h"
#include "deallocnotif.h"


static void initializeTables();

#define END_OF_OBSERVER_LIST ((id)-1)


static NSMapTable *observerTable = nil;


//---------------------------------------------------------------------------------------
//	INIT DATA STRUCTURES
//---------------------------------------------------------------------------------------

static void initializeTables()
{
    observerTable = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
}


//---------------------------------------------------------------------------------------
//	MAINTAINING THE OBSERVER LISTS
//---------------------------------------------------------------------------------------

void EDAddObserverForObject(id observer, id object)
{
    id				*observerList;
    unsigned int	i, emptySlotIdx, oldSize, newSize;

    if(observerTable == nil)
        initializeTables();
    
    // create a very small list for one observer if no list exists
    if((observerList = NSMapGet(observerTable, object)) == NULL)
        {
        observerList = NSZoneMalloc(NULL, sizeof(id) * 2);
        observerList[0] = NULL;
        observerList[1] = END_OF_OBSERVER_LIST;
        NSMapInsert(observerTable, object, observerList);
        }

    // find an empty slot in the list. also return if observer is already registered
    emptySlotIdx = NSNotFound;
    for(i = 0; observerList[i] != END_OF_OBSERVER_LIST; i++)
        {
        if(observerList[i] == observer)
            return;
        if(observerList[i] == NULL)
            emptySlotIdx = i;
        }

    // if there is none double the capacity of the list
    if(emptySlotIdx == NSNotFound)
        {
        oldSize = (i + 1) * sizeof(id);
        newSize = oldSize * 2;

        NSMapRemove(observerTable, object);

        observerList = NSZoneRealloc(NULL, observerList, newSize);
        bzero(&(observerList[i]), newSize - oldSize);
        observerList[(i + 1) * 2 - 1] = END_OF_OBSERVER_LIST;

        NSMapInsert(observerTable, object, observerList);

        emptySlotIdx = i;
        }

    // add observer to empty slot
    observerList[emptySlotIdx] = observer;
}


void EDRemoveObserverForObject(id observer, id object)
{
    id				*observerList;
    unsigned int	i;

    if(observerTable == nil)
        initializeTables();

    if((observerList = NSMapGet(observerTable, object)) == NULL)
        return;

    for(i = 0; observerList[i] != END_OF_OBSERVER_LIST; i++)
        {
        if(observerList[i] == observer)
            {
            observerList[i] = NULL;
            return;
            }
        }
}


//---------------------------------------------------------------------------------------
//	SENDING NOTIFICATIONS
//---------------------------------------------------------------------------------------

void EDNotifyObservers(Class cls, id object)
{
    id	*observerList;
    int	i;

    // Class observers
    if((observerList = NSMapGet(observerTable, cls)) != NULL)
        {
        for(i = 0; observerList[i] != END_OF_OBSERVER_LIST; i++)
            if(observerList[i] != NULL)
                EDObjcMsgSend1(observerList[i], @selector(objectDeallocated:), object);
        }

    // Instance observers
    if((observerList = NSMapGet(observerTable, object)) != NULL)
        {
        NSMapRemove(observerTable, object);

        for(i = 0; observerList[i] != END_OF_OBSERVER_LIST; i++)
            if(observerList[i] != NULL)
                EDObjcMsgSend1(observerList[i], @selector(objectDeallocated:), object);
        NSZoneFree(NULL, observerList);
        }
}
