//---------------------------------------------------------------------------------------
//  NSString+printf.m created by erik on Sat 27-Sep-1997
//  @(#)$Id: NSString+Extensions.m,v 1.7 2002-07-09 15:53:52 erik Exp $
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

#ifndef EDCOMMON_WOBUILD
#import <AppKit/AppKit.h>
#endif
#import <Foundation/Foundation.h>
#import "NSString+Extensions.h"

#ifndef WIN32
#import <unistd.h>
#else
#define random() rand()
#endif


//=======================================================================================
    @implementation NSString(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSString. "*/

static NSFileHandle *stdoutFileHandle = nil;
static NSLock *printfLock = nil;
static NSCharacterSet *iwsSet = nil;


//---------------------------------------------------------------------------------------
//	CONVENIENCE CONSTRUCTORS
//---------------------------------------------------------------------------------------

/*" Convenience factory method. "*/

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding
{
    return [[[NSString alloc] initWithData:data encoding:encoding] autorelease];
}


//---------------------------------------------------------------------------------------
//	VARIOUS EXTENSIONS
//---------------------------------------------------------------------------------------

/*" Returns a copy of the receiver with all whitespace left of the first non-whitespace character and right of the last whitespace character removed. "*/

- (NSString *)stringByRemovingSurroundingWhitespace
{
    NSRange		start, end, result;

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


/*" Returns YES if the receiver consists of whitespace only. "*/

- (BOOL)isWhitespace
{
    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    return ([self rangeOfCharacterFromSet:iwsSet].length == 0);

}


/*" Returns a copy of the receiver with all whitespace removed. "*/

- (NSString *)stringByRemovingWhitespace
{
    return [self stringByRemovingCharactersFromSet:[NSCharacterSet whitespaceCharacterSet]];
}


/*" Returns a copy of the receiver with all characters from %set removed. "*/

- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set
{
    NSMutableString	*temp;

    if([self rangeOfCharacterFromSet:set options:NSLiteralSearch].length == 0)
        return self;
    temp = [[self mutableCopyWithZone:[self zone]] autorelease];
    [temp removeCharactersInSet:set];

    return temp;
}


#ifndef EDCOMMON_WOBUILD

/*" Returns a string that is not wider than %maxWidths pixels. "*/

- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forFont:(NSFont *)font
{
    return [self stringByAbbreviatingPathToWidth:maxWidth forAttributes:[NSDictionary dictionaryWithObject:font forKey:NSFontAttributeName]];
}

/*" Returns a string that is not wider than %maxWidths pixels. "*/

- (NSString *)stringByAbbreviatingPathToWidth:(float)maxWidth forAttributes:(NSDictionary *)attributes
{
    NSString		*result;
    NSMutableArray	*components;
    int 			i;

    if([self sizeWithAttributes:attributes].width <= maxWidth)
        return self;

    result = [self stringByAbbreviatingWithTildeInPath];
    if([result sizeWithAttributes:attributes].width <= maxWidth)
        return result;

    components = [[[result pathComponents] mutableCopy] autorelease];
    if([[components objectAtIndex:0] isEqualToString:@"/"])
        [components removeObjectAtIndex:0];
    if([components count] < 2)
        return nil;
    [components replaceObjectAtIndex:0 withObject:@"..."];

    for(i = 1; i < [components count] - 1; i++)
        {
        [components removeObjectAtIndex:i];
        result = [NSString pathWithComponents:components];
        if([result sizeWithAttributes:attributes].width <= maxWidth)
            return result;
        }

    return nil;
}

#endif


/*" Returns YES if the receiver's prefix is equal to %string, comparing case insensitive. "*/

- (BOOL)hasPrefixCaseInsensitive:(NSString *)string
{
    return (([string length] <= [self length]) && ([self compare:string options:(NSCaseInsensitiveSearch|NSAnchoredSearch) range:NSMakeRange(0, [string length])] == NSOrderedSame));
}


/*" Returns YES if the receiver is equal to string "yes", comparing case insensitive. "*/

- (BOOL)boolValue
{
    if([self intValue] > 0)
        return YES;
    return [self caseInsensitiveCompare:@"yes"] == NSOrderedSame;
}


/*" Assumes the string contains an integer written in hexadecimal notation and returns its value. Uses #scanHexInt in #NSScanner. "*/

- (unsigned int)intValueForHex
{
    unsigned int	value;

    if([[NSScanner scannerWithString:self] scanHexInt:&value] == NO)
        return 0;
    return value;
}


/*" Returns yes if the string contains no text characters. Note that its length can still be non-zero. "*/

- (BOOL)isEmpty
{
  return [self isEqualToString:@""];
}


#ifndef WIN32 // [TRH 2001/01/18] quick hack: disabled since Windows does not have crypt() -- not needed for EDInternet anyway.
//---------------------------------------------------------------------------------------
//	CRYPTING
//---------------------------------------------------------------------------------------

/*" Returns an encrypted version of the receiver using a random "salt."

This method is thread-safe.

Note: This method is not available on Windows NT platforms. "*/

- (NSString *)encryptedString
{
    char 	salt[3];

    salt[0] = 'A' + random() % 26;
    salt[1] = 'A' + random() % 26;
    salt[2] = '\0';

    return [self encryptedStringWithSalt:salt];
}


/*" Returns an encrypted version of the receiver using %salt as randomizer. %Salt must be a C String containing excatly two characters.

This method is thread-safe.

Note: This method is not available on Windows NT platforms. "*/

- (NSString *)encryptedStringWithSalt:(const char *)salt
{
    static NSLock	*encryptLock = nil;
    NSMutableData 	*sdata;
    char 			*encryptedCString;
    NSString 		*encryptedString;
    char 			terminator = '\0';

    NSParameterAssert((salt != NULL) && (strlen(salt) == 2));

    if(encryptLock == nil)
        encryptLock = [[NSLock alloc] init]; // intentional leak

    sdata = [[self dataUsingEncoding:NSNonLossyASCIIStringEncoding] mutableCopy];
    [sdata appendBytes:&terminator length:1];

    [encryptLock lock];
    encryptedCString = crypt((const char *)[sdata bytes], (const char *)salt);
    encryptedString = [[[NSString allocWithZone:[self zone]] initWithCString:encryptedCString] autorelease];
    [encryptLock unlock];

    [sdata release];
    
    return encryptedString;
}


/*" Returns YES if the receiver is a encryption of %aString. Assume you have the encrypted password in !{pwd} and the user's input in !{input}. Call !{[pwd isValidEncryptionOfString:input]} to verify the passwrd.

This method is thread-safe.

Note: This method is not available on Windows NT platforms. "*/

- (BOOL)isValidEncryptionOfString:(NSString *)aString
{
  char salt[3];

  [self getCString:salt maxLength:2];
  salt[2] = '\0';
  return [self isEqualToString:[aString encryptedStringWithSalt:salt]];
}
#endif // !defined(WIN32)

//---------------------------------------------------------------------------------------
//	SHARING STRING INSTANCES (USE WITH CAUTION!)
//---------------------------------------------------------------------------------------

/*" Maintains a global pool of string instances. Returns the instance stored in the pool or adds the receiver if no such string was in the pool before. This can be used to allow for equality tests using #{==} instead of #{isEqual:} but this "leaks" all string instances that are ever shared. "*/

- (NSString *)sharedInstance
{
    static NSMutableSet *stringPool;
    NSString *sharedInstance;

    if(stringPool == nil)
        stringPool = [[NSMutableSet alloc] init];

    if((sharedInstance = [stringPool member:self]) != nil)
        return sharedInstance;
    [stringPool addObject:self];
    return self;
}


//---------------------------------------------------------------------------------------
//	PRINTING
//---------------------------------------------------------------------------------------

/*" Writes the %printf format string to %stdout using the default C String encoding. "*/

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


/*" Writes the %printf format string to %fileHandle using the default C String encoding. "*/

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


/*" Writes the contents of the reciever to %stdout using the default C String encoding. "*/

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


/*" Writes the contents of the reciever to %fileHandle using the default C String encoding. "*/

- (void)fprintf:(NSFileHandle *)fileHandle
{
    if(printfLock == nil)
        printfLock = [[NSLock alloc] init];

    [printfLock lock];
    [fileHandle writeData:[self dataUsingEncoding:[NSString defaultCStringEncoding]]];
    [printfLock unlock];
}


//=======================================================================================
    @end
//=======================================================================================


//=======================================================================================
    @implementation NSMutableString(EDExtensions)
//=======================================================================================

/*" Various common extensions to #NSMutableString. "*/

/*" Removes all whitespace left of the first non-whitespace character and right of the last whitespace character. "*/

- (void)removeSurroundingWhitespace
{
    NSRange		start, end;

    if(iwsSet == nil)
        iwsSet = [[[NSCharacterSet whitespaceCharacterSet] invertedSet] retain];

    start = [self rangeOfCharacterFromSet:iwsSet];
    if(start.length == 0)
        {
        [self setString:@""];  // string is empty or consists of whitespace only
        return;
        }

    if(start.location > 0)
        [self deleteCharactersInRange:NSMakeRange(0, start.location)];
    
    end = [self rangeOfCharacterFromSet:iwsSet options:NSBackwardsSearch];
    if(end.location < [self length] - 1)
        [self deleteCharactersInRange:NSMakeRange(NSMaxRange(end), [self length] - NSMaxRange(end))];
}


/*" Removes all whitespace from the string. "*/

- (void)removeWhitespace
{
    [self removeCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}


/*" Removes all characters in %set from the string. "*/

- (void)removeCharactersInSet:(NSCharacterSet *)set
{
    NSRange			matchRange, searchRange, replaceRange;
    unsigned int    length;

    length = [self length];
    matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:NSMakeRange(0, length)];
    while(matchRange.length > 0)
        {
        replaceRange = matchRange;
        searchRange.location = NSMaxRange(replaceRange);
        searchRange.length = length - searchRange.location;
        for(;;)
            {
            matchRange = [self rangeOfCharacterFromSet:set options:NSLiteralSearch range:searchRange];
            if((matchRange.length == 0) || (matchRange.location != searchRange.location))
                break;
            replaceRange.length += matchRange.length;
            searchRange.length -= matchRange.length;
            searchRange.location += matchRange.length;
            }
        [self deleteCharactersInRange:replaceRange];
        matchRange.location -= replaceRange.length;
        length -= replaceRange.length;
        }
}


//=======================================================================================
    @end
//=======================================================================================

