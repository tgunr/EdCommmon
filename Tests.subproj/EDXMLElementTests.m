//---------------------------------------------------------------------------------------
//  EDXMLElementTests.m created by erik on Sat May 24 2003
//  @(#)$Id: EDXMLElementTests.m,v 1.1 2003-05-26 19:56:13 erik Exp $
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
#include "EDXMLElementTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLElementTests
//---------------------------------------------------------------------------------------

static NSString *NS1 = @"urn:test1";
static NSString *NS2 = @"urn:test2";


- (void)setUp
{
    document = [[EDXMLDocument alloc] init];
}


- (void)tearDown
{
    [document release];
}


- (void)testSettingAndRemovingAttributes
{
    EDXMLElement	*element;
    NSString		*valueFromElement;
    EDXMLAttribute	*attrFromElement;

    element = [document createElement:@"element"];
    [document appendChild:element];
    
    [element setAttribute:@"foo" value:@"bar"];
    should1([element hasAttribute:@"foo"], @"Element does not have attribute after setting it.");
    valueFromElement = [element attribute:@"foo"];
    shouldBeEqual1(@"bar", valueFromElement, @"Wrong value after setting it.");

    // see whether we can also get this as a node
    attrFromElement = [element attributeNode:@"foo"];
    shouldBeEqual1(@"foo", [attrFromElement name], @"Element returned wrong attr node.");
    shouldBeEqual1(@"bar", [attrFromElement value], @"Wrong value in attr node.");

    // now overwrite and check
    [element setAttribute:@"foo" value:@"baz"];
    should1([element hasAttribute:@"foo"], @"Element does not have attribute after setting it.");
    valueFromElement = [element attribute:@"foo"];
    shouldBeEqual1(@"baz", valueFromElement, @"Wrong value after overwriting it.");

    // now remove and check
    [element removeAttribute:@"foo"];
    shouldnt1([element hasAttribute:@"foo"], @"Element has attribute after removing it.");
    valueFromElement = [element attribute:@"foo"];
    shouldnt1(valueFromElement != nil, @"Element has attribute value after removing it.");
}


- (void)testAddingAttributeNodes
{
    EDXMLElement	*element;
    EDXMLAttribute	*attr;
    NSString		*valueFromElement;
 
    element = [document createElement:@"element"];
    [document appendChild:element];
    attr = [document createAttribute:@"foo"];
    [attr setValue:@"bar"];
    
    [element setAttributeNode:attr];
    should1([element hasAttribute:@"foo"], @"Element does not have attribute after setting it.");
    valueFromElement = [element attribute:@"foo"];
    shouldBeEqual1(@"bar", valueFromElement, @"Wrong value after setting it.");
}


- (void)testSettingAndRemovingAttributesNS
{
    EDXMLElement	*element;
    NSString		*valueFromElement;
    EDXMLAttribute	*attrFromElement;

    element = [document createElement:@"element" namespaceURI:NS1];
    [document appendChild:element];

    [element setAttribute:@"t1:foo" namespaceURI:NS1 value:@"bar"];
    // the next one is correct, we do want the local name
    should1([element hasAttribute:@"foo" namespaceURI:NS1], @"Element does not have attribute.");
    valueFromElement = [element attribute:@"foo" namespaceURI:NS1];
    shouldBeEqual1(@"bar", valueFromElement, @"Wrong value after setting it.");

    // see whether we can also get this as a node
    attrFromElement = [element attributeNode:@"foo" namespaceURI:NS1];
    shouldBeEqual1(@"foo", [attrFromElement localName], @"Element returned wrong attr node.");
    shouldBeEqual1(@"bar", [attrFromElement value], @"Wrong value in attr node.");

    // now overwrite and check (note different prefix and same namespace!)
    [element setAttribute:@"t2:foo" namespaceURI:NS1 value:@"baz"];
    attrFromElement = [element attributeNode:@"foo" namespaceURI:NS1];
    shouldBeEqual1(@"foo", [attrFromElement localName], @"Element returned wrong attr node.");
    shouldBeEqual1(@"baz", [attrFromElement value], @"Wrong value in attr node.");
    shouldBeEqual1(@"t2", [attrFromElement prefix], @"Prefix not changed.");
    
    // now remove and check
    [element removeAttribute:@"foo" namespaceURI:NS1];
    shouldnt1([element hasAttribute:@"foo"], @"Element has attribute after removing it.");
    valueFromElement = [element attribute:@"foo"];
    shouldnt1(valueFromElement != nil, @"Element has attribute value after removing it.");

}


- (void)testNamspaceSeparation
{
    EDXMLElement	*element;
    NSString		*valueFromElement;
    EDXMLAttribute	*attrFromElement;

    element = [document createElement:@"element" namespaceURI:NS1];
    [document appendChild:element];

    [element setAttribute:@"t1:foo" namespaceURI:NS1 value:@"bar"];
    // the next one is correct, we do want the local name
    should1([element hasAttribute:@"foo" namespaceURI:NS1], @"Element does not have attribute.");
    valueFromElement = [element attribute:@"foo" namespaceURI:NS1];
    shouldBeEqual1(@"bar", valueFromElement, @"Wrong value after setting it.");
    // test what shouldn't happen
    shouldnt1([element hasAttribute:@"foo" namespaceURI:NS2], @"Got attr using wrong namespace.");
    valueFromElement = [element attribute:@"foo" namespaceURI:NS2];
    shouldnt1(valueFromElement != nil, @"Got attr value using wrong namespace.");

    // see whether we can also get this as a node
    attrFromElement = [element attributeNode:@"foo" namespaceURI:NS1];
    shouldBeEqual1(@"foo", [attrFromElement localName], @"Element returned wrong attr node.");
    shouldBeEqual1(@"bar", [attrFromElement value], @"Wrong value in attr node.");
    attrFromElement = [element attributeNode:@"foo" namespaceURI:NS2];
    shouldnt1(valueFromElement != nil, @"Got attr node using wrong namespace.");

    // now remove and check
    [element removeAttribute:@"foo"];
    shouldnt1([element hasAttribute:@"foo"], @"Element has attribute after removing it.");
    valueFromElement = [element attribute:@"foo"];
    shouldnt1(valueFromElement != nil, @"Element has attribute value after removing it.");
}

// getElementsByTagName is implemented in EDXMLNode. It is also used by document
// and tested there.


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
