//---------------------------------------------------------------------------------------
//  EDTableView.m created by erik on Mon 28-Jun-1999
//  @(#)$Id: EDTableView.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
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
#import "EDTVScrollView.h"
#import "EDTableView.h"

@interface EDTableView(PrivateAPI)
- (BOOL)_shouldAcceptPasteboardContents:(NSPasteboard *)pboard;
- (void)_takePasteboardContents:(NSPasteboard *)pboard atRow:(int)row;
- (BOOL)_putSelectionOntoPasteboard:(NSPasteboard *)pboard;

- (void)_updateDnDTypes;
- (void)_writeType:(NSString *)type ontoPasteboard:(NSPasteboard *)pboard;

- (NSImage *)_imageForRow:(int)aRow;
- (void)_drawTableCache:(NSRect)rowRect;
- (void)_drawRowCache:(NSRect)rowRect;
- (NSImage *)_sizeCacheWindow:(NSImage *)cacheImage to:(NSSize)windowSize;
- (void)_grabTableBits;
- (BOOL)_constrainedMove:(NSEvent *)theEvent;
- (BOOL)_startRow:(int)start endedAt:(int)end;
- (BOOL)_move:(NSEvent *)theEvent;
- (BOOL)_constrainedMove:(NSEvent *)theEvent;
- (BOOL)_unconstrainedMove:(NSEvent *)theEvent;
@end


static NSEvent *periodicEventWithLocationSetToPoint(NSEvent *oldEvent, NSPoint point);


NSString *EDTableViewRowDidMoveNotification = @"EDTableViewRowDidMoveNotification";


//---------------------------------------------------------------------------------------
    @implementation EDTableView
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//	CLASS INITIALISATION
//---------------------------------------------------------------------------------------

