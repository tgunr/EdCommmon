//---------------------------------------------------------------------------------------
//  EDXMLNodeList.h created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLNodeList.h,v 1.1 2003-05-26 19:52:35 erik Exp $
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

#ifndef	__EDXMLNodeList_h_INCLUDE
#define	__EDXMLNodeList_h_INCLUDE


@interface EDXMLNodeList : NSObject
{
    NSArray *array;	/*" All instance variables are private. "*/
}

/*" Creating new node lists "*/
- (id)initWithArray:(NSArray *)anArray;

/*" Accessing contents "*/
- (unsigned)length;
- (id)objectAtIndex:(unsigned)_idx;

@end

#endif	/* __EDXMLNodeList_h_INCLUDE */
