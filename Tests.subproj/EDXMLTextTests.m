//---------------------------------------------------------------------------------------
//  EDXMLTextTests.m created by erik on Mon Apr 21 2003
//  @(#)$Id: EDXMLTextTests.m,v 1.1 2003-05-26 19:56:13 erik Exp $
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
#include "EDXMLTextTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLTextTests
//---------------------------------------------------------------------------------------

static NSString *SampleText = @"Lorem ipsum...";


- (void)setUp
{
    document = [[EDXMLDocument alloc] init];
    textNode = [document createTextNode:SampleText];
    [document appendChild:textNode];
}


- (void)tearDown
{
    [textNode release];
    [document release];
}


// These tests are actually testing the superclass but that is abstract and it
// needs to be tested somewhere...

- (void)testSetData
{
    shouldnt1([[textNode data] isEqualToString:@"foo"], @"Node initialised with sample text.");
    [textNode setData:@"foo"];
    shouldBeEqual1(@"foo", [textNode data], @"Data differs from the data set before.");
}


- (void)testSubstring
{
    NSString *nodeSubstring;

    nodeSubstring = [textNode substringData:6 count:5];
    shouldBeEqual1(@"ipsum", nodeSubstring, @"Wrong substring.");
}


- (void)testAppendData
{
    [textNode setData:@"Tic Tac"];
    [textNode appendData:@" Toe"];
    shouldBeEqual1(@"Tic Tac Toe", [textNode data], @"Wrong data after appending.");
}


- (void)testInsertData
{
    [textNode setData:@"Tic Toe"];
    [textNode insertData:@"Tac " offset:4];
    shouldBeEqual1(@"Tic Tac Toe", [textNode data], @"Wrong data after insertion.");
}


- (void)testDeleteData
{
    [textNode setData:@"Tic Tac Toe"];
    [textNode deleteData:3 count:4];
    shouldBeEqual1(@"Tic Toe", [textNode data], @"Wrong data after deleting.");
}


- (void)testReplaceData
{
    [textNode setData:@"Tic Tac Toe"];
    [textNode replaceData:4 count:3 with:@"or"];
    shouldBeEqual1(@"Tic or Toe", [textNode data], @"Wrong data after replacing.");
}


// Tests for methods in Text

- (void)testSplitText
{
    EDXMLText	*newNode;
    
    [textNode setData:@"Tic Tac"];
    newNode = [textNode splitText:4];
    should1(newNode != nil, @"Failed to create a new node");
    shouldBeEqual1(@"Tic ", [textNode data], @"Wrong data in old node after splitting.");
    shouldBeEqual1(@"Tac", [newNode data], @"Wrong data in new node after splitting.");
    should1([textNode nextSibling] == newNode, @"New node not sibling of old node.");
}


- (void)testWhitespace
{
    should1([textNode isWhitespaceInElementContent], @"Whitespace not seen in sample.");
    [textNode setData:@"Tic"];
    shouldnt1([textNode isWhitespaceInElementContent], @"Whitespace seen in text without.");
}


#warning * ignoring some tests
#if 0
- (void)testWholeText
{
    EDXMLElement	*parent;
    EDXMLText		*first, *middle, *last;

    parent = [document createElement:@"parent"];
    [parent appendChild:[document createElement:@"block"]];
    first = (EDXMLText *)[parent appendChild:[document createTextNode:@"Tic "]];
    middle = (EDXMLText *)[parent appendChild:[document createTextNode:@"Tac "]];
    last = (EDXMLText *)[parent appendChild:[document createTextNode:@"Toe"]];

    shouldBeEqual1(@"Tic Tac Toe", [first wholeText], @"Whole text wrong.");
    shouldBeEqual1(@"Tic Tac Toe", [middle wholeText], @"Whole text wrong.");
    shouldBeEqual1(@"Tic Tac Toe", [last wholeText], @"Whole text wrong.");
}


- (void)testReplaceWholeText
{
    EDXMLElement	*parent, *block;
    EDXMLText		*first, *middle, *last, *new;

    parent = [document createElement:@"parent"];
    block = (EDXMLElement *)[parent appendChild:[document createElement:@"block"]];
    first = (EDXMLText *)[parent appendChild:[document createTextNode:@"Tic "]];
    middle = (EDXMLText *)[parent appendChild:[document createTextNode:@"Tac "]];
    last = (EDXMLText *)[parent appendChild:[document createTextNode:@"Toe"]];

    new = [middle replaceWholeText:@"Foo"];
    should1([new parentNode] == parent, @"Wrong parent for new node.");
    should1([new previousSibling] == block, @"Wrong previous sibling for new node.");
    should1([new nextSibling] == nil, @"New node has a next sibling.");
    shouldBeEqual1(@"Tic Tac Toe", [new data], @"Data wrong for new node.");
    shouldBeEqual1(@"Tic Tac Toe", [new wholeText], @"Whole text wrong for new node.");
}
#endif    

//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
