//---------------------------------------------------------------------------------------
//  EDMLParser.h created by erik
//  @(#)$Id: EDMLParser.h,v 1.5 2002-04-14 14:57:55 znek Exp $
//
//  Copyright (c) 1999-2001 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDMLParser_h_INCLUDE
#define	__EDMLParser_h_INCLUDE


#import "EDCommonDefines.h"


@protocol EDMarkupElement
- (void)takeValue:(id)value forAttribute:(NSString *)attribute;
@end

@protocol EDMarkupContainerElement <EDMarkupElement>
- (void)setContainedElements:(NSArray *)elements;
@end


@interface EDMLParser : NSObject
{
    struct {
        unsigned		preservesWhitespace : 1;
        unsigned 		acceptsUnknownAttributes : 1;
    }				flags;
    NSDictionary	*tagDefinitions;
    NSDictionary	*stringElementDefinition;
    NSDictionary	*spaceElementDefinition;
    unichar		 	*source;
    unichar		 	*charp;
    unsigned int 	lexmode;
    id				peekedToken;
    NSMutableArray	*stack;
}

+ (id)parserWithTagDefinitions:(NSDictionary *)someTagDefinitions;

- (id)initWithTagDefinitions:(NSDictionary *)someTagDefinitions;

- (void)setPreservesWhitespace:(BOOL)flag;
- (BOOL)preservesWhitespace;

- (void)setAcceptsUnknownAttributes:(BOOL)flag;
- (BOOL)acceptsUnknownAttributes;

- (NSArray *)parseString:(NSString *)aString;

// for subclassers
- (NSDictionary *)tagDefinitionForTagNamed:(NSString *)tagName;

@end


EDCOMMON_EXTERN NSString *EDMLParserException;

#endif	/* __EDMLParser_h_INCLUDE */
