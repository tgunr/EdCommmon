//---------------------------------------------------------------------------------------
//  EDXMLNode.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLNode.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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
#include "NSObject+Extensions.h"
#include "EDXMLDocument.h"
#include "EDXMLNamedNodeMap.h"
#include "EDXMLNodeList.h"
#include "EDXMLTreeWalker.h"
#include "EDXMLNode+Private.h"
#include "EDXMLNode.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLNode
//---------------------------------------------------------------------------------------

- (NSString *)description {
    return [NSString stringWithFormat:
                        @"<0x%08X[%@]: name=%@ parent=%@ type=%i #children=%i>",
        self, NSStringFromClass([self class]),
        [self nodeName],
        [[self parentNode] nodeName],
        [self nodeType],
        [self hasChildNodes] ? [[self childNodes] length] : 0];
}


//---------------------------------------------------------------------------------------
// dom impl
//---------------------------------------------------------------------------------------

/* type, name, etc. */

- (EDXMLNodeType)nodeType {
  return DOM_UNKNOWN_NODE;
}

- (NSString *)nodeName {
    [self subclassResponsibility:_cmd];
    return nil; // keep compiler happy
}

- (void)setNodeValue:(NSString *)_value {
    [self subclassResponsibility:_cmd];
}

- (NSString *)nodeValue {
    return nil;
}

- (NSString *)localName {
  return nil;
}

- (NSString *)namespaceURI {
  return nil;
}

- (void)setPrefix:(NSString *)_prefix {
  [self subclassResponsibility:_cmd];
}

- (NSString *)prefix {
  return nil;
}

/* element attributes */

- (BOOL)hasAttributes {
    return NO;
}

- (EDXMLNamedNodeMap *)attributes {
  /* returns a NamedNodeList */
  return nil;
}

/* modification */

- (id)insert:(id)_newNode before:(id)_refNode {
  return nil;
}

- (id)replaceChild:(id)_oldNode with:(id)_newNode {
  return nil;
}

- (id)removeChild:(id)_node {
  return nil;
}
- (id)appendChild:(id)_node {
  return nil;
}

/* navigation */

- (id)parentNode {
    return (flags & EDXML_NF_HASPARENT) ? ownerNode : nil;
}

- (id)previousSibling {
  EDXMLNode *parent;
  unsigned idx;
  
  if ((parent = [self parentNode]) == nil) return nil;
  if (parent == nil) return nil;

  if ((idx = [[parent _childNodes] indexOfObject:self]) == NSNotFound)
    /* i'm not a child of my parent?! */
    return nil;
  if (idx == 0)
    /* i'm first */
    return nil;

  return [[parent _childNodes] objectAtIndex:(idx - 1)];
}
  
- (id)nextSibling {
  EDXMLNode *parent;
  NSArray	*siblings;
  unsigned idx, count;
  
  if ((parent = [self parentNode]) == nil) return nil;
  if (parent == nil) return nil;

  siblings = [parent _childNodes];
  if ((count = [siblings count]) == 0)
      /* parent has no children. what about me?! */
      return nil;
  if ((idx = [siblings indexOfObject:self]) == NSNotFound)
      /* i'm not a child of my parent?! */
      return nil;
  if (idx == (count - 1))
      /* i'm last */
      return nil;

  return [siblings objectAtIndex:(idx + 1)];
}

- (id)childNodes {
  return nil;
}
- (BOOL)hasChildNodes {
  return NO;
}
- (id)firstChild {
  return nil;
}
- (id)lastChild {
  return nil;
}


- (EDXMLDocument *)ownerDocument {
    if([self _isOwned] == NO)
        return CAST(ownerNode, EDXMLDocument);
    return [ownerNode ownerDocument];
}


 
- (NSString *)nodeTypeString {
    switch ([self nodeType]) {
        case DOM_ATTRIBUTE_NODE:
            return @"attribute";
        case DOM_CDATA_SECTION_NODE:
            return @"cdata-section";
        case DOM_COMMENT_NODE:
            return @"comment";
        case DOM_DOCUMENT_NODE:
            return @"document";
        case DOM_DOCUMENT_FRAGMENT_NODE:
            return @"document-fragment";
        case DOM_ELEMENT_NODE:
            return @"element";
        case DOM_PROCESSING_INSTRUCTION_NODE:
            return @"processing-instruction";
        case DOM_TEXT_NODE:
            return @"text";

        case DOM_DOCUMENT_TYPE_NODE:
            return @"document-type";
        case DOM_ENTITY_NODE:
            return @"entity";
        case DOM_ENTITY_REFERENCE_NODE:
            return @"entity-reference";
        case DOM_NOTATION_NODE:
            return @"notation";
        default:
            return @"unknown";
    }
}


