//---------------------------------------------------------------------------------------
//  EDMLParser.m created by erik
//  @(#)$Id: EDMLParser.m,v 1.4 2001-04-26 17:04:20 znek Exp $
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

#import <Foundation/Foundation.h>
#import "NSSet+Extensions.h"
#import "EDBitmapCharset.h"
#import "EDObjectPair.h"
#import "EDMLToken.h"
#import "EDMLParser.h"


@interface EDMLParser(PrivateAPI)
- (void)_parserLoop;
- (void)_shift:(EDMLToken *)aToken;
- (BOOL)_reduce;
- (void)_reportClosingTagMismatch:(NSString *)tag;
- (EDMLToken *)_peekedToken;
- (EDMLToken *)_nextToken;
- (id <EDMarkupElement>)_elementWithString:(NSString *)string;
- (id <EDMarkupElement>)_elementWithSpace:(NSString *)string;
- (id <EDMarkupElement>)_elementWithAttributeList:(NSArray *)parsedAttrList;
@end


enum
{
    EDMLPTextMode,
    EDMLPSpaceMode,
    EDMLPTagMode
};

enum
{
    EDMLPT_STRING = 1,
    EDMLPT_SPACE = 2,
    EDMLPT_LT = 3,
    EDMLPT_GT = 4,
    EDMLPT_SLASH = 5,
    EDMLPT_EQ =  6,
    EDMLPT_TSTRING =  7,
    EDMLPT_TATTR =  8,		
    EDMLPT_TATTRLIST =  9,
    EDMLPT_OTAG = 10,
    EDMLPT_CTAG = 11,
    EDMLPT_ELEMENT = 12,
    EDMLPT_LIST = 13
};

/*
#define ALX_RAISE_INVALID_RESPONSE(COMMAND, RESPONSE) \
[[NSException exceptionWithName:ALXNSCOperationException reason:[NSString stringWithFormat:ALXLS_XR_CANNOT_PERFORM_COMMAND, COMMAND] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:self, @"channel", RESPONSE, @"response", nil]] raise];
*/


//---------------------------------------------------------------------------------------
    @implementation EDMLParser
//---------------------------------------------------------------------------------------

NSString *EDMLParserException = @"EDMLParserException";
EDBitmapCharset *idCharset, *spaceCharset, *textCharset;

static __inline__ unichar *nextchar(unichar *charp, BOOL raiseOnEnd)
{
    charp += 1;
    if((raiseOnEnd == YES) && (*charp == (unichar)0))
        [NSException raise:EDMLParserException format:@"Unexpected end of source."];
    return charp;
}


static __inline__ int match(NSArray *stack, int t0, int t1, int t2, int t3, int t4)
{
    int	ti[] = { t4, t3, t2, t1, t0, 0 };
    int	i, sp;

    sp = [stack count] - 1;
    for(i = 0; ti[i] > 0; i++)
        {
        if((sp < 0) || ([(EDMLToken *)[stack objectAtIndex:sp--] type] != ti[i]))
            break;
        }
    return (ti[i] > 0) ? 0 : i;
}


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
    NSMutableCharacterSet	*tempCharset;

    spaceCharset = EDBitmapCharsetFromCharacterSet([NSCharacterSet whitespaceAndNewlineCharacterSet]);
    tempCharset = [[[NSCharacterSet illegalCharacterSet] mutableCopy] autorelease];
    [tempCharset addCharactersInString:@"<>"];
    [tempCharset formUnionWithCharacterSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    [tempCharset invert];
    textCharset = EDBitmapCharsetFromCharacterSet(tempCharset);
    idCharset = EDBitmapCharsetFromCharacterSet([NSCharacterSet alphanumericCharacterSet]);
}


//---------------------------------------------------------------------------------------
//	FACTORY
//---------------------------------------------------------------------------------------

