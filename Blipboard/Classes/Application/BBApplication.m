//
//  BBApplication.m
//  Blipboard
//
//  Created by cktam on 8/24/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBApplication.h"
#import "BBLog.h"
#import "NIWebController.h"
#import "BBAppDelegate.h"

@implementation BBApplication

+ (BBApplication *)sharedApplication {
    return (BBApplication *)[super sharedApplication];
}

- (BOOL)openURL:(NSURL *)url
{
    return [self openURL:url forceOpenInSafari:[self mustOpenURLInSafari:url]];
}

-(BOOL)mustOpenURLInSafari:(NSURL *)url {
    NSString *urlString = [[url absoluteString] lowercaseString];
    NSError *regexError;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^https?://(m.)?facebook.com/dialog/oauth" options:NSRegularExpressionCaseInsensitive error:&regexError];
    
    NSArray *matches = [regex matchesInString:urlString options:0 range:NSMakeRange(0, urlString.length)];
    
    return matches.count>0;
}

-(BOOL)openURL:(NSURL *)url forceOpenInSafari:(BOOL)forceOpenInSafari
{
    BBLog(@"%@",url);

    if(forceOpenInSafari)
    {
        return [super openURL:url];
    }
    
    // Otherwise, we'll see if it is a request that we should let our app open.
    if ([[FBSession activeSession] handleOpenURL:url]) {
        return YES;
    }
    else {
    
        BOOL couldWeOpenUrl = NO;
        
        NSString* scheme = [url.scheme lowercaseString];
        if([scheme compare:@"http"] == NSOrderedSame
           || [scheme compare:@"https"] == NSOrderedSame)
        {
            // Check for situations where we don't want to use the web controller.
            
            // If Facebook session is valid, then proceed.
            if (FBSession.activeSession.isOpen)
            {
                BBLog(@"Pass to app delegate to handle URL");
                couldWeOpenUrl = [(BBAppDelegate*)self.delegate openURL:url ];
            }
        }
        
        if(!couldWeOpenUrl)
        {
            BBLog(@"Can't handle URL.  Let Safari handle it");
            return [super openURL:url];
        }
        else
        {
            return YES;
        }
    }
}

@end
