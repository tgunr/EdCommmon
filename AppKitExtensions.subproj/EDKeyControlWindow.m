//---------------------------------------------------------------------------------------
//  ALXReaderWindow.m created by erik on Sat 14-Aug-1999
//  @(#)$Id: EDKeyControlWindow.m,v 1.1 2002-04-02 08:43:36 erik Exp $
//
//  This file is part of the Alexandra Newsreader Project. ALX3000 and the supporting
//  ALX frameworks are free software; you can redistribute and/or modify them under
//  the terms of the GNU General Public License, version 2 as published by the Free
//  Software Foundation.
//---------------------------------------------------------------------------------------

#import <AppKit/AppKit.h>
#import "EDCommonDefines.h"
#import "NSApplication+Extensions.h"
#import "EDKeyControlWindow.h"

@interface EDKeyControlWindow(PrivateAPI)
- (void)_adjustPromptFieldOrigin;
- (void)_adjustPromptFieldSize;
- (void)_setCurrentKeyBindingDictionary:(NSDictionary *)dictionary;
- (void)_refViewFrameChanged:(NSNotification *)notification;
@end


//---------------------------------------------------------------------------------------
    @implementation EDKeyControlWindow
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (void)dealloc
{
    [DNC removeObserver:self]; // just in case the ref view stays around...
    [promptField release];
    [toplevelKeyBindingDictionary release];
}


//---------------------------------------------------------------------------------------
//	FURTHER INITIALISATION
//---------------------------------------------------------------------------------------

- (void)awakeFromNib
{
    NSString	*path, *fileContents;

    [promptField retain];
    
    path = [[[[NSApplication sharedApplication] libraryDirectory] stringByAppendingPathComponent:@"KeyBindings"] stringByAppendingPathExtension:@"dict"];
    if((fileContents = [NSString stringWithContentsOfFile:path]) == nil)
        {
        path = [[NSBundle mainBundle] pathForResource:@"KeyBindings" ofType:@"dict"];
        if((fileContents = [NSString stringWithContentsOfFile:path]) == nil)
            [NSException raise:NSGenericException format:@"Cannot read KeyBindings"];
        }

    NS_DURING
        toplevelKeyBindingDictionary = [[fileContents propertyList] retain];
        [self _setCurrentKeyBindingDictionary:toplevelKeyBindingDictionary];
    NS_HANDLER
        [NSException raise:NSGenericException format:@"Syntax error in KeyBindings"];
    NS_ENDHANDLER
}


//---------------------------------------------------------------------------------------
//	PRIVATE HELPER METHODS
//---------------------------------------------------------------------------------------

- (void)_adjustPromptFieldOrigin
{
    NSRect	rvFrame, pfFrame;

    NSAssert(referenceView != nil, @"do not invoke _adjustPromptFieldOrigin when no reference view is configured.");

    rvFrame = [referenceView frame];
    rvFrame = [[self contentView] convertRect:rvFrame fromView:[referenceView superview]];
    pfFrame = [promptField frame];
    pfFrame.origin.x = NSMaxX(rvFrame) - NSWidth(pfFrame) + 2;
    pfFrame.origin.y = NSMaxY(rvFrame) - NSHeight(pfFrame) + 1;
    [promptField setFrame:pfFrame];
}


- (void)_adjustPromptFieldSize
{
    NSRect oldFrame, newFrame;
    
    oldFrame = [promptField frame];
    [promptField sizeToFit];
    newFrame = [promptField frame];
    newFrame.origin.x -= newFrame.size.width - oldFrame.size.width;
    [promptField setFrame:newFrame];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)setReferenceView:(NSView *)aView
{
    if(referenceView != nil)
        {
        [DNC removeObserver:self name:NSViewFrameDidChangeNotification object:referenceView];
        referenceView = nil;
        }
    if(aView != nil)
        {
        referenceView = aView;
        [referenceView setPostsFrameChangedNotifications:YES];
        [DNC addObserver:self selector:@selector(_refViewFrameChanged:) name:NSViewFrameDidChangeNotification object:referenceView];
        [self _adjustPromptFieldOrigin];
        }
}


- (NSView *)referenceView
{
    return referenceView;
}


//---------------------------------------------------------------------------------------
//	PRIVATE ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)_setCurrentKeyBindingDictionary:(NSDictionary *)dictionary
{
    NSString *prompt;
    
    prompt = [dictionary objectForKey:@"prompt"];
    if((dictionary == toplevelKeyBindingDictionary) || (prompt == nil))
        {
        if([promptField superview] != nil)
            [promptField removeFromSuperview];
        }
    else
        {
        if([promptField superview] == nil)
            [[self contentView] addSubview:promptField];
        [promptField setStringValue:prompt];
        [self _adjustPromptFieldSize];
        }
    currentKeyBindingDictionary = dictionary;
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)keyDown:(NSEvent *)theEvent
{
    NSString		*keyStringRep;
    unsigned int	modifierFlags;
    id				entry;
    SEL				selector;

    keyStringRep = [theEvent charactersIgnoringModifiers];
    modifierFlags = [theEvent modifierFlags];
    if((modifierFlags & NSAlternateKeyMask) != 0)
        keyStringRep = [@"~" stringByAppendingString:keyStringRep];
    if((modifierFlags & NSControlKeyMask) != 0)
        keyStringRep = [@"^" stringByAppendingString:keyStringRep];

    if((entry = [currentKeyBindingDictionary objectForKey:keyStringRep]) != nil)
        {
        if([entry isKindOfClass:[NSDictionary class]])
            {
            [self _setCurrentKeyBindingDictionary:entry];
            }
        else if([entry isKindOfClass:[NSString class]])
            {
            if((selector = NSSelectorFromString(entry)) == NULL)
                [NSException raise:NSGenericException format:@"Invalid selector name in KeyBindings; found \"%@\"", entry];
            if([[NSApplication sharedApplication] sendAction:selector to:nil from:self] == NO)
                NSBeep();
            [self _setCurrentKeyBindingDictionary:toplevelKeyBindingDictionary];
            }
        else
            {
            [NSException raise:NSGenericException format:@"Syntax error in KeyBindings"];
            }
        }
    else
        {
        if(currentKeyBindingDictionary != toplevelKeyBindingDictionary)
            {
            [self _setCurrentKeyBindingDictionary:toplevelKeyBindingDictionary];
            NSBeep();
            }
        else
            {
            [super keyDown:theEvent];
            }
        }
}


//---------------------------------------------------------------------------------------
//	NOTIFICATIONS
//---------------------------------------------------------------------------------------

- (void)_refViewFrameChanged:(NSNotification *)notification
{
    [self _adjustPromptFieldOrigin];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