+ (id)parserWithTagDefinitions:(NSDictionary *)someTagDefinitions
{
    return [[[self alloc] initWithTagDefinitions:someTagDefinitions] autorelease];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithTagDefinitions:(NSDictionary *)someTagDefinitions
{
    [super init];
    stack = [[NSMutableArray allocWithZone:[self zone]] init];
    tagDefinitions = [someTagDefinitions retain];
    stringElementDefinition = [[tagDefinitions objectForKey:@"*"] retain];
    spaceElementDefinition = [[tagDefinitions objectForKey:@"_"] retain];
    
    return self;
}


- (void)dealloc
{
    [peekedToken release];
    [stack release];
    [tagDefinitions release];
    [stringElementDefinition release];
    [spaceElementDefinition release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	PUBLIC ENTRY INTO PARSER
//---------------------------------------------------------------------------------------

- (void)setPreservesWhitespace:(BOOL)flag
{
    flags.preservesWhitespace = flag;
}

- (BOOL)preservesWhitespace
{
    return flags.preservesWhitespace;
}


- (void)setAcceptsUnknownAttributes:(BOOL)flag
{
    flags.acceptsUnknownAttributes = flag;
}

- (BOOL)acceptsUnknownAttributes
{
    return flags.acceptsUnknownAttributes;
}


//---------------------------------------------------------------------------------------
//	PUBLIC ENTRY INTO PARSER
//---------------------------------------------------------------------------------------

- (id)parseString:(NSString *)aString
{
    NSArray			*result;
    unsigned int 	length;

    length = [aString length];
    source = NSZoneMalloc([self zone], sizeof(unichar) * (length + 1));
    [aString getCharacters:source];
    *(source + length) = (unichar)0;
    charp = source;

    [self _parserLoop];

    NSZoneFree([self zone], source);
    source = NULL;
    result = [[[[stack lastObject] value] retain] autorelease];
    [stack removeAllObjects];
    [peekedToken release];
    peekedToken = nil;

    return result;
}


//---------------------------------------------------------------------------------------
//	TOKENIZER (LEXER)
//---------------------------------------------------------------------------------------

- (EDMLToken *)_nextToken
{
    EDMLToken	*token;
    id			tvalue;
    unichar		*start;

    if(peekedToken != nil)
        {
        token = peekedToken;
        peekedToken = nil;
        return [token autorelease];
        }

    if(*charp == (unichar)0)
        return nil;

    NSAssert((lexmode == EDMLPTextMode) || (lexmode == EDMLPSpaceMode) || (lexmode == EDMLPTagMode), @"Invalid lexicalizer mode");

    switch(lexmode)
        {
    case EDMLPTextMode:
        if(*charp == '<')
            {
            charp = nextchar(charp, YES);
            if((*charp == '!') || (*charp == '?')) // ignore processing directives and comments
                {
                while(*charp != '>')
                    charp = nextchar(charp, YES);
                charp = nextchar(charp, NO);
                return [self _nextToken];
                }
            token = [EDMLToken tokenWithType:EDMLPT_LT];
            lexmode = EDMLPTagMode;
            break; // we're done and we have to skip the following ifs...
            }
        else if(*charp == '>')
            {
            [NSException raise:EDMLParserException format:@"Syntax Error; found stray `>'.", (int)*charp];
            }
        else if(EDBitmapCharsetContainsCharacter(spaceCharset, *charp))
            {
            lexmode = EDMLPSpaceMode;
            return [self _nextToken];
            }
        else
            {
            start = charp;
            while(EDBitmapCharsetContainsCharacter(textCharset, *charp))
                charp = nextchar(charp, NO);
            if(start == charp) // not at end and neither a text nor a switch char
                [NSException raise:EDMLParserException format:@"Found invalid character \\u%x.", (int)*charp];
            token = [EDMLToken tokenWithType:EDMLPT_STRING];
            [token setValue:[NSString stringWithCharacters:start length:(charp - start)]];
            }
        break;

    case EDMLPSpaceMode:
        start = charp;
        while(EDBitmapCharsetContainsCharacter(spaceCharset, *charp))
            charp = nextchar(charp, NO);
        lexmode = EDMLPTextMode;
        NSAssert(charp != start, @"Entered space mode when not located at a sequence of spaces.");
        token = [EDMLToken tokenWithType:(spaceElementDefinition != nil) ? EDMLPT_SPACE : EDMLPT_STRING];
        if(flags.preservesWhitespace == YES)
            [token setValue:[NSString stringWithCharacters:start length:(charp - start)]];
        else
            [token setValue:@" "];
        break;

    case EDMLPTagMode:
        if(*charp == '<')
            {
            [NSException raise:EDMLParserException format:@"Syntax Error; found `<' in a tag.", (int)*charp];
            }
        else if(*charp == '>')
            {
            charp = nextchar(charp, NO);
            token = [EDMLToken tokenWithType:EDMLPT_GT];
            lexmode = EDMLPTextMode;
            }
        else if(*charp == '/')
            {
            charp = nextchar(charp, YES);
            token = [EDMLToken tokenWithType:EDMLPT_SLASH];
            }
        else if(*charp == '=')
            {
            charp = nextchar(charp, YES);
            token = [EDMLToken tokenWithType:EDMLPT_EQ];
            }
        else
            {
            while(EDBitmapCharsetContainsCharacter(spaceCharset, *charp))
                charp = nextchar(charp, YES);
            if(*charp == '"')
                {
                charp = nextchar(charp, YES);
                start = charp;
                while(*charp != '"')
                    charp = nextchar(charp, YES);
                tvalue = [NSString stringWithCharacters:start length:(charp - start)];
                charp = nextchar(charp, YES);
                }
            else if(*charp == '\'')
                {
                charp = nextchar(charp, YES);
                start = charp;
                while(*charp != '\'')
                    charp = nextchar(charp, YES);
                tvalue = [NSString stringWithCharacters:start length:(charp - start)];
                charp = nextchar(charp, YES);
                }
            else
                {
                start = charp;
                while((EDBitmapCharsetContainsCharacter(idCharset, *charp)))
                    charp = nextchar(charp, YES);
                if(charp == start)
                    [NSException raise:EDMLParserException format:@"Syntax error; expected either `>' or a tag attribute/value. (Note that tag attribute values must be quoted if they contain anything other than alphanumeric characters.)"];
                tvalue = [NSString stringWithCharacters:start length:(charp - start)];
                }
            token = [EDMLToken tokenWithType:EDMLPT_TSTRING];
            [token setValue:tvalue];
            }
        break;
        }

    return token;
}


- (EDMLToken *)_peekedToken
{
    if(peekedToken == nil)
        peekedToken = [[self _nextToken] retain];
    return peekedToken;
}


//---------------------------------------------------------------------------------------
//	SHIFT/REDUCE PARSER
//---------------------------------------------------------------------------------------

- (void)_parserLoop
{
    EDMLToken	*token;

    while((token = [self _nextToken]) != nil)
        {
        [self _shift:token];
        while([self _reduce])
            {}
        }
    if([stack count] > 1)
        [NSException raise:EDMLParserException format:@"Unexpected end of source."];
}


- (void)_shift:(EDMLToken *)token
{
    //NSLog(@"-> %d, %@", [token type], [token value]);
    [stack addObject:token];
}


#define SVAL(IDX) [[stack objectAtIndex:sc - ((IDX) + 1)] value]

- (BOOL)_reduce
{
    EDMLToken 		*rToken;
    int			   	mc, sc;

    sc = [stack count];
    if((mc = match(stack, 0, 0, 0, EDMLPT_LIST, EDMLPT_ELEMENT)) > 0)
        {
        rToken = [[[stack objectAtIndex:sc - 2] retain] autorelease];
        [[rToken value] addObject:SVAL(0)];
        }
    else if((mc = match(stack, 0, 0, 0, 0, EDMLPT_ELEMENT)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_LIST];
        [rToken setValue:[NSMutableArray arrayWithObject:SVAL(0)]];
        }

    else if((mc = match(stack, 0, 0, EDMLPT_OTAG, EDMLPT_LIST, EDMLPT_CTAG)) > 0)
        {
        id <EDMarkupContainerElement> element;

        if([[[SVAL(2) objectAtIndex:0] firstObject] isEqualToString:SVAL(0)] == NO)
            [self _reportClosingTagMismatch:SVAL(0)];
        element = (id <EDMarkupContainerElement>)[self _elementWithAttributeList:SVAL(2)];
        [element setContainedElements:SVAL(1)];
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:element];
        }

    else if((mc = match(stack, 0, EDMLPT_LT, EDMLPT_SLASH, EDMLPT_TATTRLIST, EDMLPT_GT)) > 0)
        {
        NSString	 *tagName = [[SVAL(1) objectAtIndex:0] firstObject];
        NSDictionary *tagDef = [tagDefinitions objectForKey:tagName];

        if(tagDef == nil)
            [NSException raise:EDMLParserException format:@"Unknown tag; found </%@>", tagName];
        else if([[tagDef objectForKey:@"container"] boolValue] == NO)
            [NSException raise:EDMLParserException format:@"Tag <%@> is not a container tag.", tagName];
        else if([SVAL(1) count] != 1)
            [NSException raise:EDMLParserException format:@"Syntax Error; found closing tag with attributes."];
        rToken = [EDMLToken tokenWithType:EDMLPT_CTAG];
        [rToken setValue:[[SVAL(1) objectAtIndex:0] firstObject]];
        }
    else if((mc = match(stack, 0, 0, EDMLPT_LT, EDMLPT_TATTRLIST, EDMLPT_GT)) > 0)
        {
        NSString	 *tagName = [[SVAL(1) objectAtIndex:0] firstObject];
        NSDictionary *tagDef = [tagDefinitions objectForKey:tagName];

        if(tagDef == nil)
            [NSException raise:EDMLParserException format:@"Unknown tag; found <%@>", tagName];
        if([[tagDef objectForKey:@"container"] boolValue] == YES)
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_OTAG];
            [rToken setValue:SVAL(1)];
            }
        else
            {
            rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
            [rToken setValue:[self _elementWithAttributeList:SVAL(1)]];
            }
        }
    else if((mc = match(stack, 0, EDMLPT_LT, EDMLPT_TATTRLIST, EDMLPT_SLASH, EDMLPT_GT)) > 0)
        {
        NSString	 *tagName = [[SVAL(2) objectAtIndex:0] firstObject];
        NSDictionary *tagDef = [tagDefinitions objectForKey:tagName];

        if(tagDef == nil)
            [NSException raise:EDMLParserException format:@"Unknown tag; found <%@>", tagName];
        if([[tagDef objectForKey:@"container"] boolValue] == NO)
            [NSException raise:EDMLParserException format:@"Tag <%@> is not a container tag.", tagName];

        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:[self _elementWithAttributeList:SVAL(2)]];
        }
     
    else if((mc = match(stack, 0, 0, 0, EDMLPT_TATTRLIST, EDMLPT_TATTR)) > 0)
        {
        rToken = [[[stack objectAtIndex:sc - 2] retain] autorelease];
        [[rToken value] addObject:SVAL(0)];
        }
    else if((mc = match(stack, 0, 0, 0, 0, EDMLPT_TATTR)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_TATTRLIST];
        [rToken setValue:[NSMutableArray arrayWithObject:SVAL(0)]];
        }

    else if((mc = match(stack, 0, 0, EDMLPT_TSTRING, EDMLPT_EQ, EDMLPT_TSTRING)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_TATTR];
        [rToken setValue:[EDObjectPair pairWithObjects:[SVAL(2) lowercaseString]:SVAL(0)]];
        }
    else if(((mc = match(stack, 0, 0, 0, 0, EDMLPT_TSTRING)) > 0) &&
            ([[self _peekedToken] type] != EDMLPT_EQ))
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_TATTR];
        [rToken setValue:[EDObjectPair pairWithObjects:SVAL(0):nil]];
        }

    else if((mc = match(stack, 0, 0, 0, EDMLPT_STRING, EDMLPT_STRING)) > 0)
        {
        rToken = [EDMLToken tokenWithType:EDMLPT_STRING];
        [rToken setValue:[SVAL(1) stringByAppendingString:SVAL(0)]];
        }        
    else if(((mc = match(stack, 0, 0, 0, 0, EDMLPT_STRING)) > 0) &&
            ([[self _peekedToken] type] != EDMLPT_STRING))
        {
        id <EDMarkupElement>	element;

        element = [self _elementWithString:SVAL(0)];
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:element];
        }
    else if((mc = match(stack, 0, 0, 0, 0, EDMLPT_SPACE)) > 0)
        {
        id <EDMarkupElement>	element;

        element = [self _elementWithSpace:SVAL(0)];
        rToken = [EDMLToken tokenWithType:EDMLPT_ELEMENT];
        [rToken setValue:element];
        }
    else
        {
        return NO;
        }
        
    [stack removeObjectsInRange:NSMakeRange(sc - mc, mc)];
    if(rToken != nil)
        {
        [stack addObject:rToken];
        //NSLog(@"%d, %@ <- %d", [rToken type], [rToken value], mc);
        }
    else
        {
        //NSLog(@"() <- %d", mc);
        }
    //NSLog(@"stack = %@", stack);
    
    return YES;
}


