//---------------------------------------------------------------------------------------
//  EDXMLDocumentTests.m created by erik on Fri May 23 2003
//  @(#)$Id: EDXMLDocumentTests.m,v 1.2 2003-06-06 02:03:54 znek Exp $
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

#include "EDCommon.h"
#include "moremacros.h"
#include "EDXMLDocumentTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLDocumentTests
//---------------------------------------------------------------------------------------

- (void)setUp
{
    document = [[EDXMLDocument alloc] init];
}


- (void)tearDown
{
    [document release];
}


- (void)testDocumentElement
{
    EDXMLElement	*docElement;

    [document appendChild:[document createTextNode:@"some text before document element"]];
    docElement = (EDXMLElement *)[document appendChild:[document createElement:@"foo"]];
    shouldBeEqual1(docElement, [document documentElement], @"Wrong document element.");
}


- (void)testGetElementsByTagName
{
    EDXMLElement	*docElement;
    EDXMLNodeList	*list;
    int				i;

    [document appendChild:[document createTextNode:@"some text before document element"]];
    docElement = (EDXMLElement *)[document appendChild:[document createElement:@"foo"]];
    [docElement appendChild:[document createTextNode:@"some text"]];
    [docElement appendChild:[document createElement:@"foo"]];
    [docElement appendChild:[document createElement:@"bar"]];

    list = [document getElementsByTagName:@"foo"];
    shouldBeEqualInt1([list length], 2, @"Wrong number of elements.");
    for(i = 0; i < [list length]; i++)
        {
        if([list objectAtIndex:i] == docElement)
            break;
        }
    should1(i < [list length], @"Document 'foo' node element not found");
}


- (void)testGetElementsByTagNameNS
{
    EDXMLElement	*docElement;
    EDXMLNodeList	*list;
    int				i;

    [document appendChild:[document createTextNode:@"some text before document element"]];
    docElement = (EDXMLElement *)[document appendChild:[document createElement:@"t2:foo" namespaceURI:@"urn:test2"]];
    [docElement appendChild:[document createTextNode:@"some text"]];
    [docElement appendChild:[document createElement:@"foo"]];
    [docElement appendChild:[document createElement:@"bar"]];

    list = [document getElementsByTagName:@"t2:foo" namespaceURI:@"urn:test2"];
    shouldBeEqualInt1(1, [list length], @"Wrong number of elements.");
    for(i = 0; i < [list length]; i++)
        {
        if([list objectAtIndex:i] == docElement)
            break;
        }
    should1(i < [list length], @"Document 'foo' node element not found");
}


// These tests might seem superfluous as their document simply implements a facade
// for the private initialisers but these (and some logic such as the name/localName
// algorithms in node) are not tested elsewhere. Therefore we test what is releavant
// to the user, namly this API and not the underlying implementation.

- (void)testCreateAttribute
{
    EDXMLAttribute *attr;

    attr = [document createAttribute:@"foo"];
    should1(EDXML_ATTRIBUTE_NODE == [attr nodeType], @"Wrong node type after creation.");
    shouldBeEqual1(@"foo", [attr nodeName], @"Wrong node name after creation.");
    should1([attr nodeValue] == nil, @"Wrong value after creation.");
    should1([attr value] == nil, @"Wrong value after creation.");
    should1([attr specified] == NO, @"Wrong specified state after creation.");
    // to make sure we also test what shouldn't happen
    shouldnt1([attr namespaceURI] != nil, @"DOM1 node has namespace uri.");
    shouldnt1([attr prefix] != nil, @"DOM1 node has prefix.");
    shouldnt1([attr localName] != nil, @"DOM1 node has local name.");
}


- (void)testCreateAttributeNS
{
    EDXMLAttribute *attr;

    attr = [document createAttribute:@"t:foo" namespaceURI:@"urn:test"];
    should1(EDXML_ATTRIBUTE_NODE == [attr nodeType], @"Wrong node type after creation.");
    shouldBeEqual1(@"t:foo", [attr nodeName], @"Wrong node name after creation.");
    shouldBeEqual1(@"t:foo", [attr nodeName], @"Wrong nodeName after creation");
    shouldBeEqual1(@"urn:test", [attr namespaceURI], @"Wrong namespace uri after creation");
    shouldBeEqual1(@"t", [attr prefix], @"Wrong prefix after creation");
    shouldBeEqual1(@"foo", [attr localName], @"Wrong local name after creation");
}


- (void)testCreateElement
{
    EDXMLElement	*element;

    element = [document createElement:@"foo"];
    should1([element nodeType]  == EDXML_ELEMENT_NODE, @"Wrong node type after creation.");
    shouldBeEqual1(@"foo", [element tagName], @"Wrong tag after creation");
}


- (void)testCreateElementNS
{
    EDXMLElement	*element;

    element = [document createElement:@"t:foo" namespaceURI:@"urn:test"];
    should1([element nodeType]  == EDXML_ELEMENT_NODE, @"Wrong node type after creation.");
    shouldBeEqual1(@"t:foo", [element tagName], @"Wrong tag after creation");
    shouldBeEqual1(@"t:foo", [element nodeName], @"Wrong nodeName after creation");
    shouldBeEqual1(@"urn:test", [element namespaceURI], @"Wrong namespace uri after creation");
    shouldBeEqual1(@"t", [element prefix], @"Wrong prefix after creation");
    shouldBeEqual1(@"foo", [element localName], @"Wrong local name after creation");
}


- (void)testCreateTextNode
{
    EDXMLText	*textNode;
    
    textNode = [document createTextNode:@"Lorem ipsum..."];
    should1(EDXML_TEXT_NODE == [textNode nodeType], @"Wrong node type after creation.");
    shouldBeEqual1(@"#text", [textNode nodeName], @"Wrong node name after creation.");
    shouldBeEqual1(@"Lorem ipsum...", [textNode nodeValue], @"Wrong value after creation");
    shouldBeEqual1(@"Lorem ipsum...", [textNode data], @"Wrong text after creation");
}


- (void)testFactory
{
    EDXMLDocument	*doc;

    doc = [EDXMLDocument documentWithContentsOfFile:EDCommonTestsPathForResourceOfType(@"Sample", @"xml")];
    should1(doc != nil, @"Failed to initialise document from a file.");
    should1([doc nodeType] == EDXML_DOCUMENT_NODE, @"Failed to properly initialise document from a file.");
    // No more tests regarding structure of doc, these are done in the TagProcessor tests
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
