//---------------------------------------------------------------------------------------
//  EDXMLDOMTagProcessor.m created by erik on Sun Mar 09 2003
//  @(#)$Id: EDXMLDOMTagProcessor.m,v 1.1 2003-05-26 19:52:35 erik Exp $
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
#include "NSString+Extensions.h"
#include "EDObjectPair.h"
#include "EDMLParser.h"
#include "EDXMLDocument.h"
#include "EDXMLElement.h"
#include "EDXMLText.h"
#include "EDXMLDOMTagProcessor.h"


//=======================================================================================
    @implementation EDXMLDOMTagProcessor
//=======================================================================================

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)init
{
    [super init];
    return self;
}

- (void)dealloc
{
    [document release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)setDocument:(EDXMLDocument *)aDocument
{
    [document autorelease];
    document = [aDocument retain];
}


- (EDXMLDocument *)document
{
    return document;
}


//---------------------------------------------------------------------------------------
//	SETUP / TEAR DOWN
//---------------------------------------------------------------------------------------

- (void)parserWillBeginParsing:(EDMLParser *)aParser
{
    if(document == nil)
        document = [[EDXMLDocument alloc] init];
}


//---------------------------------------------------------------------------------------
//	PROCESSOR PROTOCOL
//---------------------------------------------------------------------------------------

- (id)documentForElements:(NSArray *)elementList
{
    NSEnumerator	*elementEnum;
    EDXMLNode		*node;
    EDXMLElement	*rootElement;

    rootElement = nil;
    elementEnum = [elementList objectEnumerator];
    while((node = [elementEnum nextObject]) != nil)
        {
        if([node nodeType] != EDXML_ELEMENT_NODE)
            continue;
        if(rootElement != nil)
            [NSException raise:EDMLParserException format:@"Found more than one root element."];
        rootElement = [node retain];
        }
    if(rootElement == nil)
        [NSException raise:EDMLParserException format:@"No root element."];

    [document appendChild:rootElement];

    return document;
    
}

- (NSString *)defaultNamespace
{
    return nil;
}

- (BOOL)spaceIsString
{
    return YES;
}

- (EDMLElementType)typeOfElementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList
{
    return EDMLContainerElement;
}

- (id)elementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList
{
    EDXMLElement	*newElement;
    NSEnumerator	*attrEnum;
    EDObjectPair	*attr;

    if([tagName firstObject] == nil)
        newElement = [document createElement:[tagName secondObject]];
    else
        newElement = [document createElement:[tagName secondObject] namespaceURI:[tagName firstObject]];
    attrEnum = [attrList objectEnumerator];
    while((attr = [attrEnum nextObject]) != nil)
        {
        if([[attr firstObject] firstObject] == nil)
            [newElement setAttribute:[[attr firstObject] secondObject] value:[attr secondObject]];
        else
            [newElement setAttribute:[[attr firstObject] secondObject] namespaceURI:[[attr firstObject] firstObject] value:[attr secondObject]];
        }
    return newElement;
}

- (id)elementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList containedElements:(NSArray *)containedElements
{
    EDXMLElement	*newElement;
    EDXMLNode		*childNode;
    NSEnumerator	*childEnum;

    newElement = [self elementForTag:tagName attributeList:attrList];
    childEnum = [containedElements objectEnumerator];
    while((childNode = [childEnum nextObject]) != nil)
        {
        if(([childNode nodeType] != EDXML_TEXT_NODE) || ([[(EDXMLText *)childNode data] isWhitespace] == NO))
            [newElement appendChild:childNode];
        }

    return newElement;
}

- (id)objectForText:(NSString *)string
{
    return [document createTextNode:string];
}

- (id)objectForSpace:(NSString *)string
{
    // this is never called (cf. spaceIsString)
    return nil;
}


//=======================================================================================
    @end
//=======================================================================================
