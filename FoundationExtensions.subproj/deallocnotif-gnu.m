//---------------------------------------------------------------------------------------
//  deallocnotif-next.h created by erik on Mon Jul 15 2002
//  @(#)$Id: deallocnotif-gnu.m,v 2.1 2003-02-10 21:23:15 erik Exp $
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

#if GNU_RUNTIME

#import <Foundation/Foundation.h>
#include <objc/objc-api.h>
#include <objc/objc.h>
#import "NSObject+Extensions.h"
#import "deallocnotif.h"

//#define DEBUG_PATCHING 1

static void initializeTables();
static Method_t getMethodInClass(Class cls, SEL sel);
static void patchClass(Class cls);
static void unpatchClass(Class cls);


NSMapTable *EDDeallocImpTable = NULL;

static IMP edDeallocHackImp = NULL;

/* INIT DATA STRUCTURES */

static void initializeTables() {
  EDDeallocImpTable = NSCreateMapTable(NSNonOwnedPointerMapKeyCallBacks, 
				       NSNonOwnedPointerMapValueCallBacks, 
				       0);
  edDeallocHackImp = 
    getMethodInClass([NSObject class], 
		     @selector(_edDeallocNotificationHack))->method_imp;
}

/* HELPER FUNCTIONS */

static Method_t getMethodInClass(Class cls, SEL sel) {
  /* why reimplement this ..., isn't exported in headers, but in the binary */
  extern  Method_t search_for_method_in_list (MethodList_t list, SEL op);
  return search_for_method_in_list(cls->methods, sel);
}

/* APPLY/REMOVE PATCH */

static void patchClass(Class cls) {
  extern void __objc_update_dispatch_table_for_class (Class);/* (objc-msg.c) */
  extern void class_add_method_list(Class, MethodList_t);
  Method_t classDealloc;
  IMP      realDeallocImp;
  SEL      deallocSel;
  
  NSCAssert(EDDeallocImpTable, @"dealloc-imp table is not setup ...");
  NSCAssert(edDeallocHackImp,  @"edDeallocHackImp is not setup ...");
  
  // get -dealloc implementation in this class, not in a superclass
  deallocSel   = @selector(dealloc);
  classDealloc = getMethodInClass(cls, deallocSel);
  
  if (classDealloc == NULL) {
#if DEBUG_PATCHING
    printf("patching class without -dealloc: %s\n", cls->name);
#endif
  
    // does not have a -dealloc method. lookup nearest matching -dealloc
    realDeallocImp = class_get_instance_method(cls, deallocSel)->method_imp;
    
    // do nothing if it's our hack. (I believe we can get here in a contrived
    // multi-thread case)
    if (realDeallocImp == edDeallocHackImp) {
#if DEBUG_PATCHING
      printf("  already patched class without -dealloc: %s\n", cls->name);
#endif
      return;
    }
    
    /* remember this before patching (threading issues) */
    NSMapInsert(EDDeallocImpTable, cls, realDeallocImp);
    
    /* now add a dealloc method to the class */
    {
      struct objc_method_list *hackMethodList;
      
      /* currently leaking that memory ... */
      hackMethodList = calloc(1, sizeof(struct objc_method_list));
      
      hackMethodList->method_count = 1;
      hackMethodList->method_list[0].method_name = 
	(SEL)"dealloc"; /* this is correct, morphed to SEL by class_add_method_list ! */
      hackMethodList->method_list[0].method_types = "v4@4:8"; //"v@:";
      hackMethodList->method_list[0].method_imp   = edDeallocHackImp;
      
      class_add_method_list(cls, hackMethodList);
    }
  }
  else {
#if DEBUG_PATCHING
    printf("patching class with -dealloc: %s\n", cls->name);
#endif
    
    // does have a -dealloc method.
    realDeallocImp = classDealloc->method_imp;
    
    // do nothing if it's our hack. (I believe we can get here in a contrived 
    // multi-thread case)
    if (realDeallocImp == edDeallocHackImp) {
#if DEBUG_PATCHING
      printf("  already patched class with -dealloc: %s\n", cls->name);
#endif
      return;
    }
    
    /* remember original dealloc before patching (threading issues) */
    NSMapInsert(EDDeallocImpTable, cls, realDeallocImp);
    
    /* overwrite with our hack */
    classDealloc->method_imp = edDeallocHackImp;
    
    /* update dispatch table */
    __objc_update_dispatch_table_for_class(cls);
  }
  
  /* assert that patch was successful */
  classDealloc = class_get_instance_method(cls, @selector(dealloc));
  NSCAssert1(classDealloc->method_imp == edDeallocHackImp, 
	     @"%@: Failed to patch class", NSStringFromClass(cls));

#if DEBUG_PATCHING
  printf("done patching class: %s.\n", cls->name);
#endif
}


static void unpatchClass(Class cls) {
  Method_t classDealloc;
  
#if 0
  printf("TRIED TO UNPATCH %s ...\n", cls->name);

  // we try to remove our method list; in case we added one. if we didn't no 
  // harm is
  // done and as a positive side effect the cache is flushed in both cases...
  class_removeMethods(cls, deallocHackMethodList);
  
  
#endif
  
  /* in case we simply wrote over an existing dealloc undo this now */
  if ((classDealloc = getMethodInClass(cls, @selector(dealloc))) != NULL)
    classDealloc->method_imp = NSMapGet(EDDeallocImpTable, cls);
  
  /* assert that unpatch was successful */
  classDealloc = class_get_instance_method(cls, @selector(dealloc));
  NSCAssert1(classDealloc->method_imp != edDeallocHackImp,
	     @"%@: Failed to unpatch class", NSStringFromClass(cls));
  
  /* remove from table */
  NSMapRemove(EDDeallocImpTable, cls);
}


/* PUBLIC API */

void EDEnsureDeallocHackIsInstalledForClass(Class cls) {
  NSArray *subclasses;
  Class   c;
  IMP     realDealloc;
  int     i, n;

  if (EDDeallocImpTable == NULL)
    initializeTables();
    
  // check whether this class or any of its superclasses is patched
  for (c = cls; c != NULL; c = c->super_class) {
    if (NSMapGet(EDDeallocImpTable, c) != NULL)
      return;
  }

  // now remove patch from all subclasses
  subclasses = EDSubclassesOfClass(cls);
  for (i = 0, n = [subclasses count]; i < n; i++) {
    c = [subclasses objectAtIndex:i];
    if ((realDealloc = NSMapGet(EDDeallocImpTable, c)) != NULL)
      unpatchClass(c);
  }
  
  // WARNING: The implementation is only thread-safe insofar that it does
  // not crash. An open issue is that notifications are lost when another
  // thread deallocs objects while we are at exactly this position in the
  // code...

  // finally apply patch
  patchClass(cls);
}

#if 0
IMP EDDeallocImpForClass(Class cls) {
  IMP deallocImp;
    
  // note that this method is not neccesarily patched onto the class that
  // self->isa points to. so we locate our real class first...
  deallocImp = NULL; // keep compiler happy
  for (c = cls; c != NULL; c = c->super_class) {
    if ((deallocImp = NSMapGet(EDDeallocImpTable, c)) != NULL)
      break;
  }
  NSAssert1(deallocImp != NULL, @"%@: Cannot find original dealloc",
	    NSStringFromClass(isa));
  NSAssert1(deallocImp != edDeallocHackImp, @"%@: Dealloc patch loop", 
	    NSStringFromClass(isa));

  return deallocImp;
}
#endif


#endif /* GNU_RUNTIME */
