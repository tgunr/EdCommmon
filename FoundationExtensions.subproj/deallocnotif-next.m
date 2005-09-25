//---------------------------------------------------------------------------------------
//  deallocnotif-next.h created by erik on Mon Jul 15 2002
//  @(#)$Id: deallocnotif-next.m,v 2.3 2005-09-25 11:06:38 erik Exp $
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

#ifndef GNU_RUNTIME /* NeXT RUNTIME */

#import <Foundation/Foundation.h>
#import <objc/objc-api.h>
#import <objc/objc-class.h>
#include "NSObject+Extensions.h"
#include "deallocnotif.h"


static void initializeTables();
static Method getMethodInClass(Class cls, SEL sel);
static void patchClass(Class cls);
static void unpatchClass(Class cls);


NSMapTable *EDDeallocImpTable = nil;

static struct objc_method_list *deallocHackMethodList;
static IMP edDeallocHackImp;

//---------------------------------------------------------------------------------------
//	INIT DATA STRUCTURES
//---------------------------------------------------------------------------------------

static void initializeTables()
{
    EDDeallocImpTable = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, NSNonOwnedPointerMapValueCallBacks, 0);
    edDeallocHackImp = getMethodInClass([NSObject class], @selector(_edDeallocNotificationHack))->method_imp;

    deallocHackMethodList = calloc(1, sizeof(struct objc_method_list));
    deallocHackMethodList->obsolete = ((void *)1771); // see comment below
    deallocHackMethodList->method_count = 1;
    deallocHackMethodList->method_list[0].method_name  = sel_registerName("dealloc");
    deallocHackMethodList->method_list[0].method_types = "v4@4:8"; //"v@:";
    deallocHackMethodList->method_list[0].method_imp   = edDeallocHackImp;
}

/* Why do I set obsolete to 1771? Well, if you want to remove a method list you have to pass in a pointer to the method list as stored in the class structure. Unfortunately, the runtime wants to "fix up" added selectors and to do so copies added method list. How are we supposed to find out the correct pointer to remove our method list when a copy is used? Don't know. How do we avoid the copying? By placing 1771 into the obsolete field. Does it harm that the "fix up" is not done? I believe not as all it does is call sel_registerName on all method_names... All this is true for objc4-217 as found in Darwin 1.4 for example. */


//---------------------------------------------------------------------------------------
//	HELPER FUNCTIONS
//---------------------------------------------------------------------------------------

static Method getMethodInClass(Class cls, SEL sel)
{
    void 					*iterator = 0;
    struct objc_method_list *mlist;
    int						j;

    iterator = NULL;
    while((mlist = class_nextMethodList(cls, &iterator)) != NULL)
        {
        for(j = 0; j < mlist->method_count; j++)
            if(mlist->method_list[j].method_name == sel)
                return &(mlist->method_list[j]);
        }
    return NULL;
}


//---------------------------------------------------------------------------------------
//	APPLY/REMOVE PATCH
//---------------------------------------------------------------------------------------

static void patchClass(Class cls)
{
    Method 	classDealloc;
    IMP 	realDeallocImp;

    // get -dealloc implementation in this class, not in a superclass
    classDealloc = getMethodInClass(cls, @selector(dealloc));
    if(classDealloc == NULL)
        {
        // does not have one. lookup nearest matching -dealloc
        realDeallocImp = class_getInstanceMethod(cls, @selector(dealloc))->method_imp;
        // do nothing if it's our hack. (I believe we can get here in a contrived multi-thread case)
        if(realDeallocImp == edDeallocHackImp)
            return;
        // remember this before patching (threading issues)
        NSMapInsert(EDDeallocImpTable, cls, realDeallocImp);
        // now add a dealloc method to the class
        class_addMethods(cls, deallocHackMethodList);
        }
    else
        {
        // it does.
        realDeallocImp = classDealloc->method_imp;
        // do nothing if it's our hack. (I believe we can get here in a contrived multi-thread case)
        if(realDeallocImp == edDeallocHackImp)
            return;
        // remember original dealloc before patching (threading issues)
        NSMapInsert(EDDeallocImpTable, cls, realDeallocImp);
        // overwrite with our hack
        classDealloc->method_imp = edDeallocHackImp;
        }

    // assert that patch was successful
    classDealloc = class_getInstanceMethod(cls, @selector(dealloc));
    NSCAssert1(classDealloc->method_imp == edDeallocHackImp, @"%@: Failed to patch class", NSStringFromClass(cls));
}


static void unpatchClass(Class cls)
{
    Method	classDealloc;

    // we try to remove our method list; in case we added one. if we didn't no harm is
    // done and as a positive side effect the cache is flushed in both cases...
    class_removeMethods(cls, deallocHackMethodList);

    // in case we simply wrote over an existing dealloc undo this now
    if((classDealloc = getMethodInClass(cls, @selector(dealloc))) != NULL)
        classDealloc->method_imp = NSMapGet(EDDeallocImpTable, cls);

    // remove from table
    NSMapRemove(EDDeallocImpTable, cls);

    // assert that unpatch was successful
    classDealloc = class_getInstanceMethod(cls, @selector(dealloc));
    NSCAssert1(classDealloc->method_imp != edDeallocHackImp, @"%@: Failed to unpatch class", NSStringFromClass(cls));
}


//---------------------------------------------------------------------------------------
//	PUBLIC API
//---------------------------------------------------------------------------------------

void EDEnsureDeallocHackIsInstalledForClass(Class cls)
{
    NSArray		*subclasses;
    Class		c;
    IMP			realDealloc;
    int			i, n;

    if(EDDeallocImpTable == nil)
        initializeTables();
    
    // check whether this class or any of its superclasses is patched
    for(c = cls; c != NULL; c = c->super_class)
        if(NSMapGet(EDDeallocImpTable, c) != NULL)
            return;

    // now remove patch from all subclasses
    subclasses = EDSubclassesOfClass(cls);
    for(i = 0, n = [subclasses count]; i < n; i++)
        {
        c = [subclasses objectAtIndex:i];
        if((realDealloc = NSMapGet(EDDeallocImpTable, c)) != NULL)
            unpatchClass(c);
        }

    // WARNING: The implementation is only thread-safe insofar that it does
    // not crash. An open issue is that notifications are lost when another
    // thread deallocs objects while we are at exactly this position in the
    // code...

    // finally apply patch
    patchClass(cls);
}


#endif /* NeXT_RUNTIME */
