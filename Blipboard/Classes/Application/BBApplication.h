//
//  BBApplication.h
//  Blipboard
//
//  Created by cktam on 8/24/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BBApplication : UIApplication

+(BBApplication *)sharedApplication;
-(BOOL)openURL:(NSURL *)url;
-(BOOL)openURL:(NSURL *)url forceOpenInSafari:(BOOL)forceOpenInSafari;

@end