//---------------------------------------------------------------------------------------
//  EDXMLNode+Private.h created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLNode+Private.h,v 1.1 2003-05-26 19:52:35 erik Exp $
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

#ifndef	__EDXMLNode_Private_h_INCLUDE
#define	__EDXMLNode_Private_h_INCLUDE

#include "EDXMLNode.h"
#include "EDXMLElement.h"
#include "EDXMLAttribute.h"
#include "EDXMLCharacterData.h"


enum {
    DOM_UNKNOWN_NODE                = 0,
    DOM_ATTRIBUTE_NODE              = 1,
    DOM_CDATA_SECTION_NODE          = 2,
    DOM_COMMENT_NODE                = 3,
    DOM_DOCUMENT_FRAGMENT_NODE      = 4,
    DOM_DOCUMENT_NODE               = 5,
    DOM_DOCUMENT_TYPE_NODE          = 6,
    DOM_ELEMENT_NODE                = 7,
    DOM_ENTITY_NODE                 = 8,
    DOM_ENTITY_REFERENCE_NODE       = 9,
    DOM_NOTATION_NODE               = 10,
    DOM_PROCESSING_INSTRUCTION_NODE = 11,
    DOM_TEXT_NODE                   = 12
};


@interface EDXMLNode(Private)
- (id)subclassResponsibility:(SEL)_selector;
- (void)_setOwnerNode:(EDXMLNode *)_node;
- (void)_setIsOwned:(BOOL)flag;
- (BOOL)_isOwned;
- (NSMutableArray *)_childNodes;
- (BOOL)_isValidChildNode:(EDXMLNode *)_node;
- (void)_domNodeRegisterParentNode:(id)_parentNode;
- (void)_domNodeForgetParentNode:(id)_parentNode;
- (EDXMLNodeList *)_getElementsByTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri;
@end

@interface EDXMLElement(Private)
- (id)initWithTagName:(NSString *)_tagName;
- (id)initWithTagName:(NSString *)_tagName namespaceURI:(NSString *)_uri;
@end

@interface EDXMLAttribute(Private)
- (id)initWithName:(NSString *)_name;
- (id)initWithName:(NSString *)_name namespaceURI:(NSString *)_uri;
@end

@interface EDXMLCharacterData(Private)
- (id)initWithString:(NSString *)_s;
@end


#endif	/* __EDXMLNode_Private_h_INCLUDE */