#if EXTENSTIONS

- (NSString *)xmlStringValue {
    DOMXMLOutputter *out;
    NSMutableString *s;
    NSString *r;

    s   = [[NSMutableString alloc] initWithCapacity:1024];
    out = [[DOMXMLOutputter alloc] init];

    [out outputNode:self to:s];
    [out release];

    r = [s copy];
    [s release];
    return [r autorelease];
}


- (NSData *)xmlDataValue {
    return [[self xmlStringValue] dataUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)textValue {
    NSMutableString *s;

    s = [NSMutableString stringWithCapacity:256];

    switch ([self nodeType]) {
        case DOM_ELEMENT_NODE:
        case DOM_DOCUMENT_NODE:
        case DOM_ATTRIBUTE_NODE:
            if ([self hasChildNodes]) {
                id children;
                unsigned i, count;

                children = [self childNodes];
                for (i = 0, count = [children count]; i < count; i++) {
                    NSString *cs;

                    cs = [[children objectAtIndex:i] textValue];
                    if (cs) [s appendString:cs];
                }
            }
            break;

        case DOM_TEXT_NODE:
        case DOM_COMMENT_NODE:
        case DOM_CDATA_SECTION_NODE:
            [s appendString:[(DOMCharacterData *)self data]];
            break;

        default:
            return nil;
    }

    return [[s copy] autorelease];
}

#endif

//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLNode(Private)
//---------------------------------------------------------------------------------------

- (id)subclassResponsibility:(SEL)_selector {
    [self methodIsAbstract:_selector];
    return nil; // keep compiler happy
}

- (void)_setOwnerNode:(EDXMLNode *)_node {
    ownerNode = _node;
}

- (void)_setIsOwned:(BOOL)flag {
    if(flag)
        flags |= EDXML_NF_HASPARENT;
    else
        flags &= ~EDXML_NF_HASPARENT;
}

- (BOOL)_isOwned {
    return flags & EDXML_NF_HASPARENT;
}

- (void)_domNodeRegisterParentNode:(id)_parent {
    ownerNode = _parent;
    [self _setIsOwned:YES];
}

- (void)_domNodeForgetParentNode:(id)_parent {
    NSAssert(_parent == ownerNode, @"Tried to remove from a parent that is not the node's parent.");
    ownerNode = (id)[self ownerDocument];
    [self _setIsOwned:NO];
}

- (BOOL)_isValidChildNode:(id)_node {
    return NO;
}

- (NSMutableArray *)_childNodes {
    return nil;
}


/* the following is used by EDXMLDocument and EDXMLElement. note that uri == nil means 'match all uris' and not 'match element whose uri in nil.' */

- (EDXMLNodeList *)_getElementsByTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri
{
    EDXMLTreeWalker	*walker;
    NSMutableArray 	*nodeList;
    EDXMLNode		*node;

    walker = [EDXMLTreeWalker nodeWalkerWithNode:self];
    nodeList = [NSMutableArray array];
    while((node = [walker nextElementWithTagName:_tagName]) != nil)
        {
        if((_uri == nil) || ([[node namespaceURI] isEqualToString:_uri]))
            [nodeList addObject:node];
        }
    return [[[EDXMLNodeList alloc] initWithArray:nodeList] autorelease];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLParentNode
//---------------------------------------------------------------------------------------

- (void)dealloc {
    [self->childNodes makeObjectsPerformSelector:
        @selector(_domNodeForgetParentNode:)
                                      withObject:self];

    [self->childNodes release];
    [super dealloc];
}


- (NSMutableArray *)_childNodes {
    return self->childNodes;
}

- (void)_ensureChildNodes {
    if (self->childNodes == nil)
        self->childNodes = [[NSMutableArray alloc] init];
}

/* navigation */

- (EDXMLNodeList *)childNodes {
    [self _ensureChildNodes];
    return [[[EDXMLNodeList alloc] initWithArray:self->childNodes] autorelease];
}
- (BOOL)hasChildNodes {
    return [self->childNodes count] > 0 ;
}
- (id)firstChild {
    return [self->childNodes count] > 0
    ? [self->childNodes objectAtIndex:0]
    : nil;
}
- (id)lastChild {
    unsigned count;

    return (count = [self->childNodes count]) > 0
        ? [self->childNodes objectAtIndex:(count - 1)]
        : nil;
}

/* modification */

- (id)insert:(id)_node before:(id)_refNode {
    if (_node == nil)
        /* adding a 'nil' node ?? */
        return nil;

    [self _ensureChildNodes];
    if([self->childNodes containsObject:_node])
        [self removeChild:_node];

    if ([_node nodeType] == DOM_DOCUMENT_FRAGMENT_NODE) {
        id             fragNodes;
        unsigned       i, count;
        NSMutableArray *cache;

        fragNodes = [_node childNodes];

        if ((count = [fragNodes count]) == 0)
            /* no nodes to add */
            return nil;

        /*
         copy to cache, since 'childNodes' result is 'live' and
         appendChild modifies the tree
         */
        cache = [NSMutableArray arrayWithCapacity:count];
        for (i = 0; i < count; i++)
            [cache addObject:[fragNodes objectAtIndex:i]];

        /* append nodes (in reverse order [array implemention is assumed]) .. */
        for (i = count = [cache count]; i > 0; i--)
            [self insert:[cache objectAtIndex:(i - 1)] before:_refNode];
    }
    else {
        id oldParent;

        if([self _isValidChildNode:_node] == NO)
            [NSException raise:NSInvalidArgumentException format:@"Node type %@ cannot be added to node type %@", [_node nodeTypeString], [self nodeTypeString]];

        if([_node ownerDocument] != [self ownerDocument])
            [NSException raise:NSInvalidArgumentException format:@"Node is in wrong document."];

        if ((oldParent = [_node parentNode]))
            [oldParent removeChild:_node];

        if(_refNode == nil)
            {
            [self->childNodes addObject:_node];
            }
        else
            {
            unsigned int refIndex = [self->childNodes indexOfObject:_refNode];
            if(refIndex == NSNotFound)
                [NSException raise:NSInvalidArgumentException format:@"Reference node %@ not found among children of node %@.", [_refNode nodeTypeString], [self nodeTypeString]];
            [self->childNodes insertObject:_node atIndex:refIndex];
            }
        
        [_node _domNodeRegisterParentNode:self];
    }

    /* return the node 'added' */
    return _node;
}


- (id)replaceChild:(id)_oldNode with:(id)_newNode
{
    id	refNode;

    refNode = [_oldNode nextSibling];
    [[_oldNode retain] autorelease];
    [self removeChild:_oldNode];
    [self insert:_newNode before:refNode];
    return _oldNode;
}


- (id)appendChild:(id)_node {
    return [self insert:_node before:nil];
}


- (id)removeChild:(id)_node {
    unsigned idx;

    if (self->childNodes == nil)
        /* this node has no childnodes ! */
        return nil;

    if ((idx = [self->childNodes indexOfObject:_node]) == NSNotFound)
        /* given node is not a child of this node ! */
        return nil;

    [[_node retain] autorelease];
    [self->childNodes removeObjectAtIndex:idx];
    [_node _domNodeForgetParentNode:self];

    return _node;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLNamedParentNode
//---------------------------------------------------------------------------------------

- (void)dealloc
{
    [nodeName release];
    [namespaceURI release];
    [super dealloc];
}

- (NSString *)nodeName {
    return nodeName;
}


- (NSString *)localName
{
    NSRange r;

    if(namespaceURI == nil)  // DOM1
        return nil;
    r = [nodeName rangeOfString:@":"];
    if(r.location == NSNotFound)
        return nodeName;
    return [nodeName substringFromIndex:NSMaxRange(r)];
}


- (void)setPrefix:(NSString *)_prefix
{
    NSRange r;

    if(namespaceURI == nil)  // DOM1
        [NSException raise:NSInternalInconsistencyException format:@"Cannot set prefix for node that has no namespace"];
    r = [nodeName rangeOfString:@":"];
    id localName = (r.location == NSNotFound) ? nodeName : [nodeName substringFromIndex:NSMaxRange(r)];
    [nodeName autorelease];
    nodeName = [[NSString alloc] initWithFormat:@"%@:%@", _prefix, localName];
}


- (NSString *)prefix
{
    NSRange r;

    if(namespaceURI == nil)  // DOM1
        return nil;
    r = [nodeName rangeOfString:@":"];
    if(r.location == NSNotFound)
        return nodeName;
    return [nodeName substringToIndex:r.location];
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