+ (void)initialize
{
   [self setVersion:2];
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
    [currentTypes release];
    [acceptableTypes release];
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
//	ACCESSOR METHOD OVERRIDES
//---------------------------------------------------------------------------------------

#define CACHE_RESPONDSTO(S, F) flags.F = [anObject respondsToSelector:@selector(tableView: S)]

- (void)setDelegate:(id)anObject
{
    [super setDelegate:anObject];

    CACHE_RESPONDSTO(shouldAcceptPasteboard:, delegateRespondsToShouldAccept);
    CACHE_RESPONDSTO(shouldDepositRow:at:, delegateRespondsToShouldDepositRowAt);
    CACHE_RESPONDSTO(imageForRow:, delegateRespondsToImageForRow);

    if([anObject respondsToSelector:@selector(tableViewRowDidMove:)])
        [DNC addObserver:anObject selector:@selector(tableViewRowDidMove:) name:EDTableViewRowDidMoveNotification object:self];
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (void)setDelaysRequestingData:(BOOL)flag
{
    flags.delaysRequestingData = flag;
}

- (BOOL)delaysRequestingData
{
    return flags.delaysRequestingData;
}


- (void)setAllowsRowReordering:(BOOL)flag
{
    flags.allowsRowReordering = flag;
}

- (BOOL)allowsRowReordering
{
    return flags.allowsRowReordering;
}


- (void)setAllowsRowDragging:(BOOL)flag
{
    flags.allowsRowDragging = flag;
}

- (BOOL)allowsRowDragging
{
    return flags.allowsRowDragging;
}

- (void)setNeedsControlKeyForMove:(BOOL)flag
{
    flags.needsControlKeyForMove = flag;
}

- (BOOL)needsControlKeyForMove
{
    return flags.needsControlKeyForMove;
}


//---------------------------------------------------------------------------------------
//	ACCESSOR METHODS FOR TRANSIENT ATTRIBUTES
//---------------------------------------------------------------------------------------

- (void)setCurrentTypes:(NSArray *)types
{
    [currentTypes autorelease];
    currentTypes = [types retain];
}


- (NSArray *)currentTypes
{
    return currentTypes;
}


- (void)setAcceptableTypes:(NSArray *)types
{
    [acceptableTypes autorelease];
    acceptableTypes = [types retain];
    [self _updateDnDTypes];
}


- (NSArray *)acceptableTypes
{
    return acceptableTypes;
}


//---------------------------------------------------------------------------------------
//	PASTBOARD / DRAGGING SOURCE PROTOCOL IMPLEMENTATIONS
//---------------------------------------------------------------------------------------

- (void)pasteboard:(NSPasteboard *)sender provideDataForType:(NSString *)type
{
    [self _writeType:type ontoPasteboard:sender];
}


//---------------------------------------------------------------------------------------
//	PASTEBOARD HELPER (KNOWN TO EDTVScrollView)
//---------------------------------------------------------------------------------------

- (BOOL)_shouldAcceptPasteboardContents:(NSPasteboard *)pboard
{
    if(flags.delegateRespondsToShouldAccept == YES)
        return [[self delegate] tableView:self shouldAcceptPasteboard:pboard];
    return YES;
}


- (void)_takePasteboardContents:(NSPasteboard *)pboard atRow:(int)row
{
    [[self delegate] tableView:self didAcceptPasteboard:pboard atRow:row];
}


- (BOOL)_putSelectionOntoPasteboard:(NSPasteboard *)pboard
{
    NSEnumerator	*typeEnum;
    NSString		*type;
    int				oldChangeCount;

    if(currentTypes == nil)
        return NO;

    oldChangeCount = [pboard changeCount];
    if(flags.delaysRequestingData)
        {
        [pboard declareTypes:currentTypes owner:self];
        [self _writeType:[currentTypes objectAtIndex:0] ontoPasteboard:pboard];
        }
    else
        {
        [pboard declareTypes:currentTypes owner:nil];
        typeEnum = [currentTypes objectEnumerator];
        while((type = [typeEnum nextObject]) != nil)
            [self _writeType:type ontoPasteboard:pboard];
        }

    return [pboard changeCount] != oldChangeCount;
}


//---------------------------------------------------------------------------------------
//	PRIVATE HELPER
//---------------------------------------------------------------------------------------

- (void)_updateDnDTypes
{
    EDTVScrollView 	*scrollView;

    // ScrollView can be nil during dealloc.
    if((scrollView = (id)[[self superview] superview]) == nil)
        return;

    NSAssert([scrollView isKindOfClass:[EDTVScrollView class]], @"If a delegate of an EDTableView wants drag'n'drop the table view must be placed in an EDTVScrollView.");
    if((acceptableTypes != nil) && ([acceptableTypes count] > 0))
        [scrollView registerForDraggedTypes:acceptableTypes];
    else
        [scrollView unregisterDraggedTypes];
}


- (void)_writeType:(NSString *)type ontoPasteboard:(NSPasteboard *)pboard
{
    [[self delegate] tableView:self writeType:type ontoPasteboard:pboard];
}


//---------------------------------------------------------------------------------------
//	PRIVATE HELPERS (ROW DRAGGING)
//---------------------------------------------------------------------------------------

#define MOVE_MASK NSLeftMouseUpMask|NSLeftMouseDraggedMask


- (void)mouseDown:(NSEvent *)theEvent
{
    if([self _move:theEvent] == NO)
        [super mouseDown:theEvent];
}


- (BOOL)_move:(NSEvent *)e
{
    NSPoint		mouseDownLocation;
    int 		draggedCol;
    NSEvent 	*peekedEvent;

    mouseDownLocation = [e locationInWindow];
    
    // if the next event is a mouse up, don't drag the row
    peekedEvent = [[self window] nextEventMatchingMask:MOVE_MASK untilDate:[NSDate dateWithTimeIntervalSinceNow:0.1] inMode:NSEventTrackingRunLoopMode dequeue:NO];
    if([peekedEvent type] == NSLeftMouseUp)
        return NO;

    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
    draggedCol = [self columnAtPoint:mouseDownLocation];
    draggedRow = [self rowAtPoint:mouseDownLocation];

    if((flags.needsControlKeyForMove) && (([e modifierFlags] & NSControlKeyMask) == 0))
        return NO;

    if(flags.allowsRowDragging)
         return [self _unconstrainedMove:e];
    else if(flags.allowsRowReordering)
        return [self _constrainedMove:e];

   return NO;
}


- (BOOL)_constrainedMove:(NSEvent *)theEvent
{
    NSPoint		mouseDownLocation, mouseUpLocation, mouseLocation;
    int			newRow;
    NSRect		visibleRect, rowRect;
    NSImage 	*image;
    NSWindow	*window;
    float		dy, dx;
    NSEvent 	*peek, *event;
    BOOL		scrolled = NO;
    BOOL 		inTimerLoop = NO;

    window = [self window];

    // find the cell that got clicked on and select it
    mouseDownLocation = [theEvent locationInWindow];
    mouseDownLocation = [self convertPoint:mouseDownLocation fromView:nil];
    draggedRow = [self rowAtPoint:mouseDownLocation];

    // this forces text editing to end
    [window makeFirstResponder:window];
    [self selectRow:draggedRow byExtendingSelection:NO];
    // this makes sure we get the whole row into the image
    [self scrollRowToVisible:draggedRow];
    // this makes sure the display is up to date
    [self display];

    // copy what's currently visible into the table cache
    tableCache = [self _sizeCacheWindow:tableCache to:[self visibleRect].size];
    [self _grabTableBits];

    // get the image of the table row
    // first, give the delegate a chance to supply an image
    // otherwise, get our own image (the image of the whole row)
    if((flags.delegateRespondsToImageForRow == NO) || ((image = [[self delegate] tableView:self imageForRow:draggedRow]) == nil))
        image = [self _imageForRow:draggedRow];
    rowCache = image;
    rowRect = [self rectOfRow:draggedRow];

    // save the mouse's location relative to the cell's origin
    dy = mouseDownLocation.y - rowRect.origin.y;
    dx = mouseDownLocation.x - rowRect.origin.x;

    // we're now interested in mouse dragged events
    [window setAcceptsMouseMovedEvents:YES];

    // from now on we'll be drawing into ourself
    [self lockFocus];

    // START LOOP
    event = theEvent;
    while ([event type] != NSLeftMouseUp)
        {
        // erase the active cell using the image in the matrix cache
        visibleRect = [self visibleRect];

        [self _drawTableCache:rowRect];

        // move the active row
        mouseLocation = [event locationInWindow];
        mouseLocation = [self convertPoint:mouseLocation fromView:nil];
        rowRect.origin.y = mouseLocation.y - dy;
        rowRect.origin.x = mouseLocation.x - dx;

        // constrain the row's location to our bounds
        if(NSMinY(rowRect) < NSMinX([self bounds]))
            rowRect.origin.y = NSMinX([self bounds]);
        else if (NSMaxY(rowRect) > NSMaxY([self bounds]))
            rowRect.origin.y = NSHeight([self bounds]) - NSHeight(rowRect);

        if(NSMinX(rowRect) < NSMinY([self bounds]))
            rowRect.origin.x = NSMinY([self bounds]);
        else if (NSMaxX(rowRect) > NSMaxX([self bounds]))
            rowRect.origin.x = NSWidth([self bounds]) - NSWidth(rowRect);

       // make sure the cell will be entirely visible in its new location (if
       // we're in a scrollView, it may not be)

        if(NSContainsRect(visibleRect , rowRect) == NO)
            {	
            // the cell won't be entirely visible, so scroll, dood, scroll, but
            // don't display on-screen yet
            [[self window] disableFlushWindow];
            [self scrollRectToVisible:rowRect];
            [[self window] enableFlushWindow];

            // copy the new image to the matrix cache
            [self _grabTableBits];

            // note that we scrolled and start generating timer events for autoscrolling
            scrolled = YES;
            if(inTimerLoop == NO)
                {
                [NSEvent startPeriodicEventsAfterDelay:0.1 withPeriod:0.1];
                inTimerLoop = YES;
                }
            }
        else
            {
            // don't need to scroll
            if(inTimerLoop)
                {
                [NSEvent stopPeriodicEvents];
                inTimerLoop = NO;
                }
            }

        // composite the active cell's image on top of ourself
        [self _drawRowCache:rowRect];

        // now show what we've done
        [[self window] flushWindow];

        // save the current mouse location, just in case we need it again
        mouseLocation = [event locationInWindow];

        // ADD SHOULD_DEPOSIT SOMEWHERE HERE...
        if((peek = [[self window] nextEventMatchingMask:MOVE_MASK untilDate:[NSDate date] inMode:NSEventTrackingRunLoopMode dequeue:NO]) == nil)
            event = [[self window] nextEventMatchingMask:MOVE_MASK|NSPeriodicMask];
        else
            event = [[self window] nextEventMatchingMask:MOVE_MASK];

        // if a timer event, mouse location isn't valid, so we'll set it
        if ([event type] == NSPeriodic)
            event = periodicEventWithLocationSetToPoint(event, mouseLocation);
        }

    // END LOOP

    // mouseUp, so stop any timer and unlock focus
    if (scrolled && inTimerLoop)
        {
        [NSEvent stopPeriodicEvents];
        inTimerLoop = NO;
        PSWait();
        scrolled = NO;
        }
    [self unlockFocus];

    // find the cell under the mouse's location
    mouseUpLocation = [event locationInWindow];
    mouseUpLocation = [self convertPoint:mouseUpLocation fromView:nil];
    newRow = [self rowAtPoint:mouseUpLocation];
    if(newRow == -1)
        {
        // mouse is out of bounds, so find the row the dragged row covers
        newRow = [self rowAtPoint:rowRect.origin];
        }

    // we need to shuffle cells if the active cell's going to a new location
    if((newRow != -1) && (newRow != draggedRow))
        {
        if(mouseUpLocation.y > 4)
            newRow += 1; // unless at the very top we move to the row below
        [DNC postNotificationName:EDTableViewRowDidMoveNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:draggedRow], @"EDOldRow", [NSNumber numberWithInt:newRow], @"EDNewRow", nil]];
        [self reloadData];
        if(newRow > draggedRow)
            newRow -=1; // we assume the rows were moved...
        [self selectRow:newRow byExtendingSelection:NO];
        }
    else
        {
        [self display];
        }

    // set the event mask to normal
    [window setAcceptsMouseMovedEvents:NO];
    return YES;
}


