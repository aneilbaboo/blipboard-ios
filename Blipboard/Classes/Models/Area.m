//
//  Area.m
//  Blipboard
//
//  Created by Jason Fischl on 8/16/12.
//  Copyright (c) 2012 Blipboard. All rights reserved.
//

#import "Area.h"
#import "Location.h"

@implementation Bounds

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    
    [mapping mapKeyPath:@"southwest" toRelationship:@"southwest" withMapping:Location.mapping];
    [mapping mapKeyPath:@"northeast" toRelationship:@"northeast" withMapping:Location.mapping];

    return mapping;
}

@end


@implementation Area

+(RKObjectMapping *)mapping {
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[self class]];
    
    [mapping mapKeyPathsToAttributes:
     @"name", @"name",
     nil];
    [mapping mapKeyPath:@"bounds" toRelationship:@"bounds" withMapping:Bounds.mapping];

    return mapping;
}

-(NSString *) description {
    return [NSString stringWithFormat:@"Area: %@ [%@,%@|%@,%@]",
            self.name,
            self.bounds.southwest.latitude, self.bounds.southwest.longitude,
            self.bounds.northeast.latitude, self.bounds.northeast.longitude];
}

@end
