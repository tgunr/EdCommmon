//---------------------------------------------------------------------------------------
//  NSAttributedString+Extensions.m created by erik on Tue 05-Oct-1999
//  @(#)$Id: NSAttributedString+AppKitExtensions.m,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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
#import "NSAttributedString+Extensions.h"
#import "NSAttributedString+AppKitExtensions.h"


//=======================================================================================
    @implementation NSAttributedString(EDAppKitExtensions)
//=======================================================================================

//---------------------------------------------------------------------------------------
//	CLASS ATTRIBUTES
//---------------------------------------------------------------------------------------

+ (NSColor *)defaultLinkColor
{
    return [NSColor colorWithCalibratedRed:0.1 green:0.1 blue:0.5 alpha:1.0];
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableAttributedString(EDAppKitExtensions)
//=======================================================================================

//---------------------------------------------------------------------------------------
//	APPENDING CONVENIENCE METHODS
//---------------------------------------------------------------------------------------

- (void)appendURL:(NSString *)aURL
{
    [self appendURL:aURL linkColor:[[self class] defaultLinkColor]];
}


- (void)appendURL:(NSString *)aURL linkColor:(NSColor *)linkColor
{
    NSRange	urlRange;

    urlRange.location = [self length];
    [self appendString:aURL];
    urlRange.length = [self length] - urlRange.location;
    [self addAttribute:NSLinkAttributeName value:aURL range:urlRange];
    [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:urlRange];
    if(linkColor != nil)
        [self addAttribute:NSForegroundColorAttributeName value:linkColor range:urlRange];
}


- (void)appendImage:(NSData *)data name:(NSString *)name
{
    NSFileWrapper	 	*wrapper;
    NSTextAttachment 	*attachment;
    NSAttributedString	*attchString;

    wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
    if(name != nil)
       [wrapper setPreferredFilename:name];
    // standard text attachment displays everything possible inline
    attachment = [[[NSTextAttachment alloc] initWithFileWrapper:wrapper] autorelease];
    attchString = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:attchString];
}


- (void)appendAttachment:(NSData *)data name:(NSString *)name
{
    NSFileWrapper		*wrapper;
    NSTextAttachment 	*attachment;
    NSCell			 	*cell;
    NSAttributedString	*attchString;

    wrapper = [[[NSFileWrapper alloc] initRegularFileWithContents:data] autorelease];
    if(name != nil)
        [wrapper setPreferredFilename:name];
    attachment = [[[NSTextAttachment alloc] initWithFileWrapper:wrapper] autorelease];
    cell = [attachment attachmentCell];
    NSAssert([cell isKindOfClass:[NSCell class]], @"AttachmentCell must inherit from NSCell.");
    [cell setImage:[[NSWorkspace sharedWorkspace] iconForFileType:[name pathExtension]]];
    attchString = [NSAttributedString attributedStringWithAttachment:attachment];
    [self appendAttributedString:attchString];
}


//---------------------------------------------------------------------------------------
//	URLIFIER
//---------------------------------------------------------------------------------------

- (void)urlify
{
    [self urlifyWithLinkColor:[[self class] defaultLinkColor] range:NSMakeRange(0, [self length])];
}


- (void)urlifyWithLinkColor:(NSColor *)linkColor
{
    [self urlifyWithLinkColor:linkColor range:NSMakeRange(0, [self length])];
}


- (void)urlifyWithLinkColor:(NSColor *)linkColor range:(NSRange)range
{
    static NSCharacterSet *colon = nil, *alpha, *urlstop;
    static NSString		  *scheme[] = { @"http", @"ftp", @"mailto", @"gopher", @"news", nil };
    static unsigned int   maxServLength = 6;
    NSString			  *string, *url;
    NSRange				  r, remainingRange, possSchemeRange, schemeRange, urlRange;
    unsigned int		  nextLocation, endLocation, i;

    if(colon == nil)
        {
        colon = [[NSCharacterSet characterSetWithCharactersInString:@":"] retain];
        alpha = [[NSCharacterSet alphanumericCharacterSet] retain];
        urlstop = [[NSCharacterSet characterSetWithCharactersInString:@"\"<>()[]',; \t\n\r"] retain];
        }

    string = [self string];
    nextLocation = range.location;
    endLocation = NSMaxRange(range);
    while(1)
        {
        remainingRange = NSMakeRange(nextLocation, endLocation - nextLocation);
        r = [string rangeOfCharacterFromSet:colon options:0 range:remainingRange];
        if(r.length == 0)
            break;
        nextLocation = NSMaxRange(r);

        if(r.location < maxServLength)
            possSchemeRange = NSMakeRange(0,  r.location);
        else
            possSchemeRange = NSMakeRange(r.location - 6,  6);
        // no need to clean up composed chars becasue they are not allowed in URLs anyway
        for(i = 0; scheme[i] != nil; i++)
            {
            schemeRange = [string rangeOfString:scheme[i] options:(NSBackwardsSearch|NSAnchoredSearch|NSLiteralSearch) range:possSchemeRange];
            if(schemeRange.length != 0)
                {
                r.length = endLocation - r.location;
                r = [string rangeOfCharacterFromSet:urlstop options:0 range:r];
                if(r.length == 0) // not found, assume URL extends to end of string
                    r.location = [string length];
                urlRange = NSMakeRange(schemeRange.location, r.location - schemeRange.location);
                if([string characterAtIndex:NSMaxRange(urlRange) - 1] == (unichar)'.')
                    urlRange.length -= 1;
                url = [string substringWithRange:urlRange];
                [self addAttribute:NSLinkAttributeName value:url range:urlRange];
                [self addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInt:NSSingleUnderlineStyle] range:urlRange];
                if(linkColor != nil)
                    [self addAttribute:NSForegroundColorAttributeName value:linkColor range:urlRange];
                nextLocation = urlRange.location + urlRange.length;
                break;
                }
            }
        }

}


//=======================================================================================
    @end
//=======================================================================================
