//---------------------------------------------------------------------------------------
//  EDXMLNamedNodeMapTests.m created by erik on Mon Apr 21 2003
//  @(#)$Id: EDXMLNamedNodeMapTests.m,v 1.1 2003-05-26 19:56:13 erik Exp $
//
//  Copyright (c) 2003 by Erik Doernenburg. All rights reserved.
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

#include "EDCommon.h"
#include "moremacros.h"
#include "EDXMLDocument.h"
#include "EDXMLNamedNodeMapTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLNamedNodeMapTests
//---------------------------------------------------------------------------------------

static NSString *NS1 = @"urn:test1";
static NSString *NS2 = @"urn:test2";


- (void)setUp
{
    document = [[EDXMLDocument alloc] init];
    owner = [document createElement:@"owner"];
    [document appendChild:owner];
    map = [[EDXMLNamedNodeMap alloc] initWithOwnerNode:owner];
}


- (void)tearDown
{
    [map release];
    [document release];
}


- (EDXMLNode *)_makeNode:(NSString *)name ns:(NSString *)namespace
{
    EDXMLNode *node;

    node = [document createElement:name namespaceURI:namespace];
    // the map checks whether the node is from the same document
    [document appendChild:node];
    return node;
}


- (void)testSettingItems
{
    EDXMLNode *foo, *fooFromMap;
    EDXMLNode *bar, *barFromMap;

    foo = [self _makeNode:@"foo" ns:nil];
    [map setNamedItem:foo];
    fooFromMap = [map namedItem:@"foo"];
    should1(foo == fooFromMap, @"Map returned wrong node for name foo.");

    bar = [self _makeNode:@"bar" ns:nil];
    [map setNamedItem:bar];
    barFromMap = [map namedItem:@"bar"];
    should1(bar == barFromMap, @"Map returned wrong node for name bar.");

    fooFromMap = [map namedItem:@"foo"];
    should1(foo == fooFromMap, @"Map returned wrong node for name foo after adding bar.");
}


- (void)testSettingDuplicateItems
{
    EDXMLNode *foo, *fooFromMap;
    EDXMLNode *foo2;

    foo = [self _makeNode:@"foo" ns:nil];
    [map setNamedItem:foo];
    foo2 = [self _makeNode:@"foo" ns:nil];
    fooFromMap = [map setNamedItem:foo2];
    should1(foo == fooFromMap, @"Map did not return old node when adding duplicate foo node.");

    fooFromMap = [map namedItem:@"foo"];
    should1(foo2 == fooFromMap, @"Map returned wrong node for name foo after adding duplicate foo node.");
}


- (void)testRemovingItems
{
    EDXMLNode *foo, *fooFromMap;

    foo = [self _makeNode:@"foo" ns:nil];
    [map setNamedItem:foo];

    fooFromMap = [map removeNamedItem:@"foo"];
    should1(foo == fooFromMap, @"Map did not return old node when removing it.");
        
    fooFromMap = [map namedItem:@"foo"];
    should1(nil == fooFromMap, @"Map returned node for name foo after removing it.");
}


- (void)testSettingItemsNS
{
    EDXMLNode *foo, *fooFromMap;
    EDXMLNode *bar, *barFromMap;

    foo = [self _makeNode:@"foo" ns:NS1];
    [map setNamedItemNS:foo];
    fooFromMap = [map namedItem:@"foo" namespaceURI:NS1];
    should1(foo == fooFromMap, @"Map returned wrong node for t1:foo.");
    fooFromMap = [map namedItem:@"foo" namespaceURI:NS2];
    should1(nil == fooFromMap, @"Map returned a node for t2:foo.");

    bar = [self _makeNode:@"bar" ns:NS1];
    [map setNamedItemNS:bar];
    barFromMap = [map namedItem:@"bar" namespaceURI:NS1];
    should1(bar == barFromMap, @"Map returned wrong node for t1:bar.");
    barFromMap = [map namedItem:@"bar" namespaceURI:NS2];
    should1(nil == barFromMap, @"Map returned a node for t2:bar.");

    fooFromMap = [map namedItem:@"foo" namespaceURI:NS1];
    should1(foo == fooFromMap, @"Map returned wrong node for t1:foo.");
}


- (void)testSettingDuplicateItemsNS
{
    EDXMLNode *foo, *fooFromMap;
    EDXMLNode *foo2;

    foo = [self _makeNode:@"foo" ns:NS1];
    [map setNamedItemNS:foo];
    foo2 = [self _makeNode:@"foo" ns:NS1];
    fooFromMap = [map setNamedItem:foo2];
    should1(foo == fooFromMap, @"Map did not return old node when adding duplicate foo node.");

    fooFromMap = [map namedItem:@"foo"];
    should1(foo2 == fooFromMap, @"Map returned wrong node for name foo after adding duplicate foo node.");
}


- (void)testSettingDuplicateItemsDifferentNamespace
{
    EDXMLNode *foo, *fooFromMap;
    EDXMLNode *foo2;

    foo = [self _makeNode:@"foo" ns:NS1];
    [map setNamedItemNS:foo];
    foo2 = [self _makeNode:@"foo" ns:NS2];
    [map setNamedItemNS:foo2];

    fooFromMap = [map namedItem:@"foo" namespaceURI:NS1];
    should1(foo == fooFromMap, @"Map returned wrong node for t1:foo.");

    fooFromMap = [map namedItem:@"foo" namespaceURI:NS2];
    should1(foo2 == fooFromMap, @"Map returned wrong node for t2:foo.");
}


- (void)testRemovingItemsNS
{
    EDXMLNode *foo, *fooFromMap;

    foo = [self _makeNode:@"foo" ns:NS1];
    [map setNamedItemNS:foo];

    fooFromMap = [map removeNamedItem:@"foo" namespaceURI:NS1];
    should1(foo == fooFromMap, @"Map did not return old node when removing it.");

    fooFromMap = [map namedItem:@"foo"];
    should1(nil == fooFromMap, @"Map returned node for name foo after remove it.");
}


- (void)testAccessByIndex
{
    EDXMLNode 	*foo, *bar, *node;
    BOOL 		foundFoo, foundBar;
    int			i;
    
    foo = [self _makeNode:@"foo" ns:nil];
    [map setNamedItem:foo];
    bar = [self _makeNode:@"bar" ns:nil];
    [map setNamedItem:bar];

    shouldBeEqualInt1(2, [map length], @"Wrong length.");
    foundFoo = foundBar = NO;
    for(i = 0; i < [map length]; i++)
        {
        node = [map objectAtIndex:i];
        if(node == foo)
            foundFoo = true;
        else if(node == bar)
            foundBar = true;
        else
            fail1(@"Map returned that hasn't been added.");
        }
    should1(foundFoo, @"Map did not return foo.");
    should1(foundBar, @"Map did not return foo.");
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
