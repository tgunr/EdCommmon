//---------------------------------------------------------------------------------------
//  EDXMLDocumentFragment.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLDocumentFragment.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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
#include "EDMLParser.h"
#include "EDXMLDOMTagProcessor.h"
#include "EDXMLNode+Private.h"
#include "EDXMLDocumentFragment.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLDocumentFragment
//---------------------------------------------------------------------------------------

- (void)appendChildrenFromString:(NSString *)fragment
{
    EDXMLDOMTagProcessor *processor;
    EDMLParser			 *parser;
    NSEnumerator		 *nodeEnum;
    EDXMLNode			 *node;

    processor = [[[EDXMLDOMTagProcessor alloc] init] autorelease];
    [processor setDocument:[self ownerDocument]];
    parser = [EDMLParser parserWithTagProcessor:processor];
    nodeEnum = [[parser parseXMLFragment:fragment] objectEnumerator];
    while((node = [nodeEnum nextObject]) != nil)
        [self appendChild:node];
}


//---------------------------------------------------------------------------------------
// xml node overrides
//---------------------------------------------------------------------------------------

/* type, name, etc. */

- (EDXMLNodeType)nodeType {
    return DOM_DOCUMENT_FRAGMENT_NODE;
}

- (NSString *)nodeName {
    return @"#document-fragment";
}

- (NSString *)nodeValue {
    return nil;
}


/* navigation */

- (id)parentNode {
    return nil;
}
- (id)nextSibling {
    return nil;
}
- (id)previousSibling {
    return nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLDocumentFragment(Private)
//---------------------------------------------------------------------------------------

- (BOOL)_isValidChildNode:(id)_node {
    switch ([_node nodeType]) {
        case DOM_ELEMENT_NODE:
        case DOM_PROCESSING_INSTRUCTION_NODE:
        case DOM_COMMENT_NODE:
        case DOM_TEXT_NODE:
        case DOM_CDATA_SECTION_NODE:
        case DOM_ENTITY_REFERENCE_NODE:
            return YES;

        default:
            return NO;
    }
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
