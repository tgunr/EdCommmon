//---------------------------------------------------------------------------------------
//  EDActivityIndicator.m created by erik on Tue 10-Nov-1998
//  @(#)$Id: EDActivityIndicator.m,v 1.4 2002-07-09 17:02:42 erik Exp $
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

#import <AppKit/AppKit.h>
#import "EDActivityIndicator.h"


//---------------------------------------------------------------------------------------
    @implementation EDActivityIndicator
//---------------------------------------------------------------------------------------

/*" An application displays an activity indicator to show that some lengthy task is underway. This task is happening in the background and does not prevent the user from interacting with the application. #EDActivityIndiciator uses an animation of two small arrows chasing each other, much like the ones in Mail and OmniWeb. The images used for the animation can be changed on a per-class basis by overriding the #animation class method. "*/


static NSImage *sharedImage = nil;


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    NSString *path;

    if(self != [EDActivityIndicator class])
        return;

    [self setVersion:3];

    if((path = [[NSBundle bundleForClass:self] pathForResource:@"arrows" ofType:@"tiff"]) != nil)
        sharedImage = [[NSImage alloc] initWithContentsOfFile:path];
    NSAssert(sharedImage != nil, @"cannot find image named 'arrows'");
}


/*" Returns all frames of the animation in one NSImage. Frames are assumed to be squares and arranged in a row from left to right. Consequently, if the size of the frames is %s x %s and the animation contains %n frames the image must be %s x (%s * %n) in size.

This method must be efficient as it is called frequently. "*/

+ (NSImage *)animation
{
    return sharedImage;
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- initWithFrame:(NSRect)frame
{
    [super initWithFrame:frame];
    bgColor = [[NSColor controlBackgroundColor] retain];
    flags.frameRate = 20;
    return self;
}


- (void)dealloc
{
    [self stopAnimation:self];
    [bgColor release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeObject:bgColor];
    [encoder encodeValueOfObjCType:@encode(int) at:&flags];
    [encoder encodeObject:target];
    [encoder encodeValueOfObjCType:@encode(SEL) at:&action];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super initWithCoder:decoder];
    version = [decoder versionForClassName:@"EDActivityIndicator"];
    // Version is -1 when loading a NIB file in which we were set as a custom subclass.
    // The unsigned representation of this is INT_MAX on a 2-bytes-complement machine...
    if(version == INT_MAX)
        {
        bgColor = [[NSColor controlBackgroundColor] retain];
        }
    else if(version == 1)
        {
        BOOL	tmp;
        bgColor = [[decoder decodeObject] copyWithZone:[self zone]];
        [decoder decodeValueOfObjCType:@encode(BOOL) at:&tmp];
        flags.drawsBackground = tmp;
        flags.frameRate = 20;
        }
    else
        {
        bgColor = [[decoder decodeObject] copyWithZone:[self zone]];
        [decoder decodeValueOfObjCType:@encode(int) at:&flags];
        flags.frameRate = 20;
        if(version >= 3)
            {
            target = [decoder decodeObject];
            [decoder decodeValueOfObjCType:@encode(SEL) at:&action];
            }
        }

    return self;
}


//---------------------------------------------------------------------------------------
//	AWAKE FROM NIB
//---------------------------------------------------------------------------------------

