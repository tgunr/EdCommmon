//---------------------------------------------------------------------------------------
//  NSArray+Extensions.m created by erik on Thu 28-Mar-1996
//  @(#)$Id: NSArray+Extensions.m,v 1.2 2000-09-27 15:52:47 erik Exp $
//
//  Copyright (c) 1996,1999 by Erik Doernenburg. All rights reserved.
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

#import <objc/objc-api.h>
#import <objc/objc-class.h>
#import <Foundation/Foundation.h>
#import "NSArray+Extensions.h"

#ifdef WIN32
#define random() rand()
#endif


//=======================================================================================
    @implementation NSArray(EDExtensions)
//=======================================================================================

//---------------------------------------------------------------------------------------

/*" Return the object at index 0 and make sure that the array does only contain this object. "*/

- (id)singleObject
{
    if([self count] != 1)
        [NSException raise:NSInternalInconsistencyException format:@"-[%@ %@]: Attempt to retrieve single object from an array that contains %d objects.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [self count]];
    return [self objectAtIndex:0];
}

//---------------------------------------------------------------------------------------

/*" Return the object at index 0 or %nil if the array is empty. WARNING: The method #firstObject is also implemented in the HTML framework which is sometimes loaded in AppKit applications. Unfortunately, its implemenation differs in that it raises an exception if the array is empty. (Don't ask why they did that!) So, you either live with this or call #applyFirstObjectPatch before the HTML framework is loaded. "*/

- (id)firstObject
{
    if([self count] == 0)
        return nil;
    return [self objectAtIndex:0];
}


static Method myFirstObjectMethod;

+ (void)applyFirstObjectPatch
{
    myFirstObjectMethod = class_getInstanceMethod([NSArray class], @selector(firstObject));
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bundleWasLoaded:) name:NSBundleDidLoadNotification object:nil];
}

+ (void)_bundleWasLoaded:(NSNotification *)n
{
    Method	evilFirstObjectMethod;

    if([[[n object] bundlePath] hasSuffix:@"Library/PrivateFrameworks/HTML.framework"] == NO)
        return;

    evilFirstObjectMethod = class_getInstanceMethod([NSArray class], @selector(firstObject));
    evilFirstObjectMethod->method_imp = myFirstObjectMethod->method_imp;
    NSLog(@"Applied 'firstObject' patch to HTML framework");
}


//---------------------------------------------------------------------------------------

/*" Returns a new array with the same objects as the receiver but rearranged randomly. "*/

- (NSArray *)shuffledArray
{
    NSMutableArray *copy = [self mutableCopyWithZone:[self zone]];
    [copy shuffle];
    return copy;
}


//---------------------------------------------------------------------------------------

/*" Returns an array containing all objects from the receiver up to (not including) the object at index %index. "*/

- (NSArray *)subarrayToIndex:(unsigned int)index
{
    return [self subarrayWithRange:NSMakeRange(0, index)];
}


/*" Returns an array containing all objects from the receiver starting with the object at index %index. "*/

- (NSArray *)subarrayFromIndex:(unsigned int)index
{
    return [self subarrayWithRange:NSMakeRange(index, [self count] - index)];
}


//---------------------------------------------------------------------------------------

/*" Returns #YES if the receiver is contained in %otherArray at offset %offset. "*/

- (BOOL)isSubarrayOfArray:(NSArray *)other atOffset:(int)offset
{
    int	i, n = [self count];

    if(n > offset + [other count])
        return NO;
    for(i = 0; i < n; i++)
        if([[self objectAtIndex:i] isEqual:[other objectAtIndex:offset + i]] == NO)
            return NO;
    return YES;
}

//---------------------------------------------------------------------------------------

/*" Returns the first index at which %otherArray is contained in the receiver; or #NSNotFound otherwise. "*/

- (unsigned int)indexOfSubarray:(NSArray *)other
{
    int		i, n = [self count], length, location = 0;

    do
        {
        if((length = n - location - [other count] + 1) <= 0)
            return NSNotFound;
        if((i = [self indexOfObject:[other objectAtIndex:0] inRange:NSMakeRange(location, length)]) == NSNotFound)
            return NSNotFound;
        location = i + 1;
        }
    while([other isSubarrayOfArray:self atOffset:i] == NO);

    return i;
}

//---------------------------------------------------------------------------------------

/*" Creates and returns an array of NSString objects. These refer to all files of a type specified in %type that can be found in the directory %aPath. "*/

+ (NSArray *)arrayWithFilesOfType:(NSString *)type inPath:(NSString *)aPath
{
    NSString		*firstName;
    NSArray    	   	*allNames = nil;
    unsigned int	count;

    if(![aPath hasSuffix:@"/"])
        aPath = [aPath stringByAppendingString:@"/"];

    count = [aPath completePathIntoString:&firstName caseSensitive:YES matchesIntoArray:&allNames filterTypes:[NSArray arrayWithObject:type]];
    return allNames;
}


/*" Creates and returns an array of NSString objects. These refer to all files of a type specified in %types that can be found in a directory named %libraryName in any of the standard library locations as returned by #NSSearchPathForDirectoriesInDomains. "*/

+ (NSArray *)arrayWithFilesOfType:(NSString *)type inLibrary:(NSString *)libraryName
{
    NSMutableArray	*result;
    NSArray			*libPathList;
    NSEnumerator	*pathEnum;
    NSString		*path;

    result = [NSMutableArray array];
    libPathList = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSAllDomainsMask, YES);
    pathEnum = [libPathList objectEnumerator];
    while((path = [pathEnum nextObject]) != nil)
        {
        path = [path stringByAppendingPathComponent:libraryName];
        [result addObjectsFromArray:[NSArray arrayWithFilesOfType:type inPath:path]];
       }
    return result;
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableArray(EDExtensions)
//=======================================================================================

/*" Randomly changes the order of the objects in the receiving array. "*/

- (void)shuffle
{
    int i, j, n;
    id	d;

    n = [self count];
    for(i = n - 1; i >= 0; i--)
        {
        j = random() % n;
        if(j == i)
            continue;
        d = [[self objectAtIndex:i] retain];
        [self replaceObjectAtIndex:i withObject:[self objectAtIndex:j]];
        [self replaceObjectAtIndex:j withObject:d];
        }
}


//=======================================================================================
    @end
//=======================================================================================
