//---------------------------------------------------------------------------------------
//  EDCommon.h created by erik on Sat 05-Sep-1998
//  @(#)$Id: EDCommon.h,v 1.10 2002-07-09 16:02:16 erik Exp $
//
//  Copyright (c) 1998-2001 by Erik Doernenburg. All rights reserved.
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


#ifndef	__EDCommon_h_INCLUDE
#define	__EDCommon_h_INCLUDE


#import <Foundation/Foundation.h>

#import "EDCommonDefines.h"
#import "EDObjcRuntime.h"

#import "NSArray+Extensions.h"
#import "NSAttributedString+Extensions.h"
#import "NSData+Extensions.h"
#import "NSDate+Extensions.h"
#import "NSDictionary+Extensions.h"
#import "NSInvocation+Extensions.h"
#import "NSObject+Extensions.h"
#import "NSProcessInfo+Extensions.h"
#import "NSScanner+Extensions.h"
#import "NSSet+Extensions.h"
#import "NSString+Extensions.h"
#import "CollectionMapping.h"

#import "EDBitmapCharset.h"
#import "EDIRCObject.h"
#import "EDLightWeightLock.h"
#import "EDLRUCache.h"
#import "EDNumberSet.h"
#import "EDObjectPair.h"
#import "EDObjectReference.h"
#import "EDRange.h"
#import "EDRedBlackTree.h"
#import "EDSparseClusterArray.h"
#import "EDStack.h"
#import "EDStringScanner.h"

#import "EDMLParser.h"
#import "EDMLTagProcessorProtocol.h"
#import "EDAOMTagProcessor.h"


#ifndef EDCOMMON_WOBUILD

#import <AppKit/AppKit.h>

#import "NSApplication+Extensions.h"
#import "NSAttributedString+AppKitExtensions.h"
#import "NSMatrix+Extensions.h"
#import "NSPasteboard+Extensions.h"
#import "NSTableColumn+Extensions.h"
#import "NSTableView+Extensions.h"
#import "NSWindow+Extensions.h"
#import "NSWorkspace+Extensions.h"
#import "EDApplication.h"
#import "EDKeyControlWindow.h"
#ifdef EDCOMMON_OSXBUILD
#import "EDToolbarDefinition.h"
#endif // EDCOMMON_OSXBUILD
#import "EDActivityIndicator.h"
#import "EDCanvas.h"
#import "EDObjectWell.h"
#import "EDTableView.h"
#import "EDTVScrollView.h"
#import "EDSwapView.h"

#endif // EDCOMMON_WOBUILD

#endif	/* __EDCommon_h_INCLUDE */
