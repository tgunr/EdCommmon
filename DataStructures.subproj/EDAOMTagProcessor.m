//---------------------------------------------------------------------------------------
//  EDAOMTagProcessor.m created by erik
//  @(#)$Id: EDAOMTagProcessor.m,v 1.1 2002-07-09 16:08:41 erik Exp $
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

#import <Foundation/Foundation.h>
#import "NSSet+Extensions.h"
#import "EDCommonDefines.h"
#import "EDObjectPair.h"
#import "EDMLParser.h"
#import "EDAOMTagProcessor.h"


//=======================================================================================
    @implementation EDAOMTagProcessor
//=======================================================================================

/*" Application Object Model tag processor. (For use with the EDMLParser.) This tag processor creates an object model of the original document in which the node classes are application specific. A "tag definition dictionary" describes the mapping.

The tag definition dictionary contains the elements' namespace (optional), the model classes to be used for text and for whitespace (optional) as well as the ones to be used for elements. Text objects must implement the #{setText:} method while Space objects may implement it to get the exact space string. (This also requires to set #preservesWhitespace in the parser as otherwise the space string will always be !{@" "}.) All elements must implement #{takeValue:forAttribute:} which is called once for each attribute and all container elements must implement #{setContainedObjects:} which will be called after #{takeValue:forAttribute:} to set the elements, and text/space objects, that were found between the start and end tags. The array is !{nil} if the element was empty.

Note that if #acceptsUnknownTags is YES and multiple namespaces occur in the document #{takeValue:forAttribute:} will be called for %all attributes without indiciation of the attribute's namespace. Note also that if this is the case and additionally no namespace is defined for the elements, they will be asked to take values for attributes that correspond to the namespace definition, e.g. for the tag !{<mytag xmlns:t="...">} the element representing !{mytag} will be asked to take a value for the attribute t. The obvious workaround is to define a namespace for your elements; not a bad idea anyway when dealing with XML.

See !{TagDefinitions.html} for a detailed description of the tag definition dictionary. (Sorry, but autodoc doesn't allow custom hyperlinks.)

The processor implements the #EDTagProcessorProtocol as follows: It returns the namespace defined in the tag definition dictionary, or !{nil} if there is none, as #{defaultNamespace}. If a space object was defined it returns YES in #spaceIsString, otherwise it returns NO which will make the parser treat all space between tags as text. The remaining four methods to create text and space objects as well as elements simply instantiate a corresponding object, set all properties and return it to the parser.

A convenience method is provided to use the EDMLParser with this processor. This reduces the code required to set up a parser to: !{  

NSDictionary 	*myTagDefinitions; // assume this exists
NSString		*myDocument;  // assume this exists
EDMLParser		*parser;
NSArray			*toplevelElements;

parser = [EDMLParser parserWithTagDefinitions:myTagDefinitions];
toplevelElements = [parser parseString:myDocument];
}

"*/

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

/*" Initialises a newly allocated tag processor by setting the tag definitions to %someTagDefinitions. "*/

- (id)initWithTagDefinitions:(NSDictionary *)someTagDefinitions
{
    [super init];

    flags.ignoresUnknownNamespaces = YES;
    tagDefinitions = [someTagDefinitions retain];

    if((textObjectDefinition = [[tagDefinitions objectForKey:@"*"] retain]) != nil)
        {
        NSString *className = [textObjectDefinition objectForKey:@"class"];
        NSAssert(className != nil, @"Class entry missing for text");
        flags.textRespondsToSetText = [NSClassFromString(className) instancesRespondToSelector:@selector(setText:)];
        }
    if((spaceObjectDefinition = [[tagDefinitions objectForKey:@"_"] retain]) != nil)
        {
        NSString *className = [spaceObjectDefinition objectForKey:@"class"];
        NSAssert(className != nil, @"Class entry missing for space");
        flags.spaceRespondsToSetText = [NSClassFromString(className) instancesRespondToSelector:@selector(setText:)];
        // we allow the object to ignore the string because it can assume it is a single space
        // anyway; unless you set preservesWhitespace
        if((flags.spaceRespondsToSetText == NO) && ([spaceObjectDefinition objectForKey:@"implicit"] == nil))
            flags.spaceIgnoresString = YES;
        }
    
    return self;
}


