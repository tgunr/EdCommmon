//---------------------------------------------------------------------------------------
//  EDXMLDocument.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLDocument.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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
#include "EDXMLElement.h"
#include "EDXMLDocumentFragment.h"
#include "EDXMLAttribute.h"
#include "EDXMLText.h"
#include "EDXMLTreeWalker.h"
#include "EDXMLNode+Private.h"
#include "EDXMLDocument.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLDocument
//---------------------------------------------------------------------------------------

+ (id)documentWithContentsOfFile:(NSString *)path
{
    NSData	*contents;

    if((contents = [NSData dataWithContentsOfFile:path]) == nil)
        [NSException raise:NSInvalidArgumentException format:@"Failed to read document at %@", path];
    return [self documentWithData:contents];
}


+ (id)documentWithData:(NSData *)data
{
    EDXMLDOMTagProcessor *processor;
    EDMLParser			 *parser;

    processor = [[[EDXMLDOMTagProcessor alloc] init] autorelease];
    parser = [EDMLParser parserWithTagProcessor:processor];
    return [parser parseXMLDocument:data];
}


- (id)init
{
    [super init];
    ownerNode = self;
    return self;
}

//---------------------------------------------------------------------------------------
// xml node overrides
//---------------------------------------------------------------------------------------

/* type, name, etc. */

- (EDXMLNodeType)nodeType {
    return DOM_DOCUMENT_NODE;
}

- (NSString *)nodeName {
    return @"#document";
}

- (NSString *)nodeValue {
    return nil;
}


/* navigation */

- (id)parentNode {
    /* document cannot be nested */
    return nil;
}
- (id)nextSibling {
    /* document cannot be nested */
    return nil;
}
- (id)previousSibling {
    /* document cannot be nested */
    return nil;
}


//---------------------------------------------------------------------------------------
// dom impl
//---------------------------------------------------------------------------------------

/* elements */

- (id)documentElement
{
    unsigned i, count;

    for(i = 0, count = [childNodes count]; i < count; i++)
        {
        id node;

        node = [childNodes objectAtIndex:i];
        if ([node nodeType] == DOM_ELEMENT_NODE)
            return node;
        }
    return nil;
}


- (id)getElementsByTagName:(NSString *)_tagName
{
    /* implementation in EDXMLNode */
    return [self _getElementsByTagName:_tagName namespaceURI:nil];
}


- (id)getElementsByTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri
{
    /* implementation in EDXMLNode */
    return [self _getElementsByTagName:_tagName namespaceURI:_uri];
}


- (EDXMLNodeList *)getElementById:(NSString *)_id
{
    return nil;
}


/* creation */

- (EDXMLElement *)createElement:(NSString *)_tagName
{
    EDXMLElement *e = [[EDXMLElement allocWithZone:[self zone]] initWithTagName:_tagName];
    [e _setOwnerNode:self];
    return [e autorelease];
}

- (EDXMLElement *)createElement:(NSString *)_tagName namespaceURI:(NSString *)_uri
{
    EDXMLElement *e = [[EDXMLElement allocWithZone:[self zone]] initWithTagName:_tagName namespaceURI:_uri];
    [e _setOwnerNode:self];
    return [e autorelease];
}

- (EDXMLDocumentFragment *)createDocumentFragment
{
    EDXMLDocumentFragment *df = [[EDXMLDocumentFragment allocWithZone:[self zone]] init];
    [df _setOwnerNode:self];
    return [df autorelease];
}

- (EDXMLText *)createTextNode:(NSString *)_data
{
    EDXMLText *tn = [[EDXMLText allocWithZone:[self zone]] initWithString:_data];
    [tn _setOwnerNode:self];
    return [tn autorelease];
}

- (EDXMLAttribute *)createAttribute:(NSString *)_name
{
    EDXMLAttribute *a = [[EDXMLAttribute allocWithZone:[self zone]] initWithName:_name];
    [a _setOwnerNode:self];
    return [a autorelease];
}
    
- (EDXMLAttribute *)createAttribute:(NSString *)_name namespaceURI:(NSString *)_uri
{
    EDXMLAttribute *a = [[EDXMLAttribute allocWithZone:[self zone]] initWithName:_name namespaceURI:_uri];
    [a _setOwnerNode:self];
    return [a autorelease];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
    @implementation EDXMLDocument(Private)
//---------------------------------------------------------------------------------------

- (BOOL)_isValidChildNode:(id)_node {
    switch ([_node nodeType]) {
        case DOM_ELEMENT_NODE:
        case DOM_TEXT_NODE:
        case DOM_PROCESSING_INSTRUCTION_NODE:
        case DOM_COMMENT_NODE:
        case DOM_DOCUMENT_TYPE_NODE:
            return YES;

        default:
            return NO;
    }
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
