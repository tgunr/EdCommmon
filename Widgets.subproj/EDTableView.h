//---------------------------------------------------------------------------------------
//  EDTableView.h created by erik on Mon 28-Jun-1999
//  @(#)$Id: EDTableView.h,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
//
//  Copyright (c) 1999-2000 by Erik Doernenburg. All rights reserved.
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

#import <AppKit/NSTableView.h>
#import "EDCommonDefines.h"

typedef struct _EDTVFlags {
#ifdef __BIG_ENDIAN__
    unsigned delaysRequestingData : 1;
    unsigned allowsRowReordering: 1;
    unsigned allowsRowDragging : 1;
    unsigned needsControlKeyForMove : 1;
    unsigned delegateRespondsToShouldAccept : 1;
    unsigned delegateRespondsToImageForRow:1;
    unsigned delegateRespondsToShouldDepositRowAt: 1;
    unsigned padding : 25;
#else
    unsigned padding : 25;
    unsigned delegateRespondsToShouldDepositRowAt: 1;
    unsigned delegateRespondsToImageForRow:1;
    unsigned delegateRespondsToShouldAccept : 1;
    unsigned needsControlKeyForMove : 1;
    unsigned allowsRowDragging : 1;
    unsigned allowsRowReordering: 1;
    unsigned delaysRequestingData : 1;
#endif
} _EDTVFlags;


@interface EDTableView : NSTableView
{
    _EDTVFlags	flags;
     NSArray	*currentTypes;
     NSArray	*acceptableTypes;
     int 		draggedRow;
     NSImage 	*rowCache;
     NSImage 	*tableCache;
}

- (void)setDelaysRequestingData:(BOOL)flag;
- (BOOL)delaysRequestingData;

- (void)setAllowsRowReordering:(BOOL)flag;
- (BOOL)allowsRowReordering;

- (void)setAllowsRowDragging:(BOOL)flag;
- (BOOL)allowsRowDragging;

- (void)setNeedsControlKeyForMove:(BOOL)flag;
- (BOOL)needsControlKeyForMove;

- (void)setCurrentTypes:(NSArray *)types;
- (NSArray *)currentTypes;

- (void)setAcceptableTypes:(NSArray *)types;
- (NSArray *)acceptableTypes;

@end



@interface NSObject(NSTableViewDelegateEDExtensionsInformalProtocol)
- (void)tableView:(EDTableView *)aTableView writeType:(NSString *)type ontoPasteboard:(NSPasteboard *)pboard;
- (BOOL)tableView:(EDTableView *)aTableView shouldAcceptPasteboard:(NSPasteboard *)pboard;
- (void)tableView:(EDTableView *)aTableView didAcceptPasteboard:(NSPasteboard *)pboard atRow:(int)row;

- (NSImage *)tableView:(EDTableView *)tableView imageForRow:(int)aRow;
- (BOOL)tableView:(EDTableView *)aTableView shouldDepositRow:(int)oldRow at:(int)newRow;
- (void)tableViewRowDidMove:(NSNotification *)aNotification;
@end


EDCOMMON_EXTERN NSString *EDTableViewRowDidMoveNotification;
