//
//  Liker.m
//  Blipboard
//
//  Created by Jason Fischl on 6/2/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Liker.h"

@implementation Liker

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"id",                 @"id", // user id
     @"name",               @"name",
     @"createdTime",        @"createdTime",
     nil];
    return mapping;
}


@end