- (BOOL)_unconstrainedMove:(NSEvent *)e
{
    NSPoint 		mouseDownLocation;
    NSPasteboard	*pboard;
    NSImage 		*image;
    NSRect 			rect;
    NSPoint 		lowerLeftCorner;

    mouseDownLocation = [self convertPoint:[e locationInWindow] fromView:nil];
    draggedRow = [self rowAtPoint:mouseDownLocation];

    pboard = [NSPasteboard pasteboardWithName:NSDragPboard];

    // this forces text editing to end
    [[self window] makeFirstResponder:[self window]];
    [self selectRow:draggedRow byExtendingSelection:NO];
    // this makes sure we get the whole row into the image
    [self scrollRowToVisible:draggedRow];
    // this makes sure the display is up to date
    [self display];

    // give the delegate a chance to supply an image
    if((flags.delegateRespondsToImageForRow == NO) || ((image = [[self delegate] tableView:self imageForRow:draggedRow]) == nil))
        image = [self _imageForRow:draggedRow];

    rect = [self rectOfRow:draggedRow];
    lowerLeftCorner = NSMakePoint(rect.origin.x,rect.origin.y + rect.size.height);
    if([self _putSelectionOntoPasteboard:pboard])
        {
        [self dragImage:image at:lowerLeftCorner offset:NSZeroSize event:e pasteboard:pboard source:self slideBack:YES];
       return YES;
        }

    return NO;
}


- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag
{
    return NSDragOperationCopy|NSDragOperationGeneric|NSDragOperationLink;
}





- (void)_grabTableBits
{
    NSRect 			 visibleRect;
    NSCachedImageRep *tableRep;

    // copy what's currently visible into the matrix cache

    visibleRect = [self convertRect:[self visibleRect] toView:nil];
    tableRep = [[tableCache representations] objectAtIndex:0];
    
    [tableCache lockFocusOnRepresentation:tableRep];
    PScomposite(NSMinX(visibleRect), NSMinY(visibleRect), NSWidth(visibleRect), NSHeight(visibleRect), [[self window] gState],  0.0, 0.0, NSCompositeCopy);
    [tableCache unlockFocus];
}


- (void)_grabRowBits
{
    NSRect 			 rowRect;
    NSCachedImageRep *rowRep;

    // copy what's currently visible into the row cache

    rowRect = [self convertRect:[self rectOfRow:draggedRow] toView:nil];
    rowRep = [[rowCache representations] objectAtIndex:0];

    [rowCache lockFocusOnRepresentation:rowRep];
    PScomposite(NSMinX(rowRect), NSMinY(rowRect), NSWidth(rowRect), NSHeight(rowRect), [[self window] gState],  0.0, 0.0, NSCompositeCopy);
    [rowCache unlockFocus];
}


