//---------------------------------------------------------------------------------------
//  NSString+printf.m created by erik on Sat 27-Sep-1997
//  @(#)$Id: NSString+Extensions.h,v 1.5 2002-04-14 14:57:57 znek Exp $
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


#ifndef	__NSString_Extensions_h_INCLUDE
#define	__NSString_Extensions_h_INCLUDE


#import <Foundation/NSString.h>


@class NSFileHandle;


@interface NSString(EDExtensions)

+ (NSString *)stringWithData:(NSData *)data encoding:(NSStringEncoding)encoding;

- (NSString *)stringByRemovingSurroundingWhitespace;
- (BOOL)isWhitespace;
- (NSString *)stringByRemovingWhitespace;
- (NSString *)stringByRemovingCharactersFromSet:(NSCharacterSet *)set;

- (BOOL)hasPrefixCaseInsensitive:(NSString *)string;

- (BOOL)boolValue;
- (unsigned int)intValueForHex;

- (BOOL)isEmpty;

- (NSString *)encryptedString;
- (NSString *)encryptedStringWithSalt:(const char *)salt;
- (BOOL)isValidEncryptionOfString:(NSString *)aString;

- (NSString *)sharedInstance;

+ (void)printf:(NSString *)format, ...;
+ (void)fprintf:(NSFileHandle *)fileHandle:(NSString *)format, ...;
- (void)printf;
- (void)fprintf:(NSFileHandle *)fileHandle;

@end


@interface NSMutableString(EDExtensions)

- (void)removeWhitespace;
- (void)removeCharactersInSet:(NSCharacterSet *)set;

@end

#endif	/* __NSString_Extensions_h_INCLUDE */

