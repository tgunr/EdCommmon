//---------------------------------------------------------------------------------------
//  NSWorkspace+Extensions.m created by erik on Mon 19-Feb-2001
//  $Id: NSWorkspace+Extensions.m,v 1.2 2001-04-25 20:40:06 erik Exp $
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
#import "NSWorkspace+Extensions.h"


//---------------------------------------------------------------------------------------
    @implementation NSWorkspace(EDExtensions)
//---------------------------------------------------------------------------------------

#ifdef EDCOMMON_OSXSBUILD

- (void)openURL:(NSString *)url
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
#ifndef EDCOMMON_OSXSBUILD
    [self openURL:[NSURL URLWithString:@"mailto:erik@x101.net"]];
#else
    [NSException raise:NSGenericException format:@"Cannot compose e-mails on Mac OS X Server"];
#endif    
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
