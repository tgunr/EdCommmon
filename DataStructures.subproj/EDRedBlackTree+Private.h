//---------------------------------------------------------------------------------------
//  EDRedBlackTree+Private.h created by erik on Tue 15-Sep-1998
//  @(#)$Id: EDRedBlackTree+Private.h,v 1.2 2002-04-14 14:57:55 znek Exp $
//
//  Copyright (c) 1998-1999 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDRedBlackTree_Private_h_INCLUDE
#define	__EDRedBlackTree_Private_h_INCLUDE


#import "EDRedBlackTree.h"

/*"

Some random notes:
- This could be in EDRedBlackTree.m but by making the interface available it is possible
  to subclass the tree.
- I am not using a struct for performance reasons. That gain is neglible. The reason is
  as simple as saving 4 bytes per object in the tree.

*/


typedef struct _EDRedBlackTreeNode
{
    struct _EDRedBlackTreeNode 	*left, *right, *parent;
    id 						   	object;
    struct {
        unsigned 				color : 1;
        unsigned				size : 31;
    } f;
} EDRedBlackTreeNode;



@interface EDRedBlackTree(Private)

- (EDRedBlackTreeNode *)_allocNodeForObject:(id)object;
- (void)_deallocNode:(EDRedBlackTreeNode *)node;
- (void)_deallocAllNodesBelowNode:(EDRedBlackTreeNode *)x; // doesn't restore r/b-property!
- (void)_swapValuesBetweenNodes:(EDRedBlackTreeNode *)a:(EDRedBlackTreeNode *)b;

- (EDRedBlackTreeNode *)_sentinel;
- (EDRedBlackTreeNode *)_rootNode;
- (EDRedBlackTreeNode *)_minimumNode;
- (EDRedBlackTreeNode *)_nodeForObject:(id)k;
- (EDRedBlackTreeNode *)_nodeForObjectOrPredecessorOfObject:(id)k;
- (EDRedBlackTreeNode *)_maximumBelowNode:(EDRedBlackTreeNode *)x;
- (EDRedBlackTreeNode *)_minimumBelowNode:(EDRedBlackTreeNode *)x;
- (EDRedBlackTreeNode *)_successorForNode:(EDRedBlackTreeNode *)x;
- (void)_leftRotateFromNode:(EDRedBlackTreeNode *)x;
- (void)_rightRotateFromNode:(EDRedBlackTreeNode *)y;
- (void)_insertNode:(EDRedBlackTreeNode *)z;
- (EDRedBlackTreeNode *)_deleteNode:(EDRedBlackTreeNode *)z;

- (unsigned int)_rankOfNode:(EDRedBlackTreeNode *)x;
- (EDRedBlackTreeNode *)_nodeWithRank:(unsigned int)i;

@end



@interface _EDRedBlackTreeEnumerator : NSEnumerator
{
    EDRedBlackTree 		*tree;
    EDRedBlackTreeNode	*sentinel;
    EDRedBlackTreeNode 	*node;
}

- (id)initWithTree:(EDRedBlackTree *)aTree;

@end


#define IS_SMALLER(A, B) (((NSComparisonResult)[((EDRedBlackTreeNode *)A)->object performSelector:comparator withObject:((EDRedBlackTreeNode *)B)->object]) == NSOrderedAscending)
#define IS_EQUAL(A, B) (((NSComparisonResult)[((EDRedBlackTreeNode *)A)->object performSelector:comparator withObject:((EDRedBlackTreeNode *)B)->object]) == NSOrderedSame)
#define NIL(X) (((EDRedBlackTreeNode *)X) == sentinel)


#endif	/* __EDRedBlackTree_Private_h_INCLUDE */


