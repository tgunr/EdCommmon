//---------------------------------------------------------------------------------------
//  EDToolbarDefinition.h created by erik on Sat 06-Jun-2001
//  @(#)$Id: EDToolbarDefinition.m,v 1.2 2001-08-05 20:38:00 erik Exp $
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
#import "CollectionMapping.h"
#import "EDToolbarDefinition.h"


//---------------------------------------------------------------------------------------
    @implementation EDToolbarDefinition
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithName:(NSString *)aName
{
    NSString *path;

    [super init];

    name = [aName copyWithZone:[self zone]];
    if((path = [[NSBundle mainBundle] pathForResource:name ofType:@"toolbar"]) == nil)
        {
        [self autorelease];
        return nil;
        }
    toolbarDefinition = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
    
    return self;
}



- (void)dealloc
{
    [name release];
    [toolbarDefinition release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSString *)name
{
    return name;
}


- (void)setTargetForActions:(id)anObject
{
    targetForActions = anObject;
}

- (id)targetForActions
{
    return targetForActions;
}


//---------------------------------------------------------------------------------------
//	CREATING TOOLBAR OBJECTS
//---------------------------------------------------------------------------------------

- (NSToolbar *)toolbar
{
    NSToolbar *toolbar;
    
    toolbar = [[[NSToolbar allocWithZone:[self zone]] initWithIdentifier:name] autorelease];
    if([[toolbarDefinition objectForKey:@"autosavesConfiguration"] boolValue])
        [toolbar setAutosavesConfiguration:YES];
    if([[toolbarDefinition objectForKey:@"allowsUserCustomization"] boolValue])
        [toolbar setAllowsUserCustomization:YES];
    return toolbar;    
}


- (NSArray *)defaultItemIdentifiers
{
    return [toolbarDefinition objectForKey:@"defaultItemIdentifiers"];
}


- (NSArray *)allowedItemIdentifiers
{
    return [toolbarDefinition objectForKey:@"allowedItemIdentifiers"];
}


- (NSToolbarItem *)itemWithIdentifier:(NSString *)identifier
{
    NSToolbarItem 	*item;
    NSDictionary	*definition;
    NSString		*value;
    
    definition = [[toolbarDefinition objectForKey:@"itemInfoByIdentifier"] objectForKey:identifier];
    item = [[[NSToolbarItem allocWithZone:[self zone]] initWithItemIdentifier:identifier] autorelease];

    if((value = [definition objectForKey:@"action"]) != nil)
        {
        [item setTarget:targetForActions];
        [item setAction:NSSelectorFromString(value)];
        }
    if((value = [definition objectForKey:@"imageName"]) != nil)
        [item setImage:[NSImage imageNamed:value]];
    if((value = [definition objectForKey:@"label"]) != nil)
        [item setLabel:value];
    if((value = [definition objectForKey:@"paletteLabel"]) != nil)
        [item setPaletteLabel:value];
    if((value = [definition objectForKey:@"toolTip"]) != nil)
        [item setToolTip:value];
        
    return item;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

#endif