- (void)dealloc
{
    [tagDefinitions release];
    [textObjectDefinition release];
    [spaceObjectDefinition release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

/*" Controls unknown namespace handling. If set to NO the tag processor raises an exception whenever it encounters a tag or an attribute from a namespace that is different from the namespace defined in the tag definitions.

If set to YES, the processor returns !{EDMLUnknownTag} to the parser which results in the tag to treated as a string. (See #EDMLTagProcessorProtocol for more details.) Attributes from unknown namespace are simply ignored, i.e. #{takeValue:forAttribute:} is not called for these.

The default is not to ignore unknown namespaces."*/ 

- (void)setIgnoresUnknownNamespaces:(BOOL)flag
{
    flags.ignoresUnknownNamespaces = flag;
}


/*" Returns whether the processor ignores unknown namespaces. See #{setIgnoresUnknownNamespaces:} for details. "*/

- (BOOL)ignoresUnknownNamespaces
{
    return flags.ignoresUnknownNamespaces;
}


/*" Controls unknown tag handling. If set to NO the tag processor raises an exception whenever it encounters an unknown tag from the namespace defined in the tag definitions. If it encounters a tag from a different namespace, behaviour depends on the #ignoresUnknownNamespaces setting.

If set to YES, the processor returns, regardless of the tag's namespace, !{EDMLUnknownTag} to the parser which results in the tag to treated as a string. (See #EDMLTagProcessorProtocol for more details.) 

The default is not to ignore unknown tags."*/

- (void)setIgnoresUnknownTags:(BOOL)flag
{
    flags.ignoresUnknownTags = flag;
}


/*" Returns whether the processor ignores unknown tags. See #{setIgnoresUnknownTags:} for details. "*/

- (BOOL)ignoresUnknownTags
{
    return flags.ignoresUnknownTags;
}


/*" Controls unknown attribute handling. If set to NO the tag processor raises an exception whenever it encounters an unknown attribute from the namespace defined in the tag definitions. (Unless acceptsUnknownAttributes is set to YES.) If it encounters an attribute from a different namespace, behaviour depends on the #ignoresUnknownNamespaces setting.

If set to YES, the processor ignores the attribute, i.e. #{takeValue:forAttribute:} is not called for these. Note that there is an interdependency with the #acceptsUnknownAttributes setting as not both can be set to YES at the same time and the other is automatically reset if this one is set.

The default is not to ignore unknown attributes. "*/

- (void)setIgnoresUnknownAttributes:(BOOL)flag
{
    if(flag)
        flags.acceptsUnknownAttributes = NO;
    flags.ignoresUnknownAttributes = flag;
}


/*" Returns whether the processor ignores unknown attributes. See #{setIgnoresUnknownAttributes:} for details. "*/

- (BOOL)ignoresUnknownAttributes
{
    return flags.ignoresUnknownAttributes;
}


/*" Controls unknown attribute handling. If set to NO the tag processor raises an exception whenever it encounters an unknown attribute from the namespace defined in the tag definitions. (Unless ignoresUnknownAttributes is set to YES.) If it encounters an attribute from a different namespace, behaviour depends on the #ignoresUnknownNamespaces setting.

If set to YES, the processor calls #{takeValue:forAttribute:} for unknown attributes, from all namespaces. Note that there is an interdependency with the #ignoresUnknownAttributes setting as not both can be set to YES at the same time and the other is automatically reset if this one is set.

The default is not to accept unknown attributes. "*/

- (void)setAcceptsUnknownAttributes:(BOOL)flag
{
    if(flag)
        flags.ignoresUnknownAttributes = NO;
    flags.acceptsUnknownAttributes = flag;
}


/*" Returns whether the processor accepts unknown attributes. See #{setAcceptsUnknownAttributes:} for details. "*/

- (BOOL)acceptsUnknownAttributes
{
    return flags.acceptsUnknownAttributes;
}


//---------------------------------------------------------------------------------------
//	PROCESSOR PROTOCOL
//---------------------------------------------------------------------------------------

- (NSString *)defaultNamespace
{
    return [tagDefinitions objectForKey:@"XMLNS"];
}


- (BOOL)spaceIsString
{
    return (spaceObjectDefinition == nil);
}


- (EDMLElementType)typeOfElementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)attrList
{
    NSDictionary *tagDef;

    // test this way to make sure that a *nil* defaultNamespace works as expected
    if(([tagName firstObject] != [self defaultNamespace]) && ([[tagName firstObject] isEqualToString:[self defaultNamespace]] == NO))
        {
        if(flags.ignoresUnknownNamespaces || flags.ignoresUnknownTags)
            return EDMLUnknownTag;
        [NSException raise:EDMLParserException format:@"Unknown namespace %@", [tagName firstObject]];
        }

    if((tagDef = [tagDefinitions objectForKey:[tagName secondObject]]) == nil)
        {
        if(flags.ignoresUnknownTags)
            return EDMLUnknownTag;
        [NSException raise:EDMLParserException format:@"Unknown tag %@", [tagName secondObject]];
        }

    return ([[tagDef objectForKey:@"container"] boolValue] ? EDMLContainerElement : EDMLSingleElement);
}


- (id)elementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)parsedAttrList
{
    NSString 			 *className, *attrName, *attrNamespace;
    NSDictionary		 *tagDef, *attrDef;
    NSArray				 *attrList;
    NSMutableSet		 *requiredAttributes;
    NSSet				 *knownAttributes;
    NSEnumerator		 *attrEnum;
    EDObjectPair		 *attr;
    id <EDMarkupElement> element;

    tagDef = [tagDefinitions objectForKey:[tagName secondObject]];
    NSAssert1(tagDef != nil, @"No definition for tag %@", [tagName secondObject]);
    className = [tagDef objectForKey:@"class"];
    NSAssert1(className != nil, @"Class entry missing for tag <%@>", [tagName secondObject]);
    element = [[[NSClassFromString(className) allocWithZone:[self zone]] init] autorelease];
    NSAssert1(element != nil, @"Cannot instantiate element for tag <%@>", [tagName secondObject]);

    // feed implicit attribute values
    if((attrList = [tagDef objectForKey:@"implicit"]) != nil)
        {
        attrEnum = [attrList objectEnumerator];
        while((attrDef = [attrEnum nextObject]) != nil)
            {
            attrName = [[attrDef keyEnumerator] nextObject];
            [element takeValue:[attrDef objectForKey:attrName] forAttribute:attrName];
            }
        }

    // collect known and required attributes
    knownAttributes = requiredAttributes = nil;
    if((attrList = [tagDef objectForKey:@"required"]) != nil)
        {
        requiredAttributes = [NSMutableSet setWithArray:attrList];
        knownAttributes = [NSSet setWithSet:requiredAttributes];
        }
    if((attrList = [tagDef objectForKey:@"optional"]) != nil)
        {
        if(knownAttributes == nil)
            knownAttributes = [NSSet setWithArray:attrList];
        else
            knownAttributes = [knownAttributes setByAddingObjectsFromArray:attrList];
        }

    attrEnum = [parsedAttrList objectEnumerator];
    while((attr = [attrEnum nextObject]) != nil)
        {
        attrNamespace = [[attr firstObject] firstObject];
        attrName = [[attr firstObject] secondObject];

        // If we have a namespace, we can detect and ignore xmlns attributes
        if(([self defaultNamespace] != nil) && (attrNamespace == nil))
            continue;

        // Check namespace, raise or ignore if unknown
        if((attrNamespace != [self defaultNamespace]) && ([attrNamespace isEqualToString:[self defaultNamespace]] == NO) && (flags.acceptsUnknownAttributes == NO))
            {
            if(flags.ignoresUnknownNamespaces)
                continue;
            [NSException raise:EDMLParserException format:@"Invalid attribute \"%@\" for tag <%@>.", attrName, [tagName secondObject]];
            }
        // Check name, raise or ignore if unknown
        if(([knownAttributes containsObject:attrName] == NO) && (flags.acceptsUnknownAttributes == NO))
            {
            if(flags.ignoresUnknownAttributes)
                continue;
            [NSException raise:EDMLParserException format:@"Invalid attribute \"%@\" for tag <%@>.", attrName, [tagName secondObject]];
            }
        [element takeValue:[attr secondObject] forAttribute:attrName];
        [requiredAttributes removeObject:attrName];
        }

    if((requiredAttributes != nil) && ([requiredAttributes count] > 0))
        [NSException raise:EDMLParserException format:@"Required attribute(s) \"%@\" missing in tag <%@>", [[requiredAttributes allObjects] componentsJoinedByString:@", "], [tagName secondObject]];

    return element;
}


