//---------------------------------------------------------------------------------------
//  EDXMLAttribute.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLAttribute.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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
#include "EDXMLNode+Private.h"
#include "EDXMLElement.h"
#include "EDXMLAttribute.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLAttribute
//---------------------------------------------------------------------------------------

- (void)dealloc
{
    [value release];
    [super dealloc];
}


- (NSString *)description {
    return [NSString stringWithFormat:@"<0x%08X[%@]: {%@}%@%s '%@'>",
        self, NSStringFromClass([self class]),
        self->namespaceURI,
        [self name],
     [self specified] ? " specified" : "",
        [self nodeValue]];
}


//---------------------------------------------------------------------------------------
// xml node overrides
//---------------------------------------------------------------------------------------

/* type, name, etc. */

- (EDXMLNodeType)nodeType {
    return DOM_ATTRIBUTE_NODE;
}

- (void)setNodeValue:(NSString *)_value {
    [self setValue:_value];
}

- (NSString *)nodeValue {
    return value;
}

- (NSString *)namespaceURI {
    return namespaceURI;
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
// dom impl
//---------------------------------------------------------------------------------------

- (NSString *)name
{
    return nodeName;
}

- (BOOL)specified
{
    return isSpecified;
}

- (void)setValue:(NSString *)_value
{
    isSpecified = YES;
    id old = [value retain];
    value = [_value copyWithZone:[self zone]];
    [old release];
}

- (NSString *)value
{
    return value;
}

    /* owner */

- (EDXMLElement *)ownerElement
{
    return CAST([self parentNode], EDXMLElement);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLAttribute(Private)
//---------------------------------------------------------------------------------------

- (id)initWithName:(NSString *)_name namespaceURI:(NSString *)_uri {
    if ((self = [super init])) {
        self->nodeName     = [_name copy];
        self->namespaceURI = [_uri  copy];
    }
    return self;
}

- (id)initWithName:(NSString *)_name {
    return [self initWithName:_name namespaceURI:nil];
}

- (void)_setOwnerElement:(EDXMLElement *)_element {
    [self _domNodeRegisterParentNode:_element];
}


- (BOOL)_isValidChildNode:(id)_node {
    switch ([_node nodeType]) {
        case DOM_TEXT_NODE:
        case DOM_ENTITY_REFERENCE_NODE:
            return YES;

        default:
            return NO;
    }
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
