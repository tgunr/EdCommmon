//---------------------------------------------------------------------------------------
//  EDXMLTreeWalker.m created by erik on Mon Apr 21 2003
//  @(#)$Id: EDXMLTreeWalker.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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

#import <Foundation/Foundation.h>
#include "EDXMLNode.h"
#include "EDXMLElement.h"
#include "EDXMLTreeWalker.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLTreeWalker
//---------------------------------------------------------------------------------------

/*" This class implements a preorder depth first walk over the tree rooted at a given #{EDXMLNode}. The traversal is %live, and terminates either when that given node is reached when climbing back up, or when a null parent node is reached. It may be restarted via #{reset}.

The way this remains live is to have a %current node to which the walk is tied. If the tree is modified, that current node will always still be valid ... even if it is no longer connected to the rest of the document, or if it's reconnected at a different location. The behavior of tree modifications is specified by DOM, and the interaction with a walker's current node is specified entirely by knowing that only the #{nextSibling}, #{parentNode}, and #{firstChild} methods are used for walking the tree.

For example, if the current branch is cut off, the walk will stop when it tries to access what were parents or siblings of that node. (That is, the walk will continue over the branch that was cut.) If that is not the intended behaviour, one must change the "current" branch before cutting ... much like avoiding trimming a branch off a real tree if someone is sitting on it. The #{removeCurrentNode} method encapsulates that logic. "*/


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

/*" Creates and returns a node walker with the initial node aNode. "*/

+ (EDXMLTreeWalker *)nodeWalkerWithNode:(EDXMLNode *)aNode
{
    return [[[self alloc] initWithNode:aNode] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated node walker with the intial node aNode. "*/

 - (id)initWithNode:(EDXMLNode *)aNode
{
    [super init];
    initialNode = [aNode retain];
    currentNode = initialNode;
    return self;
}


- (void)dealloc
{
    [initialNode release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSING NODES
//---------------------------------------------------------------------------------------

/*" Returns the current node. "*/

- (EDXMLNode *)currentNode
{
    return currentNode;
}


/*" Advances to the next node,  makes that current and returns it."*/

- (EDXMLNode *)nextNode
{
    EDXMLNode *nextNode;
    
    if((nextNode = [currentNode firstChild]) == nil)
        {
        while((nextNode = [currentNode nextSibling]) == nil)
            {
            currentNode = [currentNode parentNode];
            if((currentNode == initialNode) || (currentNode == nil))
                break;
            }
        }
    currentNode = nextNode;
    return currentNode;
}


/*" Convenience method to walk only through elements with the specified tag name. If tagName is '*' the next element will be returned. "*/

- (EDXMLElement *)nextElementWithTagName:(NSString *)tagName
{
    while([self nextNode] != nil)
        {
        if(([currentNode nodeType] == EDXML_ELEMENT_NODE) &&
           ([tagName isEqualToString:@"*"] || [[(id)currentNode tagName] isEqualToString:tagName]))
            break;
        }
    return (id)currentNode;
}


//---------------------------------------------------------------------------------------
//	MODIFYING SEQUENCE
//---------------------------------------------------------------------------------------

/*" Resets the walker to the state in which it was created: the current node will be the node given to the init method. "*/

- (void)reset
{
    currentNode = initialNode;
}


/*" Removes the current node. Then reassigns the current node to be the next one in the current walk that isn't a child of the (removed) current node, and returns that new current node. "*/

- (EDXMLNode *)removeCurrentNode
{
    EDXMLNode *delNode, *nextNode;

    if([currentNode parentNode] == nil)
        [NSException raise:NSInternalInconsistencyException format:@"Walker cannot remove toplevel node."];
    
    delNode = currentNode;
    while((nextNode = [currentNode nextSibling]) == nil)
        {
        currentNode = [currentNode parentNode];
        if((currentNode == initialNode) || (currentNode == nil))
            break;
        }
    [[delNode parentNode] removeChild:currentNode];
    currentNode = nextNode;
    return currentNode;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
