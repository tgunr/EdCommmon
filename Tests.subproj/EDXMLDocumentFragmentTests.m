//---------------------------------------------------------------------------------------
//  EDXMLDocumentFragmentTests.m created by erik on Mon May 26 2003
//  @(#)$Id: EDXMLDocumentFragmentTests.m,v 1.1 2003-05-26 19:56:13 erik Exp $
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
#include "EDXMLDocumentFragmentTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLDocumentFragmentTests
//---------------------------------------------------------------------------------------

- (void)testParserIntegration
{
    EDXMLDocument		  *document;
    EDXMLDocumentFragment *fragment;
    EDXMLNode			  *child;

    document = [[[EDXMLDocument alloc] init] autorelease];
    fragment = [document createDocumentFragment];

    [fragment appendChildrenFromString:@"<foo>text</foo><bar/>"];
    should1([[fragment childNodes] length] == 2, @"Wrong number of child nodes.");
    child = [fragment firstChild];
    shouldBeEqual1(@"foo", [child nodeName], @"Wrong name of first child.");
    child = [child nextSibling];
    shouldBeEqual1(@"bar", [child nodeName], @"Wrong name of second child.");
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
