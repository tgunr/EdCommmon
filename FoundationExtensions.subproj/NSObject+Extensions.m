//---------------------------------------------------------------------------------------
//  NSObject+Extensions.m created by erik on Sun 06-Sep-1998
//  @(#)$Id: NSObject+Extensions.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
//
//  Copyright (c) 1998-2000 by Erik Doernenburg. All rights reserved.
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
#import <objc/objc-runtime.h>
#import <objc/objc-class.h>
#import "NSObject+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSObject(EDExtensions)
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	RUNTIME CONVENIENCES
//---------------------------------------------------------------------------------------

- (volatile void)methodIsAbstract:(SEL)selector
{
    [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: Abstract definition must be overriden.", NSStringFromClass(isa), NSStringFromSelector(selector)];
}


- (void)methodIsObsolete:(SEL)selector
{
    [self methodIsObsolete:selector hint:nil];
}


- (void)methodIsObsolete:(SEL)selector hint:(NSString *)hint
{
    static NSMutableSet *methodList = nil;
    Method				method;
    NSValue				*methodKey;

    if(methodList == nil)
        methodList = [[NSMutableSet alloc] init];

   if((method = class_getInstanceMethod(isa, selector)) == NULL)
       method = class_getClassMethod(isa, selector);

   methodKey = [NSValue valueWithBytes:&method objCType:@encode(Method)];
   if([methodList containsObject:methodKey] == NO)
       {
       [methodList addObject:methodKey];
       if(hint == nil)
           NSLog(@"*** Warning: Compatibility method '%@' in class %@ has been invoked at least once.", NSStringFromSelector(selector), NSStringFromClass([self class]));
       else
           NSLog(@"*** Warning: Compatibility method '%@' in class %@ has been invoked at least once. %@", NSStringFromSelector(selector), NSStringFromClass([self class]), hint);
        }
}


- (NSString *)className
{
    return NSStringFromClass([self class]);
}


//---------------------------------------------------------------------------------------
//	EXTENDED INTROSPECTION 
//---------------------------------------------------------------------------------------

BOOL EDClassIsSuperclassOfClass(Class aClass, Class subClass)
{
    Class class;

    class = subClass->super_class;
    while(class != nil)
        {
        if(class == aClass)
            return YES;
        class = class->super_class;
        }
    return NO;
}


NSArray *EDSubclassesOfClass(Class aClass)
{
    NSMutableArray*	subclasses;
    NXHashTable*	subClasses;
    NXHashState 	subIterator;
    Class			subClass;
    
    subClasses = objc_getClasses();
    subIterator = NXInitHashState(subClasses);
    subclasses = [NSMutableArray array];
    while(NXNextHashState(subClasses, &subIterator, (void **)&subClass))
        {
        if(EDClassIsSuperclassOfClass(aClass, subClass) == YES)
            [subclasses addObject:subClass];
        }
    return subclasses;
}


+ (NSArray *)subclasses
{
    return EDSubclassesOfClass(self);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