- (void)_reportClosingTagMismatch:(NSString *)tag
{
    NSEnumerator	*tokenEnum;
    EDMLToken		*token;

    tokenEnum = [stack reverseObjectEnumerator];
    while((token = [tokenEnum nextObject]) != nil)
        {
        if([token type] == EDMLPT_OTAG)
            break;
        }

    if(token != nil)
        {
        [NSException raise:EDMLParserException format:@"Syntax error; found </%@> without matching opening tag. It looks like a </%@> is missing somewhere.", tag, [[[token value] objectAtIndex:0] firstObject]];
        }
    else
        {
        [NSException raise:EDMLParserException format:@"Syntax error; found <%@> without matching opening tag.", tag];
        }

}


//---------------------------------------------------------------------------------------
//	CREATING ELEMENTS
//---------------------------------------------------------------------------------------

- (id <EDMarkupElement>)_elementWithString:(NSString *)string
{
    NSString 			 *className, *attrName;
    id <EDMarkupElement> element;

    NSAssert(stringElementDefinition != nil, @"No definition for string element.");
    className = [stringElementDefinition objectForKey:@"class"];
    NSAssert(className != nil, @"Class entry missing for string element");
    element = [[[NSClassFromString(className) allocWithZone:[self zone]] init] autorelease];
    NSAssert(element != nil, @"Cannot instantiate string element");
    attrName = [stringElementDefinition objectForKey:@"implicit"];
    [element takeValue:string forAttribute:attrName];

    return element;
}