- (void)awakeFromNib
{
    if(flags.hidesOnLoad)
        flags.isHidden = YES;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Sets the receiver's target object to anObject. "*/

- (void)setTarget:(id)anObject
{
    target = anObject;
}


/*" Returns the receiver's target object. "*/

- (id)target
{
    return target;
}


/*" Sets the selector used for the action message to aSelector. "*/

- (void)setAction:(SEL)aSelector
{
    action = aSelector;
}


/*" Returns the receiver's action-message selector. "*/

- (SEL)action
{
    return action;
}


/*" Sets the receiver's background color to %aColor. "*/

- (void)setBackgroundColor:(NSColor *)aColor
{
    id old = bgColor;
    bgColor = [aColor copyWithZone:[self zone]];
    [old release];
    [self setNeedsDisplay:YES];
}


/*" Returns the receiver's background color. "*/

- (NSColor *)backgroundColor
{
    return bgColor;
}


/*" Controls whether the receiver draws its background. If flag is YES, the receiver fills its background with the background color; if flag is NO, it doesn't. "*/

- (void)setDrawsBackground:(BOOL)flag
{
    flags.drawsBackground = flag;
    [self setNeedsDisplay:YES];
}


/*" Returns YES if the receiver draws its background, NO if it doesn't. "*/

- (BOOL)drawsBackground
{
    return flags.drawsBackground;
}


/*" Controls whether the receiver automatically hides when the NIB file is loaded. This is used so that the receiver can be visible for editing in Interface Builder but hidden when loaded into the applicaton."*/

- (void)setHidesOnLoad:(BOOL)flag
{
    flags.hidesOnLoad = flag;
}


/*" Returns YES if the receiver automatically hides when the NIB file is loaded. "*/

- (BOOL)hidesOnLoad
{
    return flags.hidesOnLoad;
}


/*" Controls whether the receiver is hidden when the animation is not running. The default is YES. "*/

- (void)setIsHidden:(BOOL)flag
{
    flags.isHidden = flag;
    [self setNeedsDisplay:YES];
}


/*" Returns YES if the receiver is hidden when the animation is not running. "*/

- (BOOL)isHidden
{
    return flags.isHidden;
}


/*" Sets the frame rate for the animation. Frames are changed %value times per second whith 255 being the theoretical maximum. The default is 20. "*/

- (void)setFrameRate:(unsigned int)value
{
    NSParameterAssert(value < 256);
    if(value != flags.frameRate)
        {
        flags.frameRate = value;
        if(animationTimer != nil)
            {
            [self stopAnimation:self];
            [self startAnimation:self];
            }
        }
}

/*" Returns the current frame rate for the animation. "*/

- (unsigned int)frameRate
{
    return flags.frameRate;
}


/*" If the receiver's highlight status is different from flag, sets that status to flag and, if flag is YES, highlights the the receiver by drawing multiple slightly faded copies of the current frame's image around the image. "*/

- (void)highlight:(BOOL)flag
{
    if(flag != flags.isHighlighted)
        {
        flags.isHighlighted = flag;
        [self display];
        }
}


//---------------------------------------------------------------------------------------
// VIEW ATTRIBUTES
//---------------------------------------------------------------------------------------

- (BOOL)isOpaque
{
    return flags.drawsBackground;
}


//---------------------------------------------------------------------------------------
//	DRAWING
//---------------------------------------------------------------------------------------

- (void)drawRect:(NSRect)rect
{
    NSImage	*animation;
    NSRect	sourceFrame;
    
    if(flags.drawsBackground == YES)
        {
        [bgColor set];
        NSRectFill(rect);
        }
    if(flags.isHidden == NO)
        {
        animation = [[self class] animation];
        sourceFrame = NSMakeRect(xpos, 0, [animation size].height, [animation size].height);
        if(flags.isHighlighted)
            {
            [animation dissolveToPoint:NSMakePoint( 0, 1) fromRect:sourceFrame fraction:0.2];
            [animation dissolveToPoint:NSMakePoint( 1, 0) fromRect:sourceFrame fraction:0.2];
            [animation dissolveToPoint:NSMakePoint( 0,-1) fromRect:sourceFrame fraction:0.2];
            [animation dissolveToPoint:NSMakePoint(-1, 0) fromRect:sourceFrame fraction:0.2];
            }
        [animation compositeToPoint:NSZeroPoint fromRect:sourceFrame operation:NSCompositeSourceOver];
        }
}


//---------------------------------------------------------------------------------------
//	EVENT HANDLING
//---------------------------------------------------------------------------------------

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
    return YES;
}


- (void)mouseDown:(NSEvent *)theEvent
{
    BOOL isInside;

    if(target == nil)
        return;
    
    [self highlight:YES];
    while([theEvent type] != NSLeftMouseUp)
        {
        theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask | NSLeftMouseDraggedMask];
        isInside = [self mouse:[self convertPoint:[theEvent locationInWindow] fromView:nil] inRect:[self bounds]];

        switch([theEvent type])
            {
        case NSLeftMouseDragged:
            [self highlight:isInside];
            break;
        case NSLeftMouseUp:
            if(isInside)
                [target performSelector:action withObject:self];
            [self highlight:NO];
            break;
        default:
            break;
            }
        }
}


//---------------------------------------------------------------------------------------
//	ANIMATION
//---------------------------------------------------------------------------------------

/*" Advances the animation by one step. This method is normally called automatically by the animation timer. "*/

- (void)step:(id)sender
{
    NSSize animationSize = [[[self class] animation] size];
    xpos = fmod(xpos + animationSize.height, animationSize.width);
    [self setNeedsDisplay:YES];
}


/*" Starts the animation by setting up a timer that sends #{step:} methods in the specified frequency. Note that this means that the "lengty task" can't run in the main application thread as this would block the run loop. "*/

- (void)startAnimation:(id)sender
{
    if(animationTimer != nil)
        return;
    flags.wasHiddenOnStart = flags.isHidden;
    flags.isHidden = NO;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / (double)(flags.frameRate) target:self selector:@selector(step:) userInfo:nil repeats:YES];
}


/*" Stops the animation. Multiple #{start:} invocations do %not need to be balanced by an equivalent amount of #{stop:} invocations. "*/

- (void)stopAnimation:(id)sender
{
    if(animationTimer == nil)
        return;
    [animationTimer invalidate];
    animationTimer = nil;
    flags.isHidden = flags.wasHiddenOnStart;
    [self setNeedsDisplay:YES];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
