//
//  main.m
//  Blipboard
//
//  Created by Jason Fischl on 1/26/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "BBAppDelegate.h"

int main(int argc, char *argv[])
{
    @autoreleasepool {
#ifdef LOGGER_TARGET
        NSString* service = LOGGER_TARGET;
#else
        NSString* service = @"bb";
#endif
        LoggerSetupBonjour(NULL, NULL, (__bridge CFStringRef)service);
        
        NSString *logBufferPath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"bb.rawnsloggerdata"];
        LoggerSetBufferFile(NULL, (__bridge CFStringRef)logBufferPath);
        LoggerSetOptions(NULL, LOGGER_DEFAULT_OPTIONS);
        
        return UIApplicationMain(argc, argv, @"BBApplication", NSStringFromClass([BBAppDelegate class]));
    }
}