- (id)elementForTag:(EDObjectPair *)tagName attributeList:(NSArray *)parsedAttrList containedElements:(NSArray *)containedElements
{
    id element;

    element = [self elementForTag:tagName attributeList:parsedAttrList];
    [element setContainedElements:containedElements];

    return element;
}


- (id)objectForText:(NSString *)string
{
    NSString *className, *attrName;
    id 		 object;

    NSAssert(textObjectDefinition != nil, @"No definition for text.");
    className = [textObjectDefinition objectForKey:@"class"];
    object = [[[NSClassFromString(className) allocWithZone:[self zone]] init] autorelease];
    if(flags.textRespondsToSetText)
        {
        [object setText:string];
        }
    else
        {
        attrName = [textObjectDefinition objectForKey:@"implicit"];
        NSAssert(textObjectDefinition != nil, @"No 'implicit' for text that does not implement setText:.");
        [object takeValue:string forAttribute:attrName];
        }

    return object;
}


- (id)objectForSpace:(NSString *)string
{
    NSString *className;
    id 		 object;

    NSAssert(spaceObjectDefinition != nil, @"No definition for space.");
    className = [spaceObjectDefinition objectForKey:@"class"];
    object = [[[NSClassFromString(className) allocWithZone:[self zone]] init] autorelease];
    if(flags.spaceIgnoresString == NO)
        {
        if(flags.spaceRespondsToSetText)
            [object setText:string];
        else
            [object takeValue:string forAttribute:[spaceObjectDefinition objectForKey:@"implicit"]];
        }
    return object;
}


