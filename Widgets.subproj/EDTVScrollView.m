//---------------------------------------------------------------------------------------
//  EDTVScrollView.m created by erik on Mon 28-Jun-1999
//  @(#)$Id: EDTVScrollView.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
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

#import <AppKit/AppKit.h>
#import "EDTableView.h"
#import "EDTVScrollView.h"

@interface EDTableView(PrivateAPI)
- (BOOL)_shouldAcceptPasteboardContents:(NSPasteboard *)pboard;
- (void)_takePasteboardContents:(NSPasteboard *)pboard atRow:(int)row;
- (BOOL)_putSelectionOntoPasteboard:(NSPasteboard *)pboard;
@end


@interface EDTVScrollView(PrivateAPI)
- (BOOL)_shouldAcceptPasteboardContents:(NSPasteboard *)pasteboard;
@end


//---------------------------------------------------------------------------------------
    @implementation EDTVScrollView
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INITIALISATION
//---------------------------------------------------------------------------------------

- (void)awakeFromNib
{
    cacheChangeCount = -1;
    tableView = [self documentView];
    NSAssert1([tableView isKindOfClass:[EDTableView class]], @"wrong document view class; found %@, should be an EDTableView or a subclass of it.", NSStringFromClass([tableView class]));
}


//---------------------------------------------------------------------------------------
//	DRAGGIN DESTINATION PROTOCOL
//---------------------------------------------------------------------------------------

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
    BOOL	ok;

    ok = [self _shouldAcceptPasteboardContents:[sender draggingPasteboard]];
    return ok ? [sender draggingSourceOperationMask] & NSDragOperationGeneric : NSDragOperationNone;
}


- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
    NSPoint	point;
    NSRect	visRect;
    NSRect	scrollRect;
    float	rowHeight;
    int 	aRow;
    BOOL	ok;

    ok = [self _shouldAcceptPasteboardContents:[sender draggingPasteboard]];
    if(ok == NO)
        return NSDragOperationNone;

    point = [tableView convertPoint:[sender draggingLocation] fromView:nil];
    visRect = [tableView visibleRect];
    rowHeight = [tableView rowHeight];
    aRow = [tableView rowAtPoint:point];

    if((aRow == 0) || (aRow == [tableView numberOfRows] - 1))
        {
        [tableView scrollRowToVisible:aRow];
        }
    else if (point.y < visRect.origin.y + rowHeight / 4)
        {
        // we need to scroll at top
        scrollRect = NSMakeRect(visRect.origin.x, (visRect.origin.y - rowHeight), visRect.size.width, rowHeight);
        [tableView scrollRectToVisible:scrollRect];
        }
    else if (point.y > ((visRect.origin.y + visRect.size.height) - rowHeight / 4))
        {
        // we need to scroll at bottom
        scrollRect = NSMakeRect(visRect.origin.x, visRect.origin.y + visRect.size.height, visRect.size.width, rowHeight);
        [tableView scrollRectToVisible:scrollRect];
        }

    return [sender draggingSourceOperationMask] & NSDragOperationGeneric;
}



- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
    return YES;
}


- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
    // Mike Ferris sez that you should do the drag operation in conclude!
    // That way you don't have to wait for time-outs when debugging the
    // drop code.
    return YES;
}


- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
    NSPoint			screenPoint;
    int				targetRow;

    screenPoint = [tableView convertPoint:[sender draggingLocation] fromView:nil];
    targetRow = [tableView rowAtPoint:screenPoint];

    [tableView _takePasteboardContents:[sender draggingPasteboard] atRow:targetRow];
}


//---------------------------------------------------------------------------------------
//	DRAGGING DESTINATION HELPERS
//---------------------------------------------------------------------------------------

- (BOOL)_shouldAcceptPasteboardContents:(NSPasteboard *)pasteboard
{
    if([pasteboard changeCount] == cacheChangeCount)
        return cachedAcceptResponse;

    cachedAcceptResponse = [tableView _shouldAcceptPasteboardContents:pasteboard];
    cacheChangeCount = [pasteboard changeCount];
    NSLog(@"-[%@ %@]: %@ pasteboard contents (#%d)", NSStringFromClass(isa), NSStringFromSelector(_cmd), cachedAcceptResponse ? @"accepted" : @"rejected", cacheChangeCount);

    return cachedAcceptResponse;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
