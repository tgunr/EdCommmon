//---------------------------------------------------------------------------------------
//  EDXMLAttributeTests.m created by erik on Sat May 24 2003
//  @(#)$Id: EDXMLAttributeTests.m,v 1.1 2003-05-26 19:56:13 erik Exp $
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
#include "EDXMLAttributeTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLAttributeTests
//---------------------------------------------------------------------------------------

- (void)setUp
{
    document = [[EDXMLDocument alloc] init];
}


- (void)tearDown
{
    [document release];
}


// next test is testing superclass behaviour.

- (void)testSetPrefix
{
    EDXMLAttribute *attr;

    attr = [document createAttribute:@"t:foo" namespaceURI:@"urn:test"];
    [attr setPrefix:@"t2"];
    shouldBeEqual1(@"t2", [attr prefix], @"Prefix wrong after setting it.");
    shouldBeEqual1(@"t2:foo", [attr name], @"Name wrong after setting prefix.");
    shouldBeEqual1(@"foo", [attr localName], @"Local name wrong after setting prefix.");
}


- (void)testSettingSimpleValue
{
    EDXMLAttribute *attr;

    attr = [document createAttribute:@"foo"];
    [attr setValue:@"bar"];
    shouldBeEqual1(@"bar", [attr value], @"Wrong value after setting.");
    shouldBeEqual1(@"bar", [attr nodeValue], @"Wrong nodeValue after setting.");
    should1([attr specified] == YES, @"Wrong specified state after setting.");

    [attr setNodeValue:@"baz"];
    shouldBeEqual1(@"baz", [attr value], @"Wrong value after setting.");
    shouldBeEqual1(@"baz", [attr nodeValue], @"Wrong nodeValue after setting.");
    should1([attr specified] == YES, @"Wrong specified state after setting.");
}


#warning * tests missing for complex values
#if 0
- (void)testSettingValueThroughChildNodes
{

}
#endif


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
