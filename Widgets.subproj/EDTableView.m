//---------------------------------------------------------------------------------------
//  EDTableView.m created by erik on Mon 28-Jun-1999
//  @(#)$Id: EDTableView.m,v 1.3 2002-04-14 14:57:58 znek Exp $
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

#import <AppKit/AppKit.h>
#import "EDTVScrollView.h"
#import "EDTableView.h"

//---------------------------------------------------------------------------------------
    @implementation EDTableView
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
   [self setVersion:3];
}


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- initWithFrame:(NSRect)frame
{
    [super initWithFrame:frame];
    return self;
}


- (void)dealloc
{
    [clickableColumns release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	NSCODING
//---------------------------------------------------------------------------------------

- (void)encodeWithCoder:(NSCoder *)encoder
{
    [super encodeWithCoder:encoder];
    [encoder encodeValueOfObjCType:@encode(int) at:&flags];
}


- (id)initWithCoder:(NSCoder *)decoder
{
    unsigned int version;

    [super initWithCoder:decoder];
    version = [decoder versionForClassName:@"EDTableView"];
    // Version is -1 when loading a NIB file in which we were set as a custom subclass.
    // The unsigned representation of this is INT_MAX on a 2-bytes-complement machine...
    if(version == INT_MAX)
        {
        }
    else
        {
        [decoder decodeValueOfObjCType:@encode(int) at:&flags];
        }

    return self;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)addToClickableColumns:(NSTableColumn *)aColumn
{
    NSAssert([[self tableColumns] indexOfObject:aColumn] != NSNotFound, @"invalid column");
    if(clickableColumns == nil)
        clickableColumns = [[NSMutableSet allocWithZone:[self zone]] init];
    [clickableColumns addObject:aColumn];
}

- (void)removeFromClickableColumns:(NSTableColumn *)aColumn
{
    NSAssert([clickableColumns containsObject:aColumn], @"invalid column");
    [clickableColumns removeObject:aColumn];
}

- (NSArray *)clickableColumns
{
    return [clickableColumns allObjects];
}


//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

/* This is quite hard-core but I didn't find another way to get the desired behaviour */

- (void)mouseDown:(NSEvent *)theEvent
{
    NSTableColumn	*column;
    NSCell			*cell;
    NSRect			cellFrame;
    NSPoint			location;
    BOOL			isOverCell;

    location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
    clickedRowIdx = [self rowAtPoint:location];
    clickedColumnIdx = [self columnAtPoint:location];
    if((clickedColumnIdx == -1) || (clickedRowIdx == -1) ||
      ([clickableColumns containsObject:[_tableColumns objectAtIndex:clickedColumnIdx]] == NO))
        {
        [super mouseDown:theEvent];
        }
    else
        {
        flags.isManagingClick = YES;
        column = [_tableColumns objectAtIndex:clickedColumnIdx];
        cell = [column dataCell];
        cellFrame = [self frameOfCellAtColumn:clickedColumnIdx row:clickedRowIdx];
#ifndef GNUSTEP
        if(_tvFlags.delegateWillDisplayCell)
#else
	if(_del_responds)
#endif
            [_delegate tableView:self willDisplayCell:cell forTableColumn:column row:clickedRowIdx];
        while([theEvent type] != NSLeftMouseUp)
            {
            isOverCell = [self mouse:location inRect:cellFrame];
            [cell highlight:isOverCell withFrame:cellFrame inView:self];
            if(isOverCell)
                if([cell trackMouse:theEvent inRect:cellFrame ofView:self untilMouseUp:NO])
                    break;
            theEvent = [[self window] nextEventMatchingMask: NSLeftMouseUpMask|NSLeftMouseDraggedMask];
            location = [self convertPoint:[theEvent locationInWindow] fromView:nil];
            }
        [cell highlight:NO withFrame:cellFrame inView:self];
        flags.isManagingClick = NO;
        }
}


- (int)clickedColumn
{
    if(flags.isManagingClick == NO)
        return [super clickedColumn];
    return clickedColumnIdx;
}


- (int)clickedRow
{
    if(flags.isManagingClick == NO)
        return [super clickedRow];
    return clickedRowIdx;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------

