//
//  Environment.m
//  Blipboard
//
//  Created by Jason Fischl on 1/9/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
// see http://blog.carbonfive.com/2011/06/20/managing-ios-configurations-per-environment-in-xcode-4/ for my inspiration.

#import "BBLog.h"
#import "BBEnvironment.h"

@implementation BBEnvironment

static BBEnvironment* sharedInstance = nil;

-(void) initializeSharedInstance
{
    _APIUrlChoices = [API_URLS componentsSeparatedByString:@","];
    _index = 0;
 
#if !defined CONFIGURATION_Release
    NSString* configuration = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"Configuration"];
    BBLog(@"initialize URL(config:%@): %@", configuration, _APIUrlChoices);
#endif
    
    // use default value if didn't retrieve anything from the plist
    if (_APIUrlChoices == nil) {
        _APIUrlChoices = @[@"https://api.blipboard.com"];
    }
}

+ (BBEnvironment *)sharedEnvironment
{
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [[self alloc] init];
            [sharedInstance initializeSharedInstance];
        }
        return sharedInstance;
    }
}

-(NSString*) apiURL
{
    return [_APIUrlChoices objectAtIndex:_index];
}

-(NSString*) next_apiURL
{
    _index++;
    _index = _index % [_APIUrlChoices count];
    return [self apiURL];
}

@end
