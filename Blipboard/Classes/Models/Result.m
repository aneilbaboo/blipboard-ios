//
//  Result.m
//  Blipboard
//
//  Created by Jason Fischl on 3/9/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Result.h"

@implementation Result

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:@"",@"result",nil];
    return mapping;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"result=%@",self.result];
}

@end
