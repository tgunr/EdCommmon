//---------------------------------------------------------------------------------------
//  EDActivityIndicator.m created by erik on Tue 10-Nov-1998
//  @(#)$Id: EDActivityIndicator.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
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

static NSImage *sharedImage = nil;
static float frameWidth;


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    NSString *path;

    if(self != [EDActivityIndicator class])
        return;

    [self setVersion:2];

    if((path = [[NSBundle bundleForClass:self] pathForResource:@"arrows" ofType:@"tiff"]) != nil)
        sharedImage = [[NSImage alloc] initWithContentsOfFile:path];
    NSAssert(sharedImage != nil, @"cannot find image named 'arrows'");
    frameWidth = [sharedImage size].height;
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

- (void)setBackgroundColor:(NSColor *)aColor
{
    id old = bgColor;
    bgColor = [aColor copyWithZone:[self zone]];
    [old release];
    [self setNeedsDisplay:YES];
}

- (NSColor *)backgroundColor
{
    return bgColor;
}


- (void)setDrawsBackground:(BOOL)flag
{
    flags.drawsBackground = flag;
    [self setNeedsDisplay:YES];
}

- (BOOL)drawsBackground
{
    return flags.drawsBackground;
}


- (void)setHidesOnLoad:(BOOL)flag
{
    flags.hidesOnLoad = flag;
}

- (BOOL)hidesOnLoad
{
    return flags.hidesOnLoad;
}


- (void)setIsHidden:(BOOL)flag
{
    flags.isHidden = flag;
    [self setNeedsDisplay:YES];
}

- (BOOL)isHidden
{
    return flags.isHidden;
}


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

- (unsigned int)frameRate
{
    return flags.frameRate;
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
    if(flags.drawsBackground == YES)
        {
        [bgColor set];
        NSRectFill(rect);
        }
    if(flags.isHidden == NO)
        {
        [sharedImage compositeToPoint:NSZeroPoint fromRect:NSMakeRect(xpos, 0, frameWidth, [sharedImage size].height) operation:NSCompositeSourceOver];
        }
}


//---------------------------------------------------------------------------------------
//	ANIMATION
//---------------------------------------------------------------------------------------

- (void)step:(id)sender
{
    xpos = fmod(xpos + frameWidth, [sharedImage size].width);
    [self setNeedsDisplay:YES];
}


- (void)startAnimation:(id)sender
{
    if(animationTimer != nil)
        return;
    flags.wasHiddenOnStart = flags.isHidden;
    flags.isHidden = NO;
    animationTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 / (double)(flags.frameRate) target:self selector:@selector(step:) userInfo:nil repeats:YES];
}


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
