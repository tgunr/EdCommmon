//---------------------------------------------------------------------------------------
//  NSApplication+Extensions.m created by erik on Sat 09-Oct-1999
//  @(#)$Id: NSApplication+Extensions.m,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
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

#import <AppKit/AppKit.h>
#import "EDCommonDefines.h"
#import "NSApplication+Extensions.h"


#define LS_CANNOT_CREATE_LIBRARY_FOLDER \
NSLocalizedString(@"Failed to create a folder in your library folder.", "Error message for exception which is thrown when the creation of a folder in the library folder fails.")

#define LS_CANNOT_CREATE_LIBRARY_FOLDER_WIN(LIBFOLDER) \
[NSString stringWithFormat:NSLocalizedString(@"Failed to create a folder in your library folder (%@).", "Error message for exception which is thrown when the creation of a folder in the library folder fails under Windows."), LIBFOLDER]


//---------------------------------------------------------------------------------------
    @implementation NSApplication(EDExtensions)
//---------------------------------------------------------------------------------------

- (void)registerFactoryDefaults
{
   NSString		*resourcePath;
   NSDictionary	*factorySettings;

   resourcePath = [[NSBundle mainBundle] pathForResource:@"FactoryDefaults" ofType:@"plist"];
   NSAssert(resourcePath != nil, @"missing resource; cannot find FactoryDefaults");
   NS_DURING
       factorySettings = [[NSString stringWithContentsOfFile:resourcePath] propertyList];
   NS_HANDLER
       factorySettings = nil;
   NS_ENDHANDLER
   if([factorySettings isKindOfClass:[NSDictionary class]] == NO)
       [NSException raise:NSGenericException format:@"Damaged resource; FactoryDefaults does not contain a valid dictionary representation."];
   [[NSUserDefaults standardUserDefaults] registerDefaults:factorySettings];
}


- (NSString *)name
{
   return [[NSProcessInfo processInfo] processName];
}


- (NSString *)libraryDirectory
{
   NSFileManager	*fileManager;
   NSString 		*libraryDirectory;
   NSArray	 		*pathList;
   BOOL				isDir;

   // Allow to override the library directory. This can come in handy under Windows.
   // Maybe we should add code to let the user specify an alternative directory when
   // the creation below fails and then automatically store this in the defaults.
   if((libraryDirectory = [DEFAULTS stringForKey:@"LibraryDirectory"]) == nil)
       {
       pathList = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
       NSAssert([pathList count] > 0, @"system does not know a user specific library folder");
       NSAssert([pathList count] < 2, @"system returned more than one user specific library folder");
       libraryDirectory = [[pathList objectAtIndex:0] stringByAppendingPathComponent:[self name]];
       }

   fileManager = [NSFileManager defaultManager];
   if([fileManager fileExistsAtPath:libraryDirectory isDirectory:&isDir] == NO)
       {
       if([fileManager createDirectoryAtPath:libraryDirectory attributes:nil] == NO)
           {
#ifndef WIN32           
           [NSException raise:NSGenericException format:LS_CANNOT_CREATE_LIBRARY_FOLDER];
#else
           [NSException raise:NSGenericException format:LS_CANNOT_CREATE_LIBRARY_FOLDER_WIN([pathList objectAtIndex:0])];
#endif
           }
       }
   else
       {
       NSAssert(isDir == YES, @"found a file instead of the library folder");
       }

   return libraryDirectory;
}


- (NSMenuItem *)menuItemWithAction:(SEL)action inMenu:(NSMenu *)aMenu
{
   NSEnumerator	*itemEnum;
   NSMenuItem		*item;

   itemEnum = [[aMenu itemArray] objectEnumerator];
   while((item = [itemEnum nextObject]) != nil)
       {
       if([item hasSubmenu])
           item = [self menuItemWithAction:action inMenu:[item submenu]];
       if([item action] == action)
           break;
       }
   return item;
}


- (NSMenuItem *)menuItemWithAction:(SEL)action
{
   return [self menuItemWithAction:action inMenu:[self mainMenu]];
}



- (void)openURL:(NSString *)url;
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


- (void)composeMailWithSubject:(NSString *)subject recipients:(NSString *)recipients body:(NSString *)body
{
    NSMutableArray	*arguments;
    NSBundle		*myBundle;
    NSString		*toolPath;

    myBundle = [NSBundle bundleForClass:NSClassFromString(@"NSFramework_EDCommon")];
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
