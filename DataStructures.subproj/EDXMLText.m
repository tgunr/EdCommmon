//---------------------------------------------------------------------------------------
//  EDXMLText.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLText.m,v 1.1 2003-05-26 19:52:35 erik Exp $
//
//  Copyright (c) 2002-2003 by Helge Hess, Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Mulle Kybernetik in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------

#import <Foundation/Foundation.h>
#include "EDXMLNode+Private.h"
#include "EDXMLDocument.h"
#include "EDXMLText.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLText
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
// xml node overrides
//---------------------------------------------------------------------------------------

/* type, name, etc. */

- (EDXMLNodeType)nodeType {
    return DOM_TEXT_NODE;
}

- (NSString *)nodeName {
    return @"#text";
}

- (NSString *)nodeValue {
    return data;
}

        
//---------------------------------------------------------------------------------------
// dom impl
//---------------------------------------------------------------------------------------

- (EDXMLText *)splitText:(unsigned)_offset {
    NSString	 *left, *right;
    id			 new;

    left = [self substringData:0 count:_offset];
    right = [self substringData:_offset count:[self length] - _offset];
    [self setData:left];
    new = [[self ownerDocument] createTextNode:right];
    [[self parentNode] insert:new before:[self nextSibling]];
    return new;
}

/* Level 3 Methods */

- (BOOL)isWhitespaceInElementContent {
    if(data == nil)
        return NO;
    return ([data rangeOfCharacterFromSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0);
}

- (NSString *)wholeText {
    return nil;
}

- (EDXMLText *)replaceWholeText:(NSString *)_content {
    return nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
