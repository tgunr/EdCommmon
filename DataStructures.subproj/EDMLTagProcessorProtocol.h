//---------------------------------------------------------------------------------------
//  EDMLTagProcessorProtocol.h created by erik
//  @(#)$Id: EDMLTagProcessorProtocol.h,v 1.1 2002-07-09 16:02:18 erik Exp $
//
//  Copyright (c) 2002 by Erik Doernenburg. All rights reserved.
//
//  Permission to use, copy, modify and distribute this software and its documentation
//  is hereby granted, provided that both the copyright notice and this permission
//  notice appear in all copies of the software, derivative works or modified versions,
//  and any portions thereof, and that both notices appear in supporting documentation,
//  and that credit is given to Erik Doernenburg in all documents and publicity
//  pertaining to direct or indirect use of this code or its derivatives.
//
//  THIS IS EXPERIMENTAL SOFTWARE AND IT IS KNOWN TO HAVE BUGS, SOME OF WHICH MAY HAVE
//  SERIOUS CONSEQUENCES. THE COPYRIGHT HOLDER ALLOWS FREE USE OF THIS SOFTWARE IN ITS
//  "AS IS" CONDITION. THE COPYRIGHT HOLDER DISCLAIMS ANY LIABILITY OF ANY KIND FOR ANY
//  DAMAGES WHATSOEVER RESULTING DIRECTLY OR INDIRECTLY FROM THE USE OF THIS SOFTWARE
//  OR OF ANY DERIVATIVE WORK.
//---------------------------------------------------------------------------------------


#ifndef	__EDMLTagProcessorProtocol_h_INCLUDE
#define	__EDMLTagProcessorProtocol_h_INCLUDE


#import "EDCommonDefines.h"

@class EDObjectPair;

/*" Used to classify elements. See #{typeOfElementForTag:attributeList:} for details. "*/
typedef enum
{
    EDMLUnknownTag,
    EDMLSingleElement,
    EDMLContainerElement
} EDMLElementType;


@protocol EDMLTagProcessor < NSObject >
- (NSString *)defaultNamespace;
- (BOOL)spaceIsString;
- (EDMLElementType)typeOfElementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList;
- (id)elementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList;
- (id)elementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList containedElements:(NSArray *)containedElements;
- (id)objectForText:(NSString *)string;
- (id)objectForSpace:(NSString *)string;
@end


#endif	/* __EDMLTagProcessorProtocol_h_INCLUDE */
