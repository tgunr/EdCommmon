//---------------------------------------------------------------------------------------
//  EDXMLTreeWalkerTests.m created by erik on Sat May 24 2003
//  @(#)$Id: EDXMLTreeWalkerTests.m,v 1.1 2003-05-26 19:56:13 erik Exp $
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
#include "EDXMLTreeWalkerTests.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLTreeWalkerTests
//---------------------------------------------------------------------------------------

/*
   We are using the following tree which, I think, covers all possible cases. Note that
   with the exception of node D which is a text node, all nodes are elements. All of them
   are foos but E is a bar.
 
     /--- B --- C
    A      \--- D
     \--- E --- F

 */

- (void)setUp
{
    document = [[EDXMLDocument alloc] init];
    nodeA = [document createElement:@"foo"];
    [document appendChild:nodeA];
    nodeB = [document createElement:@"foo"];
    [nodeA appendChild:nodeB];
    nodeC = [document createElement:@"foo"];
    [nodeB appendChild:nodeC];
    nodeD = [document createTextNode:@"some text"];
    [nodeB appendChild:nodeD];
    nodeE = [document createElement:@"bar"];
    [nodeA appendChild:nodeE];
    nodeF = [document createElement:@"foo"];
    [nodeE appendChild:nodeF];
}


- (void)tearDown
{
    [document release];
}


- (void)testFullWalk
{
    EDXMLTreeWalker	*walker;
    
    walker = [[[EDXMLTreeWalker alloc] initWithNode:nodeA] autorelease];
    should1(nodeA == [walker currentNode], @"Init failed.");
    should1(nodeB == [walker nextNode], @"Wrong sequence.");
    should1(nodeC == [walker nextNode], @"Wrong sequence.");
    should1(nodeD == [walker nextNode], @"Wrong sequence.");
    should1(nodeE == [walker nextNode], @"Wrong sequence.");
    should1(nodeF == [walker nextNode], @"Wrong sequence.");
    should1(nil   == [walker nextNode], @"Wrong sequence.");
}


- (void)testPartialWalkWithReset
{
    EDXMLTreeWalker	*walker;

    walker = [[[EDXMLTreeWalker alloc] initWithNode:nodeE] autorelease];
    should1(nodeE == [walker currentNode], @"Init failed.");
    should1(nodeF == [walker nextNode], @"Wrong sequence.");
    [walker reset];
    should1(nodeE == [walker currentNode], @"Reset failed.");
    should1(nodeF == [walker nextNode], @"Wrong sequence.");
}


- (void)testFullWalkWithElementWildcard
{
    EDXMLTreeWalker	*walker;

    walker = [[[EDXMLTreeWalker alloc] initWithNode:nodeA] autorelease];
    should1(nodeA == [walker currentNode], @"Init failed.");
    should1(nodeB == [walker nextElementWithTagName:@"*"], @"Wrong sequence.");
    should1(nodeC == [walker nextElementWithTagName:@"*"], @"Wrong sequence.");
    should1(nodeE == [walker nextElementWithTagName:@"*"], @"Wrong sequence.");
    should1(nodeF == [walker nextElementWithTagName:@"*"], @"Wrong sequence.");
    should1(nil   == [walker nextElementWithTagName:@"*"], @"Wrong sequence.");
}


- (void)testFullWalkWithElementName
{
    EDXMLTreeWalker	*walker;

    walker = [[[EDXMLTreeWalker alloc] initWithNode:nodeA] autorelease];
    should1(nodeA == [walker currentNode], @"Init failed.");
    should1(nodeB == [walker nextElementWithTagName:@"foo"], @"Wrong sequence.");
    should1(nodeC == [walker nextElementWithTagName:@"foo"], @"Wrong sequence.");
    should1(nodeF == [walker nextElementWithTagName:@"foo"], @"Wrong sequence.");
    should1(nil   == [walker nextElementWithTagName:@"foo"], @"Wrong sequence.");
}


- (void)testRemoveNode
{
    EDXMLTreeWalker	*walker;

    walker = [[[EDXMLTreeWalker alloc] initWithNode:nodeA] autorelease];
    should1(nodeA == [walker currentNode], @"Init failed.");
    should1(nodeB == [walker nextNode], @"Wrong sequence.");
    should1(nodeE == [walker removeCurrentNode], @"Wrong sequence.");

    walker = [[[EDXMLTreeWalker alloc] initWithNode:nodeA] autorelease];
    should1(nodeA == [walker currentNode], @"Init failed.");
    should1(nodeE == [walker nextNode], @"Wrong sequence.");
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
