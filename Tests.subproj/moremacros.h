//---------------------------------------------------------------------------------------
//  moremacros.h created by erik on Fri May 23 2003
//  @(#)$Id: moremacros.h,v 1.1 2003-05-26 19:56:13 erik Exp $
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


#ifndef	__moremacros_h_INCLUDE
#define	__moremacros_h_INCLUDE

#define shouldBeEqualInt1(left,right,description)  \
    shouldBeEqual1([NSNumber numberWithInt:(left)], [NSNumber numberWithInt:(right)], description)
#define shouldBeEqualInt(left,right)  shouldBeEqualInt1(left,right,nil)



#endif	/* __moremacros_h_INCLUDE */
