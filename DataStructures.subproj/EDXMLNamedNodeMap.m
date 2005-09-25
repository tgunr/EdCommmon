//---------------------------------------------------------------------------------------
//  EDXMLNamedNodeMap.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLNamedNodeMap.m,v 1.2 2005-09-25 11:06:28 erik Exp $
//
//  Copyright (c) 2002 by Erik Doernenburg. All rights reserved.
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
#include "EDXMLNode.h"
#include "EDXMLNamedNodeMap.h"
#include "EDXMLNode+Private.h"

@interface EDXMLNamedNodeMap(PrivateAPI)
- (EDXMLNode *)_namedItem:(NSString *)aName index:(int *)idxPtr;
- (EDXMLNode *)_namedItem:(NSString *)aName namespaceURI:(NSString *)aURI index:(int *)idxPtr;
@end


//---------------------------------------------------------------------------------------
    @implementation EDXMLNamedNodeMap
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithOwnerNode:(EDXMLNode *)_node
{
    [super init];
    nodeList = [[NSMutableArray alloc] init];
    ownerNode = _node;
    return self;
}


- (void)dealloc
{
    [nodeList release];
	[super dealloc];
}


//---------------------------------------------------------------------------------------
//	DOM Impl (Indexed access)
//---------------------------------------------------------------------------------------

- (unsigned)length
{
    return [nodeList count];
}


- (id)objectAtIndex:(unsigned)index
{
    return [nodeList objectAtIndex:index];
}


//---------------------------------------------------------------------------------------
//	DOM Impl (Access by Name)
//---------------------------------------------------------------------------------------

- (EDXMLNode *)namedItem:(NSString *)aName
{
    return [self _namedItem:aName index:NULL];
}
    

- (EDXMLNode *)setNamedItem:(EDXMLNode *)aNode
{
    EDXMLNode	*oldNode;
    int			idx;

    if([aNode ownerDocument] != [ownerNode ownerDocument])
        [NSException raise:NSInvalidArgumentException format:@"node is in wrong document"];
    
    if((oldNode = [self _namedItem:[aNode nodeName] index:&idx]) != nil)
        {
        [[oldNode retain] autorelease];
        [nodeList replaceObjectAtIndex:idx withObject:aNode];
        }
    else
        {
        [nodeList addObject:aNode];
        }
    return oldNode;
}


- (EDXMLNode *)removeNamedItem:(NSString *)aName
{
    EDXMLNode	*oldNode;
    int			idx;

    if((oldNode = [self _namedItem:aName index:&idx]) != nil)
        {
        [[oldNode retain] autorelease];
        [nodeList removeObjectAtIndex:idx];
        }
    return oldNode;
}


- (EDXMLNode *)_namedItem:(NSString *)aName index:(int *)idxPtr
{
    EDXMLNode	*node;
    int			i, n;

    for(i = 0, n = [nodeList count]; i < n; i++)
        {
        node = [nodeList objectAtIndex:i];
        if([[node nodeName] isEqualToString:aName])
            {
            if(idxPtr != NULL)
                *idxPtr = i;
            return node;
            }
        }
    return nil;
}


//---------------------------------------------------------------------------------------
//	DOM Impl (Access by qualified name)
//---------------------------------------------------------------------------------------

- (EDXMLNode *)namedItem:(NSString *)aName namespaceURI:(NSString *)aURI
{
    return [self _namedItem:aName namespaceURI:aURI index:NULL];
}


- (EDXMLNode *)setNamedItemNS:(EDXMLNode *)aNode
{
    EDXMLNode	*oldNode;
    int			idx;

    if([aNode ownerDocument] != [ownerNode ownerDocument])
        [NSException raise:NSInvalidArgumentException format:@"Node is in wrong document."];

    if((oldNode = [self _namedItem:[aNode nodeName] namespaceURI:[aNode namespaceURI] index:&idx]) != nil)
        {
        [[oldNode retain] autorelease];
        [nodeList replaceObjectAtIndex:idx withObject:aNode];
        }
    else
        {
        [nodeList addObject:aNode];
        }
    return oldNode;
}


- (EDXMLNode *)removeNamedItem:(NSString *)aName namespaceURI:(NSString *)aURI
{
    EDXMLNode	*oldNode;
    int			idx;

    if((oldNode = [self _namedItem:aName namespaceURI:aURI index:&idx]) != nil)
        {
        [[oldNode retain] autorelease];
        [nodeList removeObjectAtIndex:idx];
        }
    return oldNode;
}


- (EDXMLNode *)_namedItem:(NSString *)aName namespaceURI:(NSString *)aURI index:(int *)idxPtr
{
    EDXMLNode	*node;
    int			i, n;

    for(i = 0, n = [nodeList count]; i < n; i++)
        {
        node = [nodeList objectAtIndex:i];
        if([[node localName] isEqualToString:aName] &&
           (((aURI == nil) && ([node namespaceURI] == nil)) || ([[node namespaceURI] isEqualToString:aURI])))
            {
            if(idxPtr != NULL)
                *idxPtr = i;
            return node;
            }
        }
    return nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
