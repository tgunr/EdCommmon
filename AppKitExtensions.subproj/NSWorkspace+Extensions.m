//---------------------------------------------------------------------------------------
//  NSWorkspace+Extensions.m created by erik on Mon 19-Feb-2001
//  $Id: NSWorkspace+Extensions.m,v 1.1 2001-03-11 03:04:45 erik Exp $
//
//  Copyright (c) 2000 by Erik Doernenburg. All rights reserved.
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
#ifndef EDCOMMON_OSXSBUILD
#import <CoreFoundation/CoreFoundation.h>
#import <HIToolbox/InternetConfig.h>
#endif
#import "NSWorkspace+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSWorkspace(EDExtensions)
//---------------------------------------------------------------------------------------

- (void)openURL:(NSString *)url

#ifndef EDCOMMON_OSXSBUILD

#warning * I guess we can get this from [[NSBundle mainBundle] infoDictionary], right?!
#define MY_APPLICATION_SIGNATURE FOUR_CHAR_CODE('ALX3')
{
    ICInstance 	anInstance;
    const char 	*urlCString;
    long 		start, length;
    OSStatus 	error;

    if(ICStart(&anInstance, MY_APPLICATION_SIGNATURE) != noErr)
        [NSException raise:NSGenericException format:@"Failed to get internet config. Error code %d", error];

    urlCString = [url UTF8String];
    start = 0;
    length = strlen(urlCString);
    error = ICLaunchURL(anInstance, NULL, (Ptr)urlCString, length, &start, &length);
    if(error != noErr)
        [NSException raise:NSGenericException format:@"Failed to launch a URL. Error code %d", error];

    ICStop(anInstance);
}

#else
{
   NSPasteboard 	*pboard;
   NSString 		*sname;

   pboard = [NSPasteboard pasteboardWithName:@"URLServicePasteboard"];
   [pboard declareTypes:[NSArray arrayWithObjects:NSStringPboardType, nil] owner:nil];
   [pboard setString:url forType:NSStringPboardType];

   if((sname = [[NSUserDefaults standardUserDefaults] stringForKey:@"URLService"]) == nil)
       sname = @"OmniWeb/Open URL";
   NSPerformService(sname, pboard);
}

#endif


- (void)composeMailWithSubject:(NSString *)subject recipients:(NSString *)recipients body:(NSString *)body
{
    NSMutableArray	*arguments;
    NSBundle		*myBundle;
    NSString		*toolPath;

    myBundle = [NSBundle bundleForClass:NSClassFromString(@"EDCommonFramework")];
    toolPath = [myBundle pathForResource:@"mvcompose" ofType:@""];
    arguments = [NSMutableArray array];
    if(subject != nil)
        {
        [arguments addObject:@"-subject"];
        [arguments addObject:subject];
        }
    if(recipients != nil)
        {
        [arguments addObject:@"-to"];
        [arguments addObject:recipients];
        }
#warning * pass body to tool
    [NSTask launchedTaskWithLaunchPath:toolPath arguments:arguments];
}

//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
