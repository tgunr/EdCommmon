//---------------------------------------------------------------------------------------
//  EDXMLElement.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLElement.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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
#include "EDCommonDefines.h"
#include "EDXMLAttribute.h"
#include "EDXMLDocument.h"
#include "EDXMLNamedNodeMap.h"
#include "EDXMLNode+Private.h"
#include "EDXMLElement.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLElement
//---------------------------------------------------------------------------------------

- (void)dealloc
{
    int	i, n;

    for(i = 0, n = [attrNodeMap length]; i < n; i++)
        [[attrNodeMap objectAtIndex:i] _domNodeForgetParentNode:self];
    [attrNodeMap release];
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:
                        @"<0x%08X[%@]: name=%@ parent=%@ #attrs=%i #children=%i>",
        self, NSStringFromClass([self class]),
        [self nodeName],
        [[self parentNode] nodeName],
        [attrNodeMap length],
        [self hasChildNodes] ? [[self _childNodes] count] : 0];
}


//---------------------------------------------------------------------------------------
// xml node overrides
//---------------------------------------------------------------------------------------

/* type, name, etc. */

- (EDXMLNodeType)nodeType {
    return DOM_ELEMENT_NODE;
}

- (NSString *)namespaceURI
{
    return namespaceURI;
}


/* element attributes */

- (EDXMLNamedNodeMap *)attributes {
    return attrNodeMap;
}


//---------------------------------------------------------------------------------------
// dom impl
//---------------------------------------------------------------------------------------

- (NSString *)tagName
{
    return nodeName;
}

/* lookup */

- (EDXMLNodeList *)getElementsByTagName:(NSString *)_tagName
{
    /* implementation in EDXMLNode */
    return [self _getElementsByTagName:_tagName namespaceURI:nil];
}


- (EDXMLNodeList *)getElementsByTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri
{
    /* implementation in EDXMLNode */
    return [self _getElementsByTagName:_tagName namespaceURI:_uri];
}



    /* element attributes */

- (void)setAttribute:(NSString *)_attrName value:(NSString *)_value
{
    EDXMLAttribute	*attr;

    if((attr = CAST([attrNodeMap namedItem:_attrName], EDXMLAttribute)) == nil)
        {
        attr = [[self ownerDocument] createAttribute:_attrName];
        [attr _domNodeRegisterParentNode:self];
        [attrNodeMap setNamedItem:attr];
        }
    [attr setValue:_value];
}
    
- (void)setAttribute:(NSString *)_qname namespaceURI:(NSString *)_uri value:(NSString *)_value
{
    NSRange			r;
    NSString		*localName, *prefix;
    EDXMLAttribute	*attr;

    r = [_qname rangeOfString:@":"];
    localName = (r.location != NSNotFound) ? [_qname substringFromIndex:NSMaxRange(r)] : _qname;
    prefix = (r.location != NSNotFound) ? [_qname substringToIndex:r.location] : @"";
     
    if((attr = CAST([attrNodeMap namedItem:localName namespaceURI:_uri], EDXMLAttribute)) == nil)
        {
        attr = [[self ownerDocument] createAttribute:_qname namespaceURI:_uri];
        NSAssert1(attr != nil, @"Failed to create attribute %@.", _qname);
        [attr _domNodeRegisterParentNode:self];
        [attrNodeMap setNamedItemNS:attr];
        }
    [attr setPrefix:prefix];
    [attr setValue:_value];
}


- (NSString *)attribute:(NSString *)_attrName
{
    return [CAST([attrNodeMap namedItem:_attrName], EDXMLAttribute) value];
}

- (NSString *)attribute:(NSString *)_localName namespaceURI:(NSString *)_uri
{
    if([_uri isEqualToString:@"*"])
        return [CAST([attrNodeMap namedItem:_localName], EDXMLAttribute) value];
    return [CAST([attrNodeMap namedItem:_localName namespaceURI:_uri], EDXMLAttribute) value];
}


- (BOOL)hasAttribute:(NSString *)_attrName
{
    return ([self attribute:_attrName] != nil);
}

- (BOOL)hasAttribute:(NSString *)_localName namespaceURI:(NSString *)_uri
{
    return ([self attribute:_localName namespaceURI:_uri] != nil);
}


- (void)removeAttribute:(NSString *)_attrName
{
    [attrNodeMap removeNamedItem:_attrName];
}

- (void)removeAttribute:(NSString *)_attrName namespaceURI:(NSString *)_uri
{
    [attrNodeMap removeNamedItem:_attrName namespaceURI:_uri];
}


- (EDXMLAttribute *)setAttributeNode:(EDXMLAttribute *)_attrNode
{
    [_attrNode _domNodeRegisterParentNode:self];
    return CAST([attrNodeMap setNamedItem:_attrNode], EDXMLAttribute);
}

- (EDXMLAttribute *)removeAttributeNode:(EDXMLAttribute *)_attrNode
{
    EDXMLAttribute *old = CAST([attrNodeMap removeNamedItem:[_attrNode name]], EDXMLAttribute);
    [old _domNodeForgetParentNode:nil];
    return old; 
}

- (EDXMLAttribute *)setAttributeNodeNS:(EDXMLAttribute *)_attrNode
{
    [_attrNode _domNodeRegisterParentNode:self];
    return CAST([attrNodeMap setNamedItemNS:_attrNode], EDXMLAttribute);
}

- (EDXMLAttribute *)removeAttributeNodeNS:(EDXMLAttribute *)_attrNode
{
    EDXMLAttribute *old = CAST([attrNodeMap removeNamedItem:[_attrNode name] namespaceURI:[_attrNode namespaceURI]], EDXMLAttribute);
    [old _domNodeForgetParentNode:nil];
    return old; 
}

- (EDXMLAttribute *)attributeNode:(NSString *)_attrName
{
    return CAST([attrNodeMap namedItem:_attrName], EDXMLAttribute);
}

- (EDXMLAttribute *)attributeNode:(NSString *)_attrName namespaceURI:(NSString *)_uri
{
    return CAST([attrNodeMap namedItem:_attrName namespaceURI:_uri], EDXMLAttribute);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLElement(Private)
//---------------------------------------------------------------------------------------

- (id)initWithTagName:(NSString *)_tagName
{
    [super init];
    attrNodeMap = [[EDXMLNamedNodeMap allocWithZone:[self zone]] initWithOwnerNode:self];
    nodeName = [_tagName copyWithZone:[self zone]];
    return self;
}

- (id)initWithTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri
{
    [self initWithTagName:_tagName];
    namespaceURI = [_uri copyWithZone:[self zone]];
    return self;
}


- (BOOL)_isValidChildNode:(id)_node {
    switch ([_node nodeType]) {
        case DOM_ELEMENT_NODE:
        case DOM_TEXT_NODE:
        case DOM_COMMENT_NODE:
        case DOM_PROCESSING_INSTRUCTION_NODE:
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
