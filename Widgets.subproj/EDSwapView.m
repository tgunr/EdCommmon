//---------------------------------------------------------------------------------------
//  EDSwapView.m created by erik
//  @(#)$Id: EDSwapView.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
//
//  Copyright (c) 1997-1998 by Erik Doernenburg. All rights reserved.
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
#import "EDSwapView.h"

@interface EDSwapView(PrivateAPI)
- (void)_setViewVar:(NSView **)viewVar toView:(NSView *)aView;
@end


//---------------------------------------------------------------------------------------
    @implementation EDSwapView
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    [self setVersion:1];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithFrame:(NSRect)frameRect
{
    [super initWithFrame:frameRect];

    views = [[NSMutableSet allocWithZone:[self zone]] init];
    visibleViews = [[NSMutableSet allocWithZone:[self zone]] init];

    return self;
}


- (void)dealloc
{
    [views release];
    [visibleViews release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];

    [encoder encodeObject:views];
    [encoder encodeObject:visibleViews];
    [encoder encodeValueOfObjCType:@encode(int) at:&flags];
    [encoder encodeObject:delegate];

    [encoder encodeObject:view0];
    [encoder encodeObject:view1];
    [encoder encodeObject:view2];
    [encoder encodeObject:view3];
    [encoder encodeObject:view4];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super initWithCoder:decoder];
    version = [decoder versionForClassName:@"EDSwapView"];
    // Version is -1 when loading a NIB file in which we were set as a custom subclass.
    // The unsigned representation of this is INT_MAX on a 2-bytes-complement machine...
    if(version == INT_MAX)
        {
        views = [[NSMutableSet allocWithZone:[self zone]] init];
        visibleViews = [[NSMutableSet allocWithZone:[self zone]] init];
        }
    else
        {
        views = [[decoder decodeObject] retain];
        visibleViews = [[decoder decodeObject] retain];
        [decoder decodeValueOfObjCType:@encode(int) at:&flags];
        delegate = [[decoder decodeObject] retain];

        view0 = [[decoder decodeObject] retain];
        view1 = [[decoder decodeObject] retain];
        view2 = [[decoder decodeObject] retain];
        view3 = [[decoder decodeObject] retain];
        view4 = [[decoder decodeObject] retain];
        }

    return self;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)setView0:(NSView *)aView
{
    [self _setViewVar:&view0 toView:aView];
}

- (NSView *)view0
{
    return view0;
}

- (void)setView1:(NSView *)aView
{
    [self _setViewVar:&view1 toView:aView];
}

- (NSView *)view1
{
    return view1;
}

- (void)setView2:(NSView *)aView
{
    [self _setViewVar:&view2 toView:aView];
}

- (NSView *)view2
{
    return view2;
}

- (void)setView3:(NSView *)aView
{
    [self _setViewVar:&view3 toView:aView];
}

- (NSView *)view3
{
    return view3;
}

- (void)setView4:(NSView *)aView
{
    [self _setViewVar:&view4 toView:aView];
}

- (NSView *)view4
{
    return view4;
}


- (void)_setViewVar:(NSView **)viewVar toView:(NSView *)aView
{
    if(*viewVar != nil)
        {
        [self removeView:*viewVar];
        }
    if([aView isKindOfClass:[NSBox class]])
        {
        NSBox *box = (NSBox *)aView;
        aView = [box contentView];
        [aView setAutoresizingMask:[box autoresizingMask]];
        }
    *viewVar = aView;
    [self addView:aView];
}


- (void)setDelegate:(id)anObject
{
    delegate = anObject;
    flags.delegateWantsSwapinNotif = NO;
    flags.delegateWantsSwapoutNotif = NO;
    if(delegate != nil)
        {
        if([delegate respondsToSelector:@selector(swapView:didSwapinView:)])
            flags.delegateWantsSwapinNotif = YES;
        if([delegate respondsToSelector:@selector(swapView:didSwapoutView:)])
            flags.delegateWantsSwapoutNotif = YES;
        }
 }


- (id)delegate
{
    return delegate;
}


//---------------------------------------------------------------------------------------
//	ADDING AND REMOVING VIEWS
//---------------------------------------------------------------------------------------

- (void)addView:(NSView *)view
{
    [self addView:view atPoint:NSZeroPoint];
}


- (void)addView:(NSView *)view atPoint:(NSPoint)point
{
    if([views containsObject:view])
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to add view <%@ 0x%x> more than once.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [view class], view];
    [views addObject:view];
    [view setFrameOrigin:point];
    [view removeFromSuperview];
}


