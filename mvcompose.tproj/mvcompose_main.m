//---------------------------------------------------------------------------------------
//  mvcompose_main.h created by ProjectBuilder
//  @(#)$Id: mvcompose_main.m,v 1.1.1.1 2000-05-29 00:09:40 erik Exp $
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

#import <Foundation/Foundation.h>

extern BOOL MVLaunchComposeWindow(id textStorage, NSDictionary *headerDictionary);


int main (int argc, const char *argv[])
{
    NSAutoreleasePool 		*pool;
    NSMutableDictionary	  	*headerDictionary;
    NSEnumerator			*argEnum;
    NSString				*option, *value, *body;
    int						exitCode;

    pool = [[NSAutoreleasePool alloc] init];

    NS_DURING

    headerDictionary = [NSMutableDictionary dictionary];
    argEnum = [[[NSProcessInfo processInfo] arguments] objectEnumerator];
    [argEnum nextObject]; // skip path to executable
    while((option = [argEnum nextObject]) != nil)
        {
        if(([option hasPrefix:@"-"] == NO) || ([option length] < 2))
            [NSException raise:NSGenericException format:@"Invalid header specification; found '%@'", option];
        value = [argEnum nextObject];
        if((value == nil) || ([value hasPrefix:@"-"]))
            [NSException raise:NSGenericException format:@"Missing value for '%@'", option];
        [headerDictionary setObject:value forKey:[option substringFromIndex:1]];
        }

    body = @"";
    MVLaunchComposeWindow([[[NSAttributedString alloc] initWithString:body] autorelease], headerDictionary);
    exitCode = 0;

    NS_HANDLER
        fprintf(stderr, "%s", [[localException reason] cString]);
        exitCode = 1;
    NS_ENDHANDLER

    [pool release];

    exit(exitCode);
}
