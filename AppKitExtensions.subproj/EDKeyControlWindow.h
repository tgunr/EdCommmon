//---------------------------------------------------------------------------------------
//  ALXReaderWindow.h created by erik on Sat 14-Aug-1999
//  @(#)$Id: EDKeyControlWindow.h,v 1.1 2002-04-02 08:43:35 erik Exp $
//
//  This file is part of the Alexandra Newsreader Project. ALX3000 and the supporting
//  ALX frameworks are free software; you can redistribute and/or modify them under
//  the terms of the GNU General Public License, version 2 as published by the Free
//  Software Foundation.
//---------------------------------------------------------------------------------------

#import <AppKit/NSWindow.h>

@interface EDKeyControlWindow : NSWindow
{
    NSDictionary	*toplevelKeyBindingDictionary;
    NSDictionary	*currentKeyBindingDictionary;

    IBOutlet NSTextField	*promptField;
    IBOutlet NSView			*referenceView;
}

- (void)setReferenceView:(NSView *)aView;
- (NSView *)referenceView;

@end
