//---------------------------------------------------------------------------------------
//  EDXMLDOMTagProcessorTests.m created by erik on Sun May 25 2003
//  @(#)$Id: EDXMLDOMTagProcessorTests.m,v 1.2 2003-06-06 02:03:54 znek Exp $
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
#include "EDXMLDOMTagProcessorTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLDOMTagProcessorTests
//---------------------------------------------------------------------------------------

- (void)testParseSimpleDocument
{
    EDXMLDOMTagProcessor	*processor;
    EDMLParser				*parser;
    EDXMLDocument			*doc;
    EDXMLElement 			*docElement, *childElement;
    EDXMLText	 			*textNode;
   
    processor = [[[EDXMLDOMTagProcessor alloc] init] autorelease];
    parser = [EDMLParser parserWithTagProcessor:processor];
    doc = [parser parseXMLDocumentAtPath:EDCommonTestsPathForResourceOfType(@"Sample", @"xml")];
    should1(doc != nil, @"Failed to create a document.");
    should([doc nodeType] == EDXML_DOCUMENT_NODE);

    docElement = [doc documentElement];
    should([docElement nodeType] == EDXML_ELEMENT_NODE);
    shouldBeEqual(@"docelement", [docElement tagName]);

    childElement = (EDXMLElement *)[docElement firstChild];
    should([childElement nodeType] == EDXML_ELEMENT_NODE);
    shouldBeEqual(@"elementwithattr", [childElement tagName]);
    shouldBeEqual(@"bar", [childElement attribute:@"foo"]);

    childElement = (EDXMLElement *)[childElement nextSibling];
    should([childElement nodeType] == EDXML_ELEMENT_NODE);
    shouldBeEqual(@"elementwithtext", [childElement tagName]);

    textNode = (EDXMLText *)[childElement firstChild];
    should([textNode nodeType] == EDXML_TEXT_NODE);
    shouldBeEqual(@"footext", [textNode data]);

    childElement = (EDXMLElement *)[childElement nextSibling];
    should([childElement nodeType] == EDXML_ELEMENT_NODE);
    shouldBeEqualInt(2, [[childElement childNodes] length]);

    shouldBeEqual(nil, [childElement nextSibling]);    
}


- (void)testParseDocumentWithNamespaces
{
    EDXMLDOMTagProcessor	*processor;
    EDMLParser				*parser;
    EDXMLDocument			*doc;
    EDXMLElement 			*docElement, *barElement;

    processor = [[[EDXMLDOMTagProcessor alloc] init] autorelease];
    parser = [EDMLParser parserWithTagProcessor:processor];
    doc = [parser parseXMLDocumentAtPath:EDCommonTestsPathForResourceOfType(@"SampleWithNamespaces", @"xml")];
    should1(doc != nil, @"Failed to create a document.");
    should([doc nodeType] == EDXML_DOCUMENT_NODE);

    docElement = [doc documentElement];
    should([docElement nodeType] == EDXML_ELEMENT_NODE);
    shouldBeEqual(@"foo:docelement", [docElement tagName]);
    shouldBeEqual(@"1", [docElement attribute:@"attr1" namespaceURI:@"urn:foo"]);
    
    barElement = (EDXMLElement *)[docElement firstChild];
    should([barElement nodeType] == EDXML_ELEMENT_NODE);
    shouldBeEqual(@"bar:elementwithchildren", [barElement tagName]);
    shouldBeEqual(@"urn:bar", [barElement namespaceURI]);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
