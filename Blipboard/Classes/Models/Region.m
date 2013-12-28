//
//  Region.m
//  Blipboard
//
//  Created by Jason Fischl on 5/10/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Region.h"

@implementation Region

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    [mapping mapKeyPathsToAttributes:
     @"latitude", @"latitude",
     @"longitude", @"longitude",
     @"radius",@"radius",
     nil];
    return mapping;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"[Region %f,%f %fm]",
            self.latitude.floatValue,
            self.longitude.floatValue,
            self.radius.floatValue];
}
@end
