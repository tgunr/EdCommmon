//---------------------------------------------------------------------------------------
//  EDStringScanner.h created by erik on Mon 24-Apr-2000
//  $Id: EDStringScanner.h,v 1.2 2002-04-14 14:57:55 znek Exp $
//
//  Copyright (c) 2000 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDStringScanner_h_INCLUDE
#define	__EDStringScanner_h_INCLUDE


/* This is a fairly simple scanner that allows little more than retrieving individual characters from an NSString in a somewhat efficient way. The OmniFoundation has a much richer implementation but at the moment I am reluctant to use their's due to the licensing terms and dependency on OmniBase. */

#import "EDCommonDefines.h"

@interface EDStringScanner : NSObject
{
    NSString	*string;
    unichar	 	*buffer;
    unichar		*charPointer;
    unichar  	*endOfBuffer;
    unsigned int bufferOffset;
}

+ (id)scannerWithString:(NSString *)aString;

- (id)initWithString:(NSString *)aString;

- (unichar)getCharacter;
- (unichar)peekCharacter;

- (unsigned int)scanLocation;

@end


EDCOMMON_EXTERN unichar EDStringScannerEndOfDataCharacter;

#endif	/* __EDStringScanner_h_INCLUDE */
