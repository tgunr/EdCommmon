//---------------------------------------------------------------------------------------
//  NSBundle+Extensions.m created by erik on Sat Jan 04 2003
//  @(#)$Id: NSBundle+Extensions.m,v 1.2 2003-01-13 20:04:29 erik Exp $
//
//  Copyright (c) 2002 by Erik Doernenburg. All rights reserved.
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
#import "NSBundle+Extensions.h"
#import "NSArray+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSBundle(EDExtensions)
//---------------------------------------------------------------------------------------

/*" Returns a bundle for the framework named %frameworkName. If %frameworkName is a path the method first tries to load the bundle from that path. If the framework is not found at that path, or if only a name is passed, the method looks for the framework inside the bundle and then at the standard library paths. "*/

- (NSBundle *)bundleForFramework:(NSString *)frameworkName
{
    NSBundle	 	*bundle;
    NSString	 	*path, *libraryPath;
    NSEnumerator 	*pathEnum;
    NSArray			*searchPaths;

    // add .framework extension if it is missing
    if([[frameworkName pathExtension] isEqualToString:@"framework"] == NO)
        frameworkName = [frameworkName stringByAppendingPathExtension:@"framework"];

    // if frameworkName includes a path try load directly
    if([[frameworkName pathComponents] count] > 1)
        {
        if((bundle = [NSBundle bundleWithPath:frameworkName]) != nil)
            return bundle;
        frameworkName = [frameworkName lastPathComponent];
        }

    // check bundle paths
    searchPaths = [NSArray arrayWithObjects:[self sharedFrameworksPath], [self privateFrameworksPath], nil];
    pathEnum = [searchPaths objectEnumerator];
    while((path = [pathEnum nextObject]) != nil)
        {
        path = [[libraryPath stringByAppendingPathComponent:frameworkName];
        if((bundle = [NSBundle bundleWithPath:path]) != nil)
            return bundle;
        }
    
    // check search library paths
    pathEnum = [[NSArray librarySearchPaths] objectEnumerator];
    while((libraryPath = [pathEnum nextObject]) != nil)
        {
        path = [[libraryPath stringByAppendingPathComponent:@"Frameworks"] stringByAppendingPathComponent:frameworkName];
        if((bundle = [NSBundle bundleWithPath:path]) != nil)
            break;
        }
    return bundle;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
