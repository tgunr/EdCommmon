//---------------------------------------------------------------------------------------
//  EDSwapView.h created by erik
//  @(#)$Id: EDSwapView.h,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
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

#import <AppKit/NSView.h>

struct EDSVFlags
{
#ifdef __BIG_ENDIAN__
    unsigned delegateWantsSwapinNotif:1;
    unsigned delegateWantsSwapoutNotif:1;
    unsigned padding:30;
#else
    unsigned padding:30;
    unsigned delegateWantsSwapoutNotif:1;
    unsigned delegateWantsSwapinNotif:1;
#endif
};


@interface EDSwapView : NSView
{
    NSMutableSet		*views;
    NSMutableSet		*visibleViews;
    struct EDSVFlags   	flags;
    id					delegate;

    IBOutlet NSView 	*view0;
    IBOutlet NSView		*view1;
    IBOutlet NSView		*view2;
    IBOutlet NSView		*view3;
    IBOutlet NSView		*view4;
}


- (void)setView0:(NSView *)aView;
- (NSView *)view0;
- (void)setView1:(NSView *)aView;
- (NSView *)view1;
- (void)setView2:(NSView *)aView;
- (NSView *)view2;
- (void)setView3:(NSView *)aView;
- (NSView *)view3;
- (void)setView4:(NSView *)aView;
- (NSView *)view4;

- (void)setDelegate:(id)anObject;
- (id)delegate;

- (void)addView:(NSView *)view;
- (void)addView:(NSView *)view atPoint:(NSPoint)point;
- (void)removeView:(NSView *)view;

- (void)showView:(NSView *)view;
- (void)hideView:(NSView *)view;

- (void)switchToView:(NSView *)view;
- (void)hideAllViews;

- (void)switchToViewNumber:(int)number;
- (IBAction)takeViewNumber:(id)sender;

- (BOOL)isShowingView:(NSView *)view;
- (NSArray *)visibleViews;

@end


@interface NSObject(EDSwapViewDelegateInformalProtocol)
- (void)swapView:(EDSwapView *)swapView didSwapinView:(NSView *)view;
- (void)swapView:(EDSwapView *)swapView willSwapoutView:(NSView *)view;
@end
