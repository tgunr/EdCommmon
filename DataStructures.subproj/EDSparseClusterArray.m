//---------------------------------------------------------------------------------------
//  EDSparseClusterArray.m created by erik on Fri 28-May-1999
//  @(#)$Id: EDSparseClusterArray.m,v 1.1.1.1 2000-05-29 00:09:39 erik Exp $
//
//  Copyright (c) 1999 by Erik Doernenburg. All rights reserved.
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
#import "EDSparseClusterArray.h"


@interface EDSparseClusterArray(PrivateAPI)
- (NSMapTable *)_pageTable;
- (unsigned int)_pageSize;
@end


@interface _EDSCAEnumerator : NSEnumerator
{
    EDSparseClusterArray *array;
    unsigned int		 *pnumList;
    unsigned int		 pnlCount, pageSize;
    unsigned int		 pnlidx, eidx;
}
- (id)initWithSparseClusterArray:(EDSparseClusterArray *)anArray;
@end


void EDSCARetain(NSMapTable *table, const void *page);
void EDSCARelease(NSMapTable *table, void *page);
NSString *EDSCADescribe(NSMapTable *table, const void *page);
int EDSCACompare(const void *a, const void *b); 


typedef struct
{
    unsigned int active;
    unsigned int retainCount;
    id 		 	 entries[0];
} EDSCAPage;



//---------------------------------------------------------------------------------------
    @implementation EDSparseClusterArray
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- init
{
    [super init];

    pageTable = NSCreateMapTableWithZone(NSIntMapKeyCallBacks, (NSMapTableValueCallBacks) { EDSCARetain, EDSCARelease, EDSCADescribe }, 0, [self zone]);
    pageSize = (NSPageSize() - sizeof(EDSCAPage)) / sizeof(id);
    
    return self;
}