- (id <EDMarkupElement>)_elementWithSpace:(NSString *)string
{
    NSString 			 *className, *attrName;
    id <EDMarkupElement> element;

    NSAssert(spaceElementDefinition != nil, @"No definition for space element.");
    className = [spaceElementDefinition objectForKey:@"class"];
    NSAssert(className != nil, @"Class entry missing for space element");
    element = [[[NSClassFromString(className) allocWithZone:[self zone]] init] autorelease];
    NSAssert(element != nil, @"Cannot instantiate space element");
    // we allow the element to ignore the string because it can assume it is a single space
    // anyway; unless you set preservesWhitespace
    if((attrName = [spaceElementDefinition objectForKey:@"implicit"]) != nil)
        [element takeValue:string forAttribute:attrName];

    return element;
}


- (id <EDMarkupElement>)_elementWithAttributeList:(NSArray *)parsedAttrList
{
    NSString 			 *tagName, *className, *attrName;
    NSDictionary		 *tagDef, *attrDef;
    NSArray				 *attrList;
    NSMutableSet		 *requiredAttributes;
    NSSet				 *knownAttributes;
    NSEnumerator		 *attrEnum;
    EDObjectPair		 *attr;
    id <EDMarkupElement> element;

    tagName = [[parsedAttrList objectAtIndex:0] firstObject];
    if([[parsedAttrList objectAtIndex:0] secondObject] != nil)
        [NSException raise:EDMLParserException format:@"Syntax error; tag names must not have values."];
    tagDef = [tagDefinitions objectForKey:tagName];
    NSAssert1(tagDef != nil, @"No definition for tag %@", tagName);
    className = [tagDef objectForKey:@"class"];
    NSAssert1(className != nil, @"Class entry missing for tag <%@>", tagName);
    element = [[[NSClassFromString(className) allocWithZone:[self zone]] init] autorelease];
    NSAssert1(element != nil, @"Cannot instantiate element for tag <%@>", tagName);

    if((attrList = [tagDef objectForKey:@"implicit"]) != nil)
        {
        attrEnum = [attrList objectEnumerator];
        while((attrDef = [attrEnum nextObject]) != nil)
            {
            attrName = [[attrDef keyEnumerator] nextObject];
            [element takeValue:[attrDef objectForKey:attrName] forAttribute:attrName];
            }
        }

    knownAttributes = requiredAttributes = nil;
    if((attrList = [tagDef objectForKey:@"required"]) != nil)
        {
        requiredAttributes = [NSMutableSet setWithArray:attrList];
        if(flags.acceptsUnknownAttributes == NO)
            knownAttributes = [NSSet setWithSet:requiredAttributes];
        }
    if((flags.acceptsUnknownAttributes == NO) && ((attrList = [tagDef objectForKey:@"optional"]) != nil))
        {
        if(knownAttributes == nil)
            knownAttributes = [NSSet setWithArray:attrList];
        else
            knownAttributes = [knownAttributes setByAddingObjectsFromArray:attrList];
        }
    attrEnum = [parsedAttrList objectEnumerator];
    [attrEnum nextObject];
    while((attr = [attrEnum nextObject]) != nil)
        {
        attrName = [attr firstObject];
        if((flags.acceptsUnknownAttributes == NO) && ([knownAttributes containsObject:attrName] == NO))
            [NSException raise:EDMLParserException format:@"Invalid attribute \"%@\" for tag <%@>.", attrName, tagName];
        [requiredAttributes removeObject:attrName];
        [element takeValue:[attr secondObject] forAttribute:attrName];
        }

    if((requiredAttributes != nil) && ([requiredAttributes count] > 0))
        [NSException raise:EDMLParserException format:@"Required attribute(s) \"%@\" missing in tag <%@>", [[requiredAttributes allObjects] componentsJoinedByString:@", "], tagName];

    return element;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
