//---------------------------------------------------------------------------------------
//  EDToolbarDefinition.h created by erik on Sat 06-Jun-2001
//  @(#)$Id: EDToolbarDefinition.h,v 1.2 2001-08-05 20:38:00 erik Exp $
//
//  Copyright (c) 2001 by Erik Doernenburg. All rights reserved.
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

#ifndef EDCOMMON_OSXSBUILD

#import <AppKit/AppKit.h>

@interface EDToolbarDefinition : NSObject
{
    NSDictionary 		*toolbarDefinition;
    NSString			*name;
    id					targetForActions;
}

- (id)initWithName:(NSString *)name;

- (NSString *)name;

- (void)setTargetForActions:(id)anObject;
- (id)targetForActions;

- (NSToolbar *)toolbar;
- (NSArray *)defaultItemIdentifiers;
- (NSArray *)allowedItemIdentifiers;
- (NSToolbarItem *)itemWithIdentifier:(NSString *)identifier;

@end

#endif
