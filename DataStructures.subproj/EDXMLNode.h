//---------------------------------------------------------------------------------------
//  EDXMLNode.h created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLNode.h,v 1.1 2003-05-26 19:52:35 erik Exp $
//
//  Copyright (c) 2002-2003 by Helge Hess, Erik Doernenburg. All rights reserved.
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

#ifndef __EDXMLNode_h_INCLUDE
#define __EDXMLNode_h_INCLUDE

@class EDXMLNamedNodeMap, EDXMLNodeList, EDXMLDocument;


typedef enum {
    EDXML_UNKNOWN_NODE         		= 0,
    EDXML_ATTRIBUTE_NODE            = 1,
    EDXML_DOCUMENT_FRAGMENT_NODE    = 4,
    EDXML_DOCUMENT_NODE             = 5,
    EDXML_ELEMENT_NODE              = 7,
    EDXML_TEXT_NODE                 = 12
} EDXMLNodeType;

typedef enum {
    EDXML_NF_HASPARENT				= 0x01
} EDXMLNodeFlags;


@interface EDXMLNode : NSObject
{
    unsigned short 	flags;
    EDXMLNode		*ownerNode;
}

/*" Setting and retrieving basic attributes (DOM) "*/
- (EDXMLNodeType)nodeType;
- (NSString *)nodeName;
- (NSString *)localName;
- (NSString *)namespaceURI;
- (void)setPrefix:(NSString *)_prefix;
- (NSString *)prefix;
- (void)setNodeValue:(NSString *)_value;
- (NSString *)nodeValue;

/*" Retrieving XML attributes (DOM) "*/
- (BOOL)hasAttributes;
- (EDXMLNamedNodeMap *)attributes;

/*" Navigating children/owner (DOM) "*/
- (EDXMLDocument *)ownerDocument;
- (EDXMLNode *)parentNode;

- (EDXMLNode *)previousSibling;
- (EDXMLNode *)nextSibling;

- (EDXMLNodeList *)childNodes;
- (BOOL)hasChildNodes;
- (EDXMLNode *)firstChild;
- (EDXMLNode *)lastChild;

/*" Modifying the node's children (DOM) "*/
- (EDXMLNode *)appendChild:(EDXMLNode *)_node;
- (EDXMLNode *)removeChild:(EDXMLNode *)_node;
- (EDXMLNode *)replaceChild:(EDXMLNode *)_oldNode with:(EDXMLNode *)_newNode;
- (EDXMLNode *)insert:(EDXMLNode *)_newNode before:(EDXMLNode *)_refNode;
- (void)normalize;

/*" Cloning a node (DOM) "*/
- (void)cloneNode:(BOOL)_deep;

/*" Retrieving contents "*/
- (NSString *)nodeTypeString;
- (NSString *)xmlStringValue;
- (NSData *)xmlDataValue;
- (NSString *)textValue;

@end


@interface EDXMLParentNode : EDXMLNode
{
    NSMutableArray *childNodes; /*" All instance variables are private. "*/
}

@end


@interface EDXMLNamedParentNode : EDXMLParentNode
{
    NSString *nodeName;			/*" All instance variables are private. "*/
    NSString *namespaceURI;		/*" "*/
}

@end


#endif /*  __EDXMLNode_h_INCLUDE */