- (void)dealloc
{
    NSFreeMapTable(pageTable);
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	DESCRIPTION & COMPARISONS
//---------------------------------------------------------------------------------------

- (NSString *)description
{
    return [NSString stringWithFormat: @"<%@ 0x%x: %@>", NSStringFromClass(isa), (void *)self, [self allObjects]];
}


//---------------------------------------------------------------------------------------
//	PRIVATE ACCESSOR METHODS
//---------------------------------------------------------------------------------------

- (NSMapTable *)_pageTable
{
    return pageTable;
}


- (unsigned int)_pageSize
{
    return pageSize;
}


//---------------------------------------------------------------------------------------
//	STORING/RETRIEVING OBJECTS BY INDEX
//---------------------------------------------------------------------------------------

- (void)setObject:(id)anObject atIndex:(unsigned int)index
{
    unsigned int	pnum, eidx;
    EDSCAPage		*page;
    id				previousObject;

    if(anObject == nil)
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to insert *nil* at index %d.", NSStringFromClass(isa), NSStringFromSelector(_cmd), index];
    
    pnum = index / pageSize;
    eidx = index % pageSize;

    if((page = NSMapGet(pageTable, (void *)pnum)) == NULL)
        {
        page = NSAllocateMemoryPages(1); // rounded up to page size...
        NSMapInsertKnownAbsent(pageTable, (void *)pnum, page);
        }

    if((previousObject = page->entries[eidx]) != nil)
        [previousObject release];
    else
        page->active += 1;

    page->entries[eidx] = [anObject retain];
}


- (void)removeObjectAtIndex:(unsigned int)index
{
    unsigned int	pnum, eidx;
    EDSCAPage		*page;

    pnum = index / pageSize;
    eidx = index % pageSize;

    if(((page = NSMapGet(pageTable, (void *)pnum)) == NULL) || ((page->entries[eidx]) == nil))
        [NSException raise:NSInvalidArgumentException format:@"-[%@ %@]: Attempt to remove an object that is not in the array (index %d).", NSStringFromClass(isa), NSStringFromSelector(_cmd), index];

    [page->entries[eidx] release];
    page->entries[eidx] = nil;
    page->active -= 1;

    if(page->active == 0)
        NSMapRemove(pageTable, (void *)pnum);
}


- (id)objectAtIndex:(unsigned int)index
{
    unsigned int	pnum, eidx;
    EDSCAPage		*page;

    pnum = index / pageSize;
    eidx = index % pageSize;

    if(((page = NSMapGet(pageTable, (void *)pnum)) == NULL) || ((page->entries[eidx]) == nil))
        return nil;

    return page->entries[eidx];
}


//---------------------------------------------------------------------------------------
//	ACCESSING THE OBJECT SET
//---------------------------------------------------------------------------------------

- (unsigned int)count
{
    NSMapEnumerator	mapEnum;
    unsigned int	count, pnum;
    EDSCAPage		*page;
    
    count = 0;
    mapEnum = NSEnumerateMapTable(pageTable);
    while(NSNextMapEnumeratorPair(&mapEnum, (void **)&pnum, (void **)&page))
        count += page->active;

    return count;
}


- (NSEnumerator *)indexEnumerator
{
    return [[[_EDSCAEnumerator allocWithZone:[self zone]] initWithSparseClusterArray:self] autorelease];
}


- (NSArray *)allObjects
{
    
    NSMutableArray	*allObjects;
    EDSCAPage		*page;
    NSMapEnumerator	mapEnum;
    id				entry;
    unsigned int	*pnumList, pnlCount, pnum, pnlidx, eidx;
    
    pnlCount = NSCountMapTable(pageTable);
    pnumList = NSZoneMalloc([self zone], pnlCount * sizeof(int));
    mapEnum = NSEnumerateMapTable(pageTable);
    pnlidx = 0;
    while(NSNextMapEnumeratorPair(&mapEnum, (void **)&pnum, (void **)&page))
        pnumList[pnlidx++] = pnum;
    qsort(pnumList, pnlCount, sizeof(int), EDSCACompare);

    pnlidx = 0;
    allObjects = [[[NSMutableArray allocWithZone:[self zone]] init] autorelease];
    while(pnlidx < pnlCount)
        {
        page = NSMapGet(pageTable, (void *)pnumList[pnlidx++]);
        eidx = 0;
        while(eidx < pageSize)
            {
            if((entry = page->entries[eidx++]) != nil)
                [allObjects addObject:entry];
            }
        }

    NSZoneFree([self zone], pnumList);

    return allObjects;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation _EDSCAEnumerator
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	INIT & DEALLOC
//---------------------------------------------------------------------------------------

- (id)initWithSparseClusterArray:(EDSparseClusterArray *)anArray
{
    EDSCAPage		*page;
    NSMapEnumerator mapEnum;
    unsigned int	pnum;
    
    [super init];
    
    array = [anArray retain];
    pageSize = [array _pageSize];
    pnlCount = NSCountMapTable([array _pageTable]);
    pnumList = NSZoneMalloc([self zone], pnlCount * sizeof(int));
    mapEnum = NSEnumerateMapTable([array _pageTable]);
    pnlidx = 0;
    while(NSNextMapEnumeratorPair(&mapEnum, (void **)&pnum, (void **)&page))
        pnumList[pnlidx++] = pnum;
    qsort(pnumList, pnlCount, sizeof(int), EDSCACompare);
    pnlidx = 0;
    eidx = 0;
    
    return self;
}


- (void)dealloc
{
    NSZoneFree([self zone], pnumList);
    [array release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
//	ENUMERATOR INTERFACE IMPLEMENTATION
//---------------------------------------------------------------------------------------

- (id)nextObject
{
    EDSCAPage	 *page;
    id 			 entry;
    unsigned int index;

    entry = nil; index = 0;
    while((entry == nil) && (pnlidx < pnlCount))
        {
        page = NSMapGet([array _pageTable], (void *)pnumList[pnlidx]);
        while((entry == nil) && (eidx < pageSize))
            entry = page->entries[eidx++];

        index = pnumList[pnlidx] * pageSize + eidx - 1;

        if(eidx >= pageSize)
            {
            pnlidx += 1;
            eidx = 0;
            }
        }

    return (entry != nil) ? [NSNumber numberWithUnsignedInt:index] : nil;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
//	VALUE CALL BACK FUNCTIONS
//---------------------------------------------------------------------------------------

void EDSCARetain(NSMapTable *table, const void *page)
{
    //NSLog(@"#p# retain %@", EDSCADescribe(table, page));
    ((EDSCAPage *)page)->retainCount += 1;
}


void EDSCARelease(NSMapTable *table, void *page)
{
    //NSLog(@"#p# release %@", EDSCADescribe(table, page));
    ((EDSCAPage *)page)->retainCount -= 1;
    if(((EDSCAPage *)page)->retainCount < 1)
        NSDeallocateMemoryPages(page, 1);
}


NSString *EDSCADescribe(NSMapTable *table, const void *page)
{
    const EDSCAPage *p = page;
    return [NSString stringWithFormat:@"{ rcount = %d; active = %d }", p->retainCount, p->active];
}


//---------------------------------------------------------------------------------------
//	SORT CALLBACK FUNCTION
//---------------------------------------------------------------------------------------

int EDSCACompare(const void *a, const void *b)
{
    // okay, they are unsigned ints, but this way it's easy and
    // the numbers cannot be that large anyway.
    return *(int *)a - *(int *)b;
}



