//---------------------------------------------------------------------------------------
//  EDXMLElement.h created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLElement.h,v 1.1 2003-05-26 19:52:35 erik Exp $
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

#ifndef	__EDXMLElement_h_INCLUDE
#define	__EDXMLElement_h_INCLUDE

#include "EDXMLNode.h"

@class EDXMLNodeList, EDXMLAttribute;


@interface EDXMLElement : EDXMLNamedParentNode
{
    EDXMLNamedNodeMap	*attrNodeMap;
}


/*" Basic attributes "*/
- (NSString *)tagName;

/*" Accessing attributes by name (DOM) "*/
- (void)setAttribute:(NSString *)_attrName value:(NSString *)_value;
- (void)removeAttribute:(NSString *)_attrName;
- (BOOL)hasAttribute:(NSString *)_attrName;
- (NSString *)attribute:(NSString *)_attrName;
- (EDXMLAttribute *)setAttributeNode:(EDXMLAttribute *)_attrNode;
- (EDXMLAttribute *)removeAttributeNode:(EDXMLAttribute *)_attrNode;
- (EDXMLAttribute *)attributeNode:(NSString *)_attrName;

/*" Accessing attributes by qualified name (DOM2) "*/
- (void)setAttribute:(NSString *)_qualifiedName namespaceURI:(NSString *)_uri value:(NSString *)_value;
- (void)removeAttribute:(NSString *)_attrName namespaceURI:(NSString *)_uri;
- (BOOL)hasAttribute:(NSString *)_localName namespaceURI:(NSString *)_uri;
- (NSString *)attribute:(NSString *)_localName namespaceURI:(NSString *)_uri;
- (EDXMLAttribute *)setAttributeNodeNS:(EDXMLAttribute *)_attrNode;
- (EDXMLAttribute *)removeAttributeNodeNS:(EDXMLAttribute *)_attrNode;
- (EDXMLAttribute *)attributeNode:(NSString *)_attrName namespaceURI:(NSString *)_uri;

/*" Finding sub-elements "*/
- (EDXMLNodeList *)getElementsByTagName:(NSString *)_tagName;
- (EDXMLNodeList *)getElementsByTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri;

@end

#endif	/* __EDXMLElement_h_INCLUDE */
