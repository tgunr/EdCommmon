//---------------------------------------------------------------------------------------
//  EDCollectionMapping.h created by erik on Wed 17-Mar-1999
//  @(#)$Id: CollectionMapping.h,v 1.4 2002-07-02 15:05:32 erik Exp $
//
//  Copyright (c) 1997-1999 by Erik Doernenburg. All rights reserved.
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


#ifndef	__CollectionMapping_h_INCLUDE
#define	__CollectionMapping_h_INCLUDE


#import <Foundation/Foundation.h>


/*" Mapping extensions to #NSArray. "*/

@interface NSArray(EDCollectionMapping)
- (NSArray *)arrayByMappingWithDictionary:(NSDictionary *)mapping;
- (NSArray *)arrayByMappingWithSelector:(SEL)selector; // similar to valueForKey:
- (NSArray *)arrayByMappingWithSelector:(SEL)selector withObject:(id)object;
- (NSArray *)flattenedArray; // doesn't really belong here...
@end


/*" Mapping extensions to #NSSet. "*/

@interface NSSet(EDCollectionMapping)
- (NSSet *)setByMappingWithDictionary:(NSDictionary *)mapping;
- (NSSet *)setByMappingWithSelector:(SEL)selector; // similar to valueForKey:
- (NSSet *)setByMappingWithSelector:(SEL)selector withObject:(id)object;
@end


/*" Mapping extensions to #NSObject. "*/

@interface NSObject(EDCollectionMapping)
- (NSArray *)mapArray:(NSArray *)array withSelector:(SEL)aSelector;
- (void)performSelector:(SEL)selector withObjects:(NSArray *)objectList;
- (void)performSelector:(SEL)selector withObjectsEnumeratedBy:(NSEnumerator *)enumerator;
@end

#endif	/* __CollectionMapping_h_INCLUDE */