//=======================================================================================
    @end
//=======================================================================================



//=======================================================================================
     @implementation EDMLParser(AOMProcessorFactory)
//=======================================================================================

/*" Methods added to the parser by the AOM tag processor. "*/

/*" Creates and returns a parser, that uses a a newly created AOM tag processor for %someTagDefinitions. See class description in the parser for details. "*/

+ (id)parserWithTagDefinitions:(NSDictionary *)someTagDefinitions
{
    EDAOMTagProcessor *processor;

    processor = [[[EDAOMTagProcessor alloc] initWithTagDefinitions:someTagDefinitions] autorelease];
    return [[[self alloc] initWithTagProcessor:processor] autorelease];
}


/*" Set the acceptsUnknownAttributes flag in the parser's tag processor. Raises an exception if the tag processor is not an #EDAOMTagProcessor. This method is for compatibility reasons only. Please use the corresponding method in the AOM tag processor class. "*/

- (void)setAcceptsUnknownAttributes:(BOOL)flag
{
    [CAST([self tagProcessor], EDAOMTagProcessor) setAcceptsUnknownAttributes:flag];
}


/*" Queries the acceptsUnknownAttributes flag in the parser's tag processor. Raises an exception if the tag processor is not an #EDAOMTagProcessor. This method is for compatibility reasons only. Please use the corresponding method in the AOM tag processor class. "*/

- (BOOL)acceptsUnknownAttributes
{
    return [CAST([self tagProcessor], EDAOMTagProcessor) acceptsUnknownAttributes];
}


//=======================================================================================
    @end
//=======================================================================================

