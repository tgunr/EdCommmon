//---------------------------------------------------------------------------------------
//  EDActivityIndicator.h created by erik on Tue 10-Nov-1998
//  @(#)$Id: EDActivityIndicator.h,v 2.0 2002-08-16 18:12:49 erik Exp $
//
//  Copyright (c) 1998-1999 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDActivityIndicator_h_INCLUDE
#define	__EDActivityIndicator_h_INCLUDE


#import <AppKit/AppKit.h>


struct EDAIFlags
{
#ifdef BIG_ENDIAN
    unsigned drawsBackground:1;
    unsigned hidesOnLoad:1;
    unsigned isHidden:1;
    unsigned wasHiddenOnStart:1;
    unsigned frameRate:8;
    unsigned isHighlighted:1;
    unsigned padding:19;
#else
    unsigned padding:19;
    unsigned isHighlighted:1;
    unsigned frameRate:8;
    unsigned wasHiddenOnStart:1;
    unsigned isHidden:1;
    unsigned hidesOnLoad:1;
    unsigned drawsBackground:1;
#endif
};



@interface EDActivityIndicator : NSView
{
    struct EDAIFlags flags;				/*" All instance variables are private. "*/
    NSColor			 *bgColor;			/*" "*/
    id				 target;			/*" "*/
    SEL				 action;			/*" "*/

    float			 xpos;    			/*" "*/
    NSTimer			 *animationTimer;	/*" "*/
}

/*" Animation image "*/
+ (NSImage *)animation;

/*" Changing the indicator's appearance "*/
- (void)setBackgroundColor:(NSColor *)aColor;
- (NSColor *)backgroundColor;
- (void)setDrawsBackground:(BOOL)flag;
- (BOOL)drawsBackground;

/*" Setting and getting the indicator's attributes "*/
- (void)setHidesOnLoad:(BOOL)flag;
- (BOOL)hidesOnLoad;
- (void)setIsHidden:(BOOL)flag;
- (BOOL)isHidden;
- (void)setFrameRate:(unsigned int)value;
- (unsigned int)frameRate;

/*" Setting target and action "*/
- (void)setTarget:(id)anObject;
- (id)target;
- (void)setAction:(SEL)aSelector;
- (SEL)action;

/*" Managing the animation "*/
- (IBAction)step:(id)sender;
- (IBAction)startAnimation:(id)sender;
- (IBAction)stopAnimation:(id)sender;

/*" Drawing and highlighting the activity indicator "*/
- (void)highlight:(BOOL)flag;

@end

#endif	/* __EDActivityIndicator_h_INCLUDE */
