//---------------------------------------------------------------------------------------
//  EDXMLCharacterData.m created by erik on Sat Mar 29 2003
//  @(#)$Id: EDXMLCharacterData.m,v 1.1 2003-05-26 19:52:35 erik Exp $
//
//  Copyright (c) 2002-2003 by Helge Hess, Erik Doernenburg. All rights reserved.
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

#import <Foundation/Foundation.h>
#include "EDXMLNode+Private.h"
#include "EDXMLCharacterData.h"


//---------------------------------------------------------------------------------------
    @implementation EDXMLCharacterData
//---------------------------------------------------------------------------------------

- (void)dealloc {
    [self->data release];
    [super dealloc];
}


//---------------------------------------------------------------------------------------
// dom impl
//---------------------------------------------------------------------------------------

/* accessors */

- (void)setData:(NSString *)_data {
    id old = self->data;
    self->data = [_data copy];
    [old release];
}

- (NSString *)data {
    return self->data;
}

- (unsigned)length {
    return [self->data length];
}

/* operations */

- (NSString *)substringData:(unsigned)_offset count:(unsigned)_count {
    return [self->data substringWithRange:NSMakeRange(_offset, _count)];
}

- (void)appendData:(NSString *)_data {
    id old = self->data;
    self->data = old ? [old stringByAppendingString:_data] : _data;
    [old release];
}

- (void)insertData:(NSString *)_data offset:(unsigned)_offset {
    id new, old;
    old = self->data;
    new = [old mutableCopy];
    [new insertString:_data atIndex:_offset];
    self->data = [new copy];
    [old release];
}

- (void)deleteData:(unsigned)_offset count:(unsigned)_count {
    id new, old;
    old = self->data;
    new = [old mutableCopy];
    [new deleteCharactersInRange:NSMakeRange(_offset, _count)];
    self->data = [new copy];
    [old release];
}

- (void)replaceData:(unsigned)_offset count:(unsigned)_c with:(NSString *)_s {
    id new, old;
    old = self->data;
    new = [old mutableCopy];
    [new replaceCharactersInRange:NSMakeRange(_offset, _c) withString:_s];
    self->data = [new copy];
    [old release];
}



//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------


//---------------------------------------------------------------------------------------
    @implementation EDXMLCharacterData(Private)
//---------------------------------------------------------------------------------------

- (id)initWithString:(NSString *)_s {
    if ((self = [super init])) {
        self->data = [_s copyWithZone:[self zone]];
    }
    return self;
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------
