//---------------------------------------------------------------------------------------
//  EDApplication.m created by erik on Sun 19-Jul-1998
//  @(#)$Id: EDApplication.m,v 1.3 2002-07-02 16:25:01 erik Exp $
//
//  Copyright (c) 1998 by Erik Doernenburg. All rights reserved.
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
#import "NSApplication+Extensions.h"
#import "EDApplication.h"

void EDUncaughtExceptionHandler(NSException *exception);

#define LS_TOPLEVEL_EXCEPTION(APPNAME, EXNAME, EXREASON) \
[NSString stringWithFormat:NSLocalizedString(@"An unexpected error has occured which may cause %@ to malfunction. You may want to save copies of your open documents and quit %@.\n\n%@: %@", "Text for the alert panel to report uncaught exceptions."), APPNAME, APPNAME, EXNAME, EXREASON]

#define LS_OK \
NSLocalizedString(@"Such is life", "For buttons unexpected error panel.")


//---------------------------------------------------------------------------------------
    @implementation EDApplication
//---------------------------------------------------------------------------------------

//---------------------------------------------------------------------------------------
//	OVERRIDES
//---------------------------------------------------------------------------------------

- init
{
    [super init];
    NSSetUncaughtExceptionHandler(EDUncaughtExceptionHandler);
    return self;
}


- (void)finishLaunching
{
    [self registerFactoryDefaults];
    [super finishLaunching];
}


- (void)reportException:(NSException *)theException
{
    NSLog(@"%@: %@", [theException name], [theException reason]);
    NSRunAlertPanel(nil, LS_TOPLEVEL_EXCEPTION([self name], [theException name], [theException reason]), LS_OK, nil, nil);
}


//---------------------------------------------------------------------------------------
    @end
//---------------------------------------------------------------------------------------



//---------------------------------------------------------------------------------------
//	EXCEPTION HANDLER
//---------------------------------------------------------------------------------------

void EDUncaughtExceptionHandler(NSException *exception)
{
    [[NSApplication sharedApplication] reportException:exception];
}