- (NSImage *)_imageForRow:(int)aRow
{
    NSSize old;
    NSRect rowRect;
    NSSize rowSize;

    old = (rowCache != nil) ? [rowCache size] : NSZeroSize;
    rowRect = [self rectOfRow:draggedRow];
    rowSize = rowRect.size;
    
    if((rowSize.width != old.width) || (rowSize.height != old.height))
        {
        NSCachedImageRep *rep;
        
        if(rowCache != nil)
            [rowCache release];
        rowCache = [[NSImage allocWithZone:[self zone]] initWithSize:rowSize];
        rep = [[[NSCachedImageRep allocWithZone:[self zone]] initWithSize:rowSize depth:[NSWindow
defaultDepthLimit] separate:YES alpha:YES]autorelease];
        [rowCache addRepresentation:rep];
        }
    [self _grabRowBits];

    return rowCache;
}


- (NSImage *)_sizeCacheWindow:(NSImage *)cacheImage to:(NSSize)windowSize
{
    NSSize old;

    old = (cacheImage != nil) ? [cacheImage size] : NSZeroSize;
    if((windowSize.width != old.width) || (windowSize.height != old.height))
        {
        NSCachedImageRep *rep;
        if(cacheImage != nil)
            [cacheImage release];
        cacheImage = [[NSImage allocWithZone:[self zone]] initWithSize:windowSize];
        rep = [[[NSCachedImageRep allocWithZone:[self zone]] initWithSize:windowSize depth:[NSWindow defaultDepthLimit] separate:YES alpha:YES] autorelease];
        [cacheImage addRepresentation:rep];
        }

    return cacheImage;
}


- (void)_drawTableCache:(NSRect)rowRect
{
    NSRect visibleRect;
    NSRect sourceRect;
    NSPoint origin;

    visibleRect = [self visibleRect];
    sourceRect = rowRect;
    origin = rowRect.origin;
    
    // adjust composite point: seems to need this!
    origin.y += rowRect.size.height;		

    // now the cache is just the visibleRect, so we need to adjust the sourceRect:
    sourceRect.origin.y = NSHeight(visibleRect) + NSMinY(visibleRect) - origin.y;
    [tableCache compositeToPoint:origin fromRect:sourceRect operation:NSCompositeCopy];
    {
        NSRect myRow = [self rectOfRow:draggedRow];
//        NSRect clipRow = myRow;
        myRow.size.height=myRow.size.height+1;
        myRow.origin.y=myRow.origin.y-1;
        NSDrawGrayBezel(myRow,myRow);
        [[NSColor controlShadowColor] set];
        myRow.origin.x=myRow.origin.x+2.0;
        myRow.size.width=myRow.size.width-4.0;

        myRow.origin.y=myRow.origin.y+2.0;
        myRow.size.height=myRow.size.height-4.0;

        NSRectFill(myRow);
    }

}


- (void)_drawRowCache:(NSRect)rowRect
{
    NSRect myRect=rowRect;

    myRect.origin.y += myRect.size.height;
    [rowCache dissolveToPoint:myRect.origin fraction:0.75];
}


//===========================================================================================
    @end
//===========================================================================================


static NSEvent *periodicEventWithLocationSetToPoint(NSEvent *oldEvent, NSPoint point)
{
    return [NSEvent otherEventWithType:[oldEvent type] location:point modifierFlags:[oldEvent modifierFlags] timestamp:[oldEvent timestamp] windowNumber:[oldEvent windowNumber] context:[oldEvent context] subtype:[oldEvent subtype] data1:[oldEvent data1] data2:[oldEvent data2]];
}

