//---------------------------------------------------------------------------------------
//  NSString+printf.m created by erik on Sat 27-Sep-1997
//  @(#)$Id: NSString+Extensions.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
//
//  Copyright (c) 1997-2000 by Erik Doernenburg. All rights reserved.
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

#import <Foundation/Foundation.h>
#import "NSString+Extensions.h"

//---------------------------------------------------------------------------------------
    @implementation NSString(EDExtensions)
//---------------------------------------------------------------------------------------

static NSFileHandle *stdoutFileHandle = nil;
static NSLock *printfLock = nil;
static NSCharacterSet *iwsSet = nil;


//---------------------------------------------------------------------------------------
//	CONVENIENCE CONSTRUCTORS
//---------------------------------------------------------------------------------------

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
}


//---------------------------------------------------------------------------------------
//	VARIOUS EXTENSIONS
//---------------------------------------------------------------------------------------

- (NSString *)stringByRemovingSurroundingWhitespace
{
    NSRange				  start, end, result;

    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    start = [self rangeOfCharacterFromSet:iwsSet];
    if(start.length == 0)
        return @""; // string is empty or consists of whitespace only

    end = [self rangeOfCharacterFromSet:iwsSet options:NSBackwardsSearch];
    if((start.location == 0) && (end.location == [self length] - 1))
        return self;

    result = NSMakeRange(start.location, end.location + end.length - start.location);

    return [self substringWithRange:result];	
}


- (BOOL)isWhitespace
{
    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    return ([self rangeOfCharacterFromSet:iwsSet].length == 0);

}


- (BOOL)hasPrefixCaseInsensitive:(NSString *)string
{
    return (([string length] <= [self length]) && ([self compare:string options:(NSCaseInsensitiveSearch|NSAnchoredSearch) range:NSMakeRange(0, [string length])] == NSOrderedSame));
}


- (BOOL)boolValue
{
    if([self intValue] > 0)
        return YES;
    return [self caseInsensitiveCompare:@"yes"] == NSOrderedSame;
}


- (unsigned int)intValueForHex
{
    unsigned int	value;

    if([[NSScanner scannerWithString:self] scanHexInt:&value] == NO)
        return 0;
    return value;
}


- (BOOL)isEmpty
{
  return [self isEqualToString:@""];
}

//---------------------------------------------------------------------------------------
//	PRINTING
//---------------------------------------------------------------------------------------

+ (void)printf:(NSString *)format, ...
{
    va_list   	args;
    NSString	*buffer;

    va_start(args, format);
    buffer = [[NSString alloc] initWithFormat:format arguments:args];
    [buffer printf];
    [buffer release];
    va_end(args);
}


+ (void)fprintf:(NSFileHandle *)fileHandle:(NSString *)format, ...
{
    va_list   	args;
    NSString	*buffer;

    va_start(args, format);
    buffer = [[NSString alloc] initWithFormat:format arguments:args];
    [buffer fprintf:fileHandle];
    [buffer release];
    va_end(args);
}


- (void)printf
{
    if(printfLock == nil)
        printfLock = [[NSLock alloc] init];

    [printfLock lock];
    if(stdoutFileHandle == nil)
        stdoutFileHandle = [[NSFileHandle fileHandleWithStandardOutput] retain];
    [stdoutFileHandle writeData:[self dataUsingEncoding:[NSString defaultCStringEncoding]]];
    [printfLock unlock];
}


- (void)fprintf:(NSFileHandle *)fileHandle
{
    if(printfLock == nil)
        printfLock = [[NSLock alloc] init];

    [printfLock lock];
    [fileHandle writeData:[self dataUsingEncoding:[NSString defaultCStringEncoding]]];
    [printfLock unlock];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
