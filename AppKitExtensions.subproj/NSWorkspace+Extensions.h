//---------------------------------------------------------------------------------------
//  NSWorkspace+Extensions.h created by erik on Mon 19-Feb-2001
//  $Id: NSWorkspace+Extensions.h,v 1.5 2002-07-02 16:25:26 erik Exp $
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


#ifndef	__NSWorkspace_Extensions_h_INCLUDE
#define	__NSWorkspace_Extensions_h_INCLUDE


#import <AppKit/AppKit.h>

/*" Various useful extensions to #NSWorkspace. "*/

@interface NSWorkspace(EDExtensions)

#if !defined(EDCOMMON_OSXBUILD) && !defined(GNUSTEP)
- (void)openURL:(NSString *)url;
#endif

- (void)composeMailWithSubject:(NSString *)subject recipients:(NSString *)recipients body:(NSString *)body;

@end

#endif	/* __NSWorkspace_Extensions_h_INCLUDE */
