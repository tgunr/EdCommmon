//---------------------------------------------------------------------------------------
//  EDBitmapCharset.h created by erik on Fri 08-Oct-1999
//  @(#)$Id: EDBitmapCharset.h,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
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

#import "EDCommonDefines.h"


typedef struct
{
    const byte 	*bytes;
    NSData		*bitmapRep;
} EDBitmapCharset;


static __inline__ BOOL EDBitmapCharsetContainsCharacter(EDBitmapCharset *charset, unichar character)
{
    return ((charset->bytes)[character >> 3] & (((unsigned int)1) << (character & 0x7)));
}


EDCOMMON_EXTERN EDBitmapCharset *EDBitmapCharsetFromCharacterSet(NSCharacterSet *charset);
EDCOMMON_EXTERN void EDReleaseBitmapCharset(EDBitmapCharset *charset);

