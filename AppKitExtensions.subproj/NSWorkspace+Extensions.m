//---------------------------------------------------------------------------------------
//  NSWorkspace+Extensions.m created by erik on Mon 19-Feb-2001
//  $Id: NSWorkspace+Extensions.m,v 2.0 2002-08-16 18:12:44 erik Exp $
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

/*" Various useful extensions to #NSWorkspace. "*/

#if !defined(EDCOMMON_OSXBUILD) && !defined(GNUSTEP)

/*" Tries to open the URL passed in with a standard application. Note that this implementation is obsolete and not compiled in on MAC OS X and GNUStep. "*/ 

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

/*" Tries to compose an email with the standard email client. This method does not work on old version of Mac OS X Server. "*/ 

- (void)composeMailWithSubject:(NSString *)subject recipients:(NSString *)recipients body:(NSString *)body
{
#if defined(EDCOMMON_OSXBUILD) || defined(GNUSTEP)
    [self openURL:[NSURL URLWithString:@"mailto:erik@x101.net"]];
#else
    [NSException raise:NSGenericException format:@"Cannot compose e-mails on Mac OS X Server"];
#endif    
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
