//---------------------------------------------------------------------------------------
//  EDXMLDOMTagProcessor.h created by erik on Sun Mar 09 2003
//  @(#)$Id: EDXMLDOMTagProcessor.h,v 1.1 2003-05-26 19:52:35 erik Exp $
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

#ifndef	__EDXMLDOMTagProcessor_h_INCLUDE
#define	__EDXMLDOMTagProcessor_h_INCLUDE

#import "EDMLTagProcessorProtocol.h"

@class EDMLParser, EDXMLDocument;


@interface EDXMLDOMTagProcessor : NSObject < EDMLTagProcessor >
{
    EDXMLDocument	*document;
}

/*" Setting the document to use "*/
- (void)setDocument:(EDXMLDocument *)aDocument;
- (EDXMLDocument *)document;

@end


#endif	/* __EDDOMTagProcessor_h_INCLUDE */