- (void)removeView:(NSView *)view
{
    if([views containsObject:view] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to remove unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [view class], view];
    if([self isShowingView:view])
        [self hideView:view];
    [views removeObject:view];
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- (void)resizeSubviewsWithOldSize:(NSSize)oldFrameSize
{
   NSMutableSet *invisibleViews;
   NSEnumerator *viewEnum;
   NSView		 *view;

   invisibleViews = [[views mutableCopy] autorelease];
   [invisibleViews minusSet:visibleViews];

   viewEnum = [invisibleViews objectEnumerator];
   while((view = [viewEnum nextObject]) != nil)
       [self addSubview:view];

   [super resizeSubviewsWithOldSize:oldFrameSize];

   viewEnum = [invisibleViews objectEnumerator];
   while((view = [viewEnum nextObject]) != nil)
       [view removeFromSuperview];
}


- (void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if([visibleViews count] == 0)
        {
        [[NSColor colorWithCalibratedWhite:0.5 alpha:0.5] set];
        [NSBezierPath fillRect:[self bounds]];
        }
}


//---------------------------------------------------------------------------------------
//	ACTIONS: SHOW AND HIDE INDIVIDUAL VIEWS
//---------------------------------------------------------------------------------------

- (void)showView:(NSView *)view
{
    if([views containsObject:view] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to show unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [view class], view];

    if([visibleViews containsObject:view])
        return;

    [[self window] disableFlushWindow];

    [self addSubview:view];
    [visibleViews addObject:view];
    [view display];
    
    if(flags.delegateWantsSwapinNotif)
        [delegate swapView:self didSwapinView:view];

    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


- (void)hideView:(NSView *)view
{
    if([views containsObject:view] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to hide unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [view class], view];

    if([visibleViews containsObject:view] == NO)
        return;

    if(flags.delegateWantsSwapoutNotif)
        [delegate swapView:self willSwapoutView:view];
    
    [[self window] disableFlushWindow];
    [view removeFromSuperview];
    [visibleViews removeObject:view];
    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


//---------------------------------------------------------------------------------------
//	ACTIONS: SHOW AND HIDE ALL VIEWS
//---------------------------------------------------------------------------------------

- (void)switchToView:(NSView *)view
{
    NSView 	*visView;
    BOOL	wasVisible = NO;
    
    if([views containsObject:view] == NO)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to switch to unknown view <%@ 0x%x>.", NSStringFromClass(isa), NSStringFromSelector(_cmd), [view class], view];

    if([visibleViews containsObject:view])
        {
        if([visibleViews count] == 1)
           return;
        wasVisible = YES;
        [visibleViews removeObject:view];
        }	

    [[self window] disableFlushWindow];
    while((visView = [visibleViews anyObject]) != nil)
        [self hideView:visView];
    if(wasVisible == YES)
        [visibleViews addObject:view];
    else
        [self showView:view];
    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


- (void)hideAllViews
{
    NSView *visView;

    [[self window] disableFlushWindow];
    while((visView = [visibleViews anyObject]) != nil)
        [self hideView:visView];
    [[self window] enableFlushWindow];
    [[self window] flushWindowIfNeeded];
}


//---------------------------------------------------------------------------------------
//	ACTIONS: SHOW VIEWS BY NUMBER
//---------------------------------------------------------------------------------------

- (void)switchToViewNumber:(int)viewnum
{
   switch(viewnum)
       {
   case 0: [self switchToView:view0]; break;
   case 1: [self switchToView:view1]; break;
   case 2: [self switchToView:view2]; break;
   case 3: [self switchToView:view3]; break;
   case 4: [self switchToView:view4]; break;
   default:
       [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to switch to invalid view #%d.", NSStringFromClass(isa), NSStringFromSelector(_cmd), viewnum];
       }
}


- (void)takeViewNumber:(id)sender
{
   int viewnum;

   if([sender isKindOfClass:[NSPopUpButton class]])
       viewnum = [[sender selectedItem] tag];
   else if([sender isKindOfClass:[NSButton class]])
       viewnum = ([sender state] == NSOnState) ? 1 : 0;
   else if([sender isKindOfClass:[NSMatrix class]])
       viewnum = [[sender selectedCell] tag];
   else
       viewnum = [sender tag];

   [self switchToViewNumber:viewnum];
}


//---------------------------------------------------------------------------------------
//	QUERIES
//---------------------------------------------------------------------------------------

- (BOOL)isShowingView:(NSView *)view
{
    return [visibleViews containsObject:view];
}

- (NSArray *)visibleViews
{
    return [visibleViews allObjects];
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
