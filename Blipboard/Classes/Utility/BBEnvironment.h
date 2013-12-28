//
//  Environment.h
//  Blipboard
//
//  Created by Jason Fischl on 1/9/13.
//  Copyright (c) 2013 Blipboard. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBEnvironment : NSObject {
    int _index;
    NSArray* _APIUrlChoices;
}

-(NSString*) apiURL;
-(NSString*) next_apiURL; // advance to next choice of API

+ (BBEnvironment *)sharedEnvironment;

@end
