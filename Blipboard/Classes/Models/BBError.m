//
//  BBError.m
//  Blipboard
//
//  Created by Jason Fischl on 4/18/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "BBError.h"

@implementation BBError

-(NSString *) description {
    return [NSString stringWithFormat:@"BBError: code=%d msg=%@ type=%@", 
            self.statusCode,
            self.message, 
            self.type];
}

+(RKObjectMapping *)mapping { 
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"message", @"message",
     @"type", @"type",
     nil];
    mapping.rootKeyPath = @"error";
    return mapping;
}


@end
