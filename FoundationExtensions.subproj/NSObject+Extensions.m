//---------------------------------------------------------------------------------------
//  NSObject+Extensions.m created by erik on Sun 06-Sep-1998
//  @(#)$Id: NSObject+Extensions.m,v 1.5 2002-07-02 15:05:32 erik Exp $
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
#import "NSObject+Extensions.h"
#import "EDObjcRuntime.h"

//---------------------------------------------------------------------------------------
    @implementation NSObject(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Various common extensions to #NSObject. "*/

//---------------------------------------------------------------------------------------
//	RUNTIME CONVENIENCES
//---------------------------------------------------------------------------------------

/*" Raises an #NSInternalInconsistencyException stating that the method must be overriden. "*/

- (volatile void)methodIsAbstract:(SEL)selector
{
    [NSException raise:NSInternalInconsistencyException format:@"*** -[%@ %@]: Abstract definition must be overriden.", NSStringFromClass([self class]), NSStringFromSelector(selector)];
}


/*" Prints a warning that the method is obsolete. This warning is only printed once per method. "*/

- (void)methodIsObsolete:(SEL)selector
{
    [self methodIsObsolete:selector hint:nil];
}


/*" Prints a warning that the method is obsolete including the %hint supplied. This warning is only printed once per method. "*/

- (void)methodIsObsolete:(SEL)selector hint:(NSString *)hint
{
    static NSMutableSet *methodList = nil;
    EDObjcMethodInfo method;
    NSValue *methodKey;

    if(methodList == nil)
        methodList = [[NSMutableSet alloc] init];

   if((method = EDObjcClassGetInstanceMethod(isa, selector)) == NULL)
       method = EDObjcClassGetClassMethod(isa, selector);

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
#ifdef NeXT_RUNTIME
#ifdef EDCOMMON_OSXBUILD
    NSMutableArray *subclasses;
    Class          *classes;
    int            numClasses, newNumClasses, i;

    // cf. /System/Library/Frameworks/System.framework/Headers/objc/objc-runtime.h
    numClasses = 0, newNumClasses = objc_getClassList(NULL, 0);
    classes = NULL;
    while (numClasses < newNumClasses)
        {
        numClasses = newNumClasses;
        classes = realloc(classes, sizeof(Class) * numClasses);
        newNumClasses = objc_getClassList(classes, numClasses);
        }

    subclasses = [NSMutableArray array];
    for(i = 0; i < numClasses; i++)
        {
        if(EDClassIsSuperclassOfClass(aClass, classes[i]) == YES)
            [subclasses addObject:classes[i]];
        }
    free(classes);

    return subclasses;
#else /* OSXS_BUILD */
    NSMutableArray	*subclasses;
    NXHashTable		*subClasses;
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
#endif
#else /* GNU_RUNTIME */
    NSMutableArray *subclasses;
    Class subClass;
    void *es = NULL;

    subclasses = [NSMutableArray array];
    while((subClass = objc_next_class(&es)) != Nil)
        if(EDClassIsSuperclassOfClass(aClass, subClass) == YES)
            [subclasses addObject:subClass];

    return subclasses;
#endif
}

/*" Returns all subclasses of the receiving class "*/

+ (NSArray *)subclasses
{
    return EDSubclassesOfClass(self);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
